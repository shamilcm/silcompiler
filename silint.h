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

int traverse(struct node* t)
{ 
	 
	 if(t!=NULL)
	  {	
	 	int res; 
	  	if(t->NODETYPE=='+')					
	  	{	res = traverse(t->P1)+traverse(t->P2);

	  	}
	  	else if(t->NODETYPE == '-')
	  	{	res = traverse(t->P1)-traverse(t->P2);
	  	
	  	}
	  	else if(t->NODETYPE == '*')
	  	{	res = traverse(t->P1)*traverse(t->P2);

	  	}
	  	else if(t->NODETYPE == '/')
	  	{	res = traverse(t->P1)/traverse(t->P2);

	  	}
	  	else if(t->NODETYPE == '%')
	  	{	res = traverse(t->P1)/traverse(t->P2);

	  	}
	  	else if(t->NODETYPE == gt)
  		{	if(traverse(t->P1) > traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;

  		}
	  	else if(t->NODETYPE == lt)
  		{	if(traverse(t->P1) < traverse(t->P2))
  			   res = T;
  			else  
  			   res =  F;

  		}
	  	else if(t->NODETYPE == le)
  		{	if(traverse(t->P1) <= traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;

  		}
	  	else if(t->NODETYPE == ge)
  		{	if(traverse(t->P1) >= traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  		}
	  	else if(t->NODETYPE == eq)
  		{	if(traverse(t->P1) == traverse(t->P2))
  			   res = T;
  			else  
  			   res = F;
  		}
  		else if(t->NODETYPE == 'a')
  		{	
  			if(traverse(t->P2) && traverse(t->P1)) 
				res = T;
			else
				res = F;
  		}
  	  	else if(t->NODETYPE == 'o')
  		{	
			if(traverse(t->P2) || traverse(t->P1)) 
				res = T;
			else
				res = F;

  		}
  		else if(t->NODETYPE == 'n')
  		{	if(!traverse(t->P2)) 
  				res = T;
  			else
				res = F;

  		}
	  	else if(t->NODETYPE == ne)
  		{	if(traverse(t->P1) != traverse(t->P2))
  			   res = T;
  			else  
  			   res =  F;
  		}
	  	else if(t->NODETYPE == 'R')
	  	  {
	  	   	 
	  	   	   struct Lsymbol* check = Llookup(t->P1->NAME);
	  		   if(check==NULL)			e			
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
			             	  {	
						*(gcheck->VALUE) = 1;            	  
			             	  }
			             	  else if(strcmp(bval,"FALSE")) 				
			             	  {	
						*(gcheck->VALUE) = 0;
			             	  }
			             	  else
			             	  {      yyerror("Unrecognized constant");
			             	  }

			             	}
			             else							
			              {	
			                scanf("%d",gcheck->VALUE);
			              
			              }
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
			             	  {	*(gcheck->VALUE+pos) = 1;
			             	  }
			             	  else if(strcmp(bval,"FALSE")==0) 
			             	   {	*(gcheck->VALUE+pos) = 0;
			             	   }
			             	  else
			             	   {  yyerror("Unrecognized constant");
				            }	   

			             	}
				        else
				     	{
				     	   
				     	   scanf("%d",(gcheck->VALUE+pos));
				     	   			               
			                }
			             }
			          }
			       } 
			    }
			   else
			   {     if(check->TYPE==BOOLEAN) 
			             	{ char bval[6];
			             	  scanf("%s", bval );
			             	  if(strcmp(bval,"TRUE")==0) 
			             	  {	*(check->VALUE) = 1;			             	  
			             	   }
			             	  else if(strcmp(bval,"FALSE")==0)
			             	  {	*(check->VALUE) = 0;
 
			             	  }
			             	  else
			             	   {     yyerror("Unrecognized constant");
					    }

			             	}
			      	else
				 {
				   scanf("%d",(check->VALUE));

				    
			         }
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
			         {  *(gcheck->VALUE) = traverse(t->P3);
		
			         }
			        else
			         {
			           int pos = traverse(t->P2);
			           if(pos >= (gcheck->SIZE) || pos<0 )
			           	yyerror("Exceeding size of array");
			           else
			           {	
					   *(gcheck->VALUE + pos) = traverse(t->P3);

					   }
			          }   
			         }
			      }
	  	 	else
	  	 	 {
			    *(check->VALUE) = traverse(t->P3);
	  	 	  
	  	 	 }
	  	 }
	  	else if(t->NODETYPE=='W')
	  	  {
	  	   	if(t->P1->TYPE==INTEGER)
	  	   	{ printf("%d\n",traverse(t->P1));
	  	   	}
	  	   	else
	  	   	 {
	  	   	   if(traverse(t->P1)==1)
	  	   	    {	printf("TRUE\n");
	  	   	        
	  	   	     }
	  	   	   else 
	  	   	       printf("FALSE\n");
	  	   	 }

	  	  }	
	  	else if(t->NODETYPE=='i')		
	  	  {

	  	     	
	  	     	
	  	     	if(traverse(t->P1)&&t->P1->TYPE==BOOLEAN)
	  	    	  {traverse(t->P2); 
	  	    	   }
	  	    	else 
	  	    	  {
	  	    	  traverse(t->P3);
	  	  	  }
	  	  	  
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
				 { 
				   res = *(t->LENTRY->VALUE);							
				  }
				else
				 {
				   res = *(t->GENTRY->VALUE);
				 }
			}
			else
			{
			  int pos = traverse(t->P1);
			  if(pos < t->GENTRY->SIZE || pos >= 0)
			   {
			      res = *(t->GENTRY->VALUE + pos);
			   } 
			  
		         }
	  	 	
	  	 }
	  	else if(t->NODETYPE=='c')
	  	 {
	  	 	res = t->VALUE;
	  	 	
	  	 }
		else if(t->NODETYPE=='x')
		{

	  	 	
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
