#include <stdio.h>

#ifdef WIN32
#include "../build/windows/libheif/include/libheif/heif.h"
#endif
#ifdef __linux__
#include "../build/linux/libheif/include/libheif/heif.h"
#endif

int main(int argc, char** argv)
{
    if (argc < 2) {
        fprintf(stderr, "ERROR: missing input parameter\n");
        return 1;
    }
    const char* input = argv[1];
    struct heif_context *ctx = heif_context_alloc();
    struct heif_error err = heif_context_read_from_file(ctx, input, NULL);
    if (err.code != heif_error_Ok) {
        fprintf(stderr, "Failed to read HEIF: %s\n", err.message);
        return 1;
    }

    struct heif_image_handle *handle;
    err = heif_context_get_primary_image_handle(ctx, &handle);
    if (err.code != heif_error_Ok) {
        fprintf(stderr, "Failed to get primary image: %s\n", err.message);
        return 1;
    }

    struct heif_image *img;
    err = heif_decode_image(handle, &img, heif_colorspace_RGB, heif_chroma_interleaved_RGB, NULL);
    if (err.code != heif_error_Ok) {
        fprintf(stderr, "Failed to decode image: %s\n", err.message);
        return 1;
    }

    int width = heif_image_get_width(img, heif_channel_interleaved);
    int height = heif_image_get_height(img, heif_channel_interleaved);
    printf("%d <> %d\n", width, height);
    return 0;
}
