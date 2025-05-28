//
// Seção transversal em L 
//


// tamanho do elemento
lc = 1e-3;

// Cantos
Point(1) = { 0   ,    0,   0, lc};
Point(2) = { 5E-2,    0,   0, lc};
Point(3) = { 5E-2, 1E-2,   0, lc};
Point(4) = { 1E-2, 1E-2,   0, lc};
Point(5) = { 1E-2, 5E-2,   0, lc};
Point(6) = { 0   , 5E-2,   0, lc};

// Lados
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 1};


// Superfície
Curve Loop(1) = {1, 2, 3, 4, 5, 6};
Plane Surface(1) = {1};

// Converte os triângulos para retângulos
Recombine Surface{:};

// Algoritmo para geração de malha
Mesh.Algorithm = 8;

// Cria a malha
Mesh 2;

// Grava a malha
Save "L.msh";
