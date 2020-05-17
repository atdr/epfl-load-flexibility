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
data = [d.Q12_1 d.Q12_2];
boxplot(data,'Labels',{'Earliest start','Latest start'})
ylim([-12 12])
yticks(-12:6:12)
box off
n = min(sum(~isnan(data)));
title(sprintf('Timing flexibility - no discount (n = %d)',n))
figExport(12,8,'flex-0')

%% flex time -- with discount

discount = strsplit(num2str(10:10:40));
for j = 1:numel(discount)
    v = num2str(j);
    figure
    data = [d.(['x' v '_Q14_1']) d.(['x' v '_Q14_2'])];
    boxplot(data,'Labels',{'Earliest start','Latest start'})
    ylim([-12 12])
    yticks(-12:6:12)
    box off
    n = min(sum(~isnan(data)));
    title(sprintf('Timing flexibility - %s%% discount (n = %d)',discount{j},n))
    figExport(12,8,['flex-' discount{j}])
end

%% flex time -- xy plot

data = [];
% add no-discount data
data(:,:,1) = [d.Q12_1 d.Q12_2];
% add discount data
for j = 1:4
    v = num2str(j);
    data(:,:,j+1) = [d.(['x' v '_Q14_1']) d.(['x' v '_Q14_2'])];
end

discount = 0:0.1:0.4;
price = 1:-0.1:0.6;

figure
hold on
for j = 1:size(data,3)
    try
boxplot(data(:,:,j),'Widths',0.07,'Positions',[1-1e-5 1+1e-5].*price(j),'Orientation','horizontal','Colors','bm')
    catch
    end
end
ylim([0.5 1.1])
ax = gca;
ax.YAxis.TickValues = 0.6:0.1:1;
ax.YAxis.TickLabelsMode = 'auto';
ax.YAxis.Limits = [0.5 1.1];

figExport(12,8,'flex-overview')
