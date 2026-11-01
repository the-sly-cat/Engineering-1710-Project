%% Clearing the Command Window

clear
clc
close all


%% Constants 

V_gas = 7e6;                                   % ft^3/year, Annual natural gas use
HV = 1037;                                     % BTU/ft^3, Natural gas heating value
eta_boiler = 0.8;                              % dimensionless, Boiler thermal efficiency
dsc = 0.66;                                    % dimensionless, Desired solar contribution
max_available_land = 3500;                     % m^2, Maximum available land
f = 0.4;                                       % dimensionless, Land utilization factor
orientation = 35;                              % degrees, Collector orientation
Tm = 60;                                       % degrees Celsius, Collector mean fluid temperature
dt = 1;                                        % hour, Hourly sampling interval
gas_price = 12;                                % dollars per 1000 ft2, Gas price for economic study


%% Reading Data

project_data_file = readmatrix("Lexington_solar_data2025.csv"); % importing the CSV into MATLAB.

Ta = project_data_file(:, 2);                  % the units of the second column are degrees Celsius, Ambient temperature
G = project_data_file(:, 3);                   % the units of the third column are W/m^2, Solar irradiance
cd = [0.78, 3.2, 0.015, 2.5 ;  0.76, 1.2, 0.008, 2]; % collector data

nrdays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]; % the lengths of the months of the year
months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]; % the names of the months of the year

ep = [450, 750; 0.01, 0.015];                  % economic parameters


%% Part A

Tmin = min(project_data_file(:, 2));           % reporting the minimum temperature
Tmax = max(project_data_file(:, 2));           % reporting the maximum temperature
Tmean = mean(project_data_file(:, 2));         % reporting the mean temperature
Gmax = max(project_data_file(:, 3));           % reporting the maximum irradiance
Irr = sum(project_data_file(:, 3)) / 1000;     % reporting the annual incident solar irradiation (divided by 1000 to convert to kWh/m^2)

fprintf('The minimum ambient temperature is %.2f degrees Celsius.\n\n', Tmin)
fprintf('The maximum ambient temperature is %.2f degrees Celsius.\n\n', Tmax)
fprintf('The mean ambient temperature is %.2f degrees Celsius.\n\n', Tmean)
fprintf('The maximum irradiance is %.1f Watts per meters squared.\n\n', Gmax)
fprintf('The annual incident solar irradiation is %.1f kilowatts hour per meters squared.\n\n', Irr)

% Calculating the useful *t*hermal *p*ower *p*er *s*quare *m*eter (tppsm) and useful thermal power for each of the two collector types

for i = 1:height(project_data_file)

    qu_plate(i) = tppsm(G(i), Ta(i), Tm, cd(1, 1), cd(1, 2), cd(1, 3)); % W/m^2, Calculating useful thermal power per square meter of aperture area for glazed flat-plate collectors at every data point
    qu_tube(i) = tppsm(G(i), Ta(i), Tm, cd(2, 1), cd(2, 2), cd(2, 3));  % W/m^2, Calculating useful thermal power per square meter of aperture area for evacuated-tube collectors at every data point
    
    Q_plate(i) = qu_plate(i) * cd(1, 4);       % W, Calculating useful thermal power for glazed flat-plate collector installation
    Q_tube(i) = qu_tube(i) * cd(2, 4);         % W, Calculating useful thermal power for evacuated-tube collector installation
end

% Calculating the annual energy per square meter (initializing them to 0 before a for loop)

e_tube = 0;
e_plate = 0;

for i = 1:height(project_data_file)
    e_plate = e_plate + qu_plate(i) * dt;
    e_tube = e_tube + qu_tube(i) * dt;
end

% Dividing by 1000 to convert from Wh/m^2 to kWh/m^2

e_plate = e_plate / 1000;
e_tube = e_tube / 1000;

fprintf('The annual thermal energy produced per square meter is \n%.2f kilowatts hour per meter squared for glazed flat-plate collectors \nand %.2f kilowatts hour per meter squared for evacuated tube collectors.\n\n', e_plate, e_tube)

% Plotting useful thermal power per square meter for the three chosen time
% intervals

% the index of the first hour of January 13 is 12 * 24 + 1
% the index of the last hour of January 19 is 19 * 24

hour = 0:167; % since we will name the x column 'Hours passed since <start date for the measurements>' so the first data point is 0 hours after start

subplot(3, 1, 1);
hold on
plot(hour, qu_plate((12 * 24 + 1):(19 * 24)))
plot(hour, qu_tube((12 * 24 + 1):(19 * 24)))
xlabel('Hours passed since 2025-01-13 - 00:00')
legend('qu_{plate}','qu_{tube}')

% the index of the first hour of April 14 is 103 * 24 + 1
% the index of the last hour of April 20 is 110 * 24 

subplot(3, 1, 2);
hold on
plot(hour, qu_plate((103 * 24 + 1):(110 * 24)))
plot(hour, qu_tube((103 * 24 + 1):(110 * 24)))
xlabel('Hours passed since 2025-04-14 - 00:00')
ylabel('Useful thermal power per square meter of aperture area (W/m^2)') % only y-labeling here for display reasons
legend('qu_{plate}','qu_{tube}')

% the index of the first hour of July 14 is 194 * 24 + 1
% the index of the last hour of July 20 is 201 * 24

subplot(3, 1, 3);
hold on
plot(hour, qu_plate((194 * 24 + 1):(201 * 24)))
plot(hour, qu_tube((194 * 24 + 1):(201 * 24)))
xlabel('Hours passed since 2025-07-14 - 00:00')
legend('qu_{plate}','qu_{tube}')

% Plotting the monthly energy production for both types of collectors in a bar chart

% initializing the values

days_passed = 0; % days passed since the start of the year (will increase in the for loop)
E_plate_monthly = zeros(1, 12);                % kWh, monthly energy production for the plate collectors
E_tube_monthly = zeros(1, 12);                 % kWh, monthly energy production for the tube collectors

for i = 1:length(nrdays)
    for j = days_passed * 24 + 1:(days_passed + nrdays(i)) * 24
        E_plate_monthly(i) = E_plate_monthly(i) + Q_plate(j) * dt;
        E_tube_monthly(i) = E_tube_monthly(i) + Q_tube(j) * dt;
    end
    days_passed = days_passed + nrdays(i);
end

% converting energies from Wh to kWh

E_plate_monthly = E_plate_monthly / 1000;
E_tube_monthly = E_tube_monthly / 1000;

% organizing the energies for both types of collectors in a matrix so we can plot them on the same bar graph

E_monthly = [E_plate_monthly; E_tube_monthly];

figure
hold on
bar(months, E_monthly)
xlabel('Month')
ylabel('Monthly Energy Production (kWh)')
title('Energy Production for Collectors')
legend('Glazed flat-plate', 'Evacuated tube')


%% Part B

E_gas = V_gas * HV;                            % BTU/year, chemical energy contained in the gas
E_boiler_useful = eta_boiler * E_gas;          % BTU/year, useful boiler heat
E_target = dsc * E_boiler_useful;              % BTU/year, annual solar thermal production

% changing unit of E target
E_target = E_target / 3412.14;                 % kWh/year

fprintf('The target energy is %.2f kilowatt hours per year.\n\n', E_target)

% Aperture area needed to meet the annual target (m^2)

A_required_plate = E_target / e_plate;
A_required_tube = E_target / e_tube;

% Number of required units to meet the annual target

N_required_plate = ceil(A_required_plate / cd(1, 4));
N_required_tube = ceil(A_required_tube / cd(2, 4));

fprintf('The number of units required to reach the target energy is \n%.d for glazed flat-plate collectors and \n%.d for evacuated tube collectors.\n\n', N_required_plate, N_required_tube)

% Area occupied by the collectors themselves (m^2)

A_installed_plate = N_required_plate * cd(1, 4);
A_installed_tube = N_required_tube * cd(2, 4);

fprintf('The installed aperture area is \n%.d meters squared for glazed flat-plate collectors and \n%.d meters squared for evacuated tube collectors.\n\n', A_installed_plate, A_installed_tube)

% Total land use (m^2) assuming land utilization factor is f = 0.40 (dimensionless) 

A_land_required_plate = A_installed_plate/f;
A_land_required_tube = A_installed_tube/f;

fprintf('The estimated total land required is \n%.d meters squared for glazed flat-plate collectors and \n%.d meters squared for evacuated tube collectors.\n\n', A_land_required_plate, A_land_required_tube)

% Verifying that the energy requirements are met

E_predicted_plate = e_plate * A_installed_plate;
E_predicted_tube = e_tube * A_installed_tube;

fprintf('The predicted thermal energy is \n%.2f kilowatts hour for glazed flat-plate collectors and \n%.2f kilowatts hour for evacuated tube collectors.\n\n', E_predicted_plate, E_predicted_tube)

% Verifying if the designs meet the 3500 m^2 land limit

if(A_land_required_plate <= max_available_land)
    fprintf('The glazed flat-plate collectors meet the land requirement.\n\n')
else
    fprintf('The glazed flat-plate collectors do not meet the land requirement.\n\n')
end

if(A_land_required_tube <= max_available_land)
    fprintf('The evacuated tube collectors meet the land requirement.\n\n')
else
    fprintf('The evacuated tube collectors do not meet the land requirement.\n\n')
end


%% Part C

% Cost of installment (dollars)

C_install_plate = A_installed_plate * ep(1, 1);
C_install_tube = A_installed_tube * ep(1, 2);

fprintf('The installed capital cost is \n%.d dollars for glazed flat-plate collectors and \n%.d dollars for evacuated tube collectors.\n\n', C_install_plate, C_install_tube)

% Annual cost of maintenance (dollars/year)

C_maintenance_annual_plate = C_install_plate * ep(2, 1);
C_maintenance_annual_tube = C_install_tube * ep(2, 2);

fprintf('The annual maintenance cost is \n%.d dollars for glazed flat-plate collectors and \n%.d dollars for evacuated tube collectors.\n\n', C_maintenance_annual_plate, C_maintenance_annual_tube)

% Annual gas displacement (ft^3/year)

Gas_displaced_plate = min(E_target, sum(E_plate_monthly) * N_required_plate) * 3412.14 / (eta_boiler * HV);
Gas_displaced_tube = min(E_target, sum(E_tube_monthly) * N_required_tube) * 3412.14 / (eta_boiler * HV);

fprintf('The displaced gas volume is \n%.d feet cubed for glazed flat-plate collectors and \n%.d feet cubed for evacuated tube collectors.\n\n', Gas_displaced_plate, Gas_displaced_tube)

% Gross fuel savings (dollars/year)

Gross_fuel_savings_plate = (Gas_displaced_plate / 1000) * 12;
Gross_fuel_savings_tube = (Gas_displaced_tube / 1000) * 12;

fprintf('The gross fuel savings are \n%.d dollars for glazed flat-plate collectors and \n%.d dollars for evacuated tube collectors.\n\n', Gross_fuel_savings_plate, Gross_fuel_savings_tube)

% Net annual savings (dollars/year)

Net_annual_savings_plate = Gross_fuel_savings_plate - C_maintenance_annual_plate;
Net_annual_savings_tube = Gross_fuel_savings_tube - C_maintenance_annual_tube;

fprintf('The net annual savings are %.d dollars for glazed flat-plate collectors and %.d dollars for evacuated tube collectors.\n\n', Net_annual_savings_plate, Net_annual_savings_tube)

% Simple payback (years)

Simple_payback_plate = C_install_plate / Net_annual_savings_plate;
Simple_payback_tube = C_install_tube / Net_annual_savings_tube;

fprintf('The simple payback period is %.2f years for glazed flat-plate collectors and %.2f years for evacuated tube collectors.\n\n', Simple_payback_plate, Simple_payback_tube)


%% Part D

Tm_new = 40:10:80;                             % values for varying the mean fluid temperature

% Calculating the yearly energy for different mean fluid temperatures

for j = 1:5
    for i = 1:height(project_data_file)
        qu_plate(i) = tppsm(G(i), Ta(i), Tm_new(j), cd(1, 1), cd(1, 2), cd(1, 3));
        qu_tube(i) = tppsm(G(i), Ta(i), Tm_new(j), cd(2, 1), cd(2, 2), cd(2, 3));
    end
    E_yearly(1, j) = yearly_energy(qu_plate, cd(1, 4));
    E_yearly(2, j) = yearly_energy(qu_tube, cd(2, 4));
end

% Plotting the obtained values for both collectors on the same graph

figure
hold on
plot(Tm_new, E_yearly(1, :))
plot(Tm_new, E_yearly(2, :))
xlabel('Mean fluid temperature (^ \circC)')
ylabel('Yearly energy output (kWh)')
legend('Glazed flat-plate', 'Evacuated tube')

dsc_new = [.5, .66, .8, .9, 1];                 % values for varying the desired solar contribution

% Calculating the installed area for different desired solar contributions

for i = 1:5
    [A(1, i), A(2, i)] = installed_area_calc(E_boiler_useful, dsc_new(i), cd, e_plate, e_tube)
end

% Plotting the obtained values for both collectors on the same graph

figure
hold on
plot(dsc_new, A(1, :))
plot(dsc_new, A(2, :))
xlabel('Desired solar contribution (dimensionless)')
ylabel('Necessary installation area (m^2)')
legend('Glazed flat-plate', 'Evacuated tube')