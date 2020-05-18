%% Dishwashers survey -- data fitting
clear, clc, close all

file = '../survey/Dishwashers Survey_17 May 2020_16.20.csv';

opts = detectImportOptions(file);
opts.VariableDescriptionsLine = 2;

% set yes/no questions to categorical type
opts = setvartype(opts,{'Q11','Q13'},'categorical') ;

d = readtable(file,opts);

%% histogram

figure
hold on
histogram(d.Q2_1,'Normalization','probability')
boxplot(d.Q2_1,'Positions',0.19,'Orientation','Horizontal','Colors','g','Widths',0.01)
ax = gca;
ax.YAxis.TickValues = 0:0.05:0.2;
ax.YAxis.TickLabelsMode = 'auto';
ax.YAxis.Limits = [0 0.2];

% fit skew normal
fit.Q2_1 = fitdist(d.Q2_1,'EpsilonSkewNormal');

sampleRes.Q2_1 = 0:0.2:15;
fitVals.Q2_1 = pdf(fit.Q2_1,sampleRes.Q2_1);
plot(sampleRes.Q2_1,fitVals.Q2_1,'LineWidth',2)