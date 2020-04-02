%This script finds the equilibrium angle for the circular segment and does
%some additional plotting to visualize the scenario. The angle of the
%segment can also be set manually to allow for additional visualizations.
clf

%define circular segment parameters
r=1.75;
h=1.5;

%define ramp angle (replace the value in the deg2rad function)
theta=deg2rad(35);

%For experimenting, you might want to manually set a rotation angle, phi,
%for the circular segment. To do that, change the flag below to 1, and
%choose set of angles to cycle through.
set_phi=1; %change to 1 if you want to manually set phi
phi_manual=-30:5:50; %manual phi value

if set_phi==0
    m=1;
elseif set_phi==1
    m=length(phi_manual);
end

for n=1:m
%specify symbolic values
syms r_sym h_sym y

%we need to setup our integrals. For the centroid, ybar=intydA/intdA 
%We use dA=xdy
  
%first define x using the definition of a circle with center at [0,R], x^2+(y-R)^2=R^2
x=sqrt(r_sym^2-(y-r_sym)^2);

%Setup the integral, symbolicaly for the area of the circular segment. This integral is A=2*int(x)dy
A=2*int(x,y,[0 h_sym]);

%do the integral for the centroid symbolically and convert to a double
ybar=int(y*x,y,[0 h_sym])/int(x,y,[0 h_sym]);

%substitute numerical values for r and h and convert the output to a double
A=double(subs(A,[r_sym, h_sym],[r, h]));
ybar=double(subs(ybar,[r_sym, h_sym],[r, h]));

% create the symbolic variable phi
syms phi

%position of the CG in global frame
i_cg=(r*phi-(r-ybar)*sin(phi))*cos(theta)+(r-(r-ybar)*cos(phi))*sin(theta);
j_cg=-(r*phi-(r-ybar)*sin(phi))*sin(theta)+(r-(r-ybar)*cos(phi))*cos(theta);

%position of contact point in global frame
i_contact=r*phi*cos(theta);
j_contact=r*phi*-sin(theta);

% find the equilibrium angle using the solve function
if set_phi==0
    eqn = i_cg == i_contact; %create equality
    phi_eq=rad2deg(double(solve(eqn,phi,'Real',true))); %use rad2deg to convert to degrees
    if isempty(phi_eq)==1
        msg='No equilibrium condition available';
        error(msg)
    end
elseif set_phi==1
    phi_eq=phi_manual(n);
end

%position of the CG in global frame
i_cg_num=(r*deg2rad(phi_eq(1))-(r-ybar)*sin(deg2rad(phi_eq(1))))*cos(theta)+(r-(r-ybar)*cos(deg2rad(phi_eq(1))))*sin(theta);
j_cg_num=-(r*deg2rad(phi_eq(1))-(r-ybar)*sin(deg2rad(phi_eq(1))))*sin(theta)+(r-(r-ybar)*cos(deg2rad(phi_eq(1))))*cos(theta);

%position of contact point in global frame
i_contact_num=r*deg2rad(phi_eq(1))*cos(theta);
j_contact_num=r*deg2rad(phi_eq(1))*-sin(theta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section will be devoted to visualization

%Righting Arm
RM(n)=i_contact_num-i_cg_num;

%find the angle that defines this segment
seg_angle=rad2deg((2*acos(1-h/r)));
max_angle=seg_angle/2;

%create points that define the circular segment
t = linspace(-deg2rad(90-(seg_angle/2)),-deg2rad(90+seg_angle/2));
% t = linspace(-deg2rad(0),-deg2rad(180));
x = r*cos(t);
y = r*sin(t) + r;
x = [x  x(1)];
y = [y  y(1)];

%need new x and y points after rolling. The points on the circle follow a
%cycloid path
dx=r*(deg2rad(phi_eq(1))-sin(deg2rad(phi_eq(1))));
dy=r*(1-cos(deg2rad(phi_eq(1))));

% this rotation matrix rotates around the center,so we will first rotate by
% and angle phi
R_phi=[cos(-deg2rad(phi_eq(1))) -sin(-deg2rad(phi_eq(1)));
    sin(-deg2rad(phi_eq(1))) cos(-deg2rad(phi_eq(1)))];
[ramp_coords]=R_phi*[x;y];

%We then translate the points based on how much they would move do to the
%rolling of the circular segment
T=[1 0 dx;
    0 1 dy;
    0 0 1];
%Translate circular segment
[ramp_coords]=T*[ramp_coords; ones(1,length(ramp_coords))];

%Next we will rotate the whole ramp according to the angle theta
R_theta=[cos(-theta) -sin(-theta);
    sin(-theta) cos(-theta)];
[ramp_coords]=R_theta*ramp_coords(1:2,:);

%create lines that show the ramp
x_ramp=linspace(-(ceil(r)+2),ceil(r)+2);
y_ramp=-tan(theta)*x_ramp;

%plot everything
figure(1)
delete(findall(gcf,'type','annotation'))
h1 = fill(x,y,'r');
hold on
h2 = plot([i_cg_num i_cg_num],[0 h+2],'k--');
h3 = plot([i_contact_num i_contact_num],[0 h+2],'k--');
h4 = plot([-(ceil(r)+2) ceil(r)+2],[0 0],'r','Linewidth',1);
h5 = fill(ramp_coords(1,:),ramp_coords(2,:),'b');
h6 = plot(x_ramp,y_ramp,'b','Linewidth',1);
h7 = plot(i_contact_num,j_contact_num,'ko','MarkerSize', 10,'MarkerFaceColor','k');
h8 = plot(i_cg_num,j_cg_num,'kd','MarkerSize', 10,'MarkerFaceColor','k');
h9 = plot([i_cg_num i_contact_num],[h+2 h+2],'r','Linewidth',1);
hold off
legend([h1 h5 h6 h7 h8],'Segment Flat','Segment Ramp','Ramp','Contact Point','Tilt CG','location','Northwest')
axis([-(ceil(r)+2) ceil(r)+2 -(ceil(r)-2) ceil(r)+4]) 
axis equal;
title(['Circular Segment with r=' num2str(r) ' and h=' num2str(h)])

% Create textbox
annotation(figure(1),'textbox',...
    [0.6 0.75 0.3 0],...
    'String',['Moment Arm = ' num2str(RM(n))],...
    'FitBoxToText','on',...
    'EdgeColor',[1 1 1]);

% Create textbox
annotation(figure(1),'textbox',...
    [0.43 0.9 0.2 0],...
    'String',['\theta = ' num2str(rad2deg(theta)) '   \phi = ' num2str(phi_eq(1))],...
    'FitBoxToText','on',...
    'FontWeight','bold',...
    'FontSize',12,...
    'EdgeColor',[1 1 1]);
drawnow
end

if set_phi==1 && length(phi_manual)>1
figure(2)
plot(phi_manual,RM,'linewidth',2)
title(['Circular Segment with r=' num2str(r) ' and h=' num2str(h)])
xlabel('Roll Angle \phi')
ylabel('Moment Arm')
grid on
end