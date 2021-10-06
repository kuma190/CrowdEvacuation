classdef EscRt <handle
    %ESCAPEROUTE handle class that stores information unique to an escape
    %route
    %   Two methods: 
    %constructor method: coordinates, identity, Capacity, and
    %   Evacuation Rate needed to construct EscRt object.
    %calcRate(): used to calculate the Evacuation rate for the next
    %timeslot. It is an EscRt in built function because it only uses EscRt
    %properties from a single object to calculate.
    
    properties
        Users %Vector of user objects
        QoS = 1
        Cap
        X %X coordinate
        Y% Y coordinate
        identity
        EvacRate
        Cluster
        MGCap %threshold used for the minority game 
        
        
    end
    
    methods
        function R = EscRt(X,Y,identity,Cap,EvacRate)
            R.identity = identity;
                R.Cap = Cap;
                R.MGCap = Cap;
                R.X = X;
                R.Y = Y;
                R.EvacRate = EvacRate;
                
                
                
          
        end
        function obj = calcRate(obj)
             obj.EvacRate = ceil((obj.EvacRate * obj.Cap)./(1+length(obj.Users))); %comment this line out for deterministic evacrate
            %obj.EvacRate = obj.EvacRate; %comment this out for dynamic
        end
       
            
    end
    
end

