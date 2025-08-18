import subprocess

print(subprocess.run(["sh 0_install_prerequisites/setup-chroma.sh"], shell=True))