import os
import tempfile

import xacro

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import IncludeLaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch_ros.actions import Node


def generate_launch_description():

    package_dir = get_package_share_directory('pipet_final')

    xacro_file = os.path.join(
        package_dir,
        'urdf',
        'pipet_final.urdf.xacro'
    )

    robot_description = xacro.process_file(
        xacro_file
    ).toxml()

    urdf_file = os.path.join(
        tempfile.gettempdir(),
        'pipet_final_launch.urdf'
    )

    with open(urdf_file, 'w', encoding='utf-8') as f:
        f.write(robot_description)

    gazebo_launch = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(
                get_package_share_directory('ros_gz_sim'),
                'launch',
                'gz_sim.launch.py'
            )
        ),
        launch_arguments={
    'gz_args': os.path.join(
        package_dir,
        'worlds',
        'pipet_world.sdf'
    )
}.items()

    )

    robot_state_publisher = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='robot_state_publisher',
        output='screen',
        parameters=[{
            'robot_description': robot_description,
            'use_sim_time': True
        }]
    )

    spawn_robot = Node(
        package='ros_gz_sim',
        executable='create',
        arguments=[
            '-world', 'empty',
            '-file', urdf_file,
            '-name', 'pipet_final',
            '-z', '0'
        ],
        output='screen'
    )

    return LaunchDescription([
        gazebo_launch,
        robot_state_publisher,
        spawn_robot
    ])
