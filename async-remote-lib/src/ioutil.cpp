//
// Created by 陈语梵 on 4/12/21.
//

#include <fstream>

#include "ioutil.h"
#include "dslice.h"
#include "dstring.h"

void* ReadStream(istream &in) {
  auto d_sli = CreateSlice(TYPE_STR);
  string word;
  while (in >> word) {
    d_sli = SliceAppend(d_sli, CreateString(word.c_str()));
  }
  return d_sli;
}

void* ReadFile(const char* path) {
  ifstream file(path);
  return ReadStream(file);
}




