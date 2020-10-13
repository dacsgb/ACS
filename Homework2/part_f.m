function SolveODEs()
    clf  %clear any existing plots

    global grado;

    tf = 20;
    x0 = [0;2];

    grado = 1;
    [t_lin,y_lin] = ode45(@deriv,[0,tf],x0); % derivative, time range, initial conditions
    
    grado = 2;
    [t_square,y_square] = ode45(@deriv,[0,tf],x0);

    grado = 3;
    [t_cube,y_cube] = ode45(@deriv,[0,tf],x0);
    
    figure(1)
    plot(t_lin,y_lin(:,1),'r',t_square,y_square(:,1),'b',t_cube,y_cube(:,1),'g');
    title('Linear and Nonlinear model comparison - X(0) = [0,10]^T');
    xlabel('Time - [s]');
    ylabel('Y position - [m]');
    legend('Linear dampener solution','Square dampener solution','Cube dampener solution')
    
    function XDOT = deriv(t,X)
    % System Parameters
    m = 30;     c1 = 0.5;       
    c2 = 1;     k = 1;
    global grado
    
    % Rename states
    x1 = X(1); x2 = X(2);
    
    % Initiate forcing function
    u = 0;
    
    % write the non-trivial equations using nice names
    if grado == 1
        x1dot = x2;
        x2dot = (-k/m)*x1 + (-c1/m)*x2 + (1/m)*u;
    end
    
    % write the non-trivial equations using nice names
    if grado == 2
        x1dot = x2;
        x2dot = (-k/m)*x1 + (-c1/m)*x2 + (-c2/m)*x2*abs(x2) + (1/m)*u;
    end

    if grado == 3
        x1dot = x2;
        x2dot = (-k/m)*x1 + (-c1/m)*x2 + (-c2/m)*x2^3 + (1/m)*u;
    end

    
    XDOT = [x1dot; x2dot] ;  %return the derivative values