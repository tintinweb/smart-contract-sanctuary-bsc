pragma solidity 0.8.14;
contract BlockTimeDos {
    function GetBlocktime() public view returns(uint256){
        return block.timestamp;
    }
}