// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Address.sol";
import "./TokensRecoverable.sol";
// import "./INFTFeeClaim.sol";

contract MintFeeSplitter is TokensRecoverable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public devAddress;
    
    mapping (IERC20 => address[]) public feeCollectors;
    mapping (IERC20 => uint256[]) public feeRates;

    constructor(address _devAddress) {
        devAddress = _devAddress;
    }
    
    function setDevAddress(address _devAddress) public {
        require (msg.sender == devAddress, "Not a dev address");
        devAddress = _devAddress;
    }

    function setFees(IERC20 token, address[] memory collectors, uint256[] memory rates) public onlyOwner {
        require (collectors.length == rates.length && collectors.length > 1, "Fee Collectors and Rates must be the same size and contain at least 2 elements");
        
        uint256 totalRate;
        
        for (uint256 i = 0; i < rates.length; i++) {
            totalRate = totalRate + rates[i];
        }
        require (totalRate == 10000, "Total fee rate must be 100%");
        
        if (token.balanceOf(address(this)) > 0) {
            payFees(token);
        }

        feeCollectors[token] = collectors;
        feeRates[token] = rates;
    }
    
    function payFees(IERC20 token) public {
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