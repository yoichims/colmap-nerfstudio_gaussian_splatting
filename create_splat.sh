#!/bin/bash

# ==============================================================================
#           Full 3D Reconstruction Pipeline Script (Streamlined)
# ==============================================================================
#
# This script automates the core Gaussian Splatting pipeline.
# The optional, problematic COLMAP dense reconstruction step has been removed
# to ensure compatibility with all COLMAP builds.
#
# Optional Flags:
#   --export-colmap-sparse : Generate only the sparse .ply model from COLMAP.
#   --cpu-only             : Force all steps to run on the CPU.
#
# Usage:
#   - Default (GPU, Fast): ./create_splat.sh
#   - With Sparse Export:  ./create_splat.sh --export-colmap-sparse
#   - CPU Only Mode:       ./create_splat.sh --cpu-only
#

# --- Configuration (IMPORTANT: EDIT THESE VALUES) ---
CONDA_ENV_NAME="nerfstudio-fixed"
#VIDEO_FILE="/home/yoichims/Dropbox/Research/colmap_depth_gsplat/datasets_gs/kiosk/mini_kiosk.mp4"
# VIDEO_FILE="/home/yoichims/Dropbox/araya/IMG_1370.MOV"
VIDEO_FILE="/home/yoichims/Dropbox/Research/colmap_depth_gsplat/datasets_gs/office/office_cut.mp4"
PROJECT_DIR="/home/yoichims/nerf-projects/my-first-splat"
GS_DENSE_CLOUD_POINTS=1000000

# --- Script Control ---
EXPORT_COLMAP_SPARSE=false
USE_CPU_ONLY=false
for arg in "$@"
do
    if [ "$arg" == "--export-colmap-sparse" ]; then
        EXPORT_COLMAP_SPARSE=true
    fi
    if [ "$arg" == "--cpu-only" ]; then
        USE_CPU_ONLY=true
    fi
done

# --- Script Logic ---
set -e # Exit immediately if a command fails.

echo ">>> Starting Streamlined 3D Reconstruction Pipeline <<<"
# Define command prefixes based on flags
if [ "$USE_CPU_ONLY" = true ]; then
    echo "INFO: --cpu-only flag detected. Hiding GPU from processes."
    CMD_PREFIX="env CUDA_VISIBLE_DEVICES=-1"
else
    echo "INFO: Running in default GPU mode."
    CMD_PREFIX=""
fi
if [ "$EXPORT_COLMAP_SPARSE" = true ]; then
    echo "INFO: --export-colmap-sparse flag detected. Sparse COLMAP .ply model will be generated."
fi

# Create project directory if it doesn't exist
DATA_DIR="$PROJECT_DIR/data"
OUTPUTS_DIR="$PROJECT_DIR/outputs"
mkdir -p "$DATA_DIR"
mkdir -p "$OUTPUTS_DIR"
echo "Project directory is at: $PROJECT_DIR"

# Activate the conda environment
echo "Activating conda environment: $CONDA_ENV_NAME"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV_NAME"

# Check if video file exists
if [ ! -f "$VIDEO_FILE" ]; then
    echo "Error: Video file not found at '$VIDEO_FILE'"
    exit 1
fi

# Step 1: Process the video data
echo -e "\n--- Step 1: Processing video data with COLMAP (Sparse) ---"
$CMD_PREFIX ns-process-data video --data "$VIDEO_FILE" --output-dir "$DATA_DIR"
echo "Sparse processing complete."

# Conditional Step: Export COLMAP's sparse reconstruction
if [ "$EXPORT_COLMAP_SPARSE" = true ]; then
    echo -e "\n--- Exporting COLMAP's sparse reconstruction ---"
    COLMAP_SPARSE_DIR="$DATA_DIR/colmap/sparse/0"
    SPARSE_PLY_FILE="$PROJECT_DIR/colmap_sparse_reconstruction.ply"
    if [ -d "$COLMAP_SPARSE_DIR" ]; then
        echo "Exporting sparse model to $SPARSE_PLY_FILE"
        colmap model_converter --input_path "$COLMAP_SPARSE_DIR" --output_path "$SPARSE_PLY_FILE" --output_type PLY
        echo "COLMAP sparse PLY model exported successfully."
    else
        echo "Warning: Could not find COLMAP sparse model directory. Skipping export."
    fi
fi

# Step 2: Train the Gaussian Splatting model
echo -e "\n--- Step 2: Training the Gaussian Splatting model ---"
$CMD_PREFIX ns-train splatfacto --data "$DATA_DIR" --output-dir "$OUTPUTS_DIR" --project-name "$(basename "$PROJECT_DIR")"
echo "Training finished."

# Step 3: Export high-density point cloud from trained Gaussian Splatting model
echo -e "\n--- Step 3: Exporting high-density point cloud from GS model ---"
CONFIG_FILE=$(find "$OUTPUTS_DIR/$(basename "$PROJECT_DIR")/splatfacto" -type f -name "config.yml" | sort | tail -n 1)
if [ -f "$CONFIG_FILE" ]; then
    GS_DENSE_PLY_FILE="$PROJECT_DIR/gs_dense_point_cloud.ply"
    echo "Exporting $GS_DENSE_CLOUD_POINTS points to $GS_DENSE_PLY_FILE..."
    $CMD_PREFIX ns-export pointcloud --load-config "$CONFIG_FILE" --output-path "$GS_DENSE_PLY_FILE" --num-points "$GS_DENSE_CLOUD_POINTS" --remove-outliers True --save-world-frame True
    echo "Gaussian Splatting dense point cloud exported successfully."
else
    echo "Warning: Could not find a config.yml file. Skipping GS dense point cloud export."
fi

echo -e "\n--- Pipeline Finished ---"
echo "All outputs are saved in: $PROJECT_DIR"

# Deactivate conda environment
conda deactivate