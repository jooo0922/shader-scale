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

  // 각 픽셀들 좌표값에 1 보다 작은 값을 곱해주면 십자가가 커지고, 
  // 1 보다 큰 값을 곱해주면 십자가가 작아짐. 엄청 간단한 원리.
  coord = coord * sin(u_time);

  vec3 col = vec3(cross(vec2(.0), vec2(.55, .07), coord));
  gl_FragColor = vec4(col, 1.);
}

/*
  각 픽셀들 좌표값에 특정 값을 곱해줘서 scale 변환을 적용하는 원리


  의외로 프래그먼트 셰이더에서 scale 변환을 구현하는 것은 간단했음.
  그런데 약간 의문이 드는 점이 있지.

  직관적으로 생각했을 때, 큰 값을 곱해주면 scale이 커져야 할 것 같고,
  작은 값을 곱해주면 scale이 작아져야 할 것 같은데,

  왜 1보다 큰 값을 곱하면 십자가가 작아지고, 1보다 작은 값을 곱하면 십자가가 커질까?
  
  원래 캔버스의 좌표계 범위는 좌하단 (0, 0) ~ 우상단 (1, 1) 이었지?
  
  근데 이거를 main 함수에서 원점을 정가운데로 옮기느라 
  좌하단 (-1, -1) ~ 우상단(1, 1) 으로 범위가 바뀌도록 픽셀들 좌표값을 Mapping했지!

  이때, 우리가 각 픽셀들 좌표값에 2.0을 곱해준다면,
  좌표계의 범위는 좌하단(-2, -2) ~ 우상단 (2, 2)로 범위가 4배가 늘어나게 되는거임.

  좌표계로 표현할 수 있는 좌표값의 범위가 늘어났는데,
  좌표계의 '시각적인' 크기는 그대로라면,
  그 안에 그려지는 도형(십자가)의 크기는 '시각적으로는 작아보이게' 되는 거지!
  하지만, 십자가의 실제 사이즈가 작아지는 건 아님.

  좌표계 범위가 커지다 보니, 십자가의 사이즈가 작아져 보이는 것.
  마치 더 커진 화면을 더 먼 거리에서 바라볼 때, 화면 안의 요소들이 작게 보이는 것과 같은 원리임.


  결론적으로 말하면, scale 변환을 적용하기 위해 곱해주는 값은
  '그 값이 클수록, 좌표계 범위를 키운다' 라고 생각하면 이해가 빠를것임.
  좌표계의 범위가 커진다면, 그 안에 그려지는 십자가는 '시각적으로만' 작아보이는 것임! 
  
*/