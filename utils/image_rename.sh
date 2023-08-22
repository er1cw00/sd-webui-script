#!/bin/bash

if [ $# != 2 ]; then
    echo "image_rename.sh DIR PREFIX"
    echo "your command: image_rename.sh $@"
    exit 1
fi

DIR=$(realpath $1)
PREFIX=$2

if  [ ! -d "$DIR" ]; then
    echo "$DIR is not a directory."
    exit 1
fi

echo "rename all images in ${DIR} >>>>"

FILES=`ls ${DIR}`

INDEX=1
for FILE in $FILES; 
do 
    NAME="${FILE%.*}"
    EXT=${FILE##*.}
    NEW_FILE="${PREFIX}_${INDEX}.jpg"
    INDEX=$((INDEX+1))
    echo "transfor ${FILE} -> ${NEW_FILE}"
    #ffmpeg -i "${INPUT}/${FILE}" -f image2 -y -vf scale=1024:-1 "${OUTPUT}/${NEW_FILE}" 1>/dev/null 2>/dev/null
    #sips -Z 1024 "${OUTPUT}/${NEW_FILE}" 1>/dev/null 
    ffmpeg -i "${DIR}/${FILE}" -f image2 -y "${DIR}/${NEW_FILE}" 1>/dev/null 2>/dev/null
    rm "${DIR}/${FILE}"
done
