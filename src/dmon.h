/// Directory Monitor - Dmon
///
/// Support only for Linux `inotify` API (for now)
///
/// Example:
///
///


#ifndef _DMON_H_
#define _DMON_H_

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <errno.h>

#include <poll.h>
#include <unistd.h>
#include <sys/inotify.h>

typedef enum {
    dmon_notify_CREATE=0,
    dmon_notify_ACCESS,
    dmon_notify_ATTRIB,
    dmon_notify_CLOSE_WRITE,
    dmon_notify_CLOSE_NOWRITE,
    dmon_notify_DELETE,
    dmon_notify_DELETE_SELF,
    dmon_notify_MODIFY,
    dmon_notify_MOVE_SELF,
    dmon_notify_MOVED_FROM,
    dmon_notify_MOVED_TO,
    dmon_notify_OPEN,
} Dmon_Notify_Mode;

typedef enum {
    dmon_fso_DIR=0,
    dmon_fso_FILE,
} Dmon_FSO_Type; // Dmon_FileSystemObject_Type

typedef struct {
    Dmon_Notify_Mode mode;
    const char* name;
    size_t name_len;
    Dmon_FSO_Type fso_type;
} Dmon_Notify_Result;

typedef struct {
    int fd; // inotify file descriptor
    nfds_t fd_polls_len;
    struct pollfd fd_polls[1]; // inotify poll event array (we expect only one event (for now))
} Dmon;

void dmon_init(Dmon *dmon);
void dmon_register_directory(Dmon *dmon, const char* full_dir_path, Dmon_Notify_Mode mode);
void dmon_poll_result(Dmon *dmon, Dmon_Notify_Result *result);

void dmon_print_notify_result(Dmon_Notify_Result result);

#endif // _DMON_H_
