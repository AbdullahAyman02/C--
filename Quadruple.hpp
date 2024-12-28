#pragma once

#include <iostream>
#include <iomanip>
#include <string>
using namespace std;

class Quadruple {
    string op;       // Operator
    string arg1;     // First operand
    string arg2;     // Second operand (can be empty for unary ops)
    string result;   // Result variable

public:
    // Constructor
    Quadruple(const std::string& op, const std::string& arg1, const std::string& arg2, const std::string& result);

    // Display function for debugging
    void display(int index) const;
};