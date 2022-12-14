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