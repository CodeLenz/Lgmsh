//
// Cantilever Beam
//

// Element size
lc = 1e-2;

// Corners
Point(1) = { 0, 0,   0, lc};
Point(2) = { 1, 0,   0, lc};
Point(3) = { 1, 0.1, 0, lc};
Point(4) = { 0, 0.1, 0, lc};

// Edges
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Surface
Curve Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// Material
Physical Surface("Material") = {1};

// Boundary conditions - displacements
Physical Curve("U,ALL,0.0") = {4};

// Boundary conditions - force at L
Physical Point("F,Y,-100.0") = {2};

// Convert triangles to quads
Recombine Surface{:};

// Better quad algorithm
Mesh.Algorithm = 8;

// Build mesh
Mesh 2;

// Save the mesh
Save "cantilever.msh";
