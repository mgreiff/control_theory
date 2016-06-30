function error_check( fset )
    if size(fset.R, 1) ~= size(fset.Cd, 1) || size(fset.R, 2) ~= size(fset.Cd, 1)
        disp('Error, the measurement noise covariance matrix R is poorly dimensioned')
    elseif size(fset.Q) ~= size(fset.Ad)
        disp('Error, the process noise covariance matrix Q is poorly dimensioned')
    elseif sum(real(eig(fset.Q)) < 0) ~= 0 || sum(real(eig(fset.R)) < 0) ~= 0
        disp('Error, Q and R both need to be positive definite, the filters may fail')
    else
        disp('All checks passed!')
    end
end

