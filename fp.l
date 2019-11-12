%option noyywrap

%{
#include <stdlib.h>
#include <string.h>
#include "fp.tab.h"
/*#include "fpnode.h"*/
/*#include "parser.h"*/
%}

separator [ \t\n\r]+
number 0|[1-9][0-9]*|-[1-9][0-9]*
id [a-z]([a-z]|[0-9]'-')*


%%
{separator}  {;}
"if"		{return TOKEN_IF;}
[*/+\-<>=()]	{return *yytext;}
"mod"		{return MOD;}
"and"		{return AND;}
"or"		{return OR;}
"not"		{return NOT;}
"define"	{return DEF;}
"fun"		{return FUN;}
"print-num"	{return PN;}
"print-bool" {return PB;}

"#t"		{yylval.boolean = 1; return TOKEN_BOOL;}
"#f"		{yylval.boolean = 0; return TOKEN_BOOL;}

{number}	{yylval.ival = atoi(yytext); return TOKEN_NUMBER;}
{id}		{yylval.name = strdup(yytext); return TOKEN_ID;}

.			{return *yytext;}

%%
