# ACORN 128 bit Authenticated Encryption and Decription

This repository contains verilog implementation of ACORN-128 bit lightweight authenticated encryption and decryption. 

Authenticated Cipher with Optimal Randomness is a stream cipher that provides both encryption and message authentication. It is designed to be lightweight yet secure, making it ideal for low power applications.

## Specifications:

* Key size: 128 bits
* IV (Nonce): 128 bits
* Tag size: 128 bits
* State size: 293 bits

## Phases:

1. Initialization
2. Associated Data Processing
3. Encryption
4. Finalization
5. Verification


### File Structure

```
Makefile
acorn128_top.v
initialization.v
associated_process.v
encryption.v
finalization.v
state_update128.v
ch_fn.v
maj_fn.v
fbk128.v
ksg128.v
```

## How To Run

Type the following on the command window you have Icarus Verilog for compilation.

```
make tb
```

## References

[] https://competitions.cr.yp.to/round3/acornv3.pdf
