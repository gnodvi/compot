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

#exit ()

#-------------------------------------------------------------------------------
import networkx as nx

from GraphRicciCurvature.FormanRicci   import FormanRicci
from GraphRicciCurvature.OllivierRicci import OllivierRicci

#<frozen importlib._bootstrap>:241: ReducedFunctionalityWarning: WARNING: module 'pandas' not found, some functionality will be restricted

print("\n- Import an example NetworkX karate club graph")
G = nx.karate_club_graph()

print("\n===== Compute the Ollivier-Ricci curvature of the given graph G =====")
print ("\n")

#exit ()

# compute the Ollivier-Ricci curvature of the given graph G

orc = OllivierRicci(G, alpha=0.5, verbose="INFO")
orc.compute_ricci_curvature()

#exit ()

print("Karate Club Graph: The Ollivier-Ricci curvature of edge (0,1) is %f" % orc.G[0][1]["ricciCurvature"])

print("\n===== Compute the Forman-Ricci curvature of the given graph G =====")
frc = FormanRicci(G)
frc.compute_ricci_curvature()
print("Karate Club Graph: The Forman-Ricci curvature of edge (0,1) is %f" % frc.G[0][1]["formanCurvature"])

#exit ()
print ("\n")

# -----------------------------------------------
print("\n-Construct a directed graph example")

Gd = nx.DiGraph()
Gd.add_edges_from([(0, 1), (1, 2), (2, 3), (1, 3), (3, 1)])

print("\n===== Compute the Ollivier-Ricci curvature of the given directed graph Gd =====")
print ("\n")


orc_directed = OllivierRicci(Gd)
orc_directed.compute_ricci_curvature()

for n1, n2 in Gd.edges():
    print("Directed Graph: The Ollivier-Ricci curvature of edge(%d,%d) id %f" %
          (n1, n2, orc_directed.G[n1][n2]["ricciCurvature"]))

#exit ()
print ("\n")

    # Forman-Ricci not support for direct graph yet.
# print("\n===== Compute the Forman-Ricci curvature of the given directed graph Gd =====")
# frc_directed = FormanRicci(Gd)
# frc_directed.compute_ricci_curvature()
# for n1, n2 in frc_directed.G.edges():
#     print("Directed Graph: The Forman-Ricci curvature of edge(%d,%d) id %f" %
#           (n1, n2, frc_directed.G[n1][n2]["formanCurvature"]))

# -----------------------------------
print("\n===== Multiprocessing computation is also supported, default is 2 cpu.")
G_rr = nx.random_regular_graph(8, 1000)
orc_rr = OllivierRicci(G_rr, proc=2, verbose="INFO")
orc_rr.compute_ricci_curvature()

# -----------------------------------
print("\n=====  Compute Ricci flow metric - Optimal Transportation Distance =====")
G = nx.karate_club_graph()
orc_OTD = OllivierRicci(G, alpha=0.5, method="OTD", verbose="INFO")
orc_OTD.compute_ricci_flow(iterations=10)

print("\n=====  Compute Ricci flow metric - Average Transportation Distance =====")
G = nx.karate_club_graph()
orc_ATD = OllivierRicci(G, alpha=0.5, method="ATD", verbose="INFO")
orc_ATD.compute_ricci_flow(iterations=10)

print("\n=====  Compute Ricci flow metric - Sinkhorn distance for approximate optimal transportation distance =====")
G = nx.karate_club_graph()
orc_Sinkhorn = OllivierRicci(G, alpha=0.5, method="Sinkhorn", verbose="INFO")
orc_Sinkhorn.compute_ricci_flow(iterations=10)

print("\n=====  You can also apply customized surgery function during Ricci flow process. =====")
from my_surgery import *

orc_surgery = OllivierRicci(G, alpha=0.5, verbose="INFO")
orc_Sinkhorn.compute_ricci_flow(iterations=10, surgery=(my_surgery, 5))
