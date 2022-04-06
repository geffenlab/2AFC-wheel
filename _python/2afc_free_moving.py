# -*- coding: utf-8 -*-
"""
Created on Fri Apr  1 10:48:43 2022

@author: Kath
"""

#%% IMPORT

import os
import serial
from scipy import io as scio
import common_code as cc
from datetime import datetime

#%% temporary definitions
mouse = 'test'
baseDir = 'D:\\Github\\2AFC-wheel\\_python'
os.chdir(baseDir)
project = 'spatial_adaptation_free'
parameterFile = 'SA_params.mat'


#%% load parameter file and setup base directories etc
# load parameters
beh_info = scio.loadmat(os.path.join(baseDir,'projects',project,parameterFile))
params = cc.matlab_struct2dict(beh_info['params'])
stimInfo = cc.matlab_struct2dict(beh_info['stimInfo'])

# set new directories and paths to files in parameters
os.chdir(baseDir)
params['basePath'] = os.curdir
params['projPath'] = os.path.join(params['basePath'],'projects',project)
params['paramFile'] = os.path.join(params['projPath'], parameterFile)
params['hexFile'] = os.path.join(params['basePath'],'hexFiles','wheel_interrupter_bit_noStimDetect.ino.hex')
params['dataPath'] = os.path.join(params['basePath'], 'mice', mouse)
now = datetime.now()
params['sessID'] = now.strftime("%Y%m%d_%H%M")

#%% open a file to write to
params['fn'] = mouse + '_' + params['sessID'] + '_' + params['taskType'] + '.txt'
fn_path = os.path.join(params['dataPath'],params['fn'])

fid = open(fn_path, 'w')

