from utils.vector import DynamicVector


fn print_vector[T: DType](a: DynamicVector[SIMD[T, 1]]):
    var first = True
    print_no_newline("[")
    for i in range(a.size):
        if first:
            first = False
        else:
            print_no_newline(" ")

        print_no_newline(a.__getitem__(i))
    print_no_newline("]")


fn equal_vector[
    T: DType
](a: DynamicVector[SIMD[T, 1]], b: DynamicVector[SIMD[T, 1]]) -> Bool:
    # assumed a and b are sorted
    if a.__len__() != b.__len__():
        return False
    for i in range(a.__len__()):
        let ai: SIMD[T, 1] = a.__getitem__(i)
        let bi: SIMD[T, 1] = b.__getitem__(i)
        if ai != bi:
            return False
    return True
