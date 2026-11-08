#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from rclpy.time import Time

from geometry_msgs.msg import PoseStamped
from tf2_ros import Buffer, TransformListener, TransformException


class ToolPoseYayinla(Node):

    def __init__(self):
        super().__init__('tool_pose_yayinla')

        self.publisher = self.create_publisher(
            PoseStamped,
            '/pipet/tool_pose',
            10
        )

        self.tf_buffer = Buffer()
        self.tf_listener = TransformListener(
            self.tf_buffer,
            self
        )

        self.timer = self.create_timer(
            0.2,
            self.konum_yayinla
        )

        self.get_logger().info(
            'Pipet konum yayincisi baslatildi.'
        )

    def konum_yayinla(self):

        try:
            transform = self.tf_buffer.lookup_transform(
                'base_link',
                'tool0',
                Time()
            )

            msg = PoseStamped()

            msg.header = transform.header
            msg.header.frame_id = 'base_link'

            msg.pose.position.x = transform.transform.translation.x
            msg.pose.position.y = transform.transform.translation.y
            msg.pose.position.z = transform.transform.translation.z

            msg.pose.orientation = transform.transform.rotation

            self.publisher.publish(msg)

        except TransformException:
            pass


def main():

    rclpy.init()

    node = ToolPoseYayinla()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == '__main__':
    main()
