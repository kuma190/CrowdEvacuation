function convergenceInfo = updateActionProbs(Conv,User,EscRts)
%ACTIONPROB updates Action Probs
%Parameters: a string conveying what type of main is being run, a User
%object,EscRts vector in order to update Reward Probabilities
%Returned: the maximum action probability of the user.
%Other Actions: goes into the user object and updates ALL action probs.
i = User.ChosenRoute.identity;%i is type int
PrevActProb = User.ActionProbs(i);
learnRate = 0.8;
NormRewProbs = updateRewardProb(Conv,User,EscRts);%update reward prob function is only called here.
%All action probs are updated according to the second formula, which is
%used for the routes not chosen.
for n = 1:length(User.ActionProbs)
    k = User.ActionProbs(n);
    User.ActionProbs(n) = k - (learnRate)*NormRewProbs(n)*k;
end
% the action prob for the chosenRoute was stored in PrevActProb prior to
% the for loop. PrevActProb is used to update the chosenRoute's action prob
% with the chosenRoute formula.
chosenRouteActionProb = PrevActProb + (learnRate)*NormRewProbs(i)*(1 - PrevActProb);
User.ActionProbs(i) = chosenRouteActionProb;
convergenceInfo = max(User.ActionProbs);
end


