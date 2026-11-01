function [qu] = tppsm(G, Ta, Tm, eta_0, a1, a2)

dT = Tm - Ta;
qu = max(0, eta_0*G - a1*dT - a2*dT^2);

% returns q, useful thermal power per square meter , aka W/m^2
end
