function asseMetricVis(dataObs,dataSim,nnR,style,titleN)
%Function requiring forcasted, observed values and optional values
%nnR - R^2 value
%style - options for display of figures (1 or 2)
%titleN - title to be included (string)


clear title xlabel ylabel

n = get(gcf,'Number');%set figure number
ylimMax1 = max(dataSim);
ylimMax2 = max(dataObs);
ylimMax = max(ylimMax1,ylimMax2);
ylimMin1 = min(dataSim);
ylimMin2 = min(dataObs);
ylimMin = min(ylimMin1,ylimMin2);

if style == 1  %Tradition visualisation with each figure has separate window
    
    %histogram
    figure(n+1)
    n = n+1;
    dataErr = abs(dataObs - dataSim);
    hmin = min(dataErr);
    hmax = max(dataErr);
    hold on;
    hist(dataErr,[hmin:1:hmax]);
    title({titleN,'Histogram absolute error frequency'});
    ylabel('Frequency of Error');
    xlabel('Errors ');
    hold off;
    
    % Scatterplot
    figure(n+1)
    n = n+1;
    hold on;
    scatter(dataObs,dataSim)
    ylim([ylimMin ylimMax])
    %text(2,2, ['R^2 = ' num2str(nnR)]);
    title({titleN,'Scatterplot prediction againts observed'});
    xlabel('Data Observation - Value');
    ylabel('Data Simulated - Value');
    %add line
    coeffs = polyfit(dataObs, dataSim, 1);
    eqn = ['y = ' sprintf('%3.3fx^%1.0f + ',[coeffs ;length(coeffs)-1:-1:0])];
    %eqn = ['y = ' sprintf('%3.3fx + %.3f + ',[coeffs ;length(coeffs)-1:-1:0])];
    eqn = eqn(1:end-3);

    xmax = min(dataObs);
    ymin = max(dataSim);
    % Get fitted values
    fittedX = linspace(min(dataObs), max(dataObs), 200);
    fittedY = polyval(coeffs, fittedX);
    text(xmax, ymin, eqn, 'FontSize', 14, 'Color','red'); %equation
    plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
    legend(['r^2 = ' num2str(nnR)],'line of best fit' ,'Location', 'Best');
    hold off;

    
    %time series
    figure(n+1)
    n = n+1;
    hold on;
    plot(dataObs);
    plot(dataSim);
    ylim([ylimMin ylimMax]);
    title({titleN,'Timeseries prediction againts observed'});
    ylabel('Value of Index');
    xlabel('Time - (days)');
    legend('forecasted','observed','Location', 'Best');
    hold off;

elseif style == 2 %visualisation in one window for easy comparison
    
    figure(n+1)
    n = n+1;
    %time series
    subplot(2,1,1)
    hold on;
    plot(dataObs);
    plot(dataSim);
    ylim([ylimMin ylimMax]);
    title({titleN,'Timeseries prediction againts observed'});
    ylabel('Value of Index');
    xlabel('Time - (days)');
    legend('forecasted','observed','Location', 'Best');
    hold off;
    
    %Histogram
    subplot(2,2,3) 
    hold on;
    dataErr = abs(dataObs - dataSim);
    hmin = min(dataErr);
    hmax = max(dataErr);
    hist(dataErr,[hmin:1:hmax]);
    title('Histogram absolute error frequency');
    ylabel('Frequency of Error');
    xlabel('Errors ');
    hold off;
    
    % Scatterplot
    subplot(2,2,4)
    hold on;
    scatter(dataObs,dataSim)
    ylim([ylimMin ylimMax])
    title('Scatterplot prediction againts observed');
    xlabel('Data Observation - Value');
    ylabel('Data Simulated - Value');
    %add line
    coeffs = polyfit(dataObs, dataSim, 1);
    % Get fitted values
    fittedX = linspace(min(dataObs), max(dataObs), 200);
    fittedY = polyval(coeffs, fittedX);
    plot(fittedX, fittedY, 'r-', 'LineWidth', 3);
    legend(['R^2 = ' num2str(nnR)],'line of best fit' ,'Location', 'Best');
    hold off;

end

end