function gradient_ascent_neato()
% Insert any setup code you want to run here
music = 0;

% TOKYO DRIFT
if music == 1
    [song, Fs] = audioread('tokyo_drift.mp3');
end
    
% define u explicitly to avoid error when using sub functions
% see: https://www.mathworks.com/matlabcentral/answers/268580-error-attempt-to-add-variable-to-a-static-workspace-when-it-is-not-in-workspace
x = [];
y = [];
% u will be our parameter 
syms x y;
assume(x, {'real'});
assume(y, {'real'});

% this is the equation of the bridge
f = x*y - x^2 - y^2 - 2*x - 2*y + 4;
grad = [diff(f, x); diff(f, y)];

% initial pose
r = [1 -1];
ang = pi / 2;

pub = rospublisher('raw_vel');

% stop the robot if it's going right now
stopMsg = rosmessage(pub);
stopMsg.Data = [0 0];
send(pub, stopMsg);

placeNeato(r(1),  r(2), 0, 1);

% wait a bit for robot to fall onto the bridge
pause(2);

% time to drive!!
vel_msg = rosmessage(pub);

odom_sub = rossubscriber('/odom');

start = rostime('now');
elapsed = rostime('now') - start;

% start music
if music == 1
    sound(song, Fs, 16);
end

lin_vel = 0;  % linear velocity in m/s
ang_vel = 0;  % angular velocity in m/s
d = 0.235;    % distance between left and right wheels

lambda = 0.1;
delta = 1;

while 1
    odom_msg = receive(odom_sub);
    
    % get timing
    elapsed_new = rostime('now') - start;
    dtime = elapsed_new - elapsed;
    elapsed = elapsed_new;

    rot = [cos(ang) -sin(ang); sin(ang) cos(ang)];
    r = r + (rot * [lin_vel; 0])' * dtime.seconds;
    ang = ang + ang_vel * dtime.seconds;
    
    r = [odom_msg.Pose.Pose.Position.X odom_msg.Pose.Pose.Position.Y]
    ang = odom_msg.Pose.Pose.Orientation.Z
    
    rgrad = double(subs(grad, [x, y], [r(1), r(2)])) * lambda;
    lin_vel = norm(rgrad);
    ang_vel = atan2(rgrad(2), rgrad(1)) - ang;
    
    lambda = lambda * delta;

    speed_l = .1; %lin_vel - ang_vel * d/2;
    speed_r = -.1; % lin_vel + ang_vel * d/2;

    if lin_vel < 0.1 || isnan(speed_l) || isnan(speed_r)
        send(pub, stopMsg);
        break
    end
    
    vel_msg.Data = [speed_l speed_r];
    send(pub, vel_msg);
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

end