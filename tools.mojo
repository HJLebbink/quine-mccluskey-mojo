fn get_bit[T: DType](v: Scalar[T], pos: Int) -> Bool:
    return ((v >> pos).__and__(1)) == 1


fn set_bit[T: DType](v: Scalar[T], pos: Int) -> Scalar[T]:
    return v.__or__(Scalar[T](1) << pos)


fn clear_bit[T: DType](v: Scalar[T], pos: Int) -> Scalar[T]:
    return v.__and__((Scalar[T](1) << pos).__invert__())


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


fn get_dk_mask[T: DType]() -> Scalar[T]:
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
fn delete_index[T: DType](inout v: List[Scalar[T]], idx: Int):
    var s = v.size
    if idx == s - 1:
        _ = v.pop()
    else:
        v[idx] = v.pop()


fn delete_indices[
    T: DType, idx_sorted: Bool = False
](inout v: List[Scalar[T]], inout indices: List[Int]):
    var i_size = indices.size

    @parameter
    if not idx_sorted:
        sort(indices)
    for i in range(i_size):
        var j = (i_size - i) - 1
        delete_index[T](v, indices[j])


fn eq_dynamic_vector[
    T: DType
](v1: List[Scalar[T]], v2: List[Scalar[T]]) -> Bool:
    if len(v1) != len(v2):
        return False
    for i in range(len(v1)):
        if v1[i] != v2[i]:
            return False
    return True


# fn my_cast[T: DType, SIZE: Int](v: List[SIMD[T, SIZE]]) -> DTypePointer[T]:
#    return rebind[DTypePointer[T]](v.data.value)
