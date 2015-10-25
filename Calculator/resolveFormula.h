//
//  resolveFormula.h
//  resolveFormula
//
//  Created by iSoftware on 15/4/27.
//  Copyright (c) 2015年 USTC. All rights reserved.
//

#pragma once
#include <string>

class Cformula{
public:
    bool resolveFormula(std::string formula, double *result);
    void rawString2FormulaString(std::string* formula);
    static int mergerMinusAndAdd(std::string str);
};
