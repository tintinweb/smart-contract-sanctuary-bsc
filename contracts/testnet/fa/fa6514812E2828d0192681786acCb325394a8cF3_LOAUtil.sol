/**
 *Submitted for verification at BscScan.com on 2022-09-03
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// import "hardhat/console.sol";

contract LOAUtil {

    mapping(address => uint256[]) private _random_nos;

    event RequestingRandom (
        address requestor,
        uint32 units
    );

    function random(uint256 limit, uint256 randNonce) public view returns (uint64) {
        if(limit == 0) return 0;
        unchecked {
            return uint64(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % limit);
        }
    }

    function randomNumber(address owner) public returns (uint256) {
        unchecked {
            // uint256 num = uint256(keccak256(abi.encodePacked(block.timestamp + nonce, msg.sender, block.difficulty)));
            require(_random_nos[owner].length > 0, "No random no available");
            uint256 num = _random_nos[owner][_random_nos[owner].length -1];
            _random_nos[owner].pop();

            if(num < 1_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000_000) {
                num = uint256(num * num);
            }
            return num;
        }
    }

    function sudoRandom(uint256 randomValue, uint32 slot) public pure returns(uint8) {
        unchecked {
            slot = slot % 31;
            return uint8(randomValue % (100 ** (slot + 1)) / (100 ** slot));
        }
    }

    function randomCount() public view returns (uint256) {
        return _random_nos[msg.sender].length;
    }

    function requestRandom(uint32 units) public {
        if(_random_nos[msg.sender].length < units) {
            emit RequestingRandom(msg.sender, uint32(units - _random_nos[msg.sender].length));
        }
    }

    function fullfillRandom(address requestor, uint32[] memory randoms) public {
        for(uint i = 0; i < randoms.length; i++) {
            _random_nos[requestor].push(randoms[i]);
        }
    }
}