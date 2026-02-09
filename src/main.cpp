#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <unistd.h>
#include <dirent.h>
#include <time.h>
#include <string.h>
#include <assert.h>
#include <filesystem>

#define TALLOC_IMPLEMENTATION
#include "talloc.h"

#define SV_IMPLEMENTATION
#include "sv.h"


bool sv_equals(StringView sv, StringView other)
{
    if (sv.size != other.size) {
        return false;
    }
    for (size_t i=0;i<sv.size;++i) {
        if (sv.data[i] != other.data[i]) {
            return false;
        }
    }
    return true;
}

#ifdef WIN32
#include "../build/windows/libheif/include/libheif/heif.h"
#endif
#ifdef __linux__
#include "../build/linux/libheif/include/libheif/heif_context.h"
#include "../build/linux/libheif/include/libheif/heif_decoding.h"
#include "../build/linux/libheif/include/libheif/heif_image.h"
#include "../build/linux/libheif/include/libheif/heif_image_handle.h"
#include "../build/linux/libjpeg/include/jpeglib.h"
#endif

#include "dmon.h"

void decode_heif_image(const char* file_path, heif_image **himage)
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

typedef struct {
    char file_path[512];
    char file_name[512];
} File;

typedef struct {
    size_t capacity;
    size_t size;
    File *es;
} FilesDA;

#define FDA_INIT_CAPACITY 256
void fda_add_file(FilesDA *fda, File file)
{
    if (fda->size >= fda->capacity) {
        fda->capacity = fda->capacity == 0 ? FDA_INIT_CAPACITY : fda->capacity*2;
        fda->es = (File*)realloc(fda->es, fda->capacity*sizeof(*fda->es));
    }
    assert(fda->es != NULL && "Go buy more RAM!");
    fda->es[fda->size++] = file;
}

void fda_dir_collect(const char* dir_path, FilesDA *files)
{
    struct dirent **namelist;
    size_t n = scandir(dir_path, &namelist, NULL, NULL);
    for (size_t i=0;i<n;++i) {
        if (namelist[i]->d_name[0] != '.') {
            File file = {}; 
            snprintf(file.file_path, sizeof(file.file_path), "%s/%s", dir_path, namelist[i]->d_name);
            snprintf(file.file_name, sizeof(file.file_name), "%s", namelist[i]->d_name);
            fda_add_file(files, file);
            free(namelist[i]);
        }
    }
    free(namelist);
}

void fda_move_to_trash(const char* trash_bin_path, File file)
{
    FILE *fd = fopen(file.file_path, "r");
    if (fd == NULL) {
        fprintf(stderr, "[fda] ERROR: `%s` file does not exist!", file.file_path);
        exit(1);
    }
    size_t trash_size = snprintf(NULL, 0, "%s/%s", trash_bin_path, file.file_name);
    char* trash_file_path = (char*)talloc_reserve(trash_size+1);
    snprintf(trash_file_path, trash_size+1, "%s/%s", trash_bin_path, file.file_name);
    std::filesystem::rename(file.file_path, trash_file_path);
}

typedef struct {
    int width;
    int height;
    char file_path[512];
    int stride;
    heif_image *ref;
    const uint8_t *data;
} AbstractImage;

// take the heif elements out of the function
// make this function be called `heif_to_jpeg` which just converts heif to jpeg but does not save the jpeg beacuse that will be handled by anther function
void heif_to_abstract(File dfile, AbstractImage *aimg)
{
    heif_image *himage;
    decode_heif_image(dfile.file_path, &himage);

    int width = heif_image_get_width(himage, heif_channel_interleaved);
    int height = heif_image_get_height(himage, heif_channel_interleaved);
    int stride = 0;
    const uint8_t *data = heif_image_get_plane_readonly(himage, heif_channel_interleaved, &stride);

    aimg->width = width;
    aimg->height = height;
    aimg->stride = stride;
    aimg->data = data;
    aimg->ref = himage;
    strcpy(aimg->file_path, dfile.file_path);

    printf("------------------------------------------------------------\n");
    printf("%s: %d <> %d\n", dfile.file_name, width, height);
    printf("------------------------------------------------------------\n");
}

void abstract_to_jpeg(AbstractImage aimg, unsigned int quality) 
{
    StringView no_ext_name = sv_chop_until_delim(SV(aimg.file_path), '.');
    char *jpeg_file_name = (char*)malloc(no_ext_name.size + 1 + 4 + 1);
    snprintf(jpeg_file_name, no_ext_name.size + 1 + 4 + 1, SV_Fmt".jpeg", SV_ARG(no_ext_name));
    jpeg_compress_struct cinfo;
    jpeg_error_mgr jerr;

    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_compress(&cinfo);

    FILE *outfile = fopen(jpeg_file_name, "wb");
    if (!outfile) {
        perror("fopen");
        exit(1);
    }
    jpeg_stdio_dest(&cinfo, outfile);

    cinfo.image_width = aimg.width;
    cinfo.image_height = aimg.height;
    cinfo.input_components = 3; // RGB
    cinfo.in_color_space = JCS_RGB;

    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, quality, TRUE);
    jpeg_start_compress(&cinfo, TRUE);

    while (cinfo.next_scanline < cinfo.image_height) {
        JSAMPROW row_pointer[1];
        row_pointer[0] = (JSAMPROW)(aimg.data + cinfo.next_scanline * aimg.stride);
        jpeg_write_scanlines(&cinfo, row_pointer, 1);
    }

    jpeg_finish_compress(&cinfo);
    fclose(outfile);
    jpeg_destroy_compress(&cinfo);
}

int main(void)
{
    const char* dir_path = "/home/tilc/dev/programming/c/pixip/testing";
    const char* trash_bin = "/home/tilc/dev/programming/c/pixip/testing/trash-bin";

    Dmon dmon = {};
    dmon_init(&dmon);
    dmon_register_directory(&dmon, dir_path, dmon_notify_CREATE);

    bool job_mark = false;

    time_t start;
    time_t end;
    while (1) {
        Dmon_Notify_Result result = {};
        if (dmon_poll_result(&dmon, &result)) {
            if (job_mark) {
                end = time(0);
                time_t dts = end-start;
                if (dts >= 1) {
                    FilesDA files = {};
                    fda_dir_collect(dir_path, &files);
                    for (size_t i=0;i<files.size;++i) {
                        File dfile = files.es[i];
                        if (cstr_ends_with(dfile.file_name, ".heic") || cstr_ends_with(dfile.file_name, ".heif")) {
                            AbstractImage aimg;
                            heif_to_abstract(dfile, &aimg);
                            abstract_to_jpeg(aimg, 10);
                            heif_image_release(aimg.ref);
                            fda_move_to_trash(trash_bin, dfile);
                        } else {
                            printf("[pixip] INFO: skipping processing of `%s`\n", dfile.file_name);
                        }
                    }
                    printf("DONE!\n");
                    job_mark = false;
                }
            }
            // event trigger when a heic image is added
            if (result.fso_type == dmon_fso_FILE) {
                talloc_reset();
                if (cstr_ends_with(result.name, ".heic") || cstr_ends_with(result.name, ".heif")) {
                    start = time(0);
                    job_mark = true;
                } 
                else if (cstr_ends_with(result.name, ".jpeg")) {
                    // TODO: introduce custom log
                    printf("[pixip] INFO: ignoring `%s`\n", result.name);
                }
                else {
                    // TODO: introduce custom log
                    fprintf(stderr, "[pixip] ERROR: `%s` is not supported yet\n", result.name);
                    printf("[pixip] INFO: Current support is only for `heic` to `jpeg`\n");
                }
            }
        }
    }
    return 0;
}
