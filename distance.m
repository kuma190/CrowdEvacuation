function d = distance(User,EscRt)
%DISTANCE Calculates distance using distance formula
%   Parameters: User object and EscRt object; extracts coodinates.
%Returned: distance between two objects' coordinates.
d = sqrt((User.X-EscRt.X).^2 +(User.Y-EscRt.Y).^2);

end

