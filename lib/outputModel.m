function outputModel(Am)
%
% Write a nodes and edges output file for external processing
%

N = size(Am,1);

fileNodes 	= "g_nodes.csv";
fIdNodes 	= fopen(fileNodes,"w");
fileEdges	= "g_edges.csv";
fIdEdges	= fopen(fileEdges,"w");

fprintf("Begin Ouput\n");
fprintf("Outputting Nodes\n");

fprintf(fIdNodes,"Id;Label\n");
for i = 1:N
        fprintf(fIdNodes, "%u;\"Node %u\"\n", i, i);
endfor;

fprintf("Outputing Edges\n");

fprintf(fIdEdges,"Source;Target;Label;Type\n");
for i = 1:N
        for j = 1:N
                if (i != j && Am(i,j) > 0)
                        fprintf(fIdEdges, "%u;%u;\"Edge %u to %u\";\"Mixed\"\n", j, i, j, i);
                endif;
        endfor;
endfor;

fclose(fIdNodes);
fclose(fIdEdges);

fprintf("Output Complete\n");

end
