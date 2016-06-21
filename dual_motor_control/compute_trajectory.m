function [ splines ] = compute_trajectory(r0, rf, t0, limits);
%% Returns a set of polynomial coefficients and times for computing the
%  optimal trajectory for a refernce step starting with \mathbf{x} = 0

splines = [];

dlim = limits(1);
jlim = limits(2);
alim = limits(3);
vlim = limits(4);
xlim = rf-r0;

j0 = 0;
a0 = 0;
v0 = 0;
x0 = 0;

td = 0;
tj = 0;
ta = 0;
tv = 0;

%% Compute td
breakTimes = [(abs(xlim)/(8*dlim)).^(1/4);
              (abs(vlim)/(2*dlim)).^(1/3);
              (abs(alim)/(dlim)).^(1/2);
              (abs(jlim)/(dlim))];

[td, index] = min(breakTimes);

dvalues = sign(xlim)*dlim.*[1,-1,-1,1,-1,1,1,-1];
intervalTimes = td.*ones(1,8);

%% Compute tj
tjRoots = roots([1, 5*td, 8*td.^2, 4*td.^3-xlim/(2*dlim*td)]);
tj = max(tjRoots(imag(tjRoots) == 0));

% Check if/when a is violated and adjust tj
tja = ((alim/2) - dlim*td.^2/2)*2/jlim;
if tja < tj
    tj = tja;
end

% Check if/when v is violated and adjust tj
%         v1 = dlim*td.^3/6;
%         a1 = dlim*td.^2/2;
%         v2 = jlim*tj.^2/2 + a1*tj + v1;
%         a2 = a1 + jlim*tj;
%         v3 = -dlim*td.^3/6+jlim*td.^2/2 + a2*td + v2;
%         disp([v1,v2,v3])
%         disp([a1,a2])
v3 = 2*(-dlim*td.^3/6+jlim*td.^2/2 + ...
     (dlim*td.^2/2 + jlim*tj)*td + ...
     jlim*tj.^2/2 + (dlim*td.^2/2)*tj + dlim*td.^3/6);

tjvRoots = roots([jlim/2,dlim*td.^2/2+jlim*td,...
                  dlim*td.^3/6+dlim*td.^3/2-dlim*td.^3/6+...
                  jlim*td.^2/2-vlim/2]);
tjv = max(tjvRoots(imag(tjvRoots) == 0));
if tjv < tj
    tj = tjv;
end

%% Compute ta
taRoots = roots([td.^2+td*tj,...
                 6*td.^3+9*td.^2*tj+3*td*tj.^2,...
                 8*td.^4+16*td.^3*tj+10*td.^2*tj.^2+2*td*tj.^3-xlim/dlim]);
ta = max(taRoots(imag(taRoots) == 0));

% Check if/when v is violated and adjust ta
 v1 = dlim*td.^3/6;
 a1 = dlim*td.^2/2;
 v2 = jlim*tj.^2/2 + a1*tj + v1;
 a2 = a1 + jlim*tj;
 v3 = -dlim*td.^3/6+jlim*td.^2/2 + a2*td + v2;
 a3 = -dlim*td.^2/2+jlim*td + a2;
 v4 = 2*((a3*ta)/2 + v3);

 tav = 2*(vlim/2 - v3)/(a3);
 disp(tav)
 if tav < ta
     ta = tav;
 end

dvalues = sign(xlim)*dlim.*[1,0,-1,0,-1,0,1,0,-1,0,1,0,1,0,-1];
intervalTimes = [td,tj,td,ta,td,tj,td,tv,td,tj,td,ta,td,tj,td];

for ii = 1:length(intervalTimes)
    d0 = dvalues(ii);

    spline.IC = [d0, j0, a0, v0, x0];
    
    if ii == 1
        t0 = 0;
    else
        t0 = sum(intervalTimes(1:ii-1));
    end
    tf = sum(intervalTimes(1:ii));
    
    spline.times = [t0, tf];
    
    j = @(t) d0.*(t-t0) + j0;
    a = @(t) d0.*(t-t0).^2./2 + j0.*(t-t0) + a0;
    v = @(t) d0.*(t-t0).^3./6 + j0.*(t-t0).^2./2 + a0.*(t-t0) + v0;
    x = @(t) d0.*(t-t0).^4./24 + j0.*(t-t0).^3./6 + a0.*(t-t0).^2./2 + v0.*(t-t0) + x0;
    
    j0 = j(tf);
    a0 = a(tf);
    v0 = v(tf);
    x0 = x(tf);
    
    spline.IC(5) = spline.IC(5) + r0;
    
    splines = [splines spline];
    
    if ii == 7
        xdist = (abs(rf-r0) - 2*abs(x0));
        if xdist > 0
            % Adds spline corresponding to tv ~= 0
            tv = xdist/v0;
            intervalTimes(8) = tv;
        end
    end
end

