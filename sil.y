%{
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

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
#define arr 'a'
#define con 'c'
#define whileloop 'w'
#define ifelse 'i'
#define r 'R'
#define w 'W'

int regcount = 0;
int adrcount = 0;
int ifcount = 0;
int whilecount = 0;


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
	int *BINDING; 		// Address of the Identifier in Memory
	struct Lsymbol *NEXT;	// Pointer to next Symbol Table Entry */
}*Lhead;

struct Lsymbol *Llookup(char* NAME);
void Linstall(char* NAME, int TYPE);

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

%token <n> NUM BNUM ID WRITE READ  RELOP
%token IF ENDIF WHILE DO ENDWHILE BEG END BOOL INT DECL ENDDECL MAIN THEN ELSE
%left RELOP
%left '-' '+'
%left '*' '/' '%'
%left NEG   
%type <n>  expr  stmt Stmtlist
%type <n> '+' '-' '*' '/' '%' '='


  
 
%%
pgm:		GDefblock  Mainblock    	{ 
						traverse(Thead); 
						FILE *fp;
						fp=fopen("sim","a");
						fprintf(fp,"HALT\n");
						fclose(fp);	
						exit(1); 
						}
		|
		Mainblock			{  
						traverse(Thead); 
						FILE *fp;
						fp=fopen("sim","a");
						fprintf(fp,"HALT\n");
						fclose(fp);
						}
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
		ID'['NUM']'				{       Ginstall($1->NAME, typeval, $3->VALUE, NULL);  }
		;

Mainblock:	INT MAIN '('')'  Fblock 	{   }
		;
		
Fblock:		 LDefblock Stmtblock      	 {  }
		|
		Stmtblock			{  }
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
		
LId:		ID					{   Linstall($1->NAME, typeval); 
							}		
		;

Stmtblock:	BEG Stmtlist ';' END			{ }
		|
		BEG END					{ }		
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

stmt:		ID '=' expr				{ 
							  struct Lsymbol* temp = Llookup($1->NAME);
							  if(temp==NULL) 
							   {
							     struct Gsymbol* gtemp = Glookup($1->NAME);
							      if(gtemp==NULL || gtemp->SIZE!=1) yyerror("Undefined Variable");
							      else
							       {
							     	 $1->TYPE = gtemp->TYPE;
							       }
							   }
							  else 
							   {
							     $1->TYPE = temp->TYPE;
							    }

							  if($1->TYPE == $3->TYPE) 
							 	 $$ = makeTree($2, $1, NULL, $3);
							  else
							  	{ yyerror("Type Mismatch");}
						
							}
		|
		ID '[' expr ']' '=' expr		{ 
							  struct Gsymbol* gtemp = Glookup($1->NAME);
							  if(gtemp==NULL || gtemp->SIZE==1) yyerror("Undefined Array");
							  else
							       {
							     	 $1->TYPE = gtemp->TYPE;
							       }
							 if($1->TYPE == $6->TYPE) 
							 	{ $$ = makeTree($5, $1, $3, $6);
							 	}
							  else
							  	yyerror("Type Mismatch"); 	
		
							}
		|
		WRITE '('expr ')'			{ 
							  
							  $$ = makeTree($1, $3, NULL, NULL);
		
							}
		|
		READ '(' ID ')' 			{ 
							  struct Lsymbol *temp = Llookup($3->NAME);
							  if(temp==NULL)
							   { struct Gsymbol *gtemp = Glookup($3->NAME);
							     if(gtemp==NULL && gtemp->SIZE!=1)
							      {
							       yyerror("Undefined variable in READ");
							      }
							     else
							       $$ = makeTree($1, $3, NULL, NULL);
							    }
							  else
							      $$ = makeTree($1, $3, NULL, NULL);
							}
		|
		READ '(' ID '[' expr ']' ')' 		{ 
					 		  struct Gsymbol *gtemp = Glookup($3->NAME);
					 		  if(gtemp == NULL && gtemp->SIZE==1)
					 		   {
					 		     yyerror("Undefined array in READ");
					 		   }
					 		  else
					 		   $$ = makeTree($1, $3, $5, NULL);
							}
		|
		IF expr  THEN Stmtlist ';' ELSE Stmtlist ';' ENDIF {
							   $$ = makeNode1(VOID, 'i', NULL, 0);
							   $$ = makeTree($$, $2, $4, $7);
							}
		|
		IF expr  THEN Stmtlist ';'  ENDIF     {
							   $$ = makeNode1(VOID, 'i', NULL, 0);
							   $$ = makeTree($$, $2, $4, NULL);
							}
		|
		WHILE expr DO Stmtlist';' ENDWHILE		{	$$ = makeNode1(VOID, 'w', NULL, 0);
								$$ = makeTree($$, $2, $4, NULL);
		
							}		
		;

expr:		expr '+' expr 			{ if( $1->TYPE == $2->TYPE && $2->TYPE == $3->TYPE )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	{ yyerror("Type Mismatch"); }
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
		expr RELOP expr			{
						  if( $1->TYPE == $3->TYPE && $1->TYPE == INTEGER )
						   	$$ = makeTree($2, $1, $3, NULL);
						  else
						  	yyerror("Type Mismatch for Boolean Operator");
						  
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
		 				  $$ = makeTree($1,$3,NULL,NULL);
		 				  struct Gsymbol* gtemp = Glookup($$->NAME);
					      	  if(gtemp==NULL) yyerror("Undefined Variable1");
					          else
					           {
					       		 $$->GENTRY = gtemp;
					     	 	 $$->TYPE = gtemp->TYPE;
					     	   }
						  
						}
		|
		NUM				{
				 		$$=$1;
						}
		|
		BNUM				{
						$$=$1; 
						$$->TYPE = BOOLEAN;
						}
					
%%

int main(void)
  { 
	FILE *fp;
	fp = fopen("sim","w");
	fprintf(fp,"START\n");
	fclose(fp);
	yyparse();
    	return 0;
	
	}


struct node* makeNode1(int type, char nodetype, char* name, int value){
		struct node* res = malloc(sizeof(struct node));
		res->TYPE=type;
		res->NODETYPE=nodetype;
		res->NAME=name;
		res->VALUE = value;
		res->ARGLIST = NULL;
		res->P1	     = NULL;
		res->P2      = NULL;
		res->P3      = NULL;
		res->GENTRY  = NULL;
		res->LENTRY  = NULL;
		return res;
}

struct node* makeTree( struct node* parent, struct node* P1, struct node* P2, struct node* P3)
{ 
 	struct node* res = parent;
	res->P1 = P1;
	res->P2 = P2;
	res->P3 = P3;
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
	   res->BINDING = malloc(sizeof(int)*SIZE);
	   Ghead = res;
 }

void Linstall(char* NAME, int TYPE)
 {
	   struct Lsymbol* res = malloc(sizeof(struct Lsymbol));
	   res->NAME = NAME;
	   res->TYPE = TYPE;
	   res->BINDING = malloc(sizeof(int));
	   res->NEXT = Lhead;
	   Lhead = res;
 }
 
struct Gsymbol* Glookup(char* NAME)
 {
	   struct Gsymbol* res;
	   res = Ghead;
	   while(res != NULL)
	    {
	      if(strcmp(res->NAME, NAME) == 0)
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
	   while(res != NULL)
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
	  	{	res = traverse(t->P1)+traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"ADD R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*-------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '-')
	  	{	res = traverse(t->P1)-traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"SUB R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '*')
	  	{	res = traverse(t->P1)*traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"MUL R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '/')
	  	{	res = traverse(t->P1)/traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"DIV R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == '%')
	  	{	res = traverse(t->P1)/traverse(t->P2);
	  	
	  		/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"MOD R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	}
	  	else if(t->NODETYPE == gt)
  		{	if(traverse(t->P1) > traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"GT R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == lt)
  		{	if(traverse(t->P1) < traverse(t->P2))
  			   res = T;
  			else  
  			   res =  F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"LT R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == le)
  		{	if(traverse(t->P1) <= traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"LE R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == ge)
  		{	if(traverse(t->P1) >= traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"GE R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == eq)
  		{	if(traverse(t->P1) == traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"EQ R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == ne)
  		{	if(traverse(t->P1) != traverse(t->P2))
  			   res = T;
  			else  
  			   res =  F;
  			/*--------------For Code Generation-----------------------*/
	  		FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"NE R%d,R%d\n", regcount-2, regcount-1);
			regcount--;
			fclose(fp);
			/*--------------------------------------------------------*/
  		}
	  	else if(t->NODETYPE == 'R')
	  	  {
	  	   	 
	  	   	   struct Lsymbol* check = Llookup(t->P1->NAME);
	  		   if(check==NULL)
	  		    {
	  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
	  		      if(gcheck==NULL)
	  		      	yyerror("Undefined Variable in read statement");
			      else
			       { 
			        if(t->P2 == NULL)
			          {
			              if(gcheck->TYPE==BOOLEAN) 
			             	{ char bval[6];
			             	  scanf("%s", bval );
			             	  if(strcmp(bval,"TRUE")) 
			             	  	*(gcheck->BINDING) = 1;
			             	  else if(strcmp(bval,"FALSE")) 
			             	  	*(gcheck->BINDING) = 0;
			             	  else
			             	        yyerror("Unrecognized constant");
			             	}
			             else
			             	scanf("%d",gcheck->BINDING);
			           }
			        else
			         {
			           int pos = traverse(t->P2);
			           if(pos >= (gcheck->SIZE) || pos<0 )
			           	yyerror("Exceeding size of array");
			           else
			             {
			             	if(gcheck->TYPE==BOOLEAN) 
			             	{ char bval[6];
			             	  scanf("%s", bval );
			             	  if(strcmp(bval,"TRUE")==0) 
			             	  	*(gcheck->BINDING+pos) = 1;
			             	  else if(strcmp(bval,"FALSE")==0) 
			             	  	*(gcheck->BINDING+pos) = 0;
			             	  else
			             	        yyerror("Unrecognized constant");
			             	}
				        else
				     	   scanf("%d",(gcheck->BINDING+pos));			               
			             }
			          }
			       } 
			    }
			   else
			   {     if(check->TYPE==BOOLEAN) 
			             	{ char bval[6];
			             	  scanf("%s", bval );
			             	  if(strcmp(bval,"TRUE")==0) 
			             	  	*(check->BINDING) = 1;
			             	  else if(strcmp(bval,"FALSE")==0)
			             	  	*(check->BINDING) = 0;
			             	  else
			             	        yyerror("Unrecognized constant");
			             	}
			      	else
				     	   scanf("%d",(check->BINDING));
			   }
	  	  }	
	  	else if(t->NODETYPE=='=')
	  	 {
	  	 	
	  	 	struct Lsymbol *check = Llookup(t->P1->NAME);
	  	 	if(check==NULL) 	  		
	  	 	    {
	  		      struct Gsymbol* gcheck = Glookup(t->P1->NAME);
	  		      if(gcheck==NULL)
	  		      	yyerror("Undefined Variable in assignment statement");
			      else
			        { 
			        if(t->P2 == NULL)
			        	*(gcheck->BINDING) = traverse(t->P3);
			        else
			         {
			           int pos = traverse(t->P2);
			           if(pos >= (gcheck->SIZE) || pos<0 )
			           	yyerror("Exceeding size of array");
			           else
			             {
			             	*(gcheck->BINDING + pos) = traverse(t->P3);
			             }
			           }   
			         }
			      }
	  	 	else
	  	 	 {
	  	 	   *(check->BINDING) = traverse(t->P3);
	  	 	 }
	  	 }
	  	else if(t->NODETYPE=='W')
	  	  {
	  	   	if(t->P1->TYPE==INTEGER)
	  	   	{  printf("%d\n",traverse(t->P1));
	  	   	}
	  	   	else
	  	   	 {
	  	   	   if(traverse(t->P1)==1)
	  	   	    {	printf("TRUE\n");
	  	   	        
	  	   	     }
	  	   	   else 
	  	   	        printf("FALSE\n");
	  	   	 }
		  	   /*--------------For Code Generation-----------------------*/
			   FILE *fp;
			   fp = fopen("sim","a");
			   fprintf(fp,"OUT R%d\n", regcount-1);
			   regcount--;
			   fclose(fp);
			   /*--------------------------------------------------------*/
	  	  }	
	  	else if(t->NODETYPE=='i')		
	  	  {
	  	     	if(traverse(t->P1)&&t->P1->TYPE==BOOLEAN)
	  	    	  traverse(t->P2); 
	  	    	else 
	  	    	  traverse(t->P3);
	  	  
	  	  }
	  	else if(t->NODETYPE=='w')		
	  	  {
	  	  	while(traverse(t->P1)&&t->P1->TYPE==BOOLEAN)
	  	  	 {
	  	  	  traverse(t->P2); 
	  	  	 }
	  	  
	  	  }
	  	else if(t->NODETYPE=='v') 		
	  	 { 
	  	 	
	  	 	if(t->P1==NULL)
	  	 	{
				if(t->LENTRY!=NULL)
					res = *(t->LENTRY->BINDING);
				else
					res = *(t->GENTRY->BINDING);
			}
			else
			{
			  int pos = traverse(t->P1);
			  if(pos < t->GENTRY->SIZE || pos >= 0)
			   {
			      res = *(t->GENTRY->BINDING + pos);
			   } 
			  
		         }
	  	 	
	  	 }
	  	else if(t->NODETYPE=='c')
	  	 {
	  	 	res = t->VALUE;
			/*--------------For Code Generation-----------------------*/
	  	 	FILE *fp;
			fp = fopen("sim","a");
			fprintf(fp,"MOV R%d,%d\n", regcount, res);
			regcount++;
			fclose(fp);
			/*--------------------------------------------------------*/
	  	 	
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




