FairyML is forked from The CakeML project: https://cakeml.org
======================================

The objective of FairyML is to slim down CakeML to just the compiler and repl for ease of understanding and quicker building.

CakeML is a verified implementation of a significant subset of
Standard ML.

The source and proofs for CakeML are developed in the [HOL4 theorem
prover](http://hol-theorem-prover.org). We use the latest development
version of [HOL4](https://github.com/HOL-Theorem-Prover/HOL), which we
build on [PolyML 5.7.1](http://www.polyml.org).
Example build instructions can be found in
[build-instructions.sh](build-instructions.sh).

Building all of CakeML (including the bootstrapped compiler and its proofs)
requires significant resources. [Built copies](https://cakeml.org/download) of
the compiler and resource usage for our
[regression tests](https://cakeml.org/regression.cgi) are online.

The [master](../../tree/master) branch contains the latest development
version of CakeML. See the [version2](../../tree/version2) or
[version1](../../tree/version1) branch for previous versions.

Directory structure
-------------------

[COPYING](COPYING):
CakeML Copyright Notice, License, and Disclaimer.

[basis](basis):
Contains the beginnings of a standard basis library for CakeML,
similar to the standard basis library of SML.

[build-instructions.sh](build-instructions.sh):
This file describes how to install Poly/ML, HOL and CakeML.

[characteristic](characteristic):
A verified CakeML adaption of Arthur Charguéraud's "Characteristic
Formulae for the Verification of Imperative Programs"

[compiler](compiler):
A verified compiler for CakeML, including:
 - lexing and PEG parsing,
 - type inference,
 - compilation to ASM assembly language, and,
 - code generation to x86, ARM, and more.

[cv_translator](cv_translator):
Translator to cv type used by cv_compute

[developers](developers):
This directory contains scripts for automating routine tasks, e.g., for
generating README.md files.

[how-to.md](how-to.md):
This document introduces how to use the CakeML compiler, providing in
particular:

- a description of how to invoke the CakeML compiler,
- a list of how CakeML differs from SML and OCaml, and,
- a number of small CakeML code examples.

[misc](misc):
Auxiliary files providing glue between a standard HOL installation
and what we want to use for CakeML development.

[semantics](semantics):
The definition of the CakeML language.
The directory includes definitions of:
 - the concrete syntax,
 - the abstract syntax,
 - big step semantics (both functional and relational),
 - a small step semantics,
 - the semantics of FFI calls, and,
 - the type system.

[translator](translator):
A proof-producing translator from HOL functions to CakeML.

[unverified](unverified):
Various unverified tools, e.g. tools for converting OCaml to CakeML
and an SML version of the CakeML register allocator.
