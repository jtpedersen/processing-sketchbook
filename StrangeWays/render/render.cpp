#include "render.h"
#include <array>
#include <cassert>
#include <random>
#include <algorithm>
#include <iterator>
#include <iostream>

using namespace std;
glm::vec3 pos;
glm::mat4 cam;

float cam_pos[3];
float cam_rotations[3];
float x_coeffs[10];
float y_coeffs[10];
float z_coeffs[10];

const int W = 800;
const int H = 600;

array<unsigned int,  W*H> canvas;
array<glm::vec3,  W*H> image;

void loadCoeffs(const char *filename) {
    std::ifstream ifs;
    ifs.open(filename);
    streamin(cam_pos, 3, ifs);
    streamin(cam_rotations, 3, ifs);
    streamin(x_coeffs, 10, ifs);
    streamin(y_coeffs, 10, ifs);
    streamin(z_coeffs, 10, ifs);
}

void streamin(float* dst, int cnt, std::ifstream& ifs) {
    for(int i = 0; i < cnt; i++)
	ifs >> dst[i] ;
    for(int i = 0; i < cnt; i++) 
	cout << dst[i] << endl;
    cout << endl;
}

void setupCamera() {
    cam = glm::lookAt(arr2vec(cam_pos),
		      glm::vec3(0.0),
		      glm::vec3(0,1,0));
}

glm::vec3 arr2vec(float * a) {
    return glm::vec3(a[0], a[1], a[2]);
}

void initCanvas() {
    for(auto& i: canvas)
	i = 0;
}

void step() {
    glm::vec3 next;
    next.x = quad_iterate(pos, x_coeffs);
    next.y = quad_iterate(pos, y_coeffs);
    next.z = quad_iterate(pos, z_coeffs);
    pos = next;
}

float quad_iterate(glm::vec3 p, float* a) {
  float res = 0;
  res += a[0];

  res += a[1]*p.x;
  res += a[2]*p.y;
  res += a[3]*p.z;

  res += a[4]*p.x*p.x;
  res += a[5]*p.y*p.y;
  res += a[6]*p.z*p.z;

  res += a[7]*p.x*p.y;
  res += a[8]*p.x*p.z;
  res += a[9]*p.y*p.z;

  return res;
}

void warmup() {
    pos = glm::vec3(.5, .78, -1.4);     // random start posistion
    for(int i = 0; i < 100; i++) {
	step();
    }
}

void iterate(unsigned int cnt) {
    for(unsigned int i = 0 ; i < cnt; i++) {
	step();
	registerPosistionToCanvas();
    }
}

void registerPosistionToCanvas() {
    glm::vec4 projected = cam * glm::vec4(pos, 0);
    const static float inv_w = 1.0 / W;
    const static float inv_h = 1.0 / H;
    int x = 10000 * projected.x * inv_w;
    int y = 10000 * projected.y * inv_h;
    canvas[y*W +x]++;
}

void tonemap() {
    unsigned int maxHits = 0;
    for(auto c: canvas)
	maxHits = c > maxHits ? c : maxHits;
    float inv_scale = 1.0 / maxHits;
    for(int i = 0; i < W*H; i++) {
	image[i] = glm::rgbColor(glm::vec3(canvas[i] * inv_scale, .7, .8));
    }
    cout << "When tonemapping, ze largest cnt was: " << maxHits << endl;

}

void saveImage() {
    ofstream ofs;
    ofs.open("file.ppm", std::ofstream::out | std::ofstream::binary);
    ofs << "P6\n" << W << " " << H << "\n255\n";
    for(glm::vec3 c: image) {
	ofs <<  static_cast<unsigned char>(c.x * 255);
	ofs <<  static_cast<unsigned char>(c.y * 255);
	ofs <<  static_cast<unsigned char>(c.z * 255);
    }
    ofs.close();
}

void cleanup() {
    // 
}
int main(int argc, char **argv) {
    if (argc < 1) {
	cout << "give my a file" << endl;
	exit(1);
    }
    loadCoeffs(argv[1]);
    setupCamera();
    initCanvas();
    warmup();
    iterate(1000000);
    tonemap();
    saveImage();
    cleanup();
}



