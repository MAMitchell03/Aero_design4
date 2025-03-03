function lambda_i_final = solve_lambda_i(CT, mu_x, mu_z)
    % General Newton-Raphson solver for induced inflow ratio (lambda_i)
    % Inputs:
    %   CT - Thrust coefficient
    %   mu_x - Advance ratio in x direction
    %   mu_z - Advance ratio in z direction
    % Output:
    %   lambda_i_final - Computed induced inflow ratio

    max_iter = 1000; % Safety limit on iterations
    tol = 1e-6; % Convergence tolerance
    lambda_i = 0.5 * sqrt(CT); % Initial guess

    for iter = 1:max_iter
        % Compute function value f(lambda_i)
        fx = lambda_i - (CT / 4) * (1 / sqrt(mu_x^2 + (mu_z + lambda_i)^2));
        
        % Compute derivative f'(lambda_i)
        dfx = 1 + (CT / 4) * ((mu_z + lambda_i) / ((mu_x^2 + (mu_z + lambda_i)^2)^(3/2)));

        % Check if derivative is too small to avoid division error
        if abs(dfx) < 1e-8
            warning('Derivative near zero, stopping iteration');
            lambda_i_final = lambda_i; % Ensure a valid output
            return;
        end

        % Newton-Raphson update
        lambda_i_new = lambda_i - fx / dfx;

        % Check for convergence
        if abs(lambda_i_new - lambda_i) < tol
            lambda_i_final = lambda_i_new; % Ensure correct return value
            return;
        end

        % Update for next iteration
        lambda_i = lambda_i_new;
    end

    % If it doesn't converge, return the last computed value
    warning('Newton-Raphson did not converge within %d iterations', max_iter);
    lambda_i_final = lambda_i;
end
