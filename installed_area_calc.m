function[A_installed_plate, A_installed_tube] = installed_area_calc(E_boiler_useful, desired_solar_contribution, cd, e_plate, e_tube)

E_target = desired_solar_contribution * E_boiler_useful;                    % BTU/year, annual solar thermal production
E_target = E_target / 3412.14;                                              % kWh/year, changing unit of E_target from BTU/year to kWh/year

A_installed_plate = ceil(E_target / (e_plate * cd(1,4))) * cd(1,4);
A_installed_tube = ceil(E_target / (e_tube * cd(2,4))) * cd(2,4);

% the function returns 2 values, corresponding to the necessary installation area for both types of collectors (so aperture only)
end