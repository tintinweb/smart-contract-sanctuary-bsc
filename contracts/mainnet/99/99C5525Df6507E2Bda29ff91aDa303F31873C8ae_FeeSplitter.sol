// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.4;

import "./IERC20.sol";
import "./IGatedERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Address.sol";
import "./TokensRecoverable.sol";
import './ISwapRouter02.sol';

contract FeeSplitter is TokensRecoverable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public devAddress;

    ISwapRouter02 public immutable router;

    mapping (IGatedERC20 => uint256) public sellRates;
    mapping (IGatedERC20 => uint256) public keepRates;

    mapping (IGatedERC20 => address[]) public chainTokenFeeCollectors;
    mapping (IGatedERC20 => uint256[]) public chainTokenFeeRates;

    mapping (IGatedERC20 => address[]) public rootedTokenFeeCollectors;
    mapping (IGatedERC20 => uint256[]) public rootedTokenFeeRates;

    mapping (IGatedERC20 => address[]) public sellPaths;

    constructor(address _devAddress, ISwapRouter02 _router) {
        devAddress = _devAddress;
        router = _router;
    }

    function setDevAddress(address _devAddress) public ownerOnly() {
        devAddress = _devAddress;
    }

    function setFees(IGatedERC20 token, uint256 sellRate, uint256 keepRate) public ownerOnly() {
        require (sellRate + keepRate == 10000, "Total fee rate must be 100%");

        sellRates[token] = sellRate;
        keepRates[token] = keepRate;
        
        token.approve(address(router), uint256(-1));
    }

    function setChainTokenFeeCollectors(IGatedERC20 token, address[] memory collectors, uint256[] memory rates) public ownerOnly() {
        require (collectors.length == rates.length, "Fee Collectors and Rates must be the same size");
        
        uint256 totalRate = 0;
        for (uint256 i = 0; i < rates.length; i++) {
            totalRate = totalRate + rates[i];
        }
        
        require (totalRate == 10000, "Total fee rate must be 100%");

        chainTokenFeeCollectors[token] = collectors;
        chainTokenFeeRates[token] = rates;
    }

    function setRootedTokenFeeCollectors(IGatedERC20 token, address[] memory collectors, uint256[] memory rates) public ownerOnly() {
        require (collectors.length == rates.length, "Fee Collectors and Rates must be the same size");
        
        uint256 totalRate = 0;
        for (uint256 i = 0; i < rates.length; i++) {
            totalRate = totalRate + rates[i];
        }

        require (totalRate == 10000, "Total fee rate must be 100%");

        rootedTokenFeeCollectors[token] = collectors;
        rootedTokenFeeRates[token] = rates;
    }

    function setSellPath(IGatedERC20 token, address[] memory path) public ownerOnly() {
        require (path[0] == address(token), "Invalid path");

        sellPaths[token] = path;
    }

    function payFees(IGatedERC20 token) public {
        uint256 balance = token.balanceOf(address(this));
        require (balance > 0, "Nothing to pay");

        // If sell percentage of a token is more than zero, process the sell and distribute tokens
        if (sellRates[token] > 0) {
            uint256 sellAmount = sellRates[token] * balance / 10000;
            
            // Get the path of token to token
            address[] memory path = sellPaths[token];

            // Carry out the swap
            uint256[] memory amounts = router.swapExactTokensForTokens(sellAmount, 0, path, address(this), block.timestamp);
 
            // Get the collectors and rates for the token
            address[] memory collectors = chainTokenFeeCollectors[token];
            uint256[] memory rates = chainTokenFeeRates[token];

            // Distribute the tokens
            uint256 lastIndex = path.length - 1;
            distribute(IERC20(path[lastIndex]), amounts[lastIndex], collectors, rates);
        }

        // If keep percentage of a token is more than zero, distribute tokens
        if (keepRates[token] > 0) {
            uint256 keepAmount = keepRates[token] * balance / 10000;
            address[] memory collectors = rootedTokenFeeCollectors[token];
            uint256[] memory rates = rootedTokenFeeRates[token];
            distribute(token, keepAmount, collectors, rates);
        }
    }
    
    function distribute(IERC20 token, uint256 amount, address[] memory collectors, uint256[] memory rates) private {
        for (uint256 i = 0; i < collectors.length; i++) {
            address collector = collectors[i];
            uint256 rate = rates[i];

            if (rate > 0) {
                uint256 feeAmount = rate * amount / 10000;
                token.transfer(collector, feeAmount);
            }
        }
    }
}