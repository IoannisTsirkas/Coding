%% LordOfTheRingsTryout
clear;
clc;
Folder   = 'C:\Users\totex\Desktop\Analysis\dotquant\nup';
FileList = dir(fullfile(Folder, '**', '*.tif'));
matOfMeans = nan(1000,numel(FileList));
matOfMedians = nan(1000,numel(FileList));
radiiOfEachCell = nan(1000,numel(FileList));
cellArr = {1:numel(FileList)};
boundariesForEachK = {{1:numel(FileList)}};
for iFile =1:numel(FileList)
    thisFolder = FileList(iFile).folder;
    thisFile   = FileList(iFile).name;
    File       = fullfile(thisFolder, thisFile);
    img = imread(File);
    img = img(20:1180, 20:1180);
    figure;

    %find circles in the image
    
    [centers,radii] = imfindcircles(img,[3 40],...%default parameters are 6 and 40
      'Sensitivity',0.95); %,... % default sensitivity os 0.85
      
    imshow(img,[]);% show image
    hold on % plot on the image over and over
    centers=round(centers); %round the centers and the radius
    radii = round(radii);
       for k = 0:2 %k is a variable for each layer(starting from outer layer inside)
       mask = createCirclesMask(img,centers,radii-k); %create a mask for each cell for each layer
       boundaries = bwboundaries(mask); %define the boundaries for each cell
       boundariesForEachK{k+1} = cell(boundaries); %put boundaries for each k in cell
       end
        wrapperCell = cell(1,length(boundariesForEachK{1})); %initialize wrapper cell
        intenCell = nan(50,3); %initialize intensity cell
        meanOfEachCell = zeros(length(wrapperCell),1); %initialize variable for mean intensity for each cell
        medianOfEachCell = zeros(length(wrapperCell),1);
        
       %find the intensity for each cell
       
       for  i =  1:length(boundariesForEachK{1})
            for j = 1:3 %for every layer
                thisBoundary = boundariesForEachK{j}(i,1);
                x = thisBoundary{1}(:,2);
                y = thisBoundary{1}(:,1);
                plot(x, y, 'g', 'LineWidth', 2);
                inten=nan(length(thisBoundary),1);
                for p=1:length(thisBoundary{1})-1
                    inten(p) = img(thisBoundary{1}(p,1),thisBoundary{1}(p,2));
                    intenCell(p,j) = inten(1,p);
                    wrapperCell{i} = intenCell(:,:);
                end
            end
            
            
       % calculate the mean of intensities from each layer for every cell
       
             
                wrapperCell{i} = wrapperCell{i}(~isnan(wrapperCell{i}));
                meanOfEachCell(i,1) = mean(wrapperCell{i});
                medianOfEachCell(i,1) = median(wrapperCell{i});
                
                
       end
       
            radiiOfEachCell(1:i,iFile) = radii(1:i,1);
            matOfMeans(1:length(boundariesForEachK{1}),iFile) = meanOfEachCell(1:length(boundariesForEachK{1}));
            matOfMedians(1:length(boundariesForEachK{1}),iFile) = medianOfEachCell(1:length(boundariesForEachK{1}));
            
            
       
       
       % export to an excel file
       
        cellArr(1,iFile) = cellstr(thisFile);
        cellArr2(1:i,iFile) = num2cell(meanOfEachCell(1:i,1));
        cellArr3(1:i,iFile) = num2cell(medianOfEachCell(1:i,1));
        cellArr4(1:1000,iFile) = num2cell(radiiOfEachCell(1:1000,iFile));

       
end
hold off
finalCell = [cellArr;cellArr2];
filename ='ringsIntensities.xlsx';
xlswrite(filename,finalCell); %first sheet in the new excel file has the mean values for each cell
finalCell = [cellArr;cellArr3];
xlswrite(filename,finalCell,2); %second sheet in the new excel file has the median values for each cell
finalCell = [cellArr;cellArr4];
xlswrite(filename,finalCell,3); %third sheet in the new excel file has the radii for each cell
%% 
function mask = createCirclesMask(varargin)
narginchk(3,3)
if numel(varargin{1}) == 2
	% SIZE specified
	xDim = varargin{1}(1);
	yDim = varargin{1}(2);
else
	% IMAGE specified
	[xDim,yDim] = size(varargin{1});
end
centers = varargin{2};
radii = varargin{3};
xc = centers(:,1);
yc = centers(:,2);
[xx,yy] = meshgrid(1:yDim,1:xDim);
mask = false(xDim,yDim);
for ii = 1:numel(radii)
	mask = mask | hypot(xx - xc(ii), yy - yc(ii)) <= radii(ii);
end
end



