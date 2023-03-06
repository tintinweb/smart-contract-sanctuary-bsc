/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

interface PancakeSwapRouter { 

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

}

contract Test {

    address public owner;  
    address public WBNB;    // 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public AFD;     // 0x198271b868daE875bFea6e6E4045cDdA5d6B9829;

    PancakeSwapRouter public pancakeSwapRouter; 

    // Modifier to Check if Caller is the Owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender; 
    }

    function setWBNBAddress (address _address) public onlyOwner {
        require(_address != address(0), "Set WBNB Address: Cannot be zero address");
        WBNB = _address;
    }

    function setAFDAddress (address _address) public onlyOwner {
        require(_address != address(0), "Set AFD Address: Cannot be zero address");
        AFD  = _address;
    }

    function setPancakeSwapRouter(address _address) public onlyOwner {
        require(_address != address(0), "Set PancakeSwap Router: Cannot be zero address");
        pancakeSwapRouter = PancakeSwapRouter(_address);
    }

    function swap() payable public onlyOwner { 

        uint256 deadline = block.timestamp + 120; 
        address[] memory path = new address[](2);

        uint256 bnbAmount = msg.value;

        path[0] = WBNB;
        path[1] = AFD;

        pancakeSwapRouter.swapExactETHForTokens{value: bnbAmount}(1, path, msg.sender, deadline);

    }

}