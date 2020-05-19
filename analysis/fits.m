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

%     figExport(7,5,['fit-' q])

%     % add boxplot for comparison (based on Q2_1)
%     boxplot(d.(q),'Positions',0.19,'Orientation','Horizontal','Colors','g','Widths',0.01)
%     ax = gca;
%     ax.YAxis.TickValues = 0:0.05:0.2;
%     ax.YAxis.TickLabelsMode = 'auto';
%     ax.YAxis.Limits = [0 0.2];
end

%% histogram + fit -- daily runs

for q = {'Q2_1' 'Q4_1' 'Q4_2'}
    q = char(q);
    
    % adjust data to be per day
    switch q
        case 'Q2_1' % full week = 7 days
            d_.(q) = d.(q)/7;
        case 'Q4_1' % weekdays = 5 days
            d_.(q) = d.(q)/5;
        case 'Q4_2' % weekends = 2 days
            d_.(q) = d.(q)/2;
    end
            

    figure
    hold on
    histogram(d_.(q),'Normalization','probability')

    % fit skew normal
    fit.(q) = fitdist(d_.(q),'EpsilonSkewNormal');

    % calculate values using skew normal
    sampleRes.(q) = linspace(0,3,60);
    fitVals.(q) = pdf(fit.(q),sampleRes.(q));
    
    plot(sampleRes.(q),fitVals.(q),'LineWidth',2)
    
    % format plot
    title({strrep(q,'_','\_') sprintf('\\theta = %2.1f, \\sigma = %2.1f, \\epsilon = %1.2f',fit.(q).Theta,fit.(q).Sigma,fit.(q).Epsilon)})
    
    % add boxplot for comparison (based on Q2_1)
    boxplot(d_.(q),'Positions',0.75,'Orientation','Horizontal','Widths',0.1)
    
    % calculate quantiles
    quants.(q) = quantile(d_.(q),3);
    
    ax = gca;
    ax.YAxis.TickValues = 0:0.5:1;
    ax.YAxis.TickLabelsMode = 'auto';
    ax.YAxis.Limits = [0 1];
    ax.XAxis.TickValues = 0:2;
    ax.XAxis.Limits = [0 2.5];

%     figExport(7,5,['fit-daily-' q])
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
    
%     figExport(7,5,['fit-' q])
end

%% import price data

price_file = 'elec-price.csv';
opts = detectImportOptions(price_file);
opts.VariableUnitsLine = 2;
p = readtable(price_file,opts);

%% plot price data

figure
plot(p.time,p.price)
ax = gca;
ax.XAxis.TickValues = 0:6:24;
ax.XAxis.Limits = [0 24];

%% plot time series with daily runs multiplier

for q = {'x1_Q7_1' 'x3_Q7_1'}
    q = char(q);
    
    % set a variable with the Q containing runs per day info
    switch q
        case 'x1_Q7_1' % weekdays
            q_daily = 'Q4_1';
        case 'x3_Q7_1' % weekends
            q_daily = 'Q4_2';
    end
    
    figure
    hold on
    
    plot(sampleRes.(q),fitVals.(q),'DisplayName','original demand');
    for j = 1:3
        plot(sampleRes.(q),fitVals.(q)*quants.(q_daily)(j),'DisplayName',sprintf('adjusted - quartile %i (%0.2f\\times)',j,quants.(q_daily)(j)));
    end
    legend('Location','southoutside')
    
    % overlay price
    yyaxis right
    plot(p.time,p.price,'DisplayName','electricity price')
    
%     figExport(7,7,['daily-time-series-' q])
end

%% fit the flexibility data

% collect the data together
flex_data = [];
% add no-discount data
% flex_data = [flex_data; ones(40,1) d.Q12_1; ones(40,1) d.Q12_2];
flex_data = [flex_data; 1 quantile(d.Q12_1,0.5); 1 quantile(d.Q12_2,0.5)];
% add discount data
for j = 1:4
    v = num2str(j);
%     flex_data = [flex_data; ones(40,1)*(1-0.1*j) d.(['x' v '_Q14_1']); ones(40,1)*(1-0.1*j) d.(['x' v '_Q14_2'])];
    flex_data = [flex_data; (1-0.1*j) quantile(d.(['x' v '_Q14_1']),0.5); (1-0.1*j) quantile(d.(['x' v '_Q14_2']),0.5)];
end
% remove NaN values
flex_data = flex_data(~isnan(flex_data(:,2)),:);

% apply custom polynomial fit
[flexfit, flexgof] = createFit(flex_data(:,2),flex_data(:,1));

%% electricity price plot with flexibility curve

figure
hold on
plot(p.time,p.price,'DisplayName','electricity price')

% plot weekday and weekend peaks
for j = {'weekday' 'weekend'}
    j = char(j);
    switch j
        case 'weekday'
            demand_var = 'x1_Q7_1';
        case 'weekend'
            demand_var = 'x3_Q7_1';
    end
    
    % find index of maximum point in fitted data
    [~,I] = max(fitVals.(demand_var));
    % return corresponding time & price
    peakTime = sampleRes.(demand_var)(I);
    peakPrice = p.price(I);
    
    % add peak point to the plot
    stem(peakTime,peakPrice,'o','DisplayName',['peak - ' j]);
    
    legend('Location','southoutside','NumColumns',2)
    
    % calculate flexibility function
    x_sample = -10:10;
    flex_sample = flexfit(x_sample);

    % adjust flexibility function to peak price
    flex_sample = peakPrice * flex_sample;
    
    % plot flexibility function around peak time
    plot(peakTime+x_sample,flex_sample,'DisplayName',['price flexibility - ' j])
    
    
end

figExport(14,8,'elec-price-peaks-flex');
