The CakeML parser.

The parsing function should conform to the specification, which is the grammar
in `../semantics/gram`. Here conforming means that if a sequence of tokens has
a parse tree in the grammar, then the function should return that parse tree
(*completeness*). Dually, if the function returns a parse tree, it should be
correct according to the grammar (*soundness*).

The parsing function is one that executes a *Parsing Expression Grammar* (or
PEG). PEGs provide an LL-like attack on input strings, but add the ability to
do significant back-tracking if necessary. The CakeML PEG is specified in the
file cmlPEGScript.sml. The same file includes a proof that the PEG is
well-formed, which means that execution will always terminate (*totality*). As
PEG execution really is a function (`peg_exec` to be precise), we also have
that execution is *deterministic*. (The necessary background theory of PEGs
is in the main HOL distribution.)

[cmlPEGScript.sml](cmlPEGScript.sml):
Definition of the PEG for CakeML.
Includes a proof that the PEG is well-formed.

[cmlParseScript.sml](cmlParseScript.sml):
Definition of the overall parsing functions that go from tokens to abstract
syntax trees. In other words, these include calls to the functions in
`../semantics/cmlPtreeConversion`.

[fromSexpScript.sml](fromSexpScript.sml):
Definitions of functions for conversion between an S-expression encoding of
the CakeML abstract syntax and the abstract syntax type itself.

[lexer_implScript.sml](lexer_implScript.sml):
Definition of the lexer: code for consuming tokens until a top-level
semicolon is found (semicolons can be hidden in `let`-`in`-`end` blocks,
structures, signatures, and between parentheses).

[proofs](proofs):
Soundness and completeness proofs for the CakeML PEG.

[tests](tests):
Tests for the lexer and parser.
