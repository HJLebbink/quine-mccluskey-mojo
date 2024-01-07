from collections.vector import DynamicVector
from algorithm.sort import sort

#cannot reproduce the bug `alias TT2 = TruthTable[4](implicants, compress=True)`

fn foo[T: DType]() -> DynamicVector[SIMD[T, 1]]:
    var d = DynamicVector[SIMD[T, 1]](100)
    sort[T](d)
    return d

fn main():
    alias XYZZY = foo[DType.uint8]()
    print(str(XYZZY[0]))
