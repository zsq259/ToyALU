#include <iostream>
#include <bitset>

// 定义一个联合体用于类型转换
union FloatConverter {
    float f;
    unsigned int i;
};

std::bitset<32> change(float num) {
    // 将浮点数转换为二进制表示
    FloatConverter converter;
    converter.f = num;

    std::bitset<32> binary(converter.i);

    // 输出二进制表示
    return binary;
}

float convertToFloat(std::bitset<32> bits) {    
    unsigned int intValue = bits.to_ulong();

    float* floatValue = reinterpret_cast<float*>(&intValue);
    return *floatValue;
}

int main() {
    float x = 58.625, y = 59.666; // 替换为你想要输出的浮点数
    // std::cin >> x >> y;
    std::bitset<32> b1 = change(x);
    std::bitset<32> b2 = change(y);
    std::cout << b1 << '\n' << b2 << '\n';
    
    // std::string str = "01000010111010101000000000000000"; // 替换为你要转换的二进制浮点数
    // binary = std::bitset<32>(str); 
    std::bitset<32> b3 = change(x + y);
    float decimal = convertToFloat(b3);
    std::cout << "Decimal: " << decimal << std::endl;

    return 0;
}
