import os, sys, subprocess, json2txt

expt_dir = sys.argv[1] #where experiment kaldi setup is stored, incl local scripts
wav_dir = sys.argv[2]
expt_name = os.path.basename(expt_dir)

if len(sys.argv) != 3:
	print 'USAGE: run_kaldi.py <expt_dir> <wav_dir>'

os.chdir(expt_dir)
print 'Entering experiment dir. Validating...'
expected = ['exp', 'run.sh', 'scripts', 'steps', 'tools', 'utils']
for p in expected:
	if not os.path.exists(p):
		raise Exception('Invalid experiment setup. Required: exp, run.sh, scripts, steps, tools, utils')
print 'Valid experiment dir'

if not os.path.exists('output'):
	os.mkdir('output')
	os.mkdir('output/json')
	os.mkdir('output/txt')

# print 'Running kaldi on each file'
#run kaldi and convert output to txt file
for f in os.listdir(wav_dir):
	print f
	f_base = f[:-4]
	f_path = os.path.join(wav_dir, f)
	json_file = 'output/json/{}.json'.format(f_base)
	json_file = os.path.join(os.getcwd(), 
		'output', 'json', '{}.json'.format(f_base))
	subprocess.call(['./run.sh', f_path, json_file]) #main kaldi call
	txt_file = os.path.join(os.getcwd(), 
		'output', 'txt', '{}.txt'.format(f_base))
	json2txt.convert(json_file, txt_file)
