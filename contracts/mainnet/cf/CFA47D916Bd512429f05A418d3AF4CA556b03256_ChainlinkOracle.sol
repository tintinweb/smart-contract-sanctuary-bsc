// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.5.16;

// Copyright 2020 Venus Labs, Inc.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
// PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


import "./PriceOracle.sol";
import "./VBep20.sol";
import "./BEP20Interface.sol";
import "./SafeMath.sol";
import "./AggregatorV2V3Interface.sol";

/**
 *
 *** MODIFICATIONS ***
 * getUnderlyingPrice() removed VAI and XVS if-else statements
 *
 */

contract ChainlinkOracle is PriceOracle {
    using SafeMath for uint;
    uint public constant VAI_VALUE = 1e18;
    address public admin;

    uint public maxStalePeriod;

    mapping(address => uint) internal prices;
    mapping(bytes32 => AggregatorV2V3Interface) internal feeds;

    event PricePosted(address asset, uint previousPriceMantissa, uint requestedPriceMantissa, uint newPriceMantissa);
    event NewAdmin(address oldAdmin, address newAdmin);
    event FeedSet(address feed, string symbol);
    event MaxStalePeriodUpdated(uint oldMaxStalePeriod, uint newMaxStalePeriod);

    constructor(uint maxStalePeriod_) public {
        admin = msg.sender;
        maxStalePeriod = maxStalePeriod_;
    }

    function setMaxStalePeriod(uint newMaxStalePeriod) external onlyAdmin() {
        require(newMaxStalePeriod > 0, "stale period can't be zero");
        uint oldMaxStalePeriod = maxStalePeriod;
        maxStalePeriod = newMaxStalePeriod;
        emit MaxStalePeriodUpdated(oldMaxStalePeriod, newMaxStalePeriod);
    }

    function getUnderlyingPrice(VToken vToken) public view returns (uint) {
        string memory symbol = vToken.symbol();
        if (compareStrings(symbol, "dBNB")) {
            return getChainlinkPrice(getFeed(symbol));
        } else {
            return getPrice(vToken);
        }
    }

    function getPrice(VToken vToken) internal view returns (uint price) {
        BEP20Interface token = BEP20Interface(VBep20(address(vToken)).underlying());

        if (prices[address(token)] != 0) {
            price = prices[address(token)];
        } else {
            price = getChainlinkPrice(getFeed(token.symbol()));
        }

        uint decimalDelta = uint(18).sub(uint(token.decimals()));
        // Ensure that we don't multiply the result by 0
        if (decimalDelta > 0) {
            return price.mul(10**decimalDelta);
        } else {
            return price;
        }
    }

    function getChainlinkPrice(AggregatorV2V3Interface feed) public view returns (uint) {
        // Chainlink USD-denominated feeds store answers at 8 decimals
        uint decimalDelta = uint(18).sub(feed.decimals());

        (, int256 answer,, uint256 updatedAt,) = feed.latestRoundData();
        // Ensure that we don't multiply the result by 0
        if (block.timestamp.sub(updatedAt) > maxStalePeriod) {
            return 0;
        }

        if (decimalDelta > 0) {
            return uint(answer).mul(10**decimalDelta);
        } else {
            return uint(answer);
        }
    }

    function setUnderlyingPrice(VToken vToken, uint underlyingPriceMantissa) external onlyAdmin() {
        address asset = address(VBep20(address(vToken)).underlying());
        emit PricePosted(asset, prices[asset], underlyingPriceMantissa, underlyingPriceMantissa);
        prices[asset] = underlyingPriceMantissa;
    }

    function setDirectPrice(address asset, uint price) external onlyAdmin() {
        emit PricePosted(asset, prices[asset], price, price);
        prices[asset] = price;
    }

    function setFeed(string calldata symbol, address feed) external onlyAdmin() {
        require(feed != address(0) && feed != address(this), "invalid feed address");
        emit FeedSet(feed, symbol);
        feeds[keccak256(abi.encodePacked(symbol))] = AggregatorV2V3Interface(feed);
    }

    function getFeed(string memory symbol) public view returns (AggregatorV2V3Interface) {
        return feeds[keccak256(abi.encodePacked(symbol))];
    }

    function assetPrices(address asset) external view returns (uint) {
        return prices[asset];
    }

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function setAdmin(address newAdmin) external onlyAdmin() {
        address oldAdmin = admin;
        admin = newAdmin;

        emit NewAdmin(oldAdmin, newAdmin);
    }

    modifier onlyAdmin() {
      require(msg.sender == admin, "only admin may call");
      _;
    }
}