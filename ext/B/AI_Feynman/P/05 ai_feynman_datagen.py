import os
import random

def getY(x01,x23):
  y = -0.5*x01+0.5*x23+3
  return y

def getRow():
  [x0,x2]=[random.random() for x in range(2)]
  x1=x0
  x3=x2
  y=getY(x1,x3)
  return str(x0)+" "+str(x1)+" "+str(x2)+" "+str(x3)+" "+str(y)+"\n"

with open("duplicateVarsExample.txt", "w") as f:
  for _ in range(10000):
    f.write(getRow())
f.close()