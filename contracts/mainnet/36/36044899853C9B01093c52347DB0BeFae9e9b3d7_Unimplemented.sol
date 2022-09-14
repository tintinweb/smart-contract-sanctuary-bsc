pragma solidity ^0.5.16;

contract Unimplemented {
    function() external {
        revert("Unimplemented");
    }
}