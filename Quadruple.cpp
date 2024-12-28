#include "Quadruple.hpp"

Quadruple::Quadruple(const string& op, const string& arg1, const string& arg2, const string& result)
    : op(op), arg1(arg1), arg2(arg2), result(result) {
}

void Quadruple::display(int index, VariadicTable<string, string, string, string, string>& vt) const {
    vt.addRow(to_string(index), op, arg1, arg2, result);
}
