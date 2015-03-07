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

const int W = 2048;
const int H = 2048;
const float inv_w = 1.0 / W;
const float inv_h = 1.0 / H;


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
    // for(int i = 0; i < cnt; i++) 
    // 	cout << dst[i] << endl;
    // cout << endl;
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
    assert(isfinite(next.x));
    assert(isfinite(next.y));
    assert(isfinite(next.z));
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
    for(int i = 0; i < 10000; i++) {
	step();
    }
}

glm::vec2 projected_min;
glm::vec2 projected_max;
glm::vec2 canvas_offset;
float canvas_range;
float canvas2ImageScaling;

void measureBounds() {
    glm::vec4 projected = cam * glm::vec4(pos, 0);
    projected_max = projected_min = glm::vec2(projected.x, projected.y);
    for(int i = 0; i < 100000; i++) {
	step();
	glm::vec4 projected = cam * glm::vec4(pos, 0);
	projected_max.x = std::max(projected.x, projected_max.x);
	projected_max.y = std::max(projected.y, projected_max.y);
	projected_min.x = std::min(projected.x, projected_min.x);
	projected_min.y = std::min(projected.y, projected_min.y);
    }
    cout << glm::to_string(projected_min) << " ---- " << glm::to_string(projected_max) << endl;

    // create projecting mappings
    glm::vec2 ranges = projected_max - projected_min;
    // select largest /XXXXXXX think about aspect ratios
    canvas_range = std::max(ranges.x, ranges.y);
    glm::vec2 center = (projected_min + projected_max) * 0.5f;
    // create offset and add little border
    canvas_offset.x = (center.x - (canvas_range * 0.6f)) * -1.0f;
    canvas_offset.y = (center.y - (canvas_range * 0.6f)) * -1.0f;
    
    int image_range = canvas_range == ranges.x ? W : H;
    canvas2ImageScaling = (float)image_range / (1.2 * canvas_range);

    cout << "Scaling stuff: offset:\n" << glm::to_string(canvas_offset) << " and scaling: " << canvas2ImageScaling << endl;

    assert((projected_min + canvas_offset).x >= 0);
    assert((projected_min + canvas_offset).y >= 0);

    assert((projected_min + canvas_offset).x * canvas2ImageScaling < W);
    assert((projected_min + canvas_offset).y * canvas2ImageScaling < H);
    assert((projected_max + canvas_offset).x * canvas2ImageScaling >= 0);
    assert((projected_max + canvas_offset).y * canvas2ImageScaling >= 0);
    assert((projected_max + canvas_offset).x * canvas2ImageScaling < W);
    assert((projected_max + canvas_offset).y * canvas2ImageScaling < H);

}

void iterate(size_t cnt) {
    for(size_t i = 0 ; i < cnt; i++) {
	step();
	registerPosistionToCanvas();
	if (i% (cnt/100) == 0)
	    cout << "." << endl;
    }
}

void registerPosistionToCanvas() {

    glm::vec4 projected = cam * glm::vec4(pos, 0);
    glm::vec2 canvas_space(projected.x, projected.y);
    canvas_space += canvas_offset;
    // cout << glm::to_string(canvas_space) << endl;
    glm::ivec2 pixel = glm::ivec2(canvas_space * canvas2ImageScaling);
    // clamp and discard
    if (pixel.x >= 0 && pixel.x < W && pixel.y >= 0 && pixel.y < H)
	canvas[pixel.y*W + pixel.x]++;
    // else
    // 	cout << "discard pixel: " << glm::to_string(pixel) << endl;
    // static ofstream fileOut;
    // if (!fileOut.is_open())
    // 	fileOut.open("foo.dat");
    // fileOut << pos.x << " " << pos.y << " " << pos.z << " " << pixel.x << " " << pixel.y << endl;
}



void tonemap() {
    unsigned int maxHits = 0;
    for(auto c: canvas)
	maxHits = c > maxHits ? c : maxHits;
    float inv_scale = 1.0 / maxHits;
    for(int i = 0; i < W*H; i++) {
	if (canvas[i] > 0) 
	    image[i] = glm::rgbColor(glm::vec3(canvas[i] * canvas[i] * inv_scale, .7, .8));
	// cout << canvas[i] << (( i%80 == 79 ) ? "\n" : " ");
	// if ( i > (H/2*W) && i < ((10 + H)/2*W)) 
	//     cout << glm::to_string(image[i]) << (( i%80 == 79 ) ? "\n" : " ");


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
    measureBounds();
    iterate(1000000000);
    tonemap();
    saveImage();
    cleanup();
}
