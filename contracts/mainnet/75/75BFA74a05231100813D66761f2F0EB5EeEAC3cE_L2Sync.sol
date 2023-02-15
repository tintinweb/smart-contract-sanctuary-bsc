/**
 *Submitted for verification at BscScan.com on 2023-02-15
*/

pragma solidity 0.5.9;

contract L2Sync {

    function sync(uint _state) public {
        emit SyncState(msg.sender, keccak256(abi.encode(msg.sender, _state)), now);
    }

    event SyncState(address _sender, bytes32 _hash, uint _timestamp);
}