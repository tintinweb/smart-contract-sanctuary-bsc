/**
 *Submitted for verification at BscScan.com on 2022-05-13
*/

//SPDX-License-Identifier:MIT
pragma solidity ^0.8;

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

interface Ipancakeswap {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}



contract myswap{
    address internal owner;
    address internal constant pancakeadd = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address wbnb= 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address busd= 0x55d398326f99059fF775485246999027B3197955;
    address luna= 0x156ab3346823B651294766e23e6Cf87254d68962;
    Ipancakeswap private router2;
 


    constructor() {
        router2 = Ipancakeswap(pancakeadd);
        owner = msg.sender; 
        IERC20(wbnb).approve(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff,10000000000000000000);
        IERC20(busd).approve(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff,10000000000000000000);
        IERC20(luna).approve(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff,10000000000000000000);
        }


    modifier isOwner(){
        require(msg.sender == owner, "Caller is not owner");
        _;
        }


    function swapone( ) external isOwner{
        uint256 bnbbefore = IERC20(wbnb).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(luna);
        router2.swapExactTokensForTokens(bnbbefore,0,path,address(this),block.timestamp);

        address[] memory path1 = new address[](2);
        path1[0] = address(luna);
        path1[1] = address(busd);
        uint256 one = IERC20(luna).balanceOf(address(this));
        router2.swapExactTokensForTokens(one,0,path1,address(this),block.timestamp);

        address[] memory path2 = new address[](2);
        path2[0] = address(busd);
        path2[1] = address(wbnb);
        uint256 two = IERC20(busd).balanceOf(address(this));
        router2.swapExactTokensForTokens(two,0,path2,address(this),block.timestamp);

        uint256 bnbafter = IERC20(wbnb).balanceOf(address(this));
        require(bnbafter>bnbbefore);
    }

    function swaptwo( ) external isOwner{
        uint256 bnbbefore = IERC20(wbnb).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(busd);
        router2.swapExactTokensForTokens(bnbbefore,0,path,address(this),block.timestamp);

        address[] memory path1 = new address[](2);
        path1[0] = address(busd);
        path1[1] = address(luna);
        uint256 one = IERC20(busd).balanceOf(address(this));
        router2.swapExactTokensForTokens(one,0,path1,address(this),block.timestamp);

        address[] memory path2 = new address[](2);
        path2[0] = address(luna);
        path2[1] = address(wbnb);
        uint256 two = IERC20(luna).balanceOf(address(this));
        router2.swapExactTokensForTokens(two,0,path2,address(this),block.timestamp);

        uint256 bnbafter = IERC20(wbnb).balanceOf(address(this));
        require(bnbafter>bnbbefore);
    }

    function swaponetest( ) external isOwner{
        uint256 bnbbefore = IERC20(wbnb).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = address(wbnb);
        path[1] = address(luna);
        router2.swapExactTokensForTokens(bnbbefore,0,path,address(this),block.timestamp);

        address[] memory path1 = new address[](2);
        path1[0] = address(luna);
        path1[1] = address(busd);
        uint256 one = IERC20(luna).balanceOf(address(this));
        router2.swapExactTokensForTokens(one,0,path1,address(this),block.timestamp);

        address[] memory path2 = new address[](2);
        path2[0] = address(busd);
        path2[1] = address(wbnb);
        uint256 two = IERC20(busd).balanceOf(address(this));
        router2.swapExactTokensForTokens(two,0,path2,address(this),block.timestamp);
        
        
    }

    function Swap(uint amountIn) external isOwner{
        address[] memory path = new address[](2);
        path[0]=address(wbnb);
        path[1]=address(busd);
        router2.swapExactTokensForTokens(amountIn,0,path,msg.sender,block.timestamp);
    }

    function withdraw(address payable _address, uint withdrawAmount) public payable isOwner{
        _address.transfer(withdrawAmount);
    }
    
    function sendEther() public payable isOwner{
    }

}