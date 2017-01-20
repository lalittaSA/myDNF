clear options

%<options>
options.optionsName = 'noise_lessBias';
options.taskVar.trialMode = 'LCESCS';
options.taskVar.nTrials = 10000; 

options.display.visualize = false;                                           % show visual representation
options.display.recordMovie = false; 

options.learning.loadWeights = true;                                         % load learned weights
options.learning.loadWeightsOptionsName = 'weights_ruleLearn_noNoise_161101'; 

options.noise.rule = 0.1;
options.noise.spatial = 0.05;
options.noise.association = 0.2;
options.noise.reach = 0.2;
options.noise.motor = 0.1;