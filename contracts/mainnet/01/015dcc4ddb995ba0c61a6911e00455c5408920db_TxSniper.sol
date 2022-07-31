/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

contract TxSniper{
    function Heresy(address[] memory path_) external{}
    function mintGasToken(uint amount) public{}
    function wrap(uint toWrap) public{}
    function unrwap() public{}
    function approve(address token, uint amount) public{}
    function withdrawToken(address token) public{}
    function withdrawTokens(address[] memory tokens) public{}
    function migrateTokens(address[] memory tokens, address newContract) public{}
    function withdrawEth(uint amount) public {}
    function migrateEth(uint amount, address payable newContract) public {}
    function emergencyWithdraw() public {}
    function _setupHand(address tokenIn, address tokenOut, uint amountIn) internal returns (address[] memory path){}
    function Hand(address[] memory path_, uint amountIn) external  {}
    function HandFee(address tokenIn, address tokenOut, uint amountIn, uint amountOutMin) external  {}
    function configureSwap(address tokenBase, address tokenToBuy, uint amountToBuy, uint numOfSwaps, bool checkTax, bool machineGunner, uint amountOutMin, uint[] memory testAmounts) external{}
    function getConfiguration() external view  returns(address, address, uint, uint, uint, bool, bool, bool,bool){}
    function HeresyGun(address[] memory path_, uint8 numberOfSwaps_) external{}
    function HeresyMany(address[] memory path_, uint8 numberOfSwaps_) external{}
    function configure(address newRouter, address newChiToken, address newHoldingAddress, address[] memory newSwaps, address newOperationAddress, bool multiwallets_) public{}
    function changeHoldingAddress(address _newHolding) public{}
    function removeSwaps(address[] memory _oldSwaps) public{}
}