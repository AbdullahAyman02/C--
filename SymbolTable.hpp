#pragma once

#include <iostream>

class SymbolTable {
public:
    void hello() {
        std::cout << "Hello from SymbolTable" << std::endl;
    }
};

extern "C" {
    void hello(){
        SymbolTable st;
        st.hello();
    }
}