%{
#include<stdio.h>
#include<string.h>

#define VOID 0
#define INTEGER 1
#define BOOLEAN 2

#define T 1
#define F 0

#define gt 'g'
#define lt 'l'
#define ge 'G'
#define le 'L'
#define eq 'E'
#define ne 'N'
#define var 'v'
#define con 'c'
#define whileloop 'w'
#define ifelse 'i'
#define r 'R'
#define w 'W'


struct ArgStruct{
	char* ARGNAME;
	char* ARGTYPE;
	struct ArgStruct *NEXTARG;
};

struct Gsymbol {
	char* NAME; 		// Name of the Identifier
	int TYPE; 		// TYPE can be INTEGER or BOOLEAN
	int SIZE; 		// Size field for arrays
	int *BINDING; 		// Address of the Identifier in Memory
	struct ArgStruct* ARGLIST;	// Argument List for functions, AgStruct - name and type of each argument
	struct Gsymbol *NEXT;	// Pointer to next Symbol Table Entry */
}*Ghead;

struct Gsymbol* Glookup(char* NAME);	 // Look up for a global identifier

void Ginstall(char* NAME, int TYPE, int SIZE, struct ArgStruct* ARGLIST); // Installation

struct Lsymbol {
	char *NAME; 		// Name of the Identifier
	int TYPE; 		// TYPE can be INTEGER or BOOLEAN
	int SIZE; 		// Size field for arrays
	int *BINDING; 		// Address of the Identifier in Memory
	struct Lsymbol *NEXT;	// Pointer to next Symbol Table Entry */
}*Lhead;

struct Lsymbol *Llookup(char* NAME);
void Linstall(char* NAME, int TYPE, int SIZE);

struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3);
struct node* makeNode1(int type, char nodetype, char* name, int value);
int traverse(struct node* t);

int typeval;   //For getting type of variable

struct node* Thead;

%}

%union{	 	
	struct node{
	  	int TYPE; // VOID - for statements, INT - for integer constants and operators, BOOL - for TRUE, FALSE and log and relational operators.
		char NODETYPE; // + - / * %  = GT LT GE LE EQ NE VAR CON WHILE IFELSE READ WRITE 
	 	char* NAME; // For Identifiers/Functions
		int VALUE; // for constants
		struct node *ARGLIST; // List of arguments for functions
		struct node *P1, *P2, *P3; /* Maximum of three subtrees (3 required for IF THEN ELSE */
		struct Gsymbol *GENTRY; // For global identifiers/functions
		struct Lsymbol *LENTRY; // For Local variables
        }*n;



}

%token <n> NUM ID WRITE READ GT LT GE LE EQ NE 
%token IF ENDIF WHILE DO ENDWHILE BEG END BOOL INT DECL ENDDECL MAIN THEN ELSE
%left '-' '+'
%left '*' '/' '%'
%left NEG   
%type <n>  expr  stmt Stmtlist
%type <n> '+' '-' '*' '/' '%' '='


  
 
%%
pgm:		GDefblock  Mainblock    	{  traverse(Thead);  }
		;

GDefblock:	DECL GDeflist ENDDECL		{		}	
		;

GDeflist:	   	
		GDecl				{ }
		|
		GDeflist GDecl			{ }
		;

GDecl:		Type GIdlist ';' 		{ }
		;

GIdlist:	GIdlist ',' GId			{ }
		|
		GId
		;

GId:		ID					{  							
								Ginstall($1->NAME, typeval, 1, NULL); 
							}
		|
		ID'['NUM']'				{  Ginstall($1->NAME, typeval, $3->VALUE, NULL);  }
		;

Mainblock:	INT MAIN '('')'  Fblock 	{   }
		;
		
Fblock:		 LDefblock Stmtblock      	 {  }
		;

LDefblock:	DECL LDlist ENDDECL			{ }			  
		;


LDlist:		LDecl					{ }
		|
		LDlist LDecl				{ }				 
		;

LDecl:		Type LIdlist ';'			 { }
		;

Type:		INT					{    typeval=INTEGER; }
		|
		BOOL					{    typeval=BOOLEAN;	}
		;
		
LIdlist:	LIdlist ',' LId				{			}
		|
		LId					{			}
		;
		
LId:		ID					{   Linstall($1->NAME, typeval, 1); 
							}		
		|
		ID'['NUM']'				{  Linstall($1->NAME, typeval, $3->VALUE); }
		;

Stmtblock:	BEG Stmtlist ';' END				
		;

Stmtlist:						{     $$ = NULL;    }
		|	
		stmt					{   	struct node* temp = malloc(sizeof(struct node));
								temp = makeNode1(VOID, 's',NULL, 0);
								$$ = makeTree(temp, $1, NULL, NULL);
							 }
		|
		Stmtlist ';' stmt 			      {  	struct node* temp = malloc(sizeof(struct node));
								temp = makeNode1(VOID, 's',NULL, 0);
								$$ = makeTree(temp, $1, $3, NULL);
							}
		;

stmt:		ID '=' expr				{ if($1->TYPE == $3->TYPE) 
							 	 $$ = makeTree($2, $1, $3, NULL);
							  else
							  	yyerror("Type Mismatch"); 
							}
		|
		ID '[' expr ']' '=' expr		{	
		
							}
		|
		WRITE '('expr ')'			{ 
							  $$ = makeTree($1, $3, NULL, NULL);
		
							}
		|
		READ '(' ID ')' 			{ 
							  $$ = makeTree($1, $3, NULL, NULL);

							}
		;

expr:		expr '+' expr 			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		expr '-' expr 			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		expr '*' expr			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}	
		|
		expr '/' expr			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		expr '%' expr			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch");
						}
		|
		'('expr')'			{ $$=$2;}
		|
		'-' expr  %prec NEG 		{ if( $1->TYPE == $2->TYPE)
						   	$$ = makeTree($1, NULL, $2, NULL);
						  else
						  	yyerror("Type Mismatch");
						  }
		|
		ID				{
						  $$ = $1;
						  struct Lsymbol* temp = Llookup($$->NAME);
						  if(temp==NULL) 
						   {
						     struct Gsymbol* gtemp = Glookup($$->NAME);
						      if(gtemp==NULL) yyerror("Undefined Variable1");
						      else
						       {
						       	 $$->GENTRY = gtemp;
						     	 $$->TYPE = gtemp->TYPE;
						       }
						   }
						  else 
						   { $$->LENTRY = temp;
						     $$->TYPE = temp->TYPE;
						    }
						}
		|
		ID'['expr']'			{
		
						}
		|
		NUM				{
				 		$$=$1;
						}			
%%

int main(void)
  { 
	
	return yyparse();
	}


struct node* makeNode1(int type, char nodetype, char* name, int value){
		struct node* res = malloc(sizeof(struct node));
		res->TYPE=type;
		res->NODETYPE=nodetype;
		res->NAME=name;
		res->VALUE = value;
		res->ARGLIST=NULL;
		res->P1=NULL;
		res->P2=NULL;
		res->P3=NULL;
		res->GENTRY = NULL;
		res->LENTRY = NULL;
		return res;
}

struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3)
{ 
 	struct node* res = parent;
	res->P1=P1;
	res->P2=P2;
	res->P3=P3;
	Thead = res;
	return res;
}
	
void Ginstall(char* NAME, int TYPE, int SIZE, struct ArgStruct* ARGLIST)
 {
	   struct Gsymbol* res = malloc(sizeof(struct Gsymbol));
	   res->NAME = NAME;
	   res->TYPE = TYPE;
	   res->SIZE = SIZE; 
	   res->ARGLIST = ARGLIST; 
	   res->NEXT = Ghead;
	   Ghead = res;
 }

void Linstall(char* NAME, int TYPE, int SIZE)
 {
	   struct Lsymbol* res = malloc(sizeof(struct Lsymbol));
	   res->NAME=NAME;
	   res->TYPE = TYPE;
	   res->SIZE = SIZE;
	   res->NEXT = Lhead;
	   Lhead = res;
 }
 
struct Gsymbol* Glookup(char* NAME)
 {
	   struct Gsymbol* res;
	   res = Ghead;
	   while(res!=NULL)
	    {
	      if(strcmp(res->NAME, NAME)==0)
		 return res;
	      else
		 res = res->NEXT;
	     }
	   return NULL;  
 }

struct Lsymbol* Llookup(char* NAME)
 {
	   struct Lsymbol* res;
	   res = Lhead;
	   while(res!=NULL)
	    {
	      if(strcmp(res->NAME, NAME)==0)
		 return res;
	      else
		 res = res->NEXT;
	     }
	   return NULL;  
 }

int traverse(struct node* t)
{ 
	 
	 if(t!=NULL)
	  {	
	 	int res; 
	  	if(t->NODETYPE=='+')
	  		res = traverse(t->P1)+traverse(t->P2);
	  	else if(t->NODETYPE=='-')
	  		res = traverse(t->P1)-traverse(t->P2);
	  	else if(t->NODETYPE=='*')
	  		res = traverse(t->P1)*traverse(t->P2);
	  	else if(t->NODETYPE=='/')
	  		res = traverse(t->P1)/traverse(t->P2);
	  	else if(t->NODETYPE=='%')
	  		res = traverse(t->P1)%traverse(t->P2);
	  	else if(t->NODETYPE=='R')
	  	  {
	  	   	 
	  	   	   struct Lsymbol* check = Llookup(t->P1->NAME);
	  	   	   printf("%s:",t->P1->NAME);
	  		   if(check==NULL)
	  		    {
	  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
	  		      if(gcheck==NULL)
	  		      	yyerror("Undefined Variable in read statement");
			      else
			       { gcheck->BINDING = malloc(sizeof(int));
			        scanf("%d",gcheck->BINDING); 
			       } 
			    }
			   else
			    {   check->BINDING = malloc(sizeof(int));
			        scanf("%d",check->BINDING); 	
			    }
	  	  }	
	  	else if(t->NODETYPE=='=')
	  	 {
	  	 	int *x = malloc(sizeof(int));
	  	 	*x = traverse(t->P2);
	  	 	struct Lsymbol *check = Llookup(t->P1->NAME);
	  	 	if(check==NULL) 	  		
	  	 	    {
	  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
	  		      if(gcheck==NULL)
	  		      	yyerror("Undefined Variable in read statement");
			      else
			        gcheck->BINDING = x;
			     }
	  	 	else
	  	 	 {
	  	 	   check->BINDING = x;
	  	 	 }
	  	 }
	  	else if(t->NODETYPE=='W')
	  	  {
	  	   	  printf("%d\n",traverse(t->P1));
	  	  }	
	  	else if(t->NODETYPE=='i')		//For if else, to be done!
	  	  {
	  	  
	  	  
	  	  }
	  	else if(t->NODETYPE=='w')		//For while loop to be done!
	  	  {
	  	  
	  	  }
	  	else if(t->NODETYPE=='v')
	  	 {
	  	 	if(t->LENTRY!=NULL)
	  	 		res = *(t->LENTRY->BINDING);
	  	 	else
	  	 		res = *(t->GENTRY->BINDING);
	  	 }
	  	else if(t->NODETYPE=='c')
	  	 {
	  	 	res = t->VALUE;
	  	 }
	  	else if(t->NODETYPE=='s')
	  	 {
	  	 	traverse(t->P1);
	  	 	traverse(t->P2);
	  	 }
	  	else
	  	 {
	  	 	
	  	 	yyerror("Unexpected error!");
	  	 }
	   	return res;
	   }		  	  	
	else
	  	return 0;
}

int yyerror (char *msg) 
   {
 	return fprintf (stderr, "YACC: %s\n", msg);
   }




