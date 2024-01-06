from algorithm.sort import sort
from tools import eq_dynamic_vector


struct MyMap[Key: DType, Value: CollectionElement](
    CollectionElement, Sized, Stringable
):
    var keys: DynamicVector[SIMD[Key, 1]]
    var values: DynamicVector[Value]

    @always_inline("nodebug")
    fn __init__(inout self):
        self.keys = DynamicVector[SIMD[Key, 1]]()
        self.values = DynamicVector[Value]()

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.keys.__copyinit__(existing.keys)
        self.values.__copyinit__(existing.values)

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.keys = existing.keys ^
        self.values = existing.values ^

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "{"
        let size = len(self.keys)
        if size > 0:
            for i in range(size - 1):
                result += str(self.keys[i]) + "-> value,"
            result += str(self.keys[size - 1]) + "-> value"
        return result + "}"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.keys)

    fn add(inout self, key: SIMD[Key, 1], owned value: Value):
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                self.values[i] = value ^
                return
        self.keys.push_back(key)
        self.values.push_back(value ^)

    fn remove(inout self, key: SIMD[Key, 1]):
        let size = len(self.keys)
        for i in range(size):
            if key == self.keys[i]:
                if i == size - 1:
                    _ = self.keys.pop_back()
                    _ = self.values.pop_back()
                else:
                    self.keys[i] = self.keys.pop_back()
                    self.values[i] = self.values.pop_back()
                return

    fn get(self, key: SIMD[Key, 1]) -> Value:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return self.values[i]
        print("ERROR: cannot return an empty element")
        return self.values[0]

    @always_inline("nodebug")
    fn contains(self, key: SIMD[Key, 1]) -> Bool:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return True
        return False


struct MySet[T: DType](CollectionElement, Sized, Stringable):
    var data: DynamicVector[SIMD[T, 1]]
    var is_sorted: Bool

    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = DynamicVector[SIMD[T, 1]]()
        self.is_sorted = True

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.data.__copyinit__(existing.data)
        self.is_sorted = existing.is_sorted

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.data = existing.data ^
        self.is_sorted = existing.is_sorted

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "["
        let size = len(self.data)
        if size > 0:
            for i in range(size - 1):
                result += str(self.data[i]) + ","
            result += str(self.data[size - 1])
        return result + "]"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.data)

    fn __eq__(self, other: Self) -> Bool:
        if self.is_sorted and other.is_sorted:
            return eq_dynamic_vector[T](self.data, other.data)

        print("WARNING performance: MySet:__eq__ on unsorted data")
        var a = self
        a.sort()
        var b = other
        b.sort()
        return a == b

    fn __ne__(self, other: Self) -> Bool:
        return not (self == other)

    @always_inline("nodebug")
    fn add[CHECK_CONTAINS: Bool = True](inout self, value: SIMD[T, 1]):
        @parameter
        if CHECK_CONTAINS:
            if self.contains(value):
                return
        self.data.push_back(value)
        self.is_sorted = False

    @always_inline("nodebug")
    fn add[CHECK_CONTAINS: Bool = True](inout self, values: MySet[T]):
        for i in range(len(values)):
            # this can be done more efficient
            self.add[CHECK_CONTAINS](values.data[i])

    fn remove(inout self, value: SIMD[T, 1]):
        let size = len(self.data)
        for i in range(size):
            if value == self.data[i]:
                if i == (size - 1):
                    _ = self.data.pop_back()
                    # NOTE this set is still sorted!
                else:
                    self.data[i] = self.data.pop_back()
                    self.is_sorted = False
                return

    @always_inline("nodebug")
    fn remove(inout self, values: MySet[T]):
        for i in range(len(values)):
            # this can be done more efficient
            self.remove(values.data[i])

    @always_inline("nodebug")
    fn sort(inout self):
        if self.is_sorted:
            return
        else:
            sort[T](self.data)
            self.is_sorted = True

    @always_inline("nodebug")
    fn contains(self, value: SIMD[T, 1]) -> Bool:
        if self.is_sorted:
            for i in range(len(self.data)):
                if value <= self.data[i]:
                    return value == self.data[i]
        else:
            for i in range(len(self.data)):
                if value == self.data[i]:
                    return True
        return False


struct MySetStr(CollectionElement, Sized, Stringable):
    var data: DynamicVector[String]

    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = DynamicVector[String]()

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.data.__copyinit__(existing.data)

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.data = existing.data ^

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "["
        let size = len(self.data)
        if size > 0:
            for i in range(size - 1):
                result += str(self.data[i]) + ","
            result += str(self.data[size - 1])
        return result + "]"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.data)

    fn add(inout self, value: String):
        for i in range(len(self.data)):
            if value == self.data[i]:
                return
        self.data.push_back(value)

    fn contains(self, value: String) -> Bool:
        for i in range(len(self.data)):
            if value == self.data[i]:
                return True
        return False
