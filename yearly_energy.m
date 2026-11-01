function [E_yearly] = yearly_energy(qu, A)

E_yearly = 0;

for i = 1:8760 %the .csv file has 8760 rows
    E_yearly = E_yearly + qu(i) * A;
end

E_yearly = E_yearly/1000; %convert from Wh to kWh
end