/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IRouter {
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, uint fee) external pure returns (uint amountOut);
    function getAmountsOut( uint amountIn, address[] memory path, address pairAdd, uint fee) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    function swapTokens(
        uint amountIn,
        uint amountOutMin,
        
        address[] memory path,
        address pair,

        address to,
        uint fee
    ) external;
    function swapETHForTokens(
        uint amountOutMin,

        address[] memory path, // [wbnb, token]
        address pair,

        address to,
        uint fee
    ) external payable;
    function swapTokensForETH(
        uint amountIn,
        uint amountOutMin,
        
        address[] memory path, // [token, wbnb]
        address pair,

        address to,
        uint fee
    ) external;
}

contract RecktorDouble {

  uint constant MAX_UINT = type(uint256).max;
  address dead = 0x0000000000000000000000000000000000000000;
  address payable owner;
  address router;
  constructor( address _router ) {
      owner = payable(msg.sender);
      router = _router;
  }

   modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

  function approve(address spender, address tokenAddress) public {
      IERC20 token = IERC20(tokenAddress);
      if(token.allowance(address(this), address(spender)) < 1){
          require(token.approve(address(spender), MAX_UINT),"FAIL TO APPROVE");
      }
  }

  function dualDexTrade(
    address[3] memory path, // bnb, A, B
    address[4] memory pairs, // bnb, A, B,
    uint256[4] memory fees, // bnb, A, B,
    
    uint256 _amountIn, // bnb or tokenA to swap
    bool activeRevert
  ) external payable isOwner {

    uint256 tokenAInitialBalance = IERC20(path[1]).balanceOf(address(this)); // 20 usdt
    uint256 tokenBInitialBalance = IERC20(path[2]).balanceOf(address(this)); //  b balanccec = 1 bnb

    address[] memory tempPath;
    tempPath[0] = path[0];
    tempPath[1] = path[1];

    uint256 tradeableAAmount;
    if( path[0] != dead ){ // swap BNB -> A 
      IRouter(router).swapETHForTokens{value: msg.value}( 0, tempPath, pairs[0], address(this), fees[0] );
      tradeableAAmount = IERC20(path[1]).balanceOf(address(this)) - tokenAInitialBalance;
    } else {
      tradeableAAmount = _amountIn; // 5 usdt
    }
    { // added scope to avoid 'Stack too dip'
      tempPath[0] = path[1];
      tempPath[1] = path[2];
      approve(router, path[1]);
      IRouter(router).swapTokens(tradeableAAmount, 0, tempPath, pairs[1], address(this), fees[1]);
    }

    { // added scope to avoid 'Stack too dip'
      tempPath[0] = path[2];
      tempPath[1] = path[1];
      approve(router, path[2]);
      IRouter(router).swapTokens(
        IERC20(path[2]).balanceOf(address(this)) - tokenBInitialBalance,  // tradable B Amount
        0, tempPath, pairs[2], address(this), fees[2]);
    }

    uint256 finalAAmount = IERC20(path[1]).balanceOf(address(this));
    uint256 spentAAmount = tradeableAAmount + tokenAInitialBalance;

    if( finalAAmount > spentAAmount ){
      { // added scope to avoid 'Stack too dip'
        tempPath[0] = path[1];
        tempPath[1] = path[0];
        IRouter(router).swapTokensForETH( finalAAmount, 0, tempPath, pairs[3], address(this), fees[3] );
        owner.transfer(address(this).balance);
      }
    } else {
      if( activeRevert ){   
        require( finalAAmount > spentAAmount, "Trade Reverted, No Profit Made");
      }
    }

  }

  function withdraw() external isOwner {
      owner.transfer(address(this).balance);
  }

  function withdrawToken(address tokenAddress, address to) external isOwner{
      IERC20 token = IERC20(tokenAddress);
      token.transfer(to, token.balanceOf(address(this)));
  }

  receive() external payable{}

}