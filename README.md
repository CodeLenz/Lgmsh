# Lgmsh

[![Build Status](https://github.com/CodeLenz/Lgmsh.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/CodeLenz/Lgmsh.jl/actions/workflows/CI.yml?query=branch%3Amain)

## A very simple interface to post-processing using Gmsh (https://gmsh.info/)

This package aims to offer some subroutines to export data to the gmsh post processing software. Imort of gmsh meshes (pre-processing) will be added in the future.

All post-processing must start with the creation of a file with $filename$

```julia
Lgmsh_init(filename::String,nn::T,ne::T,coord::Array{F},etype::Vector{T},connect::Array{T}) where {T,F}
```
where 

$nn$: number of nodes

$ne$: number of elements

$coord$: array with nodal coordinates, with size $nn \times dim$, where dim is $2$ or $3$

$etype$: vector with element types, with size $ne \times 1$. Element types are the same used by gmsh and can be found in (https://gmsh.info/dev/doc/texinfo/gmsh.pdf). The number of nodes for each element type can be found in /src/init.jl.

$connect$: array with connectivities, with size $ne \times n_{max}$, where $n_{max}$ is the maximum number of nodes per element in the model.

Example 
```julia
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
Lgmsh_init(filename,nn,ne,coord,etype,connect)
```

After creating the initial header, it is possible to export scalar and vector views to this file. Tensor views will be added in the near future. 

### Scalar Views

Currently, there are two main subroutines to export scalar views

Export element (centroidal) scalar values to filename
```julia
Lgmsh_element_scalar(filename::String,element::Vector,viewname::String,time=0.0) 
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
Lgmsh_element_scalar(filename,element,"Random centroidal Scalar") 
```

and 

Export nodal scalar values to filename
```julia
Lgmsh_nodal_scalar(filename::String,nodal::Vector,viewname::String,time=0.0) 
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
Lgmsh_nodal_scalar(filename,nodal,"Random nodal Scalar") 
```

### Vector fields

Vector fiedls are created with 

```julia
Lgmsh_nodal_vector(filename::String,vector::Vector,dim::Int,viewname::String,time=0.0)
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
Lgmsh_nodal_vector(filename,vector,dim,"Nodal vector 2D")           

#                            3D
# Dimension
dim = 3

# Three dimensional vector for each node
vector = rand(dim*nn) 

# Create view
Lgmsh_nodal_vector(filename,vector,dim,"Nodal vector 3D")           
```




