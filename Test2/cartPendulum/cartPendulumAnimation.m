function cartPendulumAnimation(u)

    % process inputs to function
    z        = u(1);
    theta    = u(2);
    zdot     = u(3);
    thetadot = u(4);
    t        = u(5);
    
    % drawing parameters
    L = 1;
    gap = 0.01;
    width = 1.0;
    height = 0.1;
    R=0.1;
    
    % define persistent variables 
    persistent base_handle
    persistent rod_handle
    persistent mass_handle
    
    % first time function is called, initialize plot and persistent vars
    if isempty(rod_handle) || ~isvalid(rod_handle)...
            || isempty(base_handle) || ~isvalid(base_handle)...
            || isempty(mass_handle) || ~isvalid(mass_handle)
        figure, clf
        track_width=2;
        plot([-track_width,track_width],[0,0],'k'); % plot track
        hold on
        base_handle = drawBase(z, width, height, gap, []);
        rod_handle  = drawRod(z, theta, L, gap, height, []);
        mass_handle = drawMass(z, theta, L, gap, height, R, []);
        axis([-track_width, track_width, -L, 2*track_width-L]);
    
    % at every other time step, redraw base and rod
    else 
        drawBase(z, width, height, gap, base_handle);
        drawRod(z, theta, L, gap, height, rod_handle);
        drawMass(z, theta, L, gap, height, R, mass_handle);
    end
end

   
%
%=======================================================================
% drawBase
% draw the base of the pendulum
% return handle if 3rd argument is empty, otherwise use 3rd arg as handle
%=======================================================================
%
function new_handle = drawBase(z, width, height, gap, handle)
  
  pts = [...
      z-width/2, gap;...
      z+width/2, gap;...
      z+width/2, gap+height;...
      z-width/2, gap+height;...
      ];

  if isempty(handle)
    new_handle = fill(pts(:,1),pts(:,2),'b');
  else
    set(handle,'XData',pts(:,1));
    drawnow
  end
end
 
%
%=======================================================================
% drawRod
% draw the pendulum rod
% return handle if last argument is empty, otherwise use last arg as handle
%=======================================================================
%
function new_handle = drawRod(z, theta, L, gap, height, handle)
  
  X = [z, z+L*sin(theta)];
  Y = [gap+height, gap+height+L*cos(theta)];

  if isempty(handle)
    new_handle = plot(X, Y, 'k');
  else
    set(handle,'XData',X,'YData',Y);
    drawnow
  end
end

%
%=======================================================================
% drawMass
% draw the pendulum mass
% return handle if last argument is empty, otherwise use last arg as handle
%=======================================================================
%
function new_handle = drawMass(z, theta, L, gap, height, R, handle)

    th = linspace(-pi,pi);
    o = [z+L*sin(theta) gap+height+L*cos(theta)];
    X = o(1) + R*cos(th);
    Y = o(2) - R*sin(th);
    if isempty(handle)
        new_handle = fill(X, Y, 'r');
    else
        set(handle,'XData',X,'YData',Y);
        drawnow
    end
end
  