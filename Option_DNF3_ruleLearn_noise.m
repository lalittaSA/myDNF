clear options

%<options>
options.optionsName = 'noise';
options.taskVar.trialMode = 'ruleLearn';
options.taskVar.nTrials = 5000; 

options.display.visualize = false;                                           % show visual representation
options.display.recordMovie = false; 

options.learning.loadWeights = false;                                         % load learned weights
% options.learning.loadWeightsOptionsName = 'weights_ruleLearn_noNoise_161101'; 

options.noise.rule = 0.1;
options.noise.spatial = 0.05;
options.noise.association = 0.2;
options.noise.reach = 0.2;
options.noise.motor = 0.1;

options.interaction.w_rs = 0.5;                                        % input to reach field on direct path (spatial-decision)
options.interaction.w_rt = 0.075*2;                                    % input to reach field from association field (association-decision)
% 
% 
options.interaction.sigma_exc = 3;
options.interaction.sigma_inh = 3;
% 
% options.interaction.w_rr_exc = 5;                                   % local excitation
options.interaction.w_rr_inh = 2;                                 % global inhibition
% options.interaction.h_r = -3;  
% 
% options.interaction.w_rm = 6; 

options.taskVar.toleranceWindow = 3;                    % max. diff between desired and actual reach position for correct trial