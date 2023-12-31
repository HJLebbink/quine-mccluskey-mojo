from collections.vector import DynamicVector
from algorithm.sort import sort

from tools import get_bit, get_dk_offset
from MyMap import MySet, MySetStr


@register_passable("trivial")
struct PrintType(Stringable):
    var value: Int
    alias VERBOSE = PrintType(0)
    alias HEX = PrintType(1)
    alias BIN = PrintType(2)
    alias BIN_VERBOSE = PrintType(3)

    fn __eq__(self: Self, other: PrintType) -> Bool:
        return self.value == other.value

    fn __init__(value: Int) -> Self:
        return Self {value: value}

    fn __str__(self) -> String:
        if self == PrintType.VERBOSE:
            return "VERBOSE"
        elif self == PrintType.HEX:
            return "HEX"
        elif self == PrintType.BIN:
            return "BIN"
        elif self == PrintType.BIN_VERBOSE:
            return "BIN_VERBOSE"
        else:
            return "UNKNOWN"


fn vector_to_string(v: DynamicVector[Int]) -> String:
    var result: String = ""
    for i in range(len(v)):
        result += str(v[i])
    return result


fn cnf_to_string[T: DType](cnf: DynamicVector[SIMD[T, 1]]) -> String:
    return cnf_dnf_to_string[T, True](cnf)


fn cnf_to_string2(cnf: DynamicVector[DynamicVector[String]]) -> String:
    return cnf_dnf_to_string2[True](cnf)


fn dnf_to_string[T: DType](dnf: DynamicVector[SIMD[T, 1]]) -> String:
    return cnf_dnf_to_string[T, False](dnf)


fn dnf_to_string2(dnf: DynamicVector[DynamicVector[String]]) -> String:
    return cnf_dnf_to_string2[False](dnf)


fn cnf_dnf_to_string[T: DType, is_cnf: Bool](cnf: DynamicVector[SIMD[T, 1]]) -> String:
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


fn cnf_dnf_to_string2[is_cnf: Bool](cnf: DynamicVector[DynamicVector[String]]) -> String:
    var conjunctions = MySetStr()
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
    T: DType, P: PrintType = PrintType.BIN, cap: Int = 30
](minterms: DynamicVector[SIMD[T, 1]], n_vars: Int) -> String:
    var result: String = ""
    let s = math.min(len(minterms), cap)
    for i in range(s):
        result += minterm_to_string[T, P](minterms[i], n_vars)
        @parameter
        if P == PrintType.VERBOSE:
            result += "\n"
        else:
            result += " "
    if len(minterms) > s:
        result += "..."
    return result


fn minterm_to_string[T: DType, P: PrintType = PrintType.BIN](mt: SIMD[T, 1], n_bits: Int) -> String:
    @parameter
    if P == PrintType.BIN:
        return minterm_to_bin_string(mt, n_bits)
    elif P == PrintType.BIN_VERBOSE:
        return minterm_to_bin_string(mt, n_bits) + " (" + int_to_bin_string(mt, n_bits*2)+")"
    elif P == PrintType.VERBOSE:
        return minterm_to_bin_string(mt, n_bits) + "=" + str(mt)
    else:
        return "ERROR"


fn minterm_to_bin_string[T: DType](mt: SIMD[T, 1], n_bits: Int) -> String:
    alias dk_offset: Int = get_dk_offset[T]()
    #print("INFO minterm_to_bin_string dk_offset "+str(dk_offset))
    var result: String = ""
    for i in range(n_bits):
        let pos = (n_bits - i) - 1 # traverse in backwards order
        let pos_X = pos + dk_offset
        #print("pos "+str(pos)+"; pos_X " + str(pos_X))
        if tools.get_bit(mt, pos_X):
            result += "X"
        elif tools.get_bit(mt, pos):
            result += "1"
        else:
            result += "0"
    return result


fn int_to_bin_string[T: DType](v: SIMD[T, 1], n_bits: Int) -> String:
    var result: String = ""
    for i in range(n_bits):
        let pos = (n_bits - i) - 1 # traverse in backwards order
        if tools.get_bit(v, pos):
            result += "1"
        else:
            result += "0"
    return result



