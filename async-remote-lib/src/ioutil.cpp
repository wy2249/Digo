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
      auto tmp_str = (DigoString*)CreateString(word.c_str());
    auto next_d_sli = (DigoSlice*)SliceAppend(d_sli, tmp_str);
    d_sli->DecRef();
    tmp_str->DecRef();
    d_sli = next_d_sli;
  }
  return d_sli;
}

void* ReadFile(void* path) {
  auto path_cstr = ((DigoString *)path)->Data().c_str();
  ifstream file(path_cstr);
  return ReadStream(file);
}




