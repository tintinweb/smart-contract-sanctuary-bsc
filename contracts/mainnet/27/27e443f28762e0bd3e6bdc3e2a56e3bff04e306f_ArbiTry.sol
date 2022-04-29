/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        _owner = 0x29ED964bfF9b9eae368Ff6A2705C2bC1672E228c;
        emit OwnershipTransferred(address(0), _owner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint);
	function approve(address spender, uint amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}

interface IUniswapV2Router {
  function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external returns (uint256[] memory amounts);
}

interface IUniswapV2Pair {
  function token0() external view returns (address);
  function token1() external view returns (address);
  function swap(uint256 amount0Out,	uint256 amount1Out,	address to,	bytes calldata data) external;
}

contract ArbiTry is Ownable {

	address public Operator;

	modifier onlyOperator() {
      require(msg.sender == Operator);
      _;
   	}

	function newOperator(address _newOperator) external onlyOwner {
		Operator = _newOperator;
	}

	function swap(address router, address _tokenIn, address _tokenOut, uint256 _amount) private {
		IERC20(_tokenIn).approve(router, _amount);
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint deadline = block.timestamp + 300;
		IUniswapV2Router(router).swapExactTokensForTokens(_amount, 1, path, address(this), deadline);
	}

	 function getAmountOutMin(address router, address _tokenIn, address _tokenOut, uint256 _amount) public view returns (uint256) {
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint256[] memory amountOutMins = IUniswapV2Router(router).getAmountsOut(_amount, path);
		return amountOutMins[path.length -1];
	}

  	function estimateDualDexTrade(address _router1, address _router2, address _token1, address _token2, uint256 _amount) external view returns (uint256) {
		uint256 amtBack1 = getAmountOutMin(_router1, _token1, _token2, _amount);
		uint256 amtBack2 = getAmountOutMin(_router2, _token2, _token1, amtBack1);
		return amtBack2;
	}
	function estimateTriDexTrade(address _router1, address _router2, address _router3, address _token1, address _token2, address _token3, uint256 _amount) external view returns (uint256) {
		uint amtBack1 = getAmountOutMin(_router1, _token1, _token2, _amount);
		uint amtBack2 = getAmountOutMin(_router2, _token2, _token3, amtBack1);
		uint amtBack3 = getAmountOutMin(_router3, _token3, _token1, amtBack2);
		return amtBack3;
	}
	
  	function dualDexTrade(address _router1, address _router2, address _token1, address _token2, uint256 _amount) external onlyOperator {
		
		uint startBalance = IERC20(_token1).balanceOf(address(this));
		uint token2InitialBalance = IERC20(_token2).balanceOf(address(this));
		
		swap(_router1,_token1, _token2,_amount);
		
		uint token2Balance = IERC20(_token2).balanceOf(address(this));
		uint tradeableAmount = token2Balance - token2InitialBalance;
		
		swap(_router2,_token2, _token1,tradeableAmount);
		
		uint endBalance = IERC20(_token1).balanceOf(address(this));
		
		require(endBalance > startBalance, "Dual DEX Trade Reverted, No Profit Made");
  	}

	function triDexTrade(address _router1, address _router2, address _router3, address _token1, address _token2, address _token3, uint256 _amount) external onlyOperator {

		uint startBalance = IERC20(_token1).balanceOf(address(this));
		uint token2InitialBalance = IERC20(_token2).balanceOf(address(this));
		uint token3InitialBalance = IERC20(_token3).balanceOf(address(this));

		swap(_router1,_token1, _token2,_amount);
		
		uint token2Balance = IERC20(_token2).balanceOf(address(this));
		uint tradeableAmount = token2Balance - token2InitialBalance;
		
		swap(_router2,_token2, _token3,tradeableAmount);
		
		uint token3Balance = IERC20(_token3).balanceOf(address(this));
		uint tradeableAmount2 = token3Balance - token3InitialBalance;
		
		swap(_router3,_token3, _token1,tradeableAmount2);

		uint endBalance = IERC20(_token1).balanceOf(address(this));
		
		require(endBalance > startBalance, "Tri DEX Trade Reverted, No Profit Made");
  	}

	function getBalance (address _tokenContractAddress) external view  returns (uint256) {
		uint balance = IERC20(_tokenContractAddress).balanceOf(address(this));
		return balance;
	}
	
	function recoverEth() external onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}

	function recoverTokens(address tokenAddress) external onlyOwner {
		IERC20 token = IERC20(tokenAddress);
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}

	receive() external payable {
	}

}