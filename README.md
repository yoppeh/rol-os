# rol-software
ROL OS

This is the ROL OS. It is written for [CA65](https://cc65.github.io).

## ROL OS Programming Guidelines

1. All public subroutines assume native mode upon entry.
2. All public subroutines return in native mode.
3. All public subroutines assume 16-bit accumulator/memory and index 
registers upon entry.
4. All public subroutines return with 16-bit accumulator/memory and index registers.
5. All public subroutines preserve all processor registers, except the flags.
6. ROLOS defines 6 32-bit pseudo-registers in page 0: r0, r1, r2, r3, r4 and r5. There is also a 16-bit software stack pointer ss.
7. All public subroutines preserve all pseudo-registers unless the subroutine returns a value, in which case it will be returned in a pseduo-register.
8. Return values are generally placed in r0. Any byte of r0 not used to return a value will be preserved. See the comments in the code for a subroutine to confirm where any return value is placed and how many bytes it is.
9. Private subroutines may or may not follow any of the above rules, check the comments in the code for the subroutine.