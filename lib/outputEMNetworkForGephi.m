function outputEMNetworkForGephi(Am, polis, purchases, pathFailures, liquidityFailures, inventoryFailures, sumLiquidityFailuresCausedByAgent, noMoneyFailures, noSellerFailures, nodesFilePath, edgesFilePath)
%=====================================================
%
% Output the netowrk model with statistics
%
% Author: Jess
% Created: 2018.12.7
%=====================================================

    N = size(Am,1);
    agents = polis.agents;
    
    fileIdNodes = fopen(nodesFilePath, "w");
    if fileIdNodes > 0
        fprintf(fileIdNodes,"Id,Label,Purchases,PathFail,SufferedLiquidityFail,CausedLiquidityFail,InventoryFail,NoMoneyFail,NoSellerFail,AgentType\n");
        for i = 1:N
                agentType = typeOfAgent(agents(i));
                fprintf(fileIdNodes, '%d,\"Node %d\", %.2f, %.2f, %.2f, %.2f, %.2f, %.2f, %2.f, %2.f\n', i, i, purchases(i), pathFailures(i), liquidityFailures(i), sumLiquidityFailuresCausedByAgent(i), inventoryFailures(i), noMoneyFailures(i), noSellerFailures(i), agentType);
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

function agentType = typeOfAgent(agent)
    agentType = 0;      % Passive agent
    if agent.isBuyer && agent.isSeller
        agentType = 2;  % Buyer + Seller
    elseif agent.isBuyer
        agentType = 1;  % Buyer Only (Seller Only is removed)
    end
end