from collections.vector import DynamicVector


struct TruthTable[bit_width: Int](Stringable):
    var data: DynamicVector[MinTerm[bit_width]]
    var is_sorted: Bool
    var is_minimized: Bool

    # initialize truth table with with every row false
    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = DynamicVector[MinTerm[bit_width]]()
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
            self.data.push_back(MinTerm[bit_width](value))
            self.is_sorted = False
            self.is_minimized = False

    fn sort(inout self):
        if self.is_sorted:
            return
        else:
            # TODO
            self.is_sorted = True

    fn minimize(inout self):
        if self.is_minimized:
            return
        else:
            self.sort()
            # TODO
            self.is_minimized = True

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "is_sorted = " + str(
            self.is_sorted
        ) + "; is_minimized = " + str(self.is_minimized) + "; data = \n"
        for i in range(len(self.data)):
            result += str(self.data[i]) + "\n"
        return result


fn getType[n: Int]() -> DType:
    @parameter
    if n <= 1:
        return DType.bool
    elif n <= 8:
        return DType.uint8
    elif n <= 16:
        return DType.uint16
    elif n <= 32:
        return DType.uint32
    elif n <= 64:
        return DType.uint64
    else:
        constrained[False]()
    return DType.uint64


fn get_bit[T: DType](v: SIMD[T, 1], pos: Int) -> Bool:
    return ((v >> pos) & 1) == 1


struct MinTerm[bit_width: Int](CollectionElement, Stringable):
    alias BaseType: DType = getType[bit_width]()
    var value: SIMD[Self.BaseType, 1]
    var unknown: SIMD[Self.BaseType, 1]

    @always_inline("nodebug")
    fn __init__(inout self, value: SIMD[Self.BaseType, 1]):
        self.value = value
        self.unknown = 0

    @always_inline("nodebug")
    fn __init__(inout self, value: Int):
        self.value = value
        self.unknown = 0

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.value = existing.value
        self.unknown = existing.unknown

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.value = existing.value ^
        self.unknown = existing.unknown ^

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = ""
        for i in range(bit_width):
            if get_bit(self.unknown, i):
                result += "X"
            elif get_bit(self.value, i):
                result += "1"
            else:
                result += "0"
        return result
