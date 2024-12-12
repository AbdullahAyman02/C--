#include <iostream>
#include <stack>
#include "example.h"
class Simple
{
private:
    std::stack<int> stack;
    Simple() {}

public:
    static Simple *getInstance()
    {
        static Simple instance;
        return &instance;
    }
    void push(int value)
    {
        stack.push(value);
    }
    void pop()
    {
        stack.pop();
    }
    int top()
    {
        return stack.top();
    }
    bool empty()
    {
        return stack.empty();
    }
};

extern "C"
{
    void my_function_c()
    {
        Simple *simple = Simple::getInstance();
        simple->push(1);
        simple->push(2);
        simple->push(3);
        while (!simple->empty())
        {
            std::cout << simple->top() << std::endl;
            simple->pop();
        }
    }
}