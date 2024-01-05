from collections.vector import DynamicVector, InlinedFixedVector
from math.bit import ctpop

from vector_tools import equal_vector, print_vector
from MintermSet import MintermSet
from petrick import petrick_simplify
from to_string import PrintType, minterm_to_string, minterms_to_string
from MyMap import MySet
from tools import get_dk_offset, eq_dynamic_vector

fn crash():
    let x = DynamicVector[Int](0)
    let y = x[100000000]
    print(y)


struct Checked[n_bits: Int]:
    var data: InlinedFixedVector[DTypePointer[DType.bool], n_bits+1]

    fn __init__(inout self):
        self.data = InlinedFixedVector[DTypePointer[DType.bool], n_bits+1](n_bits+1)

    fn at(self, bit_count: Int) -> DTypePointer[DType.bool]:
        debug_assert(bit_count < n_bits+1, "Checked:at: position 'bit_count' out of range")
        return self.data.__getitem__(bit_count)

    fn init(inout self, bit_count: Int, size: Int):
        debug_assert(bit_count < n_bits+1, "Checked:at: position 'bit_count' out of range")
        self.data[bit_count] = DTypePointer[DType.bool].aligned_alloc(8, size)
        for i in range(size):
            self.data[bit_count][i] = False


fn is_gray_code[T: DType](a: SIMD[T, 1], b: SIMD[T, 1]) -> Bool:
    return ctpop(a ^ b) == 1


fn replace_complements[T: DType](a: SIMD[T, 1], b: SIMD[T, 1]) -> SIMD[T, 1]:
    alias dk_offset = get_dk_offset[T]()
    let neq = a ^ b
    return a | neq | (neq << dk_offset)


fn reduce_minterms_CLASSIC[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](minterms: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:

    alias P = PrintType.BIN
    @parameter
    if SHOW_INFO:
        print("INFO: 65525e46: entering reduce_minterms_CLASSIC")

    var total_comparisons = 0
    let max = minterms.size
    var checked = DynamicVector[SIMD[DType.bool, 1]](max)
    for i in range(max):
        checked[i] = False
    var new_minterms = MySet[T]()
    for i in range(max):
        let term_i = minterms[i]
        for j in range(i + 1, max):
            @parameter
            if SHOW_INFO:
                total_comparisons += 1

            let term_j = minterms[j]
            # If a gray code pair is found, replace the bit position that differs with a don't care.
            if is_gray_code(term_i, term_j):
                checked[i] = True
                checked[j] = True
                let new_mt = replace_complements[T](term_i, term_j)
                @parameter
                if SHOW_INFO:
                    print_no_newline("INFO: 09f28d3a: term_i:" + minterm_to_string[T, P](term_i, N_BITS))
                    print_no_newline("; term_j:" + minterm_to_string[T, P](term_j, N_BITS))
                    print("; new_mt:" + minterm_to_string[T, P](new_mt, N_BITS))
                new_minterms.add(new_mt)

    @parameter
    if SHOW_INFO:
        print("INFO: 393bb38d: total_comparisons = " + str(total_comparisons))

    # appending all reduced terms to a new vector
    for i in range(max):
        if not checked[i]:
            @parameter
            if SHOW_INFO:
                print("INFO: 6dc50c80: adding existing minterm:" + minterm_to_string[T, P](minterms[i], N_BITS))
            new_minterms.add(minterms[i])

    return new_minterms.data

@always_inline("nodebug")
fn reduce_minterms[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](minterms: MintermSet[T, N_BITS]) -> MintermSet[T, N_BITS]:
    @parameter
    if SHOW_INFO:
        print("INFO: a0ab5759: entering: reduce_minterms")

    var total_comparisons: Int = 0
    var new_minterms = MintermSet[T, N_BITS]()
    var checked_X = Checked[N_BITS]()
    let max_bit_count = minterms.max_bit_count

    #print("INFO: 491ff4b6: max_bit_count=" + str(max_bit_count))

    for bit_count in range(max_bit_count + 1):
        let max: Int = len(minterms.get(bit_count))
        #print("INFO: f6241b1f: bit_count = " + str(bit_count) + "; max = " + str(max))
        checked_X.init(bit_count, max)

    for bit_count in range(max_bit_count):
        let minterms_i = minterms.get(bit_count)
        let minterms_j = minterms.get(bit_count + 1)
        let max_i = len(minterms_i)
        let max_j = len(minterms_j)

        @parameter
        if SHOW_INFO:
            total_comparisons += max_i * max_j
            print(
                "INFO: 413d6ad8: max_i = "
                + str(max_i)
                + "; max_j = "
                + str(max_j)
                + "; total_comparisons = "
                + str(total_comparisons)
            )
            # print("INFO: 5fa644ad: minterms_i: " + minterms_to_string[Self.MinTermType, 3](minterms_i, 10))
            # print("INFO: 84923df6: minterms_j: " + minterms_to_string[T, 3](minterms_j, 10))
            # print("\n\n")
            # print("minterms_i: " + minterms_to_string(minterms_i) + "\n")

        let checked_i = checked_X.at(bit_count)
        let checked_j = checked_X.at(bit_count + 1)

        for i in range(max_i):
            let term_i = minterms_i[i]

            for j in range(max_j):
                let term_j = minterms_j[j]
                # If a gray code pair is found, replace the bit position that differs with a don't care.
                if is_gray_code(term_i, term_j):
                    checked_i[i] = True
                    checked_j[j] = True
                    let new_mt = replace_complements(term_i, term_j)
                    @parameter
                    if SHOW_INFO:
                        print_no_newline("INFO: 09f28d3a: term_i:" + minterm_to_string[T](term_i, N_BITS))
                        print_no_newline("; term_j:" + minterm_to_string[T](term_j, N_BITS))
                        print("; new_mt:" + minterm_to_string[T](new_mt, N_BITS))
                    new_minterms.add(new_mt)
    @parameter
    if SHOW_INFO:
        print("INFO: 393bb38d: total_comparisons=" + str(total_comparisons))
        #print("INFO: 0fa954e7: new_minterms=" + new_minterms.to_string[PrintType.BIN](N_BITS))

    for bit_count in range(max_bit_count + 1):
        let checked_i = checked_X.at(bit_count)
        let minterms_i = minterms.get(bit_count)

        for i in range(len(minterms_i)):
            if not checked_i[i]:
                new_minterms.add(minterms_i[i])

    return new_minterms


fn reduce_qm_classic[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](owned minterms_input: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:
    var minterms = minterms_input
    var iteration: Int = 0
    var fixed_point: Bool = False

    while not fixed_point:
        let next_minterms = reduce_minterms_CLASSIC[T, N_BITS, SHOW_INFO](minterms)

        @parameter
        if SHOW_INFO:
            print(
                "INFO: 361a49a4: reduce_qm: iteration "
                + str(iteration)
                + "; minterms "
                + len(minterms)
                + "; next minterms "
                + len(next_minterms)
            )
            print(
                "INFO: 49ecfd1e: old minterms = "
                + minterms_to_string[T](minterms, N_BITS)
            )
            print(
                "INFO: ed11b7c0: new minterms = "
                + minterms_to_string[T](next_minterms, N_BITS)
            )
            iteration += 1

        # both are sorted, minterms is not sorted the first iteration, but that is ok.
        fixed_point = eq_dynamic_vector[T](minterms, next_minterms)
        minterms = next_minterms^

    return petrick_simplify[T, T, N_BITS, SHOW_INFO](minterms, minterms_input)


fn reduce_qm[
    T: DType, N_BITS: Int, SHOW_INFO: Bool = False
](owned minterms_input: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:
    var iteration: Int = 0
    var fixed_point: Bool = False
    var minterms = MintermSet[T, N_BITS]()
    for i in range(len(minterms_input)):
        minterms.add[check_duplicate=False, SHOW_INFO=SHOW_INFO](minterms_input[i])

    while not fixed_point:
        let next_minterms = reduce_minterms[T, N_BITS, SHOW_INFO](minterms)

        @parameter
        if SHOW_INFO:
            print(
                "INFO: 361a49a4: reduce_qm: iteration "
                + str(iteration)
                + "; minterms "
                + len(minterms)
                + "; next minterms "
                + len(next_minterms)
            )
            print( "INFO: 49ecfd1e: old minterms = " + minterms.to_string[PrintType.BIN](N_BITS))
            print( "INFO: ed11b7c0: new minterms = " + next_minterms.to_string[PrintType.BIN](N_BITS))
            iteration += 1

        fixed_point = minterms == next_minterms
        minterms = next_minterms^

    let minterms_vec = minterms.to_dynamic_vector()
    return petrick_simplify[T, T, N_BITS, SHOW_INFO](minterms_vec, minterms_input)
