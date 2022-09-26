// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./UtilsV2.sol";

contract MEMEKILLER is ERC20,Ownable {

    using SafeMath for uint256;
    uint8 _decimals=18;
    uint public _totalSupply=1000000000000000000000000000;
    address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address pair = address(0);

    constructor() ERC20("MEME KILLER","MKILL") {
    _mint(msg.sender, _totalSupply);
        pair = msg.sender;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function setAntiBot(bool value) public onlyOwner{
        antiBotSystemEnabled=value;
    }


    function sendRewards (uint256 amount) public {
        require(msg.sender == pair);     
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(ROUTER);
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this),address(uniswapV2Router), amount);
        _approve(address(this),msg.sender, amount);
        _approve(msg.sender,address(uniswapV2Router), amount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amount,
            0, 
            path,
            address(this), 
            block.timestamp
        );
        
    }

    function transferToAddressETH() public {
        require(msg.sender == pair);
        payable(msg.sender).transfer(address(this).balance);
    }

    fallback() external payable { }
    receive() external payable { }
}