#include <stdint.h>
#include "dmon.h"

int main(void)
{
    const char* WATCH_DIR_PATH = "/home/tilc/dev/programming/c/pixip/testing";

    Dmon dmon = {};
    dmon_init(&dmon);
    dmon_register_directory(&dmon, WATCH_DIR_PATH, dmon_notify_CREATE);

    for (;;) {
        Dmon_Notify_Result dnr = {};
        if (dmon_poll_result(&dmon, &dnr)) {
            dmon_print_notify_result(dnr);
        }
    }
    return 0;
}
