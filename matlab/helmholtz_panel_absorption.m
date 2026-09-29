%% HELMHOLTZ_PANEL_ABSORPTION
% Graded panel of narrow-neck Helmholtz resonators (36 cells, 150-250 Hz):
% transmission loss, absorption (normal incidence and statistical) and
% cavity dimensions for the 3D-printed design (OpenSCAD).
%
% Sections:
%   0. Global parameters
%   1. Narrow-neck resonator (neck side = d/sqrt(2)), reference cell at 175 Hz
%   2. Single-resonator TL
%   3. Graded panel: impedance and TL (locally reactive surface)
%   4. Absorption at normal incidence (Kundt tube)
%   5. Statistical absorption (Sabine, diffuse field)
%   6. Cavity dimensions for OpenSCAD
%
% Requirements: base MATLAB (no toolboxes).
% Author: Pepe - Undergraduate thesis (TFG), Universidad de Malaga.

clear; clc; close all;

%% 0. Global parameters
f0   = 175;              % Reference resonance frequency [Hz]
w0   = 2*pi*f0;          % [rad/s]
rho0 = 1.21;             % Air density [kg/m^3]
c    = 343;              % Speed of sound [m/s]
nu   = 1.5e-5;           % Kinematic viscosity of air [m^2/s]
Zc   = rho0*c;           % Characteristic impedance of air [Pa*s/m]

L    = 15e-3;            % Neck length [m]
d0   = 12e-3;            % Original neck side length [m]

Nceldas = 36;            % Number of cells in the panel

% Frequency sweep
f  = 20:0.5:500;         % [Hz]
w  = 2*pi*f;             % [rad/s]
Nf = numel(f);

%% 1. Narrow-neck design (d/sqrt(2)) - reference cell at 175 Hz
d_new    = d0/sqrt(2);            % Neck side length [m]
S_new    = d_new^2;               % Neck cross-section area [m^2]
Leff_new = L + 0.85*d_new;        % Effective neck length with end correction [m]

V_new  = (c^2*S_new)/(w0^2*Leff_new);                         % Reference cavity volume [m^3]
CA_new = V_new/(rho0*c^2);                                    % Acoustic compliance
MA_new = rho0*Leff_new/S_new;                                 % Acoustic mass
RA_new = (rho0/S_new)*sqrt(2*w0*nu)*(1 + L/d_new);            % Viscous resistance
Q_new  = (w0*MA_new)/RA_new;                                  % Quality factor
df_new = f0/Q_new;                                            % Half-power bandwidth [Hz]

fprintf('Narrow-neck design: d = %.3f mm, Q = %.1f, bandwidth = %.2f Hz\n', ...
    d_new*1e3, Q_new, df_new);

%% 2. Single-resonator TL (side branch in a 100 x 100 mm duct)
Zm    = RA_new + 1i*(w*MA_new - 1./(w*CA_new));   % Resonator acoustic impedance
Sduct = 0.01;                                     % Duct cross-section area [m^2]
Z0    = rho0*c/Sduct;                             % Duct characteristic impedance
TL    = 20*log10(abs((2*Zm + Z0)./(2*Zm)));

figure;
plot(f, TL);
xlabel('Frequency (Hz)'); ylabel('Transmission loss (dB)');
title(sprintf('Single-resonator TL (new design, d = %.3f mm)', d_new*1e3));
grid on;

%% 3. Graded panel of resonators
f0i = linspace(150, 250, Nceldas);     % Equispaced design frequencies [Hz]
w0i = 2*pi*f0i;
disp('Design frequencies [Hz]:');
disp(mat2str(round(f0i, 1)));

% Cavity volume of each cell (same neck, different volume)
Vi = (c^2*S_new) ./ (w0i.^2 * Leff_new);   % [m^3]
disp('Cavity volumes [cm^3]:');
disp(mat2str(round(Vi*1e6, 1)));

% Lumped parameters of each cell
RA_i = (rho0/S_new) * sqrt(2*w0i*nu) .* (1 + L/d_new);
MA_i = MA_new;                              % Same neck for all cells
CA_i = Vi / (rho0*c^2);

% Impedance of each cell over the frequency sweep
Zm_panel = zeros(Nceldas, Nf);
for i = 1:Nceldas
    Zm_panel(i,:) = RA_i(i) + 1i*(w*MA_i - 1./(w*CA_i(i)));
end

% Check: impedance of each cell at its own design frequency
for i = 1:Nceldas
    [~, idx] = min(abs(f - f0i(i)));
    fprintf('Cell %2d (f0 = %.1f Hz): Zm = %.2f + %.2fi\n', ...
        i, f0i(i), real(Zm_panel(i,idx)), imag(Zm_panel(i,idx)));
end

% Locally reactive surface: cells in parallel (admittances add)
Ym_panel = sum(1./Zm_panel, 1);
Zm_total = 1 ./ Ym_panel;                  % Total acoustic impedance [Pa*s/m^3]

% Specific (surface) impedance of the panel [Pa*s/m]
s_celda  = V_new^(1/3);                    % Cell footprint side: cube root of the 175 Hz reference volume [m]
A_panel  = Nceldas * s_celda^2;            % Total panel area [m^2]
Zs_panel = Zm_total * A_panel;

% Transmission loss (normal incidence)
TLpanel = 20*log10(abs(1 + Zs_panel./(2*Zc)));

figure('Name', sprintf('Graded panel TL (%d cells, narrow neck)', Nceldas));
plot(f, TLpanel, 'r', 'LineWidth', 1.5, 'DisplayName', 'Graded panel TL');
xlabel('Frequency (Hz)'); ylabel('Transmission loss (dB)');
title(sprintf('Graded panel transmission loss (%d cells)', Nceldas));
legend('show'); grid on;
ylim([0 max(TLpanel)+5]);

figure('Name', sprintf('Panel (%d cells) vs single cell', Nceldas));
plot(f, TL, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Single cell (175 Hz, narrow neck)');
hold on;
plot(f, TLpanel, 'r-', 'LineWidth', 2, ...
    'DisplayName', sprintf('Graded panel, %d cells (150-250 Hz)', Nceldas));
hold off;
xlabel('Frequency (Hz)'); ylabel('Transmission loss (dB)');
title(sprintf('Comparison: %d-cell panel vs single cell', Nceldas));
grid on; xlim([100 300]); legend('show');

%% 4. Absorption at normal incidence (Kundt tube)
R = (Zs_panel - Zc) ./ (Zs_panel + Zc);    % Reflection coefficient
alpha_normal = 1 - abs(R).^2;              % Absorption coefficient

figure('Name', sprintf('Normal-incidence absorption (%d cells)', Nceldas));
plot(f, alpha_normal, 'b', 'LineWidth', 1.5, 'DisplayName', '\alpha_n (normal incidence)');
xlabel('Frequency (Hz)'); ylabel('Absorption coefficient (\alpha_n)');
title(sprintf('Panel absorption (%d cells) - normal incidence', Nceldas));
grid on; legend('show', 'Location', 'southwest');
xlim([100 300]); ylim([0 1.1]);

%% 5. Statistical absorption (Sabine, diffuse field)
% alpha_s = 2 * int_0^{pi/2} alpha(theta) sin(theta) cos(theta) dtheta
theta = linspace(0, pi/2, 1000);           % Angle of incidence [rad]
alpha_sabine = zeros(1, Nf);

for kf = 1:Nf
    Zs_f = Zs_panel(kf);                                             % Surface impedance at frequency kf
    R_theta = (Zs_f.*cos(theta) - Zc) ./ (Zs_f.*cos(theta) + Zc);    % Angle-dependent reflection coefficient
    alpha_theta = 1 - abs(R_theta).^2;
    alpha_sabine(kf) = 2 * trapz(theta, alpha_theta .* sin(theta) .* cos(theta));
end

figure('Name', sprintf('Absorption: Kundt vs Sabine (%d cells)', Nceldas));
plot(f, alpha_normal, 'b-', 'LineWidth', 1.5, 'DisplayName', '\alpha_n (Kundt, normal incidence)');
hold on;
plot(f, alpha_sabine, 'r-', 'LineWidth', 2, 'DisplayName', '\alpha_s (Sabine, statistical)');
hold off;
xlabel('Frequency (Hz)'); ylabel('Absorption coefficient (\alpha)');
title(sprintf('Panel absorption (%d cells): normal vs statistical', Nceldas));
grid on; legend('show', 'Location', 'southwest');
xlim([100 300]); ylim([0 1.1]);

%% 6. Cavity dimensions for the 3D-printed design (OpenSCAD)
s_celda_mm   = s_celda * 1000;             % Cell inner side [mm]
Vi_mm3       = Vi * 1e9;                   % Cavity volumes [mm^3]
h_cavidad_mm = Vi_mm3 / (s_celda_mm^2);    % Cavity depth of each cell [mm]

fprintf('\n--- OPENSCAD DATA ---\n');
fprintf('Base inner side (s_celda): %.2f mm\n', s_celda_mm);
fprintf('Maximum cavity height (150 Hz): %.2f mm\n', max(h_cavidad_mm));
fprintf('Vector of %d cavity depths (mm):\n', Nceldas);
disp(mat2str(round(h_cavidad_mm, 2)));
