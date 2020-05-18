%% Dishwashers survey -- data fitting
clear, clc, close all

file = '../survey/Dishwashers Survey_17 May 2020_16.20.csv';

opts = detectImportOptions(file);
opts.VariableDescriptionsLine = 2;

% set yes/no questions to categorical type
opts = setvartype(opts,{'Q11','Q13'},'categorical') ;

d = readtable(file,opts);

%% histogram + fit

for q = {'Q2_1' 'Q4_1' 'Q4_2'}
% for q = {'x1_Q7_1'}
    q = char(q);

    figure
    hold on
    histogram(d.(q),'Normalization','probability')

    % fit skew normal
    fit.(q) = fitdist(d.(q),'EpsilonSkewNormal');

    % plot skew normal
    sampleRes.(q) = 0:24;
    fitVals.(q) = pdf(fit.(q),sampleRes.(q));
    plot(sampleRes.(q),fitVals.(q),'LineWidth',2)
    
    title(q,'Interpreter','none')
    
    figExport(12,8,['fit-' q])

%     % add boxplot for comparison
%     boxplot(d.(q),'Positions',0.19,'Orientation','Horizontal','Colors','g','Widths',0.01)
%     ax = gca;
%     ax.YAxis.TickValues = 0:0.05:0.2;
%     ax.YAxis.TickLabelsMode = 'auto';
%     ax.YAxis.Limits = [0 0.2];
end
