from tools import get_bit, delete_indices
from math.bit import ctpop
from tools import my_cast


fn convert_cnf_to_dnf[
    T: DType, SHOW_INFO: Bool
](cnf: DynamicVector[SIMD[T, 1]], n_bits: Int) -> DynamicVector[SIMD[T, 1]]:
    var result_dnf = DynamicVector[SIMD[T, 1]]()
    var result_dnf_next = DynamicVector[SIMD[T, 1]]()
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
                    let x: SIMD[T, 1] = 1 << pos
                    for j in range(len(result_dnf)):
                        let z = x.__or__(result_dnf[j])
                        update_dnf(result_dnf_next, z)

            result_dnf = result_dnf_next
            result_dnf_next.clear()
    return result_dnf


# convert_cnf_to_dnf_minimal: for Petricks method, we only need one of the smallest
# conjunction of the DNF, convert_cnf_to_dnf would compute all conjunctions of the DNF
# which could be computationally challenging, hence convert_cnf_to_dnf_minimal only
# computes the smallest ones
fn convert_cnf_to_dnf_minimal[
    T: DType, EARLY_PRUNE: Bool, SHOW_INFO: Bool
](cnf: DynamicVector[SIMD[T, 1]], n_bits: Int) -> DynamicVector[SIMD[T, 1]]:
    var result_dnf = DynamicVector[SIMD[T, 1]]()

    @parameter
    if EARLY_PRUNE:
        let n_disjunctions = len(cnf)
        var n_disjunction_done = 0

        for i1 in range(n_disjunctions):
            let disjunction = cnf[i1]

            @parameter
            if SHOW_INFO:
                print_no_newline(
                    "INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress "
                    + str(n_disjunction_done)
                    + " of "
                    + str(n_disjunctions)
                )

            if n_disjunction_done == 0:
                for pos in range(n_bits):
                    if get_bit(disjunction, pos):
                        result_dnf.push_back(1 << pos)
            else:
                var result_dnf_next = DynamicVector[SIMD[T, 1]]()
                var smallest_cnf_size: Int = 0x7FFF_FFFF
                var max_size: Int = 0
                var n_pruned: Int = 0
                var n_not_pruned: Int = 0

                for pos in range(n_bits):
                    if get_bit(disjunction, pos):
                        let x: SIMD[T, 1] = 1 << pos
                        for j in range(len(result_dnf)):
                            let z: SIMD[T, 1] = x.__or__(result_dnf[j])

                            # Early prune CNFs that cannot become the smallest cnf
                            let conjunction_size: Int = math.bit.ctpop(z).to_int()
                            if conjunction_size < smallest_cnf_size:
                                smallest_cnf_size = conjunction_size
                                max_size = conjunction_size + (
                                    n_disjunctions - n_disjunction_done
                                )

                            var consider_z = True
                            if max_size < conjunction_size:
                                consider_z = False
                                # print_no_newline("INFO: 8668d0bc: Pruning conjunction: the current minimum is " + str(smallest_cnf_size))
                                # print_no_newline(" and the remaining disjunctions is " + str((n_disjunctions - n_disjunction_done)))
                                # print_no_newline(", thus this conjunction with size " + str(conjunction_size) + " can never be the smallest\n");
                                n_pruned += 1
                            else:
                                n_not_pruned += 1

                            if consider_z:
                                update_dnf[T](result_dnf_next, z)

                @parameter
                if SHOW_INFO:
                    print(
                        "; result_dnf_next="
                        + str(len(result_dnf_next))
                        + "; n_pruned="
                        + str(n_pruned)
                        + "; n_not_prunned="
                        + str(n_not_pruned)
                        + "; max_size="
                        + str(max_size)
                        + "; smallest_cnf_size="
                        + str(smallest_cnf_size)
                    )

                result_dnf = result_dnf_next ^

            n_disjunction_done += 1
    else:  # do a late prune, can be 20 times slower
        result_dnf = convert_cnf_to_dnf[T, SHOW_INFO](cnf, n_bits)

    # select only the smallest DNFs
    var smallest_cnf_size = 0x7FFF_FFFF
    for i in range(len(result_dnf)):
        let conjunction = result_dnf[i]
        let count = math.bit.ctpop(conjunction).to_int()
        if count < smallest_cnf_size:
            smallest_cnf_size = count

    var result_dnf_minimal = DynamicVector[SIMD[T, 1]]()

    for i in range(len(result_dnf)):
        let conjunction = result_dnf[i]
        let count = math.bit.ctpop(conjunction).to_int()
        if count == smallest_cnf_size:
            result_dnf_minimal.push_back(conjunction)

    return result_dnf_minimal


# update the DNF one item at a time
fn update_dnf_1[
    T: DType
](
    dnf: DTypePointer[T],
    dnf_length: Int,
    z: SIMD[T, 1],
    begin_index: Int,
    inout index_to_delete: DynamicVector[Int],
) -> Bool:
    for index in range(begin_index, dnf_length):
        let q = dnf[index]
        #let q = dnf.load(index) # seems slower...
        let p = z.__or__(q)
        if p == z:  # z is subsumed under q: no need to add z
            return False
        elif p == q:  # q is subsumed under z: add z and remove q
            index_to_delete.push_back(index)
    return True


# update the DNF N items at a time
fn update_dnf_N[T: DType, SIZE: Int](
    dnf: DTypePointer[T],
    z: SIMD[T, SIZE],
    begin_index: Int,
    inout index_to_delete: DynamicVector[Int],
) -> Bool:
    alias zeros = SIMD[DType.bool, SIZE](False)

    let q2 = dnf.simd_load[SIZE]()
    let p2 = z.__or__(q2)
    let mask1 = p2 == z
    if mask1 != zeros:  # z is subsumed under q: no need to add z
        return False

    let mask2 = p2 == q2
    if mask2 != zeros:  # q is subsumed under z: add z and remove q
        for i in range(SIZE):
            if mask2[i]:
                index_to_delete.push_back(begin_index + i)
                break
        return True
    return False


fn update_dnf[
    T: DType, N_BITS_BLOCK: Int = 0
](inout dnf: DynamicVector[SIMD[T, 1]], z: SIMD[T, 1]):
    var index_to_delete = DynamicVector[Int]()

    @parameter
    if N_BITS_BLOCK < 1:
        let ptr: DTypePointer[T] = my_cast[T, 1](dnf)
        let add_z = update_dnf_1[T](ptr, len(dnf), z, 0, index_to_delete)
        if add_z:
            delete_indices[T, True](dnf, index_to_delete)
            dnf.push_back(z)
        return
    else:
        # NOTE: folling code is broken
        alias BLOCK_SIZE = 1 << N_BITS_BLOCK
        alias zeros = SIMD[DType.bool, BLOCK_SIZE](False)

        let size = len(dnf)
        let n_blocks: Int = size >> N_BITS_BLOCK
        #print("update_dnf: len(dnf)=" + str(len(dnf)) + "; n_blocks=" + str(n_blocks))
        let z2 = SIMD[T, BLOCK_SIZE](z)  # broadcast z to all positions in z2

        var ptr: DTypePointer[T] = my_cast[T, 1](dnf)
        var add_z = False

        for block in range(n_blocks):
            add_z = update_dnf_N[T, BLOCK_SIZE](ptr, z2, 0, index_to_delete)
            if add_z:
                break
            ptr += BLOCK_SIZE * T.sizeof()

        if not add_z:
            let start_tail_index = n_blocks << N_BITS_BLOCK
            add_z = update_dnf_1[T](ptr, len(dnf), z, start_tail_index, index_to_delete)

        if add_z:
            delete_indices[T, True](dnf, index_to_delete)
            dnf.push_back(z)
