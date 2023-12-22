from collections.vector import DynamicVector, InlinedFixedVector
from vector_tools import equal_vector, print_vector
from MintermSet import MintermSet
from math.bit import ctpop

#    template <bool SHOW_INFO, typename T>
#    [[nodiscard]] std::vector<T> reduce_minterms(const std::vector<T>& minterms)
#    {
#        long long total_comparisons = 0;

#        MintermSet set;
#        set.add(minterms);

#        std::set<T> new_minterms;

#        std::vector<std::vector<char>> checked_X;
#        const long long max_bit_count = static_cast<long long>(set.get_max_bit_count());
#        //std::cout << "max_bit_count=" << max_bit_count << std::endl;

#        for (long long bit_count = 0; bit_count <= max_bit_count; ++bit_count)
#        {
#            const int max = static_cast<int>(set.get(bit_count).size());
#            //std::cout << "bit_count = " << bit_count << "; max = " << max << std::endl;
#            checked_X.push_back(std::vector<char>(max, false));
#        }

#        for (long long bit_count = 0; bit_count < max_bit_count; ++bit_count)
#        {
#            const std::vector<T>& minterms_i = set.get(bit_count);
#            const std::vector<T>& minterms_j = set.get(bit_count + 1);
#            const int max_i = static_cast<int>(minterms_i.size());
#            const int max_j = static_cast<int>(minterms_j.size());

#            total_comparisons += (static_cast<long long>(max_i) * static_cast<long long>(max_j));

#            // std::cout << "max_i = " << max_i << "; max_j = " << max_j << "; total_comparisons = " << total_comparisons << std::endl;
#            if (false) {
#                std::cout << "minterms_i:";
#                for (int i = 0; i < std::min(max_i, 10); ++i) {
#                    std::cout << " " << std::bitset<16>(minterms_i[i]).to_string();
#                }
#                std::cout << std::endl;
#                std::cout << "minterms_j:";
#                for (int i = 0; i < std::min(max_j, 10); ++i) {
#                    std::cout << " " << std::bitset<16>(minterms_j[i]).to_string();
#                }
#                std::cout << std::endl << std::endl;

#                std::cout << "                ";
#                for (int i = 0; i < std::min(max_i, 10); ++i) {
#                    std::cout << " " << std::bitset<16>(minterms_i[i]).to_string();
#                }
#                std::cout << std::endl;
#                for (int j = 0; j < std::min(max_j, 10); ++j) {
#                    const T term_j = minterms_j[j];
#                    std::cout << std::bitset<16>(term_j).to_string();

#                    for (int i = 0; i < std::min(max_i, 10); ++i) {
#                        const T term_i = minterms_i[i];
#                        std::cout << "                " << is_gray_code(term_i, term_j);
#                    }
#                    std::cout << std::endl;
#                }
#            }

#            std::vector<char>& checked_i = checked_X.at(bit_count);
#            std::vector<char>& checked_j = checked_X.at(bit_count + 1);

#            for (int i = 0; i < max_i; ++i) {
#                const T term_i = minterms_i[i];

#                for (int j = 0; j < max_j; ++j) {
#                    //%47 of time next line
#                    const T term_j = minterms_j[j];

#                    //%47 of time next line
#                    //if (std::popcount(a ^ b) == 1)
#                    if (is_gray_code(term_i, term_j)) [[unlikely]]
#                    {
#                        checked_i[i] = true;
#                        checked_j[j] = true;
#                        new_minterms.insert(replace_complements(term_i, term_j));
#                    }
#                }
#            }
#        }
#        if constexpr (SHOW_INFO) std::cout << "total_comparisons = " << total_comparisons << std::endl;

#        std::vector<T> result = std::vector<T>(new_minterms.begin(), new_minterms.end());

#        for (int bit_count = 0; bit_count < (max_bit_count + 1); ++bit_count)
#        {
#            const std::vector<char>& checked_i = checked_X[bit_count];
#            const std::vector<T>& minterms_i = set.get(bit_count);

#            for (int i = 0; i < static_cast<int>(checked_i.size()); ++i)
#            {
#                if (!checked_i[i]) {
#                    //std::cout << "not checked i " << std::bitset<16 + 3>(minterms_i[i]) << std::endl;
#                    result.push_back(minterms_i[i]);
#                }
#            }
#        }
#        return result;
#    }


struct Checked:
    var data: InlinedFixedVector[DTypePointer[DType.bool], 32]

    fn __init__(inout self):
        self.data = InlinedFixedVector[DTypePointer[DType.bool], 32](32)

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
    let neq = a ^ b
    return a | neq | (neq << 32)


fn minterms_to_string[T: DType](v: DynamicVector[SIMD[T, 1]]) -> String:
    var result: String = ""
    for i in range(math.min(len(v), 10)):
        let x = v[i]
        for j in range(32, 0):
            if ((x >> j) & 1) == 1:
                result += "1"
            else:
                result += "0"
        result += " "
    return result


fn reduce_minterms[T: DType, SHOW_INFO: Bool](minterms: MintermSet[T]) -> MintermSet[T]:
    var total_comparisons: UInt64 = 0
    let set = minterms
    var new_minterms = MintermSet[T]()
    var checked_X = Checked()
    let max_bit_count = set.max_bit_count

    for bit_count in range(max_bit_count):
        let max: Int = len(set.get(bit_count))
        # print("bit_count = "+ str(bit_count)+ "; max = " + str(max) +"\n")
        checked_X.init(bit_count, max)

    for bit_count in range(max_bit_count):
        let minterms_i = set.get(bit_count)
        let minterms_j = set.get(bit_count + 1)
        let max_i = len(minterms_i)
        let max_j = len(minterms_j)

        total_comparisons += max_i * max_j
        # print("max_i = " + str(max_i) + "; max_j = " + str(max_j) + "; total comparisons = " + str(total_comparisons) + "\n")

        if True:
            print("minterms_i: " + minterms_to_string[T](minterms_i))
            print("minterms_j: " + minterms_to_string[T](minterms_j))
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
                    new_minterms.add(replace_complements[T](term_i, term_j))

    @parameter
    if SHOW_INFO:
        print("total_comparisons = " + str(total_comparisons))

    var result = new_minterms

    for bit_count in range(max_bit_count + 1):
        let checked_i = checked_X.at(bit_count)
        let minterms_i = set.get(bit_count)

        for i in range(len(minterms_i)):
            if checked_i[i]:
                result.add(minterms_i[i])

    return result


fn reduce_qm[T: DType](minterms_input: MintermSet[T]) -> MintermSet[T]:
    alias SHOW_INFO: Bool = True

    var minterms = minterms_input
    var next_minterms = MintermSet[T]()

    var iteration: Int = 0
    var fixed_point: Bool = False

    while not fixed_point:
        next_minterms = reduce_minterms[T, SHOW_INFO](minterms)

        if True:
            print("Iteration ", iteration)
            print(next_minterms)
            iteration += 1

        # both are sorted, minterms is not sorted the first iteration, but that is ok.
        fixed_point = minterms == next_minterms
        minterms = next_minterms

    # return petrick_simplify(minterms, minterms_input)
    return next_minterms
