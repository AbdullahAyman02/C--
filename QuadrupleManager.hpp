#pragma once
#include <map>
#include <iomanip>
#include <iostream>
#include <string>
#include <vector>
using namespace std;

#include "Quadruple.hpp"

class QuadrupleManager {
   private:
    vector<Quadruple> quadruples;  // Stores all quadruples
    int exitLabel;

    static int tempCount;   // Counter for temporary variables
    static int labelCount;  // Counter for labels
    static int registerCount;
    static map<string, string> registerMap;
   public:
    // Add a new quadruple
    void addQuadruple(const string& op, const string& arg1, const string& arg2, const string& result);

    void addQuadruple(const Quadruple& quadruple);
    // Generate a new temporary variable
    string newTemp();

    void addQuadrupleInFront(const string& op, const string& arg1, const string& arg2, const string& result);
    void addQuadrupleInFront(const Quadruple& quadruple);

    // Generate a new label
    string newLabel();

    int generateNewExitLabel();
    int getExitLabel();

    vector<Quadruple> getQuadruples();

    // alloc map
    string allocMap(string var);
    string getRegister(string var);
    // Display all quadruples
    void printQuadruples(const string& inputFileName = "");
};
