from collections.vector import DynamicVector
from math.bit import ctpop
from algorithm.sort import sort

from tools import get_bit, PrintType

struct MintermSet[T2: DType](CollectionElement, Sized, Stringable):
    alias Q = DynamicVector[SIMD[T2, 1]]
    alias N = 32 # number of bits in a minterm

    var n_elements: Int
    var max_bit_count: Int
    var is_sorted: Bool
    var data : DynamicVector[Self.Q]

    fn __init__(inout self: Self):
        self.n_elements = 0
        self.max_bit_count = 0
        self.is_sorted = True
        self.data = DynamicVector[Self.Q](Self.N)
        for i in range(Self.N):
            self.data.push_back(Self.Q())

    fn __eq__(self: Self, other: Self) -> Bool:
        if not(self.is_sorted) | not(other.is_sorted):
            print("ERROR MintermSet: equality test: self or other is not sorted")
            return False
        if len(self) != len(other):
            print("MintermSet eq: returns False (A)")
            return False
        for i in range(Self.N):
            if self.data[i].size != other.data[i].size:
                print("MintermSet eq: returns False (B)" + str(i))
                return False
        for i in range(Self.N):
            if not(Self.equal(self.data[i], other.data[i])):
                print("MintermSet eq: returns False (C)" + str(i))
                return False
        print("MintermSet eq: returns True (D)")
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
        return self.to_string[PrintType.DEC](Self.N)

    fn to_string[t: PrintType](self, number_vars: Int) -> String:
        var result: String = ""
        for i in range(Self.N):
            let s = self.data[i].size
            for j in range(s):
                let v = self.data[i][j]
                @parameter
                if t == PrintType.BIN:
                    for k in range(number_vars):
                        let pos = (number_vars - k)-1
                        #print("pos "+str(pos))
                        if tools.get_bit(v, pos + Self.N):
                            result += "X"
                        elif tools.get_bit(v, pos):
                            result += "1"
                        else:
                            result += "0"
                else:
                    result += "ERROR"
                result += " "
        return result


    fn sort(inout self):
        if self.is_sorted:
            return
        for i in range(Self.N):
            sort[T2](self.data[i])
        self.is_sorted = True

    fn add(inout self, value: SIMD[T2, 1], check_duplicate: Bool = True):
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
