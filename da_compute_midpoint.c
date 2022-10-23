#include <stdlib.h>
#include <stdio.h>

void main(int argc, char** argv){
  double num1 = atof(argv[1]);
  double num2 = atof(argv[2]);

  double midpoint = (num1 + num2)/2;

  printf("%.4f\n",midpoint);

}
