function cfg = defaultConfig(dataset)
%DEFAULTCONFIG Default configuration for computation of features, textons, etc.
%   cfg = DEFAULTCONFIG(dataset)
%   The returned structure contains the definitions for various properties used
%   throughout the program, namely the dimensions of the dataset's images, the
%   range of the depth data, and parameters for the computed features

cfg.dataset = dataset;

limitSize = false; %true;

% read image resolution from the first image in the training set
[imgFile,depthFile] = dataFilePaths(cfg.dataset,1);
imgInfo = imfinfo(imgFile);
% image height and width in pixels
cfg.size = [imgInfo.Height imgInfo.Width];
maxHeight = 800;
if limitSize && cfg.size(1) > maxHeight
    cfg.size = round(maxHeight*[1 cfg.size(2)/cfg.size(1)]);
end
cfg.height = cfg.size(1);
cfg.width = cfg.size(2);

% camera range
if ~isempty(strfind(dataset,'Make3D'))
    range = [0.9200 81.9214];
elseif ~isempty(strfind(dataset, 'NYU'))
    range = [0.7133 9.9955];
elseif ~isempty(strfind(dataset, 'ZED'))
    range = [1 20];
elseif ~isempty(strfind(dataset, 'HEIGHT'))
    range = [0.0 4.0];
else
    range = [1 100];
end
cfg.minRange = range(1);
cfg.maxRange = range(2);

% number of rows and columns in the depth map and patch grid
depthInfo = imfinfo(depthFile);
cfg.mapSize = [depthInfo.Height depthInfo.Width];
maxHeight = 80;
if limitSize && cfg.mapSize(1) > maxHeight
    cfg.mapSize = round(maxHeight*[1 cfg.mapSize(2)/cfg.mapSize(1)]);
end
cfg.nRows = cfg.mapSize(1);
cfg.nCols = cfg.mapSize(2);
% total number of patches
cfg.nPatches = cfg.nRows*cfg.nCols;
cfg.stepSize = 20; % a step size of 1 leads to extracting features at all pixel locations
% height and width of each patch in pixels
cfg.ptcSize = 15*[1 1];
cfg.ptcSize = 2*floor(cfg.ptcSize/2)+1; % round up to neareset odd size
cfg.ptcHeight = cfg.ptcSize(1);
cfg.ptcWidth = cfg.ptcSize(2);

% color or grayscale textons
cfg.txtColor = false;
% height and width of the textons in pixels
cfg.txtSize = 5*[1 1];
cfg.txtHeight = cfg.txtSize(1);
cfg.txtWidth = cfg.txtSize(2);
% number of textons learned
cfg.nTextons = 30;
% number of texture samples extracted from each image
cfg.nTextures = 100000; % if nTextures = 'all', extract all possible samples

cfg.nHOGBins = 9;
cfg.nRadonAngles = 15;
cfg.nStructBins = 15;

% possible feature types: Coordinates, FiltersL1, FiltersL2, FiltersL4,
% HOG, Textons, Radon, StructTensor
possibleFeatures = {'Coordinates','Filters','HOG','Textons','Radon',...
                    'StructTensor'};
cfg.featureTypes = {'Coordinates','Filters','Textons','HOG','Radon'};
% boolean vector indicating features used
cfg.useFeatures = ismember(possibleFeatures,cfg.featureTypes);

% possible filter types: LawsMasks, CbCrLocalAverage, OrientedEdgeDetectors
cfg.possibleFilters = {'LawsMasks','CbCrLocalAverage','OrientedEdgeDetectors'};
cfg.filterTypes = {'LawsMasks','CbCrLocalAverage','OrientedEdgeDetectors'};
% cfg.filterTypes = {'LawsMasks','OrientedEdgeDetectors'}; % for B&W images
% boolean vector indicating filters used
cfg.useFilters = ismember(cfg.possibleFilters,cfg.filterTypes);
% dimensions of each filter group, in the above order
cfg.filterDims = [9;2;6];
% total number of filters
cfg.nFilters = dot(cfg.filterDims,cfg.useFilters);

% number of size scales at which filter features are calculated
cfg.nScales = 3;
% dimensions of each feature group, in the above order
featureDims = [2;2*cfg.nFilters*cfg.nScales;cfg.nHOGBins;cfg.nTextons;...
               2*cfg.nRadonAngles;cfg.nStructBins];
% total number of features
cfg.nFeatures = dot(featureDims,cfg.useFeatures);

cfg.outputType = 'regression'; % uncomment for regression
% cfg.outputType = 'classification'; % uncomment for classification

end
