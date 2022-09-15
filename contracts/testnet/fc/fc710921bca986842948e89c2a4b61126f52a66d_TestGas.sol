/**
 *Submitted for verification at BscScan.com on 2022-09-14
*/

pragma solidity ^0.8.9;
// SPDX-License-Identifier: MIT

contract TestGas{

    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    constructor(){}

    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    event SimulationData(uint difficulty, address payable addres_coinbase, uint gasprice, uint block_number, uint block_timestamp, uint gas_left);

    function culo(bool _revert) public{
        if(_revert){
            revert(string(abi.encodePacked(toString(block.difficulty), " ", toString(uint256(uint160(address(block.coinbase)))), " ",
             toString(tx.gasprice), " ", toString(block.number), " ", toString(block.timestamp),
              " ", toString(gasleft()))));
        }else{
            emit SimulationData(block.difficulty, block.coinbase, tx.gasprice, block.number, block.timestamp, gasleft());
        }
    }
}