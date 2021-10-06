function [returningUsers,Escapees] = goOrNotGo(threshold, Cluster )
%GOORNOTGO Parameters: the threshold value (or maximum number of Escapees
%desired), Cluster vector of User objects. Returned: Two vectors of User
%objects
%  Uses exponential learning algorithm

learningRate = 0.2;
%resets the MG Scores and Probs of User
for i= 1: length(Cluster)
    Cluster(i).MGScores = [0 0];
    Cluster(i).MGProbs = [0.5 0.5];
end
convergence = 0;
MGcounter = 0;
%This while loop iterates until the minimum of the maximum MG Probs of
%Every user exceeds the convergence value. To increase efficiency, this
%while loop will run a maximum of 100 iterations, which is heuristically
% appropriate.
while convergence <= .9 && MGcounter < 100
    MGcounter = MGcounter + 1;
    %The two groups are initialized
    Go = [];
    NoGo = [];
    for i = 1: length(Cluster)
        %randomize is used to choose a group based on the MGProbs
        %distributions
        if randomize(Cluster(i).MGProbs) == 1
            Go = [Go Cluster(i)];      
        
        else
            NoGo = [NoGo Cluster(i)];
        end

    end
    %When the Go group wins, their strategies for choosing Go are updated
    if length(Go) <= threshold
        for i = 1:length(Go)
            Go(i).MGScores(1) = Go(i).MGScores(1)+1;
        end
    %When the Go group loses, the NoGo users' strategies for choosing the NoGo group are updated
    else
        for i = 1:length(NoGo)
            NoGo(i).MGScores(2) = NoGo(i).MGScores(2)+1;
        end
    end
    Cluster = [Go NoGo];
    
%     for i = 1: length(Cluster)
%         if length(Go) < threshold
%             Cluster(i).MGScores(1) = Cluster(i).MGScores(1) + 1;            
%         else
%             Cluster(i).MGScores(2) = Cluster(i).MGScores(1) + 1;
%         end
%     end


%The MGScores, or strategies of the user, are used to update the MGProbs
%based on exponential learning formula
    for i = 1: length(Cluster)
        GoTop = exp((learningRate * Cluster(i).MGScores(1))); %the numerator for the Go probability
%         prevents inf errors
        if isinf(GoTop) == 1
            GoTop = realmax;
        end
        NoGoTop = exp((learningRate * Cluster(i).MGScores(2)));%The numerator for the NoGo prob
        %isNAN = isnan(NoGoTop)
        if isinf(NoGoTop)== 1
            NoGoTop = realmax;
        end
        Sum = GoTop + NoGoTop;
        Cluster(i).MGProbs(1) = GoTop/Sum;
        Cluster(i).MGProbs(2) = NoGoTop/Sum;
        
    end
    returningUsers = NoGo;
    Escapees = Go;
    %Checks the maxes of the cluster's users' MGProbs. The loop breaks if
    %one is below the convergence threshold. That convergence value is fed
    %to the top of the while loop and the program continues.
    for k = 1:length(Cluster)
    convergence = max(Cluster(k).MGProbs);
    if convergence < .9
        break;
        
    end
   
    end

    
end

end
% Cluster(i).MGProbs(1) = e^(learningRate * Cluster(i).MGScores(1));
%             Cluster(i).MGProbs(2) = 
% 
% %         if Cluster(i).goOrNotGo(1) == Cluster(i).goOrNotGo(2)
% %             groupNums(i) = randomize([0.5 0.5]);
%         end
%         if Cluster(i).goOrNotGo(1) == Cluster(i).goOrNotGo(2)
%             [~,col] = find(Cluster(i).goOrNotGo==max(Cluster(i).goOrNotGo));
%             groupNums(i) = col;
%         end