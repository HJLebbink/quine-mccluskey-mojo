from utils.vector import DynamicVector
from tensor import Tensor
from vector_tools import equal_vector, print_vector
from MintermSet import MintermSet


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

fn reduce_minterms[T: DType, SHOW_INFO: Bool](minterms: DynamicVector[SIMD[T, 1]]) ->  DynamicVector[SIMD[T, 1]]:
    var total_comparisons: UInt64 = 0;

    var set: MintermSet = MintermSet()
    for i in range(minterms.size):
        let x : SIMD[T, 1] = minterms.__getitem__(i)
        set.add(x.cast[DType.uint32]())

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


    return minterms


fn reduce_qm[T: DType](minterms_input: DynamicVector[SIMD[T, 1]]) -> DynamicVector[SIMD[T, 1]]:
    alias SHOW_INFO: Bool = True

    var minterms = minterms_input
    var next_minterms = DynamicVector[SIMD[T, 1]]()

    var iteration: Int = 0
    var fixed_point: Bool = False

    while not fixed_point:
        next_minterms = reduce_minterms[T, SHOW_INFO](minterms)

        if True:
            print("Iteration ", iteration)
            print_vector[T](next_minterms)
            iteration += 1

        if (equal_vector[T](minterms, next_minterms)): # both are sorted, minterms is not sorted the first iteration, but that is ok.
            fixed_point = True

        minterms = next_minterms;

    #return petrick_simplify(minterms, minterms_input)
    return next_minterms
