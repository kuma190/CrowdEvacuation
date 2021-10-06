%ConvMain: Script that requires users' action probabilities to converge
%before sending them to clusters. 

%%initialization
NumUsers = 2000;
NumEscRts = 10;
Length = 500;
width = 500;
EscRts = EscRt.empty(0,NumEscRts); 
CritArea = CriticalArea;
CritArea.Users = User.empty(0,NumUsers);
%Matrices to store how important variables change. explanations given when
%variables are used in program.
Escaped = []; %Stores user objects that have escaped
QoSMat = []; %stores cumulative QoS for every timeslot
%ActionProbMat = [];
EvacRateMat = []; %Stores evacuation rate for every route every timeslot
RouteUsersMat = [];%Stores # of users in every route every timeslot
CritAreaMat = []; %population of critical area
%ConvergMat = [];
%UsersMat = [];
%EscMat = [];
EscapeeMat = [];%for every timeslot, Stores the number of users who have escaped the critical area but NOT the simulation 
MGCapMat = []; %stores the minority game threshold for every escape route every timeslot
ClusterMat = []; %stores the number of users in each cluster at every timeslot after their act probs have converged
minConvMat = []; %Stores the min of the maximum action prob from every user at every iteration
%Creation of Escape Routes: properties X coord, Y coord, identity,
%capacity, evacuation rate needed to construct EscRt objects
for i = 1:NumEscRts
    b = EscRt(Length*rand(),width*rand(),i,50,10);
    EscRts(i) = b;
end
%Creation of Users with properties X coord, Y coord, identity needed to
%construct. Equal action probabilities are created for every user based on
%the number of escape routes.
for i = 1:NumUsers
    a = User(Length*rand(),width*rand(),i);
    UsersMat(i,1) = a.X;
    UsersMat(i,2) = a.Y;
    CritArea.Users(i) = a;
    
end

convergence = 0;
counter = 0
%This while loop encompasses stochastic learning automata, the minority
%game, and updating information.
while isempty(CritArea.Users) == 0 
     CritAreaMat(counter+1,:) = length(CritArea.Users);
     %Action and reward probabilities are updated every timeslot.
     for i = 1:length(CritArea.Users)
      CritArea.Users(i).ActionProbs = (1/length(EscRts))*ones(1,length(EscRts));
        for k =1:NumEscRts
            CritArea.Users(i).RewardProbs(k) = EscRts(k).EvacRate/((distance(CritArea.Users(i),EscRts(k))).^2);
        end
     end
    length(CritArea.Users)
     minConvergence = 0;
     count = 0;
     %iterates until all users' cluster decisions have converged or  200
     %iterations, whichever comes first
   while minConvergence <.9 && count <= 200
       count = count +1;
       minConvergence = 1;
       %resets clusters
       for j = 1:length(EscRts) 
           EscRts(j).Cluster = [];                 
       end
       %randomly chooses routes for users based on action probability
       %distributions using randomize
      for k = 1:length(CritArea.Users) 
          chosenRoute = EscRts(randomize(CritArea.Users(k).ActionProbs));
           CritArea.Users(k).ChosenRoute = chosenRoute;
            for t = 1:length(EscRts)
                if t == chosenRoute.identity
                    EscRts(t).Cluster = [EscRts(t).Cluster CritArea.Users(k)]; 
                end
            end
      end
     
      %reward probability is updated for chosen route and action
      %probabilities are updated for all routes for the next iteration
      for l = 1:length(CritArea.Users)
        convergence = updateActionProbs('ful',CritArea.Users(l),EscRts);
        if convergence < minConvergence
            minConvergence = convergence;
            minConvMat(counter+1,count+1) = minConvergence; % minConvMat records minimum action prob value for the iteration
        end
      end
      if length(CritArea.Users(l).RewardProbs) == 5
          a=9;
      end

   end
    
   CritArea.Users = [];%Critical area is cleared as all users are in their final clusters  
  %The minority game is played for every route's cluster to determine the
  %go and not go groups, and  information including number of users,
  %evacuation rate, and QoS for every route is also updated.
  for j = 1:length(EscRts)
      EvacRate = EscRts(j).EvacRate;
      [returning, escapees] = minorityGame(EscRts(j));
      ClusterMat(counter+1,EscRts(j).identity) = length([returning escapees]); %records number in cluster for every timeslot
      EscapeeMat(counter+1,EscRts(j).identity) = length(escapees); %records how many have escaped the critical area to each escape route every timeslot
      MGCapMat(counter+1,EscRts(j).identity) = EscRts(j).MGCap; %records threshold used in the minority game for each escape route every timeslot
      CritArea.Users = [CritArea.Users returning];
      %Evacuation rate is updated, if the set of users in the route is
      %empty, it does not update to prevent the EvacRate from getting too
      %large.
      if length(EscRts(j).Users) > 0
          EscRts(j)=calcRate(EscRts(j));           
      end
       EvacRateMat(counter+1,j) = EscRts(j).EvacRate;
       %Users in the route is updated; first, the escapees are moved to the
       %route. Second, a number of users are removed from the route
       %according to the evacRate PRIOR to update in the 'ifelse statement'
             EscRts(j).Users = [ EscRts(j).Users escapees]; 
       if length(EscRts(j).Users) > EvacRate
            Escaped = [Escaped  EscRts(j).Users(1:EvacRate)];
            EscRts(j).Users(1:EvacRate) = [];           
       else %prevents out of index errors when the number of users in a route does not exceed the EvacRate.
           Escaped = [Escaped  EscRts(j).Users];
          EscRts(j).Users = []; 
       end
       RouteUsersMat(counter+1, j) = length(EscRts(j).Users);
       %QoS is updated for every route
       if EscRts(j).Cap >= length(EscRts(j).Users)
           LiveQoS = 0.1 +((EscRts(j).Cap - length(EscRts(j).Users))/EscRts(j).Cap);
            EscRts(j).QoS =EscRts(j).QoS+ LiveQoS;
       else
            LiveQoS = 0.1;
            EscRts(j).QoS = EscRts(j).QoS +LiveQoS;
       end
        QoSMat(counter+1,EscRts(j).identity) = EscRts(j).QoS; 
         
  end
counter = counter + 1

end
plot(1:counter,QoSMat); %Quote of service is plotted 
