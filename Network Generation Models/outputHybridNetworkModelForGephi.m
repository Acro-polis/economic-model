function outputNetworkModelForGephi(title, Am, SN, T, alpha, version_number)
%=====================================================
%
% Write nodes and edges output files for external 
% processing (semicolon delimited files)
%
% Author: Jess
% Created: 2018.07.8
%=====================================================
fprintf("Begin Ouput\n");

FN = size(Am,1);

outputNodes = 0;
if outputNodes
    fileNodes   = sprintf('Nodes %s SN=%u FN=%u T=%u a=%.2f V%s.csv', title, SN, FN, T, alpha, version_number);
    fIdNodes 	= fopen(fullfile([pwd '/Output'],fileNodes),"w");
    fprintf("Outputting Nodes\n");
    fprintf(fIdNodes,"Id;Label\n");
    for i = 1:FN
            fprintf(fIdNodes, '%d,\"Node %d\"\n', i, i);
    end
    fclose(fIdNodes);
else
    fprintf("Skipping Node Output\n");
end

fileEdges   = sprintf('Edges %s SN=%u FN=%u T=%u a=%.2f V%s.csv', title, SN, FN, T, alpha, version_number);
fIdEdges	= fopen(fullfile([pwd '/Output'],fileEdges),"w");

fprintf("Outputting Edges\n");
fprintf(fIdEdges,"Source,Target,Label,Type\n");
for i = 1:FN
        for j = 1:FN
                if (i ~= j && Am(i,j) > 0)
                        fprintf(fIdEdges, '%d,%d,\"Edge %d to %d\",\"Mixed\"\n', i, j, i, j);
                end
        end
end
fclose(fIdEdges);

fprintf("Output Complete\n");

end
