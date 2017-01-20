clear options

%<options>
options.optionsName = 'ruleLearn_clean';
options.taskVar.trialMode = 'ruleLearn';
options.taskVar.nTrials = 5000; 

options.taskVar.memoryPeriod = 200;

options.display.visualize = false;                                           % show visual representation
options.display.recordMovie = false; 

options.learning.loadWeights = false;                                         % load learned weights
% options.learning.loadWeights = true;                                         % load learned weights
% options.learning.loadWeightsOptionsName = 'weights_ruleLearn_clean_161103'; 


% options.interaction.w_rs = 4;  
% options.interaction.w_rt = 0.075;                                    % input to reach field from association field (association-decision)
% 
% 
options.interaction.sigma_exc = 2.5;
options.interaction.sigma_inh = 20;
% 
options.interaction.w_rr_exc = 2.5;                                   % local excitation
options.interaction.w_rr_inh = 10;                                 % global inhibition
% options.interaction.h_r = -3;  
% 
% options.interaction.w_rm = 6; 

options.taskVar.toleranceWindow = 5;                    % max. diff between desired and actual reach position for correct trial

options.interaction.ruleCue.strengthFix  = 6;
options.interaction.h_c = -3;
options.interaction.w_cc_exc = 20;                                  % self-excitation rule-rule
options.interaction.w_cc_inh = 5; 
