pragma solidity >=0.5.0;

contract Timer{
    function Time() external view returns(uint){
        return block.timestamp;
    }
}