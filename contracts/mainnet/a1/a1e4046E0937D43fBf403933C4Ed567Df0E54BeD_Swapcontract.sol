// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.6 <0.8.0;

import './Ownable.sol';
import './UniswapV2Library.sol';
import './IERC20.sol';
import './IUniswapV2Pair.sol';
import './IUniswapV2Factory.sol';
import './IUniswapV2Router02.sol';

contract Swapcontract is Ownable {
    // https://bscscan.com/address/0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F
    address private constant pancakeRouter = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
    // https://bscscan.com/address/0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    constructor() {}

    function startSwap(
        address token0,
        address token1,
        uint amount0,
        uint amount1
    ) external  {
        // transfer input tokens to this contract address
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        // approve pancakeRouter to transfer tokens from this contract
        IERC20(token0).approve(pancakeRouter, amount0);

        address[] memory path;
        if (token0 == WBNB || token1 == WBNB) {
            path = new address[](2);
            path[0] = token0;
            path[1] = token1;
        } else {
            path = new address[](3);
            path[0] = token0;
            path[1] = WBNB;
            path[2] = token1;
        }

        IUniswapV2Router02(pancakeRouter).swapExactTokensForTokens(
            amount0,
            amount1,
            path,
            msg.sender, // or address(this), and transfer the swapped token to msg.sender
            block.timestamp + 60
        );
    }

    function destruct() public onlyOwner {
        address payable owner = payable(owner());
        selfdestruct(owner);
    }

    function register(address sender) public payable {}

    //0xd9145CCE52D386f254917e481eB44e9943F39138

    function deposittocontract( uint256 amount) public payable returns(uint256){
       require(msg.value == amount);
      // transfer(msg.sender, 0.001);
      // IERC20(token0).transferFrom(msg.sender, address(this), amount0);

      //let amount = Self::env().transferred_value();
      
       
    }

    receive() external payable {
        // React to receiving BNB
    }

function  lendtoPancakeswap() public view returns(uint256){

    // get balance before you lend
    return address(this).balance;

}
function withdrwalBNBFromcontract(uint256 amount) external onlyOwner{
    payable(msg.sender).transfer(amount);
}


function borrowfrompancakeswap() public payable{}

function swapAndlendagain() public payable {}

function flashswapTopayborowedamount() public payable{
    
}

function withdrwallentmoneyAndPayBackFlashswap() public {
   // require(owner == msg.sender);
    msg.sender.transfer(address(this).balance);

}

// transfer or send tokens, withdrwal
 
/*
   interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}
 // this function can accept BNB  ie deposit, receive on fl
    // the accepted amount is in the `msg.value` global variable
    function foo() external payable {
        IERC20 tokenContract = IERC20(address(0x456));
        // sending 1 smallest unit of the token to the user executing the `foo()` function
        tokenContract.transfer(msg.sender, 0.001);
        0xaCFBAe0b31DC302C339b5d82e62F56c3Dc268D0F
    }
*/



    

}