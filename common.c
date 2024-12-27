#include "common.h"

#include <stdio.h>
#include <stdlib.h>

void exitOnError(const char* message, int line) {
    printf("Line %d Semantic Error: %s\n", line, message);
    exit(1);
}