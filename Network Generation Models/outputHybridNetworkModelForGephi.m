function outputHybridNetworkModelForGephi(Am, outputNodes, outputSubfolderPath)
%==========================================================================
%
% Write nodes and edges output files for external processing
%
% Author: Jess
% Created: 2018.07.8
%==========================================================================
fprintf("\nBegin Ouput\n");

numNodes = size(Am,1);

if outputNodes
    fprintf("\nOutputting Nodes\n");
    outputFilePathAndName = sprintf("%s%s", outputSubfolderPath, "nodes.csv");
    fIdNodes = fopen(outputFilePathAndName, "wt");
    fprintf(fIdNodes,"Id;Label\n");
    for i = 1:numNodes
            fprintf(fIdNodes, '%d,\"Node %d\"\n', i, i);
    end
    fclose(fIdNodes);
else
    fprintf("\nSkipping Node Output\n");
end

fprintf("\nOutputting Edges\n");

outputFilePathAndName = sprintf("%s%s", outputSubfolderPath, "edges.csv");
fIdEdges = fopen(outputFilePathAndName, "wt");
fprintf(fIdEdges,"Source,Target,Label,Type\n");

for i = 1:numNodes
        for j = 1:numNodes
                if (i ~= j && Am(i,j) > 0)
                        fprintf(fIdEdges, '%d,%d,\"Edge %d to %d\",\"Undirected\"\n', i, j, i, j);
                end
        end
end

fclose(fIdEdges);

fprintf("\nEnd Output\n");

end
