from collections.vector import InlinedFixedVector, DynamicVector
from math.bit import ctpop

alias N = 32


struct MintermSet[T2: DType](Copyable, Movable, Stringable, Sized):
    var n_elements: Int
    var max_bit_count: SIMD[T2, 1]

    var data0: Bool
    var data1: DynamicVector[SIMD[T2, 1]]
    var data2: DynamicVector[SIMD[T2, 1]]
    var data3: DynamicVector[SIMD[T2, 1]]
    var data4: DynamicVector[SIMD[T2, 1]]
    var data5: DynamicVector[SIMD[T2, 1]]
    var data6: DynamicVector[SIMD[T2, 1]]
    var data7: DynamicVector[SIMD[T2, 1]]
    var data8: DynamicVector[SIMD[T2, 1]]
    var data9: DynamicVector[SIMD[T2, 1]]
    var data10: DynamicVector[SIMD[T2, 1]]
    var data11: DynamicVector[SIMD[T2, 1]]
    var data12: DynamicVector[SIMD[T2, 1]]
    var data13: DynamicVector[SIMD[T2, 1]]
    var data14: DynamicVector[SIMD[T2, 1]]
    var data15: DynamicVector[SIMD[T2, 1]]
    var data16: DynamicVector[SIMD[T2, 1]]
    var data17: DynamicVector[SIMD[T2, 1]]
    var data18: DynamicVector[SIMD[T2, 1]]
    var data19: DynamicVector[SIMD[T2, 1]]
    var data20: DynamicVector[SIMD[T2, 1]]
    var data21: DynamicVector[SIMD[T2, 1]]
    var data22: DynamicVector[SIMD[T2, 1]]
    var data23: DynamicVector[SIMD[T2, 1]]
    var data24: DynamicVector[SIMD[T2, 1]]
    var data25: DynamicVector[SIMD[T2, 1]]
    var data26: DynamicVector[SIMD[T2, 1]]
    var data27: DynamicVector[SIMD[T2, 1]]
    var data28: DynamicVector[SIMD[T2, 1]]
    var data29: DynamicVector[SIMD[T2, 1]]
    var data30: DynamicVector[SIMD[T2, 1]]
    var data31: DynamicVector[SIMD[T2, 1]]
    var data32: Bool

    fn __init__(inout self: Self):
        self.n_elements = 0
        self.max_bit_count = 0
        self.data0 = False
        self.data1 = DynamicVector[SIMD[T2, 1]](0)
        self.data2 = DynamicVector[SIMD[T2, 1]](0)
        self.data3 = DynamicVector[SIMD[T2, 1]](0)
        self.data4 = DynamicVector[SIMD[T2, 1]](0)
        self.data5 = DynamicVector[SIMD[T2, 1]](0)
        self.data6 = DynamicVector[SIMD[T2, 1]](0)
        self.data7 = DynamicVector[SIMD[T2, 1]](0)
        self.data8 = DynamicVector[SIMD[T2, 1]](0)
        self.data9 = DynamicVector[SIMD[T2, 1]](0)
        self.data10 = DynamicVector[SIMD[T2, 1]](0)
        self.data11 = DynamicVector[SIMD[T2, 1]](0)
        self.data12 = DynamicVector[SIMD[T2, 1]](0)
        self.data13 = DynamicVector[SIMD[T2, 1]](0)
        self.data14 = DynamicVector[SIMD[T2, 1]](0)
        self.data15 = DynamicVector[SIMD[T2, 1]](0)
        self.data16 = DynamicVector[SIMD[T2, 1]](0)
        self.data17 = DynamicVector[SIMD[T2, 1]](0)
        self.data18 = DynamicVector[SIMD[T2, 1]](0)
        self.data19 = DynamicVector[SIMD[T2, 1]](0)
        self.data20 = DynamicVector[SIMD[T2, 1]](0)
        self.data21 = DynamicVector[SIMD[T2, 1]](0)
        self.data22 = DynamicVector[SIMD[T2, 1]](0)
        self.data23 = DynamicVector[SIMD[T2, 1]](0)
        self.data24 = DynamicVector[SIMD[T2, 1]](0)
        self.data25 = DynamicVector[SIMD[T2, 1]](0)
        self.data26 = DynamicVector[SIMD[T2, 1]](0)
        self.data27 = DynamicVector[SIMD[T2, 1]](0)
        self.data28 = DynamicVector[SIMD[T2, 1]](0)
        self.data29 = DynamicVector[SIMD[T2, 1]](0)
        self.data30 = DynamicVector[SIMD[T2, 1]](0)
        self.data31 = DynamicVector[SIMD[T2, 1]](0)
        self.data32 = False

    fn __eq__(self: Self, other: Self) -> Bool:
        if len(self) != len(other):
            return False
        for i in range(N - 1):
            let v1 = self.get(i)
            let v2 = other.get(i)
            if len(v1) != len(v2):
                return False
            for j in range(len(v1)):
                # assume v1 and v2 are sorted
                if v1.__getitem__(j) != v2.__getitem__(j):
                    return False
        return True

    # trait Sized
    fn __len__(self: Self) -> Int:
        return self.n_elements

    # trait Copyable
    fn __copyinit__(inout self: Self, existing: Self):
        self.n_elements = existing.n_elements
        self.max_bit_count = existing.max_bit_count
        self.data0 = existing.data0
        self.data1.__copyinit__(existing.data1)
        self.data2.__copyinit__(existing.data2)
        self.data3.__copyinit__(existing.data3)
        self.data4.__copyinit__(existing.data4)
        self.data5.__copyinit__(existing.data5)
        self.data6.__copyinit__(existing.data6)
        self.data7.__copyinit__(existing.data7)
        self.data8.__copyinit__(existing.data8)
        self.data9.__copyinit__(existing.data9)
        self.data10.__copyinit__(existing.data10)
        self.data11.__copyinit__(existing.data11)
        self.data12.__copyinit__(existing.data12)
        self.data13.__copyinit__(existing.data13)
        self.data14.__copyinit__(existing.data14)
        self.data15.__copyinit__(existing.data15)
        self.data16.__copyinit__(existing.data16)
        self.data17.__copyinit__(existing.data17)
        self.data18.__copyinit__(existing.data18)
        self.data19.__copyinit__(existing.data19)
        self.data20.__copyinit__(existing.data20)
        self.data21.__copyinit__(existing.data21)
        self.data22.__copyinit__(existing.data22)
        self.data23.__copyinit__(existing.data23)
        self.data24.__copyinit__(existing.data24)
        self.data25.__copyinit__(existing.data25)
        self.data26.__copyinit__(existing.data26)
        self.data27.__copyinit__(existing.data27)
        self.data28.__copyinit__(existing.data28)
        self.data29.__copyinit__(existing.data29)
        self.data30.__copyinit__(existing.data30)
        self.data31.__copyinit__(existing.data31)
        self.data32 = existing.data32

    # trait Movable
    fn __moveinit__(inout self: Self, owned existing: Self):
        self.n_elements = existing.n_elements
        self.max_bit_count = existing.max_bit_count
        self.data0 = existing.data0
        self.data1.__moveinit__(existing.data1)
        self.data2.__moveinit__(existing.data2)
        self.data3.__moveinit__(existing.data3)
        self.data4.__moveinit__(existing.data4)
        self.data5.__moveinit__(existing.data5)
        self.data6.__moveinit__(existing.data6)
        self.data7.__moveinit__(existing.data7)
        self.data8.__moveinit__(existing.data8)
        self.data9.__moveinit__(existing.data9)
        self.data10.__moveinit__(existing.data10)
        self.data11.__moveinit__(existing.data11)
        self.data12.__moveinit__(existing.data12)
        self.data13.__moveinit__(existing.data13)
        self.data14.__moveinit__(existing.data14)
        self.data15.__moveinit__(existing.data15)
        self.data16.__moveinit__(existing.data16)
        self.data17.__moveinit__(existing.data17)
        self.data18.__moveinit__(existing.data18)
        self.data19.__moveinit__(existing.data19)
        self.data20.__moveinit__(existing.data20)
        self.data21.__moveinit__(existing.data21)
        self.data22.__moveinit__(existing.data22)
        self.data23.__moveinit__(existing.data23)
        self.data24.__moveinit__(existing.data24)
        self.data25.__moveinit__(existing.data25)
        self.data26.__moveinit__(existing.data26)
        self.data27.__moveinit__(existing.data27)
        self.data28.__moveinit__(existing.data28)
        self.data29.__moveinit__(existing.data29)
        self.data30.__moveinit__(existing.data30)
        self.data31.__moveinit__(existing.data31)
        self.data32 = existing.data32

    # trait Stringable
    fn __str__(self: Self) -> String:
        var result: String = ""
        if self.data0:
            result += "#bits 0: size 1\n"

        for i in range(1, N - 1):
            let s: Int = self.get(i).size
            if s > 0:
                result += "#bits " + str(i) + ": size " + s + "\n"

        if self.data32:
            result += "#bits 32: size 1\n"

        return result

    fn add(inout self: Self, value: SIMD[T2, 1]):
        let n_bits_set = ctpop(value)

        if self.max_bit_count < n_bits_set:
            self.max_bit_count = n_bits_set

        if n_bits_set == 0:
            self.data0 = True
        if n_bits_set == 1:
            self.data1.push_back(value)
        elif n_bits_set == 2:
            self.data2.push_back(value)
        elif n_bits_set == 3:
            self.data3.push_back(value)
        elif n_bits_set == 4:
            self.data4.push_back(value)
        elif n_bits_set == 5:
            self.data5.push_back(value)
        elif n_bits_set == 6:
            self.data6.push_back(value)
        elif n_bits_set == 7:
            self.data7.push_back(value)
        elif n_bits_set == 8:
            self.data8.push_back(value)
        elif n_bits_set == 9:
            self.data9.push_back(value)
        elif n_bits_set == 10:
            self.data10.push_back(value)
        elif n_bits_set == 11:
            self.data11.push_back(value)
        elif n_bits_set == 12:
            self.data12.push_back(value)
        elif n_bits_set == 13:
            self.data13.push_back(value)
        elif n_bits_set == 14:
            self.data14.push_back(value)
        elif n_bits_set == 15:
            self.data15.push_back(value)
        elif n_bits_set == 16:
            self.data16.push_back(value)
        elif n_bits_set == 17:
            self.data17.push_back(value)
        elif n_bits_set == 18:
            self.data18.push_back(value)
        elif n_bits_set == 19:
            self.data19.push_back(value)
        elif n_bits_set == 20:
            self.data20.push_back(value)
        elif n_bits_set == 21:
            self.data21.push_back(value)
        elif n_bits_set == 22:
            self.data22.push_back(value)
        elif n_bits_set == 23:
            self.data23.push_back(value)
        elif n_bits_set == 24:
            self.data24.push_back(value)
        elif n_bits_set == 25:
            self.data25.push_back(value)
        elif n_bits_set == 26:
            self.data26.push_back(value)
        elif n_bits_set == 27:
            self.data27.push_back(value)
        elif n_bits_set == 28:
            self.data28.push_back(value)
        elif n_bits_set == 29:
            self.data29.push_back(value)
        elif n_bits_set == 30:
            self.data30.push_back(value)
        elif n_bits_set == 31:
            self.data31.push_back(value)
        elif n_bits_set == 32:
            self.data32 = True
        else:
            print("ERROR MintermSet.set")

    fn get(self: Self, n_bits_set: SIMD[T2, 1]) -> DynamicVector[SIMD[T2, 1]]:
        if n_bits_set == 0:
            if self.data0:
                return DynamicVector[SIMD[T2, 1]](0)
            else:
                var tmp = DynamicVector[SIMD[T2, 1]](1)
                tmp[0] = 0
                return tmp
        if n_bits_set == 1:
            return self.data1
        elif n_bits_set == 2:
            return self.data2
        elif n_bits_set == 3:
            return self.data3
        elif n_bits_set == 4:
            return self.data4
        elif n_bits_set == 5:
            return self.data5
        elif n_bits_set == 6:
            return self.data6
        elif n_bits_set == 7:
            return self.data7
        elif n_bits_set == 8:
            return self.data8
        elif n_bits_set == 9:
            return self.data9
        elif n_bits_set == 10:
            return self.data10
        elif n_bits_set == 11:
            return self.data11
        elif n_bits_set == 12:
            return self.data12
        elif n_bits_set == 13:
            return self.data12
        elif n_bits_set == 14:
            return self.data14
        elif n_bits_set == 15:
            return self.data15
        elif n_bits_set == 16:
            return self.data16
        elif n_bits_set == 17:
            return self.data17
        elif n_bits_set == 18:
            return self.data18
        elif n_bits_set == 19:
            return self.data19
        elif n_bits_set == 20:
            return self.data20
        elif n_bits_set == 21:
            return self.data21
        elif n_bits_set == 22:
            return self.data22
        elif n_bits_set == 23:
            return self.data23
        elif n_bits_set == 24:
            return self.data24
        elif n_bits_set == 25:
            return self.data25
        elif n_bits_set == 26:
            return self.data26
        elif n_bits_set == 27:
            return self.data27
        elif n_bits_set == 28:
            return self.data28
        elif n_bits_set == 29:
            return self.data29
        elif n_bits_set == 30:
            return self.data30
        elif n_bits_set == 31:
            return self.data31
        elif n_bits_set == 32:
            if self.data32:
                return DynamicVector[SIMD[T2, 1]](0)
            else:
                var tmp = DynamicVector[SIMD[T2, 1]](1)
                tmp[0] = 0
                return tmp
        else:
            print("ERROR MintermSet.get: n_bits_set=" + str(n_bits_set))
            return DynamicVector[SIMD[T2, 1]](0)
