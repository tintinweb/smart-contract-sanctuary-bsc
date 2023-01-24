// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./TokensRecoverable.sol";
import "./Whitelist.sol";

contract TeamSplitter is Whitelist, TokensRecoverable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    mapping (IERC20 => address[]) public feeCollectors;
    mapping (IERC20 => uint256[]) public feeRates;

    constructor() {
    }

    function setFees(IERC20 token, uint256 burnRate, address[] memory collectors, uint256[] memory rates) public ownerOnly() {
        
        uint256 totalRate = burnRate;

        for (uint256 i = 0; i < rates.length; i++) {
            totalRate = totalRate + rates[i];
        }

        require (totalRate == 10000, "Total fee rate must be 100%");
        
        if (token.balanceOf(address(this)) > 0) {
            distribute(token);
        }

        feeCollectors[token] = collectors;
        feeRates[token] = rates;
    }

    function distribute(IERC20 token) public {
        uint256 balance = token.balanceOf(address(this));
        require (balance > 0, "Nothing to pay");

        address[] memory collectors = feeCollectors[token];
        uint256[] memory rates = feeRates[token];

        for (uint256 i = 0; i < collectors.length; i++) {
            address collector = collectors[i];
            uint256 rate = rates[i];

            if (rate > 0) {
                uint256 feeAmount = rate * balance / 10000;
                token.transfer(collector, feeAmount);
            }
        }
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) {
        address[] memory collectors = feeCollectors[IERC20(address(token))];
        return address(token) != address(this) && collectors.length == 0; 
    }
}