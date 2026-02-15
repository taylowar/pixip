// String View - taken from TSoding SV.h

#ifndef SV_H_
#define SV_H_

#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>

typedef struct {
    size_t size;
    const char* data;
} StringView;

#define SV(cstr) sv_from_cstr(cstr, sizeof(cstr)-1)
#define SV_Fmt "%.*s"
#define SV_ARG(sv) (int)(sv).size, (sv).data

StringView sv_from_cstr(const char* cstr, size_t size);

bool cstr_ends_with(const char* cstr, const char* ends);
bool sv_equals(StringView sv1, StringView sv2);

StringView sv_chop_until_delim(StringView sv, const char* delim);

StringView sv_extend(StringView sv, const char* cstr);

void sv_trim_back(StringView *sv);

#ifdef SV_IMPLEMENTATION

StringView sv_from_cstr(const char *cstr, size_t size)
{
    StringView sv;
    sv.data = cstr;
    sv.size = size;
    return sv;
}

bool cstr_ends_with(const char* cstr, const char* ends)
{
    char ch = ends[0];
    size_t i = strlen(cstr)-1;
    while (i > 0) {
        if (cstr[i] == ch) {
            break;
        }
        i--;
    }
    if (i == 0) return false;
    assert(strlen(cstr)-i==strlen(ends)); 
    for (size_t j=0;j<strlen(ends);++j) {
        if (cstr[i+j] != ends[j]) {
            return false;
        }
    }
    return true;
}

bool sv_equals(StringView sv1, StringView sv2)
{
    if (sv1.size != sv2.size) {
        return false;
    }
    bool eq = true;
    for (size_t i=0;i<sv1.size;++i) {
        if (sv1.data[i] != sv2.data[i]) {
            eq = false;
            break;
        }
    }
    return eq;
}

StringView sv_chop_until_delim(StringView sv, const char delim)
{
    size_t i = 0;
    while (i < sv.size) {
        if (sv.data[i] == delim) {
            break;
        }
        i++;
    }
    StringView out = {
        .size = i,
        .data = sv.data
    };
    return out;
}

void sv_trim_back(StringView *sv)
{
    size_t i = sv->size-1;
    while (i > 0 && sv->data[i] == ' ') {
        i -= 1;
    }
    sv->size = i;
}

#endif // SV_IMPLEMENTATION 
#endif // SV_H_
