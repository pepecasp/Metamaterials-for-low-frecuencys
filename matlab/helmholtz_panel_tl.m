%% HELMHOLTZ_PANEL_TL
% Transmission loss (TL) of Helmholtz-resonator-based acoustic metamaterials
% for low-frequency sound isolation (target band: 150-250 Hz).
%
% The script is organised in independent sections:
%   0. Global parameters
%   1. Single Helmholtz resonator (side branch in a duct)
%   2. Narrower-neck design (higher Q)
%   3. Pink-noise filtering with the single resonator
%   4. Periodic array of resonators in a duct (transfer-matrix method)
%   5. Graded panel of 16 resonators (150-250 Hz), locally reactive surface
%
% Model: lumped-element acoustic circuit (mass MA, compliance CA, resistance RA).
% Requirements: base MATLAB (no toolboxes).
%
% Author: Pepe - Undergraduate thesis (TFG), Universidad de Malaga.

clear; clc; close all;

%% 0. Global parameters
f0   = 175;              % Target resonance frequency [Hz]
w0   = 2*pi*f0;          % Angular resonance frequency [rad/s]
rho0 = 1.21;             % Air density [kg/m^3]
c    = 343;              % Speed of sound [m/s]
nu   = 1.5e-5;           % Kinematic viscosity of air [m^2/s]

% Neck geometry (square cross-section)
L    = 15e-3;            % Neck length [m]
d    = 12e-3;            % Neck side length [m]
S    = d^2;              % Neck cross-section area [m^2] (= 1.44e-4)

% Duct (100 x 100 mm)
Sduct = 0.01;            % Duct cross-section area [m^2]
Z0    = rho0*c/Sduct;    % Characteristic acoustic impedance of the duct [Pa*s/m^3]

% Frequency sweep (fine resolution needed because of the high Q)
f  = 20:0.5:500;         % [Hz]
w  = 2*pi*f;             % [rad/s]
Nf = numel(f);

%% 1. Single Helmholtz resonator
% Effective neck length with end correction (flanged/unflanged average: 0.85*d)
Leff = L + 0.85*d;

% Cavity volume from the target resonance frequency: f0 = (c/2pi)*sqrt(S/(V*Leff))
V = (c^2*S)/(w0^2*Leff);

CA = V/(rho0*c^2);       % Acoustic compliance [m^3/Pa]
MA = rho0*Leff/S;        % Acoustic mass [kg/m^4]
% Viscous (boundary-layer) resistance; dominates over radiation resistance at this frequency
RA = (rho0/S)*sqrt(2*w0*nu)*(1 + L/d);   % [Pa*s/m^3]

% Acoustic impedance of the resonator (series RLC)
Zm = RA + 1i*(w*MA - 1./(w*CA));

% Transmission loss of a side-branch resonator in the duct
TL = 20*log10(abs((2*Zm + Z0)./(2*Zm)));

figure('Name', 'Single resonator TL');
plot(f, TL, 'LineWidth', 1.2);
xlabel('Frequency (Hz)');
ylabel('Transmission loss (dB)');
title('Transmission loss of a single Helmholtz resonator');
grid on;

%% 2. Narrower neck design (d/sqrt(2)) to widen the bandwidth (lower Q)
d_new    = d/sqrt(2);
S_new    = d_new^2;
Leff_new = L + 0.85*d_new;

MA_new = rho0*Leff_new/S_new;
RA_new = (rho0/S_new)*sqrt(2*w0*nu)*(1 + L/d_new);
Q_new  = (w0*MA_new)/RA_new;   % Quality factor
df_new = f0/Q_new;             % Half-power bandwidth [Hz]

fprintf('Narrow-neck design: Q = %.1f, bandwidth = %.2f Hz\n', Q_new, df_new);

%% 3. Pink noise filtered by the single resonator
fs  = 4000;              % Sampling frequency [Hz]
dur = 2;                 % Duration [s]
Ns  = fs*dur;            % Number of samples

% Pink noise: white noise shaped with a 1/sqrt(f) amplitude filter in the frequency domain
white = randn(Ns, 1);
X = fft(white);
freqs_fft = (0:Ns-1)*(fs/Ns);
freqs_sym = min(freqs_fft, fs - freqs_fft);   % Symmetric frequency axis (keeps ifft real)
freqs_sym(1) = freqs_sym(2);                  % Avoid division by zero at DC
pink_noise = real(ifft(X .* (1./sqrt(freqs_sym(:)))));
pink_noise = pink_noise/max(abs(pink_noise)); % Normalise

% Spectrum before the resonator (one-sided)
Y_before   = fft(pink_noise);
mag_before = abs(Y_before(1:Ns/2))/Ns;
f_axis     = (0:Ns/2-1)*(fs/Ns);

% Apply the resonator attenuation
w_axis    = 2*pi*f_axis;
w_axis(1) = w_axis(2);                        % Avoid division by zero at DC
Zm_axis   = RA + 1i*(w_axis*MA - 1./(w_axis*CA));
TL_axis   = 20*log10(abs((2*Zm_axis + Z0)./(2*Zm_axis)));
atten_lin = 10.^(-TL_axis/20);                % Linear attenuation factor

Y_after   = Y_before(1:Ns/2).' .* atten_lin;
mag_after = abs(Y_after)/Ns;

% Spectra in dB (eps avoids log(0)) and light moving-average smoothing
dB_before_smooth = movmean(20*log10(mag_before + eps), 8);
dB_after_smooth  = movmean(20*log10(mag_after  + eps), 8);

% Figure A: linear magnitude
figure('Name', 'Spectral detail (linear magnitude)');
plot(f_axis, mag_before, 'Color', [0.6 0.6 0.6], 'DisplayName', 'Original (raw)');
hold on;
plot(f_axis, mag_after, 'r-', 'LineWidth', 1.2, 'DisplayName', 'After resonator');
hold off;
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Pink noise spectrum in detail (20-300 Hz)');
grid on; xlim([20 300]);
legend('Location', 'northeast');

% Figure B: dB with smoothing (recommended)
figure('Name', 'Spectral detail (dB)');
plot(f_axis, dB_before_smooth, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Original pink noise');
hold on;
plot(f_axis, dB_after_smooth, 'r-', 'LineWidth', 1.5, 'DisplayName', 'After resonator');
hold off;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Helmholtz resonator attenuation at 175 Hz (20-300 Hz)');
grid on; xlim([20 300]);
legend('Location', 'southwest');

%% 4. Periodic array of resonators in a duct (transfer-matrix method)
% Each unit cell = duct section of length D + side-branch resonator.
lambda0  = c/f0;
D_values = [0.10, lambda0/4, lambda0/2, lambda0];   % Spacing between resonators [m]
N_values = [1, 5, 10, 20];                          % Number of unit cells
colors   = {'b', 'g', 'm', 'r'};

k = w/c;                                            % Wavenumber [rad/m]
TL_results = zeros(numel(D_values), numel(N_values), Nf);

for d_idx = 1:numel(D_values)
    D = D_values(d_idx);
    for n_idx = 1:numel(N_values)
        N_cells = N_values(n_idx);
        for idx = 1:Nf
            kD = k(idx)*D;
            T_duct = [cos(kD),          1i*Z0*sin(kD);
                      1i*sin(kD)/Z0,    cos(kD)];
            T_res  = [1,           0;
                      1/Zm(idx),   1];
            T_total = (T_duct*T_res)^N_cells;

            TL_results(d_idx, n_idx, idx) = 20*log10(abs(0.5*( ...
                T_total(1,1) + T_total(1,2)/Z0 + T_total(2,1)*Z0 + T_total(2,2))));
        end
    end
end

% One figure per spacing D, comparing N
for d_idx = 1:numel(D_values)
    figure;
    hold on;
    for n_idx = 1:numel(N_values)
        plot(f, squeeze(TL_results(d_idx, n_idx, :)), colors{n_idx}, ...
            'LineWidth', 1.5, 'DisplayName', sprintf('N = %d', N_values(n_idx)));
    end
    hold off;
    xlabel('Frequency (Hz)');
    ylabel('Transmission loss (dB)');
    title(sprintf('Effect of N (D = %.2f m = %.2f\\lambda_0)', D_values(d_idx), D_values(d_idx)/lambda0));
    legend('show');
    grid on;
    % For large D, Bragg effects appear outside the narrow band, so widen the view
    if D_values(d_idx) < lambda0/2
        xlim([100 250]);
    else
        xlim([20 500]);
    end
end

%% 5. Graded panel of resonators (varying f0 between cells)
Nceldas = 16;                          % Number of cells
f0i     = linspace(150, 250, Nceldas); % Equispaced design frequencies [Hz]
w0i     = 2*pi*f0i;

disp('Design frequencies [Hz]:');
disp(mat2str(round(f0i, 1)));

% Cavity volume of each cell (same neck, different volume)
Vi = (c^2*S) ./ (w0i.^2 * Leff);       % [m^3]
disp('Cavity volumes [cm^3]:');
disp(mat2str(round(Vi*1e6, 1)));

% Lumped parameters of each cell
RA_i = (rho0/S) * sqrt(2*w0i*nu) .* (1 + L/d);   % 1x16
MA_i = MA;                                        % Same neck for all cells
CA_i = Vi / (rho0*c^2);                           % 1x16

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

% Locally reactive surface hypothesis: cells act in parallel (admittances add)
Ym_panel = sum(1./Zm_panel, 1);
Zm_total = 1 ./ Ym_panel;                  % Total acoustic impedance [Pa*s/m^3]

% Specific (surface) impedance of the panel [Pa*s/m]
s_celda  = 8.22e-2;                        % Cell side length [m]
A_panel  = Nceldas * s_celda^2;            % Total panel area [m^2]
Zs_panel = Zm_total * A_panel;

% Transmission loss (normal incidence)
Zc      = rho0*c;                          % Characteristic impedance of air
TLpanel = 20*log10(abs(1 + Zs_panel./(2*Zc)));

figure('Name', 'Graded panel TL');
plot(f, TLpanel, 'r', 'LineWidth', 1.5, 'DisplayName', 'Graded panel TL');
xlabel('Frequency (Hz)');
ylabel('Transmission loss (dB)');
title('Transmission loss of the graded panel');
legend('show');
grid on;
xlim([100 300]);
ylim([0 max(TLpanel)+5]);

% Comparison: graded panel vs single cell
figure('Name', 'Graded panel vs single cell');
plot(f, TL, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Single cell (175 Hz)');
hold on;
plot(f, TLpanel, 'r-', 'LineWidth', 2, 'DisplayName', 'Graded panel (150-250 Hz)');
hold off;
xlabel('Frequency (Hz)');
ylabel('Transmission loss (dB)');
title('Bandwidth comparison: graded panel vs single cell');
grid on;
xlim([100 300]);
legend('show');
