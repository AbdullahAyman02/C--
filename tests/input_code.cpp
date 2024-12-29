// Single line comment

/*
Multiline
comment
*/


/*
    ======================================== DECLARATIONS AND ASSIGNMENTS ================================================
*/
int k = 0;
const int St = 100;
int declaration;
float decWith_Assign=5.2;
int x = 0;
int y = 10;
int z = x / y - x;
string str = "";
string welcome = "Hello World!";
bool a = true;
bool b = false;


/*
    ======================================== ARITHMETIC ================================================
*/
int iresult;
float fresult;
int op1 = 15;
int op2 = 6;
iresult = op1 + op2;
iresult = op1 - op2;
iresult = op1 * op2;
iresult = op1 / op2;
iresult = op1 % op2;
iresult = op1 ^ op2;
iresult = -op1;
int G =6;
int A = G+1;
int S = A-1;

//MAGNONA:   COMBO EXPRESSION TEST
iresult =  10 + 1 * 2 - 10 / 5 + 3 ^ 2;


/*
    ======================================== LOGICAL ================================================
*/

bool bresult;
bool bolo1 = true;
bool bolo2 = false;
bresult = bolo1 && bolo1;
bresult = op1 == op2;
bresult = op1 != op2;
bresult = op1 > op2 && op1 < op2;
bresult = op1 >= op2;
bresult = op1 <= op2;

//MAGNONA:   COMBO EXPRESSION TEST
bresult = ((bolo1 || !bolo1) && bolo1 || bolo2 != (bolo1 < bolo2));


/*
    ======================================== BLOCK SCOPES ================================================
*/
{
    int x = 5;
    {
        int y = 20;
    };
    y = 30;
};
x = y;

/*
    ======================================== FUNCTIONS ================================================
*/

int sum(int x, int y)
{
  return x + y;
}

void fun(){
    int res;
    if (x>7)
    {
        res = 7;
    }
    else if (x < 4) {
        res = 8;
    }
    else{
        res = 10;
    }
}

void elkebeerAwyGdn(){
    int res;
    void elkebeerAwy(){
        string kalam ;
        for (int i = 0; i < 10; i = i+1)
        {
            kalam = "Teftker hadrab";
        }
        void elkebeer(){
            if (x>7)
            {
                res = 7;
            }
            else if (x < 4) {
                res = 8;
            }
            else{
                res = 10;
            }
        }
    }
}


//MAGNONA:   COMBO EXPRESSION TEST
int paramChecker(string str = "G", float ff = 4.7, char c = 't'){
    if (ff > 7.5)
    {
        for (int i = 0; i < 10; i = i+1)
        {
            int b = paramChecker("Teftker hadrab", 3.5, 'd');
        }
        return 8;
    }
    else if (ff < 4.12) {
        return 0;
    }
    else{
        return 10;
    }
}

int returnChecker(string str = "G", float ff = 4.7, char c = 't'){
    int res;
    if (ff>7.5)
    {
        res = 8;
    }
    else if (ff < 4.12) {
        res = 0;
    }
    else{
        res = 10;
    }
}

bool booleanFunc()
{
    int f = 5;
    if (f > 10)
    {
        return false;
    }
    else
    {
        return true;
    }
}

void main()
{
    int a = sum(10, 20);
    fun();
    a = (paramChecker("S", 3.5,'d') + 3) ** 2;
}

/*
======================================== CONDITIONAL EXPRESSIONS ================================================
*/

int test;

if (x == 10)
{
    test = 10;
}
else if (x == 5)
{
    test = 5;
}
else
{
    test = x;
}

//MAGNONA:   COMBO CONDITIONAL EXPRESSION TEST
if (x == 10)
{
    test = 10;
    if(x == 10 && booleanFunc() || !booleanFunc())
    {
        test = 10;
        for (int i = 0; i < 10; i = i+1)
        {
            int b = 10;
        }
    }
    else
    {
        test = 20;
    }
}
else if (x == 5)
{
    test = 5;
}
else
{
    test = x;
}

int i = 9;
int var;

//MAGNONA:   COMBO EXPRESSION TEST
if((i>8 && i < 9) || (i!=8 && i <= 9) && i == 9){
    var=12;
}

char coco = 'a';
float j;

switch(coco){ 
    case 'b':{ 
        j = 9.0; 
    }
    break; 
    case 'p':{ 
        j = 9.0; 
    }
    break; 
    default:{ 
        j = 9.0; 
    }
    break;
}

//MAGNONA:   COMBO EXPRESSION TEST
for (int k = 0; k < 20; k++)
{
    for (int i = 0; i < 20; i++)
    {
        switch(coco){ 
        case 'b':{ 
            j = 9.0; 
        }
        break; 
        case 'p':{ 
            j = 9.0; 
        }
        break; 
        default:{ 
            j = 9.0; 
        }
        break;
        }
    }
}


/*
    ======================================== LOOPS ================================================
*/

for (int i = 0; i < 10; i = i+1)
{
    int b = 10;
}

int xx = 0;

while (xx < 20)
{
    xx = xx + 1;
}

xx = 0;

repeat
{
    xx = xx + 1;
    
} until (x < 20);

//MAGNONA:   COMBO EXPRESSION TEST
repeat
{
    xx = xx + 1;
    for (int i = 0; i < 10; i = i+1)
    {
        int b = 10;
    }
    while (xx < 20)
    {
        xx = xx + 1;
    }
    if(x == 10)
    {
        test = 10;
        for (int i = 0; i < 10; i = i+1)
        {
            int b = 10;
        }
    }
    else
    {
        test = 20;
    }
} until (x < 20);

/*
    ======================================== PRINT ================================================
*/
print("Hello World!");
print("Hello World!",4,3.6);



/*
    ======================================== NOW HELLO WITH ERRORS ================================================
*/

// *********************** SEMANTIC ERRORS ****************************8

// int x = 10;                                   // ERROR: REDECLARATION OF x  
// int x = 'd';                                 // ERROR: ASSIGNMENT MISMATCH OF TYPE INT
// float fof = fun();                          // ERROR: FUNCTION RETURN TYPE MISMATCH OF TYPE VOID
// const int CONSO;                           // ERROR: CONSTANT DECLARATION WITHOUT INITIALIZATION
// St = 10;                               // ERROR: CONSTANT CAN NOT BE CHANGED
// undeclared = 4.6;                        // ERROR: UNDECLARED VARIABLE

// int uninitialized;                         
// x = uninitialized;                        // ERROR: UNINITIALIZED VARIABLE

// bool boleaneto = true || 3;               // ERROR: OPERAND MISMATCH OF TYPE BOOLEAN

// for (int i = 0; i < 10; i = "ana error")     // ERROR: ASSIGNMENT MISMATCH OF TYPE INT
// {
//     int b = 10;
// }

// if ( 10 + 4.8)            // ERROR: CONDITION OF IF MUST BE BOOLEAN
// {
//     int b = 10;
// }

// for (int i = 0; i = 10; i++)     // ERROR: CONDITION OF FOR MUST BE BOOLEAN
// {
//     int b = 10;
// }

// int funres = fun();   // ERROR: FUNCTION RETURN TYPE MISMATCH OF TYPE VOID

// Function Argument Type Mismatch
// fun(10, 10.0);

//int redfun = paramChecker(3, 3.5,'d'); // ERROR: FUNCTION ARGUMENT TYPE MISMATCH
// int redfun = paramChecker("Teftker hadrab", 3.5); // ERROR: FUNCTION ARGUMENT SIZE MISMATCH


// ******************* SYNTAX ERRORS ***********************

// in x;

// fo (int i = 0; i < 10; i = i+1)








