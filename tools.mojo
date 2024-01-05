from collections.vector import DynamicVector
from algorithm.sort import sort

fn get_bit[T: DType](v: SIMD[T, 1], pos: Int) -> Bool:
    return ((v >> pos).__and__(1)) == 1


fn set_bit[T: DType](v: SIMD[T, 1], pos: Int) -> SIMD[T, 1]:
    return v.__or__(SIMD[T, 1](1) << pos)


fn clear_bit[T: DType](v: SIMD[T, 1], pos: Int) -> SIMD[T, 1]:
    return v.__and__((SIMD[T, 1](1) << pos).__invert__())


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

fn get_dk_mask[T: DType]() -> SIMD[T, 1]:
    alias n_bytes = T.sizeof()
    @parameter
    if n_bytes == 1:
        return 0xF
    elif n_bytes == 2:
        return 0xFF
    elif n_bytes == 4:
        return 0xFFFF
    elif n_bytes == 8:
        return 0xFFFF_FFFF
    else:
        constrained[False]()
        return 0xFFFF_FFFF


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


fn eq_dynamic_vector[
    T: DType
](v1: DynamicVector[SIMD[T, 1]], v2: DynamicVector[SIMD[T, 1]]) -> Bool:
    if len(v1) != len(v2):
        return False
    for i in range(len(v1)):
        if v1[i] != v2[i]:
            return False
    return True


fn my_cast[T: DType, SIZE: Int](v: DynamicVector[SIMD[T, SIZE]]) -> DTypePointer[T]:
    return rebind[DTypePointer[T]](v.data.value)
