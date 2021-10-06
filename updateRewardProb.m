function NormRewProbs = updateRewardProb(Conv,User,EscRts)
% Updates User's RewardProbs Array
% Parameters: String that tells whether FullConvMain or NonConvMain is being run, User object,EscRts vector of EscRt objects 
%Returned: the normalized reward probability for the chosenRoute that is used to update all the
%action probs
%Other Actions: changes the user object's reward prob for all chosenRoute.
NormRewProbs = [];


%For user object: updates reward probs for all routes 
for i = 1: length(EscRts)
    %data being extracted from objects
    SumQoS = EscRts(i).QoS;
    rate = EscRts(i).EvacRate;
    usersInRt = length(EscRts(i).Users);
    cluster = length(EscRts(i).Cluster);
    dist = distance(User,EscRts(i));
    if Conv == 'non'
        RewProb = SumQoS*(rate/((usersInRt+1)*(dist^2)));
    else
        RewProb = SumQoS*(rate/(((cluster+1)^2)*(usersInRt+1)*(dist^2))); %formula that includes length of cluster
    end

    User.RewardProbs(i) = RewProb; %The user's reward prob for the route is updated
    %Normalization is used to convey reward probabilities in values ranging only from 0 to 1
    NormRewProbs(i) = User.RewardProbs(i)/ sum(User.RewardProbs);
    
end
 

end

% %old way
% ChosenEscRt = User.ChosenRoute;
% rate = ChosenEscRt.EvacRate;
% usersInRt = length(ChosenEscRt.Users);
% cluster = ChosenEscRt.Cluster;
% dist = distance(User,ChosenEscRt);
% if Conv == 'non'
%         RewProb = ChosenEscRt.QoS*(rate/((UsersInRt+1) *(dist).^2));
% else
%     RewProb = ChosenEscRt.QoS*(rate/(((1+length(cluster)).^2)*(UsersInRt+1) *(dist).^2)); %formula that includes length of cluster
% end

