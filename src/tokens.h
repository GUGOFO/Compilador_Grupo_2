// Esse Código é TEMPORÁRIO até que o código do analisador sintático esteja funcionando
#ifndef TOKENS_H
#define TOKENS_H

// Palavras Reservadas
#define TOK_AND 258
#define TOK_BOOL 259
#define TOK_BREAK 260
#define TOK_CASE 261
#define TOK_CHAR 262
#define TOK_CIN 263
#define TOK_CONTINUE 264
#define TOK_COUT 265
#define TOK_DEFAULT 266
#define TOK_DO 267
#define TOK_DOUBLE 268
#define TOK_ELSE 269
#define TOK_FALSE 270
#define TOK_FLOAT 271
#define TOK_FOR 272
#define TOK_IF 273
#define TOK_INT 274
#define TOK_LONG 275
#define TOK_NOT 276
#define TOK_NULLPTR 277
#define TOK_OR 278
#define TOK_RETURN 279
#define TOK_SHORT 280
#define TOK_SIZEOF 281
#define TOK_SWITCH 282
#define TOK_TRUE 283
#define TOK_VOID 284
#define TOK_WHILE 285

// Identificador 
#define TOK_ID 286

// Literais 
#define TOK_INT_LIT 287
#define TOK_FLOAT_LIT 288
#define TOK_STRING_LIT 289
#define TOK_CHAR_LIT 290

// Operadores e Pontuação 
#define TOK_PLUS 291          // +
#define TOK_MINUS 292         // -
#define TOK_MULT 293          // * 
#define TOK_DIV 294           // /
#define TOK_MOD 295           // %
#define TOK_ASSIGN 296        // =
#define TOK_ADD_ASSIGN 297    // +=
#define TOK_SUB_ASSIGN 298    // -=
#define TOK_MULT_ASSIGN 299   // *=
#define TOK_DIV_ASSIGN 300    // /=
#define TOK_MOD_ASSIGN 301    // %=

#define TOK_EQ 302            // ==
#define TOK_NEQ 303           // !=
#define TOK_LT 304            // <
#define TOK_GT 305            // >
#define TOK_LE 306            // <=
#define TOK_GE 307            // >=
#define TOK_LOGIC_AND 308     // &&
#define TOK_LOGIC_OR 309      // ||
#define TOK_LOGIC_NOT 310     // !

#define TOK_OUT 311           // <<
#define TOK_IN 312            // >>
#define TOK_SCOPE 313         // ::

#define TOK_SCOLON 314        // ;
#define TOK_COMMA 315         // ,
#define TOK_LPAREN 316        // (
#define TOK_RPAREN 317        // )
#define TOK_LBRACE 318        // {
#define TOK_RBRACE 319        // }
#define TOK_LBRACKET 320      // [
#define TOK_RBRACKET 321      // ]

#endif