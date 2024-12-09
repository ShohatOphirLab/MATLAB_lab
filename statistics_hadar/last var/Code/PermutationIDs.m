function permTest = PermutationIDs(femaleHist,maleHist)


%%
group1 = femaleHist;
group2 = maleHist;

% Observed KS statistic
observed_statistic = kstest2(group1, group2);

% Permutation test
num_permutations = 1000;
permuted_statistics = zeros(1, num_permutations);

for ii = 1:num_permutations
    % Combine and shuffle the data
    combined_data = [group1; group2];
    combined_data = combined_data(randperm(length(combined_data)));
   
    % Split into permuted groups
    permuted_group1 = combined_data(1:length(group1));
    permuted_group2 = combined_data(length(group1)+1:end);
   
    % Calculate KS statistic for the permuted groups
    permuted_statistics(ii) = kstest2(permuted_group1, permuted_group2);
end

% Calculate p-value
permTest = (sum(permuted_statistics >= observed_statistic)+1) / (num_permutations+1);
%%%%% I should check what is the assemption if it 2 sides or 1 side
end


