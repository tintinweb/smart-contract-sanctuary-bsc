/**
 *Submitted for verification at BscScan.com on 2022-10-18
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


// 随机数发生器
contract RandomNumberGenerator {

    mapping(uint256 => uint256) internal randomNumber;

    uint256 internal index;
    address public owner;

    constructor(){
        owner = msg.sender;
    }

    // 获取随机数
    function getRandomNumber(uint256 _seed) external view returns (uint256){
        return randomNumber[_seed];
    }

    function insertData(uint256[] calldata _value) external onlyOwner {
        require(_value.length > 0, "length must be greater than 0");

        for(uint i; i < _value.length; i++){
            randomNumber[index] = _value[i];
            index +=1;
        }
    }

    function importSeedFromThird(address _seed, uint256 modulo) external view returns (uint8) {
        //bytes32 lastBlockHashUsed = blockhash(block.number - 1);
        uint256 blockNumber = block.number - 1;
        uint8 randomNumber_ = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase, blockNumber, _seed))) % modulo);
        return randomNumber_;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "caller is not the owner address");
        _;
    }

}