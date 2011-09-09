%{
#include<stdio.h>
#include<string.h>

#define VOID 0
#define INTEGER 1
#define BOOLEAN 2

#define GT 'g'
#define LT 'l'
#define GE 'G'
#define LE 'L'
#define EQ 'E'
#define NE 'N'
#define VAR 'v'
#define CON 'c'
#define WHILE 'w'
#define IFELSE 'i'
#define READ 'R'
#define WRITE 'W'


struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3);
int traverse(struct node* t);

%}

%union{	 	
	struct node{
	  	int TYPE; // VOID - for statements, INT - for integer constants and operators, BOOL - for TRUE, FALSE and log and relational operators.
		char NODETYPE; // + - / * %  = GT LT GE LE EQ NE VAR CON WHILE IFELSE READ WRITE 
	 	char* NAME; // For Identifiers/Functions
		int VALUE; // for constants
		struct node *ARGLIST; // List of arguments for functions
		struct node *P1, *P2, *P3; /* Maximum of three subtrees (3 required for IF THEN ELSE */
		struct node *GENTRY; // For global identifiers/functions
		struct node *LENTRY; // For Local variables
        }*n;
}

%token <n> NUM 
%left '-' '+'
%left '*' '/' '%'
%left NEG   
%type <n>  expr 
%type <n> '+' '-' '*' '/' '%'


  
 
%%
input:    
          	| input pgm
		  ;

pgm:		'\n'			
		|
		expr '\n' 	{
				 traverse($1); printf("\n");main();
				}
		;
		
expr:		expr '+' expr 	{ 
				  $$ = makeTree($2, $1, $3, NULL);
				}
		|
		expr '-' expr 	{
				  $$ = makeTree($2, $1, $3, NULL);
				}
		|
		expr '*' expr	{
				  $$ = makeTree($2, $1, $3, NULL);
				}	
		|
		expr '/' expr	{
				  $$ = makeTree($2, $1, $3, NULL);
				}
		|
		expr '%' expr	{
				  $$ = makeTree($2, $1, $3, NULL);
				}
		|
		'('expr')'	{$$=$2;}
		|
		'-' expr  %prec NEG {	$$ = makeTree($1, NULL, $2, NULL);}
		|
		NUM		{
				 $$=$1;
				}
		;	
			
			
%%

int main(void)
  { 
	printf("\n >>> ");
	return yyparse();
	}

struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3)
{ 
 	struct node* res = parent;
	res->P1=P1;
	res->P2=P2;
	res->P3=P3;
	return res;
}	


int traverse(struct node* t)
{ 
 if(t!=NULL)
  {	if(t->NODETYPE!=CON) printf("(");
	traverse(t->P1);
	if(t->NODETYPE!=CON)
	printf("%c",t->NODETYPE);
	else
	printf("%d",t->VALUE);
	traverse(t->P2);	 
	if(t->NODETYPE!=CON) printf(")");
  }
  return 1;

}

int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}




