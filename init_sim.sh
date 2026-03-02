#!/bin/bash

# Definizione colori ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

echo -e "${CYAN}======================================================${NC}"
echo -e "${GREEN}   🚗 H-CoRE UGV Simulation Container Init${NC}" 
echo -e "${CYAN}======================================================${NC}" 

# Setup ROS2 environment
echo -e "${BLUE}🔧 Setting up ROS2 environment...${NC}" 
cd ~/rover_ws
source /opt/ros/humble/setup.bash

# Build PX4 workspace
echo -e "${BLUE}📦 Building ROS2 workspace...${NC}"
colcon build
source install/setup.bash
export ROS_DOMAIN_ID=17

echo -e "${CYAN}======================================================${NC}"
echo -e "${WHITE}🚀 HOW TO RUN THE SIMULATION:${NC}"
echo -e "${YELLOW}  - $ ros2 launch rover_bringup rover_sim.launch${NC}"
echo -e "${CYAN}======================================================${NC}"

# Avvia bash interattivo
exec bash