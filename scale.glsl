#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들 좌표값 normalize
  coord = coord * 2. - 1.; // 원점을 좌하단에서 캔버스 정가운데로 옮기기 위해 각 픽셀들 좌표값 Mapping
  coord.x *= u_resolution.x / u_resolution.y; // 캔버스를 resizing 해도 도형 왜곡이 없도록 해상도 비율값을 곱해줌.

  vec3 col;
  gl_FragColor = vec4(col, 1.);
}