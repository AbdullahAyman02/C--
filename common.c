#include "common.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern const char *inputFileName;

void printExitMsgToFile(const char *message) {
    const char *outputFileName = getOutputFileName(inputFileName, "_error.txt");

    FILE *file = fopen(outputFileName, "a");
    if (file != NULL) {
        fprintf(file, "%s\n", message);
        fclose(file);
    }
}

char *getOutputFileName(const char *inputFileName, const char *postfix) {
    char *outputFileName = (char *)malloc(strlen(inputFileName) + strlen(postfix) + 1);
    strcpy(outputFileName, inputFileName);
    char *dot = strrchr(outputFileName, '.');
    if (dot != NULL) {
        *dot = '\0';
    }
    strcat(outputFileName, postfix);
    return outputFileName;
}

void exitOnError(const char *message, int line) {
    static char buffer[1024];
    sprintf(buffer, "Line %d Semantic Error: %s\n", line, message);
    fprintf(stderr, "%s", buffer);
    printExitMsgToFile(buffer);
    exit(1);
}
