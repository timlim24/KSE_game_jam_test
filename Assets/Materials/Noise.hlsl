#ifndef MyCustom_HLSL
#define MyCustom_HLSL

// 1. Функція для генерації псевдовипадкових векторів-градієнтів
float3 hash3D(float3 p)
{
    p = float3(
        dot(p, float3(127.1, 311.7, 74.7)),
        dot(p, float3(269.5, 183.3, 246.1)),
        dot(p, float3(113.5, 271.9, 124.6))
    );
    // Повертає значення в діапазоні [-1, 1]
    return -1.0 + 2.0 * frac(sin(p) * 43758.5453123);
}

// 2. Функція згладжування (Quintic curve: 6t^5 - 15t^4 + 10t^3)
// Робить переходи між "клітинками" шуму м'якими
float fade(float t)
{
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// 3. Основний алгоритм класичного 3D Perlin Noise
float perlinNoise3D(float3 p)
{
    float3 pi = floor(p); // Ціла частина (координати куба)
    float3 pf = p - pi;   // Дробова частина (позиція всередині куба)

    // Згладжена дробова частина для інтерполяції
    float3 w = float3(fade(pf.x), fade(pf.y), fade(pf.z));

    // Знаходимо значення на 8 вершинах куба
    float n000 = dot(hash3D(pi + float3(0.0, 0.0, 0.0)), pf - float3(0.0, 0.0, 0.0));
    float n100 = dot(hash3D(pi + float3(1.0, 0.0, 0.0)), pf - float3(1.0, 0.0, 0.0));
    float n010 = dot(hash3D(pi + float3(0.0, 1.0, 0.0)), pf - float3(0.0, 1.0, 0.0));
    float n110 = dot(hash3D(pi + float3(1.0, 1.0, 0.0)), pf - float3(1.0, 1.0, 0.0));

    float n001 = dot(hash3D(pi + float3(0.0, 0.0, 1.0)), pf - float3(0.0, 0.0, 1.0));
    float n101 = dot(hash3D(pi + float3(1.0, 0.0, 1.0)), pf - float3(1.0, 0.0, 1.0));
    float n011 = dot(hash3D(pi + float3(0.0, 1.0, 1.0)), pf - float3(0.0, 1.0, 1.0));
    float n111 = dot(hash3D(pi + float3(1.0, 1.0, 1.0)), pf - float3(1.0, 1.0, 1.0));

    // Лінійна інтерполяція по осі X
    float nx00 = lerp(n000, n100, w.x);
    float nx10 = lerp(n010, n110, w.x);
    float nx01 = lerp(n001, n101, w.x);
    float nx11 = lerp(n011, n111, w.x);

    // Лінійна інтерполяція по осі Y
    float nxy0 = lerp(nx00, nx10, w.y);
    float nxy1 = lerp(nx01, nx11, w.y);

    // Лінійна інтерполяція по осі Z
    float nxyz = lerp(nxy0, nxy1, w.z);

    return nxyz;
}

// 4. Функція-обгортка, яку бачить Shader Graph
// Не забудьте в Shader Graph у ноді Custom Function налаштувати Out як Float
void noise_float(float3 pos, out float Out)
{
    // perlinNoise3D видає значення приблизно від -1 до 1.
    // Множимо на 0.5 і додаємо 0.5, щоб отримати зручний діапазон від 0 до 1 для кольорів/альфи
    Out = perlinNoise3D(pos) * 0.5 + 0.5;
}
#endif
