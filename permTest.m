function permTest(filename,binWidth)
%Permutation test on multiple samples.
%Recieves the name of an Excel file, which contains data from each sample
%in a separate column, with a sample name at the top of each column.
%Creates a new Excel file, with general data about each sample (including
%mean, median and standard deviation), and significance tests for each pair
%of samples (including the differences in means and medians, and the
%P-values for mean- and median-based tests).

repNum = 1000000;
%Number of permutations tested.

filename = strcat(filename, '.xlsx');

rawData = readtable(filename);
%Read user selection from Excel file. First row contains sample names.
    
numOfSamples = size(rawData,2);
sampleNames = rawData.Properties.VariableNames;
%Sample names are converted to text even if they were numerical.
data = rawData.Variables;
%Data is extracted as a numerical array.

Ns = sum(~isnan(data));
means = mean(data,'omitnan');
medians = median(data,'omitnan');
stdevs = std(data,'omitnan');
sterrors = std(data,'omitnan')./sqrt(Ns);
%Calculate number of measurements, mean, median, sample standard deviation
%(n-1), and standard error of the mean for all samples.           

pairCounter = 0;
for i = 1:(numOfSamples-1)    
    for j = (i+1):numOfSamples
    %For every pair of samples in the data, run the permutation test.
    
        pairCounter = pairCounter+1;
        
        pairNames{pairCounter} = [sampleNames{i},'-',sampleNames{j}];
        %Every pair of samples gets a name.
        pairDeltaMeans(pairCounter) = abs(means(i)-means(j));
        pairDeltaMedians(pairCounter) = abs(medians(i)-medians(j));
        %Calculate the absolute differences in means and medians.
        
        firstSample = data(~isnan(data(:,i)),i);
        secondSample = data(~isnan(data(:,j)),j);
        concatenatedPair = [firstSample;secondSample];  
        %Discard NaN values, and create a new group containing all the 
        %values of the pair of samples. 
        
        randPairDeltaMeans = zeros(repNum,1);
        randPairDeltaMedians = zeros(repNum,1);
        %Initialization of variables.
        
        for k=1:repNum
           
            randomizedIndices = randperm(length(concatenatedPair));
            randomizationArray = [concatenatedPair,randomizedIndices'];
            randomizationArray = sortrows(randomizationArray,2);
            %Randomize the concatenated pair of samples.
            
            firstRandomizedGroup = randomizationArray(1:size(firstSample),1);
            secondRandomizedGroup = randomizationArray((size(firstSample)+1):end,1);
            %Divide back into two groups of the same sizes as the
            %original samples.
            
            randPairDeltaMeans(k) = abs(mean(firstRandomizedGroup)-mean(secondRandomizedGroup));
            randPairDeltaMedians(k) = abs(median(firstRandomizedGroup)-median(secondRandomizedGroup));
            %Calculate the absolute differences in means and medians for 
            %the randomized groups.
            
        end    
        
        meanPValues(pairCounter) = sum(randPairDeltaMeans >= pairDeltaMeans(pairCounter)) / repNum;
        medianPValues(pairCounter) = sum(randPairDeltaMedians >= pairDeltaMedians(pairCounter)) / repNum;
        %P-value for the pair is the probability a randomized pair would
        %have a similar or greater difference in mean/median.
        
    end
end

outputTable1 = cell(6,(numOfSamples+1));
outputTable1(1,2:(numOfSamples+1)) = sampleNames;
outputTable1(2:6,1) = {'n'; 'Mean'; 'Median'; 'St.Dev.'; 'SEM'};
outputTable1(2,2:(numOfSamples+1)) = num2cell(Ns);
outputTable1(3,2:(numOfSamples+1)) = num2cell(means);
outputTable1(4,2:(numOfSamples+1)) = num2cell(medians);
outputTable1(5,2:(numOfSamples+1)) = num2cell(stdevs);
outputTable1(6,2:(numOfSamples+1)) = num2cell(sterrors);

outputTable2 = cell(5,(pairCounter+1));
outputTable2(1,2:(pairCounter+1)) = pairNames;
outputTable2(2:5,1) = {'Mean Diff.'; 'Mean P-value'; 'Median Diff.'; 'Median P-value'};
outputTable2(2,2:(pairCounter+1)) = num2cell(pairDeltaMeans);
outputTable2(3,2:(pairCounter+1)) = num2cell(meanPValues);
outputTable2(4,2:(pairCounter+1)) = num2cell(pairDeltaMedians);
outputTable2(5,2:(pairCounter+1)) = num2cell(medianPValues);

writecell(outputTable1, filename, 'Sheet', 'Statistics', 'Range', 'A1');
writecell(outputTable2, filename, 'Sheet', 'Statistics', 'Range', 'A9');
%Create output tables and export to a new Excel file.

if nargin == 2  
    for i=1:numOfSamples    
        figure('Name',cell2mat(sampleNames(i)));
        h=histogram(data(:,i));
        h.BinWidth = binWidth;
    end
end
    
end