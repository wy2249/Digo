//
// Created by VM on 2021/3/27.
//

#ifndef DIGO_LINKER_AUTO_GC_H
#define DIGO_LINKER_AUTO_GC_H

#include <string>
using std::string;

const string functions_to_trace[] = {"ExtractString", "ExtractSlice",
                                     "CreateString", "AddString"};

class EscapeAnalyzer {

};


#endif //DIGO_LINKER_AUTO_GC_H
