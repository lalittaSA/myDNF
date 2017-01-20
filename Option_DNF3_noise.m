clear options

%<options>
options.optionsName = 'noise';
options.taskVar.trialMode = 'LCESCS';
options.taskVar.nTrials = 10000; 

options.taskVar.memoryPeriod = 100;

options.display.visualize = false;                                           % show visual representation
options.display.recordMovie = false; 

options.learning.learnWeights = false;
options.learning.loadWeights = true;                                         % load learned weights
options.learning.loadWeightsOptionsName = 'weights_ruleLearn_clean_161103'; 

options.noise.rule = 0.1;
options.noise.spatial = 0.05;
options.noise.association = 0.2;
options.noise.reach = 0.2;
options.noise.motor = 0.1;

options.interaction.sigma_exc = 2.5;
options.interaction.sigma_inh = 5;

options.interaction.w_rr_exc = 3;                                   % local excitation
options.interaction.w_rr_inh = 1.5;                                 % global inhibition

options.interaction.w_rt = 0.075*2;  

% options.interaction.ruleCue.strengthFix  = 6;

options.taskVar.toleranceWindow = 3;                    % max. diff between desired and actual reach position for correct trial

options.interaction.w_rm = 5; 