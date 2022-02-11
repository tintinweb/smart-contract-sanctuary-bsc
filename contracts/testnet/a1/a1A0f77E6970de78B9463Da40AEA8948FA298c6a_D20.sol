/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.11;

interface IKenshi {
    function approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    ) external returns (bool);
}

interface IVRFUtils {
    function fastVerify(
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents
    ) external view returns (bool);

    function gammaToHash(uint256 _gammaX, uint256 _gammaY)
        external
        pure
        returns (bytes32);
}

abstract contract VRFConsumer {
    /* Request tracking */
    mapping(uint256 => bool) _requests;
    uint256 private _requestId;

    /* Kenshi related */
    uint256 private _approve;
    address private _kenshiAddr;
    address private _coordinatorAddr;
    address private _vrfUtilsAddr;

    IKenshi private _kenshi;
    IVRFUtils private _utils;

    /* VRF options */
    bool private _shouldVerify;

    constructor() {
        _approve = (1e13 * 1e18) / 1e2;
    }

    function setupVRF(
        address coordinatorAddr,
        address vrfUtilsAddr,
        address kenshiAddr,
        bool shouldVerify
    ) internal {
        _coordinatorAddr = coordinatorAddr;
        _utils = IVRFUtils(vrfUtilsAddr);
        _kenshi = IKenshi(kenshiAddr);
        _shouldVerify = shouldVerify;
    }

    /**
     * @dev Sets the Kenshi VRF coordinator address.
     */
    function setVRFCoordinatorAddr(address coordinatorAddr) internal {
        _coordinatorAddr = coordinatorAddr;
    }

    /**
     * @dev Sets the Kenshi VRF verifier address.
     */
    function setVRFUtilsAddr(address vrfUtilsAddr) internal {
        _utils = IVRFUtils(vrfUtilsAddr);
    }

    /**
     * @dev Sets the Kenshi token address.
     */
    function setVRFKenshiAddr(address kenshiAddr) internal {
        _kenshi = IKenshi(kenshiAddr);
    }

    /**
     * @dev Sets if the received random number should be verified.
     */
    function setVRFShouldVerify(bool shouldVerify) internal {
        _shouldVerify = shouldVerify;
    }

    /**
     * @dev Request a random number.
     *
     * @return {requestId} Use to map received random numbers to requests.
     */
    function requestRandomness() internal returns (uint256) {
        uint256 currentId = _requestId++;
        _kenshi.approveAndCall(
            _coordinatorAddr,
            _approve,
            abi.encode(currentId)
        );
        return currentId;
    }

    event RandomnessFulfilled(
        uint256 requestId,
        uint256 randomness,
        uint256[4] _proof,
        bytes _message
    );

    /**
     * @dev Called by the VRF Coordinator.
     */
    function onRandomnessReady(
        uint256[4] memory proof,
        bytes memory message,
        uint256[2] memory uPoint,
        uint256[4] memory vComponents,
        uint256 requestId
    ) external {
        require(
            msg.sender == _coordinatorAddr,
            "Consumer: Only Coordinator can fulfill"
        );
        if (_shouldVerify) {
            bool isValid = _utils.fastVerify(
                proof,
                message,
                uPoint,
                vComponents
            );
            require(isValid, "Consumer: Proof not valid");
        }
        bytes32 beta = _utils.gammaToHash(proof[0], proof[1]);
        uint256 randomness = uint256(beta);
        emit RandomnessFulfilled(requestId, randomness, proof, message);
        fulfillRandomness(requestId, randomness);
    }

    /**
     * @dev You need to override this function in your smart contract.
     */
    function fulfillRandomness(uint256 requestId, uint256 randomness)
        internal
        virtual;
}

contract D20 is VRFConsumer {
    mapping(uint256 => address) requests;
    address _owner;

    constructor() {
        _owner = msg.sender;
    }

    function setVRFConfig(
        address coordinatorAddr,
        address vrfUtilsAddr,
        address kenshiAddr,
        bool shouldVerify
    ) public {
        require(msg.sender == _owner, "Only owner");
        setupVRF(coordinatorAddr, vrfUtilsAddr, kenshiAddr, shouldVerify);
    }

    function roll() public {
        uint256 requestId = requestRandomness();
        requests[requestId] = msg.sender;
    }

    event Rolled(address addr, uint8 number);

    function fulfillRandomness(uint256 requestId, uint256 randomness)
        internal
        override
    {
        address addr = requests[requestId];
        uint8 number = uint8(1 + (randomness % 20));
        emit Rolled(addr, number);
    }
}