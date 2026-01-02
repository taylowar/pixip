#include <stdlib.h>
#include <stdio.h>

#ifdef WIN32
#include "../build/windows/libheif/include/libheif/heif.h"
#endif
#ifdef __linux__
#include "../build/linux/libheif/include/libheif/heif_context.h"
#include "../build/linux/libheif/include/libheif/heif_decoding.h"
#include "../build/linux/libheif/include/libheif/heif_image.h"
#endif

#define DMON_IMPLEMENTATION
#include "dmon.h"

void decode_heif_image(const char* file_path, struct heif_image **himage)
{
    struct heif_context *ctx = heif_context_alloc();
    struct heif_error err = heif_context_read_from_file(ctx, file_path, NULL);
    if (err.code != heif_error_Ok) {
        fprintf(stderr, "Failed to read HEIF: %s\n", err.message);
        exit(1);
    }

    struct heif_image_handle *handle;
    err = heif_context_get_primary_image_handle(ctx, &handle);
    if (err.code != heif_error_Ok) {
        fprintf(stderr, "Failed to get primary image: %s\n", err.message);
        exit(1);
    }

    err = heif_decode_image(handle, himage, heif_colorspace_RGB, heif_chroma_interleaved_RGB, NULL);
    if (err.code != heif_error_Ok) {
        fprintf(stderr, "Failed to decode image: %s\n", err.message);
        exit(1);
    }
    heif_context_free(ctx);
}

char* args_shift(int *argc, char** *argv)
{
    char* result = **argv;
    (*argc) -= 1;
    (*argv) += 1;
    return result;
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

int main(void)
{
    // if (argc < 2) {
    //     fprintf(stderr, "ERROR: missing input parameter\n");
    //     return 1;
    // }

    Dmon dmon = {};
    dmon_init(&dmon);
    dmon_register_directory(&dmon, "/home/tilc/dev/programming/c/pixip/testing" , dmon_notify_CLOSE_WRITE);

    Dmon_Notify_Result result;
    while (1) {
        dmon_await_poll_result(&dmon, &result);
        dmon_print_notify_result(result);
        // if (result.fso_type == dmon_fso_FILE) {
        //     char full_image_path[256];
        //     snprintf(full_image_path, 256, "/home/tilc/dev/programming/c/pixip/testing/%s", result.name); 
        //     struct heif_image *img = {0};
        //     decode_heif_image(full_image_path, &img);
        //     int width = heif_image_get_width(img, heif_channel_interleaved);
        //     int height = heif_image_get_height(img, heif_channel_interleaved);
        //     printf("------------------------------------------------------------\n");
        //     printf("fullname: `%s`\n", full_image_path);
        //     printf("%d <> %d\n", width, height);
        //     printf("------------------------------------------------------------\n");
        // }
    }
    return 0;
}
