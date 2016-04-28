function [ R ] = ADR_overlapping_DD( MESH, n_subdom, overlap )
%ADR_OVERLAPPING_DD builds subdomains with overlap 
%
%   INPUT: dim: 2 for 2D, 3 for 3D
%        n_subdom: number of subdomains
%        overlap: number of overlap layers, 1 is suggested

%   This file is part of redbKIT.
%   Copyright (c) 2016, Ecole Polytechnique Federale de Lausanne (EPFL)
%   Author: Federico Negri <federico.negri at epfl.ch> 

vertices     = MESH.vertices;
elements     = MESH.elements(1:MESH.dim+1,:);% P1 elements
dim          = MESH.dim;
I            = MESH.internal_dof;
nln          = MESH.numElemDof;
nodes        = MESH.nodes;
elements_fem = MESH.elements(1:nln,:);% P1 elements

[subdom] = geometric_domain_decomposition(vertices, elements, dim, n_subdom, overlap, 1, 'Figures', elements_fem);

%% restrict subdomains to internal vertices
for i = 1 : n_subdom
    subdom_I{i} = intersect(subdom{i}, I);
    if size(subdom_I{i},1) > size(subdom_I{i},2)
        subdom_I{i} = subdom_I{i}';
    end
end


%% build subdomains restriction/prolongation operators
nov     = size(nodes,2);

parfor i = 1 : n_subdom
    tmp =  zeros(nov,1);
    tmp(subdom_I{i}) = 1;
    tmp2  =  tmp(I);    
    R{i}  = find(tmp2);
end

check_n_subd = length(R);
fprintf('\n%d subdomains and restriction/prolongation operators built ---\n',check_n_subd);
        
%% build coarse aggregation restriction/prolongation operator
% R{n_subdom+1}  = sparse(nov,n_subdom);
% 
% for j = 1 : n_subdom
%     R{n_subdom+1}(subdom_I{j},j) = 1;
% end
% 
% R{n_subdom+1} = R{n_subdom+1}(I,:)';

return