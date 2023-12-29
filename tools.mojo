from collections.vector import DynamicVector
from algorithm.sort import sort


fn get_bit[T: DType](v: SIMD[T, 1], pos: Int) -> Bool:
    return ((v >> pos) & 1) == 1


fn get_minterm_type[bit_width: Int]() -> DType:
    @parameter
    if bit_width <= 4:
        return DType.uint8
    elif bit_width <= 8:
        return DType.uint16
    elif bit_width <= 16:
        return DType.uint32
    elif bit_width <= 32:
        return DType.uint64
    else:
        constrained[False]()
    return DType.uint64


fn get_dk_offset[T: DType]() -> Int:
    alias n_bytes = T.sizeof()
    @parameter
    if n_bytes == 1:
        return 4
    elif n_bytes == 2:
        return 8
    elif n_bytes == 4:
        return 16
    elif n_bytes == 8:
        return 32
    else:
        constrained[False]()
    return 32


# delete index by moving the last element into the deleted index
fn delete_index[T: DType](inout v: DynamicVector[SIMD[T, 1]], idx: Int):
    let s = v.size
    if idx == s - 1:
        _ = v.pop_back()
    else:
        v[idx] = v.pop_back()


fn delete_indices[
    T: DType, idx_sorted: Bool = False
](inout v: DynamicVector[SIMD[T, 1]], inout indices: DynamicVector[Int]):
    let i_size = indices.size

    @parameter
    if not idx_sorted:
        sort(indices)
    for i in range(i_size):
        let j = (i_size - i) - 1
        delete_index[T](v, indices[j])
