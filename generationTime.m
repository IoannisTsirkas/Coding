function [expFit] = generationTime(dataArray)
% Finds generation time for microorganism growth by fitting an exponential
%   function to experimental growth data. Plots growth curves.
% Input is an array with time points in the first column,
%   and optical density of samples (or some other indicator of 
%   microorganism abundance) in the other columns. Any number of samples
%   can be given at once.
% Output is an array with one row for each sample, corresponding to the
%   fitted parameters. The first parameter is the initial OD, and the
%   second is the generation time.

life = @(p,t) p(1)*2.^(t/p(2)); 
% This is the definition of life - an exponential doubling function.

roughlyEstimatedGenerationTime = 1;
% A rough estimation of what the generation time might be, used as an
%   initial parameter for the fitting. Play with this if the fitting
%   doesn't work well.

expFitTCoords = dataArray(1,1):(dataArray(end,1)-dataArray(1,1))/1000:dataArray(end,1);

for i=2:(size(dataArray,2))

    initialParameters(i-1,1) = dataArray(1,i);
    initialParameters(i-1,2) = roughlyEstimatedGenerationTime;

    expFit(i-1,:) = nlinfit(dataArray(:,1),dataArray(:,i),life,initialParameters(i-1,:));
    
    expFitYCoords(:,i-1) = life(expFit(i-1,:),expFitTCoords);
    
    legendTitles{i-1} = ['Sample ',num2str(i-1)];
    
end

figure;   
plot(dataArray(:,1),dataArray(:,2:end),'o');
line(expFitTCoords,expFitYCoords);    
xlabel('Time');
ylabel('OD(600nm)');
legend(legendTitles,'Location','northwest');

end