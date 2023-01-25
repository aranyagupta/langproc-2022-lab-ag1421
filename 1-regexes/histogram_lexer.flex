%option noyywrap

%{
/* Now in a section of C that will be embedded
   into the auto-generated code. Flex will not
   try to interpret code surrounded by %{ ... %} */

/* Bring in our declarations for token types and
   the yylval variable. */
#include "histogram.hpp"
#include <string>

// This is to work around an irritating bug in Flex
// https://stackoverflow.com/questions/46213840/get-rid-of-warning-implicit-declaration-of-function-fileno-in-flex
extern "C" int fileno(FILE *stream);

/* End the embedded code section. */
%}


%%

\[[^\]]*\]|[a-zA-Z]+ {fprintf(stderr, "Word : %s\n", yytext);
                  std::string s(yytext);
                  if (s.at(0)=='[' && s.at(s.length()-1)==']'){
                     if(s.length()==2){
                        s = "";
                     }
                     else{
                        s = s.substr(1,s.length()-2);
                     }
                  }
                  
                  
                  yylval.wordValue = new std::string;
                  *(yylval.wordValue) = s;
 
                  return Word;
               }


-?[0-9]+\.?\/?[0-9]* {fprintf(stderr, "Number : %s\n", yytext);
                     std::string s(yytext);
                     int divide = 0;
                     bool ignore = false;
                     for (int i=0; i<s.length(); i++){
                        if (i!=s.length()-1 && s.at(i)=='/'){
                        divide = i;
                        break;
                        }
                        else if (i==s.length()-1 && s.at(i)=='/'){
                        ignore = true;
                        }
                     }
                     
                     if (ignore){
                        yylval.numberValue = std::stod(s.substr(0,s.length()-1));
                     }
                     else if (divide!=0){
                        yylval.numberValue = std::stod(s.substr(0, divide))/std::stod(s.substr(divide+1, s.length()-divide-1));
                     }
                     else{
                        yylval.numberValue = std::stod(s);
                     }
                     
                     return Number;
               }

\n              { fprintf(stderr, "Newline\n"); }

.               {fprintf(stderr, "Unmatched : %s\n", yytext);}

%%

/* Error handler. This will get called if none of the rules match. */
void yyerror (char const *s)
{
  fprintf (stderr, "Flex Error: %s\n", s); /* s is the text that wasn't matched */
  exit(1);
}
