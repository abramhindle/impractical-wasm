CXX = $(HOME)/wasm/clang-8/bin/clang
CXXFLAGS = \
    -Wall \
    --target=wasm32 \
    -Os \
    -flto \
    -nostdlib \
    -fvisibility=hidden \
    -std=c++14 \
    -ffunction-sections \
    -fdata-sections
CFLAGS = \
    -Wall \
    --target=wasm32 \
    -Os \
    -flto \
    -nostdlib \
    -fvisibility=hidden \
    -std=c++14 \
    -ffunction-sections \
    -fdata-sections
LD = $(HOME)/wasm/clang-8/bin/wasm-ld
LDFLAGS = \
    --no-entry \
    --strip-all \
    --export-dynamic \
    --initial-memory=131072 \
    -error-limit=0 \
    --lto-O3 \
    -O3 \
    --gc-sections

mandel2.wasm: mandel.o
    $(LD) $(LDFLAGS) -o $@ $<
