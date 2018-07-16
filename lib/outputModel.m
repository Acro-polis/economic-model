function outputModel(Am)
%=====================================================
%
% Write nodes and edges output files for external 
% processing (semicolon delimited files)
%
% Author: Jess
% Created: 2018.07.8
%=====================================================

fileNodes 	= "g_nodes.csv";
fIdNodes 	= fopen(fileNodes,"w");
fileEdges	= "g_edges.csv";
fIdEdges	= fopen(fileEdges,"w");

N = size(Am,1);

fprintf("Begin Ouput\n");
fprintf("Outputting Nodes\n");

fprintf(fIdNodes,"Id;Label\n");
for i = 1:N
        fprintf(fIdNodes, '%d;\"Node %d\"\n', i, i);
end;

fprintf("Outputing Edges\n");

fprintf(fIdEdges,"Source;Target;Label;Type\n");
for i = 1:N
        for j = 1:N
                if (i ~= j && Am(i,j) > 0)
                        fprintf(fIdEdges, '%d;%d;\"Edge %d to %d\";\"Mixed\"\n', i, j, i, j);
                end;
        end;
end;

fclose(fIdNodes);
fclose(fIdEdges);

fprintf("Output Complete\n");

end
