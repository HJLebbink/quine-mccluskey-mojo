from MyMap import MyMap
from MySet import MySet
from cnf_to_dnf import convert_cnf_to_dnf_minimal, convert_cnf_to_dnf
from tools import get_bit, get_dk_offset, get_dk_mask
from to_string import (
    PrintType,
    minterm_to_string,
    minterms_to_string,
    int_to_bin_string,
    cnf_to_string,
    dnf_to_string,
)
from algorithm.sort import sort

# using PI_table_1 = std::map<PI, std::unordered_set<MT>>;
# using PI_table_2 = std::map<MT, std::unordered_set<PI>>;


fn convert_1to2[
    PI: DType, MT: DType
](pi_table1: MyMap[PI, MySet[MT]]) -> MyMap[MT, MySet[PI]]:
    var all_minterms = MySet[MT]()
    for i in range(len(pi_table1)):
        all_minterms.add(pi_table1.values[i])
    var pi_table2 = MyMap[MT, MySet[PI]]()
    for i in range(len(all_minterms)):
        let mt = all_minterms.data[i]
        var set2 = MySet[PI]()
        for j in range(len(pi_table1)):
            let x = pi_table1.keys[j]
            let set = pi_table1.values[j]
            if set.contains(mt):
                set2.add(x)
        pi_table2.add(mt, set2 ^)
    return pi_table2 ^


fn convert_2to1[
    PI: DType, MT: DType
](pi_table2: MyMap[MT, MySet[PI]]) -> MyMap[PI, MySet[MT]]:
    return convert_1to2[MT, PI](pi_table2)


fn create_prime_implicant_table[
    PI: DType, MT: DType
](prime_implicants: MySet[PI], minterms: MySet[MT],) -> MyMap[PI, MySet[MT]]:
    alias DK_OFFSET: Int = get_dk_offset[PI]()
    alias DATA_MASK: SIMD[PI, 1] = get_dk_mask[PI]()
    var results = MyMap[PI, MySet[MT]]()

    for i in range(len(prime_implicants)):
        let pi: SIMD[PI, 1] = prime_implicants.data[i]
        let dont_know: SIMD[PI, 1] = (pi >> DK_OFFSET)
        let q: SIMD[PI, 1] = (DATA_MASK & pi) | dont_know
        # print("pi = " + minterm_to_string[PI, PrintType.BIN_VERBOSE](pi, 4) + "; dont_know=" + int_to_bin_string(dont_know, 4) +"; q = " + int_to_bin_string(q, 8))
        var set = MySet[MT]()
        for j in range(len(minterms)):
            let mt: SIMD[MT, 1] = minterms.data[j]
            # print("mt = " + minterm_to_string[MT, PrintType.BIN_VERBOSE](mt, 4))
            if (mt.cast[PI]() | dont_know) == q:
                # print("INFO: e03f53aa: create_prime_implicant_table: inserting mt " + minterm_to_string[MT, PrintType.BIN_VERBOSE](mt, 4) +"; " + int_to_bin_string(mt, 8))
                set.add(mt)
        results.add(pi, set ^)
    return results


fn identify_primary_essential_pi2[
    PI: DType, MT: DType
](pi_table2: MyMap[MT, MySet[PI]]) -> TmpStruct1[PI, MT]:
    # find distinguished row and selected primary essential implicants
    var selected_pi = MySet[PI]()

    for i in range(len(pi_table2)):
        let pi_set: MySet[PI] = pi_table2.values[i]
        if len(pi_set) == 1:  # we found a distinguished row / minterm mt
            selected_pi.add(pi_set.data[0])

    var mt_to_be_deleted = DynamicVector[SIMD[MT, 1]]()
    for i in range(len(pi_table2)):
        let mt: SIMD[MT, 1] = pi_table2.keys[i]
        let pi_set: MySet[PI] = pi_table2.values[i]
        for j in range(len(selected_pi)):
            let pi: SIMD[PI, 1] = selected_pi.data[j]
            if pi_set.contains(pi):
                mt_to_be_deleted.push_back(mt)
                break

    var result = TmpStruct1[PI, MT]()
    result.pi_table2 = pi_table2

    for i in range(len(mt_to_be_deleted)):
        result.pi_table2.remove(mt_to_be_deleted[i])

    for i in range(len(selected_pi)):
        result.essential_pi.push_back(selected_pi.data[i])

    return result ^


fn subset[T: DType](sub_set: MySet[T], super_set: MySet[T]) -> Bool:
    for i in range(len(sub_set)):
        if not super_set.contains(sub_set.data[i]):
            return False
    return True


# Given two rows a and b in a reduced prime implicant table, a is said to dominate b, if a
# has checks in all the columns in which b has checks and a and b are not interchangeable.
# Two identical rows (columns) a and b of a reduced prime table are said to be interchangeable.
fn row_dominance[
    PI: DType, MT: DType
](pi_table2: MyMap[MT, MySet[PI]]) -> MyMap[MT, MySet[PI]]:
    var mt_to_be_deleted = MySet[MT]()
    for i in range(len(pi_table2)):
        let mt1 = pi_table2.keys[i]
        if not mt_to_be_deleted.contains(mt1):
            let pi_set1 = pi_table2.values[i]
            for j in range(len(pi_table2)):
                let mt2 = pi_table2.keys[j]
                if mt1 != mt2:
                    let pi_set2 = pi_table2.values[j]
                    if subset(pi_set1, pi_set2):
                        mt_to_be_deleted.add(mt2)
    var pi_table1_out = pi_table2
    for i in range(len(mt_to_be_deleted)):
        pi_table1_out.remove(mt_to_be_deleted.data[i])
    return pi_table1_out


# Given two columns a and b in a reduced prime implicant table, a is said to dominate b, if
# a has checks in all the rows in which b has checks and a and b are not interchangeable.
# Two identical rows (columns) a and b of a reduced prime table are said to be interchangeable.
# eg prime implicant table:
#                 00X1 0X01 101X X011
# 1        = 0001 |XX..
# 3        = 0011 |X..X
# 11       = 1011 |..XX
#
# cam be reduced based on column dominance to prime implicant table:
#                  00X1 X011
# 1        = 0001 |X.
# 3        = 0011 |XX
# 11       = 1011 |.X
#
# column 00X1 dominates column 0X01, thus column 0X01 can be removed, and X011 dominates 101X,
# thus 101X can be removed.
fn column_dominance[
    PI: DType, MT: DType
](pi_table2: MyMap[MT, MySet[PI]]) -> MyMap[MT, MySet[PI]]:
    let pi_table1: MyMap[PI, MySet[MT]] = convert_2to1[PI, MT](pi_table2)
    let all_pi: DynamicVector[SIMD[PI, 1]] = pi_table1.keys
    var pi_to_be_deleted = MySet[PI]()

    for i in range(len(all_pi)):
        let pi1: SIMD[PI, 1] = all_pi[i]
        let mt_set1: MySet[MT] = pi_table1.get(pi1)
        for j in range(i + 1, len(all_pi)):
            let pi2 = all_pi[j]
            let mt_set2: MySet[MT] = pi_table1.get(pi2)
            let q1: Bool = subset(mt_set1, mt_set2)
            let q2: Bool = subset(mt_set2, mt_set1)
            if q1 and q2:
                pass
            elif q1:
                # if pi1 dominates pi2, then remove pi2
                pi_to_be_deleted.add(pi1)
            elif q2:
                pi_to_be_deleted.add(pi2)

    var result = pi_table2
    for i in range(len(result)):
        result.values[i].remove(pi_to_be_deleted)
    return result


fn petricks_method[
    PI: DType, MT: DType, N_BITS: Int, SHOW_INFO: Bool
](pi_table2: MyMap[MT, MySet[PI]],) -> DynamicVector[DynamicVector[SIMD[PI, 1]]]:
    alias VT = DType.uint32  # variable Type

    # create translation to translate the pi table to a cnf
    var translation1 = MyMap[PI, SIMD[VT, 1]]()
    var translation2 = MyMap[VT, SIMD[PI, 1]]()
    var variable_id: SIMD[VT, 1] = 0

    for i in range(len(pi_table2)):
        let mt: SIMD[MT, 1] = pi_table2.keys[i]
        let pi_set: MySet[PI] = pi_table2.values[i]
        for j in range(len(pi_set)):
            let pi: SIMD[PI, 1] = pi_set.data[j]
            if not translation1.contains(pi):
                translation1.add(pi, variable_id)
                translation2.add(variable_id, pi)
                variable_id += 1

    # give an error if we have too many variables
    let n_variables = variable_id
    if n_variables > 64:
        print("ERROR: too many variables (" + str(n_variables) + ") for cnf_to_dnf")

    # convert pi table to cnf
    alias Q = DType.uint64
    var cnf = DynamicVector[SIMD[Q, 1]]()
    for i in range(len(pi_table2)):
        let mt: SIMD[MT, 1] = pi_table2.keys[i]
        let pi_set: MySet[PI] = pi_table2.values[i]
        var disjunction: SIMD[Q, 1] = 0
        for j in range(len(pi_set)):
            let pi: SIMD[PI, 1] = pi_set.data[j]
            let mt: SIMD[VT, 1] = translation1.get(pi)
            disjunction |= 1 << mt.cast[Q]()
        cnf.push_back(disjunction)

    # convert cnf to dnf
    @parameter
    if SHOW_INFO:
        print("INFO: dee2adb6: CNF = " + cnf_to_string[Q](cnf))

    alias EARLY_PRUNE = True
    let smallest_conjunctions = convert_cnf_to_dnf_minimal[
        Q, EARLY_PRUNE=EARLY_PRUNE, SHOW_INFO=SHOW_INFO
    ](cnf, n_variables.to_int())

    @parameter
    if SHOW_INFO:
        print("INFO: 756c1db8: DNF = " + dnf_to_string[Q](smallest_conjunctions))

    # translate the smallest conjunctions back
    var result = DynamicVector[DynamicVector[SIMD[PI, 1]]]()
    for i in range(len(smallest_conjunctions)):
        let conj: SIMD[Q, 1] = smallest_conjunctions[i]
        var x = DynamicVector[SIMD[PI, 1]]()
        for j in range(Q.sizeof() * 8):
            if tools.get_bit[Q](conj, j):
                let key: SIMD[VT, 1] = SIMD[VT, 1](j)
                let pi: SIMD[PI, 1] = translation2.get(key)
                x.push_back(pi)
        result.push_back(x)
    return result


struct TmpStruct1[PI: DType, MT: DType]:
    var pi_table2: MyMap[MT, MySet[PI]]
    var essential_pi: DynamicVector[SIMD[PI, 1]]

    @always_inline("nodebug")
    fn __init__(inout self):
        self.pi_table2 = MyMap[MT, MySet[PI]]()
        self.essential_pi = DynamicVector[SIMD[PI, 1]]()

    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.pi_table2 = existing.pi_table2 ^
        self.essential_pi = existing.essential_pi ^


fn to_string_pi_table1[
    N_BITS: Int, PI: DType, MT: DType
](pi_table1: MyMap[PI, MySet[MT]]) -> String:
    var all_mt_set = MySet[MT]()
    for i in range(len(pi_table1)):
        all_mt_set.add(pi_table1.values[i])

    var all_mt = all_mt_set.data
    sort[MT](all_mt)

    var result: String = "\t"
    for i in range(len(pi_table1)):
        let pi = pi_table1.keys[i]
        result += minterm_to_string[PI, PrintType.BIN](pi, N_BITS) + " "
    result += "\n"

    for i in range(len(all_mt)):
        let mt = all_mt[i]
        var covered_by_prime_implicants = 0
        var tmp: String = ""
        for j in range(len(pi_table1)):
            let mt_set = pi_table1.values[j]
            if mt_set.contains(mt):
                tmp += "X"
                covered_by_prime_implicants += 1
            else:
                tmp += "."
        result += minterm_to_string[MT, PrintType.BIN](mt, N_BITS)
        if covered_by_prime_implicants == 1:
            result += "*"  # found a distinguished row
        result += "\t|" + tmp + "\n"
    return result


fn to_string_pi_table2[
    N_BITS: Int, PI: DType, MT: DType
](pi_table2: MyMap[MT, MySet[PI]]) -> String:
    if len(pi_table2) == 0:
        return "EMPTY\n"

    var all_pi_set = MySet[PI]()
    var all_mt = DynamicVector[SIMD[MT, 1]]()
    for i in range(len(pi_table2)):
        all_mt.push_back(pi_table2.keys[i])
        all_pi_set.add(pi_table2.values[i])

    var all_pi = all_pi_set.data
    sort[PI](all_pi)
    sort[MT](all_mt)

    var result: String = "\t\t "
    for i in range(len(all_pi)):
        result += minterm_to_string[PI, PrintType.BIN](all_pi[i], N_BITS) + " "
    result += "\n"

    for i in range(len(all_mt)):
        let mt = all_mt[i]
        let pi_set = pi_table2.get(mt)
        result += (
            str(mt) + "\t = " + minterm_to_string[MT, PrintType.BIN](mt, N_BITS) + "\t|"
        )

        for j in range(len(all_pi)):
            if pi_set.contains(all_pi[j]):
                result += "X"
            else:
                result += "."
        result += "\n"
    return result


fn print_pi_table1_raw[
    PI: DType, MT: DType, N_BITS: Int
](pi_table1: MyMap[PI, MySet[MT]]):
    for i in range(len(pi_table1)):
        let pi = pi_table1.keys[i]
        let mt_set = pi_table1.values[i]
        print_no_newline(minterm_to_string[PI, PrintType.BIN](pi, N_BITS) + " -> ")
        for j in range(len(mt_set)):
            print_no_newline(
                minterm_to_string[MT, PrintType.BIN](mt_set.data[j], N_BITS) + " "
            )
        print("")


fn petrick_simplify[
    PI: DType, MT: DType, N_BITS: Int, SHOW_INFO: Bool = True
](prime_implicants: MySet[PI], minterms: MySet[MT]) -> MySet[PI]:
    # 1] create prime implicant table
    let pi_table1: MyMap[PI, MySet[MT]] = create_prime_implicant_table[PI, MT](
        prime_implicants, minterms
    )
    # print_pi_table1_raw[PI, MT, N_BITS](pi_table1)

    @parameter
    if SHOW_INFO:
        print("1] created PI table:")
        print(to_string_pi_table1[N_BITS, PI, MT](pi_table1))

    # 2] identify primary essential prime implicants
    let primary: TmpStruct1[PI, MT] = identify_primary_essential_pi2[PI, MT](
        convert_1to2[PI, MT](pi_table1)
    )
    # print_pi_table1_raw[MT, PI, N_BITS](primary.pi_table2)

    @parameter
    if SHOW_INFO:
        print("2] identified primary essential PIs:")
        print(to_string_pi_table2[N_BITS, PI, MT](primary.pi_table2))

    # print_pi_table1_raw[MT, PI, N_BITS](primary.pi_table2)
    let pi_table3: MyMap[MT, MySet[PI]] = row_dominance[PI, MT](primary.pi_table2)

    @parameter
    if SHOW_INFO:
        print("3] reduced based on row dominance:")
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table3))

    let pi_table4: MyMap[MT, MySet[PI]] = column_dominance[PI, MT](pi_table3)

    @parameter
    if SHOW_INFO:
        print("4] reduced based on column dominance:")
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table4))

    # identify secondary essential prime implicants
    let secondary: TmpStruct1[PI, MT] = identify_primary_essential_pi2[PI, MT](
        pi_table4
    )

    @parameter
    if SHOW_INFO:
        print("5] identified secondary essential PIs:")
        print(to_string_pi_table2[N_BITS, PI, MT](secondary.pi_table2))

    let pi_table6: MyMap[MT, MySet[PI]] = row_dominance[PI, MT](secondary.pi_table2)

    @parameter
    if SHOW_INFO:
        print("6] reduced based on row dominance:")
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table6))

    let pi_table7: MyMap[MT, MySet[PI]] = column_dominance[PI, MT](pi_table6)

    @parameter
    if SHOW_INFO:
        print("7] reduced based on column dominance:")
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table7))

    var essential_pi = MySet[PI]()

    if len(pi_table7) > 0:
        # remaining problem is a cyclic covering problem: use petricks method to find minimal solutions
        let pi_vector_petricks: DynamicVector[
            DynamicVector[SIMD[PI, 1]]
        ] = petricks_method[PI, MT, N_BITS, SHOW_INFO](pi_table7)
        # take the first from Petricks method, but it could be that alternatives can yield better machine instructions...
        if len(pi_vector_petricks) > 0:
            let x = pi_vector_petricks[0]
            for i in range(x.size):
                essential_pi.add[False](x[i])

            @parameter
            if SHOW_INFO:
                print(
                    "8] reduce with Petricks method: number essential PIs = "
                    + str(len(essential_pi))
                )
                for i in range(len(pi_vector_petricks)):
                    print(
                        "Petricks yield: "
                        + minterms_to_string[PI](pi_vector_petricks[i], N_BITS)
                    )

        else:
            var pi_set = MySet[PI]()
            for i in range(len(pi_table7)):
                pi_set.add[False](pi_table7.values[i])
            for i in range(len(pi_set)):
                essential_pi.add[False](pi_set.data[i])

    for i in range(len(primary.essential_pi)):
        essential_pi.add[False](primary.essential_pi[i])

        @parameter
        if SHOW_INFO:
            print(
                "INFO: b650c460: adding primary essential PI to result: "
                + minterm_to_string[PI](primary.essential_pi[i], N_BITS)
            )

    for i in range(len(secondary.essential_pi)):
        essential_pi.add[False](secondary.essential_pi[i])

        @parameter
        if SHOW_INFO:
            print(
                "INFO: e2c83d65: adding secondary essential PI to result: "
                + minterm_to_string[PI](secondary.essential_pi[i], N_BITS)
            )

    return essential_pi ^
