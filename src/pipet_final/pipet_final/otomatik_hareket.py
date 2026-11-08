import rclpy
from rclpy.node import Node
from rclpy.action import ActionClient

from control_msgs.action import FollowJointTrajectory
from trajectory_msgs.msg import JointTrajectoryPoint


class OtomatikHareket(Node):

    def __init__(self):
        super().__init__('otomatik_hareket')

        self.client = ActionClient(
            self,
            FollowJointTrajectory,
            '/arm_controller/follow_joint_trajectory'
        )

        self.konumlar = [
            ('Konum 1', [0.3, 0.4, 0.02]),
            ('Konum 2', [-0.4, 0.6, 0.04]),
            ('Konum 3', [0.7, -0.5, 0.06]),
            ('Baslangic', [0.0, 0.0, 0.0]),
        ]

    def hareket_et(self, isim, hedef):

        goal = FollowJointTrajectory.Goal()

        goal.trajectory.joint_names = [
            'joint1',
            'joint2',
            'joint3'
        ]

        point = JointTrajectoryPoint()
        point.positions = hedef
        point.time_from_start.sec = 5

        goal.trajectory.points = [point]

        self.get_logger().info(
            f'{isim} hedefine gidiliyor: {hedef}'
        )

        future = self.client.send_goal_async(goal)
        rclpy.spin_until_future_complete(self, future)

        goal_handle = future.result()

        if goal_handle is None or not goal_handle.accepted:
            self.get_logger().error('Hedef reddedildi!')
            return False

        result_future = goal_handle.get_result_async()
        rclpy.spin_until_future_complete(self, result_future)

        result = result_future.result()

        if result is None:
            self.get_logger().error('Sonuc alinamadi!')
            return False

        if result.result.error_code != 0:
            self.get_logger().error(
                f'Hareket basarisiz: '
                f'{result.result.error_string}'
            )
            return False

        self.get_logger().info(
            f'{isim} hedefine ulasildi.'
        )

        return True


def main(args=None):

    rclpy.init(args=args)

    node = OtomatikHareket()

    node.get_logger().info(
        'Robot kontrolcusu bekleniyor...'
    )

    if not node.client.wait_for_server(timeout_sec=10.0):
        node.get_logger().error(
            'Hareket kontrolcusu bulunamadi!'
        )
        node.destroy_node()
        rclpy.shutdown()
        return

    for isim, hedef in node.konumlar:

        if not node.hareket_et(isim, hedef):
            break

    node.get_logger().info(
        'Otomatik hareket programi tamamlandi.'
    )

    node.destroy_node()
    rclpy.shutdown()


if __name__ == '__main__':
    main()
