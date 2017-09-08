%% xxxx date here 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = ; % g - weight of empty eppendorf
durations = []; % ms - duration of solenoid opening
weights = []; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,3);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1);
disp([num2str(y1) ' ul in 50 ms'])

%% 15 June 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1110; % g - weight of empty eppendorf
durations = [50,50,50]; % ms - duration of solenoid opening
weights = [1.4525,1.4517,1.4531]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,3);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1);
disp([num2str(y1) ' ul in 50 ms'])

%% %% 06/12/2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1106; % g - weight of empty eppendorf
durations = [50,50,50]; % ms - duration of solenoid opening
weights = [1.4298,1.4295,1.4328]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,3);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1);
disp([num2str(y1) ' ul in 50 ms'])

%% 06/05/2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1111; % g - weight of empty eppendorf
durations = [50,50,50]; % ms - duration of solenoid opening
weights = [1.2970,1.3949,1.3973]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,3);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1);
disp([num2str(y1) ' ul in 50 ms'])

%% 29 May 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1113; % g - weight of empty eppendorf
durations = [50,50,50]; % ms - duration of solenoid opening
weights = [1.4534, 1.4524,1.4500]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,3);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1);
disp([num2str(y1) ' ul in 50 ms'])

%% 22 May 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1112; % g - weight of empty eppendorf
durations = [50 50]; % ms - duration of solenoid opening
weights = [1.3316, 1.4091]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1)

%% 11th May 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1109; % g - weight of empty eppendorf
durations = [50, 50, 75, 25, 15, 100, 50]; % ms - duration of solenoid opening
weights = [1.4151, 1.4147, 1.5079, 1.3809, 1.3196, 1.6130, 1.4181]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1)

%% 24th April 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1112; % g - weight of empty eppendorf
durations = [50,50,100,15,25,50]; % ms - duration of solenoid opening
weights = [1.3830, 1.3624, 1.5849, 1.2818, 1.3292, 1.3632]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1)
%% 10th April 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1108; % g - weight of empty eppendorf
durations = [50,50,100,25,15]; % ms - duration of solenoid opening
weights = [1.3825, 1.3878, 1.6081, 1.3414, 1.2803]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1)
%% 6th March 2017 Water calibration for the top booth - fill the tube to 60 ml with H2O
empty = 1.1158; % g - weight of empty eppendorf
durations = [50,50,100,25,15]; % ms - duration of solenoid opening
weights = [1.3594, 1.3833, 1.5200, 1.3348, 1.2690]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1);
disp([num2str(y1) ' ul per 50 ms opening'])

%% Water calibration for the top booth - fill the tube to 60 ml with H2O

empty = 1.1152; % g - weight of empty eppendorf
durations = [6,7,7,10,10,15,20,50,100]; % ms - duration of solenoid opening
weights = [1.1973,1.2098,1.2096,1.2317,1.2315,1.2594,1.2894,1.4034,1.5920]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)

x1 = 50; % if x is ...
y1 = polyval(P,x1) % y =

%% Water calibration for the top booth - fill the tube to 25 ml with H2O

empty = 1.1155; % g - weight of empty eppendorf
durations = [6,7,7,10,10,15,15,20,20,50,50,100]; % ms - duration of solenoid opening
weights = [1.1800,1.1937,1.1949,1.2094,1.2093,1.2365,1.2317,1.2622,1.2564,1.3648,1.3587,1.5235]; % weight of eppendorf with water from 100 openings of the valve
ulPerOpening = (weights - repmat(empty,1,length(weights)))*1000/100;

figure
plot(durations,ulPerOpening,'ok','LineWidth',2)
xlabel('Time valve open (ms)')
ylabel('\mul per opening')

P = polyfit(durations,ulPerOpening,2);
x1 = 0:3:100;
y1 = polyval(P,x1);
hold on
plot(x1,y1,'r--','LineWidth',2)
set(gca,'FontSize',14)