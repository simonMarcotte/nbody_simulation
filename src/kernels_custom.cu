#include "kernels_custom.h"
#include <math.h>

__global__ void updateBodiesKernel(float* pos, float* vel, const float* mass, int n, float dt, float G, float eps) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n) {
        // Each body has 2 components (x and y)
        float xi = pos[2 * i];
        float yi = pos[2 * i + 1];
        float ax = 0.0f;
        float ay = 0.0f;
        for (int j = 0; j < n; j++) {
            if (i == j) continue;
            float dx = pos[2 * j] - xi;
            float dy = pos[2 * j + 1] - yi;
            float distSq = dx * dx + dy * dy + eps;
            float r = sqrtf(distSq);
            float a = G * mass[j] / distSq;
            ax += a * dx / r;
            ay += a * dy / r;
        }
        // Update velocity and position
        vel[2 * i]     += ax * dt;
        vel[2 * i + 1] += ay * dt;
        pos[2 * i]     += vel[2 * i] * dt;
        pos[2 * i + 1] += vel[2 * i + 1] * dt;
    }
}
