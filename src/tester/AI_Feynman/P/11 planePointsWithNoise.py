import os
import random

os.chdir("/content/gdrive/My Drive/Lemay.ai_research/AI-Feynman/example_data")

def getY(x01,x23):
  y = -0.5*x01+0.5*x23+3
  return y

def getRow():
  x=[random.random() for x in range(4)]
  x[1]=x[0]
  x[3]=x[2]
  y=getY(x[1],x[3])
  mu=0
  sigma=0.05
  noise=np.random.normal(mu, sigma, 4)
  x=x+noise
  return str(x[0])+" "+str(x[1])+" "+str(x[2])+" "+str(x[3])+" "+str(y)+"\n"

with open("duplicateVarsWithNoise.txt", "w") as f:
  for _ in range(10000):
    f.write(getRow())
f.close()