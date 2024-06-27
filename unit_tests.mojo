from random import random_ui64

from TruthTable import TruthTable
from MySet import MySet
from cnf_to_dnf import convert_cnf_to_dnf_minimal, convert_cnf_to_dnf
from to_string import (
    PrintType,
    minterms_to_string,
    cnf_to_string,
    dnf_to_string,
)


fn run_all_unit_tests[QUIET: Bool]():
    truth_table_test1[QUIET]()
    truth_table_test2[QUIET]()
    truth_table_test3[QUIET]()
    truth_table_test4[QUIET]()
    truth_table_test5[QUIET]()
    truth_table_test6[QUIET]()

    test_cnf2dnf_0[QUIET]()
    test_cnf2dnf_1[QUIET]()


fn truth_table_test1[QUIET: Bool]():
    var tt = TruthTable[3]()
    tt.set_true(0b011)
    tt.set_true(0b100)
    tt.set_true(0b101)
    tt.set_true(0b110)
    tt.set_true(0b111)

    # uncompressed:
    # ABC ->F0
    # 011 -> 1
    # 100 -> 1
    # 101 -> 1
    # 110 -> 1
    # 111 -> 1
    #
    # compressed:
    # ABC ->F0
    # X11 -> 1
    # 1XX -> 1

    tt.sort()
    var data1 = tt.data
    if not QUIET:
        print("original:     " + tt.to_string[PrintType.BIN]())
    tt.compress[USE_CLASSIC_METHOD=False, SHOW_INFO=False]()
    if not QUIET:
        print("compressed:   " + tt.to_string[PrintType.BIN]())
    tt.decompress()
    var data2 = tt.data
    if not QUIET:
        print("decompressed: " + tt.to_string[PrintType.BIN]() + "\n")

    if data1 != data2:
        print("ERROR UT: truth_table_test1: NOT EQUAL!")


# example needs Petricks method; has no primary essential prime implicants
fn truth_table_test2[QUIET: Bool]():
    alias N_BITS = 4
    var tt = TruthTable[N_BITS]()

    alias implicants = VariadicList(
        0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
    )  # example needs Petricks method; has no primary essential prime implicants
    for i in range(len(implicants)):
        tt.set_true(implicants[i])

    #     ABCD
    #  0: 0000 -> 1
    #  1: 0001 -> 0
    #  2: 0010 -> 1
    #  3: 0011 -> 1
    #  4: 0100 -> 1
    #  5: 0101 -> 1
    #  6: 0110 -> 1
    #  7: 0111 -> 1
    #  8: 1000 -> 1
    #  9: 1001 -> 1
    # 10: 1010 -> 1
    # 11: 1011 -> 1
    # 12: 1100 -> 1
    # 13: 1101 -> 1
    # 14: 1110 -> 0
    # 15: 1111 -> 0

    tt.sort()
    var data1 = tt.data
    if not QUIET:
        print("original:     " + tt.to_string[PrintType.BIN]())
    tt.compress[USE_CLASSIC_METHOD=False, SHOW_INFO=False]()
    if not QUIET:
        print("compressed:   " + tt.to_string[PrintType.BIN]())
    tt.decompress()
    var data2 = tt.data
    if not QUIET:
        print("decompressed: " + tt.to_string[PrintType.BIN]() + "\n")

    if data1 != data2:
        print("ERROR UT: truth_table_test2: NOT EQUAL!")

    # (x̄3x̄0), (x̄3x1), (x2x̄1), (x3x̄2) // manually checked with https://www.mathematik.uni-marburg.de/~thormae/lectures/ti1/code/qmc/
    # 0XX0 0X1X X10X 10XX : identical with observed

    # A'D' + A'C + BC' + AB'  // result from http://www.32x8.com/var4.html
    # 0XX0 0X1X X10X 10XX : identical with observed

    # A~B + ~C~D + ~AC + B~C  // result from https://ictlab.kz/extra/Kmap/
    # 10XX XX00 0X1X X10X : NOT identical with thormae

    # A' B  + B' C  + A C'  + C' D'  // result from logic Friday
    # 01XX X01X 1X0X XX00 ??? mess: not sure what causes this
    # 10XX X10X 0X1X XX11


fn truth_table_test3[QUIET: Bool]():
    alias N_BITS = 4
    var tt = TruthTable[N_BITS]()
    alias implicants = VariadicList(
        0, 2, 5, 6, 7, 8, 10, 12, 13, 14, 15
    )  # has primary essential prime implicants; Petricks method is not needed
    for i in range(len(implicants)):
        tt.set_true(implicants[i])

    #     ABCD
    #  0: 0000 -> 1
    #  1: 0001 -> 0
    #  2: 0010 -> 1
    #  3: 0011 -> 0
    #  4: 0100 -> 0
    #  5: 0101 -> 1
    #  6: 0110 -> 1
    #  7: 0111 -> 1
    #  8: 1000 -> 1
    #  9: 1001 -> 0
    # 10: 1010 -> 1
    # 11: 1011 -> 0
    # 12: 1100 -> 1
    # 13: 1101 -> 1
    # 14: 1110 -> 1
    # 15: 1111 -> 1

    tt.sort()
    var data1 = tt.data
    if not QUIET:
        print("original:     " + tt.to_string[PrintType.BIN]())
    tt.compress[USE_CLASSIC_METHOD=True, SHOW_INFO=False]()
    if not QUIET:
        print("compressed:   " + tt.to_string[PrintType.BIN]())
    tt.decompress()
    var data2 = tt.data
    if not QUIET:
        print("decompressed: " + tt.to_string[PrintType.BIN]() + "\n")

    if data1 != data2:
        print("ERROR UT: truth_table_test3: NOT EQUAL!")

    # (x̄2x̄0) ∨ (x2x0) ∨ (x1x̄0) ∨ (x3x̄0) // manually checked with https://www.mathematik.uni-marburg.de/~thormae/lectures/ti1/code/qmc/
    # X0X0      X1X1      XX10     1XX0

    # C~D + BD + A~D + ~B~D  // result from https://ictlab.kz/extra/Kmap/
    # XX10 X1X1 1XX0 X0X0  : identical with thormae

    # B'D' + CD' + BD + AD'  // result from http://www.32x8.com/var4.html
    # X0X0 XX10 X1X1 1XX0  : identical with thormae

    # B D + B' D' + A D' + C D'  // result from logic Friday
    # X1X1 X0X0 1XX0 XX10  : identical with thormae


fn truth_table_test4[QUIET: Bool]():
    var tt = TruthTable[8]()
    tt.set_true(0b11100111)
    tt.set_true(0b11100001)
    tt.set_true(0b01100001)
    tt.set_true(0b00100001)

    tt.sort()
    var data1 = tt.data
    if not QUIET:
        print("original:     " + tt.to_string[PrintType.BIN]())
    tt.compress[SHOW_INFO=False]()
    if not QUIET:
        print("compressed:   " + tt.to_string[PrintType.BIN]())
    tt.decompress()
    var data2 = tt.data
    if not QUIET:
        print("decompressed: " + tt.to_string[PrintType.BIN]() + "\n")

    if data1 != data2:
        print("ERROR UT: truth_table_test4: NOT EQUAL!")


# bug: fixed!
fn truth_table_test5[QUIET: Bool]():
    alias implicants = VariadicList(
        0b0001, 0b0011, 0b0101, 0b1000, 0b1010, 0b1011, 0b1101
    )

    var tt = TruthTable[4]()
    for i in range(len(implicants)):
        tt.set_true(implicants[i])

    tt.sort()
    var data1 = tt.data
    if not QUIET:
        print("original:     " + tt.to_string[PrintType.BIN]())
    tt.compress[USE_CLASSIC_METHOD=False, SHOW_INFO=False]()
    if not QUIET:
        print("compressed:   " + tt.to_string[PrintType.BIN]())
    tt.decompress()
    var data2 = tt.data
    if not QUIET:
        print("decompressed: " + tt.to_string[PrintType.BIN]() + "\n")

    if data1 != data2:
        print("ERROR UT: truth_table_test5: NOT EQUAL!")

    # y = (x3x̄2x̄0) ∨ (x2x̄1x0) ∨ (x̄3x̄2x0) ∨ (x̄2x1x0)
    # y = 10X0 X101 00X1 X011

    # http://www.32x8.com/qmm4_____A-B-C-D_____m_1-3-5-8-10-11-13___________option-4_____988791976079822295658
    # y = A'B'D + B'CD + BC'D + AB'D'
    # y = 00X1 X011 X101 10X0

    # old c++ code:
    # y = A'B'D + AB'D' + B'CD + BC'D
    # y = 00X1 10X0 X011 X101

    # obs mojo: 101X 10X0 0X01 X101
    # obs c++ : 10X0 X101 0X01 101X


# bug: fixed!
fn truth_table_test6[QUIET: Bool]():
    var tt = TruthTable[4]()
    tt.set_true(0b0000)
    tt.set_true(0b0010)
    tt.set_true(0b0011)
    tt.set_true(0b0100)
    tt.set_true(0b0101)
    tt.set_true(0b0110)
    tt.set_true(0b1011)
    tt.set_true(0b1111)

    tt.sort()
    var data1 = tt.data
    if not QUIET:
        print("original:     " + tt.to_string[PrintType.BIN]())
    tt.compress[USE_CLASSIC_METHOD=True, SHOW_INFO=False]()
    if not QUIET:
        print("compressed:   " + tt.to_string[PrintType.BIN]())
    tt.decompress()
    var data2 = tt.data
    if not QUIET:
        print("decompressed: " + tt.to_string[PrintType.BIN]() + "\n")

    if data1 != data2:
        print("ERROR UT: truth_table_test6: NOT EQUAL!")

    # y = (x3x̄2x̄0) ∨ (x2x̄1x0) ∨ (x̄3x̄2x0) ∨ (x̄2x1x0)
    # y = 10X0 X101 00X1 X011

    # http://www.32x8.com/qmm4_____A-B-C-D_____m_1-3-5-8-10-11-13___________option-4_____988791976079822295658
    # y = A'B'D + B'CD + BC'D + AB'D'
    # y = 00X1 X011 X101 10X0

    # old c++ code:
    # y = A'B'D + AB'D' + B'CD + BC'D
    # y = 00X1 10X0 X011 X101

    # obs mojo: 101X 10X0 0X01 X101
    # obs c++ : 10X0 X101 0X01 101X


fn test_compress_decompress(n_tests: Int = 1):
    fn test_compress_decompress_1x[N_BITS: Int](n_minterms: Int) -> Bool:
        alias MAX_MINTERM = (1 << N_BITS) - 1
        var tt1 = TruthTable[N_BITS]()
        var tt2 = TruthTable[N_BITS]()
        alias P = PrintType.BIN

        var minterm_set = MySet[tt1.MinTermType]()
        for i in range(n_minterms):
            minterm_set.add(random_ui64(0, MAX_MINTERM).cast[tt1.MinTermType]())

        for i in range(len(minterm_set)):
            tt1.set_true(int(minterm_set.data[i]))
            tt2.set_true(int(minterm_set.data[i]))

        tt1.sort()
        var minterms_1a = tt1.data
        tt1.compress[USE_CLASSIC_METHOD=True]()
        var minterms_2a = tt1.data
        tt1.decompress()
        var minterms_3a = tt1.data

        tt2.sort()
        var minterms_1b = tt2.data
        tt2.compress[USE_CLASSIC_METHOD=False]()
        var minterms_2b = tt2.data
        tt2.decompress()
        var minterms_3b = tt2.data

        var error = False

        # if not tools.eq_dynamic_vector[tt1.MinTermType](minterms_2a, minterms_2b):
        # print("methods do not give equal results: minterms_2a != minterms_2b")
        # print("minterms_2a:" + minterms_to_string[tt1.MinTermType, P](minterms_2a, N_BITS))
        # print("minterms_2b:" + minterms_to_string[tt1.MinTermType, P](minterms_2b, N_BITS))
        # error = True

        if not (minterms_1a == minterms_3a):
            print(
                "ERROR UT: decompression failed: minterms_1a != minterms_3a;"
                " N_BITS="
                + str(N_BITS)
            )
            print(
                "minterms_1a:"
                + minterms_to_string[tt1.MinTermType, P](
                    minterms_1a.data, N_BITS
                )
            )
            print(
                "minterms_3a:"
                + minterms_to_string[tt1.MinTermType, P](
                    minterms_3a.data, N_BITS
                )
            )
            print(
                "minterms_2a:"
                + minterms_to_string[tt1.MinTermType, P](
                    minterms_2a.data, N_BITS
                )
            )
            error = True

        if not (minterms_1b == minterms_3b):
            print(
                "ERROR UT: decompression failed: minterms_1b != minterms_3b;"
                " N_BITS="
                + str(N_BITS)
            )
            print(
                "minterms_1b:"
                + minterms_to_string[tt1.MinTermType, P](
                    minterms_1b.data, N_BITS
                )
            )
            print(
                "minterms_3b:"
                + minterms_to_string[tt1.MinTermType, P](
                    minterms_3b.data, N_BITS
                )
            )
            print(
                "minterms_2b:"
                + minterms_to_string[tt1.MinTermType, P](
                    minterms_2b.data, N_BITS
                )
            )
            error = True

        return error

    for i in range(n_tests):
        var n_minterms = int(random_ui64(1, 50))
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

        if (i & 0xFF) == 0:
            print(
                "INFO UT: test_compress_decompress: progress "
                + str(i)
                + "/"
                + str(n_tests)
            )


fn cnf2dnf_check[
    T: DType, QUIET: Bool
](
    name: String,
    cnf: List[SIMD[T, 1]],
    expected_CNF: String,
    dnf1: List[SIMD[T, 1]],
    expected_DNF1: String,
    dnf2: List[SIMD[T, 1]],
    expected_DNF2: String,
):
    var observed_CNF = cnf_to_string[T](cnf)
    var observed_DNF1 = dnf_to_string[T](dnf1)
    var observed_DNF2 = dnf_to_string[T](dnf2)

    if observed_CNF != expected_CNF:
        print("ERROR UT: " + name)
        print("observed_CNF='" + observed_CNF + "'")
        print("expected_CNF='" + expected_CNF + "'")
    if observed_DNF1 != expected_DNF1:
        print("ERROR UT: " + name)
        print("observed_DNF1='" + observed_DNF1 + "'")
        print("expected_DNF1='" + expected_DNF1 + "'")
    if observed_DNF2 != expected_DNF2:
        print("ERROR UT: " + name)
        print("observed_DNF2='" + observed_DNF2 + "'")
        print("expected_DNF2='" + expected_DNF2 + "'")
    if not QUIET:
        print("INFO UT: " + name + ": observed_CNF=" + observed_CNF)
        print("INFO UT: " + name + ": expected_CNF=" + expected_CNF)
        print("INFO UT: " + name + ": observed_DNF1=" + observed_DNF1)
        print("INFO UT: " + name + ": expected_DNF1=" + expected_DNF1)
        print("INFO UT: " + name + ": observed_DNF2=" + observed_DNF2)
        print("INFO UT: " + name + ": expected_DNF2=" + expected_DNF2)
        print("")


# CNF =  (1|2) & (3|4)
# DNF =  (1&3) | (2&3) | (1&4) | (2&4)
fn test_cnf2dnf_0[QUIET: Bool]():
    alias T = DType.uint32
    alias N_BITS = 8

    var cnf = List[SIMD[T, 1]]()
    cnf.append((1 << 1) | (1 << 2))
    cnf.append((1 << 3) | (1 << 4))

    var dnf1 = convert_cnf_to_dnf[T, SHOW_INFO=False](cnf, N_BITS)
    var dnf2 = convert_cnf_to_dnf_minimal[T, EARLY_PRUNE=True, SHOW_INFO=False](
        cnf, N_BITS
    )
    var expected_CNF = "(1|2) & (3|4)"
    var expected_DNF1 = "(1&3) | (2&3) | (1&4) | (2&4)"
    var expected_DNF2 = "(1&3) | (2&3) | (1&4) | (2&4)"
    cnf2dnf_check[T, QUIET](
        "test_cnf2dnf_0",
        cnf,
        expected_CNF,
        dnf1,
        expected_DNF1,
        dnf2,
        expected_DNF2,
    )


# CNF =  (1|2) & (1|3) & (3|4) & (2|5) & (4|6) & (5|6)
# DNF =  (1&4&5) | (2&3&4&5) | (2&3&6) | (1&2&4&6) | (1&3&5&6)
fn test_cnf2dnf_1[QUIET: Bool]():
    alias T = DType.uint32
    alias N_BITS = 8

    var cnf = List[SIMD[T, 1]]()
    cnf.append((1 << 1) | (1 << 2))
    cnf.append((1 << 3) | (1 << 4))
    cnf.append((1 << 1) | (1 << 3))
    cnf.append((1 << 5) | (1 << 6))
    cnf.append((1 << 2) | (1 << 5))
    cnf.append((1 << 4) | (1 << 6))

    # answer according to wolfram:
    # abdf acef ade bcde bcf
    # 145 1246 1356 2345 236
    # DNF = (145) & (2345) & (236) & (1246) & (1356)
    # DNF (x1 || x2) && (x1 || x3) && (x3 || x4) && (x2 || x5) && (x4 || x6) && (x5 || x6)

    var dnf1 = convert_cnf_to_dnf[T, SHOW_INFO=False](cnf, N_BITS)
    var dnf2 = convert_cnf_to_dnf_minimal[T, EARLY_PRUNE=True, SHOW_INFO=False](
        cnf, N_BITS
    )
    var expected_CNF = "(1|2) & (1|3) & (3|4) & (2|5) & (4|6) & (5|6)"
    var expected_DNF1 = "(1&4&5) | (2&3&4&5) | (2&3&6) | (1&2&4&6) | (1&3&5&6)"
    var expected_DNF2 = "(1&4&5) | (2&3&6)"
    cnf2dnf_check[T, QUIET](
        "test_cnf2dnf_1",
        cnf,
        expected_CNF,
        dnf1,
        expected_DNF1,
        dnf2,
        expected_DNF2,
    )
