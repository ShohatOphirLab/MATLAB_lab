function ret_val = compute_behavior_logic(allScores, i)

ret_val=zeros(1,allScores.tEnd(i));
ret_val(allScores.t0s{i})=1;
ret_val(allScores.t1s{i})=-1;
ret_val=logical(cumsum(ret_val));
ret_val=ret_val(1:allScores.tEnd(i));