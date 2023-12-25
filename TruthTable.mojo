from collections.vector import DynamicVector
from algorithm.sort import sort

from quine_mccluskey import reduce_qm
from MintermSet import MintermSet
from tools import get_bit, PrintType

struct TruthTable[bit_width: Int, has_unknown: Bool = True](Stringable):
    alias MinTermType: DType = Self.getMinTermType[bit_width]()

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

    @staticmethod
    fn getMinTermType[n: Int]() -> DType:
        @parameter
        if n <= 4:
            return DType.uint8
        elif n <= 8:
            return DType.uint16
        elif n <= 16:
            return DType.uint32
        elif n <= 32:
            return DType.uint64
        else:
            constrained[False]()
        return DType.uint64

    fn sort(inout self):
        if self.is_sorted:
            return
        else:
            sort[Self.MinTermType](self.data)
            self.is_sorted = True

    fn create_MintermSet(self) -> MintermSet[DType.uint32]:
        var result = MintermSet[DType.uint32]()
        for i in range(len(self.data)):
            result.add(self.get_value(i))
        return result

    fn minimize(inout self):
        if self.is_minimized:
            return
        else:
            self.sort()
            let mts2 = reduce_qm(self.create_MintermSet())
            print(mts2)
            self.is_minimized = True

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        let result: String =
            "is_sorted = " + str(self.is_sorted) +
            "; is_minimized = " + str(self.is_minimized) + "; data = \n"
        return result + self.to_string[PrintType.BIN]()

    fn to_string[t: PrintType](self) -> String:
        var result: String = ""
        @parameter
        if t == PrintType.BIN:
            for i in range(len(self.data)):
                let v = self.data[i]
                for j in range(bit_width):
                    let pos = (bit_width - j)-1
                    if tools.get_bit(v, pos + bit_width):
                        result += "X"
                    elif tools.get_bit(v, pos):
                        result += "1"
                    else:
                        result += "0"
                result += "\n"
        else: 
            result+= "Not implemented yet" #TODO

        return result


    fn print_blif(self) -> String:
        return "TODO"
