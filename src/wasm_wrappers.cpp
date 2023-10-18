// #include <emscripten/bind.h>

// using namespace emscripten;

#include <openssl/sha.h>

#include "cosigner/cmp_ecdsa_online_signing_service.h"
#include "crypto/keccak1600/keccak1600.h"

using namespace std;

extern "C" {

// int mpc_add(int x, int y) {
//   return x + y;
// }

// }

int sha256(char in[], unsigned char out[])
{
    long unsigned int i = 0;

    while (in[i]!=0) i++;

    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, in, i);
    SHA256_Final(out, &sha256);

    return 0;
}

void keccak1600(unsigned char in[], unsigned char out[])
{
    long unsigned int i = 0;

    while (in[i]!=0) i++;

    KECCAK1600_CTX hash_ctx;
    keccak1600_init(&hash_ctx, 512, KECCAK256_PAD);
    keccak1600_update(&hash_ctx, in, i);
    keccak1600_final(&hash_ctx, out);
}

// EMSCRIPTEN_BINDINGS(cmp_ecdsa_online_signing_service) {
//     class_<MyClass>("cmp_ecdsa_online_signing_service")
//         .constructor<int, std::string>()
//         .function("incrementX", &MyClass::incrementX)
//         .property("x", &MyClass::getX, &MyClass::setX)
//         .class_function("getStringFromInstance", &MyClass::getStringFromInstance)
//         ;
// }

}
