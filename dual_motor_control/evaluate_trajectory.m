function values = evaluate_trajectory( splines, t )

    j = @(t, t0, d0, j0)             d0.*(t-t0) + j0;
    a = @(t, t0, d0, j0, a0)         d0.*(t-t0).^2./2 + j0.*(t-t0) + a0;
    v = @(t, t0, d0, j0, a0, v0)     d0.*(t-t0).^3./6 + j0.*(t-t0).^2./2 + a0.*(t-t0) + v0;
    x = @(t, t0, d0, j0, a0, v0, x0) d0.*(t-t0).^4./24 + j0.*(t-t0).^3./6 + a0.*(t-t0).^2./2 + v0.*(t-t0) + x0;
            
    for ii = 1:length(splines)
        spline = splines(ii);
        if spline.times(1) <= t && t <= spline.times(2)
            
            t0 = spline.times(1);

            d0 = spline.IC(1);
            j0 = spline.IC(2);
            a0 = spline.IC(3);
            v0 = spline.IC(4);
            x0 = spline.IC(5);
            
            values = [d0,...
                      j(t, t0, d0, j0),...
                      a(t, t0, d0, j0, a0),...
                      v(t, t0, d0, j0, a0, v0),...
                      x(t, t0, d0, j0, a0, v0, x0)];
            break
        end
    end
end

