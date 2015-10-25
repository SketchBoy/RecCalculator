//
//  resolveFormula.cpp
//  resolveFormula
//
//  Created by iSoftware on 15/4/27.
//  Copyright (c) 2015年 USTC. All rights reserved.
//

#include <stdio.h>


#include <iostream>
#include <string>  ///string类的静态方法库
#include <stack>   ///处理堆栈的库
#include <list>    ///处理链表
#include <cmath>
#include "resolveFormula.h"
using namespace std;

bool isOperatorAndOrMinus(char op);
bool isOperatorTimesOrDivideOrDot(char op);
bool converResultNumToOp(int result, char* op);

bool isNumber(string str)
{
//    if(str.empty())
//        return false;
    string num_dot("0123456789.");
    if(str.find_first_not_of(num_dot) != string::npos)
        return false;
    if(str.find_first_of(".") != str.find_last_of("."))
        return false;
    if(*(str.end() - 1) == '.')
        return false;
    return true;
}

bool isOperator(string str)
{
    if(str == "+" || str == "-" || str == "*" || str == "/")
        return true;
    else
        return false;
}

bool isAddOrMinus(string str)
{
    if(str == "+" || str == "-")
        return true;
    else
    {
        return false;
    }
}

int priority(char op)
{
    switch(op){
        case '+': return 1;
        case '-': return 1;
        case '*': return 2;
        case '/': return 2;
        case '#': return 0;
        default: return -1;
    }
}

double str2num(string str)
{
    long int power = 0;
    string::size_type pos;
    if((pos = str.find_first_of('.')) == string::npos)
        power = str.size();
    else
    {
        power = pos;
        str.erase(pos, 1);
    }
    long sum = 0;
    for(size_t i = 0; i != str.size(); ++i)
        sum = sum * 10 + str[i] - 48;
    double ret = sum / pow(10.0, (double)(str.size() - power));
    return ret;
}

double operate(char op, double a, double b)
{
    switch(op){
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/':
            if(b == 0)
                throw b;
            else
                return a / b;
        default: throw op;
    }
    
}

bool Cformula::resolveFormula(string formula, double *result)
{
    if(formula.find_first_not_of("0123456789.+-*/") != string::npos)
        return false;
    formula = formula + "#";
    string::size_type pos1 = 0, pos2 = 0;
    list<string> rPolish;
    stack<char> oStack;
    long int strlenght = formula.length();
    printf("The str length:%ld\n",strlenght);
    
    while((pos2 = formula.find_first_of("+-*/#",pos1)) != string::npos)
    {
        string number(formula, pos1, pos2 - pos1);
        if(!number.empty())
        {
            //如果表达式包含非法处理"数字”、"."、"四则运算符"、“#”以外的字符，表达式非法，返回false
            if(!isNumber(number))
                return false;
            //如果是数字，入队rPolish
            else
            {
                cout<<"EnteringrPolishNumeris:"<<number<<endl;
                rPolish.push_back(number);
                
                while((!oStack.empty()) && priority(formula[pos2]) <= priority(oStack.top()))
                {
                    cout<<"EnteringrPolishNumeris:"<<string(1,oStack.top())<<endl;
                    rPolish.push_back(string(1,oStack.top()));
                    oStack.pop();
                }
                oStack.push(formula[pos2]);
                pos1 = pos2 + 1;
            }
        }
        //说明pos2 = po1
        //定义：内只含有+-的formula子字符串，叫加减子串
        else
        {
            //非+-是当前第一个字符，说明运算符序列多于一个‘*’或者‘/’，或者‘*’‘/’在formula首位，表达式错误
            if (!isOperatorAndOrMinus(formula[pos2]) ) {
                return false;
            }

            string::size_type tempos = formula.find_first_not_of("+-",pos1);
            
            string substr;
            //子字符串，第一个加减子子串和后续的子串截取方式稍有不同
            if(pos2 == 0)
            {
                substr = formula.substr(pos1,tempos-pos1);
            }
            else
            {
                substr = formula.substr(pos1-1, tempos-(pos1-1));
            }
//            cout<<substr<<endl;
            
            //加减子串的下一个是'*/.字符，表达式非法
            if(isOperatorTimesOrDivideOrDot(formula[tempos]))
            {
                return false;
            };
            
            //将之前一个已经压入oStack的运算符吐出，填入经过运算化简的加减子串结果---------------
            if(!oStack.empty())
            {
                oStack.pop();
            }
            int res = mergerMinusAndAdd(substr);
            char op;
            if(converResultNumToOp(res,&op))
            {
                oStack.push(op);
            }
            //---------------------------------------------------------------------
            
            pos1 = tempos;
        }
        

    }
    
    stack<double> nStack;
    for(list<string>::iterator i = rPolish.begin(); i != rPolish.end(); ++i)
    {
        if(isNumber(*i))
        {
            printf("number is:%f\n",str2num(*i));
            nStack.push(str2num(*i));
        }
        else
        {
            char op = (*i)[0];
            double b = nStack.top();
            nStack.pop();
            double a;
            if(nStack.empty())
            {
                a = 0;
            }
            else
            {
                a = nStack.top();
                nStack.pop();
            }
            double res;
            try
            {
                res = operate(op, a, b);
            }
            catch(double d)
            {
                //cout<<"divider cannot be zero!"<<endl;
                return false;
            }
            catch(char c)
            {
                //cout<<c<<" is not an operator!"<<endl;
                return false;
            }
            nStack.push(res);
        }
    }
    *result = nStack.top();
    return true;
}

void Cformula::rawString2FormulaString(std::string *formula)
{
    string str = *formula;
    
    list<char> op;

    for(size_t i=0; i<str.size(); i++)
    {
        if(size_t pos = str.find("×",i) != string::npos)
        {
            string t = *new string("×");
            str.replace( pos, t.size(), t);
            i = pos+1;
        }
    }
 
    *formula = str;
}

//合并只包含“加减号”的字符串，返回运算结果:
//  1.如果减号为基数个 返回-1
//  2.如果减号为偶数个 返回1

int Cformula::mergerMinusAndAdd(string str)
{
    const char* charP = str.c_str();
    size_t length = str.length();
    size_t i = 0;
    int result =1;
    
    while (i<length)
    {
        if(*charP == '-' )
        {
            result = -1*result;
        }
        charP = charP+1;
        i++;
    }
    
    return result;
}

bool isOperatorAndOrMinus(char op)
{
    switch(op)
    {
        case '+':
            return 1;
        case '-':
            return 1;
        default:
            return 0;
    };
}

bool isOperatorTimesOrDivideOrDot(char op)
{
    switch(op)
    {
        case '*':
            return 1;
        case '/':
            return 1;
        case '.':
            return 1;
        default:
            return 0;
    };
}

bool converResultNumToOp(int result, char* op)
{
    switch (result) {
        case 1:
            *op = '+';
            return 1;
        case -1:
            *op = '-';
            return 1;
        default:
            return 0;
    }
}