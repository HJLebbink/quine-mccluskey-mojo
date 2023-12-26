from collections.vector import DynamicVector


fn fun() -> Tuple[DynamicVector[Int], DynamicVector[Int]]:
    return (DynamicVector[Int](), DynamicVector[Int]())


fn main():
    let t = fun()
    let v1 = t.get[0, DynamicVector[Int]]()
