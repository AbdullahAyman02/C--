# C-- Compiler
This project is a simple compiler for the C-- language with some modifications.

The goal of this project is to implement the front-end phase of the compiler, which is:
1. **lexical analysis** : extract tokens from the source code. 
2. **syntax analysis** : check if programming constructs are correctly formed.
3. **semantic analysis** : check if programming constructs are correctly used.
4. **intermediate code generation** : generate intermediate code for the source code using **Three Address Code**.

## Table of Contents

  
- [Our C-- Language](#our-c---language)
- [Tech Stack](#tech-stack)
- [How to Build and Run](#how-to-build-and-run)
- [References](#references)
- [Example](#example)
- [Contributors](#contributors)

## Our C-- Language

The C-- language is a simplified version of C with some additional features and restrictions. Below are the programming constructs supported by our modified C-- compiler:

### Data Types
- **Primitive Types**:
  - `int`: Integer values.
  - `float`: Floating-point values.
  - `char`: Single character.
  - `string`: Sequence of characters.
  - `bool`: Boolean values (`True` or `False`).
- **Constants**:
  - `const`: Used to declare immutable variables (e.g., `const char d = 'd';`).

### Variables and Declarations
- Variables can be declared and initialized:
  ```c
  float y = 2.0;
  string var = "test";
  char c = 'c';
  bool flag = False;
    ```
- Constants are declared using the ``const`` keyword:
    ```c
    const int x = 5;
    ```
### Arithmetic and Logical Expressions  
- **Arithmetic Operations**:  
  Supports basic arithmetic operators (`+`, `-`, `*`, `/`, `^`).  
  ```c  
  int w = 3 ^ 7 * 3 / 4; // Example of mixed operations  
  float z = 3.0 + y;     // Floating-point arithmetic
- **Comparison Operations**:  
  Supports comparison operators (`==`, `!=`, `>`, `<`, `>=`, `<=`).  
  ```c  
  bool b = 3 > 2;  
  bool c = 3.0 == 3;  
  ```  
- **Logical Operations**:
    Supports logical operators (`&&`, `||`).
    ```c
    bool b = True || False;
    ```
### Control Flow
- **Conditional Statements**: `if-else`
  ```c
  if (c == d) then {
      flag = True;
  } else {
      flag = False;
  };
    ```
- **Switch Statements**:
  ```c
    switch (w) {
        case 2: {
            flag = True;
        }
    };
    ```
- **Loops**:
  - **Repeat-Until Loop**:
    ```c
    repeat {
        z = 7.3;
    } until (flag == False);
    ```
  - **For Loop**:
    ```c
    int i;
    for (i = 0; i < i; i = i + 1) {
        flag = False;
    };
    ```
  - **While Loop**:
    ```c
    while(z > y) {
        y = y + 5;
    };
    ```
### Functions
- **Function Declaration**:
  - **Return Type**: `int`, `void`, etc.
  - **Parameters**: Multiple parameters of different types.
  ```c
  function int test_function() {
      flag = True;
      return 3;
  };
  
  function void void_function(int a, char b, string k) {
      return;
  };
  ```

## Tech Stack
This project was developed using the **Flex** and **Bison** tools. In addition **C++** was used to implement the logic of the compiler.

Where flex is used to take the input token patterns and generate the necessary code to recognize these patterns, and bison is used to generate the parser for the grammar of the language.

## How to Build and Run
The following dependencies are required to build and run the project:
- **Flex**: A tool for generating scanners.
- **Bison**: A tool for generating parsers.
- **g++**: A compiler that supports C++11.
- **gcc**: A compiler that supports C.
- **make**: A build automation tool.



**Clone the repository**
```bash
git clone https://github.com/AbdullahAyman02/C--.git
```

**Go to the repository directory and build the project**
```bash
make
```
**Run the compiler**
```bash
./parser <input_file>
```
Where `<input_file>` is the path to the source code file.

The result will be the symbol table and the intermediate code generated represented in quadruples for the source code.

## Example
The following is an example of a simple C-- program that calculates the 10th Fibonacci number:

```c
function int fibonacci(int n) {
    if (n == 0) then {
        return 0;
    };
    if (n == 1) then {
        return 1;
    };
    return fibonacci(n-1) + fibonacci(n-2);
};

fibonacci(10);
```

**The output:**
```
Compiling input file: .\13_functions.txt
------ Symbol Table 0 ------
---------------------------------------------
|   Name    | Kind |  Type   |     Other    |
---------------------------------------------
| fibonacci | Func | integer | args cnt = 1 |
| n         | Arg  | integer |  -           |
| add       | Func | integer | args cnt = 2 |
| a         | Arg  | integer |  -           |
| b         | Arg  | integer |  -           |
---------------------------------------------

------ Child of Symbol Table 0 ------
------ Symbol Table 1 ------
---------------------------------
| Name | Kind |  Type   | Other |
---------------------------------
| b    | Var  | integer |  -    |
| a    | Var  | integer |  -    |
---------------------------------

------ Child of Symbol Table 0 ------
------ Symbol Table 2 ------
---------------------------------
| Name | Kind |  Type   | Other |
---------------------------------
| n    | Var  | integer |  -    |
---------------------------------

------ Child of Symbol Table 2 ------
------ Symbol Table 3 ------
Empty

------ Child of Symbol Table 2 ------
------ Symbol Table 4 ------
Empty

----------------------------------------------------
| Index |  Op  |       Arg1       | Arg2 | Result  |
----------------------------------------------------
| 0     | JMP  |                  |      | L1:     |
| 1     | L0:  |                  |      |         |
| 2     | POP  |                  |      | ret_L0: |
| 3     | POP  |                  |      | b       |
| 4     | POP  |                  |      | a       |
| 5     | ADD  | a                | b    | T0      |
| 6     | PUSH | T0               |      |         |
| 7     | JMP  | content(ret_L0:) |      |         |
| 8     | JMP  | content(ret_L0:) |      |         |
| 9     | L1:  |                  |      |         |
| 10    | JMP  |                  |      | L7:     |
| 11    | L2:  |                  |      |         |
| 12    | POP  |                  |      | ret_L2: |
| 13    | POP  |                  |      | n       |
| 14    | EQ   | n                | 0    | T1      |
| 15    | JF   | T1               |      | L3:     |
| 16    | PUSH | 0                |      |         |
| 17    | JMP  | content(ret_L2:) |      |         |
| 18    | L3:  |                  |      |         |
| 19    | EQ   | n                | 1    | T2      |
| 20    | JF   | T2               |      | L4:     |
| 21    | PUSH | 1                |      |         |
| 22    | JMP  | content(ret_L2:) |      |         |
| 23    | L4:  |                  |      |         |
| 24    | SUB  | n                | 1    | T3      |
| 25    | PUSH | T3               |      |         |
| 26    | PUSH | L5:              |      |         |
| 27    | JMP  | L2:              |      |         |
| 28    | L5:  |                  |      |         |
| 29    | POP  |                  |      | T4      |
| 30    | SUB  | n                | 2    | T5      |
| 31    | PUSH | T5               |      |         |
| 32    | PUSH | L6:              |      |         |
| 33    | JMP  | L2:              |      |         |
| 34    | L6:  |                  |      |         |
| 35    | POP  |                  |      | T6      |
| 36    | ADD  | T4               | T6   | T7      |
| 37    | PUSH | T7               |      |         |
| 38    | JMP  | content(ret_L2:) |      |         |
| 39    | JMP  | content(ret_L2:) |      |         |
| 40    | L7:  |                  |      |         |
| 41    | PUSH | 5                |      |         |
| 42    | PUSH | 10               |      |         |
| 43    | PUSH | L8:              |      |         |
| 44    | JMP  | L0:              |      |         |
| 45    | L8:  |                  |      |         |
| 46    | POP  |                  |      | T8      |
| 46    | POP  |                  |      | T8      |
| 46    | POP  |                  |      | T8      |
| 46    | POP  |                  |      | T8      |
| 47    | PUSH | 10               |      |         |
| 48    | PUSH | L9:              |      |         |
| 49    | JMP  | L2:              |      |         |
| 50    | L9:  |                  |      |         |
| 51    | POP  |                  |      | T9      |
----------------------------------------------------
```
## References
- [Compilers: Principles, Techniques, and Tools 2nd Edition](https://www.amazon.com/Compilers-Principles-Techniques-Tools-2nd/dp/0321486811)

## Contributors
* [Salah Abotaleb](https://github.com/SalahAbotaleb)
* [Abdullah Ayman](https://github.com/AbdullahAyman02)
* [Omar Elzahar](https://github.com/omarelzahar02)
* [Hussien Elhawary](https://github.com/Hussein-Elhawary)