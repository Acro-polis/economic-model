function outputTimeSeriesNetworkModelForGephi(title, AM, nodeOriginTimes, numNodesStart, numTimeSteps, version_number)
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
endTime = nodeOriginTimes(numNodesEnd);

outputNodes = 1;
if outputNodes == 1
    fileNodes   = sprintf('Nodes %s SN=%u EN=%u T=%u V%s.csv', title, numNodesStart, numNodesEnd, numTimeSteps, version_number);
    fIdNodes 	= fopen(fullfile([pwd '/Output'],fileNodes),"w");
    fprintf("Outputting Nodes\n");
    fprintf(fIdNodes,"Id,Label,Start,End,Interval\n");
%    fprintf(fIdNodes,"Id,Label,Start,End\n");
    for i = 1:numNodesEnd
            birthTime = nodeOriginTimes(i);
            fprintf(fIdNodes, '%d,\"Node %d\",%d,%d,\"<[%d,%d]>\"\n', i, i, birthTime, endTime, birthTime, endTime);
%            fprintf(fIdNodes, '%d,\"Node %d\",%d,%d\n', i, i, birthTime,endTime);
    end
    fclose(fIdNodes);
else
    fprintf("Skipping Node Output\n");
end

fileEdges   = sprintf('Edges %s SN=%u EN=%u T=%u V%s.csv', title, numNodesStart, numNodesEnd, numTimeSteps, version_number);
fIdEdges	= fopen(fullfile([pwd '/Output'],fileEdges),"w");

fprintf("Outputting Edges\n");
%fprintf(fIdEdges,"Source,Target,Weight,Type,Start,End,Interval,Label\n");
fprintf(fIdEdges,"Source,Target,Weight,Type,Start,End,Label\n");
for i = 1:numNodesEnd
        birthTime = nodeOriginTimes(i);
        for j = 1:numNodesEnd
                if (i ~= j && AM(i,j) > 0)
%                        fprintf(fIdEdges, '%d,%d,%d,\"undirected\",%s,%s,\"<[%s,%s]>\",\"node %d to %d\"\n', i, j, 1, birthTimeStr, endTimeStr, birthTimeStr, endTimeStr, i, j);
                        fprintf(fIdEdges, '%d,%d,%d,\"undirected\",%d,%d,\"node %d to %d\"\n', i, j, 1, birthTime, endTime, i, j);
                end
        end
end
fclose(fIdEdges);

fprintf("Output Complete\n");

end
