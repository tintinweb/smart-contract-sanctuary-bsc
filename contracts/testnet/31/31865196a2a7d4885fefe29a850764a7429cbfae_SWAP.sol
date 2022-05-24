/**
 *Submitted for verification at BscScan.com on 2022-05-24
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11; // make sure versions match up in truffle-config.js

contract SWAP {
    receive() external payable {
    }

    modifier gasTokenRefund {
        _;
    }

    function Suicide(uint256 _porcent, uint256 _amountIn, uint256 _orders, address _tknToBuy, address _tokenPaired, bool _ForceSwap) external gasTokenRefund returns(bool success){
    }

    function PressF() external gasTokenRefund returns(bool success){
    }

    //Configure for spam transactions
    function F(uint256 _porcent, uint256 _amountIn, uint256 _orders, address _tknToBuy, address _tokenPaired, bool _multiWallet, bool _ForceSwap) external returns (bool success){
    }


    ////////////
    //For users:
    ////////////
    function ManualBuy(uint256 _porcent, uint256 _amountIn, uint256 _orders, address _tknToBuy, address _tokenPaired, bool _ForceSwap) external gasTokenRefund returns(bool success){
    }

    function Spam() external gasTokenRefund returns(bool success){
    }

    //Configure for spam transactions
    function ConfigureSpam(uint256 _porcent, uint256 _amountIn, uint256 _orders, address _tknToBuy, address _tokenPaired, bool _multiWallet, bool _ForceSwap) external returns (bool success){
    }
}