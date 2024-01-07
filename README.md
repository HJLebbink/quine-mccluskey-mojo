# quine-mccluskey-mojo

Implementation of Quine-McCluskey and Petrick Methods in Modular Mojo

The Quine-McCluskey method is an exact algorithm employed for Boolean function simplification. While traditionally applied in digital circuit design and optimization, I would like to use it for optimizing software. This method takes a set of minterms representing a Boolean function and systematically combines them to identify things called prime implicants. Through grouping terms with similar binary representations, the algorithm constructs a table, in which we can identify essential prime implicants. The outcome is a minimal sum-of-products (SOP) expression, representing a simplified form of the given Boolean function.

Petrick's method, another exact technique used in digital circuit design, is used for solving cyclic covering problems. It constructs a matrix based on the prime implicants derived from the Quine-McCluskey method and subsequently applying a process to identify the minimal cover. This minimal cover represents the smallest form of the given Boolean function.

The logic in a programming language can be described as a Boolean function, as outlined in the following Truth-Table:

```
    ABCD -> y
0:  0000 -> 1
1:  0001 -> 0
2:  0010 -> 1
3:  0011 -> 1
4:  0100 -> 1
5:  0101 -> 1
6:  0110 -> 1
7:  0111 -> 1
8:  1000 -> 1
9:  1001 -> 1
10: 1010 -> 1
11: 1011 -> 1
12: 1100 -> 1
13: 1101 -> 1
14: 1110 -> 0
15: 1111 -> 0
```

 This function maps four input boolean variables `A` to `D` to a result `y`. Without much effort, an inefficient formula can be derived for this function, specifically the disjunction of all 13 terms (conjunctions) that map to 1, expressed as `y = (~A ^ ~B ^ ~C ^ ~D) v ... v (A ^ B ^ ~C ^ D)`. We can do better than that, and find a much more optimized representation.


The Quine-McCluskey method simplifies this truth-table to:

```
ABCD -> y
0XX0 -> 1
X0X0 -> 1
XX00 -> 1
01XX -> 1
10XX -> 1
0X1X -> 1
1X0X -> 1
X01X -> 1
X10X -> 1
```

Additionally, Petricks method simplifies this truth-table to:
```
ABCD -> y
01XX -> 1
1X0X -> 1
0XX0 -> 1
X01X -> 1
```

Which gives us the following formula: `y = (~A ^ B) v (A ^ ~C) v (~A ^ ~D) v (~B ^ C)`

The Mojo code has a parameter `SHOW_INFO: Bool` which, when set to true, will display intermediate steps. This allows us to observe how the Boolean function is incrementally simplified throughout the process.

## And what has this to do with Mojo?

Petrick's method addresses the covering problem, a known NP-complete problem: thus exact algorithm *may* take exponetial time in the worst cast. Having a efficient implementation is not a luxery.

But more important, with Mojo, this algorithm can be run at compile time. We can extract logic from our programming language, minimize it to its absolute minimum, and produce high-performance code. While compile time may be notable slower, consider it an investment in achieving faster runtime performance.

Attempting to write this algorithm as a template program in C++ may not be the most pleasant experience... Hence Mojo.
