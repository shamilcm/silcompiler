%{
#include<stdio.h>
#include<string.h>
#include<math.h>


struct node{
  	double val;
	char op;
	int flag;
	struct node *l, *r;
};

struct node* makeTree(char op, struct node* left, struct node* right);
struct node* makeLeaf(double val);
int par(struct node* t);

%}

%union{	 	
	double d;
	struct node *n;
}

%token <d> NUM 
%left '-' '+'
%left '*' '/'
%right '^'
%left NEG   
%type <n>  expr 


  
 
%%
input:    
          	| input pgm
		  ;

pgm:		'\n'			
		|
		expr '\n' 	{
				 par($1); printf("\n");main();
				}
		;
		
expr:		expr '+' expr 	{
				 $$ = makeTree('+',$1,$3);
				}
		|
		expr '-' expr 	{
				 $$ = makeTree('-',$1,$3);
				}
		|
		expr '*' expr	{
				 $$ = makeTree('*',$1,$3);
				}	
		|
		expr '/' expr	{
				 $$ = makeTree('/',$1,$3);
				}
		|
		'('expr')'	{$$=$2;}
		|
		'-' expr  %prec NEG {$$=makeTree('-',NULL, $2); }
		|
		expr '^' expr { $$ =  makeTree('^',$1,$3);}		
		|		
		NUM		{
				 $$=makeLeaf($1);
				}
		;	
			
			
%%

int main(void)
  { 
	printf("\n >>> ");
	return yyparse();
	}

struct node* makeTree(char op, struct node* left, struct node* right)
{
	struct node* res = malloc(sizeof(struct node));
	res->op = op ;
	res->flag=0;
	res->l=left;
 	res->r=right;
	return res;
}	

struct node* makeLeaf(double val)
{
	struct node* res = malloc(sizeof(struct node));
	res->val = val;
	res->flag = 1;
	res->l = NULL;
	res->r = NULL;
	return res;

}

int par(struct node* t)
{ 
 if(t!=NULL)
  
  {	if(t->flag==0) printf("(");
	par(t->l);
	if(t->flag==0)
	printf("%c",t->op);
	else
	printf("%.10g",t->val);
	par(t->r);	 
	if(t->flag==0) printf(")");
  }
  return 1;

}

int yyerror (char *msg) {
	return fprintf (stderr, "YACC: %s\n", msg);
	}




