#include "body.h"
#include "simulation.h"
#include <GLFW/glfw3.h>
#include <vector>
#include <random>
#include <cmath>
#include <cstdio>
#include <chrono>
#include <thread>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define SCREEN_WIDTH 800
#define SCREEN_HEIGHT 600

int main() {
    // Initialize GLFW.
    if (!glfwInit()) return -1;
    GLFWwindow* window = glfwCreateWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "HIP Accelerated Galaxy Collision", NULL, NULL);
    if (!window) { glfwTerminate(); return -1; }
    glfwMakeContextCurrent(window);

    // Set up orthographic projection.
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-1, 1, -1, 1, -1, 1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glPointSize(2.0f);

    // Initialize bodies (example: two galaxies with different colors).
    std::vector<nbody::Body> bodies;
    const float denseMass = 1000.0f;
    const float orbiterMass = 1.0f;
    const int numOrbiters = 10000;
    const float G = 1.0f;
    float timeScale = 0.01f;
    float dt = 0.001f * timeScale;
    float eps = 1e-5f;


    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_real_distribution<float> distAngle(0.0f, 2.0f * M_PI);
    std::uniform_real_distribution<float> distUniform(0.0f, 1.0f);

    // ----- Left Galaxy -----
    // Central body for the left galaxy.
    nbody::Body leftCentral;
    leftCentral.pos[0] = -0.5f;
    leftCentral.pos[1] = 0.0f;
    leftCentral.vel[0] = 0.05f;  // x vel
    leftCentral.vel[1] = 0.0f;
    leftCentral.mass   = denseMass;
    leftCentral.galaxy = 0;
    bodies.push_back(leftCentral);

    float leftGroupRadius = 0.2f;
    for (int i = 0; i < numOrbiters; i++) {
        nbody::Body b;
        float angle = distAngle(gen);
        float r = leftGroupRadius * std::sqrt(distUniform(gen));
        b.pos[0] = leftCentral.pos[0] + r * std::cos(angle);
        b.pos[1] = leftCentral.pos[1] + r * std::sin(angle);
        b.mass   = orbiterMass;
        float speed = std::sqrt(G * leftCentral.mass / (r + 0.001f));
        // Set velocity perpendicular to the radius vector (for a circular orbit)
        b.vel[0] = leftCentral.vel[0] - speed * std::sin(angle);
        b.vel[1] = leftCentral.vel[1] + speed * std::cos(angle);
        b.galaxy = 0;  // Same galaxy ID.
        bodies.push_back(b);
    }

    // ----- Right Galaxy -----
    // Central body for the right galaxy.
    nbody::Body rightCentral;
    rightCentral.pos[0] = 0.5f;
    rightCentral.pos[1] = 0.0f;
    rightCentral.vel[0] = -0.05f;  // x vel
    rightCentral.vel[1] = 0.0f;
    rightCentral.mass   = denseMass;
    rightCentral.galaxy = 1;
    bodies.push_back(rightCentral);

    float rightGroupRadius = 0.2f;
    for (int i = 0; i < numOrbiters; i++) {
        nbody::Body b;
        float angle = distAngle(gen);
        float r = rightGroupRadius * std::sqrt(distUniform(gen));
        b.pos[0] = rightCentral.pos[0] + r * std::cos(angle);
        b.pos[1] = rightCentral.pos[1] + r * std::sin(angle);
        b.mass   = orbiterMass;
        float speed = std::sqrt(G * rightCentral.mass / (r + 0.001f));
        b.vel[0] = rightCentral.vel[0] - speed * std::sin(angle);
        b.vel[1] = rightCentral.vel[1] + speed * std::cos(angle);
        b.galaxy = 1;
        bodies.push_back(b);
    }

    std::printf("Total bodies: %lu\n", bodies.size());


    while (!glfwWindowShouldClose(window)) {

        simulationUpdate(bodies, dt, G, eps); // HIP implementation

        // Rendering
        glClear(GL_COLOR_BUFFER_BIT);
        glLoadIdentity();
        glBegin(GL_POINTS);
        for (const auto &b : bodies) {
            if (b.galaxy == 0) {
                glColor3f(1.0f, 0.5f, 0.0f);  // Orange
            } else if (b.galaxy == 1) {
                glColor3f(0.0f, 0.0f, 1.0f);  // Blue
            } else {
                glColor3f(1.0f, 1.0f, 1.0f);
            }
            glVertex2f(b.pos[0], b.pos[1]);
        }
        glEnd();
        glfwSwapBuffers(window);
        glfwPollEvents();

        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}