/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface Exchange{



function swapExactTokensForTokensSupportingFeeOnTransferTokens(
  uint amountIn,
  uint amountOutMin,
  address[] calldata path,
  address to,
  uint deadline
) external;

function getAmountsOut(uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
}
interface ERC20{
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
}
contract Arbitrage is Ownable{

uint256 slippage = 900;
	 function getAmountOutMin(address router, address _tokenIn, address _tokenOut, uint256 _amount) public view returns (uint256) {
		address[] memory path;
		path = new address[](2);
		path[0] = _tokenIn;
		path[1] = _tokenOut;
		uint256[] memory amountOutMins = Exchange(router).getAmountsOut(_amount, path);
		return amountOutMins[path.length -1];
	}
function exchange (address _exchange1, address _exchange2, address _token0,address _token1, uint256 _amountIn,address _owner) public onlyOwner returns (uint256){

/////////////////////////////////////////////////////////////////////
ERC20(_token0).transferFrom(_owner,address(this),_amountIn);
uint256 startBalance = ERC20(_token0).balanceOf(address(this));
/////////////////////////////////////////////////////////////////////
uint256 approvedAmount = ERC20(_token0).allowance(address(this), _exchange1);
if(approvedAmount<_amountIn){
    ERC20(_token0).approve(_exchange1, _amountIn*10);
}
/////////////////////////////////////////////////////////////////////
address[] memory path = new address[](2);
address[] memory path2 = new address[](2);

path[0] = _token0;
path[1] = _token1;
path2[1] = _token0;
path2[0] = _token1;
uint256 amountOut1 = getAmountOutMin(_exchange1,_token0,_token1,_amountIn);
/////////////////////////////////////////////////////////////////////
Exchange(_exchange1).swapExactTokensForTokensSupportingFeeOnTransferTokens(_amountIn, amountOut1*(slippage/1000), path, address(this), block.timestamp+600);
/////////////////////////////////////////////////////////////////////
uint256 approvedAmount2 = ERC20(_token1).allowance(address(this), _exchange2);
uint256 availBalance = ERC20(_token1).balanceOf(address(this));
if(approvedAmount2<availBalance){
    ERC20(_token1).approve(_exchange2, availBalance*10);
}

uint256 amountOut2 = getAmountOutMin(_exchange2,_token1,_token0,amountOut1);
//////////////////////////////////////////////////////////////////////
Exchange(_exchange2).swapExactTokensForTokensSupportingFeeOnTransferTokens(availBalance, amountOut2*(slippage/1000), path2, address(this), block.timestamp+600);
uint256 endBalance = ERC20(_token0).balanceOf(address(this));
ERC20(_token0).transfer(_owner,endBalance);

 require(endBalance > startBalance, "Trade Reverted, No Profit Made");
 uint256 diff = endBalance-startBalance;
 return diff;

}


function setSlippage(uint256 _rate) external onlyOwner{
    require(slippage<1000,"Too high");
    slippage = _rate;
}

  function estimateDualDexTrade(address _router1, address _router2, address _token1, address _token2, uint256 _amount) external view returns (uint256) {
		uint256 amtBack1 = getAmountOutMin(_router1, _token1, _token2, _amount);
		uint256 amtBack2 = getAmountOutMin(_router2, _token2, _token1, amtBack1);
		return amtBack2;
	}
	function getBalance (address _tokenContractAddress) external view  returns (uint256) {
		uint balance = ERC20(_tokenContractAddress).balanceOf(address(this));
		return balance;
	}
	
	function recoverEth() external onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}

	function recoverTokens(address tokenAddress) external onlyOwner {
		ERC20 token = ERC20(tokenAddress);
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}

}