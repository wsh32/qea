% Elephant circus routine

% 1. Run forward
% 2. Roll forward
% 3. Backflip
% 4. Roll back to start

clear
clf()
axis_setup = [-.05 1 -.05 1];

elephant = [
    -0.050    -0.030 1;
    -0.050    0.0300 1;
    0.0500    0.0450 1;
    0.0500    -0.030 1;
    0.0500    0.0700 1;
    0.0700    0.0000 1;
]';

body = [2 1 0.5 2 1 1 2 6 7 7 8 7 7 6 5 5 5 4.5 5 5.5 5 5 3 3 3 2.5 3 3.5 3 3 2;
        2 4 2   2 4 7 9 9 7 4 5 6 4 2 2 0 1 0   1 0   1 2 2 0 1 0   1 0   1 2 2;
        1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
scale = [
    0.013 0.000 0;
    0.000 0.010 0;
    0.000 0.000 1;
];
translate = [
    1 0 -5;
    0 1 -5;
    0 0 1;
];
elephant=scale*translate*body;

plot(elephant(1, :), elephant(2, :), 'b-');
axis(axis_setup);

% Setup
framerate = 120;
t_pause = 1 / framerate;

% 1. Run Forward
start = [0.05; 0];
runto = [0.3; 0];
runto_frames = 20;

for i = 0:runto_frames
    t_x = (i / runto_frames) * (runto(1) - start(1)) + start(1);
    t_y = (i / runto_frames) * (runto(2) - start(2)) + start(2);
    
    transform = [
        1 0 t_x;
        0 1 t_y;
        0 0 1;
    ];

    tElephant = transform * elephant;
    plot(tElephant(1, :), tElephant(2, :), 'b-');
    axis(axis_setup);
    pause(t_pause);
end

% 2. Barrel roll
start = runto;
rollto = [0.6; 0];
rollto_frames = 30;

for i = 0:rollto_frames
    t_x = (i / rollto_frames) * (rollto(1) - start(1)) + start(1);
    t_y = (i / rollto_frames) * (rollto(2) - start(2)) + start(2);
    theta = -(i / rollto_frames) * 2 * pi;
    
    transform = [
        1 0 t_x;
        0 1 t_y;
        0 0 1;
    ] * [
        cos(theta) -sin(theta) 0;
        sin(theta) cos(theta) 0;
        0 0 1;
    ];

    tElephant = transform * elephant;
    plot(tElephant(1, :), tElephant(2, :), 'b-');
    axis(axis_setup);
    pause(t_pause);
end

% Pause a bit, ready to jump
pause(0.20);

% 3. Backflip
start = rollto;
jumpto_max_height = 0.3;
jumpto = [0.2; 0];
jumpto_frames = 20;

for i = 0:jumpto_frames
    t_x = (i / jumpto_frames) * (jumpto(1) - start(1)) + start(1);
    % Quadratic function for height
    t_y = -(2*sqrt(jumpto_max_height) * (i / jumpto_frames) - sqrt(jumpto_max_height))^2 + jumpto_max_height;
    theta = (i / jumpto_frames) * 2 * pi;
    
    transform = [
        1 0 t_x;
        0 1 t_y;
        0 0 1;
    ] * [
        cos(theta) -sin(theta) 0;
        sin(theta) cos(theta) 0;
        0 0 1;
    ];

    tElephant = transform * elephant;
    plot(tElephant(1, :), tElephant(2, :), 'b-');
    axis(axis_setup);
    pause(t_pause);
end

% 4. Barrel roll
start = jumpto;
rollto = [0.05; 0];
rollto_frames = 20;

for i = 1:rollto_frames
    t_x = (i / rollto_frames) * (rollto(1) - start(1)) + start(1);
    t_y = (i / rollto_frames) * (rollto(2) - start(2)) + start(2);
    theta = (i / rollto_frames) * 2 * pi;
    
    transform = [
        1 0 t_x;
        0 1 t_y;
        0 0 1;
    ] * [
        cos(theta) -sin(theta) 0;
        sin(theta) cos(theta) 0;
        0 0 1;
    ];

    tElephant = transform * elephant;
    plot(tElephant(1, :), tElephant(2, :), 'b-');
    axis(axis_setup);
    pause(t_pause);
end