function makeXLS(filename, trackData, flag)
% Recieves an excel file created by DotQuant and an array containing good 
%   tracks picked by hand. The first column of the array contains the
%   track number, and the second and third columns contain the starting and
%   ending times of the good part of the track, if desired.
% Creates an excel file with the raw data, the normalized data,
%   and the sigmoidal fit.

newFilename = strcat(filename, ' - Analysis.xlsx');
filename = strcat(filename, '.xlsx');
data = struct;

for i=1:size(trackData,1)
      
    data(i).input = cell(1);
    data(i).input = readcell(filename,'Sheet',['Track_' num2str(trackData(i,1))]);
    
    channelNames = split(data(i).input{1,1},'_');
    channel1Name = channelNames{2};
    channel2Name = channelNames{4};
     
    data(i).raw = cell2mat(data(i).input(4:end,1:2));
    data(i).raw(:,3) = cell2mat(data(i).input(4:end,7));
  
    if size(trackData,2) == 3
    
        data(i).selected = data(i).raw(((trackData(i,2)-data(i).raw(1,1)+1):(trackData(i,3)-data(i).raw(1,1)+1)),:);
 
    else 
      
        data(i).selected = data(i).raw;
      
    end
  
    data(i).norm(:,1) = data(i).selected(:,1)-data(i).selected(1,1)+1;
    data(i).norm(:,2) = 100*(data(i).selected(:,2)-min(data(i).selected(:,2)))/(max(data(i).selected(:,2))-min(data(i).selected(:,2)));
    data(i).norm(:,3) = 100*(data(i).selected(:,3)-min(data(i).selected(:,3)))/(max(data(i).selected(:,3))-min(data(i).selected(:,3)));
  
    [data(i).fitGreen, data(i).fitRed, data(i).fitCurves] = autoFitter2(data(i).norm);
  
    data(i).fitGreen(4) = data(i).fitGreen(4)+data(i).selected(1,1)-1;
    data(i).fitRed(4) = data(i).fitRed(4)+data(i).selected(1,1)-1;
  
    sheetName = ['Track_', num2str(trackData(i,1)), ' (', num2str(i), ')'];
    lastRow = num2str(size(data(i).selected,1)+1);
   
    writecell({'Time',channel1Name,channel2Name,[channel1Name 'Norm'],[channel2Name 'Norm'],[channel1Name 'Fit'],[channel2Name 'Fit']},newFilename,'Sheet',sheetName,'Range','A1:G1');
    writecell({[channel1Name ' Fit:'];[channel2Name ' Fit:']},newFilename,'Sheet',sheetName,'Range','I2:I3');
    writecell({'Minimum','Height','Slope','Midpoint'},newFilename,'Sheet',sheetName,'Range','J1:M2');
    writecell({'deltaT='},newFilename,'Sheet',sheetName,'Range','O3');
    writematrix([data(i).selected data(i).norm(:,2:3) data(i).fitCurves(:,2:3)],newFilename,'Sheet',sheetName,'Range',strcat('A2:G',lastRow));
    writematrix([data(i).fitGreen;data(i).fitRed],newFilename,'Sheet',sheetName,'Range','J2:M3');
    writematrix(data(i).fitRed(4)-data(i).fitGreen(4),newFilename,'Sheet',sheetName,'Range','P3');
  
end

if nargin == 3 & flag == "pair"
    
    for i=1:2:size(trackData,1)
    
        pairwiseDeltaT = data(i+1).fitRed(4)-data(i).fitGreen(4);
        writematrix(pairwiseDeltaT,newFilename,'Sheet',['Track_', num2str(trackData(i+1,1)), ' (', num2str(i+1), ')'],'Range','P3');
        
        channelNames = split(data(i).input{1,1},'_');
        channel1Name = channelNames{2};
        writecell({['(',channel1Name,' from previous sheet)']},newFilename,'Sheet',['Track_', num2str(trackData(i+1,1)), ' (', num2str(i+1), ')'],'Range','Q3');
        
    end
    
elseif nargin == 3 & flag == "cohesion"
    
    for i=1:2:size(trackData,1)
    
        pairwiseDeltaT = data(i+1).fitRed(4)-data(i).fitGreen(4);
        writematrix(pairwiseDeltaT,newFilename,'Sheet',['Track_', num2str(trackData(i+1,1)), ' (', num2str(i+1), ')'],'Range','P3');
        
        channelNames = split(data(i).input{1,1},'_');
        channel1Name = channelNames{2};
        writecell({['(',channel1Name,' from previous sheet)']},newFilename,'Sheet',['Track_', num2str(trackData(i+1,1)), ' (', num2str(i+1), ')'],'Range','Q3');
        writecell({['Two dots first seen (',channel1Name,'):'];['Two dots first seen (',channel2Name,'):'];'Mitosis:'},newFilename,'Sheet',['Track_', num2str(trackData(i+1,1)), ' (', num2str(i+1), ')'],'Range','R2:R4');
        
    end
        
end

end



function [fitGreen, fitRed, fittedCurves] = autoFitter2(data)
% Fits a logistic model to pre-defined dot intensity data, using non-linear
%   regression analysis. 
% The logistic model includes 4 parameters in the following order:
%   p(1): Intensity before the doubling event.
%   p(2): Height of the sigmoid curve.
%   p(3): Steepness of the sigmoid curve.
%   p(4): Mid-point of the sigmoid curve (along the x axis).
% Input: Quantification results for green and red dots, including only the 
%   relevant time points (before and after intensity doubling, not including 
%   cell division and such).

logistic = @(p,x) p(1)+p(2)./(1+exp(-p(3)*(x-p(4))));
% Definition of the logistic model.

greenParameters = [min(data(:,2)),(max(data(:,2))-min(data(:,2))),1,(size(data,1)/2)];
redParameters = [min(data(:,3)),(max(data(:,3))-min(data(:,3))),1,(size(data,1)/2)];    
% Setting initial parameters for calculating the non-linear regression.

fitGreen = nlinfit(data(:,1),data(:,2),logistic,greenParameters);
% Non-linear regression analysis for the green channel data.

fitRed = nlinfit(data(:,1),data(:,3),logistic,redParameters);
% Non-linear regression analysis  for the red channel data.

fittedCurves(:,1) = data(:,1);
fittedCurves(:,2) = logistic(fitGreen, data(:,1));
fittedCurves(:,3) = logistic(fitRed, data(:,1));

end