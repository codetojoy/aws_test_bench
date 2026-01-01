#!/bin/bash

# normal destroy never seems to work
# Claude recommended this, which worked after the normal one was grinding for 10 minutes.

# terraform destroy -target=aws_ecs_service.main
# terraform destroy -target=aws_autoscaling_group.ecs
# terraform destroy -target=aws_launch_template.ecs
# sleep 45
# terraform destroy


