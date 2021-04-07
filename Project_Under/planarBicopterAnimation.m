function [sys,x0,str,ts,simStateCompliance] = planarBicopterAnimation(t,x,u,flag)
%planarBicopterAnimation S-function for making planar bicopter animation.
%
%   Created based on the MATLAB pandan example by Rushikesh Kamalapurkar
%
%   November 08, 2019

% Plots every major integration step, but has no states of its own
switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes();

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2,
    sys=mdlUpdate(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate();
    
  %%%%%%%%%%%%%%%%
  % Unused flags %
  %%%%%%%%%%%%%%%%
  case { 1, 3, 4},
    sys = [];
    
  %%%%%%%%%%%%%%%
  % DeleteBlock %
  %%%%%%%%%%%%%%%
  case 'DeleteBlock',
    LocalDeleteBlock
    
  %%%%%%%%%%%%%%%
  % DeleteFigure %
  %%%%%%%%%%%%%%%
  case 'DeleteFigure',
    LocalDeleteFigure
  
  %%%%%%%%%%
  % Slider %
  %%%%%%%%%%
  case 'Slider',
    LocalSlider
  
  %%%%%%%%%
  % Close %
  %%%%%%%%%
  case 'Close',
    LocalClose
  
  %%%%%%%%%%%%
  % Playback %
  %%%%%%%%%%%%
  case 'Playback',
    LocalPlayback
   
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(message('simdemos:general:UnhandledFlag', num2str( flag )));
end

% end planarBicopterAnimation

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts,simStateCompliance]=mdlInitializeSizes()

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 0;
sizes.NumOutputs     = 0;
sizes.NumInputs      = 5;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times, for the pendulum example,
% the animation is updated every 0.1 seconds
%
ts  = [0.1 0];

%
% create the figure, if necessary
%
LocalPendInit();

% specify that the simState for this s-function is same as the default
simStateCompliance = 'DefaultSimState';

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Update the pendulum animation.
%=============================================================================
%
function sys=mdlUpdate(t,x,u) %#ok<INUSL>

fig = get_param(gcbh,'UserData');
if ishghandle(fig, 'figure'),
  if strcmp(get(fig,'Visible'),'on'),
    ud = get(fig,'UserData');
    LocalplanarBicopterSets(t,ud,u);
  end
end;
 
sys = [];

% end mdlUpdate

%
%=============================================================================
% mdlTerminate
%=============================================================================
%
function sys=mdlTerminate() 
sys = [];

% end mdlTerminate

%
%=============================================================================
% LocalDeleteBlock
% The animation block is being deleted, delete the associated figure.
%=============================================================================
%
function LocalDeleteBlock

fig = get_param(gcbh,'UserData');
if ishghandle(fig, 'figure'),
  delete(fig);
  set_param(gcbh,'UserData',-1)
end

% end LocalDeleteBlock

%
%=============================================================================
% LocalDeleteFigure
% The animation figure is being deleted, set the S-function UserData to -1.
%=============================================================================
%
function LocalDeleteFigure

ud = get(gcbf,'UserData');
set_param(ud.Block,'UserData',-1);
  
% end LocalDeleteFigure

%
%=============================================================================
% LocalClose
% The callback function for the animation window close button.  Delete
% the animation figure window.
%=============================================================================
%
function LocalClose

delete(gcbf)

% end LocalClose

%
%=============================================================================
% LocalplanarBicopterSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
%=============================================================================
%
function LocalplanarBicopterSets(time,ud,u)

D         = 2;
W         = 0.5;
R         = 1;

H         = u(3);
Z         = u(4);
Theta     = u(5);

DcosT    = D*cos(Theta);
DsinT    = D*sin(Theta);
RcosT    = R*cos(Theta);
RsinT    = R*sin(Theta);
WcosT    = W*cos(Theta);
WsinT    = W*sin(Theta);

set(ud.QuadBody,...
  'XData',[Z-DcosT Z+DcosT; Z-DcosT+WsinT Z+DcosT+WsinT],...
  'YData',[H-DsinT H+DsinT; H-DsinT-WcosT H+DsinT-WcosT]);
set(ud.RotorLeft,...
  'XData',[Z-DcosT-RcosT Z-DcosT+RcosT; Z-DcosT-RcosT-WsinT Z-DcosT+RcosT-WsinT],...
  'YData',[H-DsinT-RsinT H-DsinT+RsinT; H-DsinT-RsinT+WcosT H-DsinT+RsinT+WcosT]);
set(ud.RotorRight,...
  'XData',[Z+DcosT-RcosT Z+DcosT+RcosT; Z+DcosT-RcosT-WsinT Z+DcosT+RcosT-WsinT],...
  'YData',[H+DsinT-RsinT H+DsinT+RsinT; H+DsinT-RsinT+WcosT H+DsinT+RsinT+WcosT]);
set(ud.TimeField,...
  'String',num2str(time));
set(ud.RefMark,...
  'XData',u(2)+[-0.5 0 0.5],...
  'YData',u(1)+[0 1 0]);

% Force plot to be drawn
pause(0)
drawnow

% end LocalplanarBicopterSets

%
%=============================================================================
% LocalPendInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
%
function LocalPendInit()

%
% The name of the reference is derived from the name of the
% subsystem block that owns the pendulum animation S-function block.
% This subsystem is the current system and is assumed to be the same
% layer at which the reference block resides.
%
sys = get_param(gcs,'Parent');

TimeClock = 0;
H_ref     = 0;
Z         = 0;
H         = 0;
Theta     = 0;

D         = 2;
W         = 0.5;
R         = 1;

DcosT    = D*cos(Theta);
DsinT    = D*sin(Theta);
RcosT    = R*cos(Theta);
RsinT    = R*sin(Theta);
WcosT    = W*cos(Theta);
WsinT    = W*sin(Theta);

%
% The animation figure handle is stored in the pendulum block's UserData.
% If it exists, initialize the reference mark, time, cart, and pendulum
% positions/strings/etc.
%
Fig = get_param(gcbh,'UserData');
if ishghandle(Fig ,'figure')
  FigUD = get(Fig,'UserData');
  set(FigUD.RefMark,...
      'XData',[-0.5 0 0.5],...
      'YData',H_ref + [0 1 0]);
  set(FigUD.TimeField,...
      'String',num2str(TimeClock));
  set(FigUD.QuadBody,...
      'XData',[Z-DcosT Z+DcosT; Z-DcosT+WsinT Z+DcosT+WsinT],...
      'YData',[H-DsinT H+DsinT; H-DsinT-WcosT H+DsinT-WcosT]);
  set(FigUD.RotorLeft,...
      'XData',[Z-DcosT-RcosT Z-DcosT+RcosT; Z-DcosT-RcosT-WsinT Z-DcosT+RcosT-WsinT],...
      'YData',[H-DsinT-RsinT H-DsinT+RsinT; H-DsinT-RsinT+WcosT H-DsinT+RsinT+WcosT]);
  set(FigUD.RotorRight,...
      'XData',[Z+DcosT-RcosT Z+DcosT+RcosT; Z+DcosT-RcosT-WsinT Z+DcosT+RcosT-WsinT],...
      'YData',[H+DsinT-RsinT H+DsinT+RsinT; H+DsinT-RsinT+WcosT H+DsinT+RsinT+WcosT]);
  %
  % bring it to the front
  %
  figure(Fig);
  return
end

%
% the animation figure doesn't exist, create a new one and store its
% handle in the animation block's UserData
%
FigureName = 'Pendulum Visualization';
Fig = figure(...
  'Units',           'pixel',...
  'Position',        [100 100 500 300],...
  'Name',            FigureName,...
  'NumberTitle',     'off',...
  'IntegerHandle',   'off',...
  'HandleVisibility','callback',...
  'Resize',          'off',...
  'DeleteFcn',       'planarBicopterAnimation([],[],[],''DeleteFigure'')',...
  'CloseRequestFcn', 'planarBicopterAnimation([],[],[],''Close'');');
AxesH = axes(...
  'Parent',  Fig,...
  'Units',   'pixel',...
  'Position',[50 50 400 200],...
  'CLim',    [1 64], ...
  'Xlim',    [-12 12],...
  'Ylim',    [-2 20],...
  'Visible', 'off');
QuadBody = surface(...
  'Parent',   AxesH,...
  'XData',    [Z-DcosT Z+DcosT; Z-DcosT+WsinT Z+DcosT+WsinT],...
  'YData',    [H-DsinT H+DsinT; H-DsinT-WcosT H+DsinT-WcosT],...
  'ZData',    zeros(2),...
  'CData',    11*ones(2));
RotorLeft = surface(...
  'Parent',   AxesH,...
  'XData',    [Z-DcosT-RcosT Z-DcosT+RcosT; Z-DcosT-RcosT-WsinT Z-DcosT+RcosT-WsinT],...
  'YData',    [H-DsinT-RsinT H-DsinT+RsinT; H-DsinT-RsinT+WcosT H-DsinT+RsinT+WcosT],...
  'ZData',    zeros(2),...
  'CData',    11*ones(2));
RotorRight = surface(...
  'Parent',   AxesH,...
  'XData',    [Z+DcosT-RcosT Z+DcosT+RcosT; Z+DcosT-RcosT-WsinT Z+DcosT+RcosT-WsinT],...
  'YData',    [H+DsinT-RsinT H+DsinT+RsinT; H+DsinT-RsinT+WcosT H+DsinT+RsinT+WcosT],...
  'ZData',    zeros(2),...
  'CData',    11*ones(2));
RefMark = patch(...
  'Parent',   AxesH,...
  'XData',    [-0.5 0 0.5],...
  'YData',    H_ref + [0 1 0],...
  'CData',    22,...
  'FaceColor','flat');
uicontrol(...
  'Parent',  Fig,...
  'Style',   'text',...
  'Units',   'pixel',...
  'Position',[0 0 500 50]);
uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel',...
  'Position',           [150 0 100 25], ...
  'HorizontalAlignment','right',...
  'String',             'Time: ');
TimeField = uicontrol(...
  'Parent',             Fig,...
  'Style',              'text',...
  'Units',              'pixel', ...
  'Position',           [250 0 100 25],...
  'HorizontalAlignment','left',...
  'String',             num2str(TimeClock));
uicontrol(...
  'Parent',  Fig,...
  'Style',   'pushbutton',...
  'Position',[415 15 70 20],...
  'String',  'Close', ...
  'Callback','planarBicopterAnimation([],[],[],''Close'');');

%
% all the HG objects are created, store them into the Figure's UserData
%
FigUD.QuadBody     = QuadBody;
FigUD.RotorLeft    = RotorLeft;
FigUD.RotorRight   = RotorRight;
FigUD.TimeField    = TimeField;
FigUD.RefMark      = RefMark;
FigUD.Block        = get_param(gcbh,'Handle');
set(Fig,'UserData',FigUD);

drawnow

%
% store the figure handle in the animation block's UserData
%
set_param(gcbh,'UserData',Fig);

% end LocalPendInit
