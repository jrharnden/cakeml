This directory applies the translator to the compiler in order to
produce a deep embedding of the entire shallowly embedded compiler.
The translator is proof-producing. This means that each deep embedding
comes with a certificate theorem that relates the deep embedding to
the original shallow embedding.

[basis_defProgScript.sml](basis_defProgScript.sml):
Translate the basis library term.

[compiler64ProgScript.sml](compiler64ProgScript.sml):
Finish translation of the 64-bit version of the compiler.

[decProgScript.sml](decProgScript.sml):
Translation of CakeML source AST

[decodeProgScript.sml](decodeProgScript.sml):
Translate the compiler's state decoder.

[inferProgScript.sml](inferProgScript.sml):
Translate the compiler's type inferencer.

[inliningLib.sml](inliningLib.sml):
Stuff used for manual inlining of encoders

[lexerProgScript.sml](lexerProgScript.sml):
Translate the compiler's lexer.

[parserProgScript.sml](parserProgScript.sml):
Translate the compiler's parser.

[printingProgScript.sml](printingProgScript.sml):
Translate the pretty printing functions for the REPL

[reg_allocProgScript.sml](reg_allocProgScript.sml):
Translate the compiler's register allocator.

[to_bviProgScript.sml](to_bviProgScript.sml):
Translate the backend phase from BVL to BVI.

[to_bvlProgScript.sml](to_bvlProgScript.sml):
Translate the backend phase from closLang to BVL.

[to_closProgScript.sml](to_closProgScript.sml):
Translate the backend phase from flatLang to closLang.

[to_dataProgScript.sml](to_dataProgScript.sml):
Translate the backend phase from BVI to dataLang.

[to_flatProgScript.sml](to_flatProgScript.sml):
Translate backend phases up to and including flatLang.

[to_target64ProgScript.sml](to_target64ProgScript.sml):
Translate the final part of the compiler backend for 64-bit targets.

[to_word64ProgScript.sml](to_word64ProgScript.sml):
Translate the data_to_word part of the 64-bit compiler.

[x64ProgScript.sml](x64ProgScript.sml):
Translate the x64 instruction encoder and x64-specific config.
