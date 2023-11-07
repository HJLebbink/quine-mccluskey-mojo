
from utils.vector import InlinedFixedVector, DynamicVector
from math.bit import ctpop

alias T = UInt32
alias N = 32

struct MintermSet:

    var max_bit_count: T

    var data1: DynamicVector[T]
    var data2: DynamicVector[T]
    var data3: DynamicVector[T]
    var data4: DynamicVector[T]
    var data5: DynamicVector[T]
    var data6: DynamicVector[T]
    var data7: DynamicVector[T]
    var data8: DynamicVector[T]
    var data9: DynamicVector[T]
    var data10: DynamicVector[T]
    var data11: DynamicVector[T]
    var data12: DynamicVector[T]
    var data13: DynamicVector[T]
    var data14: DynamicVector[T]
    var data15: DynamicVector[T]
    var data16: DynamicVector[T]
    var data17: DynamicVector[T]
    var data18: DynamicVector[T]
    var data19: DynamicVector[T]
    var data20: DynamicVector[T]
    var data21: DynamicVector[T]
    var data22: DynamicVector[T]
    var data23: DynamicVector[T]
    var data24: DynamicVector[T]
    var data25: DynamicVector[T]
    var data26: DynamicVector[T]
    var data27: DynamicVector[T]
    var data28: DynamicVector[T]
    var data29: DynamicVector[T]
    var data30: DynamicVector[T]
    var data31: DynamicVector[T]

    fn __init__(inout self):
        self.data1 = DynamicVector[T](0)
        self.data2 = DynamicVector[T](0)
        self.data3 = DynamicVector[T](0)
        self.data4 = DynamicVector[T](0)
        self.data5 = DynamicVector[T](0)
        self.data6 = DynamicVector[T](0)
        self.data7 = DynamicVector[T](0)
        self.data8 = DynamicVector[T](0)
        self.data9 = DynamicVector[T](0)
        self.data10 = DynamicVector[T](0)
        self.data11 = DynamicVector[T](0)
        self.data12 = DynamicVector[T](0)
        self.data13 = DynamicVector[T](0)
        self.data14 = DynamicVector[T](0)
        self.data15 = DynamicVector[T](0)
        self.data16 = DynamicVector[T](0)
        self.data17 = DynamicVector[T](0)
        self.data18 = DynamicVector[T](0)
        self.data19 = DynamicVector[T](0)
        self.data20 = DynamicVector[T](0)
        self.data21 = DynamicVector[T](0)
        self.data22 = DynamicVector[T](0)
        self.data23 = DynamicVector[T](0)
        self.data24 = DynamicVector[T](0)
        self.data25 = DynamicVector[T](0)
        self.data26 = DynamicVector[T](0)
        self.data27 = DynamicVector[T](0)
        self.data28 = DynamicVector[T](0)
        self.data29 = DynamicVector[T](0)
        self.data30 = DynamicVector[T](0)
        self.data31 = DynamicVector[T](0)

    fn add(inout self, value: UInt32):
        let n_bits_set = ctpop(value)

        if self.max_bit_count < n_bits_set:
            self.max_bit_count = n_bits_set

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
        else:
            print("ERROR")

    fn get(self, n_bits_set: UInt32) -> DynamicVector[T]:
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
        else:
            print("ERROR get")
