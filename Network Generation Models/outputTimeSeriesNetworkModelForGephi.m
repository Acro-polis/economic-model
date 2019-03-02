function outputTimeSeriesNetworkModelForGephi(title, AM, OriginTimes, numNodesStart, numTimeSteps, version_number)
%=====================================================
%
% Write nodes and edges output files for external 
% processing (comma delimited files)
%
% Author: Jess
% Created: 2018.07.8
%=====================================================
fprintf("Begin Ouput\n");

numNodesEnd = size(AM,1);

outputNodes = 1;
if outputNodes == 1
    fileNodes   = sprintf('Nodes %s SN=%u EN=%u T=%u V%s.csv', title, numNodesStart, numNodesEnd, numTimeSteps, version_number);
    fIdNodes 	= fopen(fullfile([pwd '/Output'],fileNodes),"w");
    fprintf("Outputting Nodes\n");
    fprintf(fIdNodes,"Id,Label,Origin Time\n");
    for i = 1:numNodesEnd
            fprintf(fIdNodes, '%d,\"Node %d\",%d\n', i, i, OriginTimes(i));
    end
    fclose(fIdNodes);
else
    fprintf("Skipping Node Output\n");
end

fileEdges   = sprintf('Edges %s SN=%u EN=%u T=%u V%s.csv', title, numNodesStart, numNodesEnd, numTimeSteps, version_number);
fIdEdges	= fopen(fullfile([pwd '/Output'],fileEdges),"w");

fprintf("Outputting Edges\n");
fprintf(fIdEdges,"Source,Target,Label,Type\n");
for i = 1:numNodesEnd
        for j = 1:numNodesEnd
                if (i ~= j && AM(i,j) > 0)
                        fprintf(fIdEdges, '%d,%d,\"Edge %d to %d\",\"Mixed\"\n', i, j, i, j);
                end
        end
end
fclose(fIdEdges);

fprintf("Output Complete\n");

end
