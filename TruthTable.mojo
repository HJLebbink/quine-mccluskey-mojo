from collections.vector import DynamicVector
from algorithm.sort import sort

from quine_mccluskey import reduce_qm
from MintermSet import MintermSet
from tools import get_bit, get_minterm_type
from to_string import PrintType, minterms_to_string


struct TruthTable[bit_width: Int, has_unknown: Bool = True](Stringable):
    alias MinTermType: DType = get_minterm_type[bit_width]()

    var data: DynamicVector[SIMD[Self.MinTermType, 1]]
    var is_sorted: Bool
    var is_minimized: Bool

    # initialize truth table with with every row false
    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = DynamicVector[SIMD[Self.MinTermType, 1]]()
        self.is_sorted = True
        self.is_minimized = True

    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data
        self.is_sorted = existing.is_sorted
        self.is_minimized = existing.is_minimized

    @always_inline("nodebug")
    fn set_true(inout self, value: Int):
        alias max_value: Int = 1 << bit_width
        if value < max_value:
            self.data.push_back(SIMD[Self.MinTermType, 1](value))
            self.is_sorted = False
            self.is_minimized = False

    @always_inline("nodebug")
    fn get_value(self, idx: Int) -> Int:
        @parameter
        if bit_width <= 8:
            return (self.data[idx] & 0xFF).to_int()
        elif bit_width <= 16:
            return (self.data[idx] & 0xFFFF).to_int()
        elif bit_width <= 32:
            return (self.data[idx] & 0xFFFF_FFFF).to_int()
        else:
            print("Not implemented yet")
        return 0

    @always_inline("nodebug")
    fn get_unknown(self, idx: Int) -> Int:
        @parameter
        if bit_width == 8:
            return (self.data[idx] >> 8).to_int()
        elif bit_width == 16:
            return (self.data[idx] >> 16).to_int()
        elif bit_width == 32:
            return (self.data[idx] >> 32).to_int()
        else:
            print("Not implemented yet")
        return 0

    fn sort(inout self):
        if self.is_sorted:
            return
        else:
            sort[Self.MinTermType](self.data)
            self.is_sorted = True

    fn minimize(inout self):
        if self.is_minimized:
            return
        else:
            self.sort()
            self.data = reduce_qm[bit_width, Self.MinTermType](self.data)
            self.is_minimized = True

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        let result: String =
            "is_sorted = " + str(self.is_sorted) +
            "; is_minimized = " + str(self.is_minimized) + "; data = \n"
        return result + self.to_string[PrintType.VERBOSE]()

    fn to_string[P: PrintType](self) -> String:
        return minterms_to_string[Self.MinTermType, P, 100](self.data, bit_width)

    fn print_blif(self) -> String:
        return "TODO"
