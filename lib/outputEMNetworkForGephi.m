function outputEMNetworkForGephi(Am, purchases, pathFailures, liquidityFailures, inventoryFailures, noMoneyFailures, nodesFilePath, edgesFilePath)
%=====================================================
%
% Output the netowrk model with statistics
%
% Author: Jess
% Created: 2018.12.7
%=====================================================

    N = size(Am,1);

    fileIdNodes = fopen(nodesFilePath, "w");
    if fileIdNodes > 0
        fprintf(fileIdNodes,"Id,Label,Purchases,PathFail,LiquidityFail,InventoryFail,NoMoneyFail\n");
        for i = 1:N
                fprintf(fileIdNodes, '%d,\"Node %d\", %.2f, %.2f, %.2f, %.2f, %.2f\n', i, i, purchases(i), pathFailures(i), liquidityFailures(i), inventoryFailures(i), noMoneyFailures(i));
        end
        fclose(fileIdNodes);
    end

    fileIdEdges = fopen(edgesFilePath, "w");
    if fileIdEdges > 0
        fprintf(fileIdEdges,"Source,Target,Label,Type\n");
        for i = 1:N
                for j = 1:N
                        if (i ~= j && Am(i,j) > 0)
                                fprintf(fileIdEdges, '%d,%d,\"Edge %d to %d\",\"Undirected\"\n', i, j, i, j);
                        end
                end
        end
        fclose(fileIdEdges);
    end

end

