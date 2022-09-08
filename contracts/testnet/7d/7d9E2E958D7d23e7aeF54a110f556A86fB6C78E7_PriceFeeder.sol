// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.7.6;

contract PriceFeeder {
    uint256 public _price;
    uint256 _lastTimeStamp;

    function price() external view returns (uint256 lastPrice, uint256 lastTimestamp) {
        return (_price, _lastTimeStamp);
    }

    function setPrice(uint256 price_) external {
        _price = price_;
        _lastTimeStamp = block.timestamp;
    }
}