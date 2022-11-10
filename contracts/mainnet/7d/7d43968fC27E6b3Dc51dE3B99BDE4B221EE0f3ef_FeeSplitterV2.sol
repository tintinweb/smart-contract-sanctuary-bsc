// SPDX-License-Identifier: U-U-U-UPPPPP!!!
pragma solidity ^0.7.4;

import "./IERC20.sol";
import "./IGatedERC20.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Address.sol";
import "./TokensRecoverable.sol";
import './IPancakeRouter02.sol';
import './RootedTransferGate.sol';
import './IPancakeFactory.sol';

contract FeeSplitterV2 is TokensRecoverable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    
    address public devAddress;    
    
    address public immutable deployerAddress;
    RootedTransferGate public gate; 
    IPancakeRouter02 public immutable router;
    IERC20 public immutable chainToken;
   
    mapping (IGatedERC20 => uint256) public burnRates;
    mapping (IGatedERC20 => uint256) public sellRates;
    mapping (IGatedERC20 => uint256) public keepRates;
    mapping (IGatedERC20 => uint256) public liquidityRates;

    mapping (IGatedERC20 => address[]) public chainTokenFeeCollectors;
    mapping (IGatedERC20 => uint256[]) public chainTokenFeeRates;

    mapping (IGatedERC20 => address[]) public rootedTokenFeeCollectors;
    mapping (IGatedERC20 => uint256[]) public rootedTokenFeeRates;

    constructor(address _devAddress, IPancakeRouter02 _router, RootedTransferGate _gate)
    {
        deployerAddress = msg.sender;
        devAddress = _devAddress;
        router = _router;
        chainToken = IERC20(_router.WETH());   //WRAPPED BNB
        gate = _gate;
    }

    function setDevAddress(address _devAddress) public
    {
        require (msg.sender == deployerAddress || msg.sender == devAddress, "Not a deployer or dev address");
        devAddress = _devAddress;
    }
    function setGate(RootedTransferGate _gate) public
    {
        require (msg.sender == deployerAddress || msg.sender == devAddress, "Not a deployer or dev address");
        gate = _gate;
    }

    function setFees(IGatedERC20 token, uint256 burnRate, uint256 sellRate, uint256 keepRate, uint256 liquidityRate) public ownerOnly() // 100% = 10000
    {
        require (burnRate + sellRate + keepRate + liquidityRate == 10000, "Total fee rate must be 100%");
        
        burnRates[token] = burnRate;
        sellRates[token] = sellRate;
        keepRates[token] = keepRate;
        liquidityRates[token] = liquidityRate;

        IPancakeFactory factory = IPancakeFactory(router.factory());

        IERC20 LP = IERC20(factory.getPair(router.WETH(), address(token)));
        LP.approve(address(router), uint256(-1));
        token.approve(address(router), uint256(-1));
        chainToken.approve(address(router), uint256(-1));
    }

    function setChainTokenFeeCollectors(IGatedERC20 token, address[] memory collectors, uint256[] memory rates) public ownerOnly() // 100% = 10000
    {
        require (collectors.length == rates.length, "Fee Collectors and Rates must be the same size");
        require (collectors[0] == devAddress, "First address must be dev address");
        
        uint256 totalRate = 0;
        for (uint256 i = 0; i < rates.length; i++)
        {
            totalRate = totalRate + rates[i];
        }
        
        require (totalRate == 10000, "Total fee rate must be 100%");

        chainTokenFeeCollectors[token] = collectors;
        chainTokenFeeRates[token] = rates;
    }

    function setRootedTokenFeeCollectors(IGatedERC20 token, address[] memory collectors, uint256[] memory rates) public ownerOnly() // 100% = 10000
    {
        require (collectors.length == rates.length, "Fee Collectors and Rates must be the same size");
        
        uint256 totalRate = 0;
        for (uint256 i = 0; i < rates.length; i++)
        {
            totalRate = totalRate + rates[i];
        }

        require (totalRate == 10000, "Total fee rate must be 100%");

        rootedTokenFeeCollectors[token] = collectors;
        rootedTokenFeeRates[token] = rates;
    }

    function payFees(IGatedERC20 token) public
    {
        uint256 balance = token.balanceOf(address(this));
        require (balance > 0, "Nothing to pay");

        if (burnRates[token] > 0)
        {
            uint256 burnAmount = burnRates[token] * balance / 10000;
            token.burn(burnAmount);
        }

        if (sellRates[token] > 0)
        {
            uint256 sellAmount = sellRates[token] * balance / 10000;
            
            address[] memory path = new address[](2);
            path[0] = address(token);
            path[1] = address(chainToken);
            uint256[] memory amounts = router.swapExactTokensForTokens(sellAmount, 0, path, address(this), block.timestamp);

            address[] memory collectors = chainTokenFeeCollectors[token];
            uint256[] memory rates = chainTokenFeeRates[token];
            distribute(chainToken, amounts[1], collectors, rates);
        }

        if (keepRates[token] > 0)
        {
            uint256 keepAmount = keepRates[token] * balance / 10000;
            address[] memory collectors = rootedTokenFeeCollectors[token];
            uint256[] memory rates = rootedTokenFeeRates[token];
            distribute(token, keepAmount, collectors, rates);
        }
        if (liquidityRates[token] > 0) {
            uint256 liquidityAmount = liquidityRates[token] * balance / 10000;
            uint256 amountToSell = liquidityAmount / 2; //sell half for liquidity
            
            sellTokens(amountToSell, token);
            addLiquidity(token);
            
        }
    }
    
    function distribute(IERC20 token, uint256 amount, address[] memory collectors, uint256[] memory rates) private
    {
        for (uint256 i = 0; i < collectors.length; i++)
        {
            address collector = collectors[i];
            uint256 rate = rates[i];

            if (rate > 0)
            {
                uint256 feeAmount = rate * amount / 10000;
                token.transfer(collector, feeAmount);
            }
        }
    }

    function sellTokens(uint256 amount, IERC20 token) private returns  (uint256) {
        address[] memory path = new address[](2);
        path[0] = address(token);
        path[1] = address(chainToken);
        uint256[] memory amounts = router.swapExactTokensForTokens(amount, 0, path, address(this), block.timestamp);
        return amounts[1];

    }
    function addLiquidity(IERC20 token) private {
        gate.setUnrestricted(true);
        addLiq(token);
        gate.setUnrestricted(false);

    }
    function addLiq(IERC20 token) private {
        router.addLiquidity(address(token), address(chainToken), token.balanceOf(address(this)), chainToken.balanceOf(address(this)), 0, 0, address(this), block.timestamp);
    }

}