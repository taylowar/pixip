#include "dmon.h"

#include "windows.h"
#include <assert.h>
#include <stdlib.h>
#include <stdint.h>

void dmon_init(Dmon *dmon)
{
    dmon->overlapped.hEvent = CreateEvent(NULL, FALSE, 0, NULL);
}

void dmon_register_directory(Dmon *dmon, const char* full_dir_path, Dmon_Notify_Mode mode)
{
    HANDLE file = CreateFile(
        full_dir_path,
        FILE_LIST_DIRECTORY,
        FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
        NULL,
        OPEN_EXISTING,
        FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED,
        NULL
    );
    if (file == INVALID_HANDLE_VALUE) {
        // TODO: (Tilen) extend the descritpion of this error
        fprintf(stderr, "[dmon] ERROR: invalid handle value: %s\n", full_dir_path);
        exit(1);
    }
    assert(dmon->fd_polls_len == 0 && "We support only one handle (for now)");
    dmon->fd_polls[dmon->fd_polls_len++] = file;
    printf("[dmon] INFO: `%s` directory registered\n", full_dir_path); 
}

bool dmon_poll_result(Dmon *dmon, Dmon_Notify_Result *result)
{
    uint8_t change_buf[4096];
    // TODO: (Tilen) handle `success` ... what does it to? 
    BOOL success = ReadDirectoryChangesW(
        dmon->fd_polls[0], change_buf, 4096, TRUE,
        FILE_NOTIFY_CHANGE_FILE_NAME  |
        //FILE_NOTIFY_CHANGE_DIR_NAME   | // TODO: (Tilen) This is how we enable listening to added/removed direcotries ~ add support
        FILE_NOTIFY_CHANGE_LAST_WRITE,
        NULL, &dmon->overlapped, NULL
    );
    DWORD sig_result = WaitForSingleObject(dmon->overlapped.hEvent, 0);

    if (sig_result == WAIT_OBJECT_0) {
        DWORD bytes_transferred;
        GetOverlappedResult(dmon->fd_polls[0], &dmon->overlapped, &bytes_transferred, FALSE);

        FILE_NOTIFY_INFORMATION *event = (FILE_NOTIFY_INFORMATION*)change_buf;

        for (;;) {
            DWORD name_len = event->FileNameLength / sizeof(wchar_t);
            // prepare filename
            WCHAR filename[256];
            for (DWORD i = 0; i < name_len; i++) {
                filename[i] = event->FileName[i];
            }
            filename[name_len] = L'\0';
            result->name = (char*)malloc(name_len); // TODO: (Tilen) replace with a temporary alloaction
            wcstombs(result->name, filename, name_len); // because windows is special has decided to support the UTF-16, because why the fuck not
            result->name[name_len] = L'\0';
            result->name_len = name_len;

            switch (event->Action) {
                case FILE_ACTION_ADDED: {
                    result->mode = dmon_notify_CREATE;
                } break;
                case FILE_ACTION_REMOVED: {
                    result->mode = dmon_notify_DELETE;
                } break;
                case FILE_ACTION_MODIFIED: {
                    result->mode = dmon_notify_MODIFY;
                } break;
                case FILE_ACTION_RENAMED_OLD_NAME: {
                    printf("Renamed from: %ls\n", filename);
                    printf("TODO: not supported yet\n");
                } break;
                case FILE_ACTION_RENAMED_NEW_NAME: {
                    printf("Renamed to: %ls\n", filename);
                    printf("TODO: not supported yet\n");
                } break;
                default: {
                    printf("Unknown action!\n");
                } break;
            }
            // Are there more events to handle?
            if (event->NextEntryOffset) {
                *((uint8_t**)&event) += event->NextEntryOffset;
            } else {
                break;
            }
        }
        // Queue the next event
        BOOL success = ReadDirectoryChangesW(
            dmon->fd_polls[0], change_buf, 1024, TRUE,
            FILE_NOTIFY_CHANGE_FILE_NAME  |
            FILE_NOTIFY_CHANGE_DIR_NAME   |
            FILE_NOTIFY_CHANGE_LAST_WRITE,
            NULL, &dmon->overlapped, NULL);
        return true;
    }
    return false;
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
