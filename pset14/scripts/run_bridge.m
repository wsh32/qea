function run_bridge()
% Insert any setup code you want to run here
save data/b.mat
collectDataset_sim('data/b.mat');

music = 0;

% TOKYO DRIFT
[y, Fs] = audioread('tokyo_drift.mp3');

% define u explicitly to avoid error when using sub functions
% see: https://www.mathworks.com/matlabcentral/answers/268580-error-attempt-to-add-variable-to-a-static-workspace-when-it-is-not-in-workspace
u = [];
% u will be our parameter 
syms u;

% this is the equation of the bridge
R = 4*[0.396*cos(2.65*(u+1.4));...
       -0.99*sin(u+1.4);...
       0];

% tangent vector
T = diff(R);

% normalized tangent vector
That = T/norm(T);

pub = rospublisher('raw_vel');

% stop the robot if it's going right now
stopMsg = rosmessage(pub);
stopMsg.Data = [0 0];
send(pub, stopMsg);

bridgeStart = double(subs(R,u,0));
startingThat = double(subs(That,u,0));
placeNeato(bridgeStart(1),  bridgeStart(2), startingThat(1), startingThat(2));

% wait a bit for robot to fall onto the bridge
pause(2);

% time to drive!!
c = [];
t = [];
syms c t
assume(c, {'real', 'positive'})
assume(t, {'real', 'positive'})

u = c * t;
ri = 4*(0.396*cos(2.65*(u+1.4)));
rj = 4*(-0.99*sin(u+1.4));
r = [ri rj 0];

d = 0.235;
[VL, VR] = generate_wheel_vels(r, d);
c_num = 1/3;

msg = rosmessage(pub);

start = rostime('now');

% start music
if music == 1
    sound(y, Fs, 16);
end

while 1
    elapsed = rostime('now') - start;
    speed_l = double(subs(VL, [c, t], [c_num, elapsed.seconds]));
    speed_r = double(subs(VR, [c, t], [c_num, elapsed.seconds]));
    
    msg.Data = [speed_l speed_r];
    send(pub, msg);
    
    if elapsed > 3.2/c_num - 0.6
        send(pub, stopMsg);
        break
    end
    pause(0.01);
end

clear sound

% For simulated Neatos only:
% Place the Neato in the specified x, y position and specified heading vector.
function placeNeato(posX, posY, headingX, headingY)
    svc = rossvcclient('gazebo/set_model_state');
    msg = rosmessage(svc);

    msg.ModelState.ModelName = 'neato_standalone';
    startYaw = atan2(headingY, headingX);
    quat = eul2quat([startYaw 0 0]);

    msg.ModelState.Pose.Position.X = posX;
    msg.ModelState.Pose.Position.Y = posY;
    msg.ModelState.Pose.Position.Z = 1.0;
    msg.ModelState.Pose.Orientation.W = quat(1);
    msg.ModelState.Pose.Orientation.X = quat(2);
    msg.ModelState.Pose.Orientation.Y = quat(3);
    msg.ModelState.Pose.Orientation.Z = quat(4);

    % put the robot in the appropriate place
    ret = call(svc, msg);
end

function [V_L, V_R] = generate_wheel_vels(r, d)
    vel = diff(r, t);
    T = simplify(vel ./ norm(vel));
    dT = diff(T, t);
    w = simplify(cross(T, dT));
    V_T = simplify(dot(T, vel));
    V_L = simplify(V_T - w(3) * d / 2);
    V_R = simplify(V_T + w(3) * d / 2);
end

end