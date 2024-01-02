#!/usr/bin/env python3

#-------------------------------------------------------------------------------

import hashlib, struct

#-------------------------------------------------------------------------------
	
# blocks	
# 0	
# hash	        "0000000000000000e067a478\u202678aa52d91fabd4292982a50"
# ver	        2
# prev_block	"000000000000000117c80378\u20262ad55e2f7d18ec1975b9717"
# mrkl_root	"871714dcbae6c8193a2bb9b2\u2026d94b3a0f1b447275a29978a"
# time	        1392872245
# bits	        419520339
# next_block	[\u2026]
# fee	        3049675
# nonce	        856192328
# n_tx	        99
# size	        152509
# block_index	286819
# main_chain	true
# height	        286819
# weight	        610036
# tx	        [\u2026]

#-------------------------------------------------------------------------------

ver        = 2
prev_block = "000000000000000117c80378b8da0e33559b5997f2ad55e2f7d18ec1975b9717"
mrkl_root  = "871714dcbae6c8193a2bb9b2a69fe1c0440399f38d94b3a0f1b447275a29978a"
time_      = 0x53058b35 # 2014-02-20 04:57:25
bits       = 0x19015f53
 
# https://en.bitcoin.it/wiki/Difficulty
exp           = bits >> 24
mant          = bits & 0xffffff
target_hexstr = '%064x' % (mant * (1<<(8*(exp - 3))))
target_str    = target_hexstr.decode('hex')
 
nonce = 0

while nonce < 0x100000000:

    header = ( struct.pack("<L", ver) + prev_block.decode('hex')[::-1] +
          mrkl_root.decode('hex')[::-1] + struct.pack("<LLL", time_, bits, nonce))

    #hash = hashlib.sha256(hashlib.sha256(header).digest()).digest()

    ## print nonce, hash[::-1].encode('hex')

    #if hash[::-1] < target_str:
    #    print ("success")
    #    break
    
    nonce += 1

#-------------------------------------------------------------------------------

#  The following table shows the hash obtained for selected nonce values.
#  The key point is that each nonce generates a basically-random hash value.
#  Every so often a "lucky" nonce will generate a hash starting with some zeroes.
#  To get a lot of zeroes, you need to try an exponentially large number of nonces.
#  For this block, the "winning" nonce is 856192328.

# nonce	   hash

# 0	   5c56c2883435b38aeba0e69fb2e0e3db3b22448d3e17b903d774dd5650796f76
# 1	   28902a23a194dee94141d1b70102accd85fc2c1ead0901ba0e41ade90d38a08e
# 2	   729577af82250aaf9e44f70a72814cf56c16d430a878bf52fdaceeb7b4bd37f4
# 3	   8491452381016cf80562ff489e492e00331de3553178c73c5169574000f1ed1c
# 39	   03fd5ff1048668cd3cde4f3fb5bde1ff306d26a4630f420c78df1e504e24f3c7
# 990	   0001e3a4583f4c6d81251e8d9901dbe0df74d7144300d7c03cab15eca04bd4bb
# 52117	   0000642411733cd63264d3bedc046a5364ff3c77d2b37ca298ad8f1b5a9f05ba
# 1813152	   00000c94a85b5c06c9b06ace1ba7c7f759e795715f399c9c1b1b7f5d387a319f
# 19745650   000000cdccf49f13f5c3f14a2c12a56ae60e900c5e65bfe1cc24f038f0668a6c
# 243989801  0000000ce99e2a00633ca958a16e17f30085a54f04667a5492db49bcae15d190
# 856192328  0000000000000000e067a478024addfecdc93628978aa52d91fabd4292982a50


# I should point out that I cheated by starting with a block that could be
# successfully mined. Most of the attempts to mine a block will fail entirely -
# none of the nonce values will succeed. In that case, you need to modify the
# block slightly and try again. The timestamp can be adjusted (which is why the
# timestamp in mined blocks is often wrong). New transactions can be added to the
# block, changing the Merkle hash. The coinbase transaction can be modified -
# this turns out to be very important for mining pools. Any of these changes will
# result in totally different hashes, so the nonce values can be tried again.

# My Python program does about 42,000 hashes per second, which is a million times
# slower than the hardware used by real miners. My program would take about 11
# million years on average to mine a block from scratch. 

#-------------------------------------------------------------------------------
