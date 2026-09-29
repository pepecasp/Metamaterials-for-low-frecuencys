// --- PARÁMETROS GENERALES ---
s_celda = 68.07;      
g = 2;                
d_cuello = 8.485;     
L_cuello = 15;        
h_max = 92.65;        

tam_x = 6 * s_celda + 7 * g; 
tam_y = tam_x; 
tam_z = g + h_max + L_cuello; 

h_cav = [
    92.65, 89.22, 85.98, 82.91, 80.00, 77.24, 
    74.62, 72.13, 69.77, 67.52, 65.38, 63.33, 
    61.38, 59.52, 57.75, 56.05, 54.42, 52.87, 
    51.38, 49.95, 48.58, 47.27, 46.01, 44.80, 
    43.64, 42.52, 41.44, 40.41, 39.41, 38.45, 
    37.52, 36.63, 35.77, 34.93, 34.13, 33.35
];

// --- GENERACIÓN CON CORTE TRANSVERSAL Y COLORES ---
difference() {
    
    // 1. EL PANEL COMPLETO
    difference() {
        // Bloque principal de plástico  
        cube([tam_x, tam_y, tam_z]); 
        
        for (i = [0 : 5]) {        
            for (j = [0 : 5]) {    
                idx = i * 6 + j;
                pos_x = g + j * (s_celda + g);
                pos_y = g + i * (s_celda + g);
                
                // Z de inicio de la cavidad
                pos_z_cavidad = tam_z - L_cuello - h_cav[idx];
                
                // A) Restar la cavidad de aire (Color ROJO para el interior)
                color("pink")
                translate([pos_x, pos_y, pos_z_cavidad])
                    cube([s_celda, s_celda, h_cav[idx] + 0.1]); 
                    
                // B) Restar el cuello (Color AZUL para distinguirlo)
                centro_x = pos_x + (s_celda / 2) - (d_cuello / 2);
                centro_y = pos_y + (s_celda / 2) - (d_cuello / 2);
                
                color("cyan")
                translate([centro_x, centro_y, tam_z - L_cuello - 0.1])
                    cube([d_cuello, d_cuello, L_cuello + 0.2]); 
            }
        }
    }
    
    // 2. HERRAMIENTA DE CORTE 
    /*
    y_corte = g + 2*(s_celda+g) + s_celda/2; 
    translate([-10, y_corte, -10])
        cube([tam_x + 20, tam_y, tam_z + 20]);*/
}
