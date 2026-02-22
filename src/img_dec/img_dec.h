#ifndef IMG_DEC_H_
#define IMG_DEC_H_

#ifdef WIN32
#include "../../build/windows/libheif/include/libheif/heif.h"
#endif // WIN32
#ifdef __linux__
#include "../../build/linux/libheif/include/libheif/heif_context.h"
#include "../../build/linux/libheif/include/libheif/heif_decoding.h"
#include "../../build/linux/libheif/include/libheif/heif_image.h"
#include "../../build/linux/libheif/include/libheif/heif_image_handle.h"
#endif // linux

void imgdec_decode_heif_image(const char* file_path, heif_image **himage);

#endif // IMG_DEC_H_
