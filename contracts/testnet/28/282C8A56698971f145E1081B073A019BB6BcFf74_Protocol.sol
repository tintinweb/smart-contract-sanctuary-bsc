//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MathChain
 * @author kotsmile
 */

import './ZkLib.sol';

interface MathChainCaller {
    function fulfill(
        uint256 requestId,
        bytes32[] memory input,
        bytes32 answer,
        ZkLib.Proof memory proof
    ) external;
}

contract MathChain {
    struct Request {
        uint256 mathId;
        address sender;
        bytes32[] input;
        bool status;
    }

    Request[] public requests;

    function request(uint256 mathId, bytes32[] memory input) external returns (uint256) {
        requests.push(
            Request({mathId: mathId, sender: msg.sender, input: input, status: false})
        );
        return requests.length;
    }

    function fulfill(
        uint256 requestId,
        bytes32 answer,
        ZkLib.Proof memory proof
    ) external {
        Request storage request_ = requests[requestId];
        require(!request_.status);
        MathChainCaller(request_.sender).fulfill(
            requestId,
            request_.input,
            answer,
            proof
        );
        request_.status = true;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Protocol
 * @author kotsmile
 */

import {PowerVerifier} from './zk/PowerVerifier.sol';
import './MathChain.sol';

contract Protocol {
    MathChain public immutable mathChain;
    uint256 public constant mathId = 0;

    bool public success;
    uint256 public answer;

    constructor(MathChain mathChain_) {
        mathChain = mathChain_;
    }

    function testCall(uint256 a) external {
        uint256 response = a;
        for (uint256 i = 0; i <= 100; i++) {
            response = (response + 20) * 4;
        }
        answer = response;
    }

    function fulfill(
        uint256 requestId,
        bytes32[] memory input,
        bytes32 answer,
        PowerVerifier.Proof memory proof
    ) external {
        require(msg.sender == address(mathChain));

        uint256[2] memory input_;

        input_[0] = uint256(input[0]);
        input_[1] = uint256(answer);

        require(PowerVerifier.verifyTx(proof, input_), 'Incorrect proof');
        _callback(requestId, input_[1]);
    }

    function _callback(uint256 requestId, uint256 answer) internal {
        success = true;
    }

    function give(uint256 a) external {
        bytes32[] memory input = new bytes32[](1);
        input[0] = bytes32(a);
        mathChain.request(0, input);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ZkLib
 * @author kotsmile
 */

library ZkLib {
    struct G1Point {
        uint256 X;
        uint256 Y;
    }
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }
    struct VerifyingKey {
        G1Point alpha;
        G2Point beta;
        G2Point gamma;
        G2Point delta;
        G1Point[] gamma_abc;
    }
    struct Proof {
        G1Point a;
        G2Point b;
        G1Point c;
    }
}

// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

library PowerVerifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x02a4da2b7cb3775bea4646c0f5d40b53d625a65ed5a5a1229f93c33b6e518dbc), uint256(0x02a4723584a34ec6f423b26d936d44206e59dd8c04bc6eaf0e1d51c57366c1d5));
        vk.beta = Pairing.G2Point([uint256(0x1f7a5f08f88609895dd5ba8571eab3e756ce82e31d21fa36103fd018a7f4a670), uint256(0x114c156383a75a0f339db6d4a6e589c91e1203f2ab6942f4f0cea79ff9b56b26)], [uint256(0x2fd9f5bca1d3b8693fe3aee14fb00911f629bf0918fa798290d56cd2d8456af7), uint256(0x15f65bc6f2ae57db8674e470244c6d8da215bd29147411af295e8f9c02535192)]);
        vk.gamma = Pairing.G2Point([uint256(0x0849b418542cb416501cd3a5599870acfb1efbf4147f4aacd82ecc108712ff5c), uint256(0x24a209e86c04fd5f3e4f581cd231ca5fe705eb08feb426a795da29ddf86ec7e1)], [uint256(0x1a12a5de3c6dbd6289fd1593aec5974fa7001ee2c7fc528329dd6eca29949175), uint256(0x28a541b1ee05d098038ddd5954b55507c24751bfb15f9c4c2bfc1f3150d06425)]);
        vk.delta = Pairing.G2Point([uint256(0x01db84ce7d9a01e6ad9396ffd2255c558e3fa892e0e274e2eaddc0aa0238edaa), uint256(0x21f8444a5c2ceb75aa01cae6c82dc0e8b1f439ff8a6f6f1c828c611d99e3e9e1)], [uint256(0x2a59bab8f18e3e1a038d2502229d94c371a819b7eb04fef818a1f2263a8e847b), uint256(0x1287a206a44edf503438ad2b835cfe46de560144a146825a1564bc4858a08ace)]);
        vk.gamma_abc = new Pairing.G1Point[](3);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x26eee9466f5f99e9bb74a692a51178a9a33606f908118372417d743e5537e6c9), uint256(0x0ce46849bfe228bc98ae58dde4003dd005e6cba094061fd077a1c7b63a6f643b));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1ddf8813e5a2db49217f63040ed9ae2a090a328e01c32bb4ab5bd60d8d092d69), uint256(0x21a4e1999a51a5a4c97bcd62732b02305967e62881477a4dd42f74242fe196a3));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0b477c8824239898509011974b823a2bbebc16d1d4681537a1157cafb0183e7b), uint256(0x26abed11d79a6a67cbe84b47093b4c0395d6bbcb3e377c22da96bcf197aea29c));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[2] memory input
        ) internal view returns (bool r) {
        uint[] memory inputValues = new uint[](2);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}