#include "dmon.h"

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

void dmon_poll_result(Dmon *dmon, Dmon_Notify_Result *result)
{
    // TODO: debug print
    // printf("[dmon] INFO: polling\n");
    int poll_num = poll(dmon->fd_polls, dmon->fd_polls_len, 500);
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

                if (size <= 0) {
                    break;
                }

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

void dmon_print_notify_result(Dmon_Notify_Result result)
{
    printf("{\n");
    printf("    mode := ");
    switch (result.mode) {
        case dmon_notify_CREATE: {
            printf("CREATE\n");
        } break;
        case dmon_notify_ACCESS: {
            printf("ACCESS\n");
        } break;
        case dmon_notify_ATTRIB: {
            printf("ATTRIB\n");
        } break;
        case dmon_notify_CLOSE_WRITE: {
            printf("CLOSE_WRITE\n");
        } break;
        case dmon_notify_CLOSE_NOWRITE: {
            printf("CLOSE_NOWRITE\n");
        } break;
        case dmon_notify_DELETE: {
            printf("DELETE\n");
        } break;
        case dmon_notify_DELETE_SELF: {
            printf("DELETE_SELF\n");
        } break;
        case dmon_notify_MODIFY: {
            printf("MODIFY\n");
        } break;
        case dmon_notify_MOVE_SELF: {
            printf("MOVE_SELF\n");
        } break;
        case dmon_notify_MOVED_FROM: {
            printf("MOVED_FROM\n");
        } break;
        case dmon_notify_MOVED_TO: {
            printf("MOVED_TO\n");
        } break;
        case dmon_notify_OPEN: {
            printf("OPEN\n");
        } break;
    }
    printf("    name := %s\n", result.name);
    printf("    fso_type := ");
    switch (result.fso_type) {
        case dmon_fso_DIR: {
            printf("DIR\n");
        } break;
        case dmon_fso_FILE: {
            printf("FILE\n");
        } break;
    }
    printf("}\n");
}
