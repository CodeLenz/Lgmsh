//
// Viga engastada com força na ponta e peso próprio
//

// Comprimento da viga
L = 1.0;

// Altura da viga
H = 0.1;

// Espessura 
b = 0.01;

// tamanho do elemento
lc = 1e-2;

// Cantos
Point(1) = { 0, 0,   0, lc};
Point(2) = { L, 0,   0, lc};
Point(3) = { L, H,   0, lc};
Point(4) = { 0, H,   0, lc};

// Lados
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Superfície
Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// Material
Physical Surface("Material,aço,1,210E9,0.3,7850.0") = {1};

// Força de corpo na direção Y global
// = \rho * g = -7850*10 [N/m^3] 
Physical Surface("Fb,2,-78500") = {1};

// Aplica uma "pressão" normal na face 2, direção normal
// normal, tangencial1, tangencial2
Physical Curve("Ft,1E1,0.0,0.0") = {2};

// Força concentrada no canto superior direito 
Physical Point("Fc,2,100.0") = {3};

// Prende os gls x dos nós da face da esquerda
Physical Curve("U,1,0.0") = {4};

// Prende os gls y dos nós da face da esquerda
Physical Curve("U,2,0.0") = {4};

// Converte os triângulos para retângulos
Recombine Surface{:};

// Algoritmo para geração de malha
Mesh.Algorithm = 8;

// Cria a malha
Mesh 2;

// Grava a malha
Save "viga_longa.msh";
