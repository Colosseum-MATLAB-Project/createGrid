% Project Name: Demonstrating rectangle grid for indoor propagation scenarios  
%               
% File Name: gridDemoOutdoor.m
%
% Author: Miead Tehrani-Moayyed
% Work address: Wireless Networks and System Lab  
% Northeastern University, 360 Huntington Ave. Boston, MA 02115
% email: tehranimoayyed.m@northeastern.edu
% Last revision: 1-Nov-2021
%
% This script demonstrates a rectangle grid in a conference room on top of
% the table to characterize the channel of possible transceivers

%% Configuration
% Define grid parameters
grid1.scenarioFile = "conferenceroom.stl";
grid.controlPoints.coordinateSystem = 'cartesian';
grid.controlPoints.positions =[-0.5,0.5,-0.5,0.5;0.5,0.5,-0.5,-0.5;.8,.8,0.8,.8];
grid.spacing = .25;

%% Process section
% Indoor Scenario
viewer = siteviewer("SceneModel","conferenceroom.stl");

pause(5)

% Recognize the grid control points
ctrlPts = txsite(grid.controlPoints.coordinateSystem, ...   
    "AntennaPosition",grid.controlPoints.positions);
    
show(ctrlPts,'ShowAntennaHeight', false)

pause(5)
clearMap(viewer)

% Create rectangle grid
[positions, names] = createRectangleGrid ('CoordinateSystem',grid.controlPoints.coordinateSystem,...
                     'Positions', grid.controlPoints.positions,...
                      'Spacing', grid.spacing);

% show grid elements
rx = rxsite(grid.controlPoints.coordinateSystem, ...
    "Name",names,...
    "AntennaPosition",positions);
    
show(rx,'ShowAntennaHeight', false)