%% new dynamic neural field adapted from Klaes et al
% field list
% spatial field - s (1D)
% rule field - c (1D; previously 2 neurons -> now expanded to alternative field: n neurons = n alternative goals)
% task association field - t (2D)
% planning field - r
% motor field - m

function Script_DNF1(options)

if nargin < 1
    options.optionsName = 'default';          
end
    
%%%%%%%%%%%%%%%%%%%
% set result path %
%%%%%%%%%%%%%%%%%%%

ST = dbstack;
funcName = ST.name;
resultPath = checkDirectory(['.' filesep],['results_' funcName],1);
resultPath = [resultPath filesep];

%%%%%%%%%%%%%%%%%%%%%%%%%
% set default variables %
%%%%%%%%%%%%%%%%%%%%%%%%%

defaultOptions.optionsName = 'default';

defaultOptions.display.visualize = true;                                           % show visual representation
defaultOptions.display.recordMovie = false;                                        % store visualization as avi-movie
defaultOptions.display.movieFile = [funcName '_movie.avi'];                           % file name for movie
defaultOptions.display.visualizeActivityPlot = false;                               % if visualize is true an activity plot of the PRR layer is plotted
defaultOptions.display.activityPlotOffset = 5;                                     % baseline activity offset for visualized activity plot

defaultOptions.display.breakOnReachPlan = false;                                    % end trial once reach plan is formed

defaultOptions.display.pauseAfterTrial = false;                                    % pause after trial (only usefull when visualizing)
defaultOptions.display.dispTrials = true;
defaultOptions.display.learningCurve = true;

% architecture settings
defaultOptions.field.size_c = 2;                                             % number of rule neurons for this NF model version
defaultOptions.field.size_s = 88;                                            % size of the spatial stimulus field (also determines sizes of association and reach field)
defaultOptions.field.size_t = 16;                                            % determines size of association field rule dimension

defaultOptions.field.scale_t = 4;

% task options
defaultOptions.taskVar.trialMode = 'LCES';                          % 'LCES' or 'LCESCS' or 'ruleLearn'
defaultOptions.taskVar.probabilityCS = 0.2;                        % probability of a CS trial if LCESCS mode is chosen
defaultOptions.taskVar.nTrials = 1000;                               % number of trials
defaultOptions.taskVar.trialLength = 1000;                           % maximum length of a trial

defaultOptions.taskVar.spatialCue.number = 4;
defaultOptions.taskVar.spatialCue.randomizerMode = 1;                        % 0 = constant position; 1 = random position
defaultOptions.taskVar.spatialCue.durationFix = 100;       % duration of spatial cue
defaultOptions.taskVar.spatialCue.durationVar = 0;
defaultOptions.taskVar.spatialCue.startTimeFix = 20;           % fix start time of cue presentation
defaultOptions.taskVar.spatialCue.startTimeVar = 0;


defaultOptions.taskVar.ruleCue.number = 2;

n_c = defaultOptions.taskVar.ruleCue.number;
defaultOptions.taskVar.ruleCue.position = num2cell(1:n_c);          % valid positions for the rule cue in the rule field

defaultOptions.taskVar.ruleCue.randomizerMode = 1;                              % mode for randomizing mapping (0=constant; 1=random w/o history; 2=balanced)
defaultOptions.taskVar.ruleCue2.randomizerMode = 0;                             % mode for second rule cue
defaultOptions.taskVar.ruleCue.probabilities = ones(1,n_c)/n_c;                 % probabilities for random mappingMode choice
defaultOptions.taskVar.ruleCue2.probabilities = ones(1,n_c)/n_c;                % probabilities for second rule cue
defaultOptions.taskVar.ruleCue.balancingNo = 2 * ones(n_c,1);                   % number of trials to look back for balanced reward strategy in CS trials

defaultOptions.taskVar.ruleCue.matrix = eye(n_c);                               % translation of rule cue position to probability of a rule being used (column = rule cue position; row = rule)
defaultOptions.taskVar.ruleCue.code = num2cell(1:n_c);
switch n_c
    case 2
        defaultOptions.taskVar.ruleCue.name = {'cw' 'ccw'};                     % identifier of mapping rule belonging to mapping (cw and ccw implemented)
    case 4
        defaultOptions.taskVar.ruleCue.name = {'pro' 'anti' 'cw' 'ccw'};
    otherwise
        error('invalid task setting: rule numbers can be 2 or 4');
end

       

defaultOptions.ruleLearn.decay = 0.001;                    % per trial decay rate of second stimulus for ruleLearn
defaultOptions.ruleLearn.secondStart = -100;               % start of second cue for ruleLearn relative to go cue
defaultOptions.ruleLearn.secondDuration = 100;             % length of second cue for ruleLearn 


defaultOptions.taskVar.ruleCue.durationFix = 100;           % duration of rule cue
defaultOptions.taskVar.ruleCue.durationVar = 0;             % variable duration (random amount added to durationFix to determine start)
defaultOptions.taskVar.ruleCue.startTimeFix = 20;           % fix start time of cue presentation
defaultOptions.taskVar.ruleCue.startTimeVar = 0;
defaultOptions.taskVar.goSignal.startTimeFix = 0;           % start of go signal relative to cue and memory period
defaultOptions.taskVar.goSignal.startTimeVar = 0;
defaultOptions.taskVar.memoryPeriod = 100;                  % length of memory period for LCES etc.

defaultOptions.taskVar.toleranceWindow = 2;                    % max. diff between desired and actual reach position for correct trial

% network interaction strengths
defaultOptions.interaction.spatialCue.strengthFix  = 6;                % fix strength of cue
defaultOptions.interaction.spatialCue.strengthVar  = 0;                % variable strength of cue
defaultOptions.interaction.ruleCue.strengthFix  = 6;                % fix strength of cue
defaultOptions.interaction.ruleCue.strengthVar  = 0;                % variable strength of cue
defaultOptions.interaction.goSignal.strengthFix = 6;                % strength of boost (equivalent to a gaiting induced by go signal) 
defaultOptions.interaction.goSignal.strengthVar = 0;

% common parameters for all fields and nodes
defaultOptions.interaction.tau = 20;                                       % time constant
defaultOptions.interaction.beta = 1;                                       % steepness of output function
defaultOptions.interaction.sigma_exc = 2.5;                                % width of local self-excitation
defaultOptions.interaction.sigma_inh = 7.5;                                % width of lateral inhibition
defaultOptions.interaction.sigma_cc = 2.5;                                 % for rule dimension of field t

% rule cue nodes
defaultOptions.interaction.h_c = -3;                                       % resting level rule
defaultOptions.interaction.w_cc_exc = 10;                                  % self-excitation rule-rule
defaultOptions.interaction.w_cc_inh = 2.5;                                 % mutual inhibition rule-rule

% spatial perception field
defaultOptions.interaction.h_s = -3;                                       % resting level spatial
defaultOptions.interaction.w_ss_exc = 7.5;                                 % local self-excitation spatial-spatial
defaultOptions.interaction.w_ss_inh = 5;                                   % lateral inhibition spatial-spatial

% task association
defaultOptions.interaction.h_t = -3;                                       % resting level association
defaultOptions.interaction.w_tt_exc = 22.5;                                % local self-exc. in both dimensions
defaultOptions.interaction.w_tt_inh = 0.125;                                % global inhibition

% inputs to task associaction field
defaultOptions.interaction.w_tc = 4;                                       % rule-association interaction strength
defaultOptions.interaction.w_ts = 5;                                       % spatial-association interaction strength

% reach planning field
defaultOptions.interaction.h_r = -2;                                       % resting level planning
defaultOptions.interaction.w_rr_exc = 4;                                   % local excitation
defaultOptions.interaction.w_rr_inh = 0.25;                                 % global inhibition

defaultOptions.interaction.w_rs = 5;                                        % input to reach field on direct path (spatial-decision)
defaultOptions.interaction.w_rt = 0.075;                                    % input to reach field from association field (association-decision)

% motor field
defaultOptions.interaction.h_m = -6;
defaultOptions.interaction.w_mm_exc = 20;                                  % local excitation
defaultOptions.interaction.w_mm_inh = 1;                                    % global inhibition

defaultOptions.interaction.w_mr = 3;                                        % feedforward connection from r to m (decision-motor)
defaultOptions.interaction.w_rm = 9;                                        % feedback from m to r (motor-decision)
defaultOptions.interaction.w_rm_inh = 0.1;                                 % global inhibitory feedback from m to r

defaultOptions.interaction.sigma_s_pre = 3;                                % width of preshape ridges in field t
defaultOptions.interaction.c_pre = 0.5;                                      % strength of preshape ridges in field t

defaultOptions.interaction.reachThreshold = 0.75;



% noise
defaultOptions.noise.rule = 0;                                          % size of noise in rule field 
defaultOptions.noise.spatial = 0;                                          % size of noise in spatial field 
defaultOptions.noise.association = 0;                                      % size of noise in association field 
defaultOptions.noise.reach = 0;                                            % size of noise in reach field 
defaultOptions.noise.motor = 0;                                            % size of noise in motor field 

% defaultOptions.noise.rule = 0.05;
% defaultOptions.noise.spatial = 0.1;
% defaultOptions.noise.association = 0.2;
% defaultOptions.noise.reach = 0.1;
% defaultOptions.noise.motor = 0.1;

% learning 
defaultOptions.learning.learnWeights = true;                                        % turn learning of weights on/off
defaultOptions.learning.saveWeights = true;                                         % save learned weights
defaultOptions.learning.overwriteWeights = false;
defaultOptions.learning.loadWeights = true;                                         % load learned weights
defaultOptions.learning.loadWeightsOptionsName = 'weights_default';                 % name of the options from which the weights file is to be loaded
defaultOptions.learning.loadWeightsOptionsNameSuffix = '';                          % weight name suffix

% learning settings
defaultOptions.learning.etaSuccess = 0.1;                                 % learning rate for successfull trials
defaultOptions.learning.etaFailure = 0.05;                                % learning rate for unsuccessfull trials

% adaptive learning
defaultOptions.learning.adaptive = 0;                                      % use an adaptive learning rate that increases when more errors occur and decreases the fewer the errors
defaultOptions.learning.adaptiveBuffer = 10;                               % adaptive learning uses a sliding window that contains buffer amounts of elements (errors =1; success = 0)
defaultOptions.learning.adaptiveFactor = 1;                                % adaption factor 1 means that the maximum learning rates equal the numbers set for etaSuccess and etaFailure 
defaultOptions.learning.adaptiveMinimum = 0.2;                             % minimum fraction for learning rate even if error is lower (e.g. 0.2 -> successEta of 0.1 will not drop below 0.02) 

% randomization
defaultOptions.seed = 1;                                                   % seed for random number generator
defaultOptions.randomizeTimer = false;                                     % instead of using starting seed randomize timer

% save options
defaultOptions.saveRF = 1;                                                 % save r-field after a session
defaultOptions.overwriteData = true;                                       % overwrite data in directory

options = setScriptOptions(defaultOptions, options); 
clear defaultOptions

%initialize random number stream with fixed seed or randomize based on clock
if options.randomizeTimer
    options.seed = sum(100*clock);
end

s = RandStream('mt19937ar', 'seed', options.seed);
RandStream.setGlobalStream(s);

if options.display.recordMovie
  mov = VideoWriter(options.display.movieFile, 'Uncompressed AVI');
  open(mov);
end

if options.learning.loadWeights
    if isempty(options.learning.loadWeightsOptionsName)
        options.learning.loadWeightsOptionsName = ['weights_' options.optionsName];
    end
    if ~isempty(options.learning.loadWeightsOptionsNameSuffix)
        options.learning.loadWeightsOptionsName = [options.learning.loadWeightsOptionsName '_' options.learning.loadWeightsOptionsNameSuffix];
    end
    options.learning.loadWeightsOptionsName = [options.learning.loadWeightsOptionsName '.mat'];
end

if options.learning.overwriteWeights && options.learning.saveWeights
    weightMatrixFilename = ['weights_' options.optionsName '.mat'];
    trialStatisticsFilename = ['statistics_' options.optionsName '.mat'];
    resultFilename = ['result_' options.optionsName '.mat'];
else
    weightMatrixFilename = ['weights_' options.optionsName '_' datestr(now,'yymmdd') '.mat'];
    trialStatisticsFilename = ['statistics_' options.optionsName '_' datestr(now,'yymmdd') '.mat'];
    resultFilename = ['result_' options.optionsName '_' datestr(now,'yymmdd') '.mat'];
end

%%%%%%%%%%%%%%%%%%%%
% Model parameters %
%%%%%%%%%%%%%%%%%%%%

% field sizes
fieldSize_c = options.field.size_c;
fieldSize_s = options.field.size_s;
fieldSize_t_base = options.field.size_t;
fieldSize_t = options.field.size_t * options.field.scale_t;
scale_t = options.field.scale_t;

halfSize_s = fieldSize_s/2;

n_s = options.taskVar.spatialCue.number;
n_c = options.taskVar.ruleCue.number;

if fieldSize_c == n_c
    options.field.networkType_c = 1;   
elseif fieldSize_c > n_c
    options.field.networkType_c = 2;
else
    error('invalid field setting: size of the rule field must be at least equal to number of rules')
end

options.taskVar.spatialCue.position = num2cell((0:fieldSize_s/n_s:fieldSize_s-1)+fieldSize_s/(2*n_s)); % positions for spatial cue
options.taskVar.spatialCue.positionLabel = num2cell(0:360/n_s:360-1);
options.interaction.pos_pre = options.taskVar.spatialCue.position; % spatial positions of preshape ridges in field t

switch options.field.networkType_c
    case 1
        options.taskVar.ruleCue.position = num2cell(1:n_c);          % valid positions for the rule cue in the rule field
    case 2
        options.taskVar.ruleCue.position = num2cell((0:fieldSize_c/n_c:fieldSize_c-1)+fieldSize_c/(2*n_c)); % positions for rule cue on continuous rule field
    otherwise
        error('unsupported networkType');
end



% common parameters for all fields
tau = options.interaction.tau;
beta = options.interaction.beta;
sigma_exc = options.interaction.sigma_exc;
sigma_inh = options.interaction.sigma_inh;
sigma_cc = options.interaction.sigma_exc * scale_t;

% rule cue nodes
h_c = options.interaction.h_c;
w_cc_exc = options.interaction.w_cc_exc;
w_cc_inh = options.interaction.w_cc_inh;
q_c = options.noise.rule;

% spatial perception field
h_s = options.interaction.h_s;
w_ss_exc = options.interaction.w_ss_exc;
w_ss_inh = options.interaction.w_ss_inh;
q_s = options.noise.spatial;

% task association
h_t = options.interaction.h_t;
w_tt_exc = options.interaction.w_tt_exc;
w_tt_inh = options.interaction.w_tt_inh / scale_t;
q_t = options.noise.association;

% inputs to task associaction field
w_tc = options.interaction.w_tc;
w_ts = options.interaction.w_ts;

% reach planning field
h_r = options.interaction.h_r;
w_rr_exc = options.interaction.w_rr_exc;
w_rr_inh = options.interaction.w_rr_inh;
q_r = options.noise.reach;

w_rs = options.interaction.w_rs;
w_rt = options.interaction.w_rt / scale_t;

% motor field
h_m = options.interaction.h_m;
w_mm_exc = options.interaction.w_mm_exc;
w_mm_inh = options.interaction.w_mm_inh;
q_m = options.noise.motor;

w_mr = options.interaction.w_mr;
w_rm = options.interaction.w_rm;
w_rm_inh = options.interaction.w_rm_inh;

preshapePositions = options.interaction.pos_pre;
sigma_s_pre = options.interaction.sigma_s_pre;
c_pre = options.interaction.c_pre;

% constant factor for all interaction kernels
kernelSizeMultiplier = 3;


% threshold value for deciding that a reach has been initiated (from motor layer output)
reachThreshold = options.interaction.reachThreshold;

dispTrials = options.display.dispTrials;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time course and stimuli %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% preshape
preshape_t = zeros(fieldSize_t, fieldSize_s);
for i = 1 : length(preshapePositions)
    preshape_t = preshape_t + c_pre * repmat(1 * circshift(gauss(0:fieldSize_s-1, halfSize_s, sigma_s_pre), ...
      [0, preshapePositions{i} - halfSize_s]), [fieldSize_t, 1]);
end


%%%%%%%%%%%%%%%%%%
% Initialization %
%%%%%%%%%%%%%%%%%%

field_c = zeros(1, fieldSize_c) + h_c;
field_s = zeros(1, fieldSize_s) + h_s;
field_t = zeros(fieldSize_t, fieldSize_s) + h_t;
field_r = zeros(1, fieldSize_s) + h_r;
field_m = zeros(1, fieldSize_s) + h_m;

output_c = sigmoid(field_c, beta, 0); 
output_s = sigmoid(field_s, beta, 0);
output_t = sigmoid(field_t, beta, 0); 
output_r = sigmoid(field_r, beta, 0);
output_m = sigmoid(field_m, beta, 0);

% interaction kernels and index maps for padding
% [kernel_exc, kRange_exc] = gaussKernel(1, sigma_exc, 0, 0, 0, halfSize_s, kernelSizeMultiplier); 
% extIndex_exc = [fieldSize_s - kRange_exc + 1 : fieldSize_s, 1 : fieldSize_s, 1 : kRange_exc];
% 
% kernel_cc = gaussKernel(1, sigma_cc, 0, 0, 0, fieldSize_tc, kernelSizeMultiplier);
% 
% [kernel_ss, kRange_ss] = gaussKernel(w_ss_exc, sigma_exc, w_ss_inh, sigma_inh, 0, halfSize_s, kernelSizeMultiplier);
% extIndex_ss = [fieldSize_s - kRange_ss + 1 : fieldSize_s, 1 : fieldSize_s, 1 : kRange_ss];
% 
% [kernel_rr, kRange_rr] = gaussKernel(w_rr_exc, sigma_exc, w_rr_inh, sigma_inh, 0, halfSize_s, kernelSizeMultiplier);
% extIndex_rr = [fieldSize_s - kRange_rr + 1 : fieldSize_s, 1 : fieldSize_s, 1 : kRange_rr];

% % temporary solution while gaussKernel is unavailable
% % index vectors to perform padding for convolutions with interaction kernels
% 
kRange_exc = ceil(kernelSizeMultiplier * sigma_exc);
extIndex_exc = [fieldSize_s-kRange_exc+1:fieldSize_s, 1:fieldSize_s, 1:kRange_exc];
kernel_exc = gaussNorm(-kRange_exc:kRange_exc, 0, sigma_exc);

kSize_cc = ceil(kernelSizeMultiplier * sigma_cc);
kernel_cc = gaussNorm(-kSize_cc:kSize_cc, 0, sigma_cc);

kSize = ceil(kernelSizeMultiplier * max(sigma_exc, sigma_inh));
extIndex_ss = [fieldSize_s-kSize+1:fieldSize_s, 1:fieldSize_s, 1:kSize];
kernel_ss = w_ss_exc * gaussNorm(-kSize:kSize, 0, sigma_exc) ...
    - w_ss_inh * gaussNorm(-kSize:kSize, 0, sigma_inh);

extIndex_rr = [fieldSize_s-kSize+1:fieldSize_s, 1:fieldSize_s, 1:kSize];
kernel_rr = w_rr_exc * gaussNorm(-kSize:kSize, 0, sigma_exc) ...
    - w_rr_inh * gaussNorm(-kSize:kSize, 0, sigma_inh);


% load weights from file
if ~options.learning.loadWeights
  W_tc = zeros(numel(field_t), fieldSize_c);
  for i = 1 : fieldSize_c
    W_tc(:, i) = reshape(abs(0.5 * imresize(rand(fieldSize_t_base, fieldSize_s), [fieldSize_t, fieldSize_s])), [], 1);
  end
  
  
  W_rt = zeros(fieldSize_s);
  weights_rt_row = 5 * circshift(gaussNorm(1:fieldSize_s, halfSize_s+1, sigma_exc), [0, -halfSize_s]);
  for i = 1 : fieldSize_s
    W_rt(i, :) = circshift(weights_rt_row, [0, i-1]);
  end
  W_rt = repmat(W_rt, [1, fieldSize_t]);
else % load weight matrices
  load([resultPath options.learning.loadWeightsOptionsName]);
end

% preallocate r-field save structure
if options.saveRF
    result.RF = zeros(options.taskVar.nTrials, size(field_r,2), options.taskVar.trialLength)/0;
    result.trialLength = zeros(options.taskVar.nTrials,1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare Visualization %
%%%%%%%%%%%%%%%%%%%%%%%%%

if options.display.visualize
    hFig = figure('Position', [5 5 720 740], 'Toolbar', 'figure');  % [5 5 720 820]
    hAxes_s = axes('Units', 'Pixels', 'Position', [280, 620, 400, 100], 'NextPlot', 'add'); % [280 660 400 120]
    title('spatial input field');
    hAxes_c = axes('Units', 'Pixels', 'Position', [40, 360, 200, 200], 'NextPlot', 'add'); % [40 400 200 200]
    title('rule input');
    hAxes_t = axes('Units', 'Pixels', 'Position', [280, 360, 400, 200], 'NextPlot', 'add'); % [280 400 400 200]
    title('association field');
    hAxes_r = axes('Units', 'Pixels', 'Position', [280, 200, 400, 100], 'NextPlot', 'add'); % [280 220 400 120]
    title('decision field');
    hAxes_m = axes('Units', 'Pixels', 'Position', [280, 40, 400, 100], 'NextPlot', 'add'); % [280 40 400 120]
    title('motor field');
    
    % screen display
    hAxes_screen = axes('Units', 'Pixels', 'Position', [40, 620, 200, 100], 'NextPlot', 'add'); %[40 660 200 120]
    axis off;
    axis equal;
    title('Screen');
    
    hPlotIn_s = plot(hAxes_s, 0:fieldSize_s-1, zeros(fieldSize_s,1), 'Color', 'g');
    hPlotAct_s = plot(hAxes_s, 0:fieldSize_s-1, field_s, 'LineWidth', 2);
    hPlotOut_s = plot(hAxes_s, 0:fieldSize_s-1, 10*output_s, 'Color', 'r');
    plot(hAxes_s, [0 fieldSize_s-1], [0 0], 'Linestyle',':','Linewidth',1);
    set(hAxes_s, 'XLim', [0 fieldSize_s-1], 'YLim', [-15 15], 'YTick', [-10 0 10],...
        'XTick',cell2mat(options.taskVar.spatialCue.position),'XTickLabel',cell2mat(options.taskVar.spatialCue.positionLabel));
    
    hBar_c = barh(hAxes_c, field_c, 'BaseValue', h_c, 'ShowBaseLine', 'on');
    set(hAxes_c, 'XDir', 'reverse', 'XLim', [-10 10], 'YDir', 'reverse', ...
        'YLim', [0.5 fieldSize_c+0.5], 'YAxisLocation', 'left', ...
        'YTick', cell2mat(options.taskVar.ruleCue.position),'YTickLabel', options.taskVar.ruleCue.name);
    
    hImage_t = image([0 fieldSize_s-1], [1 fieldSize_t], field_t, ...
        'Parent', hAxes_t, 'CDataMapping', 'scaled');
    set(hAxes_t, 'CLim', [-15 15]);
    set(hAxes_t, 'XLim', [0 fieldSize_s-1], 'YLim', [1 fieldSize_t],...
        'XTick',cell2mat(options.taskVar.spatialCue.position),'XTickLabel',cell2mat(options.taskVar.spatialCue.positionLabel));
    
    hPlotAct_r = plot(hAxes_r, 0:fieldSize_s-1, field_r, 'LineWidth', 2);
    hPlotIn_rs = plot(hAxes_r, 0:fieldSize_s-1, zeros(fieldSize_s, 1), 'LineWidth', 1, 'Color', 'g');
    hPlotIn_rt = plot(hAxes_r, 0:fieldSize_s-1, zeros(fieldSize_s, 1), 'LineWidth', 1, 'Color', 'c');
    hPlotOut_r = plot(hAxes_r, 0:fieldSize_s-1, 10*output_r, 'Color', 'r');
    plot(hAxes_r, [0 fieldSize_s-1], [0 0], 'Linestyle',':','Linewidth',1);
    set(hAxes_r, 'XLim', [0 fieldSize_s-1], 'YLim', [-15 15], 'YTick', [-10 0 10],...
        'XTick',cell2mat(options.taskVar.spatialCue.position),'XTickLabel',cell2mat(options.taskVar.spatialCue.positionLabel));
    
    hPlotAct_m = plot(hAxes_m, 0:fieldSize_s-1, field_m, 'LineWidth', 2);
    hPlotOut_m = plot(hAxes_m, 0:fieldSize_s-1, 10*output_m, 'Color', 'r');
    plot(hAxes_m, [0 fieldSize_s-1], [0 0], 'Linestyle',':','Linewidth',1);
    set(hAxes_m, 'XLim', [0 fieldSize_s-1], 'YLim', [-15 15], 'YTick', [-10 0 10],...
        'XTick',cell2mat(options.taskVar.spatialCue.position),'XTickLabel',cell2mat(options.taskVar.spatialCue.positionLabel));
    hAxes_m.XLabel.String = 'angle';
    hAxes_m.XLabel.FontWeight = 'bold';
    
    % start and stop simulation while running
    hStopButton = uicontrol('Style', 'togglebutton', 'String', 'Stop',...
        'Value',0,'Position', [20 230 100 70]);
    
    % terminate simulation
    hQuitButton = uicontrol('Style', 'togglebutton', 'String', 'Quit',...
        'Value',0,'Position', [20 150 100 70]);
    
    % draw fix period
    rectangle('Parent',hAxes_screen,'Position',[0,0,200,120],'FaceColor','w');
    
end

% initialize buffer for adaptive learning
if options.learning.adaptive
    adaptiveBuffer = zeros(options.learning.adaptiveBuffer,1);
else
    learnFactor = 1;
end


% prr continuous surface plot 
activityMatrix = ones(fieldSize_s,options.taskVar.trialLength) * field_r(1);

if options.display.visualizeActivityPlot
    continuousFigure = figure('Position', [300 5 600 300]);  
    hActivityPlot = surf(activityMatrix);
    grid on
    shading interp
    colormap jet
    zlim([-10 10]);
    set(gca,'CLim',[-10,10]);
    view(-40,54);
    xlabel('time','FontWeight','bold');
    ylabel('angle','FontWeight','bold');
    title('PPC field activity plot','interpreter', 'none');
end

smoothPerf = zeros(1,options.taskVar.nTrials);
if options.display.learningCurve
    learningFigure = figure('Position', [300 5 600 600]);  
    learningCurve = plot(smoothPerf);
    ylim([0 1]);
    xlabel('n trials','FontWeight','bold');
    ylabel('performance','FontWeight','bold');
    title('learning curve','interpreter', 'none');
end

%%%%%%%%%%%%%%
% Simulation %
%%%%%%%%%%%%%%

trialFinished = false;                                                     % flag for trial finished
resultEstablished = false;                                                 % flag which is set if result for trial is established

for k = 1 : options.taskVar.nTrials
    options = DNF1_stimulusGenerator(options);
        
    % define spatial and rule input
    
    extInput_c = options.currentTrial.ruleInput;
    extInput_s = options.currentTrial.spatialInput;
    boost_m    = options.currentTrial.goSignalInput;
    
    %planEst = 0;
    
    field_c(:) = h_c;
    field_s(:) = h_s;
    field_t(:) = h_t;
    field_r(:) = h_r;
    field_m(:) = h_m;
    
    % initialize tmpW_rt, tmpW_tc
    tmpW_rt = W_rt;
    tmpW_tc = W_tc;
    
    for t = 1 : options.taskVar.trialLength
        % check gui elements
        if options.display.visualize
            if get(hStopButton,'Value') == 1
                while get(hStopButton,'Value')
                    pause(0.01);
                end
            end
            
            if get(hQuitButton,'Value') == 1
                close(hFig);
                %%%
%                 s = -6;
%                 figure;
%                 plot(1:fieldSize_s, circshift(field_s, [0, s]), 'g', ...
%                   1:fieldSize_s, circshift(field_r, [0, s]), 'b', ...
%                   1:fieldSize_s, circshift(field_m, [0, s]), 'r');
%                 figure
%                 imagesc(1:fieldSize_tc, 1:fieldSize_s, circshift(field_t, [0, s]), [-15, 15]);
                %%%
                return;
            end
            
        end
        
        % field output
        output_c = sigmoid(field_c, beta, 0);
        output_s = sigmoid(field_s, beta, 0);
        output_t = sigmoid(field_t, beta, 0);
        output_r = sigmoid(field_r, beta, 0);
        output_m = sigmoid(field_m, beta, 0);
        sumOutput_m = sum(output_m);
        
        
        % create spatially correlated noise
        noise_c = q_c * randn(1, fieldSize_c);
        noise_s = q_s * randn(1, fieldSize_s);
%         noise_t = q_t * randn(fieldSize_tc, fieldSize_s);
        noise_t = q_t * imresize(randn(fieldSize_t_base, fieldSize_s), [fieldSize_t, fieldSize_s], 'nearest');
        noise_r = q_r * randn(1, fieldSize_s);
        noise_m = q_m * randn(1, fieldSize_s);
        
        % convolutions used for multiple inputs
        conv_s_exc = conv(output_s(extIndex_exc), kernel_exc, 'valid');
        conv_r_exc = conv(output_r(extIndex_exc), kernel_exc, 'valid');
        conv_m_exc = conv(output_m(extIndex_exc), kernel_exc, 'valid');
        
        
        % endogeneous input to fields
        input_cc = w_cc_exc * output_c - w_cc_inh * sum(output_c);
        input_ss = conv(output_s(extIndex_ss), kernel_ss, 'valid');
        input_tc = reshape(w_tc * W_tc * output_c', [fieldSize_t, fieldSize_s]);
        input_ts = repmat(w_ts * conv_s_exc, [fieldSize_t, 1]);
        
        input_tt = conv2(kernel_cc', 1, output_t, 'same');
        input_tt = conv2(1, w_tt_exc * kernel_exc, input_tt(:, extIndex_exc), 'valid') - w_tt_inh * sum(sum(output_t));
        
        input_rs = w_rs * conv_s_exc;
        input_rt = (w_rt * (W_rt * reshape(output_t', [numel(output_t), 1])))';
%         input_rr = w_rr_exc * conv_r_exc - w_rr_inh * sum(output_r);
        input_rr = conv(output_r(extIndex_rr), kernel_rr, 'valid') - w_rr_inh * sum(output_r);
        input_mr = w_mr * conv_r_exc;
        input_mm = w_mm_exc * conv_m_exc - w_mm_inh * sumOutput_m;
        input_rm = w_rm * conv_m_exc - w_rm_inh * sumOutput_m;
        
        % field dynamics
        field_c = field_c + 1/tau * (-field_c + h_c ...
          + input_cc + extInput_c(t, :)) + noise_c;
        field_s = field_s + 1/tau * (-field_s + h_s ...
          + input_ss + extInput_s(t, :)) + noise_s;
        field_t = field_t + 1/tau * (-field_t + h_t + preshape_t...
          + input_tc + input_ts + input_tt) + noise_t;
        field_r = field_r + 1/tau * (-field_r + h_r ...
          + input_rs + input_rt + input_rm + input_rr) + noise_r;
        field_m = field_m + 1/tau * (-field_m + h_m + boost_m(t) ...
          + input_mr + input_mm) + noise_m;

        
        activityMatrix(:,t) = field_r;
        % plot fields
        if options.display.visualize
            set(hBar_c, 'YData', field_c);
            %set(hPlot_c, 'XData', field_c);
            set(hPlotIn_s, 'YData', extInput_s(t, :));
            set(hPlotAct_s, 'YData', field_s);
            set(hPlotOut_s, 'YData', 10*output_s);
            set(hImage_t, 'CData', field_t);
            set(hPlotAct_r, 'YData', field_r);
            set(hPlotOut_r, 'YData', 10*output_r);
            set(hPlotIn_rs, 'YData', input_rs);
            set(hPlotIn_rt, 'YData', input_rt);
            set(hPlotAct_m, 'YData', field_m);
            set(hPlotOut_m, 'YData', 10*output_m);
            
%             createStimulusScreen(hAxes_screen,options.stimulusOptions,t);
            
            drawnow;
            pause(0.01);
                   
        end
        
        if options.display.recordMovie
            frame = getframe(hFig);
            writeVideo(mov,frame);
        end
        
        if options.display.visualizeActivityPlot
            % plot surface of prr field
            set(hActivityPlot,'ZData',activityMatrix + options.display.activityPlotOffset);
        end
        
        %if ~planEst && sum(output_m) >= reachThreshold
        if ~resultEstablished && max(conv_m_exc) >= reachThreshold
            %planEst = 1;
            
            if dispTrials
              disp(['Trial ' num2str(k) ': Movement plan established after ' num2str(t) ' timesteps'])
            end
              
            
            % save time of decision (RT)
            options.trialVar.RT(length(options.trialVar.spatialCuePosition)) = t;
            
            pSin = sin(linspace(0, 2*pi*(1-1/fieldSize_s), fieldSize_s));
            pCos = cos(linspace(0, 2*pi*(1-1/fieldSize_s), fieldSize_s));
            reachAngle = atan2(sum(output_m .* pSin) / sum(output_m), sum(output_m .* pCos) / sum(output_m));
            reachPos = fieldSize_s * mod(reachAngle, 2*pi) / (2*pi);
               
            % implement several possible goals
            success = 0;
            for tarPos = 1:length(options.currentTrial.goalPosition)
                errorSize = abs(reachPos - options.currentTrial.goalPosition{tarPos});
                circError = min(errorSize, -(errorSize - fieldSize_s));
                if circError <= options.taskVar.toleranceWindow
                    success = 1;
                end
            end
            
            if success % success trial
              
                goalOutput_c = output_c;
                goalOutput_r = output_r;
                etaTrial = options.learning.etaSuccess;
                
                if dispTrials
                  disp(['Reach position: reach:' num2str(reachPos) ' (goal: '...
                    num2str(options.currentTrial.goalPosition{1})...
                    '; spatial: ' num2str(options.currentTrial.spatialCuePosition)...
                    '; rule: ' options.taskVar.ruleCue.name{options.currentTrial.rule} ' (' num2str(options.currentTrial.rule) ' : ' num2str(options.currentTrial.ruleCuePosition) '); correct)']);
                end
                
                % collect success statistics of task
                options.lastTrial.success = 1;
                options.trialVar.success(length(options.trialVar.spatialCuePosition)) = 1;
                
                %store reach position
                options.trialVar.reachPosition(length(options.trialVar.spatialCuePosition)) = reachPos;
                
                % adaptive buffer
                if options.learning.adaptive
                    % write buffer
                    adaptiveBuffer = circshift(adaptiveBuffer,1);
                    adaptiveBuffer(1) = 0;
                    
                    % calculate error rate
                    errorRate = sum(adaptiveBuffer) / length(adaptiveBuffer);
                    
                    learnFactor = errorRate * options.learning.adaptiveFactor;
                    
                    % correct for minimum
                    if learnFactor < options.learning.adaptiveMinimum
                        learnFactor = options.learning.adaptiveMinimum;
                    end
                    
                    % output learnFactor
                    learnFactor
                end
          
            else % failure trial
                goalOutput_c = sum(output_c) * (1 - output_c) / sum(1-output_c);
                goalOutput_r = sum(output_r) * (1 - output_r) / sum(1-output_r);
                etaTrial = options.learning.etaFailure;
              
                if dispTrials
                  disp(['Reach position: reach:' num2str(reachPos) ' (goal: '...
                    num2str(options.currentTrial.goalPosition{1})...
                    '; spatial: ' num2str(options.currentTrial.spatialCuePosition)...
                    '; rule: ' options.taskVar.ruleCue.name{options.currentTrial.rule} ' (' num2str(options.currentTrial.rule) ' : ' num2str(options.currentTrial.ruleCuePosition) '); error)']);
                end

                  
                  % collect success statistics of task
                options.lastTrial.success = 0;
                options.trialVar.success(length(options.trialVar.spatialCuePosition)) = 0;
                
                %store reach position
                options.trialVar.reachPosition(length(options.trialVar.spatialCuePosition)) = reachPos;
                
                 % adaptive buffer
                if options.learning.adaptive
                    % write buffer
                    adaptiveBuffer = circshift(adaptiveBuffer,1);
                    adaptiveBuffer(1) = 1;
                    
                    % calculate error rate
                    errorRate = sum(adaptiveBuffer) / length(adaptiveBuffer);
                    
                    learnFactor = errorRate * options.learning.adaptiveFactor;
                    
                    % correct for minimum
                    if learnFactor < options.learning.adaptiveMinimum
                        learnFactor = options.learning.adaptiveMinimum;
                    end
                    
                    % output learnFactor
                    learnFactor
                end
                

            end
      
            % pause if visualization is turned on
            if options.display.visualize
                pause(0.5);
            end
            
            % calculate weight changes (hebbian style)
            dW_rt = (repmat(goalOutput_r', [1, numel(output_t)]) - W_rt) .* ...
              repmat(reshape(output_t', [1, numel(output_t)]), [numel(output_r), 1]);
            dW_tc = repmat(reshape(output_t, [numel(output_t), 1]), [1, fieldSize_c]) .* ...
              (repmat(goalOutput_c, [numel(output_t), 1]) - W_tc);
            
            % learning
            if options.learning.learnWeights
              tmpW_rt = W_rt + etaTrial * learnFactor * dW_rt;
              tmpW_tc = W_tc + etaTrial * learnFactor * dW_tc;
            end
            
            %trialFinished = true;
            resultEstablished = true;
            
            if options.display.breakOnReachPlan
              trialFinished = true;
            end
            
        end
            
        if t == options.taskVar.trialLength
            if ~resultEstablished
                disp(['Trial ' num2str(k) ': No movement plan established after time ran out.'])
                
                % save time of decision (RT)
                options.trialVar.RT(length(options.trialVar.spatialCuePosition)) = -1;
            end
            
            trialFinished = true;
        end
        
        % check if trial has been finished
        % end of trial code can be put here
        if trialFinished
            
            % pause if option is selected (to make screenshots etc.
            if options.display.pauseAfterTrial && options.display.visualize
                pause;
            end
            
            
            if options.saveRF
                result.RF(k,:,:) = activityMatrix;
                result.trialLength(k) = t;
            end
            
            % set weights 
            W_rt = tmpW_rt;
            W_tc = tmpW_tc;
            
            % reset activity matrix
            activityMatrix = (activityMatrix * 0) + field_r(1);
            
            trialFinished = false;
            
            resultEstablished = false;
            
            break;
        end
    end
    
    smoothPerf = smooth(options.trialVar.success);
    
    if options.display.learningCurve
        set(learningCurve, 'YData', smoothPerf);
    end
    
    pause(0.05); % to allow file operations in MATLAB while simulator is running
end

% close movie
if options.display.recordMovie
  close(mov);
end

% save RF field information
if options.saveRF
    % store stimulusOptions
    result.taskVar = options.taskVar;
    result.trialVar = options.trialVar;
    
    % save results
    save([resultPath resultFilename], 'result');
    
end


% save learned weight matrix
if options.learning.saveWeights
    save([resultPath weightMatrixFilename], 'W_rt', 'W_tc');
end

% show statistics
totalPerformance = sum(options.trialVar.success) / length(options.trialVar.success);

disp(['performance = ' num2str(totalPerformance)]);


save([resultPath trialStatisticsFilename], 'options');
