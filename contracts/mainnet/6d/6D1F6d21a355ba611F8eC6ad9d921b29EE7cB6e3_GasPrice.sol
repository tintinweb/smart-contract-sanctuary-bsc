// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
import "./Ownable.sol";

contract GasPrice is Ownable {

    uint public maxGasPrice = 10000000000; // 10 gwei
    bool public enabled = true;

    event NewMaxGasPrice(uint oldPrice, uint newPrice);

    function setMaxGasPrice(uint _maxGasPrice) external onlyOwner {
        emit NewMaxGasPrice(maxGasPrice, _maxGasPrice);
        maxGasPrice = _maxGasPrice;
    }

    function enable() external onlyOwner {
        enabled = true;
    }

    function disable() external onlyOwner {
        enabled = false;
    }
}