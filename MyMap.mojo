from collections.vector import DynamicVector


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
        print("ERROR: MyMa: cannot return an empty element")
        return self.values[0]

    @always_inline("nodebug")
    fn contains(self, key: SIMD[Key, 1]) -> Bool:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return True
        return False
