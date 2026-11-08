from setuptools import find_packages, setup
from glob import glob
import os

package_name = 'pipet_final'

setup(
    name=package_name,
    version='0.0.0',
    packages=find_packages(exclude=['test']),

    data_files=[
        (
            'share/ament_index/resource_index/packages',
            ['resource/' + package_name]
        ),
        (
            'share/' + package_name,
            ['package.xml']
        ),
        (
            os.path.join('share', package_name, 'launch'),
            glob('launch/*.launch.py')
        ),
        (
            os.path.join('share', package_name, 'urdf'),
            glob('urdf/*.xacro')
        ),
        (
            os.path.join('share', package_name, 'config'),
            glob('config/*.yaml')
        ),
        (
            os.path.join('share', package_name, 'worlds'),
            glob('worlds/*.sdf')
        ),
    ],

    install_requires=['setuptools'],
    zip_safe=True,

    maintainer='ummahantemel',
    maintainer_email='ummahantemel@todo.todo',

    description='3 DoF pipetleme robotu ROS 2 projesi',
    license='Apache-2.0',

    entry_points={
    'console_scripts': [
        'otomatik_hareket = pipet_final.otomatik_hareket:main',
    ],
},
)


