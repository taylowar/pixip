#include "./img_dec.h"

#include <stdlib.h>
#include <stdio.h>

#include "../../build/linux/libheif/include/libheif/heif_context.h"
#include "../../build/linux/libheif/include/libheif/heif_decoding.h"
#include "../../build/linux/libheif/include/libheif/heif_image.h"
#include "../../build/linux/libheif/include/libheif/heif_image_handle.h"

void imgdec_decode_heif_image(const char* file_path, heif_image **himage)
{
    heif_context *ctx = heif_context_alloc();
    heif_error err = heif_context_read_from_file(ctx, file_path, NULL);
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
    heif_image_handle_release(handle);
}
