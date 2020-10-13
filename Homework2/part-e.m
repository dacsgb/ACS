function SolveODEs()
    clf  %clear any existing plots

    global lin;

    tf = 20;
    x0 = [0;0.5];
    %0.01,0.1,0.5,2,2.2,5,10
    
    % First difference = 0.5 - Linear system over-estimates the displacemnt

    
    lin = 1;
    [t_lin,y_lin] = ode45(@deriv,[0,tf],x0); % derivative, time range, initial conditions
    
    lin = 0;
    [t_nonlin,y_nonlin] = ode45(@deriv,[0,tf],x0);
    
    figure(1)
    plot(t_lin,y_lin(:,1),'r',t_nonlin,y_nonlin(:,1),'b');
    title('Linear and Nonlinear model comparison - X(0) = [0,0.5]^T');
    xlabel('Time - [s]');
    ylabel('Y position - [m]');
    legend('Linear solution','Non-linear solution')
    pause 
    
    function XDOT = deriv(t,X)
    % System Parameters
    m = 30;     c1 = 0.5;       
    c2 = 1;     k = 1;
    global lin
    
    % Rename states
    x1 = X(1); x2 = X(2);
    
    % Initiate forcing function
    u = 0;
    
    % write the non-trivial equations using nice names
    if lin == 1
        x1dot = x2;
        x2dot = (-k/m)*x1 + (-c1/m)*x2 + (1/m)*u;
    end
    
    % write the non-trivial equations using nice names
    if lin == 0
        x1dot = x2;
        x2dot = (-k/m)*x1 + (-c1/m)*x2 + (-c2/m)*x2^3 + (1/m)*u;
    end
    
    XDOT = [x1dot; x2dot] ;  %return the derivative values