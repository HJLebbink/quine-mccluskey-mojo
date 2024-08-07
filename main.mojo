from time import now

from TruthTable import TruthTable
from cnf_to_dnf import convert_cnf_to_dnf_minimal, convert_cnf_to_dnf
from unit_tests import run_all_unit_tests, test_compress_decompress
from to_string import (
    PrintType,
    cnf_to_string,
    dnf_to_string,
)


fn cnf2dnf_bigtest_1[QUIET: Bool]():
    alias DT = DType.uint32
    alias n_bits = 16
    alias n_conjunctions = 500
    alias n_disjunctions = 8

    var cnf1 = List[Scalar[DT]]()
    for i in range(n_conjunctions):
        var conjunction: Scalar[DT] = 0
        for j in range(n_disjunctions):
            var r = random.random_ui64(0, 0xFFFF_FFFF).cast[DT]() % n_bits
            conjunction |= 1 << r
        cnf1.append(conjunction)

    @parameter
    if not QUIET:
        print("CNF = " + cnf_to_string[DT](cnf1))

    # var dnf1 = convert_cnf_to_dnf[DT, False](cnf1, n_bits)
    var dnf1 = convert_cnf_to_dnf_minimal[DT, True, False](cnf1, n_bits)

    @parameter
    if not QUIET:
        print("DNF = " + dnf_to_string[DT](dnf1))


fn cnf2dnf_bigtest_2[QUIET: Bool]():
    alias DT = DType.uint32
    alias n_bits = 32
    alias n_conjunctions = 20
    alias n_disjunctions = 8

    var cnf1 = List[Scalar[DT]]()
    for i in range(n_conjunctions):
        var conjunction: Scalar[DT] = 0
        for j in range(n_disjunctions):
            var r = random.random_ui64(0, 0xFFFF_FFFF).cast[DT]() % n_bits
            conjunction |= 1 << r
        cnf1.append(conjunction)

    @parameter
    if not QUIET:
        print("CNF = " + cnf_to_string[DT](cnf1))

    alias EARLY_PRUNE = True
    alias SHOW_INFO = False
    var dnf1 = convert_cnf_to_dnf_minimal[DT, EARLY_PRUNE, SHOW_INFO](
        cnf1, n_bits
    )

    @parameter
    if not QUIET:
        print("DNF = " + dnf_to_string[DT](dnf1))


fn cnf2dnf_bigtest_3[QUIET: Bool = False]():
    alias DT = DType.uint64
    alias n_bits = 32
    alias n_conjunctions = 10
    alias n_disjunctions = 8

    var cnf1 = List[Scalar[DT]]()
    for i in range(n_conjunctions):
        var conjunction: Scalar[DT] = 0
        for j in range(n_disjunctions):
            var r = random.random_ui64(0, 0xFFFF_FFFF).cast[DT]() % n_bits
            conjunction |= 1 << r
        cnf1.append(conjunction)

    if not QUIET:
        print("CNF = " + cnf_to_string[DT](cnf1))

    # var dnf1 = convert_cnf_to_dnf[DT, True](cnf1, n_bits)
    var dnf1 = convert_cnf_to_dnf_minimal[DT, True, False](cnf1, n_bits)

    if not QUIET:
        print("DNF = " + dnf_to_string[DT](dnf1))


# found very hard example when generating popcnt_6_3
fn cnf2dnf_bigtest_4[QUIET: Bool = False]():
    alias DT = DType.uint64
    alias n_bits = 64

    var cnf1 = List[Scalar[DT]]()
    cnf1.append(1 << 0 | 1 << 1 | 1 << 2 | 1 << 3)
    cnf1.append(1 << 4 | 1 << 5 | 1 << 6 | 1 << 7)
    cnf1.append(1 << 3 | 1 << 7 | 1 << 11)
    cnf1.append(1 << 8 | 1 << 9 | 1 << 10 | 1 << 11)
    cnf1.append(1 << 12 | 1 << 13 | 1 << 14 | 1 << 15)
    cnf1.append(1 << 2 | 1 << 15 | 1 << 19)
    cnf1.append(1 << 16 | 1 << 17 | 1 << 18 | 1 << 19)
    cnf1.append(1 << 10 | 1 << 18 | 1 << 22)
    cnf1.append(1 << 6 | 1 << 14 | 1 << 23)
    cnf1.append(1 << 20 | 1 << 21 | 1 << 22 | 1 << 23)
    cnf1.append(1 << 24 | 1 << 25 | 1 << 26 | 1 << 27)
    cnf1.append(1 << 1 | 1 << 27 | 1 << 31)
    cnf1.append(1 << 28 | 1 << 29 | 1 << 30 | 1 << 31)
    cnf1.append(1 << 9 | 1 << 30 | 1 << 34)
    cnf1.append(1 << 5 | 1 << 26 | 1 << 35)
    cnf1.append(1 << 32 | 1 << 33 | 1 << 34 | 1 << 35)
    cnf1.append(1 << 21 | 1 << 33 | 1 << 37)
    cnf1.append(1 << 17 | 1 << 29 | 1 << 38)
    cnf1.append(1 << 13 | 1 << 25 | 1 << 39)
    cnf1.append(1 << 36 | 1 << 37 | 1 << 38 | 1 << 39)
    cnf1.append(1 << 40 | 1 << 41 | 1 << 42 | 1 << 43)
    cnf1.append(1 << 0 | 1 << 43 | 1 << 47)
    cnf1.append(1 << 44 | 1 << 45 | 1 << 46 | 1 << 47)
    cnf1.append(1 << 8 | 1 << 46 | 1 << 50)
    cnf1.append(1 << 4 | 1 << 42 | 1 << 51)
    cnf1.append(1 << 48 | 1 << 49 | 1 << 50 | 1 << 51)
    cnf1.append(1 << 20 | 1 << 49 | 1 << 53)
    cnf1.append(1 << 16 | 1 << 45 | 1 << 54)
    cnf1.append(1 << 12 | 1 << 41 | 1 << 55)
    cnf1.append(1 << 52 | 1 << 53 | 1 << 54 | 1 << 55)
    cnf1.append(1 << 36 | 1 << 52 | 1 << 56)
    cnf1.append(1 << 32 | 1 << 48 | 1 << 57)
    cnf1.append(1 << 28 | 1 << 44 | 1 << 58)
    cnf1.append(1 << 24 | 1 << 40 | 1 << 59)
    cnf1.append(1 << 56 | 1 << 57 | 1 << 58 | 1 << 59)

    # CNF = (0 | 1 | 2 | 3) & (4 | 5 | 6 | 7) & (3 | 7 | 11) & (8 | 9 | 10 | 11) & (12 | 13 | 14 | 15) & (2 | 15 | 19) & (16 | 17 | 18 | 19) & (10 | 18 | 22) & (6 | 14 | 23) & (20 | 21 | 22 | 23) & (24 | 25 | 26 | 27) & (1 | 27 | 31) & (28 | 29 | 30 | 31) & (9 | 30 | 34) & (5 | 26 | 35) & (32 | 33 | 34 | 35) & (21 | 33 | 37) & (17 | 29 | 38) & (13 | 25 | 39) & (36 | 37 | 38 | 39) & (40 | 41 | 42 | 43) & (0 | 43 | 47) & (44 | 45 | 46 | 47) & (8 | 46 | 50) & (4 | 42 | 51) & (48 | 49 | 50 | 51) & (20 | 49 | 53) & (16 | 45 | 54) & (12 | 41 | 55) & (52 | 53 | 54 | 55) & (36 | 52 | 56) & (32 | 48 | 57) & (28 | 44 | 58) & (24 | 40 | 59) & (56 | 57 | 58 | 59)

    @parameter
    if not QUIET:
        print("CNF = " + cnf_to_string[DT](cnf1))

    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 2 of 35; result_dnf_next=16; n_pruned=0; n_not_prunned=48; max_size=35; smallest_cnf_size=2
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 3 of 35; result_dnf_next=37; n_pruned=0; n_not_prunned=64; max_size=35; smallest_cnf_size=3
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 4 of 35; result_dnf_next=148; n_pruned=0; n_not_prunned=148; max_size=35; smallest_cnf_size=4
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 5 of 35; result_dnf_next=175; n_pruned=0; n_not_prunned=444; max_size=34; smallest_cnf_size=4
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 6 of 35; result_dnf_next=403; n_pruned=0; n_not_prunned=700; max_size=34; smallest_cnf_size=5
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 7 of 35; result_dnf_next=547; n_pruned=0; n_not_prunned=1209; max_size=33; smallest_cnf_size=5
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 8 of 35; result_dnf_next=707; n_pruned=0; n_not_prunned=1641; max_size=32; smallest_cnf_size=5
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 9 of 35; result_dnf_next=1160; n_pruned=0; n_not_prunned=2828; max_size=32; smallest_cnf_size=6
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 10 of 35; result_dnf_next=4640; n_pruned=0; n_not_prunned=4640; max_size=32; smallest_cnf_size=7
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 11 of 35; result_dnf_next=6140; n_pruned=0; n_not_prunned=13920; max_size=31; smallest_cnf_size=7
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 12 of 35; result_dnf_next=14483; n_pruned=0; n_not_prunned=24560; max_size=31; smallest_cnf_size=8
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 13 of 35; result_dnf_next=21578; n_pruned=0; n_not_prunned=43449; max_size=30; smallest_cnf_size=8
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 14 of 35; result_dnf_next=31135; n_pruned=0; n_not_prunned=64734; max_size=29; smallest_cnf_size=8
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 15 of 35; result_dnf_next=51655; n_pruned=0; n_not_prunned=124540; max_size=29; smallest_cnf_size=9
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 16 of 35; result_dnf_next=84437; n_pruned=0; n_not_prunned=154965; max_size=28; smallest_cnf_size=9
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 17 of 35; result_dnf_next=134781; n_pruned=0; n_not_prunned=253311; max_size=27; smallest_cnf_size=9
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 18 of 35; result_dnf_next=209163; n_pruned=0; n_not_prunned=404343; max_size=27; smallest_cnf_size=10
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 19 of 35; result_dnf_next=272184; n_pruned=0; n_not_prunned=836652; max_size=26; smallest_cnf_size=1INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 20 of 35; result_dnf_next=1088736; n_pruned=0; n_not_prunned=1088736; max_size=26; smallest_cnf_size=11
    # INFO: 5693ff80: convert_cnf_to_dnf_minimal: progress 21 of 35; result_dnf_next=1566900; n_pruned=0; n_not_prunned=3266208; max_size=25; smallest_cnf_size=11

    alias EARLY_PRUNE = True
    alias SHOW_INFO = True
    var dnf1 = convert_cnf_to_dnf_minimal[DT, EARLY_PRUNE, SHOW_INFO](
        cnf1, n_bits
    )

    @parameter
    if not QUIET:
        print("DNF = " + dnf_to_string[DT](dnf1))


fn test_static_compress():
    alias implicants = VariadicList(
        0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
    )  # example needs Petricks method; has no primary essential prime implicants

    alias TT1 = TruthTable[4](implicants, compress=False)
    print("TT1 = " + TT1.pretty_print_blif())

    # static compression fails v0.7.0
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:231:1: note:                     failed to interpret function @$stdlib::$algorithm::$sort::sort[$stdlib::$builtin::$dtype::DType]($stdlib::$collections::$vector::List[$stdlib::$builtin::$simd::SIMD[*(0,0), {1}]]&),_231x9_type=ui8
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:244:15: note:                       failed to evaluate call
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:198:1: note:                         failed to interpret function @$stdlib::$algorithm::$sort::sort[$stdlib::$builtin::$dtype::DType]($stdlib::$memory::$unsafe::Pointer[$stdlib::$builtin::$simd::SIMD[*(0,0), {1}], {{0}}]&,$stdlib::$builtin::$int::Int),_198x9_type=ui8
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:215:47: note:                           failed to evaluate call
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:94:1: note:                             failed to interpret function @$stdlib::$algorithm::$sort::_quicksort[AnyRegType,fn[AnyRegType]($0, $0, /) capturing -> $stdlib::$builtin::$bool::Bool]($stdlib::$memory::$unsafe::Pointer[*(0,0), {{0}}],$stdlib::$builtin::$int::Int),_95x5_type=scalar<ui8>,_95x23_cmp_fn=@"$stdlib::$algorithm::$sort::sort[$stdlib::$builtin::$dtype::DType]($stdlib::$memory::$unsafe::Pointer[$stdlib::$builtin::$simd::SIMD[*(0,0), {1}], {{0}}]&,$stdlib::$builtin::$int::Int)__less_than_equal[AnyRegType]($0,$0)"<:dtype ui8, :type ?>
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:100:60: note:                               failed to evaluate call
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:89:1: note:                                 failed to interpret function @$stdlib::$algorithm::$sort::_estimate_initial_height($stdlib::$builtin::$int::Int)
    # /__w/modular/modular/Kernels/mojo/stdlib/algorithm/sort.mojo:91:51: note:                                   failed to fold operation pop.call_llvm_intrinsic{fastmathFlags: #pop<fmf none>, intrin: "llvm.ctlz" : !kgen.string}(13 : index, #pop<simd false> : !pop.scalar<bool>)
    # mojo: error: failed to run the pass manager

    # alias TT2 = TruthTable[4](implicants, compress=True)
    # print("TT2 = " + TT2.pretty_print_blif())


fn main():
    var start_time_ns = now()

    run_all_unit_tests[QUIET=True]()
    test_compress_decompress(n_tests=2000)  # crash

    # test_static_compress() # crashes if you uncomment the static code...

    # cnf2dnf_bigtest_1[False]() # 2 seconds
    # cnf2dnf_bigtest_2[False]() # 2.6 seconds
    # cnf2dnf_bigtest_3[False]() # 0.006 seconds
    # cnf2dnf_bigtest_4[False]() # impossible large! eons

    # NOTE benchmark was removed from the language
    # benchmark.run[cnf2dnf_bigtest_1[True]]().print()
    # benchmark.run[cnf2dnf_bigtest_2[True]]().print()
    # benchmark.run[cnf2dnf_bigtest_3[True]]().print()

    var elapsed_time_ns = now() - start_time_ns
    print("Elapsed time " + str(elapsed_time_ns) + " ns", end="")
    print(" = " + str(Float32(elapsed_time_ns) / 1_000) + " μs", end="")
    print(" = " + str(Float32(elapsed_time_ns) / 1_000_000) + " ms", end="")
    print(" = " + str(Float32(elapsed_time_ns) / 1_000_000_000) + " s", end="")
    print(" = " + str(Float32(elapsed_time_ns) / 60_000_000_000) + " min")
