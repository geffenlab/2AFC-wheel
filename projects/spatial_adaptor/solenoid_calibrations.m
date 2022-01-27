%% 27 Jan 2022 solenoid calibration after leak fixed
baseline_weight = 1.1307;
n = [100 100]; % number of valve openings
delay = [150 160]; % ms
weight = [1.5951 1.6169]; % weight with water from testing
ul_opening = zeros(size(weight));
for ii = 1:length(delay)
    ul_opening(ii) = (weight(ii)-baseline_weight)/n(ii)*1000;
end

figure
[~,i] = sort(delay);
plot(delay(i),ul_opening(i),'ok','LineWidth',2)
set(gca,'FontSize',14)
xlabel('delay (ms)')
ylabel('\mul per opening')
axis tight

mdl = fitlm(delay,ul_opening);
pred_x = (50:1:200)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 19 Jan 2022 solenoid calibration after leak fixed
baseline_weight = 1.1308;
n = [100 100 100]; % number of valve openings
delay = [135 135 150]; % ms
weight = [1.5148 1.5517 1.6436]; % weight with water from testing
ul_opening = zeros(size(weight));
for ii = 1:length(delay)
    ul_opening(ii) = (weight(ii)-baseline_weight)/n(ii)*1000;
end

figure
[~,i] = sort(delay);
plot(delay(i),ul_opening(i),'ok','LineWidth',2)
set(gca,'FontSize',14)
xlabel('delay (ms)')
ylabel('\mul per opening')
axis tight

mdl = fitlm(delay,ul_opening);
pred_x = (50:1:200)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 10 Dec 2021 solenoid calibration after leak fixed
baseline_weight = 1.1305;
n = [100 100 100 100]; % number of valve openings
delay = [100 50 150 135]; % ms
weight = [1.5494 1.4224 1.6697 1.6292]; % weight with water from testing
ul_opening = zeros(size(weight));
for ii = 1:length(delay)
    ul_opening(ii) = (weight(ii)-baseline_weight)/n(ii)*1000;
end

figure
[~,i] = sort(delay);
plot(delay(i),ul_opening(i),'ok','LineWidth',2)
set(gca,'FontSize',14)
xlabel('delay (ms)')
ylabel('\mul per opening')
axis tight

mdl = fitlm(delay,ul_opening);
pred_x = (50:5:200)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

%% 10 Dec 2021 solenoid calibration
baseline_weight = 1.1305;
n = [200 200 100 100 100 100 100]; % number of valve openings
delay = [50 100 120 80 100 150 100]; % ms
weight = [1.6178 1.9065 1.5562 1.4535 1.4982 1.6128 1.5494]; % weight with water from testing
ul_opening = zeros(size(weight));
for ii = 1:length(delay)
    ul_opening(ii) = (weight(ii)-baseline_weight)/n(ii)*1000;
end

figure
[~,i] = sort(delay);
plot(delay(i),ul_opening(i),'ok','LineWidth',2)
set(gca,'FontSize',14)
xlabel('delay (ms)')
ylabel('\mul per opening')
axis tight

mdl = fitlm(delay,ul_opening);
pred_x = (50:5:200)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)
