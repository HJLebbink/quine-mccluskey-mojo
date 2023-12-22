from collections.vector import DynamicVector
from math.bit import ctpop
from algorithm.sort import sort

struct MintermSet[T2: DType](CollectionElement, Sized, Stringable):
    alias Q = DynamicVector[SIMD[T2, 1]]
    alias N = 32

    var n_elements: Int
    var max_bit_count: Int
    var is_sorted: Bool
    var data : DynamicVector[Self.Q]

    fn __init__(inout self: Self):
        self.n_elements = 0
        self.max_bit_count = 0
        self.is_sorted = True
        self.data = DynamicVector[Self.Q](Self.N)


    fn __eq__(self: Self, other: Self) -> Bool:
        if not(self.is_sorted) | not(other.is_sorted):
            print("ERROR MintermSet: equality test: self or other is not sorted")
            return False

        if len(self) != len(other):
            return False
        for i in range(Self.N):
            if self.data[i].size != other.data[i].size:
                return False
        for i in range(Self.N):
            if not(Self.equal(self.data[i], other.data[i])):
                return False
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
        var result: String = ""
        for i in range(Self.N):
            let s = self.data[i].size
            if s > 0:
                result += "#bits " + str(i) + ": size " + s + "\n"
        return result

    fn sort(inout self):
        for i in range(Self.N):
            pass
            #sort[Self.Q](self.data[i])
        self.is_sorted = True


    fn add(inout self, value: SIMD[T2, 1]):
        let n_bits_set = ctpop(value).to_int()
        self.n_elements += 1

        if self.max_bit_count < n_bits_set:
            self.max_bit_count = n_bits_set

        self.data[n_bits_set].push_back(value)
        self.is_sorted = False

    fn get(self, n_bits_set: Int) -> Self.Q:
        return self.data[n_bits_set]
