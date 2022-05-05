/**
 *Submitted for verification at BscScan.com on 2022-05-05
*/

pragma solidity ^0.6.2;

contract Permit {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }


    function hashMsg(address spender, uint256 value) public pure returns (bytes32) {
        bytes32 digest = keccak256(
            abi.encodePacked(
                value,
                keccak256(abi.encode(spender, value))
            )
        );

        return digest;
    }

    function permit(address spender, uint256 value, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
       
        bytes32 digest = hashMsg(spender, value);
        address recoveredAddress = ecrecover(digest, v, r, s);
        return recoveredAddress == owner;
    }
    
}