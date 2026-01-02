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
void dmon_await_poll_result(Dmon *dmon, Dmon_Notify_Result *result);

#ifdef DMON_IMPLEMENTATION
void dmon_init(Dmon *dmon)
{
    int fd = inotify_init1(IN_NONBLOCK);
    if (fd < 0) {
        fprintf(stderr, "[dmon] ERROR: Unable to open file descriptor\n");
        exit(1);
    }
    dmon->fd = fd;
    dmon->fd_polls_len = 1;
    dmon->fd_polls[0].fd = fd;
    dmon->fd_polls[0].events = POLLIN;
}

void dmon_register_directory(Dmon *dmon, const char* full_dir_path, Dmon_Notify_Mode mode)
{
    uint32_t __mask;
    // inotify masks
    // :Man inotify(7)
    switch (mode) {
        case dmon_notify_CREATE: {
            __mask = IN_CREATE;
        } break;
        case dmon_notify_ACCESS: {
            __mask = IN_ACCESS;
        } break;
        case dmon_notify_ATTRIB: {
            __mask = IN_ATTRIB;
        } break;
        case dmon_notify_CLOSE_WRITE: {
            __mask = IN_CLOSE_WRITE;
        } break;
        case dmon_notify_CLOSE_NOWRITE: {
            __mask = IN_CLOSE_NOWRITE;
        } break;
        case dmon_notify_DELETE: {
            __mask = IN_DELETE;
        } break;
        case dmon_notify_DELETE_SELF: {
            __mask = IN_DELETE_SELF;
        } break;
        case dmon_notify_MODIFY: {
            __mask = IN_MODIFY;
        } break;
        case dmon_notify_MOVE_SELF: {
            __mask = IN_MOVE_SELF;
        } break;
        case dmon_notify_MOVED_FROM: {
            __mask = IN_MOVED_FROM;
        } break;
        case dmon_notify_MOVED_TO: {
            __mask = IN_MOVED_TO;
        } break;
        case dmon_notify_OPEN: {
            __mask = IN_OPEN;
        } break;
    }
    inotify_add_watch(dmon->fd, full_dir_path, __mask);
    printf("[dmon] INFO: `%s` directory registered\n", full_dir_path); 
}

void dmon_await_poll_result(Dmon *dmon, Dmon_Notify_Result *result)
{
    // TODO: debug print
    printf("[dmon] INFO: polling\n");
    int poll_num = poll(dmon->fd_polls, dmon->fd_polls_len, -1);
    if (poll_num < 0) {
        if (errno == EINTR) {
            printf("[dmon] WARN: got an error but `errno` is `EINTR`");
            // continue;
        } else {
            fprintf(stderr, "[dmon] ERROR: polling file descriptor\n");
            exit(1);
        }
    }
    if (poll_num > 0) {
        // HANDLE `POLLIN` event
        if (dmon->fd_polls[0].revents & POLLIN) {
            ///  Some systems cannot read integer variables if they are not
            ///  properly aligned. On other systems, incorrect alignment may
            ///  decrease performance. Hence, the buffer used for reading from
            ///  the inotify file descriptor should have the same alignment as
            ///  struct inotify_event.

            char buf[4096]
                __attribute__ ((aligned(__alignof__(struct inotify_event))));
            const struct inotify_event *event;
            ssize_t size;

            /* Loop while events can be read from inotify file descriptor. */

            for (;;) {
                // TODO: debug mode enable
                // printf("[dmon] reading events\n");

                /* Read some events. */

                size = read(dmon->fd, buf, sizeof(buf));
                if (size == -1 && errno != EAGAIN) {
                    // TODO: fprintf error 
                    perror("[dmon] read");
                    exit(EXIT_FAILURE);
                }

                /// If the nonblocking read() found no events to read, then
                /// it returns -1 with errno set to EAGAIN. In that case,
                /// we exit the loop

                if (size <= 0)
                    break;

                /* Loop over all events in the buffer. */

                for (char *ptr = buf; ptr < buf + size; ptr += sizeof(struct inotify_event) + event->len) {
                    event = (const struct inotify_event *) ptr;
                    /* capture occured event type. */
                    if (event->mask & IN_OPEN) {
                        result->mode = dmon_notify_OPEN;
                    }
                    else if (event->mask & IN_CLOSE_NOWRITE) {
                        result->mode = dmon_notify_CLOSE_NOWRITE;
                    }
                    else if (event->mask & IN_CLOSE_WRITE) {
                        result->mode = dmon_notify_CLOSE_WRITE;
                    }
                    else if (event->mask & IN_CREATE) {
                        result->mode = dmon_notify_CREATE;
                    }
                    else {
                        assert(0 && "unhandled event type");
                    }
                    /* print the name of the watched directory */
                    // TODO: debug mode print
                    // printf("[dmon] %s/", "../probe");
                    /* capture the name of the file */
                    result->name = event->name;
                    result->name_len = event->len;
                    /* capture type of filesystem object */
                    if (event->mask & IN_ISDIR) {
                        result->fso_type = dmon_fso_DIR;
                    } else {
                        result->fso_type = dmon_fso_FILE;
                    }
                }
            }
        }
    }
}
#endif // DMON_IMPLEMENTATION
#endif // _DMON_H_
