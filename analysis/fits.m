%% Dishwashers survey -- data fitting
clear, clc, close all

file = '../survey/Dishwashers Survey_17 May 2020_16.20.csv';

opts = detectImportOptions(file);
opts.VariableDescriptionsLine = 2;

% set yes/no questions to categorical type
opts = setvartype(opts,{'Q11','Q13'},'categorical') ;

d = readtable(file,opts);

%% histogram + fit -- weekly runs

for q = {'Q2_1' 'Q4_1' 'Q4_2'}
    q = char(q);

    figure
    hold on
    histogram(d.(q),'Normalization','probability')

    % fit skew normal
    fit.(q) = fitdist(d.(q),'EpsilonSkewNormal');

    % calculate values using skew normal
    sampleRes.(q) = 0:15;
    fitVals.(q) = pdf(fit.(q),sampleRes.(q));
    
    plot(sampleRes.(q),fitVals.(q),'LineWidth',2)
    
    % format plot
    title({strrep(q,'_','\_') sprintf('\\theta = %2.1f, \\sigma = %2.1f, \\epsilon = %1.2f',fit.(q).Theta,fit.(q).Sigma,fit.(q).Epsilon)})

    figExport(7,5,['fit-' q])

%     % add boxplot for comparison (based on Q2_1)
%     boxplot(d.(q),'Positions',0.19,'Orientation','Horizontal','Colors','g','Widths',0.01)
%     ax = gca;
%     ax.YAxis.TickValues = 0:0.05:0.2;
%     ax.YAxis.TickLabelsMode = 'auto';
%     ax.YAxis.Limits = [0 0.2];
end

%% histogram + fit -- 24h time-series w/ loop

for q = {'x1_Q7_1' 'x1_Q8_1' 'x1_Q8_2' 'x3_Q7_1' 'x3_Q8_1' 'x3_Q8_2'}
    q = char(q);

    figure
    hold on
    histogram(d.(q),'Normalization','probability')

    % fit normal
    fit.(q) = fitdist(d.(q),'Normal');

    % calculate values using normal
    sampleRes.(q) = -12:36;
    fitVals.(q) = pdf(fit.(q),sampleRes.(q));
    
    % adjust values for 24h window
    sampleRes.(q) = mod(sampleRes.(q),24);
    fitVals.(q) = accumarray(sampleRes.(q)'+1,fitVals.(q));
        % +1 hack necessary to avoid 0 index
    sampleRes.(q) = 0:23;
    
    plot(sampleRes.(q),fitVals.(q),'LineWidth',2)
    
    % format plot
    title({strrep(q,'_','\_') sprintf('\\mu = %2.1f, \\sigma = %2.1f',fit.(q).mu,fit.(q).sigma)})
    ax = gca;
    ax.XAxis.TickValues = 0:6:24;
    ax.XAxis.Limits = [0 24];
    
    figExport(12,8,['fit-' q])
end
