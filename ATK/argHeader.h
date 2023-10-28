

#ifndef HANDLEARGS_H
#define HANDLEARGS_H

#include <string>
using namespace std;

struct basicInfo
  {
    string type;
    string path;
    string password;
    string newPath;
    string header;
    bool safe = false;
    string uniq;
    int cypher = 0;
  };

basicInfo* handleArgs(char** argv, int argc);

#endif