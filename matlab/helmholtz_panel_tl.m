%% 1. Inicializar variables y parámetros del resonador (ORIGINAL, d=12mm)
f0 = 175;
w0 = 2*pi*f0;
p0 = 1.21;
c = 343;
L = 15e-3;
Lado = 12e-3;
nu = 1.5e-5;

%% 1b. NUEVO diseño del panel: cuello estrechado (d/sqrt(2))
Lado_new = Lado/sqrt(2);
d_new = Lado_new;
S_new = d_new^2;
Leff_new = L + 0.85*d_new;

V_new = (c^2*S_new)/(w0^2*Leff_new);   % volumen de referencia a 175Hz con el NUEVO cuello
CA_new = V_new/(p0*c^2);
MA_new = (p0*Leff_new)/S_new;
RA_new = (p0/S_new)*sqrt(2*w0*nu)*(1 + L/d_new);
Q_new = (w0*MA_new)/RA_new;
df_new = f0/Q_new;

% 2. Barrido en frecuencia
f = 20:0.5:500;
w = 2*pi*f;
Nf = length(f);

% Impedancia y TL del resonador único (nuevo cuello, referencia 175Hz)
Zm = RA_new + 1i*(w*MA_new - 1./(w*CA_new));
Sduct = 0.01;
Z0 = (p0*c)/Sduct;
TL = 20*log10(abs((2*Zm + Z0)./(2*Zm)));

figure;
plot(f, TL);
xlabel('Frecuencia (Hz)'); ylabel('Pérdida de transmisión (dB)');
title('TL resonador único (nuevo diseño, d=8.485mm)');
grid on;

%% Panel de resonadores (25 celdas, cuello estrechado)
Nceldas = 36;
f0i = linspace(150, 250, Nceldas);
disp(mat2str(round(f0i, 1)))

w0i = 2*pi*f0i;
Vi = (c^2*S_new) ./ (w0i.^2 * Leff_new);
Vi_cm3 = Vi * 1e6;
disp(mat2str(round(Vi_cm3, 1)))

RA_i = (p0/S_new) * sqrt(2*w0i*nu) .* (1+L/d_new);
MA_i = MA_new;
CA_i = Vi / (p0*c^2);

Zm_panel = zeros(Nceldas, Nf);
for i = 1:Nceldas
    Zm_panel(i,:) = RA_i(i) + 1i*(w*MA_i - 1./(w*CA_i(i)));
end

for i = 1:Nceldas
    [~, idx] = min(abs(f - f0i(i)));
    fprintf('Celda %2d (f0=%.1f Hz): Zm = %.2f + %.2fi\n', i, f0i(i), real(Zm_panel(i,idx)), imag(Zm_panel(i,idx)));
end

% TL del panel (superficie localmente reactiva)
Ym_panel = zeros(1, Nf);
for i = 1:Nceldas
    Ym_panel = Ym_panel + 1./Zm_panel(i,:);
end
Zm_total = 1 ./ Ym_panel;

s_celda = V_new^(1/3);       % footprint de referencia del NUEVO diseño (celda a 175Hz)
A_panel = Nceldas * (s_celda^2);
Zs_panel = Zm_total * A_panel;

Zc = p0 * c;
TLpanel = 20*log10(abs(1 + Zs_panel./(2*Zc)));

figure('Name', sprintf('TL Panel Graduado (%d celdas, cuello estrecho)', Nceldas));
plot(f, TLpanel, 'r', 'LineWidth', 1.5, 'DisplayName', 'TL Panel Graduado');
xlabel('Frecuencia (Hz)'); ylabel('Pérdida de transmisión (dB)');
title(sprintf('Pérdida de Transmisión del Panel Graduado (%d celdas)', Nceldas));
legend('show'); grid on;
%xlim([100 300]);
ylim([0 max(TLpanel)+5]);

figure('Name', sprintf('Comparativa Panel %d celdas vs Celda Única', Nceldas));
plot(f, TL, 'b--', 'LineWidth', 1.2, 'DisplayName', 'Celda Única (175 Hz, nuevo cuello)');
hold on;
plot(f, TLpanel, 'r-', 'LineWidth', 2, 'DisplayName', sprintf('Panel Graduado %d celdas (150-250 Hz)', Nceldas));
hold off;
xlabel('Frecuencia (Hz)'); ylabel('Pérdida de transmisión (dB)');
title(sprintf('Comparativa: Panel %d celdas vs Celda Única', Nceldas));
grid on; xlim([100 300]); legend('show');

%% --- 3.3 ESTUDIO DE ABSORCIÓN: Incidencia Normal (Kundt) ---
% 1. Cálculo del coeficiente de reflexión (incidencia normal)
R = (Zs_panel - Zc) ./ (Zs_panel + Zc);

% 2. Cálculo del coeficiente de absorción (incidencia normal)
alpha_normal = 1 - abs(R).^2;

% 3. Representación gráfica 
figure('Name', sprintf('Absorción Incidencia Normal (%d celdas)', Nceldas));
plot(f, alpha_normal, 'b', 'LineWidth', 1.5, 'DisplayName', '\alpha_n (Incidencia Normal)');
xlabel('Frecuencia (Hz)'); 
ylabel('Coeficiente de Absorción (\alpha_n)');
title(sprintf('Absorción del Panel (%d celdas) - Incidencia Normal', Nceldas));
grid on; 
legend('show', 'Location', 'southwest');
xlim([100 300]);
ylim([0 1.1]);


%% --- 3.4 ESTUDIO DE ABSORCIÓN: Estadística (Sabine) ---
% Definimos el rango de angulos
theta = linspace(0, pi/2, 1000); % Vector de angulos entre 0 y 90
alpha_sabine = zeros(1, Nf);

% Calculo del coeficiente de cada frecuencia
for k = 1:Nf
    Zs_f = Zs_panel(k); % Impedancia superficial en la frec k
    R_theta = (Zs_f.*cos(theta) - Zc) ./ (Zs_f.*cos(theta) + Zc); % coef de reflexion
    alpha_theta = 1 - abs(R_theta).^2;
    % Integramos 
    alpha_sabine(k) = 2 * trapz(theta, alpha_theta .* sin(theta) .* cos(theta));
end
% 3. Representación gráfica comparativa (Kundt vs Sabine)
figure('Name', sprintf('Absorción: Kundt vs Sabine (%d celdas)', Nceldas));
plot(f, alpha_normal, 'b-', 'LineWidth', 1.5, 'DisplayName', '\alpha_n (Kundt - Inc. Normal)');
hold on;
plot(f, alpha_sabine, 'r-', 'LineWidth', 2, 'DisplayName', '\alpha_s (Sabine - Estadístico)');
hold off;
xlabel('Frecuencia (Hz)'); 
ylabel('Coeficiente de Absorción (\alpha)');
title(sprintf('Absorción del Panel (%d celdas): Normal vs Estadística', Nceldas));
grid on; 
legend('show', 'Location', 'southwest');
xlim([100 300]);
ylim([0 1.1]);




% Calcular la profundidad real de cada cavidad en mm
s_celda_mm = s_celda * 1000; 
Vi_mm3 = Vi * 1e9; 
h_cavidad_mm = Vi_mm3 / (s_celda_mm^2);

% Imprimir los valores para copiarlos a OpenSCAD
fprintf('\n--- DATOS PARA OPENSCAD ---\n');
fprintf('Lado interior base (s_celda): %.2f mm\n', s_celda_mm);
fprintf('Altura máxima de cavidad (para 150Hz): %.2f mm\n', max(h_cavidad_mm));
disp('Vector de 36 profundidades de cavidad (mm):');
disp(mat2str(round(h_cavidad_mm, 2)));


%% COMPARACION COMSOL
datos_comsol = load('absorcion_KUNDT_comsol.txt');
f_comsol = datos_comsol(:, 1);
alpha_comsol = datos_comsol(:, 2);

% Creamos la gráfica comparativa
figure('Name','Validación: Analítico vs COMSOL', 'Color', 'w');
hold on;
plot(f, alpha_normal, 'b-', 'LineWidth', 2, 'DisplayName', '\alpha_n (Kundt - Analítico)');
plot(f_comsol, alpha_comsol, 'r--', 'LineWidth', 2, 'DisplayName', '\alpha (COMSOL - Simulación)');

% 3. Formato profesional y limpio
title('Absorción del Panel (36 celdas): Analítico vs Simulación', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Frecuencia (Hz)', 'FontSize', 12);
ylabel('Coeficiente de Absorción (\alpha)', 'FontSize', 12);
grid on;
axis([100 300 0 1.05]); % Ajustamos los ejes para que encuadre perfectamente
legend('Location', 'south', 'FontSize', 11);
hold off;
