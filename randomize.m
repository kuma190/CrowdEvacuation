function Route = randomize(ActionProbsVector)
%RANDOMIZE returns a random route based on action probs
% a cumulative sum of the ActionProbs are made
cumAP = [0 cumsum(ActionProbsVector)];
      r = rand(1,1); %Any rational number between zero and one is chosen
       % the minus one prevents a index out of bound error 
       %for an x number of elements in a vector, there are x-1 number of ranges
       %The 'space' between each element is checked for 'r'. The index 'n'
       %which precedes the space with 'r' in it is the chosenRoute.
      for n = 1:(length(cumAP)-1)
          if (r > cumAP(n) && r <= cumAP(n+1))
              Route = n;
          end
      end
      %Chooses route based on maximum Action Prob. Comment this out to use
      %the randomize section above. 
      Routew = find(ActionProbsVector == max(ActionProbsVector));
      if length(Routew) == 1
          Route = Routew;
      else
          randomIndex = randi(length(Routew), 1);
          Route = Routew(randomIndex);
      end
end

