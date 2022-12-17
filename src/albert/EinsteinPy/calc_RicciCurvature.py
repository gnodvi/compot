#!/usr/bin/env python3

#-------------------------------------------------------------------------------

print ("\n")
print ("..... 01 .... \n")

import sys
sys.path.append (".")

print ("..... 02 .... \n")

#exit ()

#-------------------------------------------------------------------------------

# Ricci Tensor and Scalar Curvature calculations using Symbolic module

import sympy
from einsteinpy.symbolic import RicciTensor, RicciScalar
from einsteinpy.symbolic.predefined import AntiDeSitter

sympy.init_printing()


#Defining the Anti-de Sitter spacetime Metric

metric = AntiDeSitter()
metric.tensor()


#Calculating the Ricci Tensor(with both indices covariant)

Ric = RicciTensor.from_metric(metric)
Ric.tensor()


#Calculating the Ricci Scalar(Scalar Curvature) from the Ricci Tensor

R = RicciScalar.from_riccitensor(Ric)
R.simplify()

print ("R.expr = ", R.expr, "\n")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
