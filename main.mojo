from quine_mccluskey import reduce_qm
from MintermSet import MintermSet
from TruthTable import TruthTable


fn minterms_test():
    alias T = DType.uint64
    var minterms = MintermSet[T]()
    minterms.add(0b11100111)
    minterms.add(0b11100001)
    minterms.add(0b01100001)
    minterms.add(0b00100001)

    print("before:\n" + str(minterms))

    # let x = reduce_qm(minterms)
    print("after:\n" + str(minterms))


fn truth_table_test():
    var tt = TruthTable[3]()
    tt.set_true(0b011)
    tt.set_true(0b100)
    tt.set_true(0b101)
    tt.set_true(0b110)
    tt.set_true(0b111)

    #uncompressed:
    #ABC ->F0
    #011 -> 1
    #100 -> 1
    #101 -> 1
    #110 -> 1
    #111 -> 1
    #
    #compressed:
    #ABC ->F0
    #X11 -> 1
    #1XX -> 1

    #print(tt)
    #tt.sort()
    print("INFO: c4eb08c9: uncompressed:")
    print(tt)

    print("INFO: 161fd301: compressed:")
    tt.minimize()
    print(tt)


fn main():
    # minterms_test()
    truth_table_test()
