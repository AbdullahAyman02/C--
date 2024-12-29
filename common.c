#include "common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern const char* inputFileName;

void printLogToFile(const char* message, int line, const char* errorType) {
    char outputFileName[256];
    strncpy(outputFileName, inputFileName, sizeof(outputFileName) - 1);
    outputFileName[sizeof(outputFileName) - 1] = '\0';

    char *inputPos = strstr(outputFileName, "input");
    if (inputPos != NULL) {
        memmove(inputPos + 6, inputPos + 5, strlen(inputPos + 5) + 1); 
        strncpy(inputPos, "output", 6);
    }

    char *dot = strrchr(outputFileName, '.');
    if (dot != NULL) {
        *dot = '\0';
    }

    strncat(outputFileName, "_", sizeof(outputFileName) - strlen(outputFileName) - 1);
    strncat(outputFileName, errorType, sizeof(outputFileName) - strlen(outputFileName) - 1);
    strncat(outputFileName, "_log.txt", sizeof(outputFileName) - strlen(outputFileName) - 1);

    FILE *file = fopen(outputFileName, "a");
    if (file != NULL) {
        fprintf(file, "Line %d %s Error: %s\n", line, errorType, message);
        fclose(file);
    } else {
        printf("Failed to open %s for writing.\n", outputFileName);
    }
}

//void printSyntaxErrorLogToFile()

void exitOnError(const char* message, int line) {
    printf("Line %d Semantic Error: %s\n", line, message);

    printLogToFile(message, line, "semantic");

    exit(1);
}
