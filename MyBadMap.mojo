struct MyBadMap[Key: DType, Value: CollectionElement](
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
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                self.keys[i] = self.keys.pop_back()
                self.values[i] = self.values.pop_back()
                return

    fn get(self, key: SIMD[Key, 1]) -> Value:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return self.values[i]
        return 0

    fn contains(self, key: SIMD[Key, 1]) -> Bool:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return True
        return False


struct MyBadSet[Value: DType](CollectionElement, Sized, Stringable):
    var data: DynamicVector[SIMD[Value, 1]]

    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = DynamicVector[SIMD[Value, 1]]()

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

    fn add(inout self, value: SIMD[Value, 1]):
        for i in range(len(self.data)):
            if value == self.data[i]:
                return
        self.data.push_back(value)

    fn add(inout self, values: MyBadSet[Value]):
        for i in range(len(values)):
            # this can be done more efficient
            self.add(values.data[i])

    fn contains(self, value: SIMD[Value, 1]) -> Bool:
        for i in range(len(self.data)):
            if value == self.data[i]:
                return True
        return False


struct MyBadSetStr(CollectionElement, Sized, Stringable):
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
