#include "Quadruple.hpp"

Quadruple::Quadruple(const string& op, const string& arg1, const string& arg2, const string& result)
    : op(op), arg1(arg1), arg2(arg2), result(result)
{
}

void Quadruple::display(int index) const
{
    printf("%5d%10s%10s%10s%10s\n", index, op.c_str(), arg1.c_str(), arg2.c_str(), result.c_str());
}
