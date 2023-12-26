from algorithm.sort import sort
from MyBadMap import MyBadSetStr


@register_passable("trivial")
struct PrintType(Stringable):
    var value: Int
    alias DEC = PrintType(0)
    alias HEX = PrintType(1)
    alias BIN = PrintType(2)

    fn __eq__(self: Self, other: PrintType) -> Bool:
        return self.value == other.value

    fn __init__(value: Int) -> Self:
        return Self {value: value}

    fn __str__(self) -> String:
        if self == PrintType.DEC:
            return "DEC"
        elif self == PrintType.HEX:
            return "HEX"
        elif self == PrintType.BIN:
            return "BIN"
        else:
            return "UNKNOWN"


fn get_bit[T: DType](v: SIMD[T, 1], pos: Int) -> Bool:
    return ((v >> pos) & 1) == 1


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


fn cnf_to_string[T: DType](cnf: DynamicVector[SIMD[T, 1]]) -> String:
    return to_string[T](cnf, True)


fn cnf_to_string2(cnf: DynamicVector[DynamicVector[String]]) -> String:
    return to_string2(cnf, True)


fn dnf_to_string[T: DType](dnf: DynamicVector[SIMD[T, 1]]) -> String:
    return to_string[T](dnf, False)


fn dnf_to_string2(dnf: DynamicVector[DynamicVector[String]]) -> String:
    return to_string2(dnf, False)


fn to_string[T: DType](cnf: DynamicVector[SIMD[T, 1]], is_cnf: Bool) -> String:
    alias n_bits = T.sizeof() * 8
    var cnf_copy = cnf
    sort[T](cnf_copy)
    var result: String = ""
    var first_disj = True
    for i in range(cnf_copy.size):
        let disj = cnf_copy[i]
        if first_disj:
            first_disj = False
        else:
            if is_cnf:
                result += "&"
            else:
                result += "|"
            result += " ("
            var first_e = True
            for pos in range(n_bits):
                if get_bit(disj, pos):
                    if first_e:
                        first_e = False
                    else:
                        if is_cnf:
                            result += "|"
                        else:
                            result += "&"
                    result += str(pos)
            result += ") "
    return result


fn to_string2(cnf: DynamicVector[DynamicVector[String]], is_cnf: Bool) -> String:
    var conjunctions = MyBadSetStr()
    for i in range(cnf.size):
        var conj = cnf[i]
        # sort[String](conj)
        var s: String = " ("
        var first = True
        for j in range(conj.size):
            if first:
                first = False
            else:
                if is_cnf:
                    s += "|"
                else:
                    s += "&"
            s += conj[j]
        s += ") "
        conjunctions.add(s ^)
    var result: String = ""
    var first = True
    for i in range(len(conjunctions)):
        if first:
            first = False
        else:
            if is_cnf:
                result += "&"
            else:
                result += "|"
        result += conjunctions.data[i]
    return result


fn minterms_to_string[
    T: DType, P: PrintType = PrintType.BIN, cap: Int = 10
](minterms: DynamicVector[SIMD[T, 1]], number_vars: Int) -> String:
    var result: String = ""
    for i in range(math.min(len(minterms), cap)):
        result += minterm_to_string[T, P](minterms[i], number_vars) + " "
    return result


fn minterm_to_string[
    T: DType, P: PrintType = PrintType.BIN
](minterm: SIMD[T, 1], number_vars: Int) -> String:
    var result: String = ""

    @parameter
    if P == PrintType.BIN:
        for k in range(number_vars):
            let pos = (number_vars - k) - 1
            let pos_X = pos + 32
            # print("pos "+str(pos)+"; pos_X " + str(pos_X))
            if tools.get_bit(minterm, pos_X):
                result += "X"
            elif tools.get_bit(minterm, pos):
                result += "1"
            else:
                result += "0"
    else:
        result += "ERROR"
    return result
