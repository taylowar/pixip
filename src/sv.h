// StringView - sv.h - Tilen Okretic 21.02.2026
//
// Heavily inspired by a who? A Mr. Tsoding
//

#ifndef SV_H_
#define SV_H_

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

#define SV_FMT "%.*s"
#define SV_ARG(sv) (int)(sv).size, (sv).data

typedef struct {
    const char* data;
    size_t size;
} StringView;

StringView sv_from_cstr(const char* cstr);
#define SV(cstr) sv_from_cstr((cstr))

// remove trailing spaces
void sv_trim_begin(StringView *sv);
void sv_trim_end(StringView *sv);
void sv_trim(StringView *sv);

void sv_chop_begin(StringView *sv);
void sv_chop_end(StringView *sv);

StringView sv_chop_until_delim(StringView *sv, char delim);
StringView sv_chop_until_word(StringView *sv, StringView word);

bool sv_starts_with(StringView sv, StringView prefix);
bool sv_ends_with(StringView sv, StringView sufix);
bool sv_equals(StringView sv, StringView other);

#define SV_IMPLEMENTATION
#ifdef SV_IMPLEMENTATION

StringView sv_from_cstr(const char *cstr)
{
    return (StringView) {
        .data = cstr,
        .size = strlen(cstr),
    };
}

// remove all spaces (` `) between the start of the string literal and first word
void sv_trim_begin(StringView *sv)
{
    size_t i = 0;
    while (i < sv->size && sv->data[i] == ' ') {
        i += 1;
    }
    sv->size -= i;
    sv->data += i;
}

// remove all spaces (` `) between the last word of the string literal and end of string literal
void sv_trim_end(StringView *sv)
{
    size_t i = sv->size;
    while (i > 0 && sv->data[i] == ' ') {
        i -= 1;
    }
    sv->size = i;
}

// combine `sv_trim_left` and `sv_trim_right`
void sv_trim(StringView *sv)
{
    sv_trim_begin(sv);
    sv_trim_end(sv);
}

// Remove one character from the begining of the string literal
void sv_chop_begin(StringView*sv)
{
    if (sv->size <= 0) {
        return;
    }
    sv->data += 1;
    sv->size -= 1;
}

// Remove one character from the end of the string literal
void sv_chop_end(StringView *sv)
{
    if (sv->size <= 0) {
        return;
    }
    sv->size -= 1;
}

StringView sv_chop_until_delim(StringView *sv, char delim)
{
    size_t i = 0;
    while (i < sv->size && sv->data[i] != delim) {
        i += 1;
    }

    StringView chopped = {
        .data = sv->data,
        .size = i,
    };

    sv->data += i;
    sv->size -= i;

    return chopped;
}

// TODO: (Tilen 23.03.2026) For practise we should implement a Trie here :)
StringView sv_chop_until_word(StringView *sv, StringView word)
{
    size_t i = 0;
    while (sv->size - i > word.size) {
        if (sv->data[i] == word.data[0]) {
            bool found_word = true;
            for (size_t j=0;j<word.size;++j) {
                if (sv->data[j+i] != word.data[j]) {
                    found_word = false;
                }
            }
            if (found_word) {
                break;
            }
        }
        i += 1;
    }
    StringView chopped = {
        .data=sv->data,
        .size=i,
    };

    sv->data += i;
    sv->size -= i;

    return chopped;
}

bool sv_starts_with(StringView sv, StringView prefix)
{
    size_t i = 0;
    while (i < prefix.size) {
        if (sv.data[i] == prefix.data[0]) {
            if (i + prefix.size < sv.size) {
                break;
            }
        }
        i += 1;
    }

    bool found = true;
    for (size_t j=0;j<prefix.size;++j) {
        if (sv.data[i+j] != prefix.data[j]) {
            found = false;
        }
    }

    return found;
}

// Look from then end of the view for a sequence that matches the sufix view
bool sv_ends_with(StringView sv, StringView sufix)
{
    size_t i = sv.size;
    while (i >= sufix.size) {
        if (sv.data[i] == sufix.data[0]) {
            if (i + sufix.size == sv.size) {
                break;
            }
        }
        i -= 1;
    }
    if (i < sufix.size) {
        return 0;
    }
    bool found = true;
    for (size_t j=0;j<sufix.size;++j) {
        if (sv.data[i+j] != sufix.data[j]) {
            found = false;
        }
    }
    return found;
}

bool sv_equals(StringView sv, StringView other)
{
    if (sv.size != other.size) return false;
    bool eq = true;
    for (size_t i=0;i<sv.size;++i) {
        if (sv.data[i] != other.data[i]) {
            eq = false;
        }
    }
    return eq;
}

#endif // SV_IMPLEMENTATION
#endif // SV_H_
