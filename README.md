# Dockerized speech recognition with Kaldi + Pop Up Archive models

### References

  - Kaldi: [http://kaldi-asr.org/](http://kaldi-asr.org/)
  - Pop Up Archive Kaldi release and install guide: [https://github.com/popuparchive/american-archive-kaldi](https://github.com/popuparchive/american-archive-kaldi)
  - PUA model files: [https://sourceforge.net/projects/popuparchive-kaldi/files/](https://sourceforge.net/projects/popuparchive-kaldi/files/)
  - American Archive of Public Broadcasting (source of training set): [http://americanarchive.org/](http://americanarchive.org/)

### Setup notes

- Pull image from Docker Hub (12GB compressed, 24GB uncompressed).

```
docker pull hipstas/kaldi-pop-up-archive
```

- Run Docker container, adjusting memory allowance and location of shared folder as needed (>=16 GB RAM recommended).

*Linux:*

```
docker run -it --name kaldi_pua -m 16g --volume /audio_in/:/audio_in/ hipstas/kaldi-pop-up-archive:v1
```

*macOS:*

```
docker run -it --name kaldi_pua -m 16g --volume ~/Desktop/audio_in/:/audio_in/ hipstas/kaldi-pop-up-archive:v1
```

*Windows:*

```
docker run -it --name kaldi_pua -m 16g --volume C:\Users\***username_here***\Desktop\audio_in\:/audio_in/ hipstas/kaldi-pop-up-archive:v1
```



### Run speech-to-text batch

- Add media files to `/audio_in/` (WAV, MP3, or MP4 video).

- Download and run `setup.sh`, which will make a few configuration tweaks and start your job. When the batch is finished, your plain text and JSON transcript files will be written to `/audio_in/transcripts/`.

```
wget https://raw.githubusercontent.com/hipstas/kaldi-pop-up-archive/master/setup.sh
sh ./setup.sh
```

To keep your job from ending when you close the terminal window (or your connection to the server is interrupted), use `nohup sh ./setup.sh` instead, then close the window. If you'd like to monitor the job's status, open a new terminal session and use the following command to display the end of your `nohup` log file every 3 seconds:

```
while :; do tail -n 30 nohup.out; sleep 3; done
```


### Notes

- Try running a test with one or two short media files before beginning a big job. If Kaldi doesn't have enough memory, it will crash without explanation. If this happens, try reducing the number of simultaneous jobs as described above.

- Any commas, spaces, pipes, etc. in audio filenames will break the script and halt progress without producing any descriptive errors. To be safe, you may want to rename each file with a unique ID before starting. I'll fix this when I get a chance.

- With this configuration, speech-to-text processing may take 5 times the duration of your audio input, or perhaps even longer. If you have memory to spare, you can speed things up by increasing the number of simultaneous jobs. Use the `free -m` command while Kaldi is running to see how you're doing.



### Optional performance tweaks

- In `/kaldi/egs/american-archive-kaldi/sample_experiment/run.sh`, adjust the following option to set the number of simultaneous jobs:

```
nj=4
```

- In `/kaldi/egs/wsj/s5/utils/run.pl`:

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



### Manual method

Alternately, you can prepare your files and start the batch run manually.

- Add some media files to the `/audio_in/` directory.

```
mkdir /audio_in/
cd /audio_in/
```

- Make a 16kHz WAV copy of each file with `ffmpeg`.

```
for file in *.{wav,mp3,mp4,WAV,MP3,MP4}; do
base=$(basename """$file""" .mp3);
ffmpeg -i """$file""" -ac 1 -ar 16000 """$base"""_16kHz.wav;
done
```

- Now move the 16kHz WAV files to a separate directory.

```
mkdir /audio_in_16khz/
mv *_16kHz.wav /audio_in_16khz/
```

- Start the batch transcription run like so.

```
python /kaldi/egs/american-archive-kaldi/run_kaldi.py /kaldi/egs/american-archive-kaldi/sample_experiment/ /audio_in_16khz/
```

- When Kaldi finishes processing an audio file, plain text and JSON transcripts will be written here:

```
/kaldi/egs/american-archive-kaldi/sample_experiment/output/
```
