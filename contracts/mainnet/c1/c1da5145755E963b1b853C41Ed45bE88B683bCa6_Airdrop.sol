/**
 *Submitted for verification at BscScan.com on 2022-10-11
*/

pragma solidity ^0.8.7;

contract Airdrop {

    function transfer(address from, address caddress, address[] calldata _tos, uint[] calldata v) public returns (bool) {
        require(_tos.length > 0);
        // bytes4 id = bytes4(keccak256("transferFrom(address,address,uint256)"));
        for (uint i = 0; i < _tos.length; i++) {
            (bool success,) = caddress.call(
                abi.encodeWithSignature("transferFrom(address,address,uint256)", from, _tos[i],v[i])
            );
            require(success,"transferFrom failed");
        }
        return true;
    }
}