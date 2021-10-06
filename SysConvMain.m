%NonConvMain: Main script that does not depend on the convergence of users'
%action probabilities to make clusters. The action probabilites are updated
%only once in a timeslot, after the reward probability has been updated.
%The program ends after the Critical Area has been cleared.

%initialization of variables
NumUsers = 2000;
NumEscRts = 5;
Length = 500;
width = 500;
EscRts = EscRt.empty(0,NumEscRts); 
CritArea = CriticalArea;
CritArea.Users = User.empty(0,NumUsers);

EscapeeMat = [];
%Matrices that store how important variables change in the program
QoSMat = []; %cumulative QoS every timeslot
%ActionProbMat = [];
EvacRateMat = []; %stores evacuation rate of every escape route each timeslot
RouteUsersMat = []; 
CritAreaMat = []; %stores size of crit area after every tmeslot
UsersMat = []; %Stores coordinates of all users
MGCapMat = [];
Escaped = []; %Stores user objects who have exited the simulation
nCumQoS = []; %Stores QoS of every timeslot
ClusterMat = []; %Stores size of cluster after every timeslot

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
    CritArea.Users(i).ActionProbs = (1/length(EscRts))*ones(1,length(EscRts));
    for k =1:NumEscRts
        CritArea.Users(i).RewardProbs(k) = EscRts(k).EvacRate/((distance(CritArea.Users(i),EscRts(k))).^2);
    end
end

convergence = 0;
counter = 0
%this while loop encompasses stochastic learning automata, the minority
%game, and updating information. It ends when the CritArea empties.
while isempty(CritArea.Users) == 0
     CritAreaMat(counter+1,:) = length(CritArea.Users);
     % a route for every user based on its action prob distributions using randomize().
   for i = 1:length(CritArea.Users)
       chosenRoute = EscRts(randomize(CritArea.Users(i).ActionProbs));
       CritArea.Users(i).ChosenRoute = chosenRoute;
        for j = 1:length(EscRts)
            if j == chosenRoute.identity
                EscRts(j).Cluster = [EscRts(j).Cluster CritArea.Users(i)]; 
            end  
        end 
   end
   %Critical Area is cleared as all users are in clusters. 
   %Minority game is played to determine go and not go groups for each
   %escape route
    CritArea.Users = [];
    for j = 1:length(EscRts)
      EvacRate = EscRts(j).EvacRate; %used when removing users from route
      [returning, escapees] = minorityGame(EscRts(j));
      ClusterMat(counter+1,EscRts(j).identity) = length([returning,escapees]); %Stores number of users in route's cluster in matrix
      EscapeeMat(counter+1,EscRts(j).identity) = length(escapees); %records how many have escaped the critical area to each escape route every timeslot
    MGCapMat(counter+1,EscRts(j).identity) = EscRts(j).MGCap; %Stores minority game threshold for every timeslot
      CritArea.Users = [CritArea.Users returning]; %not go group is returned to critical area
      %Evacuation rate is updated, if the set of users in the route is
      %empty, it does not update to prevent the EvacRate from getting too
      %large.
       if length(EscRts(j).Users) > 0
          EscRts(j)=calcRate(EscRts(j));           
      end
       EvacRateMat(counter+1,j) = EscRts(j).EvacRate;
       
       %Users in the route is updated; first, the escapees are moved to the
       %route. Second, a number of users are removed from the route
       %according to the evacRate PRIOR to update
             EscRts(j).Users = [ EscRts(j).Users escapees]; 
       if length(EscRts(j).Users) > EscRts(j).EvacRate 
            Escaped = [Escaped  EscRts(j).Users(1:EvacRate)];
            EscRts(j).Users(1:EvacRate) = [];
       else %prevents out of index errors when the number of users in a route does not exceed the EvacRate.
           Escaped = [Escaped  EscRts(j).Users];
          EscRts(j).Users = []; 
       end
       RouteUsersMat(counter+1, j) = length(EscRts(j).Users); %Stores users in route for every timeslot
       %Qoute of Service is updated
       if EscRts(j).Cap >= length(EscRts(j).Users) 
           LiveQoS = 0.1 +((EscRts(j).Cap - length(EscRts(j).Users))/EscRts(j).Cap);
            EscRts(j).QoS =EscRts(j).QoS+ LiveQoS;
       else
            LiveQoS = 0.1;
            EscRts(j).QoS = EscRts(j).QoS +LiveQoS;
       end
        QoSMat(counter+1,EscRts(j).identity) = EscRts(j).QoS; %Stores cumulative QoS for each route
        nCumQoS(counter+1,EscRts(j).identity) = LiveQoS; %Stores QoS for each timeslot independently
  end
%Action probabilities and reward probabilities are updated for every user
  for k = 1:length(CritArea.Users)
    convergence = updateActionProbs('non',CritArea.Users(k),EscRts);   
  end
convergence;
counter = counter + 1

end
plot(1:counter,QoSMat) %plots cumulative QoS for all routes

QoSAnalysis = [];
ClusterAnalysis = [];
for v = 1:counter
    for e = 1:NumEscRts
        QoSAnalysis(v,e) = QoSMat(v,e)/(sum(QoSMat(v,:)));
        ClusterAnalysis(v,e) = ClusterMat(v,e)/(sum(ClusterMat(v,:)));
    end
end
