# Pixip

This project aims to implement a locally running program that monitors a specified directory for newly added images and applies automated image compression to reduce their file size to a predefined target

---

## Configurations

* Located "nearby" in the same directory and same level as the executable
  - some_dir/
      |- pixip.exe
      |- pixip.conf

|        key         | description                                  |
| ------------------ | -------------------------------------------- |
| `monitor_dir_path` | Full dirpath to directory to monitor         |
| `trash_bin_path`   | Full dirpath to directory used as a trasbin  |

---

* `libde265` is a decoder for the `H.265` video format which can be found in `HEIF` video containers 
* `libheif` is a library for reading, writing, and manipulating `HEIF`/`HEIC` containers, including images (HEIC) and image sequences or video that may be encoded with codecs such as `H.265`

---

## References
- `MinGW` - https://www.mingw-w64.org
- `libde265` - https://github.com/strukturag/libde265
- `libheif` - https://github.com/strukturag/libheif 
