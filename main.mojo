from random import random_ui64

from quine_mccluskey import reduce_qm
from MintermSet import MintermSet
from TruthTable import TruthTable
from cnf_to_dnf import convert_cnf_to_dnf_minimal, convert_cnf_to_dnf
from to_string import PrintType, cnf_to_string, dnf_to_string, cnf_to_string2, dnf_to_string2

fn truth_table_test1():
    alias SHOW_INFO = False

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

    print("INFO: c4eb08c9: uncompressed:")
    print("expected: 011 100 101 110 111")
    print("observed: " + tt.to_string[PrintType.BIN]())

    print("INFO: 161fd301: compressed:")
    print("expected: 1XX X11")
    tt.minimize[USE_CLASSIC_METHOD=True, SHOW_INFO=SHOW_INFO]()
    print("observed: " + tt.to_string[PrintType.BIN]())


# example needs Petricks method; has no primary essential prime implicants
fn truth_table_test2():
    alias SHOW_INFO = False

    alias N_BITS = 4
    var tt = TruthTable[N_BITS]()
    let implicants = VariadicList(0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13) #has primary essential prime implicants; Petricks method is not needed
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

    print("expected: 0000 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011 1100 1101")
    print("observed: " + tt.to_string[PrintType.BIN]())
    tt.minimize[USE_CLASSIC_METHOD=False, SHOW_INFO=SHOW_INFO]()
    print("expected: X10X 10XX 0X1X 0XX0")
    print("observed: " + tt.to_string[PrintType.BIN]())

    # (x̄3x̄0), (x̄3x1), (x2x̄1), (x3x̄2) // manually checked with https://www.mathematik.uni-marburg.de/~thormae/lectures/ti1/code/qmc/
    # 0XX0 0X1X X10X 10XX : identical with observed

    # A'D' + A'C + BC' + AB'  // result from http://www.32x8.com/var4.html
    # 0XX0 0X1X X10X 10XX : identical with observed

    # A~B + ~C~D + ~AC + B~C  // result from https://ictlab.kz/extra/Kmap/
    # 10XX XX00 0X1X X10X : NOT identical with thormae

    # A' B  + B' C  + A C'  + C' D'  // result from logic Friday
    # 01XX X01X 1X0X XX00 ??? mess: not sure what causes this
    # 10XX X10X 0X1X XX11


fn truth_table_test3():
    alias SHOW_INFO = False

    alias N_BITS = 4
    var tt = TruthTable[N_BITS]()
    let implicants = VariadicList(0, 2, 5, 6, 7, 8, 10, 12, 13, 14, 15) #has primary essential prime implicants; Petricks method is not needed
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

    #print("INFO: c4eb08c9: uncompressed:")
    print("expected: 0000 0010 0101 0110 0111 1000 1010 1100 1101 1110 1111")
    print("observed: " + tt.to_string[PrintType.BIN]())

    #print("INFO: 161fd301: compressed:")
    tt.minimize[USE_CLASSIC_METHOD=True, SHOW_INFO=SHOW_INFO]()
    print("expected: X0X0 X1X1 1XX0 XX10")
    print("observed: " + tt.to_string[PrintType.BIN]())

    # (x̄2x̄0) ∨ (x2x0) ∨ (x1x̄0) ∨ (x3x̄0) // manually checked with https://www.mathematik.uni-marburg.de/~thormae/lectures/ti1/code/qmc/
    # X0X0      X1X1      XX10     1XX0

    # C~D + BD + A~D + ~B~D  // result from https://ictlab.kz/extra/Kmap/
    # XX10 X1X1 1XX0 X0X0  : identical with thormae

    # B'D' + CD' + BD + AD'  // result from http://www.32x8.com/var4.html
    # X0X0 XX10 X1X1 1XX0  : identical with thormae

    # B D + B' D' + A D' + C D'  // result from logic Friday
    # X1X1 X0X0 1XX0 XX10  : identical with thormae



fn truth_table_test4():
    alias SHOW_INFO = True

    var tt = TruthTable[8]()
    tt.set_true(0b11100111)
    tt.set_true(0b11100001)
    tt.set_true(0b01100001)
    tt.set_true(0b00100001)

    print("INFO: c4eb08c9: uncompressed:")
    print("expected: 11100111 11100001 01100001 00100001")
    print("observed: " + tt.to_string[PrintType.BIN]())

    print("INFO: 161fd301: compressed:")
    tt.minimize[SHOW_INFO]()
    print("expected: 0X100001 X1100001 11100111")
    print("observed: " + tt.to_string[PrintType.BIN]())


# CNF =  (1|2) & (3|4)
# DNF =  (1&3) | (2&3) | (1&4) | (2&4)
fn test_cnf2dnf_0():
    alias SHOW_INFO = True
    alias DT = DType.uint32
    alias N_BITS = 8

    var cnf1 = DynamicVector[SIMD[DT, 1]]()
    cnf1.push_back((1 << 1) | (1 << 2))
    cnf1.push_back((1 << 3) | (1 << 4))

    print("expected CNF: (1|2) & (3|4)")
    print("observed CNF:" + cnf_to_string[DT](cnf1))
    let dnf1 = convert_cnf_to_dnf[DT, SHOW_INFO](cnf1, N_BITS)
    print("expected DNF: (1&3) | (2&3) | (1&4) | (2&4)")
    print("observed DNF:" + dnf_to_string[DT](dnf1))


# CNF =  (1|2) & (1|3) & (3|4) & (2|5) & (4|6) & (5|6)
# DNF =  (1&4&5) | (2&3&4&5) | (2&3&6) | (1&2&4&6) | (1&3&5&6)
fn test_cnf2dnf_1():
    alias DT = DType.uint32
    alias N_BITS = 8

    var cnf1 = DynamicVector[SIMD[DT, 1]]()
    cnf1.push_back((1 << 1) | (1 << 2))
    cnf1.push_back((1 << 3) | (1 << 4))
    cnf1.push_back((1 << 1) | (1 << 3))
    cnf1.push_back((1 << 5) | (1 << 6))
    cnf1.push_back((1 << 2) | (1 << 5))
    cnf1.push_back((1 << 4) | (1 << 6))

    # answer according to wolfram:
    # abdf acef ade bcde bcf
    # 145 1246 1356 2345 236
    # DNF = (145) & (2345) & (236) & (1246) & (1356)

    print("expected CNF: (1|2) & (1|3) & (3|4) & (2|5) & (4|6) & (5|6)")
    print("observed CNF:" + cnf_to_string[DT](cnf1))
    let dnf1 = convert_cnf_to_dnf[DT, True](cnf1, N_BITS)
    print("expected DNF: (1&4&5) | (2&3&4&5) | (2&3&6) | (1&2&4&6) | (1&3&5&6)")
    print("observed DNF:" + dnf_to_string[DT](dnf1))


# CNF =  (A|B) & (A|C) & (B|E) & (C|D) & (D|F) & (E|F)
# DNF =  (A&B&D&F) | (A&C&E&F) | (A&D&E) | (B&C&D&E) | (B&C&F)
fn test_cnf2dnf_2():
    alias DT = DType.uint32
    # std::vector<std::vector<std::string>> cnf1;
    # cnf1.push_back({ "A", "B" });
    # cnf1.push_back({ "C", "D" });
    # cnf1.push_back({ "A", "C" });
    # cnf1.push_back({ "E", "F" });
    # cnf1.push_back({ "B", "E" });
    # cnf1.push_back({ "D", "F" });

    # print("CNF = " + cnf_to_string2(cnf1))
    # const auto dnf1 = cnf::convert_cnf_to_dnf<OF>(cnf1);
    # print("DNF = " + dnf_to_string(dnf1))


fn test_cnf2dnf_3():
    alias DT = DType.uint32
    alias n_bits = 16
    alias n_conjunctions = 500
    alias n_disjunctions = 8

    var cnf1 = DynamicVector[SIMD[DT, 1]]()
    for i in range(n_conjunctions):
        var conjunction: SIMD[DT, 1] = 0
        for j in range(n_disjunctions):
            let r = random.random_ui64(0, 0xFFFF_FFFF).cast[DT]() % n_bits
            conjunction |= 1 << r
        cnf1.push_back(conjunction)

    print("CNF = " + cnf_to_string[DT](cnf1))
    let dnf1 = convert_cnf_to_dnf[DT, True](cnf1, n_bits)
    print("DNF = " + dnf_to_string[DT](dnf1))


fn test_cnf2dnf_4():
    alias DT = DType.uint32
    alias n_bits = 32
    alias n_conjunctions = 20
    alias n_disjunctions = 8

    var cnf1 = DynamicVector[SIMD[DT, 1]]()
    for i in range(n_conjunctions):
        var conjunction: SIMD[DT, 1] = 0
        for j in range(n_disjunctions):
            let r = random.random_ui64(0, 0xFFFF_FFFF).cast[DT]() % n_bits
            conjunction |= 1 << r
        cnf1.push_back(conjunction)

    print("CNF = " + cnf_to_string[DT](cnf1))
    let dnf1 = convert_cnf_to_dnf[DT, True](cnf1, n_bits)
    print("DNF = " + dnf_to_string[DT](dnf1))


fn test_cnf2dnf_5():
    alias DT = DType.uint64
    alias n_bits = 64
    alias n_conjunctions = 10
    alias n_disjunctions = 8

    var cnf1 = DynamicVector[SIMD[DT, 1]]()
    for i in range(n_conjunctions):
        var conjunction: SIMD[DT, 1] = 0
        for j in range(n_disjunctions):
            let r = random.random_ui64(0, 0xFFFF_FFFF).cast[DT]() % n_bits
            conjunction |= 1 << r
        cnf1.push_back(conjunction)

    print("CNF = " + cnf_to_string[DT](cnf1))
    let dnf1 = convert_cnf_to_dnf[DT, True](cnf1, n_bits)
    print("DNF = " + dnf_to_string[DT](dnf1))


# found very hard example when generating popcnt_6_3
fn test_cnf2dnf_very_hard():
    alias DT = DType.uint64
    alias n_bits = 64

    var cnf1 = DynamicVector[SIMD[DT, 1]]()
    cnf1.push_back(1 << 0 | 1 << 1 | 1 << 2 | 1 << 3)
    cnf1.push_back(1 << 4 | 1 << 5 | 1 << 6 | 1 << 7)
    cnf1.push_back(1 << 3 | 1 << 7 | 1 << 11)
    cnf1.push_back(1 << 8 | 1 << 9 | 1 << 10 | 1 << 11)
    cnf1.push_back(1 << 12 | 1 << 13 | 1 << 14 | 1 << 15)
    cnf1.push_back(1 << 2 | 1 << 15 | 1 << 19)
    cnf1.push_back(1 << 16 | 1 << 17 | 1 << 18 | 1 << 19)
    cnf1.push_back(1 << 10 | 1 << 18 | 1 << 22)
    cnf1.push_back(1 << 6 | 1 << 14 | 1 << 23)
    cnf1.push_back(1 << 20 | 1 << 21 | 1 << 22 | 1 << 23)
    cnf1.push_back(1 << 24 | 1 << 25 | 1 << 26 | 1 << 27)
    cnf1.push_back(1 << 1 | 1 << 27 | 1 << 31)
    cnf1.push_back(1 << 28 | 1 << 29 | 1 << 30 | 1 << 31)
    cnf1.push_back(1 << 9 | 1 << 30 | 1 << 34)
    cnf1.push_back(1 << 5 | 1 << 26 | 1 << 35)
    cnf1.push_back(1 << 32 | 1 << 33 | 1 << 34 | 1 << 35)
    cnf1.push_back(1 << 21 | 1 << 33 | 1 << 37)
    cnf1.push_back(1 << 17 | 1 << 29 | 1 << 38)
    cnf1.push_back(1 << 13 | 1 << 25 | 1 << 39)
    cnf1.push_back(1 << 36 | 1 << 37 | 1 << 38 | 1 << 39)
    cnf1.push_back(1 << 40 | 1 << 41 | 1 << 42 | 1 << 43)
    cnf1.push_back(1 << 0 | 1 << 43 | 1 << 47)
    cnf1.push_back(1 << 44 | 1 << 45 | 1 << 46 | 1 << 47)
    cnf1.push_back(1 << 8 | 1 << 46 | 1 << 50)
    cnf1.push_back(1 << 4 | 1 << 42 | 1 << 51)
    cnf1.push_back(1 << 48 | 1 << 49 | 1 << 50 | 1 << 51)
    cnf1.push_back(1 << 20 | 1 << 49 | 1 << 53)
    cnf1.push_back(1 << 16 | 1 << 45 | 1 << 54)
    cnf1.push_back(1 << 12 | 1 << 41 | 1 << 55)
    cnf1.push_back(1 << 52 | 1 << 53 | 1 << 54 | 1 << 55)
    cnf1.push_back(1 << 36 | 1 << 52 | 1 << 56)
    cnf1.push_back(1 << 32 | 1 << 48 | 1 << 57)
    cnf1.push_back(1 << 28 | 1 << 44 | 1 << 58)
    cnf1.push_back(1 << 24 | 1 << 40 | 1 << 59)
    cnf1.push_back(1 << 56 | 1 << 57 | 1 << 58 | 1 << 59)

    # CNF = (0 | 1 | 2 | 3) & (4 | 5 | 6 | 7) & (3 | 7 | 11) & (8 | 9 | 10 | 11) & (12 | 13 | 14 | 15) & (2 | 15 | 19) & (16 | 17 | 18 | 19) & (10 | 18 | 22) & (6 | 14 | 23) & (20 | 21 | 22 | 23) & (24 | 25 | 26 | 27) & (1 | 27 | 31) & (28 | 29 | 30 | 31) & (9 | 30 | 34) & (5 | 26 | 35) & (32 | 33 | 34 | 35) & (21 | 33 | 37) & (17 | 29 | 38) & (13 | 25 | 39) & (36 | 37 | 38 | 39) & (40 | 41 | 42 | 43) & (0 | 43 | 47) & (44 | 45 | 46 | 47) & (8 | 46 | 50) & (4 | 42 | 51) & (48 | 49 | 50 | 51) & (20 | 49 | 53) & (16 | 45 | 54) & (12 | 41 | 55) & (52 | 53 | 54 | 55) & (36 | 52 | 56) & (32 | 48 | 57) & (28 | 44 | 58) & (24 | 40 | 59) & (56 | 57 | 58 | 59)

    print("CNF = " + cnf_to_string[DT](cnf1))
    alias EARLY_PRUNE = True
    alias SHOW_INFO = True
    let dnf1 = convert_cnf_to_dnf_minimal[DT, EARLY_PRUNE, SHOW_INFO](cnf1, n_bits)
    print("DNF = " + dnf_to_string[DT](dnf1))


fn main():
    #truth_table_test1()
    truth_table_test2()
    #truth_table_test3()
    #truth_table_test4()

    # test_cnf2dnf_0()
    # test_cnf2dnf_1()
    # test_cnf2dnf_2() #TODO
    # test_cnf2dnf_3()
    # test_cnf2dnf_4()
    # test_cnf2dnf_5()
    # test_cnf2dnf_very_hard() #TODO
