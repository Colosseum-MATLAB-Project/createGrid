% Project Name: Demonstrating rectangle grid for outdoor propagation scenarios  
%               
% File Name: gridDemoOutdoor.m
%
% Author: Miead Tehrani-Moayyed
% Work address: Wireless Networks and System Lab  
% Northeastern University, 360 Huntington Ave. Boston, MA 02115
% email: tehranimoayyed.m@northeastern.edu
% Last revision: 1-Nov-2021
%

%% Configuration
% Define grid parameters
grid1.scenarioFile = "NUcampus.osm";
grid1.controlPoints.coordinateSystem = 'geographic';
grid1.controlPoints.lats = [42.340257, 42.340487, 42.339876, 42.340100];
grid1.controlPoints.lons = [-71.088774, -71.088241, -71.088474, -71.087960 ];
grid1.controlPoints.heights = [2, 2, 2, 2];
grid1.spacing = 7;

grid2.scenarioFile = "downtownBoston.osm";
grid2.controlPoints.coordinateSystem = 'geographic';
grid2.controlPoints.lats = [42.35671, 42.356943, 42.35599, 42.356268];
grid2.controlPoints.lons = [-71.05632, -71.055719, -71.05592, -71.055211 ];
grid2.controlPoints.heights = [2, 2, 2, 2];
grid2.spacing = 10;

grid3.scenarioFile = "downtownBoston.osm";
grid3.controlPoints.coordinateSystem = 'geographic';
grid3.controlPoints.lats = [42.35678, 42.3571, 42.35548, 42.3559];
grid3.controlPoints.lons = [-71.05694, -71.05541, -71.05659, -71.05477 ];
grid3.controlPoints.heights = [2, 2, 2, 2];
grid3.spacing = 15;


gridDemo(grid1);

pause(10)

gridDemo(grid2)

pause(10)

gridDemo(grid3)

%% Process section
function gridDemo (grid)
% Outdoor scenario
viewer = siteviewer("Buildings",grid.scenarioFile,"Basemap","satellite");

pause (5)

% Recognize the grid control points
ctrlPts = txsite(grid.controlPoints.coordinateSystem, ...   
    "Latitude",grid.controlPoints.lats,...
    "Longitude",grid.controlPoints.lons,...
    "AntennaHeight",grid.controlPoints.heights(1));
    
show(ctrlPts,'ShowAntennaHeight', false,...
    'Icon','pin.png',...
    'IconSize',[12 30])

pause (5)

clearMap(viewer)

% Create rectangle grid
[positions, names] = createRectangleGrid('CoordinateSystem',grid.controlPoints.coordinateSystem,...
                     'Latitudes', grid.controlPoints.lats,...
                     'Longitudes',grid.controlPoints.lons,...
                     'Heights', grid.controlPoints.heights,...
                     'Spacing',grid.spacing);

% show grid elements
rxs = rxsite('Name', names,...
       'Latitude',positions.lats,...
       'Longitude',positions.lons, ...
       "AntennaHeight",grid.controlPoints.heights(1));

show(rxs,'ShowAntennaHeight', false)

end
