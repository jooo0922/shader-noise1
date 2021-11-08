#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들 좌표값 normalize
  coord.x *= u_resolution.x / u_resolution.y; // 캔버스를 resizing 해도 왜곡이 없도록 좌표값에 해상도비율값 곰해줌.

  vec3 col;

  gl_FragColor = vec4(col, 1.);
}

/*
  noise vs random

  random은 인접한 요소들의 값이  
  예를 들면, 1 과 1000 처럼
  값 차이가 지나치게 크게 나는 값이 나올수도 있음.

  반면, noise는 인접한 요소들의 값이
  저렇게 급격하게 분절되지 않고 
  인접한 요소들끼리는 값이 이어지는 특성이 있음.

  그래서 random은 모양새가 자글자글하고 값을 예측할 수 없지만,
  noise는 값이 부드럽게 이어지긴 하지만, 
  random과 마찬가지로 다음에 어떤 값이 나올 지 예측하기 어렵고 변칙적임.

  noise-and-random.png 이미지 참고.
*/

/*
  noise 를 만드는 방법


  noise도 random 처럼 어떤 특수한 내장함수가 존재하는 것이 아니라,
  사람들이 직접 알고리즘을 짜서 pseudo code 를 만들어내는 것임.

  기본적인 코드는 다음과 같음

  float i = floor(x);  // 각 픽셀들 x좌표값의 정수부분만 가져옴
  float f = fract(x);  // 각 픽셀들 x좌표값의 소수부분만 가져옴

  // 이제 각 픽셀들의 x좌표값의 정수와 그 다음 정수를 넣어서 
  // random 예제에서 사용했던 랜덤함수로 랜덤값을 리턴받아오고,
  // 두 랜덤값을 f만큼의 비율로 섞어주는 것임.
  // 이 방법의 문제는 뭐냐면, x좌표값의 정수부분이 바뀌는 지점에서 
  // y좌표값이 부드럽게 변환되는 게 아니라 분절이 되어버림.
  // 근데 noise는 위에서도 말했지만 인접한 x좌표값들 끼리는 y좌표값이 부드럽게 이어져야 하는 거잖아.
  // 그거를 다음 줄의 코드에서 해주는거지. 
  y = mix(rand(i), rand(i + 1.0), f); 

  // smoothstep() 내장함수를 이용해서 섞어주는 비율값 f를 보간되는 값으로 리턴시켜 줌.
  // 왜냐면, f값 자체가 각 픽셀들 x좌표값의 소수부분이니까 0 ~ 1 사이일거 아냐
  // 근데 smoothstep(0.,1.,f) 이렇게 해놨으면 f가 0보다 작거나, 1보다 클 일은 없으니까
  // 0 ~ 1 사이의 보간된 값이 나오겠지.
  // 따라서 이 보간된 비율값으로 랜덤값을 섞어주면 인접한 x좌표값들끼리는 y좌표값이 부드럽게 이어지도록 할 수 있음.
  y = mix(rand(i), rand(i + 1.0), smoothstep(0.,1.,f));
*/