#include "simulation.h"
#include "kernels_custom.h"
#include <vector>

void simulationUpdate(std::vector<nbody::Body>& bodies, float dt, float G, float eps) {
    int n = bodies.size();
    size_t posSize = n * 2 * sizeof(float);
    size_t velSize = n * 2 * sizeof(float);
    size_t massSize = n * sizeof(float);

    // Prepare host arrays.
    std::vector<float> h_pos(n * 2), h_vel(n * 2), h_mass(n);
    for (int i = 0; i < n; i++) {
        h_pos[2 * i]     = bodies[i].pos[0];
        h_pos[2 * i + 1] = bodies[i].pos[1];
        h_vel[2 * i]     = bodies[i].vel[0];
        h_vel[2 * i + 1] = bodies[i].vel[1];
        h_mass[i]        = bodies[i].mass;
    }

    // Allocate device memory.
    float *d_pos, *d_vel, *d_mass;
    hipMalloc(&d_pos, posSize);
    hipMalloc(&d_vel, velSize);
    hipMalloc(&d_mass, massSize);

    // Copy data from host to device.
    hipMemcpy(d_pos, h_pos.data(), posSize, hipMemcpyHostToDevice);
    hipMemcpy(d_vel, h_vel.data(), velSize, hipMemcpyHostToDevice);
    hipMemcpy(d_mass, h_mass.data(), massSize, hipMemcpyHostToDevice);

    // Launch the HIP kernel.
    int threadsPerBlock = 256;
    int blocks = (n + threadsPerBlock - 1) / threadsPerBlock;
    hipLaunchKernelGGL(updateBodiesKernel, dim3(blocks), dim3(threadsPerBlock), 0, 0,
                         d_pos, d_vel, d_mass, n, dt, G, eps);
    hipDeviceSynchronize();

    // Copy the updated data back to host.
    hipMemcpy(h_pos.data(), d_pos, posSize, hipMemcpyDeviceToHost);
    hipMemcpy(h_vel.data(), d_vel, velSize, hipMemcpyDeviceToHost);

    // Update your bodies vector.
    for (int i = 0; i < n; i++) {
        bodies[i].pos[0] = h_pos[2 * i];
        bodies[i].pos[1] = h_pos[2 * i + 1];
        bodies[i].vel[0] = h_vel[2 * i];
        bodies[i].vel[1] = h_vel[2 * i + 1];
    }

    // Free device memory.
    hipFree(d_pos);
    hipFree(d_vel);
    hipFree(d_mass);
}
