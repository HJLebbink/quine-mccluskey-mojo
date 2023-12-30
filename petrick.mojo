from MintermSet import MintermSet
from MyMap import MyMap, MySet
from cnf_to_dnf import convert_cnf_to_dnf_minimal
from tools import get_bit, get_dk_offset, get_dk_mask


#alias PI = DType.uint8
#alias MT = DType.uint8

# using PI_table_1 = std::map<PI, std::unordered_set<MT>>;
# using PI_table_2 = std::map<MT, std::unordered_set<PI>>;


# [[nodiscard]] inline PI_table_2 convert(const PI_table_1& pi_table) {
#    std::set<MT> all_minterms;
#    for (const auto& [_, set] : pi_table) {
#        for (const MT& minterm : set) {
#            all_minterms.insert(minterm);
#        }
#    }
#    PI_table_2 result;
#
#    for (const MT& mt : all_minterms) {
#        std::unordered_set<PI> set2;
#        for (const auto& [x, set] : pi_table) {
#            if (set.contains(mt)) {
#                set2.insert(x);
#            }
#        }
#        result.insert_or_assign(mt, std::move(set2));
#    }
#    return result;
fn convert_1to2[PI: DType, MT: DType](pi_table1: MyMap[PI, MySet[MT]]) -> MyMap[MT, MySet[PI]]:
    var all_minterms = MySet[MT]()
    for i in range(len(pi_table1)):
        all_minterms.add(pi_table1.values[i])
    var pi_table2 = MyMap[MT, MySet[PI]]()
    for i in range(len(all_minterms)):
        let mt = all_minterms.data[i]
        var set2 = MySet[PI]()
        for j in range(len(pi_table1)):
            let x = pi_table1.keys[i]
            let set = pi_table1.values[i]
            if set.contains(mt):
                set2.add(x)
        pi_table2.add(mt, set2 ^)
    return pi_table2

fn convert_2to1[PI: DType, MT: DType](pi_table2: MyMap[MT, MySet[PI]]) -> MyMap[PI, MySet[MT]]:
    return convert_1to2[MT, PI](pi_table2)

# [[nodiscard]] inline PI_table_1 create_prime_implicant_table(
#    const std::vector<PI>& prime_implicants,
#    const std::vector<MT>& minterms)
# {
#    constexpr int N_BITS = (MAX_16_BITS) ? 16 : 32;
#    constexpr unsigned int data_mask = 0xFFFF'FFFF;
#    PI_table_1 results;
#
#    for (const PI& pi : prime_implicants) {
#        const MT dontknow = static_cast<MT>(pi >> N_BITS);
#        const MT q = (static_cast<MT>(data_mask) & pi) | dontknow;
#
#        std::unordered_set<MT> set;
#        for (const MT& mt : minterms) {
#            if ((mt | dontknow) == q) {
#                set.insert(mt);
#                //std::cout << "INFO: create_prime_implicant_table: inserting " << std::bitset<32>(mt).to_string() << std::endl;
#            }
#        }
#        results.insert_or_assign(pi, std::move(set));
#    }
#    return results;
fn create_prime_implicant_table[PI: DType, MT: DType](
    prime_implicants: DynamicVector[SIMD[PI, 1]],
    minterms: DynamicVector[SIMD[MT, 1]],
) -> MyMap[PI, MySet[MT]]:
    alias n_bits = get_dk_offset[PI]()
    alias data_mask: SIMD[PI, 1] = get_dk_mask[PI]()

    var results = MyMap[PI, MySet[MT]]()

    for i in range(prime_implicants.size):
        let pi: SIMD[PI, 1] = prime_implicants[i]
        let dontknow: SIMD[PI, 1] = pi >> n_bits
        let q = (data_mask & pi) | dontknow
        var set = MySet[MT]()
        for j in range(minterms.size):
            let mt: SIMD[MT, 1] = minterms[i]
            if (mt.cast[PI]() | dontknow) == q:
                set.add(mt)
                print("INFO: create_prime_implicant_table: inserting mt " + str(mt))
        results.add(pi, set ^)
    return results


#    [[nodiscard]] inline std::tuple<PI_table_2, std::vector<PI>> identify_primary_essential_pi2(const PI_table_2& pi_table)
#    {
#        // find distinguished row and selected primary essential implicants
#        std::unordered_set<MT> selected_pi;
#        for (const auto& [_, pi_set] : pi_table) {
#            if (pi_set.size() == 1) { // we found a distinguished row / minterm mt
#                const PI pi = *pi_set.begin();
#                if (!selected_pi.contains(pi)) {
#                    selected_pi.insert(pi);
#                }
#                else {
#                    // Note: here we have a choice; we found a distinghuished row yet another minterm was selected as essential prime implicant
#                }
#            }
#        }
#        std::vector<MT> mt_to_be_deleted;
#        for (const auto& [mt, pi_set] : pi_table) {
#           for (const PI& pi : selected_pi) {
#                if (pi_set.contains(pi)) {
#                    mt_to_be_deleted.push_back(mt);
#                    break;
#                }
#            }
#        }
#        PI_table_2 pi_table_out = pi_table;
#        for (const MT& mt : mt_to_be_deleted) {
#            pi_table_out.erase(mt);
#        }
#        return std::make_tuple(pi_table_out, std::vector<PI>(selected_pi.begin(), selected_pi.end()));
#    }
fn identify_primary_essential_pi2[PI: DType, MT: DType](pi_table2: MyMap[MT, MySet[PI]]) -> TmpStruct1[PI, MT]:
    # find distinguished row and selected primary essential implicants
    var selected_pi = MySet[PI]()
    for i in range(len(pi_table2)):
        let pi_set: MySet[PI] = pi_table2.values[i]
        if len(pi_set) == 1:  # we found a distinguished row / minterm mt
            selected_pi.add(pi_set.data[0])
        else:
            pass
            # Note: here we have a choice; we found a distinghuished row yet another minterm was selected as essential prime implicant

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

    for i in range(mt_to_be_deleted.size):
        result.pi_table2.remove(mt_to_be_deleted[i])

    return result ^


#    template <class T>
#    [[nodiscard]] bool subset(const std::unordered_set<T>& sub_set, const std::unordered_set<T>& super_set) {
#        for (const T& e : sub_set) {
#            if (!super_set.contains(e)) {
#                return false;
#            }
#        }
#        return true;
#    }
fn subset[T: DType](sub_set: MySet[T], super_set: MySet[T]) -> Bool:
    for i in range(len(sub_set)):
        if not super_set.contains(sub_set.data[i]):
            return False
    return True


#    [[nodiscard]] inline PI_table_2 row_dominance(const PI_table_2& pi_table2)
#    {
#        std::set<MT> mt_to_be_deleted;
#        for (const auto& [mt1, pi_set1] : pi_table2) {
#            if (!mt_to_be_deleted.contains(mt1)) {
#                for (const auto& [mt2, pi_set2] : pi_table2) {
#                    if ((mt1 != mt2) && subset(pi_set1, pi_set2)) {
#                        mt_to_be_deleted.insert(mt2);
#                    }
#                }
#            }
#        }
#        PI_table_2 pi_table_out = pi_table2;
#        for (const MT& mt : mt_to_be_deleted) {
#            pi_table_out.erase(mt);
#        }
#        return pi_table_out;
#    }
fn row_dominance[PI: DType, MT: DType](pi_table2: MyMap[MT, MySet[PI]]) -> MyMap[MT, MySet[PI]]:
    var mt_to_be_deleted = MySet[MT]()
    for i in range(len(pi_table2)):
        let mt1 = pi_table2.keys[i]
        let pi_set1 = pi_table2.values[i]
        if not mt_to_be_deleted.contains(mt1):
            for j in range(len(pi_table2)):
                let mt2 = pi_table2.keys[j]
                let pi_set2 = pi_table2.values[j]
                if mt1 != mt2 & subset(pi_set1, pi_set2):
                    mt_to_be_deleted.add(mt2)
    var pi_table1_out = pi_table2
    for i in range(len(mt_to_be_deleted)):
        pi_table1_out.remove(mt_to_be_deleted.data[i])
    return pi_table1_out


#    [[nodiscard]] inline PI_table_2 column_dominance(const PI_table_2& pi_table2) {
#        const PI_table_1 pi_table1 = convert(pi_table2);
#        std::set<PI> pi_to_be_deleted;
#        for (const auto& [pi1, mt_set1] : pi_table1) {
#            if (!pi_to_be_deleted.contains(pi1)) {
#                for (const auto& [pi2, mt_set2] : pi_table1) {
#                    if ((pi1 != pi2) && subset(mt_set1, mt_set2)) {
#                        pi_to_be_deleted.insert(pi2);
#                    }
#                }
#            }
#        }
#        PI_table_1 pi_table1_out = pi_table1;
#        for (const PI& pi : pi_to_be_deleted) {
#            pi_table1_out.erase(pi);
#        }
#        return convert(pi_table1_out);
#    }

fn column_dominance[PI: DType, MT: DType](pi_table2: MyMap[MT, MySet[PI]]) -> MyMap[MT, MySet[PI]]:
    let pi_table1: MyMap[PI, MySet[MT]] = convert_2to1[PI, MT](pi_table2)
    var pi_to_be_deleted = MySet[PI]()
    for i in range(len(pi_table1)):
        let pi1: SIMD[PI, 1] = pi_table1.keys[i]
        let mt_set1 = pi_table1.values[i]
        if not pi_to_be_deleted.contains(pi1):
            for j in range(len(pi_table1)):
                let pi2: SIMD[PI, 1] = pi_table1.keys[j]
                let mt_set2 = pi_table1.values[j]
                if (pi1 != pi2) & subset(mt_set1, mt_set2):
                    pi_to_be_deleted.add(pi2)
    var pi_table1_out = pi_table1
    for i in range(len(pi_to_be_deleted)):
        pi_table1_out.remove(pi_to_be_deleted.data[i])
    return convert_1to2[PI, MT](pi_table1_out)
    #BUG, the types are reversed, does not matter when PI == MT, but still
    #return convert_1to2[PI, MT](pi_table1_out)


#    [[nodiscard]] inline std::vector<std::vector<PI>> petricks_method(const PI_table_2& pi_table2)
#    {
#        // create translation to translate the pi table to a cnf
#        std::unordered_map<PI, int> translation1;
#        std::unordered_map<int, PI> translation2;
#        int variable_id = 0;

#        for (const auto& [mt, pi_set] : pi_table2) {
#            for (const auto& pi : pi_set) {
#                if (!translation1.contains(pi)) {
#                    translation1.insert({ pi, variable_id });
#                    translation2.insert({ variable_id, pi });
#                    variable_id++;
#                }
#            }
#        }

#        // give an error if we have too many variables
#        const int n_variables = variable_id;
#        if (n_variables > 64) {
#            std::cout << "ERROR: too many variables (" << n_variables << ") for cnf_to_dnf" << std::endl;
#            static_cast<void>(std::getchar());
#            return {};
#        }

#       // convert pi table to cnf
#       using DT = unsigned long long;
#       std::vector<DT> cnf;
#       for (const auto& [mt, pi_set] : pi_table2) {
#           DT disjunction = 0;
#           for (const auto& pi : pi_set) {
#               disjunction |= (1ull << translation1.at(pi));
#           }
#           cnf.push_back(disjunction);
#       }

#       // convert cnf to dnf
#       //std::cout << "CNF = " << cnf::cnf_to_string(cnf) << std::endl;
#       const auto smallest_conjuctions = cnf::convert_cnf_to_dnf_minimal<cnf::OptimizedFor::avx512_64bits>(cnf, n_variables);
#       //std::cout << "DNF = " << cnf::dnf_to_string(dnf) << std::endl;


#       // translate the smallest conjunctions back
#       std::vector<std::vector<PI>> result;
#       for (const DT conj : smallest_conjuctions) {
#           std::vector<PI> x;
#           for (int i = 0; i < 64; ++i) {
#               if (tools::bit::get_bit(conj, i)) {
#                   x.push_back(translation2.at(i));
#               }
#           }
#           result.push_back(std::move(x));
#       }
#       return result;
#   }
fn petricks_method[PI: DType, MT: DType](
    pi_table2: MyMap[MT, MySet[PI]],
) -> DynamicVector[DynamicVector[SIMD[PI, 1]]]:
    # create translation to translate the pi table to a cnf
    alias VariableType = DType.uint32

    var translation1 = MyMap[PI, SIMD[VariableType, 1]]()
    var translation2 = MyMap[VariableType, SIMD[PI, 1]]()
    var variable_id: SIMD[VariableType, 1] = 0

    for i in range(len(pi_table2)):
        let mt = pi_table2.keys[i]
        let pi_set = pi_table2.values[i]
        for j in range(len(pi_set)):
            let pi = pi_set.data[j]
            if not translation1.contains(pi):
                translation1.add(pi, variable_id)
                translation2.add(variable_id, pi)
                variable_id += 1

    # give an error if we have too many variables
    let n_variables = variable_id.to_int()
    if n_variables > 64:
        print("ERROR: too many variables (" + str(n_variables) + ") for cnf_to_dnf")

    # convert pi table to cnf
    let contant: UInt64 = 0  # NOTE to prevent a bug

    alias DT = UInt64
    var cnf = DynamicVector[DT]()
    for i in range(len(pi_table2)):
        let mt = pi_table2.keys[i]
        let pi_set = pi_table2.values[i]
        var disjunction = contant
        for j in range(len(pi_set)):
            let pi = pi_set.data[j]
            disjunction |= 1 << translation1.get(pi).cast[DT.element_type]()
        cnf.push_back(disjunction)

    # convert cnf to dnf
    # print("CNF = " + cnf_to_string(cnf))
    let smallest_conjuctions = convert_cnf_to_dnf_minimal[DT.element_type, True, True](
        cnf, n_variables
    )
    # print("DNF = " + dnf_to_string(dnf))

    # translate the smallest conjunctions back
    var result = DynamicVector[DynamicVector[SIMD[PI, 1]]]()
    for i in range(len(smallest_conjuctions)):
        let conj: DT = smallest_conjuctions[i]
        var x = DynamicVector[SIMD[PI, 1]]()
        for j in range(64):
            if tools.get_bit(conj, j):
                x.push_back(translation2.get(j))
        result.push_back(x ^)

    return result


#    template <typename OC, bool QUIET = false>
#    [[nodiscard]] std::vector<PI> simplify(
#        const std::vector<PI>& prime_implicants,
#        const std::vector<MT>& minterms)
#
#        let n_variables: Int = len(prime_implicants);
#        std::vector<std::string> names;
#        for (int i = 0; i < n_variables; ++i) {
#            names.push_back("v" + std::to_string(i));
#        }

#        // 1] create prime implicant table
#        const PI_table_1 pi_table1 = create_prime_implicant_table(prime_implicants, minterms);
#        if constexpr (!QUIET) std::cout << "1] created prime implicant table: #pi = " << pi_table1.size() << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table1(pi_table1, n_variables, names) << std::endl;

#        // 2] identify primary essential prime implicants
#        const auto [pi_table2, primary_essential_pi] = identify_primary_essential_pi2(convert(pi_table1));
#        if constexpr (!QUIET) std::cout << "2] identified primary essential prime implicants: #essential pi " << primary_essential_pi.size() << "; #pi remaining = " << pi_table2.size() << std::endl;
#        //if constexpr (!QUIET) std::cout << "Primary essential pi: " << prime_implicant_to_string(primary_essential_pi, n_variables, names) << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table2, n_variables, names) << std::endl;

#        const PI_table_2 pi_table3 = row_dominance(pi_table2);
#        if constexpr (!QUIET) std::cout << "3] reduced based on row dominance: #pi remaining = " << pi_table3.size() << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table3, n_variables, names) << std::endl;

#        const PI_table_2 pi_table4 = column_dominance(pi_table3);
#        if constexpr (!QUIET) std::cout << "4] reduced based on column dominance: #pi remaining = " << pi_table4.size() << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table4, n_variables, names) << std::endl;

#        // identify secondary essential prime implicants
#        const auto [pi_table5, secondary_essential_pi] = identify_primary_essential_pi2(pi_table4);
#        if constexpr (!QUIET) std::cout << "5] identified secondary essential prime implicants: #essential pi " << secondary_essential_pi.size() << "; #pi remaining = " << pi_table5.size() << std::endl;
#        //if constexpr (!QUIET) std::cout << "Secondary essential pi: " << prime_implicant_to_string(secondary_essential_pi_b, n_variables, names) << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table5, n_variables, names) << std::endl;

#        const PI_table_2 pi_table6 = row_dominance(pi_table5);
#        if constexpr (!QUIET) std::cout << "6] reduced based on row dominance: #pi remaining = " << pi_table6.size() << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table6, n_variables, names) << std::endl;

#        const PI_table_2 pi_table7 = column_dominance(pi_table6);
#        if constexpr (!QUIET) std::cout << "7] reduced based on column dominance: #pi remaining = " << pi_table7.size() << std::endl;
#        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table7, n_variables, names) << std::endl;

#        std::vector<PI> essential_pi;

#        // remaining problem is a cyclic covering problem: use petricks method to find minimal solutions
#        if constexpr (OC::PETRICK_CNF2DNF) {
#            const std::vector<std::vector<PI>> pi_vector_petricks = petricks_method(pi_table7);
#            // take the first from Petricks method
#            if (!pi_vector_petricks.empty()) {
#                for (const PI& pi : pi_vector_petricks[0]) {
#                    essential_pi.push_back(pi);
#                }
#            }
#        }
#        else {
#            std::set<PI> pi_set;
#            for (const auto& [mt, pi_set2] : pi_table7) {
#                for (const PI& pi : pi_set2) {
#                    pi_set.insert(pi);
#                }
#            }
#            for (const PI& pi : pi_set) {
#                essential_pi.push_back(pi);
#            }
#        }
#
#        if constexpr (!QUIET) std::cout << "8] reduce with Petricks method: #essential pi = " << essential_pi.size() << std::endl;
#        if constexpr (!QUIET) {
#            //for (const std::vector<PI>& vec : pi_vector_petricks) {
#            //    std::cout << "Petricks yield: " << prime_implicant_to_string(vec, n_variables, names) << std::endl;
#            //}
#        }
#
#        for (const PI& pi : primary_essential_pi) {
#            essential_pi.push_back(pi);
#        }
#        for (const PI& pi : secondary_essential_pi) {
#            essential_pi.push_back(pi);
#        }
#        if constexpr (!QUIET) std::cout << "simplify removed " << (n_variables - essential_pi.size()) << " from initially " << n_variables << " prime implicants" << std::endl;
#        return essential_pi;
#    }


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


fn petrick_simplify[
   PI: DType, MT: DType, bit_width: Int, SHOW_INFO: Bool = True
](
    prime_implicants: DynamicVector[SIMD[PI, 1]],
    minterms: DynamicVector[SIMD[MT, 1]],
) -> DynamicVector[SIMD[PI, 1]]:
    let n_variables: Int = len(prime_implicants)
    var names = DynamicVector[String](n_variables)
    for i in range(n_variables):
        names.push_back("v" + str(i))

    # 1] create prime implicant table
    let pi_table1: MyMap[PI, MySet[MT]] = create_prime_implicant_table[PI, MT](prime_implicants, minterms)

    @parameter
    if SHOW_INFO:
        print("1] created prime implicant table: #pi " + str(len(pi_table1)))
        # print(to_string_pi_table1(pi_table1, n_variabes, names))

    # 2] identify primary essential prime implicants
    #        const auto [pi_table2, primary_essential_pi] = identify_primary_essential_pi2(convert(pi_table1));
    var primary: TmpStruct1[PI, MT] = identify_primary_essential_pi2[PI, MT](convert_1to2[PI, MT](pi_table1))

    @parameter
    if SHOW_INFO:
        pass
    #        if constexpr (!QUIET) std::cout << "2] identified primary essential prime implicants: #essential pi " << primary_essential_pi.size() << "; #pi remaining = " << pi_table2.size() << std::endl;
    #        //if constexpr (!QUIET) std::cout << "Primary essential pi: " << prime_implicant_to_string(primary_essential_pi, n_variables, names) << std::endl;
    #        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table2, n_variables, names) << std::endl;

    let pi_table3: MyMap[MT, MySet[PI]] = row_dominance[PI, MT](primary.pi_table2)
    #        if constexpr (!QUIET) std::cout << "3] reduced based on row dominance: #pi remaining = " << pi_table3.size() << std::endl;
    #        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table3, n_variables, names) << std::endl;

    let x = column_dominance[PI, MT](pi_table3)
    let pi_table4: MyMap[MT, MySet[PI]] = x
    #        if constexpr (!QUIET) std::cout << "4] reduced based on column dominance: #pi remaining = " << pi_table4.size() << std::endl;
    #        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table4, n_variables, names) << std::endl;

    # identify secondary essential prime implicants
    #        const auto [pi_table5, secondary_essential_pi] = identify_primary_essential_pi2(pi_table4);
    let secondary: TmpStruct1[PI, MT] = identify_primary_essential_pi2[PI, MT](pi_table4)
    # let secondary_essential_pi = x2.get[1]()
    #        if constexpr (!QUIET) std::cout << "5] identified secondary essential prime implicants: #essential pi " << secondary_essential_pi.size() << "; #pi remaining = " << pi_table5.size() << std::endl;
    #        //if constexpr (!QUIET) std::cout << "Secondary essential pi: " << prime_implicant_to_string(secondary_essential_pi_b, n_variables, names) << std::endl;
    #        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table5, n_variables, names) << std::endl;

    let pi_table6: MyMap[MT, MySet[PI]] = row_dominance[PI, MT](secondary.pi_table2)
    #        if constexpr (!QUIET) std::cout << "6] reduced based on row dominance: #pi remaining = " << pi_table6.size() << std::endl;
    #        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table6, n_variables, names) << std::endl;

    let pi_table7: MyMap[MT, MySet[PI]] = column_dominance[PI, MT](pi_table6)
    #        if constexpr (!QUIET) std::cout << "7] reduced based on column dominance: #pi remaining = " << pi_table7.size() << std::endl;
    #        if constexpr (!QUIET) std::cout << to_string_pi_table2(pi_table7, n_variables, names) << std::endl;

    var essential_pi = DynamicVector[SIMD[PI, 1]]()

    # remaining problem is a cyclic covering problem: use petricks method to find minimal solutions
    #        const std::vector<std::vector<PI>> pi_vector_petricks = petricks_method(pi_table7);
    #        // take the first from Petricks method
    #        if (!pi_vector_petricks.empty()) {
    #            for (const PI& pi : pi_vector_petricks[0]) {
    #                essential_pi.push_back(pi);
    #            }
    #        }
    let pi_vector_petricks = petricks_method[PI, MT](pi_table7)
    # take the first from Petricks method
    if len(pi_vector_petricks) > 0:
        let x = pi_vector_petricks[0]
        for i in range(x.size):
            essential_pi.push_back(x[i])

    for i in range(len(primary.essential_pi)):
        essential_pi.push_back(primary.essential_pi[i])

    for i in range(len(secondary.essential_pi)):
        essential_pi.push_back(secondary.essential_pi[i])

    return essential_pi
