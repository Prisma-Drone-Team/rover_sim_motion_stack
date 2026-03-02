# UGV MOTION STACK

This repository contains tools and configurations for UGV (Unmanned Ground Vehicle) simulation and navigation within the H-CoRE framework. It implements the ground agent simulation stack for autonomous robot operations in controlled environments.

## Architecture Overview

This repository implements the ROS2-based simulation of the ground agent (UGV) of the H-CoRE framework. The **leonardo** branch provides a standalone simulation environment, while the **multi-robot** branch modifies scripts to enable multi-robot simulation with other agents in the H-CoRE ecosystem.

The system consists of several modular ROS2 packages, each with a specific responsibility:

```
rover_sim_motion_stack/
├── src/pkg/                        # ROS2 workspace with modular packages
│   ├── aruco_detector_ocv_ros2/    # OpenCV-based ArUco detector for localization
│   ├── costmap_plugin/             # Custom gradient layer for navigation costmaps  
│   ├── custom_explorer/            # Autonomous exploration and coverage algorithms
│   ├── nav2_astar_planner/         # A* global path planning algorithm
│   ├── nav2_straightline_planner/  # Straight-line global planner
│   ├── pointcloud_to_laserscan/    # 3D pointcloud to 2D laser scan conversion
│   ├── rover_bringup/              # Launch files and configurations
│   ├── rover_description_pkg/      # URDF robot models and descriptions
│   ├── rover_gazebo/               # Gazebo simulation worlds and launch files
│   ├── rover_manager/              # Robot state management and control interface
│   ├── scan_merger/                # Multi-sensor laser scan fusion
│   └── yolov11_ros2/               # Object detection using YOLOv11
├── docker_*.sh                     # Docker management scripts
├── Dockerfile                      # Container configuration
├── init_sim.sh                     # Automatic simulation initialization
└── README.md                       # This documentation
```

## System Requirements

- **Docker**: For isolated development environment
- **ROS2 Humble**: Robotics framework
- **Gazebo Garden**: 3D simulator with physics engine
- **OpenCV**: Computer vision library for perception
- **Navigation2**: Robot navigation stack

## Installation and Setup

### 1. Repository Clone
```bash
git clone https://github.com/Prisma-Drone-Team/rover_sim_motion_stack.git
cd rover_sim_motion_stack
```

### 2. Branch Selection

#### Leonardo Branch (Standalone Simulation)
```bash
git checkout leonardo
```
This branch provides a complete standalone simulation environment for single-robot operations.

#### Multi-Robot Branch (Multi-Agent Simulation)  
```bash
git checkout multi-robot
```
This branch includes modifications to support multi-robot simulation within the H-CoRE framework.

### 3. Build Docker Image
```bash
./docker_build.sh rover_sim_image
```

### 4. Run Container with Automatic Initialization
```bash
./docker_run.sh rover_sim_image rover_container
```
The container will automatically execute `init_sim.sh` which sets up the ROS2 environment and builds the workspace.

## Development Configuration

### ROS2 Workspace Build
The workspace is automatically built during container initialization. For manual builds:

```bash
cd ~/rover_ws
source /opt/ros/humble/setup.bash
colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release
source install/setup.bash
export ROS_DOMAIN_ID=17
```

### Main Dependencies
```xml
<!-- Common package.xml -->
<depend>rclcpp</depend>
<depend>geometry_msgs</depend>
<depend>nav_msgs</depend>
<depend>sensor_msgs</depend>
<depend>tf2</depend>
<depend>tf2_ros</depend>
<depend>nav2_common</depend>
<depend>gazebo_ros_pkgs</depend>
<depend>ros_gz_bridge</depend>
```

## Usage

### Simulation Launch (Leonardo Branch)
```bash
ros2 launch rover_bringup rover_sim.launch
```

### Multi-Robot Simulation (Multi-Robot Branch)

**Important**: In multi-robot scenarios, the Gazebo Garden simulation is launched from the **uav_motion_stack container** (see [Prisma-Drone-Team/uav_motion_stack](https://github.com/Prisma-Drone-Team/uav_motion_stack)). This repository only launches the rover-specific components.

First, ensure both containers share the same ROS domain:
```bash
export ROS_DOMAIN_ID=17
```

Then launch only the rover components (without Gazebo):
```bash
ros2 launch rover_bringup rover_sim.launch
```

**Note**: `rover_sim.launch` contains fewer components compared to the standalone version, as the simulation environment and some shared services are managed by the uav_motion_stack container.

### Manual Robot Control
```bash
ros2 topic pub /rover/cmd_vel geometry_msgs/msg/Twist \
  '{linear: {x: 0.2}, angular: {z: 0.1}}' --once
```

### Autonomous Exploration
```bash
ros2 launch custom_explorer exploration.launch.py
```

## ROS2 Packages

### 🤖 rover_description_pkg
**Robot model and URDF descriptions**

Contains the complete robot description with sensors, actuators, and physical properties.

**Key Features:**
- Complete rover URDF with differential drive
- Camera, LiDAR, and IMU sensor models  
- Gazebo-compatible physics simulation
- Configurable meshes and visual materials

### 🗺️ rover_bringup
**Launch configurations and parameter management**

Central launch files for different simulation scenarios and hardware configurations.

**Main Launch Files:**
- `rover_sim.launch` - Complete simulation stack
- `navigation_launch.py` - Navigation stack only
- `slam_launch.py` - SLAM configuration

### 🌍 rover_gazebo  
**Gazebo simulation environment**

Provides world files, robot spawning, and simulation management.

**Key Features:**
- Leonardo race field environment
- Multi-robot world support
- Headless and GUI modes
- Automatic robot spawning and positioning

### 📡 custom_explorer
**Autonomous exploration algorithms**

Implements frontier-based exploration and area coverage for autonomous mapping.

**Main Topics:**
- **Subscriber:** `/map` (nav_msgs/OccupancyGrid) - Current map state
- **Publisher:** `/move_base_simple/goal` (geometry_msgs/PoseStamped) - Exploration targets
- **Publisher:** `/exploration_status` (std_msgs/String) - Mission status

### 🛣️ nav2_astar_planner
**A-star global path planning**

Advanced path planning algorithm with optimized search heuristics.

**Main Topics:**
- **Service:** `/ComputePathToPose` - Path computation service
- **Publisher:** `/plan` (nav_msgs/Path) - Computed trajectory

### 📷 yolov11_ros2
**Object detection and recognition**

Real-time object detection using state-of-the-art YOLOv11 neural networks.

**Main Topics:**
- **Subscriber:** `/rover/color/image_raw` (sensor_msgs/Image) - Camera input
- **Publisher:** `/detections` (vision_msgs/Detection2DArray) - Detected objects
- **Publisher:** `/detection_image` (sensor_msgs/Image) - Annotated image

### 🎯 aruco_detector_ocv_ros2
**ArUco marker detection and localization**

Provides precise localization using visual markers for navigation assistance.

**Main Topics:**
- **Subscriber:** `/rover/color/image_raw` (sensor_msgs/Image) - Camera feed
- **Publisher:** `/aruco_poses` (geometry_msgs/PoseArray) - Detected marker poses
- **Publisher:** `/aruco_markers` (aruco_msgs/MarkerArray) - Marker information

### 🔄 scan_merger
**Multi-sensor laser scan fusion**

Combines multiple laser scanners into unified sensor data for navigation.

**Main Topics:**
- **Subscriber:** `/scan1`, `/scan2` (sensor_msgs/LaserScan) - Individual scans 
- **Publisher:** `/scan_merged` (sensor_msgs/LaserScan) - Fused laser data

## Important Notes

**Simulation Environment**: This stack is optimized for Gazebo Garden simulation with ROS2 Humble. It provides complete UGV simulation capabilities for the H-CoRE framework.

**Multi-Robot Support**: The multi-robot branch enables seamless integration with other H-CoRE agents (drones, additional rovers) through shared simulation environments and coordinated control.

**Leonardo Environment**: The simulation includes the Leonardo race field environment, specifically designed for autonomous robot competitions and testing scenarios.

## Branch Differences

### Leonardo Branch
- **Standalone simulation** - Complete autonomous operation
- **Single robot focus** - Optimized for individual rover testing
- **Full navigation stack** - SLAM, path planning, and autonomous exploration
- **Hardware-ready** - Direct deployment capabilities to physical robots

### Multi-Robot Branch  
- **Shared simulation environment** - Multi-agent coordination capabilities
- **Container communication** - Enhanced Docker networking for agent interaction
- **Headless operation** - Optimized for server/cloud deployment
- **H-CoRE integration** - Seamless connection with drone and other ground agents

## Container Features

The Docker environment provides:
- **Automatic initialization** via `init_sim.sh`
- **Pre-built ROS2 workspace** with all dependencies
- **X11 forwarding** for GUI applications
- **Device access** for hardware sensors
- **Network host mode** for multi-robot communication