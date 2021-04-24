//
// Created by 陈语梵 on 4/12/21.
//

#include <fstream>

#include "ioutil.h"
#include "dslice.h"
#include "dstring.h"

void* ReadStream(istream &in) {
  auto d_sli = (DigoSlice*)CreateSlice(TYPE_STR);
  string word;
  while (in >> word) {
    auto next_d_sli = (DigoSlice*)SliceAppend(d_sli, CreateString(word.c_str()));
    d_sli->DecRef();
    d_sli = next_d_sli;
  }
  return d_sli;
}

void* ReadFile(const char* path) {
  ifstream file(path);
  return ReadStream(file);
}




