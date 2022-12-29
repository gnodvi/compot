#!/usr/bin/env python3

#-------------------------------------------------------------------------------


print ("\n")
print ("..... 01 .... \n")

import sys
#sys.path.append ("../networkx-networkx-2.8.8")
sys.path.append (".")

#print ("sys.path = ",  sys.path)

#print ("..... 02 .... \n")

# import os
# print (os.environ.get ('PYTHONPATH', ''))

#exit ()
#__path__.append(os.path.join(os.path.dirname(__file__), "utils"))

#print ("..... 03 .... \n")

#exit ()

#-------------------------------------------------------------------------------

import networkx as nx

#exit ()

#from GraphRicciCurvature.OllivierRicci import OllivierRicci
#from GraphRicciCurvature.FormanRicci   import FormanRicci


# 1) 
import OllivierRicci # ?? 
import FormanRicci

# 2) 
#exec (open ("OllivierRicci.py").read())

#exit ()

#-------------------------------------------------------------------------------

# import an example NetworkX karate club graph
G = nx.karate_club_graph()

#exit ()

print ("..... 02 .... \n")

# compute the Ollivier-Ricci curvature of the given graph G
#orc = OllivierRicci (G, alpha=0.5, verbose="INFO")
orc = OllivierRicci.OllivierRicci (G, alpha=0.5, verbose="INFO")

#exit ()

print ("..... 03 .... \n")

orc.compute_ricci_curvature()

print ("..... 04 .... \n")

#exit ()

print ("\n")
print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n")

print ("Karate Club Graph: The Ollivier-Ricci curvature of edge (0,1) is %f" % orc.G[0][1]["ricciCurvature"])

print ("")

#exit ()

# compute the Forman-Ricci curvature of the given graph G

#frc = FormanRicci(G)
#TypeError: 'module' object is not callable
frc = FormanRicci.FormanRicci (G)

#exit ()

frc.compute_ricci_curvature()

print ("\n")
print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n")

print("Karate Club Graph: The Forman-Ricci curvature of edge (0,1) is %f" % frc.G[0][1]["formanCurvature"])

print ("")

#exit ()

# -----------------------------------------------------
# Construct a directed graph example
print ("\n")
print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n")

Gd = nx.DiGraph()
Gd.add_edges_from([(1, 2), (2, 3), (3, 4), (2, 4), (4, 2)])

# compute the Ollivier-Ricci curvature of the given directed graph Gd

#orc_directed = OllivierRicci (Gd)
orc_directed = OllivierRicci.OllivierRicci (Gd)

orc_directed.compute_ricci_curvature()

print ("\n")

for n1, n2 in Gd.edges():
    print("Directed Graph: The Ollivier-Ricci curvature of edge(%d,%d) id %f" %
          (n1, n2, orc_directed.G[n1][n2]["ricciCurvature"]))

print ("\n")

#exit ()

# compute the Forman-Ricci curvature of the given directed graph Gd

#frc_directed = FormanRicci(Gd)
frc_directed = FormanRicci.FormanRicci (Gd)

frc_directed.compute_ricci_curvature()

print ("\n")
##print ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n")

for n1, n2 in frc_directed.G.edges():
    print("Directed Graph: The Forman-Ricci curvature of edge(%d,%d) id %f" %
          (n1, n2, frc_directed.G[n1][n2]["formanCurvature"]))

print ("\n")

exit ()  # OK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# ---------------------------------------------
# Multiprocessing computation is also supported, default is all detected cpu.

if False:
    
    G_rr = nx.random_regular_graph (8, 1000)
    orc_rr = OllivierRicci.OllivierRicci (G_rr, proc=4)
    
    orc_rr.compute_ricci_curvature()

#exit ()

# ---------------------------------------------
# Compute Ricci flow metric - Optimal Transportation Distance

G = nx.karate_club_graph()

orc_OTD = OllivierRicci.OllivierRicci (G, alpha=0.5, method="OTD", verbose="INFO")
orc_OTD.compute_ricci_flow (iterations=10)

#exit ()

# Compute Ricci flow metric - Average Transportation Distance (Faster)
G = nx.karate_club_graph()

orc_ATD = OllivierRicci.OllivierRicci (G, alpha=0.5, method="ATD", verbose="INFO")
orc_ATD.compute_ricci_flow(iterations=10)

#exit ()

# Compute Ricci flow metric - Applying Sinkhorn distance for approximate optimal transportation distance
G = nx.karate_club_graph()

orc_Sinkhorn = OllivierRicci.OllivierRicci (G, alpha=0.5, method="Sinkhorn", verbose="INFO")
orc_Sinkhorn.compute_ricci_flow(iterations=10)

#exit ()
print ("\n")
print ("\n")

# You can also apply customized surgery function during Ricci flow process.
from my_surgery import *

orc_surgery = OllivierRicci.OllivierRicci (G, alpha=0.5, method="Sinkhorn", verbose="INFO")
orc_Sinkhorn.compute_ricci_flow(iterations=10, surgery=(my_surgery, 5))

print ("\n")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
