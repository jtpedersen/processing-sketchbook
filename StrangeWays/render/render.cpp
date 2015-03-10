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

void measureBounds() {
    glm::vec4 projected = cam * glm::vec4(pos, 0);
    projected_max = projected_min = glm::vec2(projected.x, projected.y);
    for(int i = 0; i < 100000; i++) {
	pos = step(pos);
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
    canvas_offset.x = (center.x - (canvas_range * 0.525f)) * -1.0f;
    canvas_offset.y = (center.y - (canvas_range * 0.525f)) * -1.0f;
    
    int image_range = canvas_range == ranges.x ? W : H;
    canvas2ImageScaling = (float)image_range / (1.05 * canvas_range);

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

// if (i% (cnt/100) == 0)
	//     cout << "\r" << (i / (cnt/100)) << " %" << std::flush;
    return canvis[0];
}

void registerPosistionToCanvas(Canvas& canvas, const glm::vec3& p) {
    glm::vec4 projected = cam * glm::vec4(p, 0);
    glm::vec2 canvas_space(projected.x, projected.y);
    canvas_space += canvas_offset;
    // cout << glm::to_string(canvas_space) << endl;
    glm::ivec2 pixel = glm::ivec2(canvas_space * canvas2ImageScaling);
    // clamp and discard
    if (pixel.x >= 0 && pixel.x < W && pixel.y >= 0 && pixel.y < H) {
	size_t idx = pixel.y*W + pixel.x;
	// check zbuffer
	// if (zbuffer[idx] > projected.z) {
	    canvas[idx]++;
	//     zbuffer[idx] = projected.z;
	// }
    }
    // else
    // 	cout << "discard pixel: " << glm::to_string(pixel) << endl;
    // static ofstream fileOut;
    // if (!fileOut.is_open())
    // 	fileOut.open("foo.dat");
    // fileOut << pos.x << " " << pos.y << " " << pos.z << " " << pixel.x << " " << pixel.y << endl;
}



Image tonemap(const Canvas& canvas) {
    unsigned int maxHits = 0;
    for(auto c: canvas)
	maxHits = c > maxHits ? c : maxHits;
    float inv_scale = 1.0 / maxHits;
    Image image;
    for(int i = 0; i < W*H; i++) {
	if (canvas[i] > 0) 
	    image[i] = glm::rgbColor(glm::vec3(pow(canvas[i], 3) * inv_scale, .7, .8));
	// cout << canvas[i] << (( i%80 == 79 ) ? "\n" : " ");
	// if ( i > (H/2*W) && i < ((10 + H)/2*W)) 
	//     cout << glm::to_string(image[i]) << (( i%80 == 79 ) ? "\n" : " ");


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
    auto canvas = iterate(iterations);
    auto img = tonemap(canvas);
    saveImage(img);
    cleanup();
}
