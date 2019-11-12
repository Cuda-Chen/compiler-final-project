%code requires {
	enum nodeType{
		integer,
		boolean,
		variable,
		function
		};

	struct node {
		enum nodeType T;

		int value;
		int b;
		char* cname;
		};

}
%error-verbose
%{
#define YYDEBUG 1
#include <stdlib.h>
#include <string.h>
#include <map>


/*typedef enum {
	integer, 
	bean,
	variable,
	function, 
	} nodeType;*/
	


/*typedef struct {
	nodeType type;
	
	int value;
	char* cname;
	int b;
	} node;	*/
/*typedef struct node {
	int value;
	char* cname;
	int b;
};*/

int yylex(void);	
void yyerror(const char* const message);	

struct classcomp {
	bool operator() (char* str, char* str1) const
	{return strcmp(str, str1) < 0;}
};
static std::map<char*, int, classcomp> vars;
%}

%union {
	int ival;
	char* name;
	int boolean;
	
	struct node N;

	/*struct {
		enum
	        {
			integer,
			bean,
			variable,
			function
		} type;

		type T;
		
		int value;
		int b;
		char* cname;
	} N;*/
}

%token<ival> TOKEN_NUMBER
%token<name> TOKEN_ID
%token<boolean> TOKEN_BOOL
%type<N> exp def_stmt print_stmt variable num_op logical_op fun_exp fun_call if_exp plus_op mul_op and_op or_op equal_op

%token TOKEN_IF PN PB MOD AND OR NOT DEF FUN
%start program

%%

program: stmts
	;
stmts: 	stmt
	| stmts stmt
	;
stmt:	exp
	| def_stmt
	| print_stmt
	;
print_stmt:	'(' PN exp ')' {if($3.T == boolean)
					yyerror("Type error");
				printf("%d\n", $3.value);}
	| '(' PB exp ')'	{if(($3.b == 1) && ($3.T == boolean))
					printf("%s\n", "#t");
				else if(($3.b == 0) && ($3.T == boolean))
					printf("%s\n", "#f");
				else
					yyerror("Type error");}
	;
exp:	TOKEN_BOOL {$$.b = $1; $$.T = boolean;}
	| TOKEN_NUMBER {$$.value = $1; $$.T = integer;}
	| variable
	| num_op
	| logical_op
	| fun_exp
	| fun_call
	| if_exp
	;
num_op:	'(' plus_op  ')' {$$.value = $2.value; $$.T = $2.T;}
	| '(' '-' exp exp ')'			 {if(($3.T == boolean) || ($4.T == boolean))
							yyerror("Type error");
						$$.value = $3.value - $4.value; $$.T = $3.T;}
	| '(' mul_op  ')'   {$$.value = $2.value; $$.T = $2.T;}			
	| '(' '/' exp exp ')'			 {if(($3.T == boolean) || ($4.T == boolean))
							yyerror("Type error");
						$$.value = $3.value / $4.value; $$.T = $3.T;}
	| '(' MOD exp exp ')'			 {if(($3.T == boolean) || ($4.T == boolean))
							yyerror("Type error");
						$$.value = $3.value % $4.value; $$.T = $3.T;}
	;
plus_op: plus_op exp	{if(($1.T == boolean) || ($2.T == boolean))
				yyerror("Type error");
			$$.value = $1.value + $2.value; $$.T = $2.T;}
	| '+' exp exp   {if(($2.T == boolean) || ($3.T == boolean))
				yyerror("Type error");
			$$.value = $2.value + $3.value; $$.T = $2.T;}
	;
mul_op:  mul_op exp	{if(($1.T == boolean) || ($2.T == boolean))
				yyerror("Type error");
			$$.value = $1.value * $2.value; $$.T = $2.T;}
	| '*' exp exp   {if(($2.T == boolean) || ($3.T == boolean))
				yyerror("Type error");
			$$.value = $2.value * $3.value; $$.T = $2.T;}
	;

logical_op:	'(' and_op  ')' {$$.b = $2.b; $$.T = $2.T;}
	| '(' or_op ')'		{$$.b = $2.b; $$.T = $2.T;}
	| '(' NOT  exp ')'	{if($3.T != boolean)
					yyerror("Type error");
				$$.b = !($3.b); $$.T = $3.T;}
	| '(' '>' exp exp ')'   {if(($3.T == boolean) || ($4.T == boolean))
					yyerror("Type error");
				$$.b = $3.value > $4.value; $$.T = boolean;}
	| '(' '<' exp exp ')'	{if(($3.T == boolean) || ($4.T == boolean))
					yyerror("Type error");
				$$.b = $3.value < $4.value; $$.T = boolean;}
	| '(' equal_op ')'	{$$.b = $2.b; $$.T = $2.T;}
	;
and_op:	and_op exp		{if(($1.T == integer) || ($2.T == integer))
					yyerror("Type error");
				$$.b = $1.b && $2.b; $$.T = $2.T;}
	| AND exp exp		{if(($2.T == integer) || ($3.T == integer))
					yyerror("Type error");
				$$.b = $2.b && $3.b; $$.T = $2.T;}
	;
or_op:  or_op exp		{if(($1.T == integer) || ($2.T == integer))
					yyerror("Type error");
				$$.b = $1.b || $2.b; $$.T = $2.T;}
	| OR exp exp		{if(($2.T == boolean) || ($3.T == integer))
					yyerror("Type error");
				$$.b = $2.b || $3.b; $$.T = $2.T;}
	;
equal_op:	equal_op exp	{if($2.T == boolean)
					yyerror("Type error");
				$$.b = $1.value == $2.value; $$.T = boolean;}
	| '=' exp exp		{if(($2.T == boolean) || ($3.T == boolean))
					yyerror("Type error");
				$$.b = $2.value == $3.value; $$.T = boolean;}
	;

def_stmt:	'(' DEF  variable exp ')' {$$.value = vars[$3.cname] = $4.value;}
	;
variable:	TOKEN_ID	{if(vars.find($1) != vars.end())
					$$.value = vars[$1];
				$$.cname = $1; $$.T = variable;}
	;

fun_exp:	'(' FUN  '(' TOKEN_ID ')' exp ')' {;}
	| '(' FUN '(' exp TOKEN_ID ')' exp ')' {;}
	| '(' FUN '(' ')' exp ')' {;}
	;
fun_call:	'(' fun_exp exp ')' {;}
	| '(' TOKEN_ID exp ')' {;}
	;
if_exp:	'(' TOKEN_IF exp exp exp ')' {if($3.b) $$ = $4;
								 else $$ = $5;}
	;
	
%%

#include <stdlib.h>
#include <stdio.h>

void yyerror(const char* const message)
{
	fprintf(stderr, "%s\n", message);
	exit(1);
}

int main()
{
	yydebug = 0;
	//
	yyparse();
}
