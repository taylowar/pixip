/// talloc.h - Tilen Okretic - 01.09.2024
///
/// This is an STB style header only library which implement sn arena allocator for maneging temporary memory
///
#ifndef TALLOC_H_
#define TALLOC_H_

#include <stdlib.h>
#include <assert.h>

#define TALLOC_CAPACITY 8*1024*1024 // 8MiB
static char TALLOC_BUF[TALLOC_CAPACITY];
static size_t talloc_cursor = 0;

void* talloc_reserve(size_t size);
void  talloc_reset();

#ifdef TALLOC_IMPLEMENTATION
void* talloc_reserve(size_t size)
{
    assert(talloc_cursor+size <= TALLOC_CAPACITY && "Temporary allocator overflow\n");
    void* tmem = &TALLOC_BUF[talloc_cursor];
    talloc_cursor += size;
    return tmem;
}

void  talloc_reset()
{
    talloc_cursor = 0;
}
#endif // TALLOC_IMPLEMENTATION
#endif // TALLOC_H_
