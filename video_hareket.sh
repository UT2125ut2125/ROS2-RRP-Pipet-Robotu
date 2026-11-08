#!/bin/bash

source /opt/ros/lyrical/setup.bash
source ~/pipet_final_ws/install/setup.bash

echo "=== PIPET ROBOTU VIDEO GOSTERISI ==="
echo "3 saniye sonra hareket basliyor..."
sleep 3

hareket() {
    echo "Yeni hedef: $1 $2 $3"
    ros2 action send_goal \
      /arm_controller/follow_joint_trajectory \
      control_msgs/action/FollowJointTrajectory \
      "{trajectory: {joint_names: [joint1, joint2, joint3], points: [{positions: [$1, $2, $3], time_from_start: {sec: 10}}]}}"
    sleep 2
}

hareket  0.0  0.0  0.00
hareket  0.8  0.7  0.08
hareket -0.8  0.7  0.00
hareket  0.6 -0.9  0.08
hareket -0.6 -0.6  0.00
hareket  0.4  1.0  0.08
hareket  0.0  0.0  0.00

echo "=== GOSTERI TAMAMLANDI ==="
