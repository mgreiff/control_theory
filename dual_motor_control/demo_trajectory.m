% This scipt implements the compute_trajectory and evaluate_trajectory
% functions and demonstrates how constraints are set, displayes an optimal
% trajectory and a histogram of the execution time fo evaluating the spline
% object.

%% Specifications
limits = [15,5,2,2]; % Limits in [ddddx,dddx,ddx,dx]
t0 = 0;              % Initial time
r0 = 10;             % Starting position
rf = 15;             % Terminal position

%% Compute spline object
tic
splines = compute_trajectory(r0, rf, t0, limits);
disp(['Time required to compute the spline object: ', num2str(toc), ' [s]'])

tf = splines(end).times(2);
N = 10e3;
tt = linspace(t0,tf,N);
val = zeros(5, N);
execution = zeros(1, N);

%% Evaluate spline object
% Evaluates spline object at N equidistant timepoints on [t0, tf] as you 
% would in a the discrete control loop
for ii = 1:length(tt)
    tic
    t = tt(ii);
    res = evaluate_trajectory( splines, t );
    execution(ii) = toc;
    val(:,ii) = res';
end
disp(['Mean time required to evaluate the spline object: ', num2str(sum(execution)/N), ' [s]'])
%% Plot the complete trajectory in a single plot
if 1
    figure(2)
    hold on;
    for ii = 1:length(val(:,1))
        plot(tt, val(ii,:), colors(ii))
    end
    for ii = 1:length(val(:,1))-1
        plot(tt, limits(ii).*ones(1,length(tt)), [colors(ii),'--'])
        plot(tt, -limits(ii).*ones(1,length(tt)), [colors(ii),'--'])
    end
    hold off;
end

%% Plot splines and limits in subplots, as well as execution time histogram
if 1
    colors = ['b','r','g','m','k'];
    labels = {'Jerk derivative', 'Jerk', 'Acceleration', 'Velocity', 'Position'};
    figure(1);
    for ii = 1:length(val(:,1))
        subplot(2,3,ii);
        hold on;
        plot(tt, val(ii,:), colors(ii));
        if ii < length(val(:,1))
            plot(tt, limits(ii).*ones(1,length(tt)), [colors(ii),'--'])
            plot(tt, -limits(ii).*ones(1,length(tt)), [colors(ii),'--'])
            axis([tt(1) tt(end) -1.1*limits(ii) 1.1*limits(ii)]);
            ylabel(['x^{(', num2str(5 - ii),')}(t) [m/s^', num2str(5 - ii),']'])
        end
        title({[label{ii}, ' as a function'],'of time'})
        xlabel('Time [s]')
        ylabel('x(t) [m]')
        hold off;
    end
    subplot(2,3,6);
    histogram(execution,40,'Normalization','probability')
    title({'Histogram of the execution time','of the eval_trajectory() function'})
    xlabel('Time [s]')
    ylabel('Probability')
end