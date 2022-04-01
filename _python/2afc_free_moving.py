# -*- coding: utf-8 -*-
"""
Created on Fri Apr  1 10:48:43 2022

@author: Kath
"""

#%% IMPORT

import os
import serial

#%% temporary definitions
mouse = 'test';
baseDir = 'D:\\Github\\2AFC-wheel\\_python';
os.chdir(baseDir)
project = 'spatial_adaptation_free';
parameterFile = os.path.join(baseDir,'projects\\spatial_adaptation\\spatial_adaptor_training_params')

#%% setup base directories etc
cd(baseDir);
params.basePath = pwd;
params.projPath = [params.basePath filesep 'projects' filesep project];
params.paramFile = [params.projPath filesep parameterFile];
params.hexFile = [params.basePath filesep 'hexFiles' filesep 'wheel_interrupter_bit_noStimDetect.ino.hex'];
params.dataPath = [params.basePath filesep 'mice' filesep mouse];
git = strfind(params.basePath,'GitHub');
params.githubPath = params.basePath(1:git+5);
params.sessID = datestr(now,'yyyymmdd_HHMM');