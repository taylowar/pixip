/// setting_loader.h - Tilen Okretic - 12.02.2026
///
/// This is a C++ STB style header only library for loading defined setting from a file
///
#ifndef SETTINGS_LOADER_H_
#define SETTINGS_LOADER_H_

#include <stdlib.h>
#include <stdio.h>
#include <fstream>

#include "sv.h" // This assumes `sv.h` is included in the `main` file

typedef struct {
    char* monitor_dir_path;
    size_t monitor_dir_path_len;
    char* trash_bin_path;
    size_t trash_bin_path_len;
} SL_Settings;

void sl_read_settings_from_file(const char* settings_file_path, SL_Settings *settings);

#define SL_IMPLEMENTATION
#ifdef SL_IMPLEMENTATION
void sl_read_settings_from_file(const char* settings_file_path, SL_Settings *settings)
{
    std::ifstream file_stream = std::ifstream(settings_file_path, std::ios::in);
    if (file_stream.is_open()) {
        const size_t buf_size = 1024;
        char buf[buf_size];
        while (file_stream.getline(buf, buf_size)) {
            StringView sv = SV(buf);
            sv_trim_back(&sv);
            // validate correct format of key value pair
            StringView kv_pair = sv_chop_until_delim(sv, ';');
            // determine setting key (before '=')
            StringView key = sv_chop_until_delim(kv_pair, '=');
            // determine setting value (after '=')
            const char* value = "aboba";
            // store parsed settings data
            if (sv_equals(key, SV("monitor_dir_path"))) {
                #ifdef TALLOC_H_
                settings->monitor_dir_path = (char*)talloc_reserve(5+1);
                #else
                printf("[SettingLoader] WARN: Using `malloc` instead of `talloc`. Did you free the string?\n");
                settings->monitor_dir_path = (char*)malloc(5+1);
                #endif // TALLOC_H_
                snprintf(settings->monitor_dir_path, 5+1, "%s", value);
            }
            else if (sv_equals(key, SV("trash_bin_path"))) {
                #ifdef TALLOC_H_
                settings->trash_bin_path = (char*)talloc_reserve(5+1);
                #else
                printf("[SettingLoader] WARN: Using `malloc` instead of `talloc`. Did you free the string?\n");
                settings->trash_bin_path = (char*)malloc(5+1);
                #endif // TALLOC_H_
                snprintf(settings->trash_bin_path, 5+1, "%s", value);
            } else {
                fprintf(
                    stderr,
                    "[SettingLoader] ERROR: Unknown configuration key: `%s`\n", key.data
                ); 
                exit(1);
            }
        }
    } else {
        fprintf(
            stderr,
            "[SettingLoader] ERROR: Unable to find file '%s'\n", settings_file_path
        );
    }
}
#endif // SL_IMPLEMENTATION
#endif // SETTINGS_LOADER_H_
