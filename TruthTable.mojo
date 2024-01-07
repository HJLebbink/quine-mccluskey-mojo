from collections.vector import DynamicVector
from algorithm.sort import sort

from quine_mccluskey import reduce_qm, reduce_qm_classic
from tools import get_bit, set_bit, clear_bit, get_minterm_type
from to_string import PrintType, minterms_to_string, minterm_to_string
from MySet import MySet

struct TruthTable[N_BITS: Int](Stringable):
    alias MinTermType: DType = get_minterm_type[N_BITS]()
    alias MAX_VALUE: Int = 1 << N_BITS

    var data: MySet[Self.MinTermType]
    var is_compressed: Bool
    var is_decompressed: Bool

    # initialize truth table with with every row false
    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = MySet[Self.MinTermType]()
        self.is_compressed = True
        self.is_decompressed = True

    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.data = existing.data
        self.is_compressed = existing.is_compressed
        self.is_decompressed = existing.is_decompressed

    @always_inline("nodebug")
    fn set_true(inout self, value: Int):
        if value < Self.MAX_VALUE:
            self.data.add(SIMD[Self.MinTermType, 1](value))
            self.is_compressed = False
            # NOTE: no need to update is_decompressed since only values without unknowns can be added

    @always_inline("nodebug")
    fn get_value(self, idx: Int) -> Int:
        @parameter
        if N_BITS <= 4:
            return (self.data.data[idx].__and__(0xF)).to_int()
        if N_BITS <= 8:
            return (self.data.data[idx].__and__(0xFF)).to_int()
        elif N_BITS <= 16:
            return (self.data.data[idx].__and__(0xFFFF)).to_int()
        elif N_BITS <= 32:
            return (self.data.data[idx].__and__(0xFFFF_FFFF)).to_int()
        else:
            print("ERROR: 855c5c76: Not implemented yet")
        return 0

    @always_inline("nodebug")
    fn get_unknown(self, idx: Int) -> Int:
        @parameter
        if N_BITS <= 4:
            return (self.data.data[idx] >> 4).to_int()
        elif N_BITS <= 8:
            return (self.data.data[idx] >> 8).to_int()
        elif N_BITS <= 16:
            return (self.data.data[idx] >> 16).to_int()
        elif N_BITS <= 32:
            return (self.data.data[idx] >> 32).to_int()
        else:
            print("ERROR: 61fd61ff: Not implemented yet")
        return 0


    @always_inline("nodebug")
    fn sort(inout self):
        self.data.sort()


    @always_inline("nodebug")
    fn compress[USE_CLASSIC_METHOD: Bool = False, SHOW_INFO: Bool = False](inout self):
        if self.is_compressed:
            return
        self.sort()
        @parameter
        if USE_CLASSIC_METHOD:
            self.data = reduce_qm_classic[Self.MinTermType, N_BITS, SHOW_INFO](self.data)
        else:
            self.data = reduce_qm[Self.MinTermType, N_BITS, SHOW_INFO](self.data)
        self.is_compressed = True
        self.is_decompressed = False
        self.sort()


    @always_inline("nodebug")
    fn decompress[SHOW_INFO: Bool = False](inout self):
        if self.is_decompressed:
            return
        var new_data = MySet[Self.MinTermType]()
        for i in range(len(self.data)):
            Self.flatten(self.get_value(i), self.get_unknown(i), 0, new_data)
        self.data = new_data
        self.is_compressed = False
        self.is_decompressed = True
        self.sort()


    @staticmethod
    fn flatten(value: SIMD[Self.MinTermType, 1], unknown: SIMD[Self.MinTermType, 1], pos: Int, inout r: MySet[Self.MinTermType]):
        if unknown == 0:
            r.add(value)
            return
        for new_pos in range(pos, N_BITS):
            if get_bit(unknown, new_pos):
                let unknown_new = clear_bit(unknown, new_pos)
                Self.flatten(clear_bit(value, new_pos), unknown_new, new_pos+1, r)
                Self.flatten(set_bit(value, new_pos), unknown_new, new_pos+1, r)


    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        return
            "; is_compressed = " + str(self.is_compressed) +
            "; is_decompressed = " + str(self.is_decompressed) + "; data = \n" +
            self.to_string[PrintType.VERBOSE]()

    fn to_string[P: PrintType](self) -> String:
        return minterms_to_string[Self.MinTermType, P, 100](self.data.data, N_BITS)

    fn print_blif(self) -> String:
        return "TODO"
