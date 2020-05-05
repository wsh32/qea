function GauntletDrive(pos_matrix, circle_center, circle_radius) 
    pub = rospublisher('raw_vel');

    % stop the robot if it's going right now
    stopMsg = rosmessage(pub);
    stopMsg.Data = [0 0];
    send(pub, stopMsg);

    placeNeato(0, 0, cos(atan2(((pos_matrix(2,2)-pos_matrix(1,2))),((pos_matrix(2,1)-pos_matrix(1,1))))), sin(atan2(((pos_matrix(2,2)-pos_matrix(1,2))),((pos_matrix(2,1)-pos_matrix(1,1))))));

    % wait a bit for robot to fall onto contour map
    pause(2);

    % time to drive!!
    msg = rosmessage(pub);
    angle = atan2(((pos_matrix(2,2)-pos_matrix(1,2))) , ((pos_matrix(2,1)-pos_matrix(1,1))));

    for i = 1:(length(pos_matrix(:,1))-1)
        old_angle = angle;

        angle = atan2(((pos_matrix(i+1,2)-pos_matrix(i,2))),((pos_matrix(i+1,1)-pos_matrix(i,1))));

        turn_time = .5;
        angle_turn = angle-old_angle;
        V_lw = (-angle_turn/turn_time)*(.235/2);
        V_rw = (angle_turn/turn_time)*(.235/2);
        msg.Data = [V_lw, V_rw];
        send(pub, msg);
        pause_rostime(turn_time); %pauses loop while robot runs at this speed

        lin_speed = 0.25;
        %distance formula
        step_distance = sqrt((pos_matrix(i+1,1)-pos_matrix(i,1))^2 + (pos_matrix(i+1,2)-pos_matrix(i,2))^2);
        step_time =  step_distance / lin_speed;    
        msg.Data = [lin_speed, lin_speed];
        send(pub, msg);
        pause_rostime(step_time); %pauses loop while robot runs at this speed 

        distance_from_center = pos_matrix(i, :) - circle_center;
        if norm(distance_from_center) < circle_radius
            msg.Data = [0,0];
            send(pub, msg);
            display(STOP)
            break
        end
    end

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

    function pause_rostime(pause_seconds)
        time_start = rostime('now');
        while 1
            elapsed = (rostime('now') - time_start);
            if elapsed.seconds > pause_seconds
                break
            end
            pause(0.01);  % pause slightly to allow "concurrent" programs
        end
    end
end