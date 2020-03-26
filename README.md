#  qt wasm build

docker run -v $PWD/build_wasm:/project/build -v $PWD:/project/source qt541-wasm-with-thread:latest
