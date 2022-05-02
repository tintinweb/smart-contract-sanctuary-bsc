// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;
pragma experimental ABIEncoderV2;

import "./Address.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";

import "./IERC20.sol";
import "./IGatedERC20.sol";

import "./TokensRecoverable.sol";

contract FeeSplitter is TokensRecoverable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public developerAddress;
    
    address public burnFeeRecipientAddress;

    mapping (IGatedERC20 => address[]) public feeCollectors;
    mapping (IGatedERC20 => uint256[]) public feeRates;
    mapping (IGatedERC20 => uint256) public burnRates;

    constructor(address _burnFeeRecipientAddress, address _developerAddress) {
        burnFeeRecipientAddress = _burnFeeRecipientAddress;
        developerAddress = _developerAddress;
    }

    function setFees(IGatedERC20 token, uint256 burnRate, address[] memory collectors, uint256[] memory rates) public ownerOnly() {

        uint256 totalRate = burnRate;
        for (uint256 i = 0; i < rates.length; i++) {
            totalRate = totalRate + rates[i];
        }

        require (totalRate == 10000, "Total fee rate must be 100%");
        
        if (token.balanceOf(address(this)) > 0) {
            distributeTokens(token);
        }

        feeCollectors[token] = collectors;
        feeRates[token] = rates;
        burnRates[token] = burnRate;
    }

    function distributeTokens(IGatedERC20 token) public {
        uint256 balance = token.balanceOf(address(this));
        require (balance > 0, "Nothing to pay");

        if (burnRates[token] > 0) {
            uint256 burnAmount = burnRates[token] * balance / 10000;
            token.transfer(burnFeeRecipientAddress, burnAmount);
        }

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

    function setDevAddress(address _devAddress) public {
        require (msg.sender == developerAddress, "Not Dev Address");
        developerAddress = _devAddress;
    }

    function setBurnFeeRecipient(address _feeRecipient) public ownerOnly() {
        burnFeeRecipientAddress = _feeRecipient;
    }

    function canRecoverTokens(IERC20 token) internal override view returns (bool) {
        address[] memory collectors = feeCollectors[IGatedERC20(address(token))];
        return address(token) != address(this) && collectors.length == 0; 
    }
}