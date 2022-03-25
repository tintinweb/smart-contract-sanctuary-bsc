/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VerichainsNetRegistry {
    function randomService(uint256 key) external returns(VerichainsNetRandomService);
}

interface VerichainsNetRandomService {
    function random() external returns(uint256);
}

contract Test{
    event RandomNumber(uint256 _value);
    uint256 constant key = 0xc9821440a2c2cc97acac89148ac13927dead00238693487a9c84dfe89e28a284;
    uint256 a;
    function test() public {
        uint256 randomNumber = VerichainsNetRegistry(0x4141cADa751Aeb18bc2AE51065ea7e86Da379Dc4).randomService(key).random();
        a = randomNumber;
        emit RandomNumber(randomNumber);
    }

    function test2(uint256 frame) public view returns(uint256){
        return (frame - ((frame / a) * a));
    }
}