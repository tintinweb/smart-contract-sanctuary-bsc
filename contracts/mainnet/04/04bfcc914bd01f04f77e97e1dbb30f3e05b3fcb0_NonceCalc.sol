/**
 *Submitted for verification at BscScan.com on 2023-04-01
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract NonceCalc {

    function addressFrom(address _origin, uint8 _nonce) public pure returns (address) {
       if(_nonce == 0x00) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(0x80))))));
       else if (_nonce <= 0x7f) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), _origin, bytes1(_nonce))))));
    
    }
}