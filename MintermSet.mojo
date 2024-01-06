from collections.vector import DynamicVector
from math.bit import ctpop
from algorithm.sort import sort
from tools import get_bit, get_dk_mask
from to_string import PrintType, minterms_to_string, minterm_to_string
from MyMap import MySet


struct MinTermSet[T: DType, N_BITS: Int](CollectionElement, Sized, Stringable):
    alias Q = DynamicVector[SIMD[T, 1]]
    alias n_sets = N_BITS + 1

    var n_elements: Int
    var max_bit_count: Int
    var is_sorted: Bool
    var data: DynamicVector[Self.Q]

    fn __init__(inout self):
        self.n_elements = 0
        self.max_bit_count = 0
        self.is_sorted = True
        self.data = DynamicVector[Self.Q](Self.n_sets)
        for i in range(Self.n_sets):
            self.data.push_back(Self.Q())

    fn __eq__(self, other: Self) -> Bool:
        if not (self.is_sorted) or not (other.is_sorted):
            print("WARNING performance: MinTermSet: __eq__: self or other is not sorted!")
            #return False
        if len(self) != len(other):
            # print("MinTermSet eq: returns False (A)")
            return False
        for i in range(Self.n_sets):
            if self.data[i].size != other.data[i].size:
                # print("MinTermSet eq: returns False (B)" + str(i))
                return False
        for i in range(Self.n_sets):
            if not (Self.equal(self.data[i], other.data[i])):
                # print("MinTermSet eq: returns False (C)" + str(i))
                return False
        # print("MinTermSet eq: returns True (D)")
        return True

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)

    @staticmethod
    fn equal(v1: Self.Q, v2: Self.Q) -> Bool:
        for i in range(v1.size):
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
        return self.to_string[PrintType.VERBOSE](N_BITS)

    fn to_string[P: PrintType](self, number_vars: Int) -> String:
        var result: String = ""
        for i in range(Self.n_sets):
            result += minterms_to_string[T, P](self.data[i], number_vars)
        return result

    fn sort(inout self):
        if self.is_sorted:
            return
        for i in range(Self.n_sets):
            sort[T](self.data[i])
        self.is_sorted = True

    fn add[
        CHECK_CONTAINS: Bool = True, SHOW_INFO: Bool = False
    ](inout self, value: SIMD[T, 1]):
        alias dk_mask: SIMD[T, 1] = get_dk_mask[T]()
        let n_bits_set = ctpop(value & dk_mask).to_int()

        # @parameter
        # if SHOW_INFO:
        # print("INFO: 7bd7968f: adding value: check_duplicate=" +str(check_duplicate) +"; value=" + minterm_to_string[T, PrintType.VERBOSE](value, bit_width) + "; n_bits_set="+str(n_bits_set))

        self.n_elements += 1

        if self.max_bit_count < n_bits_set:
            self.max_bit_count = n_bits_set

        # @parameter
        # if SHOW_INFO:
        # print("INFO: currently present: n_bits_set=" + str(n_bits_set) + "; size=" + str(self.data[n_bits_set].size))

        @parameter
        if CHECK_CONTAINS:
            var already_present = False
            for i in range(self.data[n_bits_set].size):
                if self.data[n_bits_set][i] == value:
                    already_present = True
                    break
            if not already_present:
                self.data[n_bits_set].push_back(value)
                self.is_sorted = False
        else:
            self.data[n_bits_set].push_back(value)
            self.is_sorted = False


    fn get(self, n_bits_set: Int) -> Self.Q:
        debug_assert(n_bits_set < Self.n_sets, "invalid idx")
        return self.data[n_bits_set]

    fn to_set(self) -> MySet[T]:
        var result = MySet[T]()
        for i in range(Self.n_sets):
            let x = self.data[i]
            for j in range(len(x)):
                result.add[CHECK_CONTAINS=False](x[j])
        return result ^
