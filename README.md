# Lgmsh -  A very simple interface to pre and post-processing using Gmsh 

This package aims to offer some subroutines to export data to the gmsh post processing software (https://gmsh.info/). Import of gmsh meshes (pre-processing) is performed by using the Gmsh library.

This package is not registerd and shoud be installed by using 
```julia
]add https://github.com/CodeLenz/Lgmsh
```
or
```julia
using Pkg
Pkg.add("url=https://github.com/CodeLenz/Lgmsh")
```

# Post-Processing

All post-processing must start with the creation of a file with $filename$

```julia
Lgmsh_export_init(filename::String,nn::T,ne::T,coord::Array{F},etype::Vector{T},connect::Array{T}) where {T,F}
```
where 

$nn$: number of nodes

$ne$: number of elements

$coord$: array with nodal coordinates, with size $nn \times dim$, where dim is $2$ or $3$

$etype$: vector with element types, with size $ne \times 1$. Element types are the same used by gmsh and can be found in (https://gmsh.info/dev/doc/texinfo/gmsh.pdf). The number of nodes for each element type can be found in /src/definitions.jl.

$connect$: array with connectivities, with size $ne \times n_{max}$, where $n_{max}$ is the maximum number of nodes per element in the model.

Example 
```julia
using Lgmsh

#
# Create a model with a square and a triangle
#

# Number of nodes
nn = 5

# Nodal coordinates
coord = [0.0 0.0 ;
         1.0 0.0 ;
         1.0 1.0 ;
         0.0 1.0 ;
         0.5 2.0 ]

# Element types
# 2 is triange and 3 is a rectangle
etype = [3;2]         

# Connectivities. 
# Observe that the rectangle has 4 nodes and the triangle has 3. Thus,
# we must insert a zero in the last row for this element.
connect = [1 2 3 4 ;
           4 3 5 0]

# Filename 
filename = "example.pos"

# Create the file
Lgmsh_export_init(filename,nn,ne,coord,etype,connect)
```

After creating the initial header, it is possible to export scalar and vector views to this file. Tensor views will be added in the near future. 

### Scalar Views

Currently, there are two main subroutines to export scalar views

Export element (centroidal) scalar values to filename
```julia
Lgmsh_export_element_scalar(filename::String,element::Vector,viewname::String,time=0.0) 
```

where

$filename$: must be  the same filename used in Lgmsh_init

$element$: vector with $ne$ scalars 

$viewname$: the name of this field 

$time$: time (default is 0.0)

```julia
# Create a random centroidal scalar field 
element = rand(ne)
    
# Append the view to the existing file
Lgmsh_export_element_scalar(filename,element,"Random centroidal Scalar") 
```

and 

Export nodal scalar values to filename
```julia
Lgmsh_export_nodal_scalar(filename::String,nodal::Vector,viewname::String,time=0.0) 
```

where

$filename$: must be  the same filename used in Lgmsh_init

$nodal$: vector with $nn$ scalars 

$viewname$: the name of this field 

$time$: time (default is 0.0)

```julia
# Create a random nodal scalar field 
nodal = rand(nn)
    
# Append the view to the existing file
Lgmsh_export_nodal_scalar(filename,nodal,"Random nodal Scalar") 
```

### Vector fields

Vector fiedls are created with 

```julia
Lgmsh_export_nodal_vector(filename::String,vector::Vector,dim::Int,viewname::String,time=0.0)
```
where

$vector$: is a $dim*nn \times 1$ vector containing the vector field. If $dim=2$, each pair of values are assigned to each node and if $dim=3$, each 3-tuple is assigned to each node. It is assumed that the information is from the first to the last node, in ascending order.

Example

```julia

#                             2D
# Dimension
dim = 2

# Two dimensional vector for each node
vector = rand(dim*nn) 

# Create view
Lgmsh_export_nodal_vector(filename,vector,dim,"Nodal vector 2D")           

#                            3D
# Dimension
dim = 3

# Three dimensional vector for each node
vector = rand(dim*nn) 

# Create view
Lgmsh_export_nodal_vector(filename,vector,dim,"Nodal vector 3D")           
```

# Pre-Processing

Pre-processing Gmsh .msh files is not very easy, since there are a lot of additional information on the .msh file. For example, if one creates a simple domain comprised of four points, four lines, one planar surface and a 2D mesh, there will be, at least, three types of finite elements; lines, points and the 2D elements (triangles and quads, for example). To make things worst, the imposition of boundary conditions is not direct and we must define Physical Groups. Thus, there are some soubroutines to parse basic information from such files. Those informations must be further processed to some specific format.


To recover nodes and nodal coordinates
```julia
nn, norder, coord = Lgmsh_import_coordinates(filename)
```

where 

$nn$: is the number of nodes 

$norder$: is an $nn \times 1$ vector of integers with the node numbers

$coord$: is an $nn \times 3$ array with nodal coordinates


To recover element types
```julia
etypes = Lgmsh_import_etypes(filename)
```

where 

$etypes$: is an vector with all the element types in the mesh. 


To recover elements of a given (valid) type
```julia
ne, number, connect =  Lgmsh_import_element_by_type(filename,type)
```

where 

$ne$: is the number of elements of this type

$number$: is an $ne \times 1$ are the element numbers in the mesh

$connect$: is a matriz $ne \times n_{nodes}$ with the connectivities and $n_{nodes}$ is the number of nodes of this particular element type.


To list Physical Groups and their names
```julia
pgroups, pgnames = Lgmsh_import_physical_groups(filename)
```

where 

$pggroups" is a vector of tuples (dim,tag) 

$pgnames" is a vector of strings


To recover all the entities belonging to a given Physical Group name
```julia
entities = Lgmsh_import_entities_physical_group(filename,name)
```

Example

Process the file testmesh1.msh in the test directory

```julia
# Load the package
using Lgmsh

# Path to the mesh file
filename = joinpath(pathof(Lgmsh)[1:end-12],"geo/cantilever.msh")

# Obtain nodes and coordinates
# This model has 10 nodes
nn, norder, coord = Lgmsh_import_coordinates(filename)

# Obtain the list of element types
etypes = Lgmsh_import_etypes(filename)

# Obtain the information about the triangular elements (type 2)
ne, number, connect =  Lgmsh_import_element_by_type(filename,2)

# Obtain the Physical Groups and names
pgroups, pgnames = Lgmsh_import_physical_groups(filename)

# Obtain the entities with for the second group
entities = Lgmsh_import_entities_physical_group(filename,pgnames[2])

```

Some higer level auxiliary functions for processing .msh files are provided

```julia
# Load the package
using Lgmsh

# Path to the mesh file
# This file corresponds to a 2D region with a circular hole. Some
# boundary conditions are imposed at nodes, lines and regions, by
# means of Physical Groups.
filename = joinpath(pathof(Lgmsh)[1:end-12],"geo/plate_hole.msh")

# Read the file, elements of type 2 (tri) and 3 (quads)
# nn is the number of nodes
# ne is the number of elements
# coord has the coordinates (x,y,z) for each node
# etypes has the types of each element
# connect has the connectivities for each element.
# etags is a dictionary with the original tags of each element.
# 
nn,ne,coord,etypes,connect,etags = Readmesh(filename,[3])

# Obtain the Physical Groups and names
pgroups, pgnames = Lgmsh_import_physical_groups(filename)

#
# There are three groups
#
# ["U,Y,0.0", "P,X,100.0", "U,X,0.0", "Domain"]

# Get all nodes for the group "U,X,0.0"
nodesx = Readnodesgroup(filename,"U,X,0.0")

# Get all nodes for the group "U,Y,0.0"
nodesy = Readnodesgroup(filename,"U,X,0.0")

# Get all elements inside Domain
elems_domain = Readelementsgroup(filename,"Domain",etags)


# These data must then be processed to some specific format
```
There are some examples (.geo and associated .msh files) in the 
geo. They can be accesses by using the joinpath command, as in the previous examples. The .geo files can be eddited with any text editor and the .msh can be generated by using $gmsh \, file.geo$

Those .geo files are adapted from the tutrials at https://gitlab.onelab.info/gmsh/gmsh/-/tree/master/tutorials.