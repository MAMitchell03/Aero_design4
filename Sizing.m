function [W0]=sizing()
% 2.0 Definition of Variables and Values
% 2.1 Fuel-Related Variables
mdot = 110; % Average maximum consumption rate [Litres per hour]
Tendurance = 3.6; % Endurance time requirement [Hours]
fuelDensity = 0.715; % Density of aviation fuel [Kilograms per litre]

sfcImperial = 0.697; % [lb/hp·h] Rolls royce M250 CIS / C18A/B/C specific fuel consumption
sfc = sfcImperial*0.453592/0.757 %[kh/kW·h]

% 2.2 Mass Variables
% All masses are measured in kilograms.
Wcrew=340; % 2.1 Crew mass requirement
Wpayload=40; % 2.2 Payload mass requirement
Wfuel=0; % 2.3 Fuel mass requirement, calculated in section 3.1
We=900; % 2.4 Helicopter empty mass
W0=1200; % 2.5 Estimated Maximum Take-Off Weight (MTOW) of helicopter
WfW0 = 0.24; % Estimated Mass Ratio
WeW0 = 0.53; % Estimated Mass Ratio. This is typically 0.45-0.6.
Wd = 30; % Disposable weight/mass. This can be used if needed to accomodate excess crew, passenger, payload or fuel weight.

% 3.0 Calculations
% 3.1 Calculation of Fuel Mass Requirement
fuelVolume = mdot*Tendurance;
Wfuel = fuelVolume*fuelDensity;
FuelMassConsumptionRate = mdot * fuelDensity;

% 3.2 Calculation of MTOW
W0 = (Wcrew + Wpayload+Wd)/(1-WfW0-WeW0) % MTOW [Kilograms]
% W0 = W0/1000; % MTOW [tons]
% The value of WeW0 is around 0.45-0.60 for civil or utility helicopters.

% 3.3 Will this provide enough fuel?
CalculatedFuelAmount = W0*WfW0

% 4.0 Statistical Analysis of a Useful Range of Helicopter Masses
% List of helicopter models, each of their MTOWs in kilograms and the data source:
R44 = 1134; % Mackenzie's 'MTOW Estimate' Document
EC120 = 1715; % Mackenzie's 'MTOW Estimate' Document
G2 = 700; % Mackenzie's 'MTOW Estimate' Document
R66 = 1225; % Mackenzie's 'MTOW Estimate' Document
Bell505 = 2030; % Mackenzie's 'MTOW Estimate' Document
Md520N = 1520; % Mackenzie's 'MTOW Estimate' Document
AW109 = 2850; % Mackenzie's 'MTOW Estimate' Document
AS350 = 2250; % Mackenzie's 'MTOW Estimate' Document
GazelleSA341 = 1860; % Kai's 'List of Helicopters' Document
H135Juno = 2980; % Ben's 'List of Helicopters' Document
SchweizerS300 = 930; % Ben's 'List of Helicopters' Document
H145Jupiter = 3700; % Ben's 'List of Helicopters' Document
% Heli13 = ;
% Heli14 = ;
% Heli15 = ;

RangeOfMassStatistics = [R44 EC120 G2 R66 Bell505 Md520N AW109 AS350 GazelleSA341 H135Juno SchweizerS300 H145Jupiter];
AvgMass = sum(RangeOfMassStatistics)/12;
end
