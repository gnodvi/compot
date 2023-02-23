git clone https://github.com/SJ001/AI-Feynman.git
# fix the requirements.txt if it is still broken (full details in the notebook I supplied above)
pip install -r AI-Feynman/requirements.txt
# Make sure gfortran is installed
gfortran --version
sudo apt-get install csh
# Fix permission issue if it is still a problem in the version you cloned
chmod +777 AI-Feynman/Code/*
# Compile
cd AI-Feynman/Code/ && ./compile.sh