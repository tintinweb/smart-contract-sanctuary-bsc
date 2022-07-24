pragma solidity ^0.5.0;

// Fiat-Shamir Zero Knowledge proof 
// (non-interactive random oracle access)
contract FiatShamirZKP {
    
    // prime
    uint n;
    // generator
    uint g;
    // g^x mod n
    uint y;
    // TODO Random Challenge Nonce
    uint public c;
    
    // used for pr
    uint nonce;

    // User register's a seed with prime number n, generator g, and y = g^x mod n
    function registerSeed(uint _n, uint _g, uint _y) public {
        // require(probablyPrime(_n), 'n is probably not a prime number');
        n = _n;
        g = _g;
        y = _y;
        // pseudorandom kick
        nonce += uint(keccak256(abi.encodePacked(now, msg.sender, block.coinbase, block.difficulty, nonce, _n, _g, _y))) % n;
    }

    function pseudoRandom() internal returns (uint) {
        uint random = uint(keccak256(abi.encodePacked(now, msg.sender, block.coinbase, block.difficulty, nonce, n, g, y))) % n;
        nonce++;
        return random;
    }

    // TODO generate random challenge number
    function getChallenge() external returns (uint) {
        c = pseudoRandom();
        return c;
    }
    
    /* 
      User wishes to verify, so she generates a new random number and sends product of t:
       t = g^v mod n

      User uses random value (v), and using the challenge in the previous txn, computes for r:
       r = v − c * t
       Contract computes:
       result = g^c * y^c
       and checks if the result equals t equals val
    */
    function verify(uint t, uint256 r) public view returns (bool) {
        uint256 result = 0;
        if (lessThanZero(r)){
            result = (invmod(expmod(g, -r, n), n) * expmod(y, c, n)) % n;
        }else{
            result = (expmod(g, r, n) * expmod(y, c, n)) % n;
        }
        return (t == result);
    }
    
    function lessThanZero(uint256 x) internal pure returns (bool) {
        return (x > 21888242871839275222246405745257275088548364400416034343698204186575808495617);
    }

    function expmod(uint base, uint e, uint m) public view returns (uint o) {  
      assembly {
       // define pointer
       let p := mload(0x40)
       // store data assembly-favouring ways
       mstore(p, 0x20)             // Length of Base
       mstore(add(p, 0x20), 0x20)  // Length of Exponent
       mstore(add(p, 0x40), 0x20)  // Length of Modulus
       mstore(add(p, 0x60), base)  // Base
       mstore(add(p, 0x80), e)     // Exponent
       mstore(add(p, 0xa0), m)     // Modulus
       if iszero(staticcall(sub(gas, 2000), 0x05, p, 0xc0, p, 0x20)) {
         revert(0, 0)
       }
       // data
       o := mload(p)
      }
    }


    function expmod(uint256 base, uint256 exponent) internal view returns (uint256) {
        uint256 q = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        return expmod(base, exponent, q);
    }
    
    /// @dev Modular inverse of a (mod p) using euclid.
    /// "a" and "p" must be co-prime.
    /// @param a The number.
    /// @param p The modulus.
    /// @return x such that ax = 1 (mod p)
    function invmod(uint a, uint p) internal pure returns (uint) {
        if (a == 0 || a == p || p == 0)
            revert();
        if (a > p)
            a = a % p;
        int t1;
        int t2 = 1;
        uint r1 = p;
        uint r2 = a;
        uint q;
        while (r2 != 0) {
            q = r1 / r2;
            (t1, t2, r1, r2) = (t2, t1 - int(q) * t2, r2, r1 - q * r2);
        }
        if (t1 < 0)
            return (p - uint(-t1));
        return uint(t1);
    }
    
}