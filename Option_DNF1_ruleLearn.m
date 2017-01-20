clear options

%<options>
options.optionsName = 'ruleLearn';
options.taskVar.trialMode = 'ruleLearn'; 

% options.interaction.h_c = 0;
% options.interaction.h_s = 2;
% options.interaction.h_t = 2; 
% options.interaction.h_r = 3;
% options.interaction.h_m = 0;
% options.interaction.reachThreshold = 5;

% options.taskVar.memoryPeriod = 500;  
% options.interaction.tau = 10;
% options.interaction.beta = 5;

options.taskVar.trialLength = 1000;

options.field.size_s = 88;
options.interaction.sigma_exc = options.field.size_s/12;                               
options.interaction.sigma_inh = options.field.size_s/6;
% options.learning.loadWeights = false; 
