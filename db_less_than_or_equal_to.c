#include <stdlib.h>
#include <stdio.h>

void main(int argc, char** argv){
  double num1 = atof(argv[1]);
  double num2 = atof(argv[2]);


  if(num1 > num2){
    printf("%d\n",0);
  }else{
    printf("%d\n",1);
  }

}
