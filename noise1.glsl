#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// 이 예제에서 사용할 랜덤함수는 첫 번째 랜덤함수인 float / float 랜덤함수
// 코드에 대한 자세한 설명은 shader-random1 예제 참고
float random(float f) {
  // 리턴값은 0 ~ 1 사이의 소수값만 리턴해주도록 fract()로 소수부분만 잘라줌.
  return fract(sin(f * 654.876) * 915.876);
}

// 이제 랜덤값을 가지고 noise를 만드는 노이즈 함수를 만들거임.
// 참고로 이번에는 float / float 형태를 사용할 것이고, 
// thebookofshader.com 의 노이즈 예제에서 그래프 그릴 때 사용한 코드를 그대로 사용하면 됨.
// 매개변수 val에는 각 픽셀들의 x좌표값을 0 ~ 10으로 Mapping 시켜 확대한 값이 들어올거임.
float noise(float val) {
  float i = floor(val);
  float f = fract(val);

  float ret;

  // 0 ~ 10 으로 범위를 확대한 x좌표값의 정수부분이 같은 픽셀들끼리 같은 랜덤값(0 ~ 1 사이의 fract값)을 리턴받음.
  // 따라서, x좌표값의 정수부분이 같은 픽셀들은 같은 색상이 찍히게 됨.
  // 이거는 아직까진 노이즈라고 할 수는 없음. 그냥 정수부분이 같은 영역은 같은 색상을 찍어준 것.
  // ret = random(i);

  // 같은 x좌표값의 정수부분을 공유하는 영역 내에서 mix() 함수를 이용해 그라데이션을 먹여줌.
  // 그러나, 맨밑에 정리한 필기에서도 말했듯이 정수부분이 바뀌는 지점에서 자연스럽지 못한 분절이 일어남.
  // 그래서 캔버스에서도 아직까지는 색상간의 경계가 부드럽게 연결되지는 않게 그려짐.
  // 이거는 좋은 노이즈가 아님. 경계를 최대한 부드럽게 깎아줘야 좋은 노이즈라고 할 수 있음.
  // ret = mix(random(i), random(i + 1.), f);

  // smoothstep() 으로 mix해주는 비율값 f를 보간해줌으로써,
  // 캔버스에 찍히는 색상간의 경계가 아까보다 더 부드러워짐.
  // ret = mix(random(i), random(i + 1.), smoothstep(0., 1., f));

  // 2D 평면 셰이딩에서는 굳이 필요가 없겠지만, 3D 셰이딩의 경우
  // smoothstep() 만 사용하는 노이즈조차 경계가 눈에 잘 보일 수 밖에 없음.
  // 아래의 공식은 3D 셰이딩 상에서 그러한 노이즈의 곡선을 훨씬 더 부드럽게 해주는 공식임.
  // 나중을 위해서 공식을 미리 저장해둘 것.
  f = f * f * f * (f * (f * 6. - 15.) + 10.);
  ret = mix(random(i), random(i + 1.), f);

  return ret;
}

void main() {
  vec2 coord = gl_FragCoord.xy / u_resolution; // 각 픽셀들 좌표값 normalize
  coord.x *= u_resolution.x / u_resolution.y; // 캔버스를 resizing 해도 왜곡이 없도록 좌표값에 해상도비율값 곰해줌.

  // 랜덤함수의 인자로 각 픽셀들 x좌표값에 10배를 곱해준 이유는
  // thebookofshaders.com 의 noise 그래프 예제처럼 그려주려면
  // x좌표값의 정수부분이 달라짐에 따라 어떻게 y값이 그려지는지를(즉, noise의 추이를) 봐야하는 것이기 때문에
  // x좌표값의 범위를 0 ~ 1 에서 0 ~ 10으로 Mapping 함으로써, 정수값 변화의 추이를 확인할 수 있도록 범위를 늘려준 것.
  vec3 col = vec3(noise(coord.x * 10.));

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

  // 이거는 x좌표값의 정수값이 같은 픽셀들끼리 같은 랜덤값을 리턴받아 y에 할당하도록 함.
  // 이거는 분절된 상태이기 때문에 노이즈라고 볼 수는 없음.
  y = rand(i); 

  // 이제 각 픽셀들의 x좌표값의 정수와 그 다음 정수를 각각 
  // random 예제에서 사용했던 랜덤함수에 인자로 전달하여 랜덤값을 리턴받아오고,
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