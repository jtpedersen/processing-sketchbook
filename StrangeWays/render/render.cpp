#include "render.h"
#include <thread>
#include <cassert>
#include <random>
#include <algorithm>
#include <iterator>
#include <iostream>
#include <limits>

using namespace std;
glm::vec3 pos;
glm::mat4 cam;

float cam_pos[3];
float cam_rotations[3];
float x_coeffs[10];
float y_coeffs[10];
float z_coeffs[10];

const float inv_w = 1.0 / W;
const float inv_h = 1.0 / H;

array<unsigned int,  W*H> canvas;
array<float,  W*H> zbuffer;

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
    cam = cam * glm::rotate(cam_rotations[0], glm::vec3(1.0f, 0.0f, 0.0f));
    cam = cam * glm::rotate(cam_rotations[1], glm::vec3(0.0f, 1.0f, 0.0f));
    cam = cam * glm::rotate(cam_rotations[2], glm::vec3(0.0f, 0.0f, 1.0f));
}

glm::vec3 arr2vec(float * a) {
    return glm::vec3(a[0], a[1], a[2]);
}

void initCanvas() {
    for(auto& i: canvas)
	i = 0;
    for(auto& z: zbuffer)
	z = std::numeric_limits<float>::max();

}

glm::vec3 step(glm::vec3 p) {
    glm::vec3 next;
    next.x = quad_iterate(p, x_coeffs);
    next.y = quad_iterate(p, y_coeffs);
    next.z = quad_iterate(p, z_coeffs);
    assert(isfinite(next.x));
    assert(isfinite(next.y));
    assert(isfinite(next.z));
    return next;
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

glm::vec3 randomPos() {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_real_distribution<> posDis(-.2, .2);
    return glm::vec3(posDis(gen),posDis(gen),posDis(gen));
}

void warmup() {
    pos = randomPos();
    for(int i = 0; i < 10000; i++) {
	pos = step(pos);
    }
}

glm::vec2 projected_min;
glm::vec2 projected_max;
glm::vec2 canvas_offset;
float canvas_range;
float canvas2ImageScaling;
glm::vec3 aabb_max, aabb_min;

void measureBounds() {
    aabb_max = aabb_min = pos;
    for(int i = 0; i < 100000; i++) {
	pos = step(pos);
	aabb_max.x = std::max(pos.x, aabb_max.x);
	aabb_max.y = std::max(pos.y, aabb_max.y);
	aabb_max.z = std::max(pos.z, aabb_max.z);
	aabb_min.x = std::min(pos.x, aabb_min.x);
	aabb_min.y = std::min(pos.y, aabb_min.y);
	aabb_min.z = std::min(pos.z, aabb_min.z);
    }
    cout << glm::to_string(aabb_min) << " ---- " << glm::to_string(aabb_max) << endl;
    auto center = (aabb_max + aabb_min) * 0.5f;
    cout << "Center: " << glm::to_string(center) << endl;
    // move to center
//    cam  = glm::translate(cam, -center);

    // project all corners to screen to see how it must be scale to fill image nicely
    auto p = cam * glm::vec4(aabb_min, 0.0f);
    projected_max = projected_min = glm::vec2(p.x, p.y);
    for(int i = 0; i < 8; i++)  {
	float x = (i & 0x1) ? aabb_min.x : aabb_max.x;
	float y = (i & 0x2) ? aabb_min.y : aabb_max.y;
	float z = (i & 0x4) ? aabb_min.z : aabb_max.z;
	glm::vec4 projected = cam * glm::vec4(x,y,z, 1.0);
	projected_min.x = min(projected.x, projected_min.x);
	projected_min.y = min(projected.y, projected_min.y);
	projected_max.x = max(projected.x, projected_max.x);
	projected_max.y = max(projected.y, projected_max.y);
    }
    cout << glm::to_string(projected_min) << " ---- " << glm::to_string(projected_max) << endl;
    auto range = projected_max - projected_min;
    float scale = (range.x > range.y ? W : H) / max(range.x, range.y);
    cout << "Scale: " << scale << endl;
    cam = glm::scale(cam, glm::vec3(scale));
    cout << "CAM: " << glm::to_string(cam) << endl;

}


void registerPosistionToCanvas(Canvas& canvas, const glm::vec3& p) {
    glm::vec4 projected = cam * glm::vec4(p, 1.0);
    // glm::vec2 canvas_space(projected.x, projected.y);
    // //canvas_space += canvas_offset;
    // // cout << glm::to_string(canvas_space) << endl;
    // glm::ivec2 pixel = glm::ivec2(canvas_space * canvas2ImageScaling);
    glm::ivec2 pixel = glm::ivec2(projected.x - projected_min.x, projected.y - projected_min.y);
    // clamp and discard
    if (pixel.x >= 0 && pixel.x < W && pixel.y >= 0 && pixel.y < H) {
	size_t idx = pixel.y*W + pixel.x;
	// check zbuffer
	// if (zbuffer[idx] > projected.z) {
	    canvas[idx]++;
	//     zbuffer[idx] = projected.z;
	// }
    }   // else
    // 	cout << "discard pixel: " << glm::to_string(pixel) << endl;
    // static ofstream fileOut;
    // if (!fileOut.is_open())
    // 	fileOut.open("foo.dat");
    // fileOut << pos.x << " " << pos.y << " " << pos.z << " " << pixel.x << " " << pixel.y << endl;
}


void threadIterate(size_t cnt, Canvas& canvas) {

    // clear
    for(auto& bin: canvas)
	bin  = 0;
    // varmup
    auto p = randomPos();
    for(size_t i = 0 ; i < 10000; i++) 
	p = step(p);

    size_t i = 0;
    while(i < cnt) {
	for(size_t j = 0 ; j < cnt/100; j++) {
	    p = step(p);
	    registerPosistionToCanvas(canvas, p);
	}
	i += cnt/100;
	cout << "\r" << (i / (cnt/100)) << " %" << std::flush;
	
    }
}

Canvas iterate(size_t cnt) {
    const int threadCount = 4;
    std::array< Canvas, threadCount> canvis;
    std::thread workers[threadCount];
    for(int i = 0; i < threadCount; i++) {
	workers[i] = std::thread(threadIterate, (size_t)(cnt/threadCount), std::ref(canvis[i]));    }

    for(int i = 0; i < threadCount; i++) {
	workers[i].join();
    }
    // merge
    for(unsigned int i = 1; i < threadCount; i++) {
	for(unsigned int j = 0; j < canvis[i].size(); j++)
	    canvis[0][j] += canvis[i][j];
    }
    return canvis[0];
}


float de(const Canvas& c, int x, int y) {
    float res = c[x + y *W];
    res += .5 * c[(x+1) + y * W];
    res += .5 * c[(x-1) + y * W];
    res += .5 * c[x + (y+1) * W];
    res += .5 * c[x + (y-1) * W];

    res += .24 * c[(x+1) + (y+1) * W];
    res += .24 * c[(x-1) + (y-1) * W];
    res += .24 * c[(x+1) + (y-1) * W];
    res += .24 * c[(x-1) + (y+1) * W];


    return res * (1.0  / ( .5 * 4.0 + .24 * 4.0));
}

Image tonemap(const Canvas& canvas) {
    unsigned int maxHits = 0;
    for(auto c: canvas)
	maxHits = c > maxHits ? c : maxHits;
    float inv_scale = 1.0 / maxHits;
    Image image;
    for(int j = 1; j < H-1; j++) {
	for(int i = 1; i < W-1; i++) {
	    auto idx = i + j * W;
	    auto cnt = de(canvas, i, j);
	if (cnt > 0) 
	    image[idx] = glm::rgbColor(glm::vec3(pow(cnt, 5) * inv_scale, .7, .8));
	// cout << canvas[i] << (( i%80 == 79 ) ? "\n" : " ");
	// if ( i > (H/2*W) && i < ((10 + H)/2*W)) 
	//     cout << glm::to_string(image[i]) << (( i%80 == 79 ) ? "\n" : " ");
	}

    }
    cout << "When tonemapping, ze largest cnt was: " << maxHits << endl;
    return image;
}

void saveImage(const Image& image) {
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
    const char *filename = "default.dump";
    size_t iterations = 10000000;
    if (argc < 1) {
	cout << "give my a file" << endl;
	exit(1);
    }
    filename = argv[1];
    if (argc > 2) {
	iterations = atol(argv[2]);
    }
    loadCoeffs(filename);
    setupCamera();
    initCanvas();
    warmup();
    measureBounds();
    measureBounds();
    auto canvas = iterate(iterations);
    auto img = tonemap(canvas);
    saveImage(img);
    cleanup();
}
