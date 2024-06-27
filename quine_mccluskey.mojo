from collections.vector import InlinedFixedVector
from bit import pop_count

from MinTermSet import MinTermSet
from petrick import petrick_simplify
from to_string import PrintType, minterm_to_string, minterms_to_string
from MySet import MySet
from tools import get_dk_offset, eq_dynamic_vector


fn crash():
    var x = List[Int](0)
    var y = x[100000000]
    print(y)


struct Checked[N_BITS: Int]:
    var data: InlinedFixedVector[DTypePointer[DType.bool], N_BITS + 1]

    fn __init__(inout self):
        self.data = InlinedFixedVector[DTypePointer[DType.bool], N_BITS + 1](
            N_BITS + 1
        )

    fn at(self, bit_count: Int) -> DTypePointer[DType.bool]:
        debug_assert(
            bit_count < N_BITS + 1,
            "Checked:at: position 'bit_count' out of range",
        )
        return self.data.__getitem__(bit_count)

    fn init(inout self, bit_count: Int, size: Int):
        debug_assert(
            bit_count < N_BITS + 1,
            "Checked:at: position 'bit_count' out of range",
        )
        self.data[bit_count] = DTypePointer[DType.bool].alloc(size)
        for i in range(size):
            self.data[bit_count][i] = False


fn is_gray_code[T: DType](a: SIMD[T, 1], b: SIMD[T, 1]) -> Bool:
    return pop_count(a ^ b) == 1


fn replace_complements[T: DType](a: SIMD[T, 1], b: SIMD[T, 1]) -> SIMD[T, 1]:
    alias dk_offset = get_dk_offset[T]()
    var neq = a ^ b
    return a | neq | (neq << dk_offset)


fn reduce_minterms_CLASSIC[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](minterms: MySet[T]) -> MySet[T]:
    alias P = PrintType.BIN

    @parameter
    if SHOW_INFO:
        print("INFO: 65525e46: entering reduce_minterms_CLASSIC")

    var total_comparisons = 0
    var max = len(minterms)
    var checked = List[SIMD[DType.bool, 1]](max)
    for i in range(max):
        checked[i] = False
    var new_minterms = MySet[T]()
    for i in range(max):
        var term_i = minterms.data[i]
        for j in range(i + 1, max):

            @parameter
            if SHOW_INFO:
                total_comparisons += 1

            var term_j = minterms.data[j]
            # If a gray code pair is found, replace the bit position that differs with a don't care.
            if is_gray_code(term_i, term_j):
                checked[i] = True
                checked[j] = True
                var new_mt = replace_complements[T](term_i, term_j)

                @parameter
                if SHOW_INFO:
                    print(
                        "INFO: 09f28d3a: term_i:"
                        + minterm_to_string[T, P](term_i, N_BITS),
                        end="",
                    )
                    print(
                        "; term_j:" + minterm_to_string[T, P](term_j, N_BITS),
                        end="",
                    )
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
                print(
                    "INFO: 6dc50c80: adding existing minterm:"
                    + minterm_to_string[T, P](minterms.data[i], N_BITS)
                )
            new_minterms.add(minterms.data[i])

    new_minterms.sort()
    return new_minterms^


@always_inline("nodebug")
fn reduce_minterms[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](minterms: MinTermSet[T, N_BITS]) -> MinTermSet[T, N_BITS]:
    @parameter
    if SHOW_INFO:
        print("INFO: a0ab5759: entering: reduce_minterms")

    var total_comparisons: Int = 0
    var new_minterms = MinTermSet[T, N_BITS]()
    var checked_X = Checked[N_BITS]()
    var max_bit_count = minterms.max_bit_count

    # print("INFO: 491ff4b6: max_bit_count=" + str(max_bit_count))

    for bit_count in range(max_bit_count + 1):
        var max: Int = len(minterms.get(bit_count))
        # print("INFO: f6241b1f: bit_count = " + str(bit_count) + "; max = " + str(max))
        checked_X.init(bit_count, max)

    for bit_count in range(max_bit_count):
        var minterms_i = minterms.get(bit_count)
        var minterms_j = minterms.get(bit_count + 1)
        var max_i = len(minterms_i)
        var max_j = len(minterms_j)

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

        var checked_i = checked_X.at(bit_count)
        var checked_j = checked_X.at(bit_count + 1)

        for i in range(max_i):
            var term_i = minterms_i[i]

            for j in range(max_j):
                var term_j = minterms_j[j]
                # If a gray code pair is found, replace the bit position that differs with a don't care.
                if is_gray_code(term_i, term_j):
                    checked_i[i] = True
                    checked_j[j] = True
                    var new_mt = replace_complements(term_i, term_j)

                    @parameter
                    if SHOW_INFO:
                        print(
                            "INFO: 09f28d3a: term_i:"
                            + minterm_to_string[T](term_i, N_BITS),
                            end="",
                        )
                        print(
                            "; term_j:" + minterm_to_string[T](term_j, N_BITS),
                            end="",
                        )
                        print(
                            "; new_mt:" + minterm_to_string[T](new_mt, N_BITS)
                        )
                    new_minterms.add(new_mt)

    @parameter
    if SHOW_INFO:
        print("INFO: 393bb38d: total_comparisons=" + str(total_comparisons))
        # print("INFO: 0fa954e7: new_minterms=" + new_minterms.to_string[PrintType.BIN](N_BITS))

    for bit_count in range(max_bit_count + 1):
        var checked_i = checked_X.at(bit_count)
        var minterms_i = minterms.get(bit_count)

        for i in range(len(minterms_i)):
            if not checked_i[i]:
                new_minterms.add(minterms_i[i])

    new_minterms.sort()
    return new_minterms


fn reduce_qm_classic[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](owned minterms_input: MySet[T]) -> MySet[T]:
    var minterms = minterms_input
    var iteration: Int = 0
    var fixed_point: Bool = False

    while not fixed_point:
        var next_minterms = reduce_minterms_CLASSIC[T, N_BITS, SHOW_INFO](
            minterms
        )

        @parameter
        if SHOW_INFO:
            print(
                "INFO: 361a49a4: reduce_qm: iteration "
                + str(iteration)
                + "; minterms "
                + str(len(minterms))
                + "; next minterms "
                + str(len(next_minterms))
            )
            print(
                "INFO: 49ecfd1e: old minterms = "
                + minterms_to_string[T](minterms.data, N_BITS)
            )
            print(
                "INFO: ed11b7c0: new minterms = "
                + minterms_to_string[T](next_minterms.data, N_BITS)
            )
            iteration += 1

        # both are sorted, minterms is not sorted the first iteration, but that is ok.
        fixed_point = minterms == next_minterms
        minterms = next_minterms^

    return petrick_simplify[T, T, N_BITS, SHOW_INFO](minterms, minterms_input)


fn reduce_qm[
    T: DType, N_BITS: Int, SHOW_INFO: Bool
](owned minterms_input: MySet[T]) -> MySet[T]:
    var iteration: Int = 0
    var fixed_point: Bool = False
    var minterms = MinTermSet[T, N_BITS]()

    for i in range(len(minterms_input)):
        minterms.add[CHECK_CONTAINS=False, SHOW_INFO=SHOW_INFO](
            minterms_input.data[i]
        )
    minterms.sort()

    while not fixed_point:
        var next_minterms = reduce_minterms[T, N_BITS, SHOW_INFO](minterms)

        @parameter
        if SHOW_INFO:
            print(
                "INFO: 361a49a4: reduce_qm: iteration "
                + str(iteration)
                + "; minterms "
                + str(len(minterms))
                + "; next minterms "
                + str(len(next_minterms))
            )
            print(
                "INFO: 49ecfd1e: old minterms = "
                + minterms.to_string[PrintType.BIN](N_BITS)
            )
            print(
                "INFO: ed11b7c0: new minterms = "
                + next_minterms.to_string[PrintType.BIN](N_BITS)
            )
            iteration += 1

        fixed_point = minterms == next_minterms
        minterms = next_minterms^

    return petrick_simplify[T, T, N_BITS, SHOW_INFO](
        minterms.to_set(), minterms_input
    )
