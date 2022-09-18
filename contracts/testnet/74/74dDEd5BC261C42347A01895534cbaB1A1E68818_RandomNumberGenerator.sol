/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//import "@openzeppelin/contracts/access/Ownable.sol";


// 随机数发生器
contract RandomNumberGenerator {

    uint32[] public randomNumber3;
    uint32[] public randomNumber4;
    uint32[] public randomNumber5;

    constructor() {}

    // 获取随机数
    function getRandomNumber(uint256 _seed) external view returns(uint32){
        return randomNumber3[_seed];
    }


    // 铸造
    function mintLevel3(uint32[] calldata random) external returns(bool){
        require(random.length > 0, "Insufficient data");

        for(uint i; i < random.length; i++){
            randomNumber3.push(random[i]);
        }
        return true;
    }


}