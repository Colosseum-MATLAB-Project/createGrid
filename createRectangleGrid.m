function [position, names] = createRectangleGrid (varargin) 
% Project Name: Creating rectangle grid for outdoor and indoor scenario  
%               
% File Name: createRectangleGrid.m
%
% Author: Miead Tehrani-Moayyed
% Work address: Wireless Networks and System Lab  
% Northeastern University, 360 Huntington Ave. Boston, MA 02115
% email: tehranimoayyed.m@northeastern.edu
% Last revision: 1-Nov-2021
%
% This function creates a rectangle grid using four control points as the
% rectangle vertices.
%
% Properties:
%   
%   CoordinateSystem: 'geographic' for outdoor or 'cartesian' for indoor
%   Latitudes       - latitudes array for the control points
%   Longitudes      - longitudes array the control points
%   Positions:      - cartesian coordinates for indoor control points defines as
%                     a 3 by 4 matrix with the format [x1,x2..;y1,y2..;z1,z2..]
%   Spacing:        - grid element spacing
%
% Outputs
%   position         
%                   - For geographic coordinates
%                       position.lats: grid points latitudes
%                       position.lons: grid points longitudes
%                   - For cartesian coordinates includes [x;y;z]
%   names           - grid points name including the location tag in row and column
%
%   Examples
%   Example 1: Creating a grid in an outdoor scenario
%        [positions, names] = createRectangleGrid('CoordinateSystem','geographic',...
%                             'Latitudes', [42.340257, 42.340487, 42.339876, 42.340100],...
%                             'Longitudes',[-71.088774, -71.088241, -71.088474, -71.087960 ],...
%                             'Heights', [2, 2, 2, 2],...
%                             'Spacing',7);
%
%
%   Example 2: Creating a grid in an indoor scenario
%         [positions, names] = createRectangleGrid ('CoordinateSystem',grid.controlPoints.coordinateSystem,...
%                             'Positions', [-1,1,-1,1;1,1,-1,-1;.85,.85,0.85,.85],...
%                               'Spacing', 0.25);

%
%
% ------------- BEGIN CODE --------------

defaultGridLatitudes = [42.340257, 42.340487, 42.339876, 42.340100];
defaultGridLongitudes = [-71.088774, -71.088241, -71.088474, -71.087960 ];
defaultGridHeights = [2, 2, 2, 2];
defaultIndoorPosition = [-1,1,-1,1;1,1,-1,-1;.85,.85,0.85,.85];

p = inputParser;
validGeoCtrlPts = @(x) isnumeric(x) && isvector(x) && (numel(x) == 4);
addOptional(p,'CoordinateSystem','geographic', @(x) ischar(x) && (strcmp(x,'geographic') || strcmp(x, 'cartesian')))
addOptional(p,'Latitudes', defaultGridLatitudes, validGeoCtrlPts )  % Quadrant in NU campus as default
addOptional(p,'Longitudes', defaultGridLongitudes, validGeoCtrlPts)   
addOptional(p,'Heights', defaultGridHeights, validGeoCtrlPts)   
addOptional(p,'Positions', defaultIndoorPosition, @(x) isnumeric(x) && ismatrix(x) && sum(size(x) == [3,4] )==2 ), 
addOptional(p,'Spacing',1, @(x) isscalar(x) && (x>0));

parse(p,varargin{:});

grid.controlPoints.coordinateSystem = p.Results.CoordinateSystem;
grid.controlPoints.lats = p.Results.Latitudes;
grid.controlPoints.lons = p.Results.Longitudes;
grid.controlPoints.heights = p.Results.Heights;
grid.controlPoints.positions = p.Results.Positions;
grid.spacing = p.Results.Spacing;

if strcmpi(grid.controlPoints.coordinateSystem,'geographic')
    % Define grid control points as the sites
    grid_ctrlPts = rxsite("Latitude",grid.controlPoints.lats, ...
        "Longitude",grid.controlPoints.lons, ...
        "AntennaHeight",grid.controlPoints.heights);

    % Calculate parameters for obtaining grid point location
    Xaz = angle(grid_ctrlPts(1),grid_ctrlPts(2));
    %Yaz = angle(grid_ctrlPts(1),grid_ctrlPts(3));
    Xdist = distance(grid_ctrlPts(1),grid_ctrlPts(2));
    Ydist = distance(grid_ctrlPts(1),grid_ctrlPts(3));
    XnSensor = floor(Xdist/grid.spacing);
    YnSensor = floor(Ydist/grid.spacing);

    % Calculkate grid element location
    latsm = nan(YnSensor,XnSensor);
    lonsm = nan(YnSensor,XnSensor);
    namesm = strings(YnSensor,XnSensor);
    for Yidx = 0:YnSensor
        for Xidx = 0:XnSensor
            d = sqrt( (Xidx^2 + Yidx^2) * grid.spacing^2 );
            az = Xaz - atand( Yidx/Xidx );
            if d == 0   % handle divided by zero for the y,x=0  
                az = 0;
            end

            [latsm(Yidx+1,Xidx+1),lonsm(Yidx+1,Xidx+1)] = location(grid_ctrlPts(1),d,az);
            namesm(Yidx+1,Xidx+1) = sprintf(" S%d,%d",Yidx,Xidx);
        end

    end

    % Convert grid points matrix to array to be used for Rx/Tx site decleration
    position.lats = latsm(:);
    position.lons =lonsm(:);
    names = namesm(:);

elseif strcmpi(grid.controlPoints.coordinateSystem,'cartesian')
    % Define grid control points as the indoor sites
    grid_ctrlPts = rxsite("cartesian","AntennaPosition",grid.controlPoints.positions);

    % Calculate parameters for obtaining grid point location
    Xaz = angle(grid_ctrlPts(1),grid_ctrlPts(2));
    %Yaz = angle(grid_ctrlPts(1),grid_ctrlPts(3));
    Xdist = distance(grid_ctrlPts(1),grid_ctrlPts(2));
    Ydist = distance(grid_ctrlPts(1),grid_ctrlPts(3));
    XnSensor = floor(Xdist/grid.spacing);
    YnSensor = floor(Ydist/grid.spacing);

    % Calculkate grid element location
    Xsm = nan(YnSensor,XnSensor);
    Ysm = nan(YnSensor,XnSensor);
    Zsm = nan(YnSensor,XnSensor);
    namesm = strings(YnSensor,XnSensor);
    for Yidx = 0:YnSensor
        for Xidx = 0:XnSensor
            d = sqrt( (Xidx^2 + Yidx^2) * grid.spacing^2 );
            az = Xaz - atand( Yidx/Xidx );
            if d == 0   % handle divided by zero for the y,x=0  
                az = 0;
            end
                
            Xsm(Yidx+1,Xidx+1) = grid_ctrlPts(1).AntennaPosition(1) + d * cosd(az);
            Ysm(Yidx+1,Xidx+1) = grid_ctrlPts(1).AntennaPosition(2) + d * sind(az);
            Zsm(Yidx+1,Xidx+1) = grid_ctrlPts(1).AntennaPosition(3);
            namesm(Yidx+1,Xidx+1) = sprintf(" S%d,%d",Yidx,Xidx);
        end

    end

    % Convert grid points matrix to array to be used for Rx/Tx site decleration
    Xs = Xsm(:);
    Ys = Ysm(:);
    Zs = Zsm(:);

    position = [Xs';Ys';Zs'];
    names = namesm(:);
end

end