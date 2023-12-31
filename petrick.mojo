from MintermSet import MintermSet
from MyMap import MyMap, MySet
from cnf_to_dnf import convert_cnf_to_dnf_minimal, convert_cnf_to_dnf
from tools import get_bit, get_dk_offset, get_dk_mask
from to_string import PrintType, minterm_to_string, minterms_to_string, int_to_bin_string, cnf_to_string, dnf_to_string

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
            let x = pi_table1.keys[j]
            let set = pi_table1.values[j]
            if set.contains(mt):
                set2.add(x)
        pi_table2.add(mt, set2 ^)
    return pi_table2^

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
    alias DK_OFFSET: Int = get_dk_offset[PI]()
    alias DATA_MASK: SIMD[PI, 1] = get_dk_mask[PI]()
    var results = MyMap[PI, MySet[MT]]()

    for i in range(len(prime_implicants)):
        let pi: SIMD[PI, 1] = prime_implicants[i]
        let dont_know: SIMD[PI, 1] = (pi >> DK_OFFSET)
        let q: SIMD[PI, 1] = (DATA_MASK & pi) | dont_know
        #print("pi = " + minterm_to_string[PI, PrintType.BIN_VERBOSE](pi, 4) + "; dont_know=" + int_to_bin_string(dont_know, 4) +"; q = " + int_to_bin_string(q, 8))
        var set = MySet[MT]()
        for j in range(len(minterms)):
            let mt: SIMD[MT, 1] = minterms[j]
            #print("mt = " + minterm_to_string[MT, PrintType.BIN_VERBOSE](mt, 4))
            if (mt.cast[PI]() | dont_know) == q:
                #print("INFO: e03f53aa: create_prime_implicant_table: inserting mt " + minterm_to_string[MT, PrintType.BIN_VERBOSE](mt, 4) +"; " + int_to_bin_string(mt, 8)) 
                set.add(mt)
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


#    [[nodiscard]] inline PI_table_2 row_dominance(const PI_table_2& pi_table2) {
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
                if (mt1 != mt2) & subset(pi_set1, pi_set2):
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
fn petricks_method[PI: DType, MT: DType, N_BITS: Int, SHOW_INFO: Bool](
    pi_table2: MyMap[MT, MySet[PI]],
) -> DynamicVector[DynamicVector[SIMD[PI, 1]]]:
    alias VT = DType.uint32 # variable Type

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
    let smallest_conjunctions = convert_cnf_to_dnf_minimal[Q, EARLY_PRUNE=EARLY_PRUNE, SHOW_INFO=SHOW_INFO](cnf, n_variables.to_int())

    @parameter
    if SHOW_INFO:
        print("INFO: 756c1db8: DNF = " + dnf_to_string[Q](smallest_conjunctions))

    # translate the smallest conjunctions back
    var result = DynamicVector[DynamicVector[SIMD[PI, 1]]]()
    for i in range(len(smallest_conjunctions)):
        let conj: SIMD[Q, 1] = smallest_conjunctions[i]
        var x = DynamicVector[SIMD[PI, 1]]()
        for j in range(Q.sizeof()*8):
            if tools.get_bit[Q](conj, j):
                let key: SIMD[VT, 1] = SIMD[VT, 1](j)
                let pi: SIMD[PI, 1] = translation2.get(key)
                x.push_back(pi)
        result.push_back(x)
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

fn to_string_pi_table1[N_BITS: Int, PI: DType, MT: DType](pi_table1: MyMap[PI, MySet[MT]]) -> String:
    var all_minterms = MySet[MT]()
    for i in range(len(pi_table1)):
        all_minterms.add(pi_table1.values[i])

    var result: String = "\t"
    for i in range(len(pi_table1)):
        let pi = pi_table1.keys[i]
        result += minterm_to_string[PI, PrintType.BIN](pi, N_BITS) + " "
    result += "\n"

    for i in range(len(all_minterms)):
        let mt = all_minterms.data[i]
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
            result += "*" # found a distinguished row
        result += "\t|" + tmp + "\n"
    return result


fn to_string_pi_table2[N_BITS: Int, PI: DType, MT: DType](pi_table2: MyMap[MT, MySet[PI]]) -> String:
    if len(pi_table2) == 0:
        return "EMPTY"

    var all_pi = MySet[PI]()
    for i in range(len(pi_table2)):
        all_pi.add(pi_table2.values[i])

    var result: String = "\t"
    for i in range(len(all_pi)):
        let pi: SIMD[PI, 1] = all_pi.data[i]
        result += minterm_to_string[PI, PrintType.BIN](pi, N_BITS) + " "
    result += "\n"

    for i in range(len(pi_table2)):
        let mt: SIMD[MT, 1] = pi_table2.keys[i]
        let pi_set = pi_table2.values[i]

        result += minterm_to_string[MT, PrintType.BIN](mt, N_BITS) + "\t|"
        for j in range(len(all_pi)):
            let pi: SIMD[PI, 1] = all_pi.data[j]
            if pi_set.contains(pi):
                result += "X"
            else:
                result += "."
        result += "\n"
    return result


fn print_pi_table1_raw[PI: DType, MT: DType, N_BITS: Int](pi_table1: MyMap[PI, MySet[MT]]):
    for i in range(len(pi_table1)):
        let pi = pi_table1.keys[i]
        let mt_set = pi_table1.values[i]
        print_no_newline(minterm_to_string[PI, PrintType.BIN](pi, N_BITS) + " -> ")
        for j in range(len(mt_set)):
            print_no_newline(minterm_to_string[MT, PrintType.BIN](mt_set.data[j], N_BITS) + " ")
        print("")


fn petrick_simplify[
   PI: DType, MT: DType, N_BITS: Int, SHOW_INFO: Bool = True
](
    prime_implicants: DynamicVector[SIMD[PI, 1]],
    minterms: DynamicVector[SIMD[MT, 1]],
) -> DynamicVector[SIMD[PI, 1]]:

    # 1] create prime implicant table
    let pi_table1: MyMap[PI, MySet[MT]] = create_prime_implicant_table[PI, MT](prime_implicants, minterms)
    #print_pi_table1_raw[PI, MT, N_BITS](pi_table1)

    @parameter
    if SHOW_INFO:
        print("1] created PI table: number of PIs = " + str(len(pi_table1)))
        print(to_string_pi_table1[N_BITS, PI, MT](pi_table1))

    # 2] identify primary essential prime implicants
    let primary: TmpStruct1[PI, MT] = identify_primary_essential_pi2[PI, MT](convert_1to2[PI, MT](pi_table1))
    #print_pi_table1_raw[MT, PI, N_BITS](primary.pi_table2)

    @parameter
    if SHOW_INFO:
        print("2] identified primary essential PIs: number of essential PIs = " + str(len(primary.essential_pi)) + "; number of remaining PIs = " + str(len(primary.pi_table2)))
        #//if constexpr (SHOW_INFO) std::cout << "Primary essential pi: " << minterms_to_string(pi_width, primary_essential_pi) << std::endl;
        print(to_string_pi_table2[N_BITS, PI, MT](primary.pi_table2))


    #print_pi_table1_raw[MT, PI, N_BITS](primary.pi_table2)
    let pi_table3: MyMap[MT, MySet[PI]] = row_dominance[PI, MT](primary.pi_table2)
    @parameter
    if SHOW_INFO:
        print("3] reduced based on row dominance: number of PIs remaining = " + str(len(pi_table3)))
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table3))

    let pi_table4: MyMap[MT, MySet[PI]] = column_dominance[PI, MT](pi_table3)
    @parameter
    if SHOW_INFO:
        print("4] reduced based on column dominance: number of PIs remaining = " + str(len(pi_table4)))
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table4))

    # identify secondary essential prime implicants
    #        const auto [pi_table5, secondary_essential_pi] = identify_primary_essential_pi2(pi_table4);
    let secondary: TmpStruct1[PI, MT] = identify_primary_essential_pi2[PI, MT](pi_table4)
    @parameter
    if SHOW_INFO:
        print("5] identified secondary essential PIs: number of essential PIs " + str(len(secondary.essential_pi)) + "; number of PIs remaining = " + str(len(secondary.pi_table2)))
    #        //if constexpr (!QUIET) std::cout << "Secondary essential pi: " << prime_implicant_to_string(secondary_essential_pi_b, n_variables, names) << std::endl;
        print(to_string_pi_table2[N_BITS, PI, MT](secondary.pi_table2))

    let pi_table6: MyMap[MT, MySet[PI]] = row_dominance[PI, MT](secondary.pi_table2)
    @parameter
    if SHOW_INFO:
        print("6] reduced based on row dominance: number of PIs remaining = " + str(len(pi_table6)))
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table6))

    let pi_table7: MyMap[MT, MySet[PI]] = column_dominance[PI, MT](pi_table6)
    @parameter
    if SHOW_INFO:
        print("7] reduced based on column dominance: number of PIs remaining = " + str(len(pi_table7)))
        print(to_string_pi_table2[N_BITS, PI, MT](pi_table7))

    var essential_pi = DynamicVector[SIMD[PI, 1]]()

    if len(pi_table7) > 0:
        # remaining problem is a cyclic covering problem: use petricks method to find minimal solutions
        #        const std::vector<std::vector<PI>> pi_vector_petricks = petricks_method(pi_table7);
        #        // take the first from Petricks method
        #        if (!pi_vector_petricks.empty()) {
        #            for (const PI& pi : pi_vector_petricks[0]) {
        #                essential_pi.push_back(pi);
        #            }
        #        }
        let pi_vector_petricks: DynamicVector[DynamicVector[SIMD[PI, 1]]] = petricks_method[PI, MT, N_BITS, SHOW_INFO](pi_table7)
        # take the first from Petricks method
        if len(pi_vector_petricks) > 0:
            let x = pi_vector_petricks[0]
            for i in range(x.size):
                essential_pi.push_back(x[i])

            @parameter
            if SHOW_INFO:
                print("8] reduce with Petricks method: number essential PIs = " + str(len(essential_pi)))
                for i in range(len(pi_vector_petricks)):
                    print("Petricks yield: " + minterms_to_string[PI](pi_vector_petricks[i], N_BITS))

        else:
            var pi_set = MySet[PI]()
            for i in range(len(pi_table7)):
                pi_set.add(pi_table7.values[i])
            for i in range(len(pi_set)):
                essential_pi.push_back(pi_set.data[i])

    for i in range(len(primary.essential_pi)):
        essential_pi.push_back(primary.essential_pi[i])
        @parameter
        if SHOW_INFO:
            print("INFO: b650c460: adding primary essential PI to result: " + minterm_to_string[PI](primary.essential_pi[i], N_BITS))

    for i in range(len(secondary.essential_pi)):
        essential_pi.push_back(secondary.essential_pi[i])
        @parameter
        if SHOW_INFO:
            print("INFO: e2c83d65: adding secondary essential PI to result: " + minterm_to_string[PI](secondary.essential_pi[i], N_BITS))

    let n_variables: Int = len(prime_implicants)

    return essential_pi
