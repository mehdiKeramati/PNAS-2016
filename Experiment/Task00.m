function varargout = Task00(varargin)
% TASK00 MATLAB code for Task00.fig
%      TASK00, by itself, creates a new TASK00 or raises the existing
%      singleton*.
%
%      H = TASK00 returns the handle to a new TASK00 or the handle to
%      the existing singleton*.
%
%      TASK00('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TASK00.M with the given input arguments.
%
%      TASK00('Property','Value',...) creates a new TASK00 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Task00_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Task00_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Task00

% Last Modified by GUIDE v2.5 28-Apr-2014 14:46:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Task00_OpeningFcn, ...
                   'gui_OutputFcn',  @Task00_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes just before Task00 is made visible.
function Task00_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Task00 (see VARARGIN)

% Choose default command line output for Task00
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Task00 wait for user response (see UIRESUME)
% uiwait(handles.figure1);

set(handles.text3,'visible','off')        
set(handles.text4,'visible','off')        
set(handles.text6,'visible','off')        
set(handles.text9,'visible','off')        

set(handles.axes5,'visible','off')        
set(handles.axes7,'visible','off')        
set(handles.axes9,'visible','off')        
set(handles.axes10,'visible','off')        
set(handles.axes12,'visible','off')        
set(handles.axes14,'visible','off')        

set(handles.text1,'String','Please enter your name and press <start> to start...')


global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 
global hoppingTrialsMean
global hoppingTrialsVariance
global rewardChance

global pretraining1TrialsNum       
global pretraining2TrialsNum       
global pretraining3TrialsNum       
global test1TrialsNum              
global test2TrialsNum              
global test3TrialsNum              


global gettingReadyTime
global reactionTimeLimitTraining
global reactionTimeLimitTest
global firstLevelActionPresentation
global secondLevelActionPresentation
global forcedWaitingAtFractal
global tooLateMessageTime
global rewardPresentationTime

global interBreakTrials
global forcedBreakTime
% --------------------------- Task Parameters

pretraining1TrialsNum   = 10    ;
pretraining2TrialsNum   = 10    ;
pretraining3TrialsNum   = 20    ;

test1TrialsNum          = 20    ;
test2TrialsNum          = 20    ;
test3TrialsNum          = 500   ;

interBreakTrials        = 50    ;
forcedBreakTime         = 30    ;

firstLevelChance_Pretraining        = 0.80  ;
secondLevelChance_Pretraining       = 0.80  ;

firstLevelChance_Test               = 0.70  ;
secondLevelChance_Test              = 0.70  ;

hoppingTrialsMean       = 5     ;
hoppingTrialsVariance   = 2     ;
rewardChance            = 1     ;

% --------------------------- Timing Parameters

gettingReadyTime                    = 0.4   ;
reactionTimeLimitTraining           = 0.7   ;
reactionTimeLimitTest               = 0.7   ;
firstLevelActionPresentation        = 0.5   ;
secondLevelActionPresentation       = 0.4   ;
forcedWaitingAtFractal              = 0.5   ;
rewardPresentationTime              = 0.7   ;
tooLateMessageTime                  = 2     ;


set(handles.text7 ,'String',['0/',int2str(pretraining1TrialsNum)])    
set(handles.text18,'String',['0/',int2str(pretraining2TrialsNum)])    
set(handles.text19,'String',['0/',int2str(pretraining3TrialsNum)])    
set(handles.text20,'String',['0/',int2str(test1TrialsNum)])    
set(handles.text21,'String',['0/',int2str(test2TrialsNum)])    
set(handles.text22,'String',['0/',int2str(test3TrialsNum)])   

% --- Outputs from this function are returned to the command line.
function varargout = Task00_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global records
if strcmp(eventdata.Key,'escape')
    finalize(hObject, eventdata, handles,records.totalReward);
end
        
% --- Executes on button press in pushbutton1.
function pushbuttonfi1_Callback(hObject, eventdata, handles)

global pretraining1TrialsNum       
global pretraining2TrialsNum       
global pretraining3TrialsNum       
global test1TrialsNum              
global test2TrialsNum              
global test3TrialsNum              

% --------------------------- Main

initializePretraining(hObject, eventdata, handles);

pretraining1 (hObject, eventdata, handles, pretraining1TrialsNum);
readyForNext (hObject, eventdata, handles);
pretraining2 (hObject, eventdata, handles, pretraining2TrialsNum);
readyForNext (hObject, eventdata, handles);
pretraining3 (hObject, eventdata, handles, pretraining3TrialsNum);
CallExperimentalist (hObject, eventdata, handles);

initializeTest(hObject, eventdata, handles);

test1 (hObject, eventdata, handles, test1TrialsNum);
readyForNext (hObject, eventdata, handles);
test2 (hObject, eventdata, handles, test2TrialsNum);
readyForNext (hObject, eventdata, handles);
test3 (hObject, eventdata, handles, test3TrialsNum);

function initializePretraining(hObject, eventdata, handles);

    global totalReward
    global FirstLevelActionLeft
    global FirstLevelActionRight
    global secondLevelStateAction1Left  
    global secondLevelStateAction1Right  
    global secondLevelStateAction2Left  
    global secondLevelStateAction2Right      
    global thirdLevelState1  
    global thirdLevelState2  
    global thirdLevelState3  
    global thirdLevelState4    
    global blank
    global rectangle

    set(handles.text1,'visible','off')        
    set(handles.edit1,'visible','off')        
    set(handles.pushbutton1,'Visible','off')
    set(handles.text3,'visible','on')
    
    totalReward = 0 ;
    %---------------- Counterbalacing the stimuli
    blank = 'stimuli/Blank.jpg';
    rectangle = 'stimuli/Rect.jpg';
    
    FirstLevelActionLeft  = 'stimuli/S0-L-pre.jpg';
    FirstLevelActionRight = 'stimuli/S0-R-pre.jpg';
    
    secondLevelStateAction1Left  = 'stimuli/S1-L-pre.jpg';
    secondLevelStateAction1Right = 'stimuli/S1-R-pre.jpg';
    secondLevelStateAction2Left  = 'stimuli/S2-L-pre.jpg';
    secondLevelStateAction2Right = 'stimuli/S2-R-pre.jpg';
    
    thirdLevelState1 = ['stimuli/S1-pre.bmp'];
    thirdLevelState2 = ['stimuli/S2-pre.bmp'];
    thirdLevelState3 = ['stimuli/S3-pre.bmp'];
    thirdLevelState4 = ['stimuli/S4-pre.bmp'];  
    
    %-----------------------------
    global phaseCounter
    phaseCounter = 1
    
    set(handles.text10,'BackgroundColor','yellow')            

function pretraining1(hObject, eventdata, handles,trialsNum);

global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 

global firstTransitionArrayRightCounter
global firstTransitionArrayLeftCounter
global secondTransitionArrayS1RightCounter
global secondTransitionArrayS1LeftCounter
global secondTransitionArrayS2RightCounter
global secondTransitionArrayS2LeftCounter
firstTransitionArrayRightCounter     = 21 ;
firstTransitionArrayLeftCounter      = 21 ;
secondTransitionArrayS1RightCounter  = 21 ;
secondTransitionArrayS1LeftCounter   = 21 ;
secondTransitionArrayS2RightCounter  = 21 ;
secondTransitionArrayS2LeftCounter   = 21 ;


global interBreakTrials
global reactionTimeLimitTraining

global filename
global fileID
filename    = get(handles.edit1,'String');
fileID      = fopen(['Data/',filename,'_Pre1.txt'], 'w');

records.totalReward          = 0;       % total reward obtained so far.
trialsTillRewardHops         = 0;
rewardingState               = 1 ;

for trial = 1 : trialsNum
    
    if mod(trial-1,interBreakTrials)==0 &&  trial>1
        takingBreak(hObject, eventdata, handles);
    end
    
 
    % --------------------------- Initializing the parameters to be logged
    records.trial                 = 0;       % trial number
    records.firstState            = 0;       % always 0
    records.secondState           = 0;       % 1 or 2
    records.thirdState            = 0;       % 1, 2, 3, or 4
    records.firstAction           = 0;       % 0 for left, 1 for right 
    records.secondAction          = 0;       % 0 for left, 1 for right 
    records.firstReactionTime     = 0;       % The reaction time for the first  action
    records.secondReactionTime    = 0;       % The reaction time for the second action
    records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    records.totalReward           = records.totalReward;       % total reward obtained so far.

    records.trial                = trial;
    records.firstState           = 0    ;
    showReadyMessage(hObject, eventdata, handles, trial , trialsNum );    

    reversed = showFirstState(hObject, eventdata, handles);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);
    [secondState,firstTransitionType] = firstTransition (key,firstLevelChance_Pretraining);
    
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showFirstLevelStateAction(hObject, eventdata, handles,'right',reversed);
        records.firstAction             = 1;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'leftShift')        
        showFirstLevelStateAction(hObject, eventdata, handles,'left',reversed);        
        records.firstAction             = 0;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'noKey')
        records.slowFirstAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    reversed = showSecondState(hObject, eventdata, handles, secondState);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);

    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'right',reversed);
        records.secondAction            = 1;
        records.secondReactionTime      = RT;
    elseif strcmp(key,'leftShift')        
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'left',reversed);
        records.secondAction            = 0;
        records.secondReactionTime      = RT;
    elseif strcmp(key,'noKey')
        records.slowSecondAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end

    logTrial(records);
    
    global blank
    imshow(blank, 'Parent', handles.axes4 )   
    imshow(blank, 'Parent', handles.axes5 )   
    imshow(blank, 'Parent', handles.axes7 )   
    imshow(blank, 'Parent', handles.axes9 )   
    imshow(blank, 'Parent', handles.axes10)   
    
end

global fileID
fclose (fileID);

function pretraining2(hObject, eventdata, handles,trialsNum);

global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 

global firstTransitionArrayRightCounter
global firstTransitionArrayLeftCounter
global secondTransitionArrayS1RightCounter
global secondTransitionArrayS1LeftCounter
global secondTransitionArrayS2RightCounter
global secondTransitionArrayS2LeftCounter
firstTransitionArrayRightCounter     = 21 ;
firstTransitionArrayLeftCounter      = 21 ;
secondTransitionArrayS1RightCounter  = 21 ;
secondTransitionArrayS1LeftCounter   = 21 ;
secondTransitionArrayS2RightCounter  = 21 ;
secondTransitionArrayS2LeftCounter   = 21 ;


global interBreakTrials
global reactionTimeLimitTraining

global filename
global fileID
filename    = get(handles.edit1,'String');
fileID      = fopen(['Data/',filename,'_Pre2.txt'], 'w');

records.totalReward          = 0;       % total reward obtained so far.
trialsTillRewardHops         = 0;
rewardingState               = 1 ;

for trial = 1 : trialsNum
    
    if mod(trial-1,interBreakTrials)==0 &&  trial>1
        takingBreak(hObject, eventdata, handles);
    end
    
 
    % --------------------------- Initializing the parameters to be logged
    records.trial                 = 0;       % trial number
    records.firstState            = 0;       % always 0
    records.secondState           = 0;       % 1 or 2
    records.thirdState            = 0;       % 1, 2, 3, or 4
    records.firstAction           = 0;       % 0 for left, 1 for right 
    records.secondAction          = 0;       % 0 for left, 1 for right 
    records.firstReactionTime     = 0;       % The reaction time for the first  action
    records.secondReactionTime    = 0;       % The reaction time for the second action
    records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    records.totalReward           = records.totalReward;       % total reward obtained so far.

    records.trial                = trial;
    records.firstState           = 0    ;
    showReadyMessage(hObject, eventdata, handles, trial , trialsNum );    

    reversed = showFirstState(hObject, eventdata, handles);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);
    [secondState,firstTransitionType] = firstTransition (key,firstLevelChance_Pretraining);
    
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showFirstLevelStateAction(hObject, eventdata, handles,'right',reversed);
        records.firstAction             = 1;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'leftShift')        
        showFirstLevelStateAction(hObject, eventdata, handles,'left',reversed);        
        records.firstAction             = 0;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'noKey')
        records.slowFirstAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    reversed = showSecondState(hObject, eventdata, handles, secondState);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);
    [thirdState,secondTransitionType] = secondTransition (secondState,key,secondLevelChance_Pretraining);

    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'right',reversed);
        records.secondAction            = 1;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'leftShift')        
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'left',reversed);
        records.secondAction            = 0;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'noKey')
        records.slowSecondAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    showThirdState(hObject, eventdata, handles, thirdState);
    [key , RT] = getSpace (hObject, eventdata, handles, reactionTimeLimitTraining);
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'space')
        records.thirdReactionTime      = RT;
    elseif strcmp(key,'noKey')
        records.slowThirdAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
            
    logTrial(records);
     
    global blank
    imshow(blank, 'Parent', handles.axes4 )   
    
end

global fileID
fclose (fileID);

function pretraining3(hObject, eventdata, handles,trialsNum);

global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 

global firstTransitionArrayRightCounter
global firstTransitionArrayLeftCounter
global secondTransitionArrayS1RightCounter
global secondTransitionArrayS1LeftCounter
global secondTransitionArrayS2RightCounter
global secondTransitionArrayS2LeftCounter
firstTransitionArrayRightCounter     = 21 ;
firstTransitionArrayLeftCounter      = 21 ;
secondTransitionArrayS1RightCounter  = 21 ;
secondTransitionArrayS1LeftCounter   = 21 ;
secondTransitionArrayS2RightCounter  = 21 ;
secondTransitionArrayS2LeftCounter   = 21 ;


global interBreakTrials
global reactionTimeLimitTest

global filename
global fileID
filename    = get(handles.edit1,'String');
fileID      = fopen(['Data/',filename,'_Pre3.txt'], 'w');

records.totalReward          = 0;       % total reward obtained so far.
trialsTillRewardHops         = 0;
rewardingState               = 1 ;

for trial = 1 : trialsNum
    
    if mod(trial-1,interBreakTrials)==0 &&  trial>1
        takingBreak(hObject, eventdata, handles);
    end
    
 
    % --------------------------- Initializing the parameters to be logged
    records.trial                 = 0;       % trial number
    records.firstState            = 0;       % always 0
    records.secondState           = 0;       % 1 or 2
    records.thirdState            = 0;       % 1, 2, 3, or 4
    records.firstAction           = 0;       % 0 for left, 1 for right 
    records.secondAction          = 0;       % 0 for left, 1 for right 
    records.firstReactionTime     = 0;       % The reaction time for the first  action
    records.secondReactionTime    = 0;       % The reaction time for the second action
    records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    records.totalReward           = records.totalReward;       % total reward obtained so far.

    records.trial                = trial;
    records.firstState           = 0    ;
    showReadyMessage(hObject, eventdata, handles, trial , trialsNum );    

    reversed = showFirstState(hObject, eventdata, handles);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTest);
    [secondState,firstTransitionType] = firstTransition (key,firstLevelChance_Test);
    
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showFirstLevelStateAction(hObject, eventdata, handles,'right',reversed);
        records.firstAction             = 1;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'leftShift')        
        showFirstLevelStateAction(hObject, eventdata, handles,'left',reversed);        
        records.firstAction             = 0;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'noKey')
        records.slowFirstAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    reversed = showSecondState(hObject, eventdata, handles, secondState);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTest);
    [thirdState,secondTransitionType] = secondTransition (secondState,key,secondLevelChance_Test);

    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'right',reversed);
        records.secondAction            = 1;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'leftShift')        
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'left',reversed);
        records.secondAction            = 0;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'noKey')
        records.slowSecondAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    showThirdState(hObject, eventdata, handles, thirdState);
    [key , RT] = getSpace (hObject, eventdata, handles, reactionTimeLimitTest);
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'space')
        records.thirdReactionTime      = RT;
    elseif strcmp(key,'noKey')
        records.slowThirdAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    [trialsTillRewardHops,rewardingState] = updateRewardArrays(trialsTillRewardHops,rewardingState);        
    [reward,rewardPosition] = getReward (thirdState);

    HighlyRewardingState = rewardingState ;
    records.HighlyRewardingState = HighlyRewardingState ;
    records.rewardPosition = rewardPosition ;
    records.rewarded    = reward;
    records.totalReward = records.totalReward + reward;
    showRewardMessage (hObject, eventdata, handles, reward , records.totalReward);
        
    logTrial(records);
       
end

global fileID
fclose (fileID);

function initializeTest(hObject, eventdata, handles);

    global totalReward
    global FirstLevelActionLeft
    global FirstLevelActionRight
    global secondLevelStateAction1Left  
    global secondLevelStateAction1Right  
    global secondLevelStateAction2Left  
    global secondLevelStateAction2Right      
    global thirdLevelState1  
    global thirdLevelState2  
    global thirdLevelState3  
    global thirdLevelState4    
    global blank
    global rectangle

    
    set(handles.text1,'visible','off')        
    set(handles.edit1,'visible','off')        
    set(handles.pushbutton1,'Visible','off')
    set(handles.text3,'visible','on')
    
    totalReward = 0 ;
    %---------------- Counterbalacing the stimuli
    blank = 'stimuli/Blank.jpg';
    rectangle = 'stimuli/Rect.jpg';
    
    FirstLevelAction = randi([1 2],1,1);
    if FirstLevelAction == 1
        FirstLevelActionLeft  = 'stimuli/S0-L.jpg';
        FirstLevelActionRight = 'stimuli/S0-R.jpg';
    elseif FirstLevelAction == 2
        FirstLevelActionLeft  = 'stimuli/S0-R.jpg';
        FirstLevelActionRight = 'stimuli/S0-L.jpg';
    end
    
    secondLevelStateAction1Left  = 'stimuli/S1-L.jpg';
    secondLevelStateAction1Right = 'stimuli/S1-R.jpg';
    secondLevelStateAction2Left  = 'stimuli/S2-L.jpg';
    secondLevelStateAction2Right = 'stimuli/S2-R.jpg';
    
    thirdState1 = randi([1 4],1,1);
    thirdState2 = randi([1 4],1,1);
    while thirdState2 == thirdState1
        thirdState2 = randi([1 4],1,1);
    end
    thirdState3 = randi([1 4],1,1);
    while thirdState3 == thirdState1 || thirdState3 == thirdState2
        thirdState3 = randi([1 4],1,1);
    end
    thirdState4 = 10 - thirdState1 - thirdState2 - thirdState3;

    thirdLevelState1 = ['stimuli/S',int2str(thirdState1),'.bmp'];
    thirdLevelState2 = ['stimuli/S',int2str(thirdState2),'.bmp'];
    thirdLevelState3 = ['stimuli/S',int2str(thirdState3),'.bmp'];
    thirdLevelState4 = ['stimuli/S',int2str(thirdState4),'.bmp'];       
    
function test1(hObject, eventdata, handles,trialsNum);

global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 

global firstTransitionArrayRightCounter
global firstTransitionArrayLeftCounter
global secondTransitionArrayS1RightCounter
global secondTransitionArrayS1LeftCounter
global secondTransitionArrayS2RightCounter
global secondTransitionArrayS2LeftCounter
firstTransitionArrayRightCounter     = 21 ;
firstTransitionArrayLeftCounter      = 21 ;
secondTransitionArrayS1RightCounter  = 21 ;
secondTransitionArrayS1LeftCounter   = 21 ;
secondTransitionArrayS2RightCounter  = 21 ;
secondTransitionArrayS2LeftCounter   = 21 ;

    
global interBreakTrials
global reactionTimeLimitTraining

global filename
global fileID
filename    = get(handles.edit1,'String');
fileID      = fopen(['Data/',filename,'_Test1.txt'], 'w');

records.totalReward          = 0;       % total reward obtained so far.
trialsTillRewardHops         = 0;
rewardingState               = 1 ;

for trial = 1 : trialsNum
    
    if mod(trial-1,interBreakTrials)==0 &&  trial>1
        takingBreak(hObject, eventdata, handles);
    end
    
 
    % --------------------------- Initializing the parameters to be logged
    records.trial                 = 0;       % trial number
    records.firstState            = 0;       % always 0
    records.secondState           = 0;       % 1 or 2
    records.thirdState            = 0;       % 1, 2, 3, or 4
    records.firstAction           = 0;       % 0 for left, 1 for right 
    records.secondAction          = 0;       % 0 for left, 1 for right 
    records.firstReactionTime     = 0;       % The reaction time for the first  action
    records.secondReactionTime    = 0;       % The reaction time for the second action
    records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    records.totalReward           = records.totalReward;       % total reward obtained so far.

    records.trial                = trial;
    records.firstState           = 0    ;
    showReadyMessage(hObject, eventdata, handles, trial , trialsNum );    

    reversed = showFirstState(hObject, eventdata, handles);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);
    [secondState,firstTransitionType] = firstTransition (key,firstLevelChance_Pretraining);
    
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showFirstLevelStateAction(hObject, eventdata, handles,'right',reversed);
        records.firstAction             = 1;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'leftShift')        
        showFirstLevelStateAction(hObject, eventdata, handles,'left',reversed);        
        records.firstAction             = 0;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'noKey')
        records.slowFirstAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    reversed = showSecondState(hObject, eventdata, handles, secondState);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);

    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'right',reversed);
        records.secondAction            = 1;
        records.secondReactionTime      = RT;
    elseif strcmp(key,'leftShift')        
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'left',reversed);
        records.secondAction            = 0;
        records.secondReactionTime      = RT;
    elseif strcmp(key,'noKey')
        records.slowSecondAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end

    logTrial(records);
    
    global blank
    imshow(blank, 'Parent', handles.axes4 )   
    imshow(blank, 'Parent', handles.axes5 )   
    imshow(blank, 'Parent', handles.axes7 )   
    imshow(blank, 'Parent', handles.axes9 )   
    imshow(blank, 'Parent', handles.axes10)   
    
end

global fileID
fclose (fileID);

function test2(hObject, eventdata, handles,trialsNum);

global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 

global firstTransitionArrayRightCounter
global firstTransitionArrayLeftCounter
global secondTransitionArrayS1RightCounter
global secondTransitionArrayS1LeftCounter
global secondTransitionArrayS2RightCounter
global secondTransitionArrayS2LeftCounter
firstTransitionArrayRightCounter     = 21 ;
firstTransitionArrayLeftCounter      = 21 ;
secondTransitionArrayS1RightCounter  = 21 ;
secondTransitionArrayS1LeftCounter   = 21 ;
secondTransitionArrayS2RightCounter  = 21 ;
secondTransitionArrayS2LeftCounter   = 21 ;


global interBreakTrials
global reactionTimeLimitTraining

global filename
global fileID
filename    = get(handles.edit1,'String');
fileID      = fopen(['Data/',filename,'_Test2.txt'], 'w');

records.totalReward          = 0;       % total reward obtained so far.
trialsTillRewardHops         = 0;
rewardingState               = 1 ;

for trial = 1 : trialsNum
    
    if mod(trial-1,interBreakTrials)==0 &&  trial>1
        takingBreak(hObject, eventdata, handles);
    end
    
 
    % --------------------------- Initializing the parameters to be logged
    records.trial                 = 0;       % trial number
    records.firstState            = 0;       % always 0
    records.secondState           = 0;       % 1 or 2
    records.thirdState            = 0;       % 1, 2, 3, or 4
    records.firstAction           = 0;       % 0 for left, 1 for right 
    records.secondAction          = 0;       % 0 for left, 1 for right 
    records.firstReactionTime     = 0;       % The reaction time for the first  action
    records.secondReactionTime    = 0;       % The reaction time for the second action
    records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    records.totalReward           = records.totalReward;       % total reward obtained so far.

    records.trial                = trial;
    records.firstState           = 0    ;
    showReadyMessage(hObject, eventdata, handles, trial , trialsNum );    

    reversed = showFirstState(hObject, eventdata, handles);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);
    [secondState,firstTransitionType] = firstTransition (key,firstLevelChance_Pretraining);
    
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showFirstLevelStateAction(hObject, eventdata, handles,'right',reversed);
        records.firstAction             = 1;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'leftShift')        
        showFirstLevelStateAction(hObject, eventdata, handles,'left',reversed);        
        records.firstAction             = 0;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'noKey')
        records.slowFirstAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    reversed = showSecondState(hObject, eventdata, handles, secondState);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTraining);
    [thirdState,secondTransitionType] = secondTransition (secondState,key,secondLevelChance_Pretraining);

    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'right',reversed);
        records.secondAction            = 1;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'leftShift')        
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'left',reversed);
        records.secondAction            = 0;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'noKey')
        records.slowSecondAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    showThirdState(hObject, eventdata, handles, thirdState);
    [key , RT] = getSpace (hObject, eventdata, handles, reactionTimeLimitTraining);
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'space')
        records.thirdReactionTime      = RT;
    elseif strcmp(key,'noKey')
        records.slowThirdAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
            
    logTrial(records);
     
    global blank
    imshow(blank, 'Parent', handles.axes4 )   
    
end

global fileID
fclose (fileID);

function test3(hObject, eventdata, handles,trialsNum);

global firstLevelChance_Test
global secondLevelChance_Test
global firstLevelChance_Pretraining
global secondLevelChance_Pretraining 

global firstTransitionArrayRightCounter
global firstTransitionArrayLeftCounter
global secondTransitionArrayS1RightCounter
global secondTransitionArrayS1LeftCounter
global secondTransitionArrayS2RightCounter
global secondTransitionArrayS2LeftCounter
firstTransitionArrayRightCounter     = 21 ;
firstTransitionArrayLeftCounter      = 21 ;
secondTransitionArrayS1RightCounter  = 21 ;
secondTransitionArrayS1LeftCounter   = 21 ;
secondTransitionArrayS2RightCounter  = 21 ;
secondTransitionArrayS2LeftCounter   = 21 ;


global interBreakTrials
global reactionTimeLimitTest

global filename
global fileID
filename    = get(handles.edit1,'String');
fileID      = fopen(['Data/',filename,'_Test3.txt'], 'w');

records.totalReward          = 0;       % total reward obtained so far.
trialsTillRewardHops         = 0;
rewardingState               = 1 ;

for trial = 1 : trialsNum
    
    if mod(trial-1,interBreakTrials)==0 &&  trial>1
        takingBreak(hObject, eventdata, handles);
    end
    
 
    % --------------------------- Initializing the parameters to be logged
    records.trial                 = 0;       % trial number
    records.firstState            = 0;       % always 0
    records.secondState           = 0;       % 1 or 2
    records.thirdState            = 0;       % 1, 2, 3, or 4
    records.firstAction           = 0;       % 0 for left, 1 for right 
    records.secondAction          = 0;       % 0 for left, 1 for right 
    records.firstReactionTime     = 0;       % The reaction time for the first  action
    records.secondReactionTime    = 0;       % The reaction time for the second action
    records.thirdReactionTime     = 0;       % The reaction time for the third action (space)
    records.slowFirstAction       = 0;       % 1 for too slow reaction for the first  action, 0 otherwise 
    records.slowSecondAction      = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.slowThirdAction       = 0;       % 1 for too slow reaction for the second action, 0 otherwise 
    records.firstTransition       = 0;       % 0 for common, and 1 for rare transition at the first  level
    records.secondTransition      = 0;       % 0 for common, and 1 for rare transition at the second level
    records.HighlyRewardingState  = 0;       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    records.rewardPosition        = 0;       % 1, 2, 3, or 4 - for where the reward is in this trial
    records.rewarded              = 0;       % 0 for unrewarded, and 1 for rewarded
    records.totalReward           = records.totalReward;       % total reward obtained so far.

    records.trial                = trial;
    records.firstState           = 0    ;
    showReadyMessage(hObject, eventdata, handles, trial , trialsNum );    

    reversed = showFirstState(hObject, eventdata, handles);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTest);
    [secondState,firstTransitionType] = firstTransition (key,firstLevelChance_Test);
    
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showFirstLevelStateAction(hObject, eventdata, handles,'right',reversed);
        records.firstAction             = 1;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'leftShift')        
        showFirstLevelStateAction(hObject, eventdata, handles,'left',reversed);        
        records.firstAction             = 0;
        records.firstReactionTime       = RT;
        records.secondState             = secondState;
        records.firstTransition         = firstTransitionType;
    elseif strcmp(key,'noKey')
        records.slowFirstAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    reversed = showSecondState(hObject, eventdata, handles, secondState);
    [key,RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimitTest);
    [thirdState,secondTransitionType] = secondTransition (secondState,key,secondLevelChance_Test);

    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'rightShift')
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'right',reversed);
        records.secondAction            = 1;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'leftShift')        
        showSecondLevelStateAction(hObject, eventdata, handles, secondState, 'left',reversed);
        records.secondAction            = 0;
        records.secondReactionTime      = RT;
        records.thirdState              = thirdState;
        records.secondTransition        = secondTransitionType;
    elseif strcmp(key,'noKey')
        records.slowSecondAction         = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    showThirdState(hObject, eventdata, handles, thirdState);
    [key , RT] = getSpace (hObject, eventdata, handles, reactionTimeLimitTest);
    if strcmp(key,'escape')
        finalize(hObject, eventdata, handles,records.totalReward);    
    elseif strcmp(key,'space')
        records.thirdReactionTime      = RT;
    elseif strcmp(key,'noKey')
        records.slowThirdAction        = 1; 
        showTooLateMessage(hObject, eventdata, handles);    
        logTrial(records);
        continue;
    end
    
    [trialsTillRewardHops,rewardingState] = updateRewardArrays(trialsTillRewardHops,rewardingState);        
    [reward,rewardPosition] = getReward (thirdState);

    HighlyRewardingState = rewardingState ;
    records.HighlyRewardingState = HighlyRewardingState ;
    records.rewardPosition = rewardPosition ;
    records.rewarded    = reward;
    records.totalReward = records.totalReward + reward;
    showRewardMessage (hObject, eventdata, handles, reward , records.totalReward);
        
    logTrial(records);
       
end

global fileID
fclose (fileID);

finalize(hObject, eventdata, handles,records.totalReward);    

function readyForNext (hObject, eventdata, handles);

    global blank
    imshow(blank, 'Parent', handles.axes14)
    set(handles.axes14,'visible','off')            
    imshow(blank, 'Parent', handles.axes4)
    h=findobj(handles.axes4,'type','image'); set(h,'visible','off')        

    set(handles.text6,'FontSize',50)        
    set(handles.text6,'ForegroundColor','green')        
    set(handles.text6,'String','Ready for the next phase ?')    
    set(handles.text6,'visible','on')        
    
    set(handles.text9,'String','')    
%    set(handles.text7,'String','')    
    set(handles.text3,'FontSize',25)        
    set(handles.text3,'String','Press any key to continue the experiment...')    
    set(handles.text3,'visible','on')        
    set(handles.text9,'visible','off')        
    pause(1.001)
    
    touch = 0;
    while ~(touch)
        pause(0.001);
        [touch, secs, keycode] = KbCheck;
    end
    
    set(handles.text9,'visible','on')        
    set(handles.text3,'FontSize',16)        
    set(handles.text3,'String','Press <ESC> to quit...')    
    
    %-----------------
    
    global phaseCounter
    phaseCounter = phaseCounter+1
    
    if phaseCounter==2
        set(handles.text10,'BackgroundColor','white')        
        set(handles.text12,'BackgroundColor','yellow')        
    elseif phaseCounter==3
        set(handles.text12,'BackgroundColor','white')        
        set(handles.text13,'BackgroundColor','yellow')        
    elseif phaseCounter==4
        set(handles.text13,'BackgroundColor','white')        
        set(handles.text15,'BackgroundColor','yellow')        
    elseif phaseCounter==5
        set(handles.text15,'BackgroundColor','white')        
        set(handles.text16,'BackgroundColor','yellow')        
    elseif phaseCounter==6
        set(handles.text16,'BackgroundColor','white')        
        set(handles.text17,'BackgroundColor','yellow')                
    end    

function CallExperimentalist (hObject, eventdata, handles);

    global blank
    imshow(blank, 'Parent', handles.axes14)
    set(handles.axes14,'visible','off')            
    imshow(blank, 'Parent', handles.axes4)
    h=findobj(handles.axes4,'type','image'); set(h,'visible','off')        

    set(handles.text6,'FontSize',50)        
    set(handles.text6,'ForegroundColor','green')        
    set(handles.text6,'String','Please call the experimentalist...')    
    set(handles.text6,'visible','on')        
    
    set(handles.text9,'String','')    
%    set(handles.text7,'String','')    
    set(handles.text3,'FontSize',25)        
    set(handles.text3,'String','Press any key to continue the experiment...')    
    set(handles.text3,'visible','on')        
    set(handles.text9,'visible','off')        
    pause(0.001)
    
    touch = 0;

    while ~( touch && (keycode(20) == 1 ))
        pause(0.001);
        [touch, secs, keycode] = KbCheck;
    end
    
    set(handles.text9,'visible','on')        
    set(handles.text3,'FontSize',16)        
    set(handles.text3,'String','Press <ESC> to quit...')    
    
    %-----------------
    
    global phaseCounter
    phaseCounter = phaseCounter+1
    
    if phaseCounter==2
        set(handles.text10,'BackgroundColor','white')        
        set(handles.text12,'BackgroundColor','yellow')        
    elseif phaseCounter==3
        set(handles.text12,'BackgroundColor','white')        
        set(handles.text13,'BackgroundColor','yellow')        
    elseif phaseCounter==4
        set(handles.text13,'BackgroundColor','white')        
        set(handles.text15,'BackgroundColor','yellow')        
    elseif phaseCounter==5
        set(handles.text15,'BackgroundColor','white')        
        set(handles.text16,'BackgroundColor','yellow')        
    elseif phaseCounter==6
        set(handles.text16,'BackgroundColor','white')        
        set(handles.text17,'BackgroundColor','yellow')                
    end       
    
function showTooLateMessage(hObject, eventdata, handles);    
    
    global tooLateMessageTime
    global blank

    imshow(blank, 'Parent', handles.axes4 )
    imshow(blank, 'Parent', handles.axes5 )
    imshow(blank, 'Parent', handles.axes7 )
    imshow(blank, 'Parent', handles.axes9 )
    imshow(blank, 'Parent', handles.axes10)
    imshow(blank, 'Parent', handles.axes12)
    imshow(blank, 'Parent', handles.axes14)
    h=findobj(handles.axes4 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes5 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes7 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes9 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes10,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes12,'type','image'); set(h,'visible','off')    
    h=findobj(handles.axes14,'type','image'); set(h,'visible','off')    
    
    set(handles.text4,'ForegroundColor','red')        
    set(handles.text6,'ForegroundColor','red')        
    set(handles.text4,'visible','on')        
    set(handles.text4,'String','You were too slow in responding.')    
    set(handles.text6,'visible','on')        
    set(handles.text6,'String','You lost this trial.')    
    pause (tooLateMessageTime)
    set(handles.text4,'ForegroundColor','green')        
    set(handles.text6,'ForegroundColor','green')        
    set(handles.text4,'visible','off')        
    set(handles.text6,'visible','off')        
    
function showReadyMessage(hObject, eventdata, handles, trialNum , totalTrialsNum)
    global gettingReadyTime
    global blank
    timeStep = gettingReadyTime/3 ;
                  
%------------------------------------------------------
    global phaseCounter
    
    if phaseCounter==1
        set(handles.text7 ,'String',[int2str(trialNum),'/',int2str(totalTrialsNum)])    
    elseif phaseCounter==2
        set(handles.text18,'String',[int2str(trialNum),'/',int2str(totalTrialsNum)])    
    elseif phaseCounter==3
        set(handles.text19 ,'String',[int2str(trialNum),'/',int2str(totalTrialsNum)])    
    elseif phaseCounter==4
        set(handles.text20 ,'String',[int2str(trialNum),'/',int2str(totalTrialsNum)])    
    elseif phaseCounter==5
        set(handles.text21 ,'String',[int2str(trialNum),'/',int2str(totalTrialsNum)])    
    elseif phaseCounter==6
        set(handles.text22,'String',[int2str(trialNum),'/',int2str(totalTrialsNum)])    
    end    
    
    
%------------------------------------------------------

    imshow(blank, 'Parent', handles.axes14)
    h=findobj(handles.axes14,'type','image'); set(h,'visible','off')        
    
    imshow(blank, 'Parent', handles.axes4)
    h=findobj(handles.axes4,'type','image'); set(h,'visible','off')        
    
    set(handles.axes12,'visible','on')        
    imshow('stimuli/Fixed.jpg', 'Parent',   handles.axes12)
    
    pause (0.001);
    

    set(handles.text4,'String','Next trial:')    
    set(handles.text4,'visible','on')        
    set(handles.text6,'visible','on')        
    set(handles.text6,'String','')
    pause (timeStep);
    set(handles.text6,'String','3')
    pause (timeStep);
    set(handles.text6,'String','2')
    pause (timeStep);
    set(handles.text6,'String','1')
    pause (timeStep);
    set(handles.text6,'String','')
    set(handles.text4,'visible','off')        
    set(handles.text6,'visible','off')        

function reversed = showFirstState (hObject, eventdata, handles)

    global FirstLevelActionLeft
    global FirstLevelActionRight
    global blank
    
    set(handles.axes12 ,'visible','on')        
    imshow(blank, 'Parent',    handles.axes12)
    
    set(handles.axes7 ,'visible','on')        
    set(handles.axes10,'visible','on')        

    reversed = randi([0 1],1,1);

    if reversed
        imshow(FirstLevelActionRight, 'Parent',    handles.axes7 )
        imshow(FirstLevelActionLeft , 'Parent',    handles.axes10)
    else
        imshow(FirstLevelActionLeft,  'Parent',    handles.axes7 )
        imshow(FirstLevelActionRight, 'Parent',    handles.axes10)
    end
          
    pause (0.0001)

function showFirstLevelStateAction(hObject, eventdata, handles, action, reversed);        

    global firstLevelActionPresentation
    global rectangle

    if reversed
        if strcmp(action,'left')
            imshow(rectangle, 'Parent', handles.axes9)
        elseif strcmp(action,'right')
            imshow(rectangle, 'Parent', handles.axes5)
        end    
    else
        if strcmp(action,'left')
            imshow(rectangle, 'Parent', handles.axes5)
        elseif strcmp(action,'right')
            imshow(rectangle, 'Parent', handles.axes9)
        end            
    end
    
    pause (firstLevelActionPresentation)
    pause (0.001)
    
function [secondState,transitionType] = firstTransition (key,rareProbability);
    
    global firstTransitionArrayRight
    global firstTransitionArrayLeft
    global firstTransitionArrayRightCounter
    global firstTransitionArrayLeftCounter

    
    if firstTransitionArrayRightCounter==21
        firstTransitionArrayRightCounter = 1 ;
        firstTransitionArrayRight = enforcedRandom(20 , 1-rareProbability );        
    end

    if firstTransitionArrayLeftCounter==21
        firstTransitionArrayLeftCounter = 1 ;
        firstTransitionArrayLeft = enforcedRandom(20 , 1-rareProbability );        
    end
    

    
    if strcmp(key,'rightShift')                                                 % Right action
        if firstTransitionArrayRight(firstTransitionArrayRightCounter)==0           % Common transition
            transitionType = 0;
            secondState = 2;
        else                                                                        % Rare   transition
            transitionType = 1;
            secondState = 1;
        end
        firstTransitionArrayRightCounter = firstTransitionArrayRightCounter +1;
        
    else                                                                        % Left  action
        if firstTransitionArrayLeft (firstTransitionArrayLeftCounter )==0           % Common transition
            transitionType = 0;
            secondState = 1;
        else                                                                        % Rare   transition
            transitionType = 1;
            secondState = 2;
        end
        firstTransitionArrayLeftCounter = firstTransitionArrayLeftCounter +1;
        
    end
    
function reversed = showSecondState(hObject, eventdata, handles, secondState);
    global secondLevelStateAction1Left  
    global secondLevelStateAction1Right  
    global secondLevelStateAction2Left  
    global secondLevelStateAction2Right  
    global blank  
    
    imshow(blank , 'Parent', handles.axes5 )
    imshow(blank , 'Parent', handles.axes9 )
    
    reversed = randi([0 1],1,1);

    if reversed
        if secondState == 1
            imshow(secondLevelStateAction1Left , 'Parent', handles.axes10)
            imshow(secondLevelStateAction1Right, 'Parent', handles.axes7 )
        elseif secondState == 2
            imshow(secondLevelStateAction2Left , 'Parent', handles.axes10)
            imshow(secondLevelStateAction2Right, 'Parent', handles.axes7 )
        end
    else
        if secondState == 1
            imshow(secondLevelStateAction1Left , 'Parent', handles.axes7)
            imshow(secondLevelStateAction1Right, 'Parent', handles.axes10)
        elseif secondState == 2
            imshow(secondLevelStateAction2Left , 'Parent', handles.axes7)
            imshow(secondLevelStateAction2Right, 'Parent', handles.axes10)
        end
    end
    
    pause (0.0001)

function [thirdState,transitionType] = secondTransition (secondState, key, rareProbability);

    global secondTransitionArrayS1Right
    global secondTransitionArrayS1Left
    global secondTransitionArrayS2Right
    global secondTransitionArrayS2Left

    global secondTransitionArrayS1RightCounter
    global secondTransitionArrayS1LeftCounter
    global secondTransitionArrayS2RightCounter
    global secondTransitionArrayS2LeftCounter
    
    if secondTransitionArrayS1RightCounter==21
        secondTransitionArrayS1RightCounter = 1 ;
        secondTransitionArrayS1Right = enforcedRandom(20 , 1-rareProbability );        
    end

    if secondTransitionArrayS1LeftCounter==21
        secondTransitionArrayS1LeftCounter = 1 ;
        secondTransitionArrayS1Left = enforcedRandom(20 , 1-rareProbability );        
    end

    if secondTransitionArrayS2RightCounter==21
        secondTransitionArrayS2RightCounter = 1 ;
        secondTransitionArrayS2Right = enforcedRandom(20 , 1-rareProbability );        
    end

    if secondTransitionArrayS2LeftCounter==21
        secondTransitionArrayS2LeftCounter = 1 ;
        secondTransitionArrayS2Left = enforcedRandom(20 , 1-rareProbability );        
    end
    
        
    
    if secondState==1                                                                   % secondState=1
        if strcmp(key,'rightShift')                                                         % Right action 
            if secondTransitionArrayS1Right (secondTransitionArrayS1RightCounter )==0           % Common transition
                transitionType = 0;                 
                thirdState = 2;
            else                                                                                % rare transition
                transitionType = 1;                 
                thirdState = 4;
            end
            secondTransitionArrayS1RightCounter = secondTransitionArrayS1RightCounter + 1;
        else                                                                                % Left action
            if secondTransitionArrayS1Left (secondTransitionArrayS1LeftCounter )==0           % Common transition
                transitionType = 0;                 
                thirdState = 1;
            else                                                                                % rare transition
                transitionType = 1;                 
                thirdState = 3;
            end
            secondTransitionArrayS1LeftCounter  = secondTransitionArrayS1LeftCounter  + 1;
        end
    else                                                                                % secondState=2
        if strcmp(key,'rightShift')                                                         % Right action 
            if secondTransitionArrayS2Right (secondTransitionArrayS2RightCounter )==0           % Common transition
                transitionType = 0;                 
                thirdState = 4;
            else                                                                                % rare transition
                transitionType = 1;                 
                thirdState = 2;
            end
            secondTransitionArrayS2RightCounter = secondTransitionArrayS2RightCounter + 1;
        else                                                                                % Left action
            if secondTransitionArrayS2Left (secondTransitionArrayS2LeftCounter )==0           % Common transition
                transitionType = 0;                 
                thirdState = 3;
            else                                                                                % rare transition
                transitionType = 1;                 
                thirdState = 1;
            end
            secondTransitionArrayS2LeftCounter  = secondTransitionArrayS2LeftCounter  + 1;
            
        end    
    end
    
function showSecondLevelStateAction(hObject, eventdata, handles, secondState, key, reversed);
    global rectangle

    global secondLevelActionPresentation
    
    if reversed
        if strcmp(key,'left')
            imshow(rectangle, 'Parent', handles.axes9)
        else
            imshow(rectangle, 'Parent', handles.axes5)
        end
    else
        if strcmp(key,'left')
            imshow(rectangle, 'Parent', handles.axes5)
        else
            imshow(rectangle, 'Parent', handles.axes9)
        end
    end
    
    pause (secondLevelActionPresentation)
    pause (0.001)

function showThirdState(hObject, eventdata, handles, thirdState);
    
    global thirdLevelState1  
    global thirdLevelState2  
    global thirdLevelState3  
    global thirdLevelState4  

    global blank  

    global forcedWaitingAtFractal

    imshow(blank, 'Parent', handles.axes5 )
    imshow(blank, 'Parent', handles.axes7 )
    imshow(blank, 'Parent', handles.axes9 )
    imshow(blank, 'Parent', handles.axes10)
    imshow(blank, 'Parent', handles.axes12)
    h=findobj(handles.axes5 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes7 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes9,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes10,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes12,'type','image'); set(h,'visible','off')
    
    if     thirdState == 1
        imshow(thirdLevelState1, 'Parent', handles.axes4)
    elseif thirdState == 2
        imshow(thirdLevelState2, 'Parent', handles.axes4)
    elseif thirdState == 3
        imshow(thirdLevelState3, 'Parent', handles.axes4)
    elseif thirdState == 4
        imshow(thirdLevelState4, 'Parent', handles.axes4)
    end

    
    pause(forcedWaitingAtFractal);

    global rectangle
    set(handles.axes14,'visible','on')        
    imshow(rectangle, 'Parent', handles.axes14)
    
    pause(0.001);
   
function [postTrialsTillRewardHops,postRewardingState]  = updateRewardArrays(preTrialsTillRewardHops,preRewardingState);

    global rewardArrayRaw
    global rewardArray
    global rewardArrayCounter
    global hoppingTrialsMean
    global hoppingTrialsVariance
    global rewardChance  
    
    if (preTrialsTillRewardHops==0)

        %------------------ Random number for the number of trials the reward stays in its new position
        postTrialsTillRewardHops = round (normrnd( hoppingTrialsMean , hoppingTrialsVariance , 1 , 1));
        if postTrialsTillRewardHops<1
            postTrialsTillRewardHops = 1;
        end
                
        %------------------ New position of the reward
        randNumber = randi([1,3]);
        if randNumber<preRewardingState
            postRewardingState = randNumber;            
        else
            postRewardingState = randNumber+1;            
        end
                    
        %------------------ Filling in the reward array, determinin the exact position of reward in the next N trials      
        rewardArrayCounter = 1;
        rewardArrayRaw = enforcedRandom (postTrialsTillRewardHops,1-rewardChance);

        rewardArray = zeros ( 1 , postTrialsTillRewardHops ) ;
        
        
        for i =1:postTrialsTillRewardHops
            if rewardArrayRaw(i) == 0
                rewardArray(i) = postRewardingState;
            else                                
                
                randNumber = randi([1,3]);
                if randNumber<postRewardingState
                    anotherState = randNumber ;            
                else
                    anotherState = randNumber + 1 ;            
                end                
                
                rewardArray(i) = anotherState ;
            end
        end
        
        
        postTrialsTillRewardHops = postTrialsTillRewardHops - 1;
        
    else
        postRewardingState = preRewardingState ;
        postTrialsTillRewardHops = preTrialsTillRewardHops - 1;
        rewardArrayCounter = rewardArrayCounter + 1;
    end
            
function [ reward , rewardPosition ] = getReward (thirdState);

    global rewardArray
    global rewardArrayCounter
    if rewardArray(rewardArrayCounter) == thirdState
        reward = 1;
    else
        reward = 0;
    end
    rewardPosition = rewardArray(rewardArrayCounter);
    
function showRewardMessage (hObject, eventdata, handles, reward , totalReward );    

    global rewardPresentationTime

    global blank
    imshow(blank, 'Parent', handles.axes14)
    set(handles.axes14,'visible','off')            
    imshow(blank, 'Parent', handles.axes4)
    h=findobj(handles.axes4,'type','image'); set(h,'visible','off')        
        
    if reward == 0
        set(handles.text4,'FontSize',50)        
        set(handles.text4,'ForegroundColor','red')        
        set(handles.text4,'String','You lost.')    
        set(handles.text4,'visible','on')        
        
        set(handles.axes4,'visible','on')        
        imshow('stimuli/lost.jpg', 'Parent', handles.axes4)

    elseif reward == 1        
        set(handles.text4,'FontSize',50)        
        set(handles.text4,'ForegroundColor','green')        
        set(handles.text4,'String','You Won.')    
        set(handles.text4,'visible','on')        

        set(handles.axes4,'visible','on')        
        imshow('stimuli/won.jpg', 'Parent', handles.axes4)

    end
    
%    set(handles.text9,'String',['Your total reward is ',int2str(totalReward),'0.'])    

    h=findobj(handles.axes5 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes7 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes9,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes10,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes12,'type','image'); set(h,'visible','off')

    pause (rewardPresentationTime)

    set(handles.text4,'FontSize',30)        
    set(handles.text4,'ForegroundColor','green')        
    set(handles.text4,'visible','off')        
    set(handles.axes4,'visible','off')            
    h=findobj(handles.axes4,'type','image'); set(h,'visible','off')
    
    set(handles.text9,'String','')    
    
function logTrial(records);
    global fileID

    fprintf(fileID,'%u,'    ,records.trial                 );       % trial number
    fprintf(fileID,'%u,'    ,records.firstState            );       % always 0
    fprintf(fileID,'%u,'    ,records.secondState           );       % 0 or 1
    fprintf(fileID,'%u,'    ,records.thirdState            );       % 0, 1, 2, or 3
    fprintf(fileID,'%u,'    ,records.firstAction           );       % 0 for left, 1 for right 
    fprintf(fileID,'%u,'    ,records.secondAction          );       % 0 for left, 1 for right 
    fprintf(fileID,'%f,'    ,records.firstReactionTime     );       % The reaction time for the first  action
    fprintf(fileID,'%f,'    ,records.secondReactionTime    );       % The reaction time for the second action
    fprintf(fileID,'%f,'    ,records.thirdReactionTime     );       % The reaction time for the third action
    fprintf(fileID,'%u,'    ,records.slowFirstAction       );       % 1 for too slow reaction for the first  action, 0 otherwise 
    fprintf(fileID,'%u,'    ,records.slowSecondAction      );       % 1 for too slow reaction for the second action, 0 otherwise 
    fprintf(fileID,'%u,'    ,records.slowThirdAction       );       % 1 for too slow reaction for the second action, 0 otherwise 
    fprintf(fileID,'%u,'    ,records.firstTransition       );       % 0 for common, and 1 for rare transition at the first  level
    fprintf(fileID,'%u,'    ,records.secondTransition      );       % 0 for common, and 1 for rare transition at the second level
    fprintf(fileID,'%u,'    ,records.HighlyRewardingState  );       % 1, 2, 3, or 4 - for the state that is rewarding most likely
    fprintf(fileID,'%u,'    ,records.rewardPosition        );       % 1, 2, 3, or 4 - for where the reward is in this trial
    fprintf(fileID,'%u,'    ,records.rewarded              );       % 0 for unrewarded, and 1 for rewarded
    fprintf(fileID,'%u \n'  ,records.totalReward           );       % total reward obtained so far.    
        
function finalize (hObject, eventdata, handles, totalReward);
    
    global blank 
    
    imshow(blank, 'Parent', handles.axes4 )
    imshow(blank, 'Parent', handles.axes5 )
    imshow(blank, 'Parent', handles.axes7 )
    imshow(blank, 'Parent', handles.axes9 )
    imshow(blank, 'Parent', handles.axes10)
    imshow(blank, 'Parent', handles.axes12)
    h=findobj(handles.axes4 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes5 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes7 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes9 ,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes10,'type','image'); set(h,'visible','off')
    h=findobj(handles.axes12,'type','image'); set(h,'visible','off')    


    set(handles.text4,'FontSize',50)        
    set(handles.text4,'ForegroundColor','red')        
    set(handles.text4,'String','T H E     E N D...')    
    set(handles.text4,'visible','on')        

    set(handles.text6,'FontSize',40)        
    set(handles.text6,'ForegroundColor','green')        
    set(handles.text6,'String','Thanks for your participation in this experiment.')    
    set(handles.text6,'visible','on')        
    
    set(handles.text9,'visible','on')        
    set(handles.text9,'String',['Your total reward is ',int2str(totalReward),'0.'])    
    set(handles.text3,'String','Press any key to quit...')    
    pause(0.001)
    
    touch = 0;
    while ~(touch)
        WaitSecs(0.001);
        [touch, secs, keycode] = KbCheck;
    end
    
    close (handles.figure1);  
   
function [key , RT] = getKey (hObject, eventdata, handles, reversed, reactionTimeLimit);

    touch = 0;
    tStart = GetSecs;
    tEnd   = tStart + reactionTimeLimit ;
    while ~( ( touch && (keycode(229) == 1 || keycode(225) == 1 || keycode(41) == 1) ) || GetSecs>tEnd )
        WaitSecs(0.001);
        [touch, secs, keycode] = KbCheck;
    end
    
    RT = GetSecs - tStart ;
    
    if keycode(41) == 1
        key = 'escape';
    elseif keycode(229) == 1
        if reversed
            key = 'leftShift';
        else
            key = 'rightShift';
        end
    elseif keycode(225) == 1
        if reversed
            key = 'rightShift';
        else
            key = 'leftShift';
        end
    else
        key = 'noKey';
    end
    
function [key , RT] = getSpace (hObject, eventdata, handles, reactionTimeLimit);

    touch = 0;
    tStart = GetSecs;
    tEnd   = tStart + reactionTimeLimit ;
    while ~( ( touch && (keycode(44) == 1 || keycode(41) == 1) ) || GetSecs>tEnd )
        WaitSecs(0.001);
        [touch, secs, keycode] = KbCheck;
    end
        
    RT = GetSecs - tStart ;
    
    if keycode(41) == 1
        key = 'escape';
    elseif keycode(44) == 1
        key = 'space';
    else
        key = 'noKey';
    end
    
function takingBreak(hObject, eventdata, handles);

    global forcedBreakTime

    global blank
    imshow(blank, 'Parent', handles.axes14)
    set(handles.axes14,'visible','off')            
    imshow(blank, 'Parent', handles.axes4)
    h=findobj(handles.axes4,'type','image'); set(h,'visible','off')        
    
    set(handles.text6,'FontSize',40)        
    set(handles.text6,'ForegroundColor','green')        
    set(handles.text6,'String',['Please take a break for at least ' ,int2str(forcedBreakTime), ' seconds..'])    
    set(handles.text6,'visible','on')        
    
    set(handles.text3,'String','')    
    set(handles.text9,'String','')    
%    set(handles.text7,'String','')    
    set(handles.text3,'visible','off')        

    set(handles.text9,'ForegroundColor','green')        
    set(handles.text9,'FontSize',50)        
    set(handles.text9,'visible','on')        
    for i=1:forcedBreakTime
        set(handles.text9,'String',int2str(forcedBreakTime-i+1))            
        pause (1);
    end
    
    set(handles.text9,'String','Press any key to continue the experiment...')    
    set(handles.text9,'visible','on')        
    pause(0.001)
    
    touch = 0;
    while ~(touch)
        WaitSecs(0.001);
        [touch, secs, keycode] = KbCheck;
    end
    
    set(handles.text9,'FontSize',30)        
    set(handles.text9,'visible','off')        
    set(handles.text3,'visible','on')        
    set(handles.text3,'FontSize',16)        
    set(handles.text3,'String','Press <ESC> to quit...')    
    
function randomArray = enforcedRandom(arrayLength , probability);

    randomArray     = zeros ( 1 , arrayLength ) ;
    
    numberOfOnes    = arrayLength * probability ;

    emptyCells      = ones ( 1 , arrayLength ) ;
    emptyCellsNum   = arrayLength ;

    
    for i=1:numberOfOnes
        newOne = randi ([1,emptyCellsNum]);
        
        
        indexCounter    = 0 ;
        onesCounter     = 0 ;
        
        while onesCounter < newOne
            indexCounter = indexCounter + 1 ;
            
            if emptyCells(indexCounter)==1
                onesCounter = onesCounter + 1 ;
            end            
        end
        
        randomArray(indexCounter) = 1       ;
        
        emptyCells(indexCounter) = 0        ;
        emptyCellsNum = emptyCellsNum - 1   ;
        
        if indexCounter ~= 1
            emptyCells(indexCounter-1) = 0      ;
            emptyCellsNum = emptyCellsNum - 1   ;            
        end
        
        if indexCounter ~= arrayLength
            emptyCells(indexCounter+1) = 0      ;
            emptyCellsNum = emptyCellsNum - 1   ;            
        end
                            
    end    
