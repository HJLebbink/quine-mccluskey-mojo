from collections.vector import DynamicVector, InlinedFixedVector
from math.bit import ctpop

from vector_tools import equal_vector, print_vector
from MintermSet import MintermSet
from petrick import petrick_simplify
from to_string import PrintType, minterm_to_string, minterms_to_string
from MyBadMap import MyBadSet
from tools import get_dk_offset

fn crash():
    let x = DynamicVector[Int](0)
    let y = x[100000000]
    print(y)


struct Checked[n_bits: Int]:
    var data: InlinedFixedVector[DTypePointer[DType.bool], n_bits]

    fn __init__(inout self):
        self.data = InlinedFixedVector[DTypePointer[DType.bool], n_bits](n_bits)

    fn at(self, pos: Int) -> DTypePointer[DType.bool]:
        return self.data.__getitem__(pos)

    fn init(inout self, bit_count: Int, size: Int):
        self.data[bit_count] = DTypePointer[DType.bool].aligned_alloc(8, size)
        for i in range(size):
            self.data[bit_count][i] = False


struct MySet[T: DType]:
    var data: DynamicVector[SIMD[T, 1]]
    var is_sorted: Bool

    fn contains(self, v: SIMD[T, 1]) -> Bool:
        for i in range(len(self.data)):
            if self.data[i] == v:
                return True
        return False

    fn add(inout self, v: SIMD[T, 1]):
        if not self.contains(v):
            self.data.push_back(v)


fn is_gray_code[T: DType](a: SIMD[T, 1], b: SIMD[T, 1]) -> Bool:
    return ctpop(a ^ b) == 1


fn replace_complements[T: DType](a: SIMD[T, 1], b: SIMD[T, 1]) -> SIMD[T, 1]:
    alias dk_offset = get_dk_offset[T]()
    let neq = a ^ b
    return a | neq | (neq << dk_offset)


#   template <bool SHOW_INFO, typename T>
#   [[nodiscard]] std::vector<T> reduce_minterms_CLASSIC(const std::vector<T>& minterms) {
#        long long total_comparisons = 0;
#        const long long max = static_cast<long long>(minterms.size());
#        std::vector<char> checked = std::vector<char>(max, false);
#        std::set<T> new_minterms;
#        total_comparisons += (max * max) / 2;
#        for (long long i = 0; i < max; ++i) {
#            const T term_i = minterms[i];
#            for (long long j = i; j < max; ++j) {
#                const T term_j = minterms[j];
#                //If a gray code pair is found, replace the differing bits with don't cares.
#                if (is_gray_code(term_i, term_j)) [[unlikely]] {
#                   checked[i] = true;
#                   checked[j] = true;
#                   new_minterms.insert(replace_complements(term_i, term_j));
#                }
#            }
#        }
#        if constexpr (SHOW_INFO) std::cout << "total_comparisons = " << total_comparisons << std::endl;
#        //appending all reduced terms to a new vector
#        for (long long i = 0; i < max; ++i) {
#           if (!checked[i]) {
#               new_minterms.insert(minterms[i]);
#           }
#        }
#        return std::vector<T>(new_minterms.begin(), new_minterms.end());
#    }
fn reduce_minterms_CLASSIC[
    T: DType, SHOW_INFO: Bool = False
](minterms: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:
    let max = minterms.size
    var checked = DynamicVector[SIMD[DType.bool, 1]](max)
    for i in range(max):
        checked[i] = False
    var new_minterms = MyBadSet[T]()
    for i in range(max):
        let term_i = minterms[i]
        for j in range(i, max):
            let term_j = minterms[j]
            # If a gray code pair is found, replace the differing bits with don't cares.
            if is_gray_code(term_i, term_j):
                checked[i] = True
                checked[j] = True
                let x = replace_complements[T](term_i, term_j)

                @parameter
                if SHOW_INFO:
                    print("INFO: 09f28d3a: term_i:" + minterm_to_string[T](term_i, 3))
                    print("INFO: 2d17146f: term_j:" + minterm_to_string[T](term_j, 3))
                    print("INFO: 313a49ea: new   :" + minterm_to_string[T](x, 3))
                new_minterms.add(x)

    # appending all reduced terms to a new vector
    for i in range(max):
        if not checked[i]:
            new_minterms.add(minterms[i])

    return new_minterms.data


fn reduce_minterms[
    T: DType, bit_width: Int, SHOW_INFO: Bool
](minterms: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:
    var total_comparisons: Int = 0
    var set = MintermSet[T, bit_width]()

    for i in range(len(minterms)):
        set.add[False](minterms[i])

    var new_minterms = DynamicVector[SIMD[T, 1]]()
    var checked_X = Checked[bit_width]()
    let max_bit_count = set.max_bit_count

    print("INFO: 491ff4b6: max_bit_count=" + str(max_bit_count))

    for bit_count in range(max_bit_count + 1):
        let max: Int = len(set.get(bit_count))
        print("INFO: f6241b1f: bit_count = " + str(bit_count) + "; max = " + str(max))
        checked_X.init(bit_count, max)

    for bit_count in range(max_bit_count):
        let minterms_i = set.get(bit_count)
        let minterms_j = set.get(bit_count + 1)
        let max_i = len(minterms_i)
        let max_j = len(minterms_j)

        total_comparisons += max_i * max_j
        print(
            "INFO: 413d6ad8: max_i = "
            + str(max_i)
            + "; max_j = "
            + str(max_j)
            + "; total_comparisons = "
            + str(total_comparisons)
        )

        if True:
            pass
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

                if is_gray_code(term_i, term_j):
                    checked_i[i] = True
                    checked_j[j] = True
                    let new_mt = replace_complements(term_i, term_j)
                    # print("INFO: 8920c08c: adding new minterm " + MintermSet.minterm_to_string[PrintType.BIN](new_mt, 3))
                    new_minterms.push_back(new_mt)

    @parameter
    if SHOW_INFO:
        print("INFO: 393bb38d: total_comparisons = " + str(total_comparisons))
        print(
            "INFO: 0fa954e7: new_minterms "
            + minterms_to_string[T](new_minterms, bit_width)
        )

    var result = new_minterms

    for bit_count in range(max_bit_count + 1):
        let checked_i = checked_X.at(bit_count)
        let minterms_i = set.get(bit_count)

        for i in range(len(minterms_i)):
            if not checked_i[i]:
                result.push_back(minterms_i[i])

    return result


fn eq_minterms[
    T: DType
](v1: DynamicVector[SIMD[T, 1]], v2: DynamicVector[SIMD[T, 1]]) -> Bool:
    if len(v1) != len(v2):
        return False
    for i in range(len(v1)):
        if v1[i] != v2[i]:
            return False
    return True


fn reduce_qm[
    bit_width: Int, T: DType, SHOW_INFO: Bool = False
](minterms_input: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:
    var minterms = minterms_input
    var iteration: Int = 0
    var fixed_point: Bool = False

    while not fixed_point:
        # let next_minterms = reduce_minterms[bit_width, SHOW_INFO](minterms)
        let next_minterms = reduce_minterms_CLASSIC[T, SHOW_INFO](minterms)

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
                + minterms_to_string[T](minterms, bit_width)
            )
            print(
                "INFO: ed11b7c0: new minterms = "
                + minterms_to_string[T](next_minterms, bit_width)
            )
            iteration += 1

        # both are sorted, minterms is not sorted the first iteration, but that is ok.
        fixed_point = eq_minterms[T](minterms, next_minterms)
        #print("INFO: ada1cdf5: fixed_point=" + str(fixed_point))
        minterms = next_minterms ^

    # return petrick_simplify[bit_width, SHOW_INFO](minterms, minterms_input)
    return minterms
