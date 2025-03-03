function [W0] = Sizing(Tendurance,NoCrew)
%origanl prelimanary sizing code by dylan refactored into a function of
%endurance time and number of crew.

% 2.0 Definition of Variables and Values
% 2.1 Fuel-Related Variables
%Endurance time and fuel flow included in function input for ease of
%editing 
mdot=110;
fuelDensity = 0.7; % Density of aviation fuel [Kilograms per cubic meter]

% 2.2 Mass Variables
% All masses are measured in kilograms.
Wcrew=NoCrew*110;%4 passengers @ 110kg each.
Wpayload=40; % 2.2 Payload mass requirement
Wfuel=0; % 2.3 Fuel mass requirement, calculated in section 3.1
We=900; % 2.4 Helicopter empty mass
W0=1200; % 2.5 Estimated Maximum Take-Off Weight (MTOW) of helicopter
WfW0 = 0.275; % Estimated Mass Ratio
WeW0 = 0.55; % Estimated Mass Ratio

% 3.0 Calculations
% 3.1 Calculation of Fuel Mass Requirement
fuelVolume = mdot*Tendurance;
Wfuel = fuelVolume*fuelDensity;

% 3.2 Calculation of MTOW
W0 = (Wcrew + Wpayload)/(1-(WfW0)-(WeW0)); % MTOW [Kilograms]
% W0 = W0/1000; % MTOW [tons]
% The value of WeW0 is around 0.45-0.60 for civil or utility helicopters.

% 3.3 Will this provide enough fuel?
CalulatedFuelAmount = W0*WfW0;
end