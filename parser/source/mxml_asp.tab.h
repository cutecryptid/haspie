/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_MXML_ASP_TAB_H_INCLUDED
# define YY_YY_MXML_ASP_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    OPTAG = 258,
    CLTAG = 259,
    SLASHTAG = 260,
    EQUAL = 261,
    KVOTHE = 262,
    QUES = 263,
    EXCL = 264,
    NOTE = 265,
    OCTA = 266,
    STEP = 267,
    PART_ID = 268,
    REST = 269,
    CHORD = 270,
    ALTER = 271,
    DOCTYPE = 272,
    TEXT = 273,
    NUMBER = 274
  };
#endif
/* Tokens.  */
#define OPTAG 258
#define CLTAG 259
#define SLASHTAG 260
#define EQUAL 261
#define KVOTHE 262
#define QUES 263
#define EXCL 264
#define NOTE 265
#define OCTA 266
#define STEP 267
#define PART_ID 268
#define REST 269
#define CHORD 270
#define ALTER 271
#define DOCTYPE 272
#define TEXT 273
#define NUMBER 274

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 51 "mxml_asp.y" /* yacc.c:1909  */

	int valInt;
	float valFloat;
	char * valStr;

#line 98 "mxml_asp.tab.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_MXML_ASP_TAB_H_INCLUDED  */
