%% Generates stimulus settings for neural field model
function options = DNF2_stimulusGenerator(options)
% GUI for generating a task setting and continously caculating new task settings from a start set.
% options= options struct that configure the script


% statistical information of trials
defaultOptions.trialVar.spatialCuePosition = [];                                   % storage of all presented positions
defaultOptions.trialVar.rule  = [];                                   % storage of all presented mapping rules
defaultOptions.trialVar.ruleCuePosition = [];                            % storage of all presented contextual cue positions
defaultOptions.trialVar.biasCuePosition = [];
defaultOptions.trialVar.isCSTrial = [];
defaultOptions.trialVar.ruleCueDuration = [];                                 % storage of all duration variations CC
defaultOptions.trialVar.ruleCueStart =[];                                 % storage of all start time variations CC
defaultOptions.trialVar.ruleCueStrength = [];                                 % storage of all stregnth variations CC
defaultOptions.trialVar.spatialCueDuration = [];                                 % storage of all duration variations SC
defaultOptions.trialVar.spatialCueStart = [];                                % storage of all start time variations SC
defaultOptions.trialVar.spatialCueStrength = [];                                 % storage of all stregnth variations SC
defaultOptions.trialVar.reachPosition = [];                              % storage of all reached positions
defaultOptions.trialVar.success = [];                                    % storage of correct trials (needed if history dependend cw/ccw choice is used)
defaultOptions.trialVar.goSignalStart = [];                              % storage of go signal start time
defaultOptions.trialVar.goSignalStrength = [];                           % storage of go signal strength
defaultOptions.trialVar.RT = [];                                         % storage of reaction time 
 
options = setScriptOptions(defaultOptions,options);


% current trial settings
options.currentTrial.spatialInputStrength = 6;                      % strength for spatial input
options.currentTrial.spatialInput = [];                             % spatio-temporal structure for the spatial cue
options.currentTrial.ruleInputStrength = 6;                      % strength for rule input
options.currentTrial.ruleInput = [];                             % temporal structure of rule cue

options.currentTrial.spatialCuePosition = 5;                                % position of spatial cue for this trial
options.currentTrial.spatialCueStartStop = [20 120];                        % begin and end of spatial cue presentation
options.currentTrial.rule = 1;                                 % rule cue (pro; anti; cw; ccw)
options.currentTrial.ruleCuePosition = 3;                                % rule cue position
options.currentTrial.ruleCueStartStop = [20 120];                        % begin and end of rule cue presentation
options.currentTrial.balancingCounter= zeros(2,2);                  % counter for cw and ccw condition for non-CS and CS

options.currentTrial.biasInputStrength = [3,3];                      % strength for bias input
options.currentTrial.biasInput = []; 
options.currentTrial.biasCuePosition = 4; 

options.currentTrial.goSignalStart = [];                             % start of go signal for current trial
options.currentTrial.goSignalStrength = 6;                          % stregnth of go signal for current trial
options.currentTrial.goSignalInput = [];                            % temporal structure of go signal

% last trial success
options.lastTrial.success = -1;                                     % result of last trial (used for some balancing etc. algorithms); entered externally; -1 = no last trial available



% update success statistics
if options.lastTrial.success > -1
    options.trialVar.success(end) = options.lastTrial.success;
end

% determine if CS trial (only meaningfull when mode 'LCESCS' is chosen)
switch options.taskVar.trialMode
    case {'LCESCS' 'LCESCS_alwaysReward'}
        isCSTrial = rand(1) <= options.taskVar.probabilityCS;
    otherwise
        isCSTrial = 0;
end

if strcmp(options.taskVar.trialMode,'ruleLearn')
    options.taskVar.biasCue.number = 1;
    options.taskVar.biasCue.level = [1,1];
    options.interaction.biasCue.strengthFix = [0,0];
    options.interaction.biasCue.strengthVar = 0;
end

% update balancing counter according to success of last trial

if options.lastTrial.success == 1
    options.currentTrial.balancingCounter(options.trialVar.mapping(end),isCSTrial+1) =...
        options.currentTrial.balancingCounter(options.trialVar.mapping(end),isCSTrial+1) + 1;
end

switch options.taskVar.biasCue.randomizerMode
    case 0
        % nothing is changed % add blockwise?
    case 1
        % change randomly w/o history
        tmpInd_b = randi(options.taskVar.biasCue.number);
        options.currentTrial.biasCuePosition = tmpInd_b;
    otherwise
        error('no valid randomizer mode choosen');
end

% determine rule cue position, rule and spatial cue position
% switch options.taskVar.ruleCue.randomizerMode
%     case 0
%         % nothing is changed
%     case 1
%         % first determine rule cue position
%         tmpIndex = my_randsample(1:options.taskVar.ruleCue.number,1,true,options.taskVar.ruleCue.probabilities);
%         options.currentTrial.ruleCuePosition = options.taskVar.ruleCue.position{tmpIndex};
%             
%         % second determine mapping rule according to ruleMatrix
%         options.currentTrial.rule = my_randsample(cell2mat(options.taskVar.ruleCue.code),1,true,options.taskVar.ruleCue.matrix(tmpIndex,:));
%      
%     case 2
%         % balanced (last 2 trials; like in real TC)
%         % implementation equal to current TC
%         % ONLY works with two mapping options at the moment
%         % and ONLY if networkType is 1
%         
%         pCur = (options.taskVar.ruleCue.balancingNo(1)-...
%             options.currentTrial.balancingCounter(1,isCSTrial+1)) /...
%             sum(options.taskVar.ruleCue.balancingNo -...
%             options.currentTrial.balancingCounter(:,isCSTrial+1));
%         
%         % reset balancing counter if both conditions are equal for non-CS and CS trials separately
%         if sum(options.currentTrial.balancingCounter(:,1)) == sum(options.taskVar.ruleCue.balancingNo)
%             options.currentTrial.balancingCounter(:,1) = ...
%                 options.currentTrial.balancingCounter(:,1) - options.taskVar.ruleCue.balancingNo;
%         end
%         
%         if sum(options.currentTrial.balancingCounter(:,2)) == sum(options.taskVar.ruleCue.balancingNo)
%             options.currentTrial.balancingCounter(:,2) = ...
%                 options.currentTrial.balancingCounter(:,2) - options.taskVar.ruleCue.balancingNo;
%         end
%         
%         % calculate mapping
%         if rand(1) > pCur
%             options.currentTrial.rule = options.taskVar.ruleCue.code{2};
%         else
%             options.currentTrial.rule = options.taskVar.ruleCue.code{1};
%         end
%         
%     case 3    
        tmpIndex = my_randsample(1:options.taskVar.ruleCue.number,1,true,options.taskVar.biasCue.level(tmpInd_b,:));
        options.currentTrial.ruleCuePosition = options.taskVar.ruleCue.position{tmpIndex};
            
        % second determine mapping rule according to ruleMatrix
        options.currentTrial.rule = my_randsample(cell2mat(options.taskVar.ruleCue.code),1,true,options.taskVar.ruleCue.matrix(tmpIndex,:));

%     otherwise
%         error('no valid randomizer mode choosen');
% end


switch options.taskVar.spatialCue.randomizerMode
    case 0
        % nothing is changed
    case 1
        % change randomly w/o history
        tmpInd_s = randi(options.taskVar.spatialCue.number);
        options.currentTrial.spatialCuePosition = options.taskVar.spatialCue.position{tmpInd_s};
    otherwise
        error('no valid randomizer mode choosen');
end

% determine goal position depending on trial type
tmpCirInd = circshift((1:options.taskVar.spatialCue.number)', - tmpInd_s);
cwInd = tmpCirInd(1);
tmpCirInd = circshift((1:options.taskVar.spatialCue.number)', 2 - tmpInd_s);
ccwInd = tmpCirInd(1);
tmpCirInd = circshift((1:options.taskVar.spatialCue.number)', 3 - tmpInd_s);
antiInd = tmpCirInd(1);
options.currentTrial.ruleList = circshift({'pro';'cw';'anti';'ccw'}, tmpInd_s - 1);

switch options.taskVar.trialMode
    % goal position for LCESCS task with reward for both possible targets
    case {'LCESCS_alwaysReward'}
        
        for rr = 1:options.taskVar.ruleCue.number
            switch options.taskVar.ruleCue.name{rr}
                case 'pro'
                    options.currentTrial.goalPosition{rr} = options.currentTrial.spatialCuePosition;
                case 'cw'
                    options.currentTrial.goalPosition{rr} = options.taskVar.spatialCue.position{cwInd};
                case 'ccw'
                    options.currentTrial.goalPosition{rr} = options.taskVar.spatialCue.position{ccwInd};
                case 'anti'
                    options.currentTrial.goalPosition{rr} = options.taskVar.spatialCue.position{antiInd};
            end
        end
        % goal position for all other tasks
    otherwise
        switch options.taskVar.ruleCue.name{options.currentTrial.rule}
            case 'pro'
                options.currentTrial.goalPosition{1} = options.currentTrial.spatialCuePosition;
            case 'anti'
                options.currentTrial.goalPosition{1} = options.taskVar.spatialCue.position{antiInd};
            case 'cw'
                options.currentTrial.goalPosition{1} = options.taskVar.spatialCue.position{cwInd};
            case 'ccw'
                options.currentTrial.goalPosition{1} = options.taskVar.spatialCue.position{ccwInd};
        end
end
        
% determine start times, strengths and durations depending on trialMode
if strfind(options.taskVar.trialMode,'LCES')
    % classic LCES trial
    % determine cue strengths
    options.currentTrial.ruleInputStrength = options.interaction.ruleCue.strengthFix + randi(options.interaction.ruleCue.strengthVar+1)-1;
    options.currentTrial.spatialInputStrength = options.interaction.spatialCue.strengthFix + randi(options.interaction.spatialCue.strengthVar+1)-1;
    options.currentTrial.biasInputStrength = options.taskVar.biasCue.level(tmpInd_b,:)/10 + randi(options.interaction.biasCue.strengthVar+1)-1;

    tmp_CS = 0;
    % classic LCES trial with context suppression
    if strfind(options.taskVar.trialMode,'CS')    
        % turn of context cue if CS trial flag is set
        if isCSTrial
            options.currentTrial.ruleInputStrength = 0;
            tmp_CS = 1;
        else
            options.currentTrial.ruleInputStrength = options.interaction.ruleCue.strengthFix + randi(options.interaction.ruleCue.strengthVar+1)-1;
        end
    end
    
       % determine spatial cue start time and length
    tmpStartTimeSpatial = options.taskVar.spatialCue.startTimeFix + randi(options.taskVar.spatialCue.startTimeVar+1)-1;
    tmpDurationSpatial  = options.taskVar.spatialCue.durationFix + randi(options.taskVar.spatialCue.durationVar+1)-1;
    
    % set rule cue start time
    tmpStartTimeRule = tmpStartTimeSpatial + tmpDurationSpatial +...
        options.taskVar.memoryPeriod + randi(options.taskVar.ruleCue.startTimeVar+1)-1;
    
    tmpDurationRule  = options.taskVar.ruleCue.durationFix + randi(options.taskVar.ruleCue.durationVar+1)-1;
    
    options.currentTrial.ruleCueStartStop = [tmpStartTimeRule tmpStartTimeRule+tmpDurationRule];
    options.currentTrial.spatialCueStartStop = [tmpStartTimeSpatial tmpStartTimeSpatial+tmpDurationSpatial];
    options.currentTrial.biasCueStartStop = options.currentTrial.spatialCueStartStop;
    
    % go signal
    tmpGoStartTime = tmpStartTimeRule + tmpDurationRule + options.taskVar.goSignal.startTimeFix + randi(options.taskVar.goSignal.startTimeVar+1)-1;
    tmpGoStrength = options.interaction.goSignal.strengthFix + randi(options.interaction.goSignal.strengthVar+1)-1;

    
    % create spatio-temporal stimuli
    options.currentTrial.ruleInput = zeros(options.taskVar.trialLength, options.taskVar.ruleCue.number);
    options.currentTrial.biasInput = options.currentTrial.ruleInput;
    
    switch options.field.networkType_c
        case 1
            options.currentTrial.ruleInput(tmpStartTimeRule:tmpStartTimeRule+tmpDurationRule,options.currentTrial.rule) = options.currentTrial.ruleInputStrength;
            options.currentTrial.biasInput(tmpStartTimeSpatial:tmpStartTimeSpatial+tmpDurationSpatial,:) = repmat(options.currentTrial.biasInputStrength,tmpDurationSpatial+1,1);
        case 2
            options.currentTrial.ruleInput(tmpStartTimeRule:tmpStartTimeRule+tmpDurationRule,:) = ...
                repmat(options.currentTrial.ruleInputStrength * circularGauss(0:options.field.size_c-1,...
                options.currentTrial.ruleCuePosition, options.interaction.sigma_cc),tmpDurationRule+1,1);
        otherwise
            error('unsupported networkType');
    end
    
    options.currentTrial.spatialInput = zeros(options.taskVar.trialLength, options.field.size_s);
    options.currentTrial.spatialInput(tmpStartTimeSpatial:tmpStartTimeSpatial+tmpDurationSpatial,:) = ...
        repmat(options.currentTrial.spatialInputStrength * circularGauss(0:options.field.size_s-1,...
        options.currentTrial.spatialCuePosition, options.interaction.sigma_exc),tmpDurationSpatial+1,1);
    
    options.currentTrial.goSignalInput = [zeros(1, tmpGoStartTime), tmpGoStrength * ones(1, options.taskVar.trialLength - tmpGoStartTime)];
    options.currentTrial.goSignalStart = tmpGoStartTime;
    
    % currentTrial
    curTrial = length(options.trialVar.spatialCuePosition) + 1;
    
    options.trialVar.spatialCuePosition(curTrial) = options.currentTrial.spatialCuePosition;
    options.trialVar.ruleCuePosition(curTrial) = options.currentTrial.ruleCuePosition;
    options.trialVar.rule(curTrial) = options.currentTrial.rule;
    options.trialVar.isCSTrial(curTrial) = tmp_CS;
    options.trialVar.biasCuePosition(curTrial) = options.currentTrial.biasCuePosition;
    options.trialVar.biasCueStrength(curTrial,:) = options.currentTrial.biasInputStrength;
    options.trialVar.biasCueDuration(curTrial) = tmpDurationSpatial;
    options.trialVar.ruleCueDuration(curTrial) = tmpDurationRule;
    options.trialVar.ruleCueStart(curTrial) = tmpStartTimeRule;
    options.trialVar.ruleCueStrength(curTrial) = options.currentTrial.ruleInputStrength;
    options.trialVar.spatialCueDuration(curTrial) = tmpDurationSpatial;
    options.trialVar.spatialCueStart(curTrial) = tmpStartTimeSpatial;
    options.trialVar.spatialCueStrength(curTrial) = options.currentTrial.spatialInputStrength;
    options.trialVar.goSignalStart(curTrial) = tmpGoStartTime;
    options.trialVar.goSignalStrength(curTrial) = tmpGoStrength;

% learning rule associations (with a second spatial cue at the end which becomes gradually weaker with each trial)
elseif strfind(options.taskVar.trialMode,'ruleLearn')
    % determine cue strength
    options.currentTrial.ruleInputStrength = options.interaction.ruleCue.strengthFix + randi(options.interaction.ruleCue.strengthVar+1)-1;
    options.currentTrial.spatialInputStrength = options.interaction.spatialCue.strengthFix + randi(options.interaction.spatialCue.strengthVar+1)-1;
    options.currentTrial.biasInputStrength = options.interaction.biasCue.strengthFix + randi(options.interaction.biasCue.strengthVar+1)-1;

    
    % determine spatial cue start time and length
    tmpStartTimeSpatial = options.taskVar.spatialCue.startTimeFix + randi(options.taskVar.spatialCue.startTimeVar+1)-1;
    tmpDurationSpatial  = options.taskVar.spatialCue.durationFix + randi(options.taskVar.spatialCue.durationVar+1)-1;
    
    % set contextual cue start time (same as spatial cue)
    tmpStartTimeRule = tmpStartTimeSpatial;
    tmpDurationRule  = tmpDurationSpatial;
    
    options.currentTrial.ruleCueStartStop = [tmpStartTimeRule tmpStartTimeRule+tmpDurationRule];
    options.currentTrial.spatialCueStartStop = [tmpStartTimeSpatial tmpStartTimeSpatial+tmpDurationSpatial];
    options.currentTrial.biasCueStartStop = options.currentTrial.spatialCueStartStop;

    % go signal
    tmpGoStartTime = options.taskVar.memoryPeriod + tmpStartTimeRule + tmpDurationRule + options.taskVar.goSignal.startTimeFix + randi(options.taskVar.goSignal.startTimeVar+1)-1;
    tmpGoStrength = options.interaction.goSignal.strengthFix + randi(options.interaction.goSignal.strengthVar+1)-1;
  
    % currentTrial
    curTrial = length(options.trialVar.spatialCuePosition) + 1;
    
    options.currentTrial.ruleInput = zeros(options.taskVar.trialLength, options.taskVar.ruleCue.number);
    options.currentTrial.biasInput = options.currentTrial.ruleInput;

    switch options.field.networkType_c
        case 1
            options.currentTrial.ruleInput(tmpStartTimeRule:tmpStartTimeRule+tmpDurationRule,options.currentTrial.rule) = options.currentTrial.ruleInputStrength;
        case 2
            options.currentTrial.ruleInput(tmpStartTimeRule:tmpStartTimeRule+tmpDurationRule,:) = ...
                repmat(options.currentTrial.ruleInputStrength * circularGauss(0:options.field.size_c-1,...
                options.currentTrial.ruleCuePosition, options.interaction.sigma_cc),tmpDurationRule+1,1);
        otherwise
            error('unsupported networkType');
    end
    
    options.currentTrial.spatialInput = zeros(options.taskVar.trialLength, options.field.size_s);
    options.currentTrial.spatialInput(tmpStartTimeSpatial:tmpStartTimeSpatial+tmpDurationSpatial,:) = ...
        repmat(options.currentTrial.spatialInputStrength * circularGauss(0:options.field.size_s-1,...
        options.currentTrial.spatialCuePosition, options.interaction.sigma_exc),tmpDurationSpatial+1,1);
    
    % second spatial cue
    tmpStrength = max(0,options.currentTrial.ruleInputStrength * (1 - curTrial * options.ruleLearn.decay));
    tmpSecondStart = options.taskVar.memoryPeriod + tmpStartTimeRule + tmpDurationRule + options.ruleLearn.secondStart;
    options.currentTrial.spatialInput(tmpSecondStart:tmpSecondStart+options.ruleLearn.secondDuration,:) = ...
        repmat(tmpStrength * circularGauss(0:options.field.size_s-1, options.currentTrial.goalPosition{1}, options.interaction.sigma_exc), options.ruleLearn.secondDuration+1,1);
    
    options.currentTrial.goSignalInput = [zeros(1, tmpGoStartTime), tmpGoStrength * ones(1, options.taskVar.trialLength - tmpGoStartTime)];
    options.currentTrial.goSignalStart = tmpGoStartTime;
    
    options.trialVar.spatialCuePosition(curTrial) = options.currentTrial.spatialCuePosition;
    options.trialVar.ruleCuePosition(curTrial) = options.currentTrial.ruleCuePosition;
    options.trialVar.rule(curTrial) = options.currentTrial.rule;
    options.trialVar.isCSTrial(curTrial) = 0;
    options.trialVar.biasCuePosition(curTrial) = options.currentTrial.biasCuePosition;
    options.trialVar.biasCueStrength(curTrial,:) = options.currentTrial.biasInputStrength;
    options.trialVar.biasCueDuration(curTrial) = tmpDurationSpatial;
    options.trialVar.ruleCueDuration(curTrial) = tmpDurationRule;
    options.trialVar.ruleCueStart(curTrial) = tmpStartTimeRule;
    options.trialVar.ruleCueStrength(curTrial) = options.currentTrial.ruleInputStrength;
    options.trialVar.spatialCueDuration(curTrial) = tmpDurationSpatial;
    options.trialVar.spatialCueStart(curTrial) = tmpStartTimeSpatial;
    options.trialVar.spatialCueStrength(curTrial) = options.currentTrial.spatialInputStrength;
    options.trialVar.goSignalStart(curTrial) = tmpGoStartTime;
    options.trialVar.goSignalStrength(curTrial) = tmpGoStrength; 
else
    error('invalid trial type: LCES, LCESCS, LCESCS_alwaysReward, ruleLearn');
end
  




