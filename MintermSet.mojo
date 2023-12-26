from collections.vector import DynamicVector
from math.bit import ctpop
from algorithm.sort import sort

from tools import get_bit, PrintType, minterms_to_string, minterm_to_string

struct MintermSet[T: DType, bit_width: Int](CollectionElement, Sized, Stringable):
    alias Q = DynamicVector[SIMD[T, 1]]

    var n_elements: Int
    var max_bit_count: Int
    var is_sorted: Bool
    var data: DynamicVector[Self.Q]

    fn __init__(inout self: Self):
        self.n_elements = 0
        self.max_bit_count = 0
        self.is_sorted = True
        self.data = DynamicVector[Self.Q](bit_width)
        for i in range(bit_width):
            self.data.push_back(Self.Q())

    fn __eq__(self: Self, other: Self) -> Bool:
        if not(self.is_sorted) | not(other.is_sorted):
            #print("ERROR MintermSet: equality test: self or other is not sorted")
            return False
        if len(self) != len(other):
            #print("MintermSet eq: returns False (A)")
            return False
        for i in range(bit_width):
            if self.data[i].size != other.data[i].size:
                #print("MintermSet eq: returns False (B)" + str(i))
                return False
        for i in range(bit_width):
            if not(Self.equal(self.data[i], other.data[i])):
                #print("MintermSet eq: returns False (C)" + str(i))
                return False
        #print("MintermSet eq: returns True (D)")
        return True

    @staticmethod
    fn equal(v1: Self.Q, v2: Self.Q) -> Bool:
        for i in range (v1.size):
            if v1[i] != v2[i]:
                return False
        return True

    # trait Sized
    fn __len__(self) -> Int:
        return self.n_elements

    # trait Copyable
    fn __copyinit__(inout self, existing: Self):
        self.n_elements = existing.n_elements
        self.max_bit_count = existing.max_bit_count
        self.is_sorted = existing.is_sorted
        self.data = existing.data

    # trait Movable
    fn __moveinit__(inout self, owned existing: Self):
        self.n_elements = existing.n_elements
        self.max_bit_count = existing.max_bit_count
        self.is_sorted = existing.is_sorted
        self.data = existing.data ^

    # trait Stringable
    fn __str__(self) -> String:
        return self.to_string[PrintType.DEC](bit_width)

    fn to_string[P: PrintType](self, number_vars: Int) -> String:
        var result: String = ""
        for i in range(bit_width):
            result += minterms_to_string[T, P](self.data[i], number_vars)
        return result

    fn sort(inout self):
        if self.is_sorted:
            return
        for i in range(bit_width):
            sort[T](self.data[i])
        self.is_sorted = True

    fn add[check_duplicate: Bool = True](inout self, value: SIMD[T, 1]):
        print("INFO: 7bd7968f: adding value " +str(value) + "=" + minterm_to_string[T, PrintType.BIN](value, 3))
        let n_bits_set = ctpop(value).to_int()
        self.n_elements += 1

        if self.max_bit_count < n_bits_set:
            self.max_bit_count = n_bits_set

        var already_present = False
        if check_duplicate:
            for i in range(self.data[n_bits_set].size):
                if self.data[n_bits_set][i] == value:
                    already_present = True
                    break

        if not already_present:
            self.data[n_bits_set].push_back(value)
            self.is_sorted = False

    fn get(self, n_bits_set: Int) -> Self.Q:
        return self.data[n_bits_set]
