#ifndef RENDER_H_
#define RENDER_H_

#include <fstream>
#include <array>

#define GLM_FORCE_RADIANS
#define GLM_SWIZZLE 
#include <glm/vec2.hpp>// glm::vec2
#include <glm/vec3.hpp>// glm::vec3
#include <glm/vec4.hpp>// glm::vec4
#include <glm/mat4x4.hpp> // glm::mat4
#include <glm/gtc/matrix_transform.hpp> //lookAt etc
#include <glm/gtx/transform.hpp>
#include <glm/gtx/color_space.hpp>
#include <glm/ext.hpp> // << friends

#define W 4096
#define H 4096

using Canvas = std::array<unsigned int, W*H>;
using Image  = std::array<glm::vec3,  W*H>;

void loadCoeffs(const char *filename);
void streamin(float* dst, int cnt, std::ifstream& ifs);
void setupCamera();
glm::vec3 randomPos();
glm::vec3 arr2vec(float * a);
void initCanvas();
glm::vec3 step(glm::vec3 p);
float quad_iterate(glm::vec3 p, float* a);
void cleanup();
void warmup();
void measureBounds();
Canvas iterate(size_t cnt);
void registerPosistionToCanvas(Canvas& canvas, const glm::vec3& p);
Canvas histogramEqualize(const Canvas& canvas);
Canvas DEFilter(const Canvas& canvas, int cnt);
Image tonemap(const Canvas& canvas);
void saveImage(const Image&);
void thread_iterate(size_t cnt, Canvas& canvas);

#endif /* !RENDER_H_ */
