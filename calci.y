%{
#include<stdio.h>
#include<string.h>
#include<math.h>

%}

%token NUM
%left '-' '+'
%left '*' '/'
%left NEG     


  
 
%%
input:    
          | input pgm
		  ;

pgm:	'\n'			
		|
		expr '\n' 	{printf("%d\n>>", $1); }
		;
		
expr:	expr '+' expr {$$=$1+$3;}
		|
		expr '-' expr {$$=$1-$3;}
		|
		expr '*' expr	{$$=$1*$3;}	
		|
		expr '/' expr	{$$=$1/$3;}
		|
		'-' expr  %prec NEG { $$ = -$2;        }
        |  
        '(' expr ')'        { $$ = $2;   }
		|
		NUM		{$$=$1;}
		;	
			
			
%%

int main(void)
  { 
	printf(">>");
	return yyparse();
	}
	


int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}









//Shifterror
/*
pgm:				
		|		
		expr1 '\n' 	{printf("%d\n", $1); return(0);}
		;
expr1:		expr1 '+' expr1 {$$=$1+$3;}
		|
		expr1 '-' expr1 {$$=$1-$3;}
		|
		expr1 '/' expr1 {$$=$1/$3;}
		|
		expr1 '*' expr1 {$$=$1*$3;}
		|
		'('expr1')' {$$=$2;}
		|
		NUM	{$$=$1;}
		;

*/
