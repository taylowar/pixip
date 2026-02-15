#include <stdint.h>

#define SL_IMPLEMENTATION
#include "settings_loader.h"

#include "./dmon/dmon.h"

int main(void)
{
    // Pixip Settings
    SL_Settings settings = {};
    sl_read_settings_from_file("./pixip.conf", &settings);

    Dmon dmon = {};
    dmon_init(&dmon);
    dmon_register_directory(&dmon, settings.monitor_dir_path, dmon_notify_CREATE);

    for (;;) {
        Dmon_Notify_Result dnr = {};
        if (dmon_poll_result(&dmon, &dnr)) {
            dmon_print_notify_result(dnr);
        }
    }
    return 0;
}
