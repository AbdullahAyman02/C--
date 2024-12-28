#include "QuadrupleManager.hpp"

void QuadrupleManager::addQuadruple(const string &op, const string &arg1, const string &arg2, const string &result)
{
    printf("Adding quadruple: %s %s %s %s\n", op.c_str(), arg1.c_str(), arg2.c_str(), result.c_str());
    quadruples.emplace_back(op, arg1, arg2, result);
}

string QuadrupleManager::newTemp()
{
    return "t" + std::to_string(tempCount++);
}

string QuadrupleManager::newLabel()
{
    return "L" + std::to_string(labelCount++);
}

void QuadrupleManager::printQuadruples()
{
    printf("\nGenerated Quadruples:\n");
    printf("%5s%10s%10s%10s%10s\n", "Index", "Op", "Arg1", "Arg2", "Result");

    for (size_t i = 0; i < quadruples.size(); ++i) {
        quadruples[i].display(i);
    }
}
