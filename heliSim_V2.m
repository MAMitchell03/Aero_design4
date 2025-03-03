clc;
clear;
close all;
% Helicopter and rotor parameters
R = 5; % Rotor radius (m)
omega = 35; % Rotor angular velocity (rad/s)
n = 10; % Number of blade sections
N = 4; % Number of blades

% Environmental and aircraft parameters
M = sizing(); % Mass of helicopter (kg)
W = 9.81 * M; % Weight (N)
rho = 1.225; % Air density (kg/m^3)
A = pi * R^2; % Rotor disk area
disc_loading = W/A;

% Blade geometry
c = 0.31 * ones(1, n); % Chord length (m), assumed constant across blade span
r = linspace(0, R, n); % Radial positions of blade sections
dr = [diff(r), diff(r(end-1:end))]; % Differential span elements

% Aerodynamic properties
Cl0 = 0.309; % Zero-lift coefficient
a = 6.291; % Lift curve slope (1/rad)
Cd = 0.006 * ones(1, n); % Drag coefficient, assumed constant

% Induced velocity at hover
v0 = sqrt(W / (2 * rho * A)) * ones(1, n); % Uniform hover inflow velocity

% Velocity components at each blade section
V = omega .* r; % Blade element velocity due to rotation
Vrel = sqrt(v0.^2 + V.^2); % Total relative velocity

% Inflow angle (phi) at each section
phi = atan(v0 ./ V); % Induced flow angle (radians)

% Blade twist distribution: -5° at root to 0° at tip, twist angle beta
beta = linspace(-5, 0, n) * (pi/180); % Convert to radians

% Compute integrals numerically as summations
I1 = sum(Vrel.^2 .* c .* dr); % ∫ Vrel^2 c dr
I2 = sum(Vrel.^2 .* c .* beta .* dr); % ∫ Vrel^2 c theta_t dr
I3 = sum(Vrel.^2 .* c .* phi .* dr); % ∫ Vrel^2 c phi dr
I4 = sum(Vrel.^2 .* c .* Cl0 .* dr); % ∫ Vrel^2 c Cl0 dr

% Solve for collective pitch algebraically
theta_0 = (W - (N/2) * rho * I4 - (N/2) * rho * a * I2 + (N/2) * rho * a * I3) / ((N/2) * rho * a * I1);

% Convert to degrees
theta_0 = theta_0 * (180/pi);

% --- Torque Calculation ---
dQ = 0.5 * rho .* (Vrel.^2) .* c .* dr .* Cd .* r;
Q = N * sum(dQ);

% --- Power Calculation Over Range of Vinf ---
Vinf_values = linspace(0, 67, 10); % 10 points from 0 to 70 m/s
Pi_values = zeros(size(Vinf_values));
P_profile_values = zeros(size(Vinf_values));
P_parasitic_values = zeros(size(Vinf_values));
P_total_values = zeros(size(Vinf_values));

for i = 1:length(Vinf_values)
    Vinf = Vinf_values(i);
    mu = Vinf / (omega * R);
    
    Tz = W;
    
    % Forward thrust from drag
    A_body = 1.9;
    Cd_body = 0.7;
    D_body = 0.5 * rho * (Vinf^2) * A_body * Cd_body;
    Tx = D_body;
    
    gamma = atan(Tx/Tz);
    T = sqrt(Tz^2 + Tx^2);
    
    CT = T / (0.5 * rho * (omega*R)^2 * A);
    Vx = Vinf * cos(gamma);
    Vz = Vinf * sin(gamma);
    
    mu_x = Vx / (omega * R);
    mu_z = Vz / (omega * R);
    
    lambda_i_final = solve_lambda_i(CT, mu_x, mu_z);
    
    lambda_i = lambda_i_final;
    vi = lambda_i * (omega * R);
    
    Pi_values(i) = T * vi;
    P_profile_values(i) = (1/8) * rho * N * 0.31 * 0.006 * R * (omega*R)^3;
    P_parasitic_values(i) = D_body * Vinf;
    P_total_values(i) = Pi_values(i) + P_profile_values(i) + P_parasitic_values(i);
end
Q_main_values = P_total_values / omega;


%Tail rotor power requirements
Rtr=1; % tail rotor radius (m)
omegatr=150;% tail rotor angular speed rads
xtr=7.8;% Tail rotor lever arm 
c_tr=0.124;
Cltr=1.9;
Cdtr=0.0068;
Ntr=2;


Atr=pi*(Rtr^2);
freq=omegatr/(2*pi);%rotational frequency 
Dtr=2*Rtr; % tail blade diameter
mutr=Vinf_values./(freq*Dtr); %advance ratio


%Tail rotor blade element
% Radial ordinate array (10 segments for integration, basic but a start)
h=0;
rtr = linspace(h, Rtr, 10);
vtr = (rtr .* omegatr); % Velocity at each blade element
% Blade element width (dr) for integration
drtr = diff(rtr);
drtr = [drtr, drtr(end)]; % Ensure correct length for integration
    
% Elemental lift and drag per unit span
dL = 0.5 * rho * (vtr .^ 2) .* c_tr .* Cltr .* drtr;  % Lift per element
dD = 0.5 * rho * (vtr .^ 2) .* c_tr .* Cdtr .* drtr;  % Drag per element
    
% Total lift and drag over all blade elements
Ltr_total = Ntr * sum(dL);
Dtr_total = Ntr * sum(dD);
    
% Torque from (Drag force * radius)
dQ = dD .* r;  % Elemental torque contribution
Q_total = N * sum(dQ); % Total torque
    
% Useful rotor parameters
V_tip = omegatr * Rtr; % Tip speed

Tail_thrust_values=Q_main_values./xtr; 
Tail_power_values=(Tail_thrust_values.^(3/2))/sqrt(2*rho*Atr);

P_total_values=P_total_values+Tail_power_values+10000; %the 10K is a estimate of avionics and other systems power

% Display Tail rotor results
fprintf('\n---- Tail ROTOR STATS! ----\n');
fprintf('Tip Speed: %.2f m/s\n', V_tip);
fprintf('Total Lift: %.2f N\n', Ltr_total);
fprintf('Total Drag: %.2f N\n', Dtr_total);
fprintf('Total Torque: %.2f Nm\n', Q_total);

% Plot results
figure;
hold on;
plot(Vinf_values, Pi_values, '-o', 'DisplayName', 'Induced Power');
plot(Vinf_values, P_profile_values, '-s', 'DisplayName', 'Profile Power');
plot(Vinf_values, P_parasitic_values, '-d', 'DisplayName', 'Parasitic Power');
plot(Vinf_values, P_total_values, '-x', 'DisplayName', 'Total Power');
plot(Vinf_values, Tail_power_values, '-k', 'DisplayName','Tail rotor power')
hold off;

grid on;
xlabel('Forward Speed V_{inf} (m/s)');
ylabel('Power (W)');
title('Power vs Forward Speed');
legend('show');



figure;
plot(Vinf_values, Q_main_values, '-o', 'DisplayName', 'Main Rotor Torque');
grid on;
xlabel('Forward Speed V_{inf} (m/s)');
ylabel('Main Rotor Torque (Nm)');
title('Main Rotor Torque vs Forward Speed');
legend('show');


disp(['Required power in hover is ', num2str(Pi_values(1) + P_profile_values(1)+Tail_power_values(1))]);
disp(['Collective Pitch Angle for hover: ', num2str(theta_0), ' degrees']);
