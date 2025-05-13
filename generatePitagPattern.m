function [pts2d] = generatePitagPattern(AB0, AC0, AB1, AC1 )
%GENERATEPITAGPATTERN Generates the pattern for a unit Pitag 
%   AB0, AC0, AB1, AC1
% Bergamasco, Filippo, Andrea Albarelli, and Andrea Torsello. 
% "Pi-tag: a fast image-space marker design based on projective invariants."
% Machine vision and applications 24, no. 6 (2013): 1295-1310.
%%

pts2d = [0 0;
    AB0 0; 
    AC0 0;
    1 0;
    0 AB0;
    0 AC0;
    0 1;
    AB1 1;
    AC1 1;
    1 AB1;
    1 AC1;
    1 1]';


%figure(1234);
%scatter(pts2d(1, :), pts2d(2, :))
%xlim([-0.5 1.5])
%ylim([-0.5 1.5])
%axis equal;

end

