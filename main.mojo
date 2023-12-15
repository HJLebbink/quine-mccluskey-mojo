from quine_mccluskey import reduce_qm, print_vector
from MintermSet import MintermSet


fn main():
    alias T = DType.uint64
    var minterms = MintermSet[T]()
    minterms.add(0b11100111)
    minterms.add(0b11100001)
    minterms.add(0b01100001)
    minterms.add(0b00100001)

    print("before:\n" + str(minterms))

    let x = reduce_qm(minterms)
    print("after:\n" + str(minterms))
