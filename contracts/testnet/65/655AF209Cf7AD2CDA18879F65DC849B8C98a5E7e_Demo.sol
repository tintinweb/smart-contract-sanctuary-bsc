pragma solidity ^0.8.0;

contract Demo {

    event Spin(address user, uint256 res);

    function Spint1(uint256 amount) public returns(uint256){
        uint256 hard = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));

        return hard % 6;


    }
    function Spin2(uint256) public {

        uint256 hard = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));

        emit Spin(msg.sender, hard% 6);

    }
}