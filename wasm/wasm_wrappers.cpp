// #include <openssl/sha.h>

#include <string>

#include "cosigner/cmp_ecdsa_online_signing_service.h"
#include "cosigner/platform_service.h"
#include "cosigner/sign_algorithm.h"
#include "cosigner/types.h"
#include "crypto/keccak1600/keccak1600.h"
#include <openssl/sha.h>

using namespace fireblocks::common::cosigner;

class platform : public platform_service
{
public:
    platform(uint64_t id) : _id(id) {}
private:
    void gen_random(size_t len, uint8_t* random_data) const {}
    const std::string get_current_tenantid() const {return "hello";}
    uint64_t get_id_from_keyid(const std::string& key_id) const {return _id;}
    void derive_initial_share(const share_derivation_args& derive_from, cosigner_sign_algorithm algorithm, elliptic_curve256_scalar_t* key) const {assert(0);}
    byte_vector_t encrypt_for_player(uint64_t id, const byte_vector_t& data) const {return data;}
    byte_vector_t decrypt_message(const byte_vector_t& encrypted_data) const {return encrypted_data;}
    bool backup_key(const std::string& key_id, cosigner_sign_algorithm algorithm, const elliptic_curve256_scalar_t& private_key, const cmp_key_metadata& metadata, const auxiliary_keys& aux) {return true;}
    void start_signing(const std::string& key_id, const std::string& txid, const signing_data& data, const std::string& metadata_json, const std::set<std::string>& players) {}
    void fill_signing_info_from_metadata(const std::string& metadata, std::vector<uint32_t>& flags) const {assert(0);}
    bool is_client_id(uint64_t player_id) const override {return false;}

    uint64_t _id;
};



extern "C" {

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


/*
Keygen service: cmp_setup_service
Signing service: cmp_ecdsa_signing_service
*/

struct test_struct {
  int a;
  int b;
};


int ecdsa_keygen_1(test_struct s, cosigner_sign_algorithm type, const std::string& keyid) {
    // elliptic_curve256_algebra_ctx_t algebra = *elliptic_curve256_new_secp256k1_algebra();
    // const size_t PUBKEY_SIZE = algebra->point_size(algebra);
    platform plt = platform(42);

    // cmp_setup_service(platform_service& service, setup_key_persistency& key_persistency);

    // elliptic_curve256_algebra_ctx_free(algebra);

    return s.a;
}

}
