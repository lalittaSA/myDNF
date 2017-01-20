clear options

%<options>
options.optionsName = 'clean';
options.taskVar.trialMode = 'LCESCS';
options.taskVar.nTrials = 1000; 

options.taskVar.memoryPeriod = 200;

options.display.visualize = false;                                           % show visual representation
options.display.recordMovie = false; 

options.learning.learnWeights = false; 
options.learning.loadWeights = true;                                         % load learned weights
options.learning.loadWeightsOptionsName = 'weights_ruleLearn_clean_161103'; 

% options.taskVar.biasCue.level = [3,3];


% options.noise.rule = 0.1;
% options.noise.spatial = 0.05;
% options.noise.association = 0.2;
% options.noise.reach = 0.2;
% options.noise.motor = 0.1;

% options.taskVar.probabilityCS = 1;
% options.taskVar.memoryPeriod = 50;

% options.interaction.w_rs = 4;                                        % input to reach field on direct path (spatial-decision)
options.interaction.w_rt = 0.075*2;                                    % input to reach field from association field (association-decision)

options.interaction.sigma_exc = 3;
options.interaction.sigma_inh = 3;
% 
options.interaction.w_rr_exc = 2.5;                                   % local excitation
options.interaction.w_rr_inh = 5;                                 % global inhibition
% options.interaction.h_r = -3;  

% options.interaction.w_cc_exc = 20;                                  % self-excitation rule-rule
% options.interaction.w_cc_inh = 5; 
% 
options.interaction.ruleCue.strengthFix  = 10;
% options.interaction.h_c = -2;
% 
% options.interaction.w_rm = 6; 

options.taskVar.toleranceWindow = 3;                    % max. diff between desired and actual reach position for correct trial

% 
