% Barabási-Albert (BA) scale-free, preferential-attachment graph
% generation model, as per "Emergence of Scaling in Random Networks".
%
% N: the number of vertices
% m: number of edges to add per step
% m0: the number of initial edges (must be greater than m, defaults to m +
%     1)
% a: an additive boost, governing initial attractiveness of a node,
% from Dorogovtsev, et al, "Structure of Growing Networks 
% with Preferential Linking", Phys. Rev. Lett., 2000. Default is 0,
% in which case the model is identical to the original BA model.
%
% mode: "strict" or "min" Whether to use the "strict" definition of
% Barabási-Albert and add /exactly/ m edges per step; or be more relaxed
% (and potentially much more efficient) and treat m as a minimum and 
% add /at least/ m edges per step.

function G = scale_free (N, m, m0 = m + 1, a = 0, mode = "strict")
	G = sparse (N,N);

	for i = 2 : m0 + 1
		G(i, i - 1) = 1;
    end

	G = G | G';

	for i = m0 + 1: N
		connect = scale_free_add (G, i, m, a, mode);
		G(connect,i) = 1;
		G(i,connect) = 1;		
		%disp(["adde]);
    end
	G = G | G';
end

function connect = scale_free_add (G, n, m, a = 0, mode = "strict")

	ki = sum(G(1:n - 1,1:n-1));
	sumkj = sum(ki);
	pi = (a + ki)/sumkj;

	connect = zeros (1, n - 1);

	while (sum(connect) < m)
 		connect |= (pi >= rand (1,n - 1));
    end

	if (strcmp (mode, "strict") && sum(connect) > m)
		perm = randperm (n - 1);
		c = connect(perm);
		added = 0;
		% a binary search would make this faster
                % or perhaps using sort
		for i = 1:columns(c)
			if (added < m)
				added += c(i);
			else
				connect(perm(i)) = 0;
            end
        end
    end 
end