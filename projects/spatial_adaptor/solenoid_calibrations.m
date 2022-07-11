%% 7 JULY 2022 solenoid calibration RIGHT 
baseline_weight = 1.1309;

delay = [92 170 158 170]; % ms
weight = [1.4220 1.6679 1.6483 1.6801]; % weight with water from testing
n = ones(length(delay),1)*100; % number of valve openings
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 4 ul: %d ms\n',pred_x(knnsearch(pred_ul,4)))



%% 7 JULY 2022 solenoid calibration LEFT 
baseline_weight = 1.1309;
n = [100 100 100 100 100 100]; % number of valve openings
delay = [116 170 162 160 150 170]; % ms
weight = [1.4804 1.6571 1.6490 1.6426 1.6198 1.6757]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 4 ul: %d ms\n',pred_x(knnsearch(pred_ul,4)))



%% 27 JUNE 2022 solenoid calibration LEFT 
baseline_weight = 1.1310;
n = [100 100 100]; % number of valve openings
delay = [100 125 116]; % ms
weight = [1.5751 1.6606 1.6305]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))


%% 27 JUNE 2022 solenoid calibration CENTER 
baseline_weight = 1.1310;
n = [100 100 100 100]; % number of valve openings
delay = [92 120 130 124]; % ms
weight = [1.5325 1.6192 1.6506 1.6356]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 27 JUNE 2022 solenoid calibration RIGHT 
baseline_weight = 1.1310;
n = [100 100 100 100 100 100]; % number of valve openings
delay = [50 50 75 100 100 92]; % ms
weight = [1.4565 1.4719 1.5705 1.6599 1.6611 1.6332]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))
%% 5 MAY 2022 solenoid calibration LEFT 
baseline_weight = 1.1321;
n = [100 ]; % number of valve openings
delay = [50 ]; % ms
weight = [1.6376 ]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 5 MAY 2022 solenoid calibration CENTER 
baseline_weight = 1.1321;
n = [100 100]; % number of valve openings
delay = [50 55]; % ms
weight = [1.6252 1.6428]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 5 MAY 2022 solenoid calibration RIGHT 
baseline_weight = 1.1321;
n = [100 100 100]; % number of valve openings
delay = [100 70 50]; % ms
weight = [1.8586 1.7098 1.6471]; % weight with water from testing
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
pred_x = (10:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 14 Feb 2022 solenoid calibration 
baseline_weight = 1.1308;
n = [100 100 100 100 100]; % number of valve openings
delay = [160 160 180 180 200]; % ms
weight = [1.4526 1.4438 1.4731 1.4758 1.5070]; % weight with water from testing
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
pred_x = (50:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))

%% 07 Feb 2022 solenoid calibration 
baseline_weight = 1.1307;
n = [100 100]; % number of valve openings
delay = [150 170]; % ms
weight = [1.5187 1.5592]; % weight with water from testing
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
pred_x = (50:1:250)';
pred_ul = predict(mdl,pred_x);
hold on;
plot(pred_x,pred_ul,'r-','LineWidth',2)

fprintf('closest to 5 ul: %d ms\n',pred_x(knnsearch(pred_ul,5)))


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
