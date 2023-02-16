// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

contract RandomNumberGeneraterTest {
    address public  manager;
    uint256 private _nonce;

    uint256[] public randoms;

    constructor(address _manager) {
        manager = _manager;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can call this function");
        _;
    }

    function random(uint256 amount) public onlyManager returns (uint256[] memory) {
        uint256[] memory seeds = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            seeds[i] = randoms[i];
            _nonce++; // this is to prevent compiler error
        }
        return seeds;
    }

    function setRandoms(uint256[] memory _randoms) public {
        randoms = _randoms;
    }
}