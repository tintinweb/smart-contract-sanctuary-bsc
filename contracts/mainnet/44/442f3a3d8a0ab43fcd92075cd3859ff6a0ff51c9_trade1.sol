/**
 *Submitted for verification at BscScan.com on 2022-05-29
*/

// SPDX-License-Identifier: Unlicensed 
pragma solidity =0.8.14;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IPancakeRouter {
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline)
        external payable returns (uint[] memory amounts);
}

contract trade1 {
    address public owner;
    constructor () {
        owner = msg.sender;
       
    }
    
    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
    
    
    
    
    //address of the PCS V2 router
    address private constant PANCAKE_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;


    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function trade(address _tokenIn, address _tokenOut, uint _amountOutMin, address _to,uint _split) onlyOwner external payable{

        address[] memory path;
        path = new address[](2);
        path[0] = _tokenIn;
        path[1] = _tokenOut;

        uint splittedPayment = msg.value/_split;

        for(uint i =0;i<_split;i++){
            IPancakeRouter(PANCAKE_V2_ROUTER).swapExactETHForTokens{value:splittedPayment}(_amountOutMin, path, _to, block.timestamp);

        }

    }

}