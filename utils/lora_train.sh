#!/bin/bash

set -e
# 设置工作路径
AI_PATH=/Users/wadahana/workspace/AI
KOHYA_SS_PATH=${AI_PATH}/sd-scripts
SD_WEBUI_PATH=${AI_PATH}/stable-diffusion-webui

# 训练集路径
NAME=wulei
TRAIN_DATA_PATH=${AI_PATH}/trains/${NAME}/images
OUTPUT_PATH=${AI_PATH}/trains/${NAME}/output
LOG_PATH=${AI_PATH}/trains/${NAME}/log
SAMPLE_PATH=${AI_PATH}/trains/${NAME}/sample
REGER_PATH=""

# 基础模型
#CHECKPOINT=chilloutmix_NiPrunedFp32Fix.safetensors
CHECKPOINT=v1-5-pruned-emaonly.safetensors
BASE_CHECKPOINT=${SD_WEBUI_PATH}/models/Stable-diffusion/${CHECKPOINT}

# 
N_RESOLUTION='512,512'
N_MAX_EPOCHS=10
N_SAVE_EPOCHS=1
N_MIN_RESOLUTION=512
N_MAX_RESOLUTION=1024
MIXED_PRECISION="fp16"

USE_SAVE_STATE="ON"
USE_OPTIMIZER="OFF"

if [ "${USE_SAVE_STATE}" == "ON"]; then
    SAVE_STATE="--save_state"
else 
    SAVE_STATE=""
fi

if [ "${USE_OPTIMIZER}" == "ON" ]; then
    OPTIMIZER="Lion"
    XFORMERS="--optimizer_type=${OPTIMIZER} --xformers"
else
    XFORMERS=""
fi

echo "data path:       ${TRAIN_DATA_PATH}"
echo "log path:        ${LOG_PATH}"
echo "sample path:     ${SAMPLE_PATH}"
echo "output path:     ${OUTPUT_PATH}"

echo "base model:      ${BASE_CHECKPOINT}"
echo "resolution:      ${N_RESOLUTION}"
echo "max epochs:      ${N_MAX_EPOCHS}"
echo "save epochs:     ${N_SAVE_EPOCHS}"
echo "mixed precision: ${MIXED_PRECISION}"

#     --max_train_steps=${MAX_STEP}
#     --color-aug 
#            --sample_every_n_epochs=1 \
#            --sample_prompts=${SAMPLE_PATH} \
# repeat count * image num * epoch < max
# https://zhuanlan.zhihu.com/p/610779658

accelerate launch \
            --num_cpu_threads_per_process 1    \
            ${KOHYA_SS_PATH}/train_network.py  \
            --pretrained_model_name_or_path=${BASE_CHECKPOINT} \
            --train_data_dir=${TRAIN_DATA_PATH} \
            --output_dir=${OUTPUT_PATH} \
            --logging_dir=${LOG_PATH} \
            --log_prefix="${NAME}_" \
            --reg_data_dir='' \
            --prior_loss_weight=1.0 \
            --resolution=${N_RESOLUTION} \
            --min_bucket_reso=${N_MIN_RESOLUTION} \
            --max_bucket_reso=${N_MAX_RESOLUTION} \
            --train_batch_size=1 \
            --learning_rate=1e-4 \
            --mixed_precision=${MIXED_PRECISION} \
            --max_train_epochs=${N_MAX_EPOCHS} \
            ${XFORMERS} \
            ${SAVE_STATE} \
            --mixed_precision=no \
            --save_every_n_epochs=${N_SAVE_EPOCHS} \
            --save_model_as=safetensors \
            --clip_skip=1 \
            --seed=3407 \
            --network_module=networks.lora
