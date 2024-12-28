#pragma once

#include <iostream>
#include <iomanip>
#include <string>
#include <vector>
using namespace std;

#include "Quadruple.hpp"

class QuadrupleManager {
private:
    vector<Quadruple> quadruples;       // Stores all quadruples
    int tempCount = 0;                  // Counter for temporary variables
    int labelCount = 0;                 // Counter for labels

public:
    // Add a new quadruple
    void addQuadruple(const string& op, const string& arg1, const string& arg2, const string& result);

    // Generate a new temporary variable
    string newTemp();

    // Generate a new label
    string newLabel();

    // Display all quadruples
    void printQuadruples();
};
