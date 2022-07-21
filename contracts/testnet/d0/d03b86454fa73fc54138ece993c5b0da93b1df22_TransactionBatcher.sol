/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// File: contracts/TFTC/Batcher.sol

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface TFTCTokenV2 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool success);
}

contract TransactionBatcher {
    TFTCTokenV2 public TFTC;
     address public owner;
    constructor (address TFTCAddress) {
        TFTCTokenV2 _TFTCToken = TFTCTokenV2(TFTCAddress);
        TFTC = _TFTCToken;
        owner = msg.sender;
    }

    function batchTokenTransfer(address[] memory _userWallet, uint256[] memory _balance) public {
        for(uint i =0; i <= _userWallet.length; i++ ) {
            TFTC.transfer(_userWallet[i], _balance[i]);
        }
    }

}