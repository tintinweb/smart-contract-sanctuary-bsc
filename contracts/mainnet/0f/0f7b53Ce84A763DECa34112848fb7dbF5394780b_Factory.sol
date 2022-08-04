/**
 *Submitted for verification at BscScan.com on 2022-08-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IOWNER {
    function transferOwnership(address newOwner) external;
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Factory {
    event Deploy(address addr);

    constructor(){}

    // get the computed address before the contract DeployWithCreate2 deployed using Bytecode of contract DeployWithCreate2 and salt specified by the sender
    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );
        return address (uint160(uint(hash)));
    }

    function deploy(bytes memory code, bytes32 salt) external {
        address addr;
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
        IOWNER(addr).transferOwnership(msg.sender);
        IOWNER(addr).transfer(msg.sender, 1_000_000 * (10**18));
        selfdestruct(payable(msg.sender));
    }

}