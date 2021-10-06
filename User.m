classdef User < handle
    %USER handle class that stores properties of a user trying to escape
    %the critical area
    %  the coordinates and identity are needed to construct a user
    
    properties
        %user number
        identity 
        %the identity of the escape route the user came from.
        Status         
        %coordinates
        X
        Y
        %Stochastic learning automata
        ActionProbs
        RewardProbs
        ChosenRoute
        %Minority game
        MGScores
        MGProbs
        ActionProbHist
        
    end
    
    methods
        function F = User(a,b,c)
            F.X = a;
            F.Y = b;
            F.identity = c;
        end
            
            
    end
    
end

