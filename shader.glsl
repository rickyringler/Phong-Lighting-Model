cbuffer ConstantBuffer : register(b0)
{
    matrix World;
    matrix View;
    matrix Projection;
    float3 LightDirection;
    float3 LightColor;
    float3 AmbientColor;
}

Texture2D texDiffuse : register(t0);
SamplerState samLinear : register(s0);

struct VS_INPUT
{
    float3 position : POSITION;
    float3 normal : NORMAL;
    float2 texCoord : TEXCOORD;
};

struct VS_OUTPUT
{
    float4 position : SV_POSITION;
    float3 normal : NORMAL;
    float2 texCoord : TEXCOORD;
};

VS_OUTPUT VS_Main(VS_INPUT input)
{
    VS_OUTPUT output;

    output.position = mul(float4(input.position, 1.0f), World);
    output.position = mul(output.position, View);
    output.position = mul(output.position, Projection);

    output.normal = normalize(mul(input.normal, World));
    output.texCoord = input.texCoord;

    return output;
}

float4 PS_Main(VS_OUTPUT input) : SV_TARGET
{
    float3 lightDir = normalize(LightDirection);
    float3 normal = normalize(input.normal);

    float diffuseFactor = max(0.0f, dot(normal, lightDir));
    float3 diffuse = diffuseFactor * LightColor;

    float3 viewDir = normalize(-input.position.xyz);
    float3 reflectDir = reflect(-lightDir, normal);
    float specularFactor = pow(max(0.0f, dot(viewDir, reflectDir)), 32);
    float3 specular = specularFactor * LightColor;

    float3 ambient = AmbientColor;
    float3 finalColor = texDiffuse.Sample(samLinear, input.texCoord) * (ambient + diffuse) + specular;

    return float4(finalColor, 1.0f);
}
