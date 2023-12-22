from quine_mccluskey import reduce_qm, print_vector
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
    var tt = TruthTable[8]()
    tt.set_true(0b11100111)
    tt.set_true(0b11100001)
    tt.set_true(0b01100001)
    tt.set_true(0b00100001)

    print(str(tt))


fn main():
    # minterms_test()
    truth_table_test()
