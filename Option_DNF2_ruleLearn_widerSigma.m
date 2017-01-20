clear options

%<options>
options.optionsName = 'ruleLearn_widerSigma';
options.taskVar.trialMode = 'ruleLearn';
options.taskVar.nTrials = 5000; 

options.display.visualize = false;                                           % show visual representation
options.display.recordMovie = false;

options.learning.saveWeights = true;                                         % save learned weights
options.learning.overwriteWeights = false;
options.learning.loadWeights = false;  

% options.noise.rule = 0.05;
% options.noise.spatial = 0.1;
% options.noise.association = 0.2;
% options.noise.reach = 0.2;
% options.noise.motor = 0.1;

options.interaction.sigma_exc = 3;                                % width of local self-excitation
options.interaction.sigma_inh = 9;                                % width of lateral inhibition
