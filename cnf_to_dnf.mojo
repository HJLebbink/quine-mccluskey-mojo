from tools import get_bit, delete_indices
from bit import pop_count


fn convert_cnf_to_dnf[
    T: DType, SHOW_INFO: Bool
](cnf: List[Scalar[T]], n_bits: Int) -> List[Scalar[T]]:
    var result_dnf = List[Scalar[T]]()
    var result_dnf_next = List[Scalar[T]]()
    var first = True
    for i in range(len(cnf)):
        var disjunction = cnf[i]
        if first:
            first = False
            for pos in range(n_bits):
                if get_bit(disjunction, pos):
                    result_dnf.append(1 << pos)
        else:
            for pos in range(n_bits):
                if get_bit(disjunction, pos):
                    var x: Scalar[T] = 1 << pos
                    for j in range(len(result_dnf)):
                        var z = x.__or__(result_dnf[j])
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
](cnf: List[Scalar[T]], n_bits: Int) -> List[Scalar[T]]:
    var result_dnf = List[Scalar[T]]()

    @parameter
    if EARLY_PRUNE:
        var n_disjunctions = len(cnf)
        var n_disjunction_done = 0

        for i1 in range(n_disjunctions):
            var disjunction = cnf[i1]

            @parameter
            if SHOW_INFO:
                print(
                    "INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress "
                    + str(n_disjunction_done)
                    + " of "
                    + str(n_disjunctions),
                    end="",
                )

            if n_disjunction_done == 0:
                for pos in range(n_bits):
                    if get_bit(disjunction, pos):
                        result_dnf.append(1 << pos)
            else:
                var result_dnf_next = List[Scalar[T]]()
                var smallest_cnf_size: Int = 0x7FFF_FFFF
                var max_size: Int = 0
                var n_pruned: Int = 0
                var n_not_pruned: Int = 0

                for pos in range(n_bits):
                    if get_bit(disjunction, pos):
                        var x: Scalar[T] = 1 << pos
                        for j in range(len(result_dnf)):
                            var z: Scalar[T] = x.__or__(result_dnf[j])

                            # Early prune CNFs that cannot become the smallest cnf
                            var conjunction_size: Int = int(pop_count(z))
                            if conjunction_size < smallest_cnf_size:
                                smallest_cnf_size = conjunction_size
                                max_size = conjunction_size + (
                                    n_disjunctions - n_disjunction_done
                                )

                            var consider_z = True
                            if max_size < conjunction_size:
                                consider_z = False
                                # print("INFO: 8668d0bc: Pruning conjunction: the current minimum is " + str(smallest_cnf_size), end='')
                                # print(" and the remaining disjunctions is " + str((n_disjunctions - n_disjunction_done)), end='')
                                # print(", thus this conjunction with size " + str(conjunction_size) + " can never be the smallest");
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

                result_dnf = result_dnf_next^

            n_disjunction_done += 1
    else:  # do a late prune, can be 20 times slower
        result_dnf = convert_cnf_to_dnf[T, SHOW_INFO](cnf, n_bits)

    # select only the smallest DNFs
    var smallest_cnf_size = 0x7FFF_FFFF
    for i in range(len(result_dnf)):
        var conjunction = result_dnf[i]
        var count = int(pop_count(conjunction))
        if count < smallest_cnf_size:
            smallest_cnf_size = count

    var result_dnf_minimal = List[Scalar[T]]()

    for i in range(len(result_dnf)):
        var conjunction = result_dnf[i]
        var count = int(pop_count(conjunction))
        if count == smallest_cnf_size:
            result_dnf_minimal.append(conjunction)

    return result_dnf_minimal


# update the DNF one item at a time
fn update_dnf_1[
    T: DType
](
    dnf: DTypePointer[T],
    dnf_length: Int,
    z: Scalar[T],
    begin_index: Int,
    inout index_to_delete: List[Int],
) -> Bool:
    for index in range(begin_index, dnf_length):
        var q = dnf[index]
        # var q = dnf.load(index) # seems slower...
        var p = z.__or__(q)
        if p == z:  # z is subsumed under q: no need to add z
            return False
        elif p == q:  # q is subsumed under z: add z and remove q
            index_to_delete.append(index)
    return True


# update the DNF N items at a time
fn update_dnf_N[
    T: DType, SIZE: Int
](
    dnf: DTypePointer[T],
    z: SIMD[T, SIZE],
    begin_index: Int,
    inout index_to_delete: List[Int],
) -> Bool:
    alias zeros = SIMD[DType.bool, SIZE](False)

    var q2: SIMD[T, SIZE] = dnf.load[width=SIZE]()
    var p2 = z.__or__(q2)
    var mask1 = p2 == z
    if mask1 != zeros:  # z is subsumed under q: no need to add z
        return False

    var mask2 = p2 == q2
    if mask2 != zeros:  # q is subsumed under z: add z and remove q
        for i in range(SIZE):
            if mask2[i]:
                index_to_delete.append(begin_index + i)
                break
        return True
    return False


fn update_dnf[
    T: DType, N_BITS_BLOCK: Int = 0
](inout dnf: List[Scalar[T]], z: SIMD[T, 1]):
    var index_to_delete = List[Int]()

    @parameter
    if N_BITS_BLOCK < 1:
        var ptr: DTypePointer[T] = DTypePointer[T](dnf.unsafe_ptr())
        var add_z = update_dnf_1[T](ptr, len(dnf), z, 0, index_to_delete)
        if add_z:
            delete_indices[T, True](dnf, index_to_delete)
            dnf.append(z)
        return
    else:
        # NOTE: folling code is broken
        alias BLOCK_SIZE = 1 << N_BITS_BLOCK
        alias zeros = SIMD[DType.bool, BLOCK_SIZE](False)

        var size = len(dnf)
        var n_blocks: Int = size >> N_BITS_BLOCK
        # print("update_dnf: len(dnf)=" + str(len(dnf)) + "; n_blocks=" + str(n_blocks))
        var z2 = SIMD[T, BLOCK_SIZE](z)  # broadcast z to all positions in z2

        var ptr: DTypePointer[T] = DTypePointer[T](dnf.unsafe_ptr())
        var add_z = False

        for block in range(n_blocks):
            add_z = update_dnf_N[T, BLOCK_SIZE](ptr, z2, 0, index_to_delete)
            if add_z:
                break
            ptr += BLOCK_SIZE * T.sizeof()

        if not add_z:
            var start_tail_index = n_blocks << N_BITS_BLOCK
            add_z = update_dnf_1[T](
                ptr, len(dnf), z, start_tail_index, index_to_delete
            )

        if add_z:
            delete_indices[T, True](dnf, index_to_delete)
            dnf.append(z)
