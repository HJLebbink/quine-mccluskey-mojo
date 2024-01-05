from random import random_ui64

from TruthTable import TruthTable
from MyMap import MySet
from tools import eq_dynamic_vector
from to_string import PrintType, minterms_to_string


fn test_compress_decompress(n_tests: Int = 1, n_minterms: Int = 10):
    for i in range(n_tests):
        if test_compress_decompress_1x[2](n_minterms):
            return
        if test_compress_decompress_1x[3](n_minterms):
            return
        if test_compress_decompress_1x[4](n_minterms):
            return
        if test_compress_decompress_1x[5](n_minterms):
            return
        if test_compress_decompress_1x[6](n_minterms):
            return
        if test_compress_decompress_1x[7](n_minterms):
            return
        if test_compress_decompress_1x[8](n_minterms):
            return
        if test_compress_decompress_1x[9](n_minterms):
            return
        if test_compress_decompress_1x[10](n_minterms):
            return
        if test_compress_decompress_1x[11](n_minterms):
            return


fn test_compress_decompress_1x[N_BITS: Int](n_minterms: Int) -> Bool:
    alias MAX_MINTERM = (1 << N_BITS) - 1
    var tt1 = TruthTable[N_BITS]()
    var tt2 = TruthTable[N_BITS]()
    alias P = PrintType.BIN

    var minterm_set = MySet[tt1.MinTermType]()
    for i in range(n_minterms):
        minterm_set.add(random_ui64(0, MAX_MINTERM).cast[tt1.MinTermType]())

    for i in range(len(minterm_set)):
        tt1.set_true(minterm_set.data[i].to_int())
        tt2.set_true(minterm_set.data[i].to_int())

    tt1.sort()
    let minterms_1a = tt1.data
    tt1.compress[USE_CLASSIC_METHOD=True]()
    let minterms_2a = tt1.data
    tt1.decompress()
    let minterms_3a = tt1.data

    tt2.sort()
    let minterms_1b = tt2.data
    tt2.compress[USE_CLASSIC_METHOD=False]()
    let minterms_2b = tt2.data
    tt2.decompress()
    let minterms_3b = tt2.data

    var error = False

    if not tools.eq_dynamic_vector[tt1.MinTermType](minterms_2a, minterms_2b):
        print("methods do not give equal results: minterms_2a != minterms_2b")
        print("minterms_2a:" + minterms_to_string[tt1.MinTermType, P](minterms_2a, N_BITS))
        print("minterms_2b:" + minterms_to_string[tt1.MinTermType, P](minterms_2b, N_BITS))
        error = True

    if not tools.eq_dynamic_vector[tt1.MinTermType](minterms_1a, minterms_3a):
        print("decompression failed: minterms_1a != minterms_3a; N_BITS=" + str(N_BITS))
        print("minterms_1a:" + minterms_to_string[tt1.MinTermType, P](minterms_1a, N_BITS))
        print("minterms_3a:" + minterms_to_string[tt1.MinTermType, P](minterms_3a, N_BITS))
        print("minterms_2a:" + minterms_to_string[tt1.MinTermType, P](minterms_2a, N_BITS))
        error = True

    if not tools.eq_dynamic_vector[tt1.MinTermType](minterms_1b, minterms_3b):
        print("decompression failed: minterms_1b != minterms_3b; N_BITS=" + str(N_BITS))
        print("minterms_1b:" + minterms_to_string[tt1.MinTermType, P](minterms_1b, N_BITS))
        print("minterms_3b:" + minterms_to_string[tt1.MinTermType, P](minterms_3b, N_BITS))
        print("minterms_2b:" + minterms_to_string[tt1.MinTermType, P](minterms_2b, N_BITS))
        error = True

    return error
