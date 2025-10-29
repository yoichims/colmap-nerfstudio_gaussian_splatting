# COLMAP + Nerfstudio Gaussian Splatting

A streamlined conda environment for running COLMAP and Nerfstudio's Gaussian Splatting implementation. This setup provides everything needed to create high-quality 3D Gaussian Splats from videos or image collections.

## Overview

This project combines:
- **COLMAP**: Structure-from-Motion for camera pose estimation
- **Nerfstudio**: Modern NeRF framework with Gaussian Splatting support
- **Splatfacto**: Nerfstudio's optimized Gaussian Splatting implementation

## Prerequisites

- NVIDIA GPU with CUDA support (recommended: RTX 3060 or better)
- CUDA 12.1 installed on your system
- Conda or Miniconda
- ~10GB free disk space

## Installation

### Step 1: Create and activate environment

```bash
conda create --name nerfstudio -y python=3.10
conda activate nerfstudio
```

### Step 2: Install PyTorch with CUDA support

```bash
conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
```

### Step 3: Install Nerfstudio

```bash
pip install nerfstudio==1.1.5
```

### Step 4: Install COLMAP

```bash
conda install -c conda-forge colmap
```

### Step 5: Run the setup script

```bash
./create_splat.sh
```

## Usage

### Process a video

```bash
ns-process-data video --data /path/to/video.mp4 --output-dir /path/to/output
```

### Train Gaussian Splatting

```bash
ns-train splatfacto --data /path/to/output
```

### View results

```bash
ns-viewer --load-config /path/to/output/splatfacto/*/config.yml
```

## Verify Installation

Check that everything is installed correctly:

```bash
# Check Nerfstudio
ns-train --help

# Check COLMAP
colmap -h

# Check CUDA availability
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## Troubleshooting

**CUDA version mismatch**: If you have a different CUDA version, adjust the pytorch-cuda version:
- For CUDA 11.8: `pytorch-cuda=11.8`
- For CUDA 12.4: `pytorch-cuda=12.4`

**COLMAP not found**: Ensure conda-forge channel is added:
```bash
conda config --add channels conda-forge
```

**Out of memory during training**: Reduce batch size or number of iterations in training command.

## Resources

- [Nerfstudio Documentation](https://docs.nerf.studio/)
- [COLMAP Documentation](https://colmap.github.io/)
- [Gaussian Splatting Paper](https://repo-sam.inria.fr/fungraph/3d-gaussian-splatting/)

## License

This setup uses open-source tools. Please refer to individual project licenses:
- Nerfstudio: Apache 2.0
- COLMAP: BSD License