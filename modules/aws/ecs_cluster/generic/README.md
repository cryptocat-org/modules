# Generic ECS Cluster Module

This module deploys an ECS Cluster with an Autoscaling Group and Security Group. It supports both EC2 and Fargate capacity providers.

## Features

- **EC2 Capacity Provider**:
  - Deploys an Autoscaling Group for managing EC2 instances.
  - Configures a Security Group for the instances.
  - Supports defining on-demand or spot instances.

- **Fargate Capacity Provider**:
  - Enables serverless ECS tasks and services.

This module is designed to simplify the deployment of scalable ECS Clusters with flexible compute options.
