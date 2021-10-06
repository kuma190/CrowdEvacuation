function [returningUsers, Escapees] = minorityGame(Route )
%MINORITYGAME This function determines if the actual minority game should
%be used.
% Parameters: an EscRt object.
%Returned:  two vectors of User objects, one meant to be appended to the CritArea in MAIN,
%other to be appended to the Escaped vector in MAIN
%Other actions: the Route cluster is cleared of users.

cap = Route.Cap;
numRoute = length(Route.Users);
numCluster = length(Route.Cluster);
%When the capacity exceeds the users in a route by as much as
% the number in the cluster or more, the minority game is not needed and all users
% can escape.
if  cap - numRoute >= numCluster
    a = [];
    b = Route.Cluster;  
    
end
 %When the
%capacity exceeds the users by less than the size of the cluster,
%goOrNotGo() is used.
if ((cap - numRoute > 0) && (cap - numRoute < numCluster))
    MGCap = cap - numRoute;
    Route.MGCap = MGCap;
    [a,b] = goOrNotGo(MGCap, Route.Cluster);
   
end
 %When the users exceeds capacity, there is no more space in
% the route and the entire cluster is returned to the CritArea.
if cap - numRoute <= 0
    a = Route.Cluster;
    b= [];
end

Route.Cluster = [];
returningUsers = a;
Escapees = b;
end

