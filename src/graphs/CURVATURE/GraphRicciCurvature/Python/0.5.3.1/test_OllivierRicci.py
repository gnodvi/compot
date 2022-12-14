#!/usr/bin/env python3

#-------------------------------------------------------------------------------

import sys
sys.path.append (".")

#-------------------------------------------------------------------------------

import networkx as nx
import numpy.testing as npt

from GraphRicciCurvature.OllivierRicci import OllivierRicci

#-------------------------------------------------------------------------------

def test_compute_ricci_curvature_edges():
    G = nx.karate_club_graph()
    for (n1, n2, d) in G.edges(data=True):
        d.clear()   # remove edge weight
    orc = OllivierRicci(G, method="OTD", alpha=0.5)
    output = orc.compute_ricci_curvature_edges([(0, 1)])

    npt.assert_almost_equal(output[0, 1], 0.111111)


def test_compute_ricci_curvature():
    G = nx.karate_club_graph()
    for (n1, n2, d) in G.edges(data=True):
        d.clear()   # remove edge weight
    orc = OllivierRicci(G, method="OTD", alpha=0.5)
    Gout = orc.compute_ricci_curvature()
    rc = list(nx.get_edge_attributes(Gout, "ricciCurvature").values())
    ans = [0.111111, -0.143750, 0.041667, -0.114583, -0.281250, -0.281250, 0.062500, -0.200000, -0.114583, 0.062500,
           -0.000000, 0.062500, 0.062500, -0.031250, 0.062500, -0.427083, 0.044444, 0.166667, 0.194444, 0.244444,
           0.166667, 0.111111, 0.166667, -0.041667, 0.050000, 0.125000, 0.100000, 0.100000, 0.200000, -0.175000,
           0.033333, -0.233333, 0.416667, 0.250000, 0.216667, 0.291667, 0.500000, 0.500000, 0.291667, 0.375000,
           0.375000, 0.375000, -0.025000, 0.011765, -0.044118, -0.288235, 0.125000, 0.088235, 0.125000, 0.088235,
           0.125000, 0.088235, -0.254902, 0.125000, 0.088235, 0.125000, 0.088235, 0.100000, 0.225000, 0.200000,
           -0.066667, -0.076471, 0.500000, 0.125000, 0.083333, 0.166667, 0.375000, -0.073529, -0.147059, 0.166667,
           -0.068627, -0.041667, -0.014706, -0.041667, -0.044118, -0.166667, -0.122549, 0.267157]

    npt.assert_array_almost_equal(rc, ans)


def test_compute_ricci_curvature_directed():
    Gd = nx.DiGraph()
    Gd.add_edges_from([(0, 1), (1, 2), (2, 3), (1, 3), (3, 1)])
    orc = OllivierRicci(Gd, method="OTD", alpha=0.5)
    Gout = orc.compute_ricci_curvature()
    rc = list(nx.get_edge_attributes(Gout, "ricciCurvature").values())
    ans = [-0.49999999999999956,
           -3.842615114990622e-11,
           0.49999999996158007,
           0.49999999992677135,
           0.7499999999364129]

    npt.assert_array_almost_equal(rc, ans)


def test_compute_ricci_curvature_ATD():
    G = nx.karate_club_graph()
    for (n1, n2, d) in G.edges(data=True):
        d.clear()   # remove edge weight
    orc = OllivierRicci(G, alpha=0.5, method="ATD", verbose="INFO")
    orc.compute_ricci_curvature()
    Gout = orc.compute_ricci_curvature()
    rc = list(nx.get_edge_attributes(Gout, "ricciCurvature").values())
    ans = [-0.343750, -0.437500, -0.265625, -0.250000, -0.390625, -0.390625, -0.195312, -0.443750, -0.250000,
           0.000000, -0.140625, -0.287500, -0.109375, -0.291667, -0.109375, -0.640625, -0.311111, -0.175926,
           -0.083333, -0.166667, 0.000000, -0.166667, 0.000000, -0.333333, -0.241667, -0.137500, -0.220000,
           -0.125000, -0.160000, -0.400000, -0.200000, -0.479167, 0.020833, 0.041667, -0.100000, -0.041667,
           0.055556, -0.062500, -0.041667, 0.000000, 0.000000, -0.075000, -0.275000, -0.300000, -0.176471,
           -0.464706, 0.000000, -0.073529, 0.000000, -0.073529, 0.000000, -0.073529, -0.421569, 0.000000,
           -0.073529, 0.000000, -0.073529, -0.200000, -0.200000, -0.125000, -0.291667, -0.335294, -0.055556,
           -0.208333, -0.194444, -0.194444, 0.062500, -0.176471, -0.375000, -0.166667, -0.245098, -0.197917,
           -0.227941, -0.250000, -0.294118, -0.430556, -0.455882, -0.355392]

    npt.assert_array_almost_equal(rc, ans)


def test_compute_ricci_flow():
    G = nx.karate_club_graph()
    for (n1, n2, d) in G.edges(data=True):
        d.clear()   # remove edge weight
    orc = OllivierRicci(G, method="OTD", alpha=0.5)
    Gout = orc.compute_ricci_flow(iterations=3)
    rf = list(nx.get_edge_attributes(Gout, "weight").values())
    ans = [0.584642, 1.222957, 0.828566, 1.893597, 2.179315, 2.179315, 0.814135, 1.647656, 1.893597, 0.906430,
           0.916791, 0.798319, 0.760511, 0.829311, 0.760511, 2.477847, 0.937765, 0.681481, 0.612859, 0.568307,
           0.675702, 0.702774, 0.675702, 1.484889, 0.843498, 0.753397, 1.098413, 0.868616, 0.646627, 2.061065,
           1.425968, 1.924123, 0.292387, 0.487378, 0.446435, 0.509673, 0.101477, 0.108645, 0.509673, 0.246037,
           0.246037, 0.228701, 1.309931, 1.213249, 1.317511, 2.149341, 0.712759, 0.811386, 0.712759, 0.811386,
           0.712759, 0.811386, 2.245314, 0.712759, 0.811386, 0.712759, 0.811386, 0.947310, 0.518039, 0.857636,
           1.525740, 1.429449, 0.180896, 0.692919, 0.724545, 0.639637, 0.281116, 1.427853, 1.622385, 0.807457,
           1.386869, 1.372091, 1.320579, 1.324087, 1.276729, 1.843012, 1.721982, 0.412472]

    npt.assert_array_almost_equal(rf, ans)


def test_ricci_community_all_possible_clusterings():
    G = nx.karate_club_graph()
    for (n1, n2, d) in G.edges(data=True):
        d.clear()   # remove edge weight
    orc = OllivierRicci(G, exp_power=1, alpha=0.5)
    orc.compute_ricci_flow(iterations=40)
    cc = orc.ricci_community_all_possible_clusterings()
    cuts = [x[0] for x in cc]
    clusterings = [x[1] for x in cc]
    cuts_ans = [1.8364944935528884, 1.6114944935528852, 1.461494493552883, 1.2614944935528802, 1.1864944935528792,
                1.111494493552878, 1.036494493552877]
    clusterings_ans = [{0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 23: 2, 24: 2,
                        25: 2, 26: 2, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2},
                       {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 23: 2, 24: 2,
                        25: 2, 26: 2, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2},
                       {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 23: 2, 24: 2,
                        25: 2, 26: 2, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2},
                       {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 23: 2, 24: 2,
                        25: 2, 26: 2, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2},
                       {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 23: 2, 24: 2,
                        25: 2, 26: 2, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2},
                       {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 23: 2, 24: 2,
                        25: 2, 26: 2, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2},
                       {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                        6: 1, 10: 1, 16: 1, 32: 2, 33: 2, 8: 2, 14: 2, 15: 2, 18: 2, 20: 2, 22: 2, 30: 2, 23: 3,
                        24: 3, 25: 3, 26: 3, 27: 3, 28: 3, 29: 3, 31: 3}]

    npt.assert_array_almost_equal(cuts, cuts_ans)
    assert clusterings == clusterings_ans


def test_ricci_community():
    
    G = nx.karate_club_graph()
    for (n1, n2, d) in G.edges(data=True):
        d.clear()   # remove edge weight
    orc = OllivierRicci(G, exp_power=1, alpha=0.5)
    cut, clustering = orc.ricci_community()
    cut_ans = 1.2613588421005884
    clustering_ans = {0: 0, 1: 0, 2: 0, 3: 0, 7: 0, 9: 0, 11: 0, 12: 0, 13: 0, 17: 0, 19: 0, 21: 0, 4: 1, 5: 1,
                      6: 1, 10: 1, 16: 1, 8: 2, 30: 2, 32: 3, 33: 3, 14: 3, 15: 3, 18: 3, 20: 3, 22: 3, 23: 4,
                      24: 4, 25: 4, 26: 4, 27: 4, 28: 4, 29: 4, 31: 4}


    npt.assert_array_almost_equal(cut, cut_ans)
    assert clustering == clustering_ans

#-------------------------------------------------------------------------------

test_compute_ricci_curvature_edges()

print (".. 1")

test_compute_ricci_curvature()
test_compute_ricci_curvature_directed()
test_compute_ricci_curvature_ATD()

print (".. 2")

test_compute_ricci_flow()
test_ricci_community_all_possible_clusterings()
test_ricci_community()

print (".. 3")

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
