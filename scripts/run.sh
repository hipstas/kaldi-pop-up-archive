#!/bin/bash 

# Written by Cantab Research Ltd for use by American Public Media (APM), June 2014.
# Dependencies: Kaldi, CMUseg_0.5, sox

PREFIX=$(dirname $0)
PATHSETTER=$PREFIX/set-kaldi-path.sh
. $PATHSETTER
TMPDIR=/var/extra/audio/work

nj=1
decode_nj=1
lmw=14.0
amw=`echo $lmw | awk '{print 1/$1}'`
#amw=0.083333
QUEUE=false

if [ $# -ne 2 ] ; then
  echo "syntax: $0 <wavFile> <outputFile>" 
  exit 1
fi

if [ ! -f "$1" ] ; then
  echo "Can't find input .wav file"
  exit 1
fi

INPUT=$1
OUTPUT=$2
wavName=$(basename ${INPUT/%.wav})
WORK=$TMPDIR/audio-tmp-$wavName-$$

if [ $QUEUE == true ]; then
  source $PREFIX/scripts/qq.sh
  train_cmd=queue.pl 
  decode_cmd=queue.pl
else
  train_cmd=run.pl 
  decode_cmd=run.pl
fi

mkdir -p $WORK

echo "=================== Segmenting audio ================="
cp $INPUT $WORK/$wavName.wav
echo $wavName | perl -pe "s:^:$WORK/tmp-rec/:" | perl -pe 's:^(.*)/.*$:$1:' | sort -u | xargs --no-run-if-empty mkdir -p

rm -f $WORK/splitFiles.dbl
$PREFIX/scripts/wav2pem $WORK/$wavName.wav $WORK/tmp-rec/$wavName.pem $PREFIX/tools

if [ ! -f "$WORK/tmp-rec/$wavName.pem" ]; then
    echo "Failed to create $WORK/tmp-rec/$wavName.pem"
    exit
fi

cat $WORK/tmp-rec/$wavName.pem | egrep -v '^;;' | while read dummy chan spkr init quit cond ; do
  durn=`printf "%.2f" $(perl -e "print $quit-$init")`
  needSplit=$(awk 'BEGIN{ print ('$durn' > 45) }')
  if [ "$needSplit" -eq 1 ];then
    durn2=$(awk 'BEGIN{ print ('$durn' / 2) }')
    init2=$(awk 'BEGIN{ print ('$durn2' + '$init') }')
    wav1=$WORK/tmp-rec/$wavName-$init+$durn2.wav
    wav2=$WORK/tmp-rec/$wavName-$init2+$durn2.wav
    sox $WORK/$wavName.wav $wav1 trim $init $durn2      
    sox $WORK/$wavName.wav $wav2 trim $init2 $durn2
    echo $wavName-$init+$durn2 >> $WORK/splitFiles.dbl
    echo $wavName-$init2+$durn2 >> $WORK/splitFiles.dbl
  else
    wav=$WORK/tmp-rec/$wavName-$init+$durn.wav
    sox $WORK/$wavName.wav $wav trim $init $durn
    echo $wavName-$init+$durn >> $WORK/splitFiles.dbl
  fi
done

echo "=================== Preparing data =================="
export LC_ALL=C
dataPrep=$WORK/dataPrep
mkdir -p $dataPrep
n=`cat $WORK/splitFiles.dbl | wc -l`
seq $n | awk '{ printf("%05d\n", $1) }' > $dataPrep/nums
cat -n $WORK/splitFiles.dbl | awk -v w=$WORK/tmp-rec '{ printf("%05d", $1); print " "w"/"$2".wav" }' > $dataPrep/wav.scp
paste $dataPrep/nums $dataPrep/nums > $dataPrep/utt2spk

# PATH is wonky so just run relative to our tools
cd $PREFIX
cat $dataPrep/utt2spk | sort -k 2 | utils/utt2spk_to_spk2utt.pl > $dataPrep/spk2utt
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" --mfcc-config exp/mfcc.conf $dataPrep exp/make_mfcc/test $WORK/mfcc
steps/compute_cmvn_stats.sh $dataPrep exp/make_mfcc/test $WORK/mfcc

echo "=================== Decoding ===================="
decodeDirF=exp/tri3/decode-$wavName
decodeDir=exp/tri3_mmi_b0.1/decode-$wavName
decodeDirR=exp/tri3_rescore/decode-$wavName
mkdir $decodeDirR
steps/decode_fmllr.sh --nj $decode_nj --cmd "$decode_cmd" --acwt $amw --skip_scoring true exp/tri3/graph $dataPrep $decodeDirF
steps/decode.sh --transform-dir $decodeDirF --nj $decode_nj --cmd "$decode_cmd" --acwt $amw --skip_scoring true exp/tri3/graph $dataPrep $decodeDir
steps/lmrescore_const_arpa.sh --cmd "$decode_cmd" --skip_scoring true exp/lang_newlm exp/lang_lmrescore $dataPrep $decodeDir $decodeDirR
lattice-1best --lm-scale=$lmw "ark:gunzip -c $decodeDirR/lat.*.gz|" ark:- | lattice-align-words exp/lang_lmrescore/phones/word_boundary.int exp/tri3_mmi_b0.1/final.mdl ark:- ark:- | nbest-to-ctm ark:- - | utils/int2sym.pl -f 5 exp/lang_newlm/words.txt > $WORK/timings.all.txt

echo "================== Writing output ================"
echo "#!MLF!#" > $WORK/tmp.mlf
scale=10000000
cat $dataPrep/wav.scp | while read line; do
  num=`echo $line | awk '{print $1}'`
  name=`echo $line | awk '{print $2}'`
  echo "\"${name/%.wav/.rec}\"" >> $WORK/tmp.mlf
  egrep "^$num " $WORK/timings.all.txt | awk -v s=$scale '{printf "%.0f", s*$3 ; printf " " ; printf "%.0f", s*$4 ; print " "$5;}' >> $WORK/tmp.mlf
  echo "." >> $WORK/tmp.mlf
done

awk '{print $2}' $dataPrep/wav.scp | sed 's/.wav//g' > $WORK/tmp.scp
scripts/kaldi2json.pl $WORK/tmp.scp $WORK/tmp.mlf > $OUTPUT

echo "================== Cleaning up =================="
#rm -rf $WORK $decodeDir* $decodeDirF* exp/make_mfcc
