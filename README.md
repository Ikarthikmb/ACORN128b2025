# ACORN-128 Cryptographic Cipher
The core of this repository is the ACORN-128, which is explicitly identified as a cryptographic cipher


ACORN-128 is a lightweight authenticated encryption with associated data (AEAD) algorithm. It was a finalist in the CAESAR (Competition for Authenticated Encryption: Security, Applicability, and Robustness) competition and is specifically optimized for hardware efficiency, utilizing a bit-oriented stream cipher approach.

The repository is organized into the following components:

- `rtl/`: Contains the Verilog source code for the Register-Transfer Level (RTL) implementation of the cipher.
- `sim/`: Contains simulation files and testbenches used to verify the design.
- `Makefile`: A script used to automate the build and simulation processes.
- `example-1.txt`: provides example test vectors or data for use during simulation

**Cipher Type**: Cryptographic Cipher ACORN-128

### Parameters

Parameters | Specification 
---| --- 
Key Size | 128-bit
Nonce (IV) Size | 128-bit
Tag Size (t) | 128-bit (supports 64 to 128)

The security goals of ACORN are given in below table. In ACORN, each key, IV pair is used to protect only one message. If verification fails, the new tag and the decrypted ciphertext should not be given as output. [Verified]

Name | Encryption | Authentication
 --- | --- | ---
ACORN-128 | 128-bit | 128-bit

### Cipher Architecture and Internal State

The internal state of ACORN-128 comprises 293 bits, denoted as S0,S1,…,S292. From a hardware architect's perspective, the choice of 293 bits is critical; because 293 is a prime number, the overall tap distance is ensured to be coprime to all internal feedback tap distances within the constituent registers. This property is fundamental to the cipher's resistance against various cryptographic attacks.

The state is organized into six concatenated Linear Feedback Shift Registers (LFSRs) and a specialized 4-bit input register (bits 289–292). This 4-bit register ensures that the state update function remains invertible for a known key, which is vital for maintaining the period of the keystream and preventing initialization-based differential attacks.

The simulation can be triggered using the Makefile:

```
make tb
```

**Verification Results**

```
iverilog -o sim/tb.out -g2012 rtl/associated_process.v rtl/encryption.v rtl/finalization.v rtl/ksg128.v rtl/state_update128.v rtl/acorn128_top.v rtl/ch_fn.v rtl/fbk128.v rtl/initialization.v rtl/maj_fn.v sim/acorn128_tb.v 
vvp sim/tb.out
============================================================
VCD info: dumpfile acorn128_tb.vcd opened for output.
[INFO] Pre Setup Completed
[INFO] STARTING ENCRYPTION ...
[INFO] Plain :      Hello ACORN
[INFO] Key   : 12312341234512345612345671234567
[INFO] IV    : 11111111111111111111111111111111
[INFO] AD    : 44455556666677777788888883332222

[INFO] ENCRYPTION READY
[INFO] Cipher: 083ef7ae14e91f61a0d45393f274047c
[INFO] Tag   : 85a34f3d62e97cc2cb097bad29e4c1e4

[INFO] Cipher Verification ...

[INFO] Tag Verified

[INFO] Encryption Verified
============================================================
```
