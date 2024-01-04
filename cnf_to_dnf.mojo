from tools import get_bit, delete_indices
from math.bit import ctpop

fn convert_cnf_to_dnf[DT: DType, SHOW_INFO: Bool](cnf: DynamicVector[SIMD[DT, 1]], n_bits: Int) -> DynamicVector[SIMD[DT, 1]]:
    var result_dnf = DynamicVector[SIMD[DT, 1]]()
    var result_dnf_next = DynamicVector[SIMD[DT, 1]]()
    var first = True
    for i in range(len(cnf)):
        let disjunction = cnf[i]
        if first:
            first = False
            for pos in range(n_bits):
                if get_bit(disjunction, pos):
                    result_dnf.push_back(1 << pos)
        else:
            for pos in range(n_bits):
                if get_bit(disjunction, pos):
                    let x: SIMD[DT, 1] = 1 << pos
                    for j in range(len(result_dnf)):
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
    return result_dnf



# convert_cnf_to_dnf_minimal: for Petricks method, we only need one of the smallest
# conjunction of the DNF, convert_cnf_to_dnf would compute all conjunctions of the DNF
# which could be computationally challenging, hence convert_cnf_to_dnf_minimal only
# computes the smallest ones
fn convert_cnf_to_dnf_minimal[
    DT: DType, EARLY_PRUNE: Bool, SHOW_INFO: Bool
](cnf: DynamicVector[SIMD[DT, 1]], n_bits: Int) -> DynamicVector[SIMD[DT, 1]]:
    var result_dnf = DynamicVector[SIMD[DT, 1]]()

    @parameter
    if EARLY_PRUNE:
        let n_disjunctions = len(cnf)
        var n_disjunction_done = 0

        for i1 in range(n_disjunctions):
            let disjunction = cnf[i1]

            @parameter
            if SHOW_INFO:
                print_no_newline("INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress " + str(n_disjunction_done) + " of " + str(n_disjunctions))

            if n_disjunction_done == 0:
                for pos in range(n_bits):
                    if get_bit(disjunction, pos):
                        result_dnf.push_back(1 << pos)
            else:
                var result_dnf_next = DynamicVector[SIMD[DT, 1]]()
                var smallest_cnf_size: Int = 0x7FFF_FFFF
                var max_size: Int = 0
                var n_pruned: Int = 0
                var n_not_pruned: Int = 0

                for pos in range(n_bits):
                    if get_bit(disjunction, pos):  # unlikely
                        let x: SIMD[DT, 1] = 1 << pos
                        for j in range(len(result_dnf)):
                            let y: SIMD[DT, 1] = result_dnf[j]
                            let z: SIMD[DT, 1] = x.__or__(y)

                            var consider_z = True
                            # Early prune CNFs that cannot become the smallest cnf
                            let conjuction_size: Int = math.bit.ctpop(z).to_int()
                            if conjuction_size < smallest_cnf_size:
                                smallest_cnf_size = conjuction_size
                                max_size = conjuction_size + (
                                    n_disjunctions - n_disjunction_done
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
                if SHOW_INFO:
                    print("; result_dnf_next=" + str(len(result_dnf_next)) + "; n_pruned="+str(n_pruned) + "; n_not_prunned=" + str(n_not_pruned) +"; max_size=" + str(max_size) +"; smallest_cnf_size="+ str(smallest_cnf_size))

                 # swap(result_dnf, result_dnf_next)
                result_dnf = result_dnf_next

            n_disjunction_done += 1
    else:  # do a late prune, can be 20 times slower
        result_dnf = convert_cnf_to_dnf[DT, SHOW_INFO](cnf, n_bits)

    # select only the smallest DNFs
    var smallest_cnf_size = 0x7FFF_FFFF
    for i in range(len(result_dnf)):
        let conjunction = result_dnf[i]
        let count = math.bit.ctpop(conjunction).to_int()
        if count < smallest_cnf_size:
            smallest_cnf_size = count

    var result_dnf_minimal = DynamicVector[SIMD[DT, 1]]()

    for i in range(len(result_dnf)):
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
    var result = TmpStruct2()
    var index = 0
    for i in range(len(dnf)):
        let q = dnf[i]
        let p = z.__or__(q)
        if p == z:  # z is subsumed under q: no need to add z
            return result ^
        elif p == q:  # q is subsumed under z: add z and remove q
            result.index_to_delete.push_back(index)
        index += 1

    result.add_z = True
    return result ^
