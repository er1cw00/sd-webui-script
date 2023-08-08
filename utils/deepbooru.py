import os
import sys
import getopt
import torch
import argparse
from PIL import Image
from modules import devices, cmd_args
from modules.deepbooru import DeepDanbooru

parser = argparse.ArgumentParser()
parser.add_argument("--path", type=str, help="input images path")
parser.add_argument("--token", type=str, help="input key token")
opt = parser.parse_args()

path = opt.path
token = opt.token

if not os.path.exists(path):
    print(f'image path: {path} not exist!')
    sys.exit(2)

print(f'start tag images in: {path}')

devices.dtype = torch.float32

x = DeepDanbooru()
x.load()
x.start()

images_exts = ['.png', '.jpg', '.jpeg', '.bmp']
for filename in os.listdir(path):
    t = os.path.splitext(filename)
    if len(t) != 2 : 
        print(f'unknown file: {filename}')
        continue
    if not t[1] in images_exts:
        print(f'unknown file ext: {filename}')
        continue

    img_path = os.path.join(path, filename)
    tag_path = os.path.join(path, t[0] + '.txt')
    print(f'deepbooru: {filename} -> {tag_path}')
    img = Image.open(img_path)
    tag = x.tag(img)
    if len(tag) == 0:
        print('not tag for {filename} !');
        continue
    if len(token) > 0:
        tag = token + ", " + tag 
    with open(tag_path, "w", errors='ignore') as f:
        f.writelines(tag)

x.stop()