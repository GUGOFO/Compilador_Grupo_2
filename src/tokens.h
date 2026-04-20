// Esse Código é TEMPORÁRIO até que o código do analisador sintático esteja funcionando
#ifndef TOKENS_H
#define TOKENS_H

// LEMBRANDO, está em ordem alfabética na seção de palavras reservadas, caso queira ver dividido de maneira lógica, vá para a documentação.

// Palavras Reservadas
#define TOK_AND 258
#define TOK_BOOL 259
#define TOK_BREAK 260
#define TOK_CASE 261
#define TOK_CHAR 262
#define TOK_CIN 263
#define TOK_CONST 264
#define TOK_CONTINUE 265
#define TOK_COUT 266
#define TOK_DEFAULT 267
#define TOK_DO 268
#define TOK_DOUBLE 269
#define TOK_ELSE 270
#define TOK_EXPORT 271
#define TOK_EXTERN 272
#define TOK_FALSE 273
#define TOK_FLOAT 274
#define TOK_FOR 275
#define TOK_IF 276
#define TOK_INT 277
#define TOK_LONG 278
#define TOK_NAMESPACE 279
#define TOK_NOT 280
#define TOK_NULLPTR 281
#define TOK_OR 282
#define TOK_RETURN 283
#define TOK_SHORT 284
#define TOK_SIZEOF 285
#define TOK_STATIC 286
#define TOK_SWITCH 287
#define TOK_TRUE 288
#define TOK_UNSIGNED 289
#define TOK_USING 290
#define TOK_VOID 291
#define TOK_WHILE 292

// Identificador 
#define TOK_ID 293

// Literais 
#define TOK_INT_LIT 294
#define TOK_FLOAT_LIT 295
#define TOK_STRING_LIT 296
#define TOK_CHAR_LIT 297

// Operadores e Pontuação 

#define TOK_PLUS 298          // +
#define TOK_MINUS 299         // -
#define TOK_MULT 300          // * 
#define TOK_DIV 301           // /
#define TOK_MOD 302           // %
#define TOK_ASSIGN 303        // =
#define TOK_ADD_ASSIGN 304    // +=
#define TOK_SUB_ASSIGN 305    // -=
#define TOK_MULT_ASSIGN 306   // *=
#define TOK_DIV_ASSIGN 307    // /=
#define TOK_MOD_ASSIGN 308    // %=

#define TOK_EQ 309            // ==
#define TOK_NEQ 310           // !=
#define TOK_LT 311            // <
#define TOK_GT 312            // >
#define TOK_LE 313            // <=
#define TOK_GE 314            // >=
#define TOK_LOGIC_AND 315     // &&
#define TOK_LOGIC_OR 316      // ||
#define TOK_LOGIC_NOT 317     // !

#define TOK_OUT 318           // <<
#define TOK_IN 319            // >>
#define TOK_SCOPE 320         // ::

#define TOK_SCOLON 321        // ;
#define TOK_COMMA 322         // ,
#define TOK_LPAREN 323        // (
#define TOK_RPAREN 324        // )
#define TOK_LBRACE 325        // {
#define TOK_RBRACE 326        // }
#define TOK_LBRACKET 327      // [
#define TOK_RBRACKET 328      // ]

#endif