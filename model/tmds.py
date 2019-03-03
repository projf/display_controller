#!/usr/bin/env python

# Project F: TMDS Encoder Python Model
# (C)2019 Will Green, Open source software released under the MIT License
# Learn more at https://projectf.io

from __future__ import print_function

def static_vars(**kwargs):
    def decorate(func):
        for k in kwargs:
            setattr(func, k, kwargs[k])
        return func
    return decorate

def bin_array_8(x):
    '''
    Convert integer into fixed-length 8-bit binary array. LSB in [0].
    '''
    b_array = [int(i) for i in reversed(bin(x)[2:])]
    return b_array + [0 for _ in range(8 - len(b_array))]

def tmds(decimal, d):
    '''
    Perform base TMDS encoding. Does not balance.
    Convert d[0:7] to q_m[0:8] as per DVI spec.
    '''
    q_m = [None] * 9
    one_cnt_d = sum(d)
    if one_cnt_d > 4 or (one_cnt_d == 4 and d[0] == 0):
        print("{:3}: XNOR(".format(decimal), end='')
        q_m[0] = d[0]
        q_m[1] = int(q_m[0] == d[1])
        q_m[2] = int(q_m[1] == d[2])
        q_m[3] = int(q_m[2] == d[3])
        q_m[4] = int(q_m[3] == d[4])
        q_m[5] = int(q_m[4] == d[5])
        q_m[6] = int(q_m[5] == d[6])
        q_m[7] = int(q_m[6] == d[7])
        q_m[8] = 0  # using XNOR == 0
    else:
        print("{:3}: XOR (".format(decimal), end='')
        q_m[0] = d[0]
        q_m[1] = int(q_m[0] ^ d[1])
        q_m[2] = int(q_m[1] ^ d[2])
        q_m[3] = int(q_m[2] ^ d[3])
        q_m[4] = int(q_m[3] ^ d[4])
        q_m[5] = int(q_m[4] ^ d[5])
        q_m[6] = int(q_m[5] ^ d[6])
        q_m[7] = int(q_m[6] ^ d[7])
        q_m[8] = 1  # using XOR == 1
    return q_m

@static_vars(bias=0)
def bias(q_m):
    '''
    Perform TMDS bias encoding. Generates one of 460 10-bit outputs.
    Convert q_m[0:8] to q_m[0:9] as per DVI spec.
    '''
    q_out = [None] * 10
    one_cnt = sum(q_m[0:8])
    zero_cnt = 8 - one_cnt
    option = ''

    if bias.bias == 0 or one_cnt == 4:
        q_out[9] = int(not q_m[8])
        q_out[8] = q_m[8]
        if q_m[8] == 0:
            print("{},{:2}, A1) ".format(one_cnt, bias.bias), end='')
            q_out[0:8] = [int(not i) for i in q_m[0:8]]
            bias.bias = bias.bias + zero_cnt - one_cnt
        else:
            print("{},{:2}, A0) ".format(one_cnt, bias.bias), end='')
            q_out[0:8] = q_m[0:8]
            bias.bias = bias.bias + one_cnt - zero_cnt
    else:
        if (bias.bias > 0 and one_cnt > zero_cnt) or (bias.bias < 0 and one_cnt < zero_cnt):
            print("{},{:2}, B1) ".format(one_cnt, bias.bias), end='')
            q_out[9] = 1
            q_out[8] = q_m[8]
            q_out[0:8] = [int(not i) for i in q_m[0:8]]
            bias.bias = bias.bias + 2 * q_m[8] + zero_cnt - one_cnt
        else:
            print("{},{:2}, B0) ".format(one_cnt, bias.bias), end='')
            q_out[9] = 0
            q_out[8] = q_m[8]
            q_out[0:8] = q_m[0:8]
            bias.bias = bias.bias - 2 * (not q_m[8]) + one_cnt - zero_cnt
    return q_out


print("Project F TMDS Encoding Model")
print("================================")
print("d[0:7] -> q_m[0:8] -> q_out[0:9]")
print("LSB First, 8=X(N)OR  9=invert\n")
print("         1s  B   O   0  1  2  3  4  5  6  7      0  1  2  3  4  5  6  7  8      0  1  2  3  4  5  6  7  8  9")
print("=============================================================================================================")
for decimal in range(0,256):
    d = bin_array_8(decimal)
    q_m = tmds(decimal, d)
    q_out = bias(q_m)
    print("{} -> {} -> {}".format(d, q_m, q_out))
