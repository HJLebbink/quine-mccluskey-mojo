from quine_mccluskey import reduce_qm, print_vector

from tensor import Tensor

fn main():

    alias T = DType.uint32
    var minterms = DynamicVector[SIMD[T, 1]](4)
    minterms.push_back(0b11100111)
    minterms.push_back(0b11100001)
    minterms.push_back(0b01100001)
    minterms.push_back(0b00100001)

    print("before:")
    print_vector[T](minterms)

    let x = reduce_qm[T](minterms)

    print("after:")
    print_vector[T](x)
