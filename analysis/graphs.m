%% Dishwashers survey -- data analysis
clear, clc, close all

file = '../survey/Dishwashers Survey_17 May 2020_16.20.csv';

opts = detectImportOptions(file);
opts.VariableDescriptionsLine = 2;

d = readtable(file,opts);

%% runs per week

figure
boxplot([d.Q2_1 d.Q4_1 d.Q4_2],'Labels',{'Total','On weekdays','On weekends'})
title('Dishwasher runs per week')
figExport(12,8,'dishwasher-runs')

%% time of runs -- weekday / weekend

t_label = {'weekday', 'weekend'};
t_prefix = {'x1', 'x3'};
for j = 1:numel(t_prefix)
    t = t_prefix{j};
    figure
    boxplot([d.([t '_Q7_1']) d.([t '_Q8_1']) d.([t '_Q8_2'])],'Labels',{'Most common time','Earliest usual time','Latest usual time'})
%     ylim([0 24])
    title(sprintf('Dishwasher run times on %ss',t_label{j}))
    figExport(12,8,['dishwasher-times-' t_label{j}])
end
