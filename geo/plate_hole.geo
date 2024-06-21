SetFactory("OpenCASCADE");

// Set size for mesh 
// It will be changed in the bottom of the file
lc = 1.0;

// Corner points
Point(1) = {0, 0, 0, lc};
Point(2) = {2, 0, 0, lc};
Point(3) = {2, 1, 0, lc};
Point(4) = {0, 1, 0, lc};

// Edge lines
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// First curve Loop
Curve Loop(1) = {3, 4, 1, 2};

// Circle
Mesh.MinimumCirclePoints = 1;
radius = 0.2;
cx = 1.0;
cy = 0.5;
cz = 0.0;
Circle(5) = {cx, cy, cz, radius, 0, 2*Pi};

// Second curve loop
Curve Loop(2) = {5};

// Planar surface (with hole)
Plane Surface(1) = {1, 2};

// Set a name and number for this Phisical Surface
Physical Surface("Domain", 2) = {1};

// Lets apply a surface force in the second lines
Physical Line("P,X,100.0",3) = {2};

// Lets constrain the fourth line in X
Physical Line("U,X,0.0",4) = {4};

// And the first node in Y as well
Physical Point("U,Y,0.0",5) = {1};

// Convert triangles to quads
Recombine Surface{1};

// Set smooth ratio
Mesh.SmoothRatio = 3;

// Global mesh size
MeshSize {:} = 0.05;

// Better quad algorithm
Mesh.Algorithm = 8;

// Build mesh
Mesh 2;

// Save the mesh
Save "plate_hole.msh";