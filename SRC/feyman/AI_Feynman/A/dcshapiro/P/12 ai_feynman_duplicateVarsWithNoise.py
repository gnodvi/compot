from S_run_aifeynman import run_aifeynman
# Make sure your path to the AI-Fetnman directory is correct. 
# I have used a base directory of /content/gdrive/... because that's where I put the code in Google Drive
# Change this to the spot in your machine where you are working from, if you need to
run_aifeynman("/content/gdrive/My Drive/Lemay.ai_research/AI-Feynman/example_data/","duplicateVarsWithNoise.txt",30,"14ops.txt", polyfit_deg=3, NN_epochs=400)