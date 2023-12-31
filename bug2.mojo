
fn test() -> Bool:
    return True

fn main():
    let A: SIMD[DType.int32, 1] = 10
    let B: SIMD[DType.int32, 1] = 10

    if A != B & test(): # assumed operator precedence
        print("A: not expected but observed")
    else: 
        print("A: expected but not observed")


    if (A != B) & test(): # explicit
        print("B: not expected and not observed")
    else: 
        print("B: expected and observed")
