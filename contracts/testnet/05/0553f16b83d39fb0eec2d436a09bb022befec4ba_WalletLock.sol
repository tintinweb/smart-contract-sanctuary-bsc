/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WalletLock {
    mapping (address => bool) public transfersInLocked;
    mapping (address => bool) public transfersOutLocked;
    mapping (address => mapping (address => bool)) public tokenTransfersLocked;
    
    event Locked(address user, bool transfersIn, bool transfersOut, address token);
    
    function lockTransfersIn(bool _lock) public {
        transfersInLocked[msg.sender] = _lock;
        emit Locked(msg.sender, _lock, transfersOutLocked[msg.sender], address(0));
    }
    
    function lockTransfersOut(bool _lock) public {
        transfersOutLocked[msg.sender] = _lock;
        emit Locked(msg.sender, transfersInLocked[msg.sender], _lock, address(0));
    }
    
    function lockTokenTransfer(address _token, bool _lock) public {
        tokenTransfersLocked[msg.sender][_token] = _lock;
        emit Locked(msg.sender, transfersInLocked[msg.sender], transfersOutLocked[msg.sender], _token);
    }
    
    function isTokenTransferLocked(address _token) public view returns (bool) {
        return tokenTransfersLocked[msg.sender][_token];
    }
}