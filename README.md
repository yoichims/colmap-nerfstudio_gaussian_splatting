# colmap-nerfstudio_gaussian_splatting
A simple conda environment to run colmap and nerf studio gaussian splatting.

## Installation

```bash
conda create --name nerfstudio -y python=3.10
conda activate nerfstudio

conda install pytorch torchvision torchaudio pytorch-cuda=12.1 -c pytorch -c nvidia
pip install nerfstudio==1.1.5
conda install -c conda-forge colmap
./create_splat.sh
```
