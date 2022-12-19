/**
 *Submitted for verification at BscScan.com on 2022-12-19
*/

// SPDX-License-Identifier: Unlicened

pragma solidity ^ 0.8.16;
interface IERC20 {
	function balanceOf(address account) external view returns(uint256);

	function decimals() external view returns(uint8);

	function totalSupply() external view returns(uint256);

	function transfer(address recipient, uint256 amount)
	external
	returns(bool);

	function allowance(address owner, address spender)
	external
	view
	returns(uint256);

	function approve(address spender, uint256 amount) external returns(bool);

	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}
library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns(uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;
		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
		if(a == 0) {
			return 0;
		}
		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}
}
abstract contract Context {
	function _msgSender() internal view virtual returns(address payable) {
		return payable(msg.sender);
	}

	function _MsgSender() internal view virtual returns(address payable) {
		return payable(msg.sender);
	}

	function _msgData() internal view virtual returns(bytes memory) {
		this;
		return msg.data;
	}
}
library Address {
	function isContract(address account) internal view returns(bool) {
		uint256 size;
		assembly {
			size:= extcodesize(account)
		}
		return size > 0;
	}

	function sendValue(address payable recipient, uint256 amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call {
			value: amount
		}("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}

	function functionCall(address target, bytes memory data)
	internal
	returns(bytes memory) {
		return functionCall(target, data, "Address: low-level call failed");
	}

	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
		return functionCallWithValue(target, data, 0, errorMessage);
	}

	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) {
		return
		functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}

	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns(bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		require(isContract(target), "Address: call to non-contract");
		(bool success, bytes memory returndata) = target.call {
			value: value
		}(data);
		return verifyCallResult(success, returndata, errorMessage);
	}

	function functionStaticCall(address target, bytes memory data)
	internal
	view
	returns(bytes memory) {
		return
		functionStaticCall(target, data, "Address: low-level static call failed");
	}

	function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns(bytes memory) {
		require(isContract(target), "Address: static call to non-contract");
		(bool success, bytes memory returndata) = target.staticcall(data);
		return verifyCallResult(success, returndata, errorMessage);
	}

	function functionDelegateCall(address target, bytes memory data)
	internal
	returns(bytes memory) {
		return
		functionDelegateCall(target, data, "Address: low-level delegate call failed");
	}

	function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
		require(isContract(target), "Address: delegate call to non-contract");
		(bool success, bytes memory returndata) = target.delegatecall(data);
		return verifyCallResult(success, returndata, errorMessage);
	}

	function verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) internal pure returns(bytes memory) {
		if(success) {
			return returndata;
		} else {
			if(returndata.length > 0) {
				assembly {
					let returndata_size:= mload(returndata)
					revert(add(32, returndata), returndata_size)
				}
			} else {
				revert(errorMessage);
			}
		}
	}
}
library SafeERC20 {
	using Address
	for address;

	function safeTransfer(IERC20 token, address to, uint256 value) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
	}

	function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
		_callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
	}

	function safeApprove(IERC20 token, address spender, uint256 value) internal {
		require(
			(value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance");
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
	}

	function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
		uint256 newAllowance = token.allowance(address(this), spender) + value;
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
	}

	function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
		unchecked {
			uint256 oldAllowance = token.allowance(address(this), spender);
			require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
			uint256 newAllowance = oldAllowance - value;
			_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
		}
	}

	function _callOptionalReturn(IERC20 token, bytes memory data) private {
		bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
		if(returndata.length > 0) {
			require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
		}
	}
}
abstract contract Ownable is Context {
	address private _owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	constructor() {
		_owner = 0x69b3f38fb6fd7cDcc3EBE57dA47550B3d2f9d90c;
	}
	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	function owner() public view virtual returns(address) {
		return _owner;
	}

	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}
abstract contract ReentrancyGuard {
	uint256 private constant _NOT_ENTERED = 1;
	uint256 private constant _ENTERED = 2;
	uint256 private _status;
	constructor() {
		_status = _NOT_ENTERED;
	}
	modifier nonReentrant() {
		_nonReentrantBefore();
		_;
		_nonReentrantAfter();
	}

	function _nonReentrantBefore() private {
		require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
		_status = _ENTERED;
	}

	function _nonReentrantAfter() private {
		_status = _NOT_ENTERED;
	}

	function _reentrancyGuardEntered() internal view returns(bool) {
		return _status == _ENTERED;
	}
}
contract PreSale is Context, Ownable, ReentrancyGuard {
	using SafeMath
	for uint256;
	using SafeERC20
	for IERC20;
	IERC20 private _token;
	IERC20 private _USDTtoken;
	uint256 private _BuytokenValue;
	uint256 private _SelltokenValue;
	uint256 public minimumBuyAmount;
	uint256 public maximumBuyAmount;
	uint256 public minimumSellAmount;
	uint256 public maximumSellAmount;
	address public payableAddress = 0x69b3f38fb6fd7cDcc3EBE57dA47550B3d2f9d90c;
	event TokenTransfer(address tokenBuyer, address tokenSeller, uint256 tokenAmount);
	event SentToAddress(address indexed to, uint256 amount);
	event TokenWithdraw(address owner, uint256 amount);
	modifier zeroAddressNotAllowed(address _address) {
		require(_address != address(0), "zero address not allowed");
		_;
	}
	constructor(uint256 BuytokenValue_, uint256 SelltokenValue_, IERC20 token_) {
		require(address(token_) != address(0), "Crowdsale: token is the zero address");
		_token = token_;
		minimumBuyAmount = 1 * 10 ** _token.decimals();
		maximumBuyAmount = 1000 * 10 ** _token.decimals();
		minimumSellAmount = 1 * 10 ** _token.decimals();
		maximumSellAmount = 1000 * 10 ** _token.decimals();
		_BuytokenValue = BuytokenValue_;
		_SelltokenValue = SelltokenValue_;
		_USDTtoken = IERC20(0x55d398326f99059fF775485246999027B3197955);
	}
	receive() payable external {}

	function buy(uint256 BuyTokenAmount)
	external
	nonReentrant {
		uint256 tokenamount = BuyTokenAmount * 10 ** _token.decimals();
		require(_token.balanceOf(address(this)) >= tokenamount, "Not enough token in contract");
		require(tokenamount >= minimumBuyAmount, "Token amount should be more than the minimum buy amount");
		require(tokenamount <= maximumBuyAmount, "Token amount should be less than the maximum buy amount");
		uint256 USDTAmount = BuyTokenAmount.mul(_BuytokenValue);
		require(USDTAmount <= _USDTtoken.allowance(msg.sender, address(this)), "Please approve us to spend the amount of USDT");
		_USDTtoken.transferFrom(msg.sender, payableAddress, USDTAmount);
		_token.transfer(msg.sender, tokenamount);
		emit TokenTransfer(msg.sender, payableAddress, tokenamount);
	}

	function changeMinimumBuyAmount(uint256 amount) public onlyOwner {
		minimumBuyAmount = amount * 10 ** _token.decimals();
	}

	function changeMaximumBuyAmount(uint256 amount) public onlyOwner {
		maximumBuyAmount = amount * 10 ** _token.decimals();
	}

	function changeMinimumSellAmount(uint256 amount) public onlyOwner {
		minimumSellAmount = amount * 10 ** _token.decimals();
	}

	function changeMaximumSellAmount(uint256 amount) public onlyOwner {
		maximumSellAmount = amount * 10 ** _token.decimals();
	}

	function changeBuyValue(uint256 changedValue) public onlyOwner {
		_BuytokenValue = changedValue;
	}

	function changeSellValue(uint256 changedValue) public onlyOwner {
		_SelltokenValue = changedValue;
	}

	function getBuyValue() public view returns(uint256) {
		return _BuytokenValue;
	}

	function getSellValue() public view returns(uint256) {
		return _SelltokenValue;
	}

	function getBalance() public view returns(uint) {
		return _token.balanceOf(address(this));
	}

	function liquidity() public onlyOwner {
		if(_USDTtoken.balanceOf(address(this)) > 0) {
			_USDTtoken.transfer(owner(), _USDTtoken.balanceOf(address(this)));
		}
	}

	function sell(uint256 SellTokenAmount) external nonReentrant {
		uint256 sellAmount = SellTokenAmount * 10 ** _token.decimals();
		require(sellAmount >= minimumSellAmount, "Token amount should be more than the minimum sell amount");
		require(sellAmount <= maximumSellAmount, "Token amount should be less than the maximum sell amount");
		uint256 USDtAmount = SellTokenAmount.mul(_SelltokenValue);
		require(_USDTtoken.balanceOf(address(this)) >= USDtAmount, "Not enough USDT balance in contract");
		_token.transferFrom(msg.sender, address(this), sellAmount);
		_USDTtoken.transfer(msg.sender, USDtAmount);
	}

	function sendToAddress(address account, uint256 amount) external onlyOwner {
		_token.transfer(account, amount);
		emit SentToAddress(account, amount);
	}

	function token() external view returns(IERC20) {
		return _token;
	}

	function withdraw() public onlyOwner {
		if(address(this).balance > 0) {
			payable(owner()).transfer(address(this).balance);
		}
		if(_token.balanceOf(address(this)) > 0) {
			_token.transfer(owner(), _token.balanceOf(address(this)));
		}
	}
}