
function out = sortRhosByCondition(rho, uniqueConditionIndex, conditionIndex)
numUniqueConditions = max(uniqueConditionIndex);
numFeats = size(rho,2);
out.rho = zeros(numUniqueConditions,numFeats);
out.conditionIndex = zeros(numUniqueConditions,1);

for i = 1:numUniqueConditions
    indice = find(uniqueConditionIndex == i);
    out.rho(i,:) = mean(rho(indice,:));
    out.conditionIndex(i) = mean(conditionIndex(indice))';
end
out.indexPlay = find(out.conditionIndex == 1);
out.indexBci = find(out.conditionIndex == 2);
out.indexWatch = find(out.conditionIndex == 3);