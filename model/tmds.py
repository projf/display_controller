#!/usr/bin/env python

# Project F: HDMI/DVI TMDS Encoder Python Model
# (C)2019 Will Green, Open source software released under the MIT License
# Learn more at https://projectf.io

# NB. [0:7] is 7 elements in Python, but 8 in Verilog.

"""HDMI/DVI TMDS Encoder Python Model"""

from __future__ import print_function

def static_vars(**kwargs):
    """Static variable decorator."""
    def decorate(func):
        for k in kwargs:
            setattr(func, k, kwargs[k])
        return func
    return decorate

def bin_array_8(integer):
    """Convert integer into fixed-length 8-bit binary array. LSB in [0]."""
    b_array = [int(i) for i in reversed(bin(integer)[2:])]
    return b_array + [0 for _ in range(8 - len(b_array))]

def tmds(d, d_decimal):  # pylint: disable=invalid-name
    """
    Convert d to q_m as per DVI spec.
    Perform base TMDS encoding. Does not balance.
    """
    q_m = [None] * 9
    one_cnt_d = sum(d)
    if one_cnt_d > 4 or (one_cnt_d == 4 and d[0] == 0):
        print("{:3}: XNOR(".format(d_decimal), end='')
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
        print("{:3}: XOR (".format(d_decimal), end='')
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
    """
    Convert q_m to q_out as per DVI spec.
    Perform TMDS balancing to handle bias. Generate one of 460 10-bit outputs.
    """
    q_out = [None] * 10
    one_cnt = sum(q_m[0:8])
    zero_cnt = 8 - one_cnt

    if bias.bias == 0 or one_cnt == 4:
        q_out[9] = int(not q_m[8])
        q_out[8] = q_m[8]
        if q_m[8] == 0:
            print("{},{:2}, A1) ".format(one_cnt, bias.bias), end='')
            q_out[:8] = [int(not i) for i in q_m[:8]]  # inverted q_m[:8]
            bias.bias = bias.bias + zero_cnt - one_cnt
        else:
            print("{},{:2}, A0) ".format(one_cnt, bias.bias), end='')
            q_out[:8] = q_m[:8]
            bias.bias = bias.bias + one_cnt - zero_cnt
    else:
        if (bias.bias > 0 and one_cnt > zero_cnt) or (bias.bias < 0 and one_cnt < zero_cnt):
            print("{},{:2}, B1) ".format(one_cnt, bias.bias), end='')
            q_out[9] = 1
            q_out[8] = q_m[8]
            q_out[:8] = [int(not i) for i in q_m[:8]]  # inverted q_m[:8]
            bias.bias = bias.bias + 2 * q_m[8] + zero_cnt - one_cnt
        else:
            print("{},{:2}, B0) ".format(one_cnt, bias.bias), end='')
            q_out[9] = 0
            q_out[8] = q_m[8]
            q_out[:8] = q_m[:8]
            bias.bias = bias.bias - 2 * (not q_m[8]) + one_cnt - zero_cnt
    return q_out

def main():
    """Generate formatted table of TMDS encoded values."""
    print("Project F TMDS Encoding Model from https://projectf.io")
    print("d -> q_m -> q_out (MSB first) - 1s: one count, B: bias")
    print("O: balance option. 0-7: data, 8: X(N)OR, 9: inverted\n")
    print("         1s  B   O  76543210    876543210    9876543210")
    print("=======================================================")

    for decimal in range(0, 256):  # encode all possible 8-bit values (0-255)
        d = bin_array_8(decimal)   # pylint: disable=invalid-name
        q_m = tmds(d, decimal)
        q_out = bias(q_m)
        d_str = ''.join(map(str, reversed(d)))
        q_m_str = ''.join(map(str, reversed(q_m)))
        q_out_str = ''.join(map(str, reversed(q_out)))
        print("{} -> {} -> {}".format(d_str, q_m_str, q_out_str))

if __name__ == "__main__":
    main()
