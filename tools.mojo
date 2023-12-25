

@register_passable("trivial")
struct PrintType(Stringable):
    var value: Int
    alias DEC = PrintType(0)
    alias HEX = PrintType(1)
    alias BIN = PrintType(2)

    fn __eq__(self: Self, other: PrintType) -> Bool:
        return self.value == other.value

    fn __init__(value: Int) -> Self:
        return Self { value: value }

    fn __str__(self) -> String:
        if self == PrintType.DEC: return "DEC"
        elif self == PrintType.HEX: return "HEX"
        elif self == PrintType.BIN: return "BIN"
        else: return "UNKNOWN"


fn get_bit[T: DType](v: SIMD[T, 1], pos: Int) -> Bool:
    return ((v >> pos) & 1) == 1
