# Kaldi PUA

## References
  - Kaldi: [http://kaldi-asr.org/](http://kaldi-asr.org/)
  - Pop Up Archive Kaldi release and install guide: [https://github.com/popuparchive/american-archive-kaldi](https://github.com/popuparchive/american-archive-kaldi)
  - PUA model files: [https://sourceforge.net/projects/popuparchive-kaldi/files/](https://sourceforge.net/projects/popuparchive-kaldi/files/)
  - American Archive of Public Broadcasting (source of training set): [http://americanarchive.org/](http://americanarchive.org/)

## Setup notes

Pull image from Docker Hub (11GB compressed, 24GB uncompressed).

```
docker pull hipstas/kaldi-pop-up-archive
```

Run container, adjusting memory allowance and location of shared folder as needed (>=16 GB RAM recommended).

```
docker run -it --name kaldi_pua -m 16g --volume ~/Desktop/audio_in/:/audio_in/ hipstas/kaldi-pop-up-archive
```

## Optional performance tweaks

In `/kaldi/egs/american-archive-kaldi/sample_experiment/run.sh`, set the following option to reduce the number of simultaneous jobs:

```
nj=4
```

In `/kaldi/egs/wsj/s5/utils/run.pl`, set the following option:

```
$max_jobs_run = 10;
```

In `/kaldi/egs/wsj/s5/steps/decode_fmllr.sh`:

<!--
`/kaldi/egs/wsj/s5/steps/tandem/decode_fmllr.sh`
-->

```
nj=4 in
max_active=2000
```

- In `/kaldi/egs/wsj/s5/steps/decode.sh`:

```
nj=2
```


## Run speech-to-text batch

- Add media files to `/audio_in/` (WAV, MP3, or MP4 video).

- Download and run `setup.sh`, which will make a few configuration tweaks and start your job. When the batch is finished, your txt and json transcript files will be written to `/audio_in/transcripts/`.

```
wget https://raw.githubusercontent.com/hipstas/kaldi-pop-up-archive/master/setup.sh
sh ./setup.sh
```


## Manual method

Alternately, you can start the batch manually. (You'll need to run the first chunk of `setup.sh` by hand first.)

Create `/audio_in/` directory and add media files.

```
mkdir /audio_in/
cd /audio_in/
```

- Create 16kHz copies with `ffmpeg`.

```
for file in *.{wav,mp3,mp4,WAV,MP3,MP4}; do
base=$(basename """$file""" .mp3);
ffmpeg -i """$file""" -ac 1 -ar 16000 """$base"""_16kHz.wav;
done
```

- Start the batch run.

```
python /kaldi/egs/american-archive-kaldi/run_kaldi.py /kaldi/egs/american-archive-kaldi/sample_experiment/ /audio_in/
```

- When the batch is complete, plain text and JSON transcripts will be created here:

```
/kaldi/egs/american-archive-kaldi/sample_experiment/
```

## Notes

- Any commas, spaces, pipes, etc. in audio filenames will break the script and halt progress (without producing any descriptive errors). To be safe, you might want to rename each file with a unique ID before starting.

- With this configuration, speech-to-text processing will take roughly 5 times the duration of your audio input, or possibly more on a home computer.
