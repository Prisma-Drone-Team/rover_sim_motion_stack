xhost +local:root
IMAGE_ID=$(docker images -q $1)
WORKSPACE_DIR=$(pwd)/src
docker run --rm -it --name=$2 --net=host -e GZ_PARTITION=shared_world -e GZ_VERBOSE=4  --env="DISPLAY=$DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:ro" --privileged -v /dev:/dev --volume=${WORKSPACE_DIR}/pkg:/home/user/rover_ws/src/pkg -v $(pwd)/init_sim.sh:/home/user/init_sim.sh:rw  $1 /home/user/init_sim.sh
xhost -local:root