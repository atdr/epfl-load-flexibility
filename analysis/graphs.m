%% Dishwashers survey -- data analysis
clear, clc, close all

file = '../survey/Dishwashers Survey_17 May 2020_16.20.csv';

opts = detectImportOptions(file);
opts.VariableDescriptionsLine = 2;

% set yes/no questions to categorical type
opts = setvartype(opts,{'Q11','Q13'},'categorical') ;

d = readtable(file,opts);

%% runs per week

figure
boxplot([d.Q2_1 d.Q4_1 d.Q4_2],'Labels',{'Total','On weekdays','On weekends'})
title('Dishwasher runs per week')
figExport(12,8,'dishwasher-runs')

%% time of runs -- weekday / weekend

v_label = {'weekday', 'weekend'};
v_prefix = {'x1', 'x3'};
for j = 1:numel(v_prefix)
    v = v_prefix{j};
    figure
    boxplot([d.([v '_Q7_1']) d.([v '_Q8_1']) d.([v '_Q8_2'])],'Labels',{'Most common time','Earliest usual time','Latest usual time'})
%     ylim([0 24])
    title(sprintf('Dishwasher run times on %ss',v_label{j}))
    figExport(12,8,['dishwasher-times-' v_label{j}])
end

%% pie charts for yes/no questions

v_name = {'Q11' 'Q13'};
for j = 1:numel(v_name)
    v = v_name{j};
    figure
    pie(d.(v))
%     title(d.Properties.VariableDescriptions{v})
%     title(multilineText(d.Properties.VariableDescriptions{v},5))
    figExport(6,3,['categorical-' v])
end

%% flex times -- no discount

figure
boxplot([d.Q12_1 d.Q12_2],'Labels',{'Earliest start','Latest start'})
title('Timing flexibility - no discount')
figExport(12,8,'flex-0')
