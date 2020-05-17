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