#pragma once

#include <hip/hip_runtime.h>

__global__ void updateBodiesKernel(float* pos, float* vel, const float* mass, int n, float dt, float G, float eps);

