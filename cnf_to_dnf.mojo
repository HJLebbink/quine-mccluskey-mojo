from tools import get_bit, delete_indices
from math.bit import ctpop


#        template <OptimizedFor OF, typename DT>
#        [[nodiscard]] std::vector<DT> convert_cnf_to_dnf(const std::vector<DT>& cnf, const int n_bits) {
#            std::vector<DT> result_dnf;
#            bool first = true;
#            for (const DT disjunction : cnf) {
#                if (first) {
#                    first = false;
#                    for (int pos = 0; pos < n_bits; ++pos) {
#                        if (test_bit(disjunction, pos)) {
#                            result_dnf.push_back(1ull << pos);
#                        }
#                    }
#                }
#                else {
#                    std::vector<DT> result_dnf_next;
#                    for (int pos = 0; pos < n_bits; ++pos) {
#                        if (test_bit(disjunction, pos)) [[unlikely]] {
#                            const DT x = (1ull << pos);
#                            for (const DT y : result_dnf) {
#                                const DT z = (x | y);
#                                const std::tuple<std::vector<int>, bool> tup = run_optimized<OF>(result_dnf_next, z);
#                                const bool add_z = std::get<1>(tup);
#                                if (add_z) { //NOTE: if add_z is false, then index_to_delete has to be empty always
#                                    const std::vector<int> index_to_delete = std::move(std::get<0>(tup));
#                                    for (int i = static_cast<int>(index_to_delete.size()) - 1; i >= 0; --i) {
#                                        result_dnf_next.erase(result_dnf_next.begin() + index_to_delete[i]);
#                                    }
#                                    result_dnf_next.push_back(z);
#                                }
#                            }
#                        }
#                    }
#                    std::swap(result_dnf, result_dnf_next);
#                }
#            }
#            return result_dnf;
#        }
fn convert_cnf_to_dnf[
    DT: DType, QUIET: Bool
](cnf: DynamicVector[SIMD[DT, 1]], n_bits: Int) -> DynamicVector[SIMD[DT, 1]]:
    var result_dnf = DynamicVector[SIMD[DT, 1]]()
    var first = True
    for i in range(cnf.size):
        let disjunction = cnf[i]
        if first:
            first = False
            for pos in range(n_bits):
                if get_bit(disjunction, pos):
                    result_dnf.push_back(1 << pos)
        else:
            var result_dnf_next = DynamicVector[SIMD[DT, 1]]()
            for pos in range(n_bits):
                if get_bit(disjunction, pos):
                    let x: SIMD[DT, 1] = 1 << pos
                    for j in range(result_dnf.size):
                        let y = result_dnf[j]
                        let z = x.__or__(y)

                        var tmp_struct = run_optimized(result_dnf_next, z)
                        if tmp_struct.add_z:
                            # print("INFO: size(index_to_delete) = " + str(tmp_struct.index_to_delete.size)) #DynamicVector2Str(index_to_delete))
                            delete_indices[DT, True](
                                result_dnf_next, tmp_struct.index_to_delete
                            )
                            result_dnf_next.push_back(z)

            result_dnf = result_dnf_next
            result_dnf_next.clear()
            # std::swap(result_dnf, result_dnf_next);
    return result_dnf


#        template <OptimizedFor OF, typename DT, bool EARLY_PRUNE, bool QUIET=true>
#        [[nodiscard]] std::vector<DT> convert_cnf_to_dnf_minimal_private(const std::vector<DT>& cnf, const int n_bits)
#        {
#            std::vector<DT> result_dnf;
#
#            if constexpr (EARLY_PRUNE) {
#                const int n_disjuctions = static_cast<int>(cnf.size());
#                int n_disjunction_done = 0;
#
#                for (const DT disjunction : cnf2) {
#                    if constexpr (!QUIET) std::cout << "convert_cnf_to_dnf_minimal: progress " << n_disjunction_done << " of " << n_disjuctions;
#                    if (n_disjunction_done == 0) {
#                        for (int i = 0; i < n_bits; ++i) {
#                            if (test_bit(disjunction, i)) {
#                                result_dnf.push_back(1ull << i);
#                            }
#                        }
#                    }
#                    else {
#                        std::vector<DT> result_dnf_next;
#
#                        int smallest_cnf_size = 0x7FFF'FFFF;
#                        int max_size = 0;
#
#                        int n_pruned = 0;
#                        int n_not_pruned = 0;
#
#                        for (int pos = 0; pos < n_bits; ++pos) {
#                            if (test_bit(disjunction, pos)) [[unlikely]] {
#                                const DT x = (1ull << pos);
#                                for (const DT y : result_dnf) {
#                                    const DT z = (x | y);
#
#                                    bool consider_z = true;
#                                    { // Early prune CNFs that cannot become the smallest cnf
#                                        const int conjuction_size = std::popcount(z);
#                                        if (conjuction_size < smallest_cnf_size) {
#                                            smallest_cnf_size = conjuction_size;
#                                            max_size = conjuction_size + (n_disjuctions - n_disjunction_done);
#                                        }
#                                        if (max_size < conjuction_size) {
#                                            consider_z = false;
#
#                                            //std::cout << "pruning conjunction: the current minimum is " << smallest_cnf_size <<
#                                            //    " and the remaining disjunctions is " << (n_disjuctions - n_disjunction_done) <<
#                                            //    ", thus this conjuction with size " << conjuction_size << " can never be the smallest" <<  std::endl;
#                                            n_pruned++;
#                                        }
#                                        else {
#                                            n_not_pruned++;
#                                        }
#                                    }
#
#                                    if (consider_z) {
#                                        const std::tuple<std::vector<int>, bool> tup = run_optimized<OF>(result_dnf_next, z);
#                                        const bool add_z = std::get<1>(tup);
#
#                                        if (add_z) { //NOTE: if add_z is false, then index_to_delete has to be empty always
#                                            const std::vector<int> index_to_delete = std::move(std::get<0>(tup));
#                                            for (int i = static_cast<int>(index_to_delete.size()) - 1; i >= 0; --i) {
#                                                result_dnf_next.erase(result_dnf_next.begin() + index_to_delete[i]);
#                                            }
#                                            result_dnf_next.push_back(z);
#                                        }
#                                    }
#                                }
#                            }
#                        }
#
#                        if constexpr (!QUIET) std::cout << "; result_dnf_next = " << result_dnf_next.size() << "; n_pruned = " << n_pruned << "; n_not_pruned = " << n_not_pruned << "; max_size " << max_size << "; smallest_cnf_size = " << smallest_cnf_size << std::endl;
#
#                        std::swap(result_dnf, result_dnf_next);
#                    }
#                    n_disjunction_done++;
#                }
#            }
#            else {// do a late prune, can be 20 times slower
#                result_dnf = convert_cnf_to_dnf<OF>(cnf, n_bits);
#            }
#            { // select only the smallest DNFs
#                int smallest_cnf_size = 0x7FFF'FFFF;
#                for (const DT conjunction : result_dnf) {
#                    smallest_cnf_size = std::min(smallest_cnf_size, std::popcount(conjunction));
#                }
#                std::vector<DT> result_dnf_minimal;
#                for (const DT conjunction : result_dnf) {
#                    if (std::popcount(conjunction) == smallest_cnf_size) {
#                        result_dnf_minimal.push_back(conjunction);
#                    }
#                }
#                return result_dnf_minimal;
#            }
#        }


fn convert_cnf_to_dnf_minimal[
    DT: DType, EARLY_PRUNE: Bool, QUIET: Bool
](cnf: DynamicVector[SIMD[DT, 1]], n_bits: Int) -> DynamicVector[SIMD[DT, 1]]:
    var result_dnf = DynamicVector[SIMD[DT, 1]]()

    @parameter
    if EARLY_PRUNE:
        let n_disjuctions = cnf.size
        var n_disjunction_done = 0

        for i in range(n_disjuctions):
            let disjunction = cnf[i]

            # if constexpr (!QUIET) std::cout << "convert_cnf_to_dnf_minimal: progress " << n_disjunction_done << " of " << n_disjuctions;
            if n_disjunction_done == 0:
                for j in range(n_bits):
                    if get_bit(disjunction, j):
                        let x: SIMD[DT, 1] = 1 << i
                        result_dnf.push_back(x)
            else:
                var result_dnf_next = DynamicVector[SIMD[DT, 1]]()
                var smallest_cnf_size: Int = 0x7FFF_FFFF
                var max_size: Int = 0
                var n_pruned: Int = 0
                var n_not_pruned: Int = 0

                for pos in range(n_bits):
                    if get_bit(disjunction, pos):  # unlikely
                        let x: SIMD[DT, 1] = 1 << pos
                        for j in range(result_dnf.size):
                            let y: SIMD[DT, 1] = result_dnf[j]
                            let z: SIMD[DT, 1] = x.__or__(y)

                            var consider_z = True
                            # Early prune CNFs that cannot become the smallest cnf
                            let conjuction_size: Int = math.bit.ctpop(z).to_int()
                            if conjuction_size < smallest_cnf_size:
                                smallest_cnf_size = conjuction_size
                                max_size = conjuction_size + (
                                    n_disjuctions - n_disjunction_done
                                )
                            if max_size < conjuction_size:
                                consider_z = False
                                # std::cout << "pruning conjunction: the current minimum is " << smallest_cnf_size <<
                                # " and the remaining disjunctions is " << (n_disjuctions - n_disjunction_done) <<
                                # ", thus this conjuction with size " << conjuction_size << " can never be the smallest" <<  std::endl;
                                n_pruned += 1
                            else:
                                n_not_pruned += 1

                            if consider_z:
                                var tmp_struct2 = run_optimized(result_dnf_next, z)
                                if tmp_struct2.add_z:
                                    delete_indices[DT, True](
                                        result_dnf_next, tmp_struct2.index_to_delete
                                    )
                                    result_dnf_next.push_back(z)

                @parameter
                if not QUIET:
                    print("; result_dnf_next=" + str(result_dnf_next.size) + "; n_pruned="+str(n_pruned) + "; n_not_prunned=" + str(n_not_pruned) +"; max_size=" + str(max_size) +"; smallest_cnf_size="+ str(smallest_cnf_size))

                result_dnf = result_dnf_next
                # swap(result_dnf, result_dnf_next)
                n_disjunction_done += 1
    else:  # do a late prune, can be 20 times slower
        result_dnf = convert_cnf_to_dnf[DT, QUIET](cnf, n_bits)

    # select only the smallest DNFs
    var smallest_cnf_size = 0x7FFF_FFFF
    for i in range(result_dnf.size):
        let conjuction = result_dnf[i]
        let count = math.bit.ctpop(conjuction).to_int()
        if count < smallest_cnf_size:
            smallest_cnf_size = count

    var result_dnf_minimal = DynamicVector[SIMD[DT, 1]]()

    for i in range(result_dnf.size):
        let conjunction = result_dnf[i]
        let count = math.bit.ctpop(conjunction).to_int()
        if count == smallest_cnf_size:
            result_dnf_minimal.push_back(conjunction)

    return result_dnf_minimal


struct TmpStruct2:
    var index_to_delete: DynamicVector[Int]
    var add_z: Bool

    @always_inline("nodebug")
    fn __init__(inout self):
        self.index_to_delete = DynamicVector[Int]()
        self.add_z = False

    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.index_to_delete = existing.index_to_delete ^
        self.add_z = existing.add_z


fn run_optimized[T: DType](dnf: DynamicVector[SIMD[T, 1]], z: SIMD[T, 1]) -> TmpStruct2:
    # TODO consider only test with content of result_dnf_next that has less number of bits set.
    var result = TmpStruct2()
    var index = 0
    for i in range(dnf.size):
        let q = dnf[i]
        let p = z.__or__(q)
        if p == z:  # z is subsumed under q: no need to add z
            return result ^
        elif p == q:  # q is subsumed under z: add z and remove q
            result.index_to_delete.push_back(index)
        index += 1

    result.add_z = True
    return result ^
