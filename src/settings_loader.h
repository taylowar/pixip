/// setting_loader.h - Tilen Okretic - 12.02.2026
///
/// This is a C++ STB style header only library for loading defined setting from a file
///
#ifndef SETTINGS_LOADER_H_
#define SETTINGS_LOADER_H_

#include <stdlib.h>
#include <string>
#include <fstream>

typedef struct {
    std::string monitor_dir_path;
    std::string trash_bin_path;
} SL_Settings;

void sl_read_settings_from_file(const char* settings_file_path, SL_Settings *settings);

#ifdef SL_IMPLEMENTATION
void sl_read_settings_from_file(const char* settings_file_path, SL_Settings *settings)
{
    std::ifstream file_stream = std::ifstream(settings_file_path, std::ios::in);
    if (file_stream.is_open()) {
        const size_t buf_size = 1024;
        char buf[buf_size];
        while (file_stream.getline(buf, buf_size)) {
            std::string line = std::string(buf); 
            size_t new_size = line.length();
            // TODO: (Tilen) trim_back
            while (line.at(new_size-1) == ' ') {
                line.pop_back();
                new_size-=1;
            }
            // validate correct format of key value pair
            size_t s = line.find_first_of(";");
            if (s < line.length()-1) {
                fprintf(stderr, "ERROR: malformed settings file\n");
                exit(1);
            }
            if (line.at(line.length()-1) != ';') {
                fprintf(stderr, "ERROR: malformed settings file: missing ';'\n");
                exit(1);
            }
            line.pop_back(); // remove ';'
            // determine setting key (before '=')
            size_t delim_loc = line.find_first_of('=');
            std::string key = line.substr(0, delim_loc);
            line.erase(0, delim_loc+1);
            // determine setting value (after '=')
            std::string value = line.data();
            if (value.length() <= 0) {
                fprintf(stderr, "ERROR: malformed settings file: '%s' has no value\n", key.c_str());
                exit(1);
            }
            // store parsed settings data
            if (key.compare("monitor_dir_path") == 0) {
                settings->monitor_dir_path = value;
            }
            else if (key.compare("trash_bin_path") == 0) {
                settings->trash_bin_path = value;
            } else {
                fprintf(
                    stderr,
                    "[SettingLoader] ERROR: Unknown configuration key: `%s`\n", key.c_str()
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
