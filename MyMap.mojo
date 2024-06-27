from collections import Dict, KeyElement
from collections.optional import Optional


@value
struct SIMDKey[T: DType](KeyElement):
    var d: Scalar[T]

    fn init(inout self, d: Scalar[T]):
        self.d = d

    fn __hash__(self) -> Int:
        return int(self.d)

    fn __eq__(self, other: Self) -> Bool:
        return self.d == other.d


struct MyMap2[Key2: DType, Value: CollectionElement](
    CollectionElement, Sized, Stringable
):
    alias Key = SIMDKey[Key2]
    var data: Dict[Self.Key, Value]

    @always_inline("nodebug")
    fn __init__(inout self):
        self.data = Dict[Self.Key, Value]()
        self.data.__init__()

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.data = Dict[Self.Key, Value]()
        for i in range(len(self.data)):
            self.data._insert(self.data._entries[i].take())

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.data = existing.data^

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "{"
        var size = len(self.data)
        if size > 0:
            for i in range(size - 1):
                var de = self.data._entries[i].take()
                # result += str(de.key) + "->" + str(de.value)
        return result + "}"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.data)

    fn add(inout self, key: Self.Key, owned value: Value):
        self.data._insert(key, value)

    fn remove(inout self, key: Self.Key):
        try:
            _ = self.data.pop(key)
        except:
            pass

    fn get(self, key: Self.Key) -> Value:
        return self.data.find(key).take()

    @always_inline("nodebug")
    fn contains(self, key: Self.Key) -> Bool:
        return self.data.__contains__(key)

    fn values(self) -> List[Value]:
        var result = List[Value]()
        for i in range(len(self.data)):
            result.append(self.data._entries[i].take().value)
        return result


struct MyMap[Key: DType, Value: CollectionElement](
    CollectionElement, Sized, Stringable
):
    var keys: List[SIMD[Key, 1]]
    var values: List[Value]

    @always_inline("nodebug")
    fn get_values(self) -> List[Value]:
        return self.values

    @always_inline("nodebug")
    fn __init__(inout self):
        self.keys = List[SIMD[Key, 1]]()
        self.values = List[Value]()

    # trait CollectionElement
    @always_inline("nodebug")
    fn __copyinit__(inout self, existing: Self):
        self.keys.__copyinit__(existing.keys)
        self.values.__copyinit__(existing.values)

    # trait CollectionElement
    @always_inline("nodebug")
    fn __moveinit__(inout self, owned existing: Self):
        self.keys = existing.keys^
        self.values = existing.values^

    # trait CollectionElement
    @always_inline("nodebug")
    fn __del__(owned self: Self):
        pass

    # trait Stringable
    @always_inline("nodebug")
    fn __str__(self) -> String:
        var result: String = "{"
        var size = len(self.keys)
        if size > 0:
            for i in range(size - 1):
                result += str(self.keys[i]) + "-> value,"
            result += str(self.keys[size - 1]) + "-> value"
        return result + "}"

    # trait Sized
    @always_inline("nodebug")
    fn __len__(self) -> Int:
        return len(self.keys)

    fn add(inout self, key: Scalar[Key], owned value: Value):
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                self.values[i] = value^
                return
        self.keys.append(key)
        self.values.append(value^)

    fn remove(inout self, key: Scalar[Key]):
        var size = len(self.keys)
        for i in range(size):
            if key == self.keys[i]:
                if i == size - 1:
                    _ = self.keys.pop()
                    _ = self.values.pop()
                else:
                    self.keys[i] = self.keys.pop()
                    self.values[i] = self.values.pop()
                return

    fn get(self, key: Scalar[Key]) -> Value:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return self.values[i]
        print("ERROR: MyMa: cannot return an empty element")
        return self.values[0]

    @always_inline("nodebug")
    fn contains(self, key: Scalar[Key]) -> Bool:
        for i in range(len(self.keys)):
            if key == self.keys[i]:
                return True
        return False
