#ifndef RENDER_H_
#define RENDER_H_

#include <fstream>

#define GLM_FORCE_RADIANS
#include <glm/vec2.hpp>// glm::vec2
#include <glm/vec3.hpp>// glm::vec3
#include <glm/vec4.hpp>// glm::vec4
#include <glm/mat4x4.hpp> // glm::mat4
#include <glm/gtc/matrix_transform.hpp> //lookAt etc
#include <glm/gtx/color_space.hpp>
#include <glm/ext.hpp> // << friends

void loadCoeffs(const char *filename);
void streamin(float* dst, int cnt, std::ifstream& ifs);
void setupCamera();
glm::vec3 arr2vec(float * a);
void initCanvas();
void step();
float quad_iterate(glm::vec3 p, float* a);
void cleanup();
void warmup();
void measureBounds();
void iterate(size_t cnt);
void registerPosistionToCanvas();
void tonemap();
void saveImage();


#endif /* !RENDER_H_ */
