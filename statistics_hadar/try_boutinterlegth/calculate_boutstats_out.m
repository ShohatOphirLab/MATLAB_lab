function [bout_lengths inter_bout_lengths ]=...
    calculate_boutstats_out(behavior_data,behavior_logic,behaviornot)%,behavior_data2,sexdata,behaviornot)

bout_lengths=cell(1,length(behavior_data.allScores.t0s));
inter_bout_lengths=cell(1,length(behavior_data.allScores.t0s));

for i=1:length(behavior_data.allScores.t0s)  % individual
  tmp1 = compute_behavior_logic_out(behavior_data.allScores, i);
  tmp1 = tmp1(behavior_data.allScores.tStart(i) : behavior_data.allScores.tEnd(i));

  tmp2=[];
  if(behavior_logic>1)
    tmp2 = compute_behavior_logic(behavior_data2.allScores, i);
    tmp2 = tmp2(behavior_data2.allScores.tStart(i) : behavior_data2.allScores.tEnd(i));
  end

  if(behaviornot)  tmp1=~tmp1;  end

  partition_idx=[];
  switch(behavior_logic)
    case(1)
      partition_idx=tmp1;
    case(2)
      partition_idx=tmp1 & tmp2;
    case(3)
      partition_idx=tmp1 & ~tmp2;
    case(4)
      partition_idx=tmp1 | tmp2;
    case(5)
      partition_idx=tmp1 | ~tmp2;
  end

  % inter-bout NOT <behavior> is not quite the same as bout <behavior>

  partition_idx=[0 partition_idx 0];
  start=1+find(~partition_idx(1:(end-1)) &  partition_idx(2:end))-1;
  stop =  find( partition_idx(1:(end-1)) & ~partition_idx(2:end))-1;
  if(length(start)>0)
    bout_lengths{i}=stop-start+1;
    
    if(length(start)>1)
      inter_bout_lengths{i}=start(2:end)-stop(1:(end-1));
      
    end
  end
end

