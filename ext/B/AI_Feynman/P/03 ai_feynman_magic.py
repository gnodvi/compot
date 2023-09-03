from S_run_aifeynman import run_aifeynman
# Make sure your path to the AI-Fetnman directory is correct. 
# I have used a base directory of /content because that's where a Collab notebook puts the cloned repo
# Change this to the spot in your machine where you are working from if you need to
run_aifeynman("/content/AI-Feynman/example_data/","example1.txt",30,"14ops.txt", polyfit_deg=3, NN_epochs=400)