alias blaze=bazel

# Custom installs
export PATH=$HOME/software:$PATH

# CUDA (but this failed, because radeon)
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Opencode https://opencode.ai
export PATH=$HOME/.opencode/bin:$PATH

# Add Cargo installs to the path
export PATH=$HOME/.cargo/bin:$PATH

# Add wprs to path
export PATH=$HOME/software/wprs/target/release-lto:$PATH

# Add LM Studio to path
export PATH=$HOME/.lmstudio/bin:$PATH
export GGML_CUDA_ENABLE_UNIFIED_MEMORY=ON

