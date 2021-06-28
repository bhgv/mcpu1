research multicore SOC/CPU/MCU
==============================
(> 2. now tested 2 - 5 cores).

testing hardware: Altera cyclone 2 and Altera cyclone IV.

(including memory controllers, serial ports and a simple RGB framebuffer): 2 cores < 20k lut, 4 cores < 30k lut.

Features:
--------
* easily configurable number of synthesized CPU-cores (defines.v -> CPU_QUANTITY).
* redefining the order of command execution.
* automatic hardware distribution of threads among cores.
* if there are fewer active threads than CPU cores, several cores can process several instructions of one thread at once.
* hardware synchronization of memory access and hardware correct memory access order (this is necessary when changing the execution order and accessing memory by reference)
* MMU. virtual memory. memory protection. each thread sees memory as 0 -- the amount assigned to it. and only has access to the memory of his childs.
* Whenever possible, the CPU captures data directly from the data bus without accessing memory.
* if several sequential commands write-read-write the same address in memory, no intermediate write-reads are made.
* hardware creation and completion of threads.
* hardware thread scheduler. the cost of switching a thread is 1 machine cycle. in the worst case, it is the time until the end of execution of the current command by any of the cores.
* hardware channels (blocking). only one CPU instruction is needed for each operation. you just write to the channel. read from it. check the pending connection.
* channels are used for: communication between threads, communication with external devices, interrupts. may be used to wait on locks.

* RISC orthogonal command system. easy-to-understand commands.
* a fairly high-level assembler (`/asm`) written in python. you can easily change it to suit your desires.

Registers:
---------
Registers are:

* `r0` - `r7`
* `r7` is also called `ip` (command counter of the thread).
* `z`  - means this register is not used.

POST increment/decrement:
------------------------
* in each instruction the used register may be *post*(!) incremented(`--`) or decremented(`++`).

*NOTE*: `z` cannot be incremented or decremented.

Memory access:
-------------
Register may be used directly:

*Ex*: `r2`, `r1++`, `r5--`

`--` or `++` decrease or increase the register value by 1 after using the register in the instruction and keep its value:

*Ex*:
```C
//(let r3 = 1)
r3++ = r3++ + r3++; // (1 + (1+1)) + 1 = 4
```

Registers may be used to access memory:

*Ex*: `[r1]`, `[r4++]`, `[r0--]`

`--` or `++` decrease or increase the register value (adress, not the value of the pointed memory!) by 1 after using the register in the instruction and keep its value (adress in the register!):

*NOTE*:`z` is skipped in calculations and cannot be used to access memory.

*NOTE*: there are no instructions for working with immediate data. to include data in your instructions, do this:
```
R = R + [ip++];
<immediate data>; //ways of specifying immediate data see below
```

Instructions / Commands:
-----------------------
each command is addressed by the `ip` (`r7`) register and can include up to 4 registers. each register may be a memory reference, may be (post) increased or decreased.

List of currently existing commands:

*R* - means any of:

* `z`,
* `r0` -- `r7`,
* `ip`,
* `r0++` -- `r7++`,
* `r0--` -- `r7--`,
* `ip++`, `ip--`,
* `[r0]` -- `[r7]`,
* `[ip]`,
* `[r0++]` -- `[r7++]`,
* `[r0--]` -- `[r7--]`,
* `[ip--]` -- `[ip--]`

* * *

Ariphmetic/Bitwise operations:

1. *R* `=` *R* `+` *R*;
1. *R* `=` *R* `-` *R*;
1. *R* `=` *R* `*` *R*;
1. *R* `=` *R* `/` *R*;
1. *R* `=` *R* `|` *R*;  //bitwise OR
1. *R* `=` *R* `&` *R*;  //bitwise AND
1. *R* `=` *R* `^` *R*;  //bitwise XOR
1. *R* `=` *R* `>>` *R*; //logical shift right
1. *R* `=` *R* `<<` *R*; //logical shift left

Channel operations:

1. *R* `c<-` *R*;  // send a data to the channel (*R* contains the num of channel)
1. *R* `<-c` *R*;  // recieve a data from the channel
1. *R* `?c` *R*;   // polls the channel to wait for communication on the other side

thread operations:

1. *R* = `fork` *R* `(` *R* `)`;  // start a thread
1. *R* = `stop` *R* `(` *R* `)`;  // stop a thread

conditional:

1. `if` `(` *R* `)` `<an_instruction_without_condition>`;       //instruction is executed if R is not 0
1. `if` `not` `(` *R* `)` `<an_instruction_without_condition>`; //instruction is executed if R is 0

Structure of program:
--------------------

Comments:

1. `//`
1. `/* ... */`

- as in C / C++

Labels:

labels are local to thread. form:
```
<unique label name>:
```
(like in C)

Immediate data:

* Dec numbers: 123
* Hex numbers: h'7b
* Bin numbers: b'1111011
* Chars:       'A'
* Strings:     "12aB"  // no ending zero. max up to processor word length.
* Labels:      just a name of label
* Operations between them: `+ - * / % | & ^ ()`
* Continuous list of them: data`,` data`,` data 

immediate data may be added to code as:
```
<immediate_data>;
```

Main structure block - thread:
```
def <name_of_thread>() {

  init {  // "init" is an optional block
    // ...
    // initial values of registers
    // like: r0 = 8;
    // ...
  }

  var {   // "var" is an optional block
    // ...
    // list of names of thread variables.
    // like:
    i;
    j;
    camelCaseVarName;             // variables may be uninitialised
    good_var_name [15][h'1d][33]; // ..and initialised
    // etc
    // ...
  }

  // ...
  // the code of this thread
  // ...

}
```
the first running thread in the program has name "`main`" (as in C)


Aliases:

alias is a preprocessor sintactic sugar to to name registers more understandeable. for example `ip` is an alias of `r7`

1. `\alias` `<name_of_alias>` `=` `<register: r0 -- r7>`;
1. `\unalias` `<name_of_alias>`;

in the code they uses like `\<name_of_alias>`

*Ex*:
```
def foo() {
  init {
    \alias rs232 = r5;
    \rs232 = 0xffffff5; // number of COM port channel
  }

start:
  \rs232 c<- [ip++]; // send "hi" to COM-port
  13,10, "ih";       // little endian words! so bytes should be in backward order!

  r0 <-c \rs232;     // wait for answer, get it to "r0" (but not use)

  ip = z + [ip++];   // go to "start" label
  start;
}
```

