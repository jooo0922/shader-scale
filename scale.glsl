#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

// shader-translate 예제에서 사용했던 bar() 함수와 동일하게 직사각형 그리는 함수
// 구체적인 설명 정리는 해당 예제 참고할 것.
float rect(vec2 loc, vec2 size, vec2 coord) {
  // 직사각형의 좌하단(sw)과 우상단(ne) 좌표를 정해주는 것임.
  vec2 sw = loc - size / 2.;
  vec2 ne = loc + size / 2.;

  float pad = 0.001; // 이전 예제와 달리 리턴값을 smoothstep()으로 계산할 거라서 sw나 ne에 더해주거나 빼줄 offset(padding)값이라고 보면 됨.
  vec2 ret = smoothstep(sw - pad, sw, coord);
  ret -= smoothstep(ne, ne + pad, coord);

  // ret 값은 padding 안쪽 영역에서는 (1, 1)이고, padding 바깥 영역은 무조건 0을 하나 이상 포함하고 있으며,
  // padding 영역은 보간된 값으로 계산되고 있으므로 0 ~ 1 사이의 값으로 된 좌표값이 할당될거임.
  // 따라서, padding 안쪽 영역은 1이 리턴되고, padding 바깥쪽 영역은 0,
  // padding 영역은 0 ~ 1 사이의 보간된 값들끼리 빼준 값이 리턴되겠지!
  return (ret.x * ret.y);
}

// 이전 예제에서 썼던 것처럼 십자가 도형을 그리는 함수
float cross(vec2 loc, vec2 size, vec2 coord) {
  float r1 = rect(loc, size, coord); // 가로로 누워있는 직사각형
  float r2 = rect(loc, size.yx, coord); // 세로로 누워있는 직사각형 -> size의 가로, 세로를 바꿔주면 되기 때문에 swizzle 문법을 사용해서 넘겨줌. (shader-color 예제 참고.)

  // r1, r2 값 중 적어도 하나가 1로 리턴된다면(즉, 적어도 하나라도 직사각형 영역에 속한다면) 
  // max() 내장함수를 통해 1을 리턴해주도록 함.
  return max(r1, r2);
}

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들 좌표값 normalize
  coord = coord * 2. - 1.; // 원점을 좌하단에서 캔버스 정가운데로 옮기기 위해 각 픽셀들 좌표값 Mapping
  coord.x *= u_resolution.x / u_resolution.y; // 캔버스를 resizing 해도 도형 왜곡이 없도록 해상도 비율값을 곱해줌.

  vec3 col = vec3(cross(vec2(.0), vec2(.55, .07), coord));
  gl_FragColor = vec4(col, 1.);
}