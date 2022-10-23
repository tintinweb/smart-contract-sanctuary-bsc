/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-08-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

interface IERC20 {
	
	function totalSupply() external view returns (uint256);
	function balanceOf(address account) external view returns (uint256);
	function transfer(address recipient, uint256 amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint256);
	function approve(address spender, uint256 amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
	
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);

	event TransferDetails(address indexed from, address indexed to, uint256 total_Amount, uint256 reflected_amount, uint256 total_TransferAmount, uint256 reflected_TransferAmount);
}

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns (bytes calldata) {
		this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
		return msg.data;
	}
}

library Address {
	
	function isContract(address account) internal view returns (bool) {
		uint256 size;
		assembly { size := extcodesize(account) }
		return size > 0;
	}

	function sendValue(address payable recipient, uint256 amount) internal {
		require(address(this).balance >= amount, "Address: insufficient balance");
		(bool success, ) = recipient.call{ value: amount }("");
		require(success, "Address: unable to send value, recipient may have reverted");
	}
	
	function functionCall(address target, bytes memory data) internal returns (bytes memory) {
	  return functionCall(target, data, "Address: low-level call failed");
	}
	
	function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
		return functionCallWithValue(target, data, 0, errorMessage);
	}
	
	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
		return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
	}
	
	function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
		require(address(this).balance >= value, "Address: insufficient balance for call");
		require(isContract(target), "Address: call to non-contract");
		(bool success, bytes memory returndata) = target.call{ value: value }(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}
	
	function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
		return functionStaticCall(target, data, "Address: low-level static call failed");
	}
	
	function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
		require(isContract(target), "Address: static call to non-contract");
		(bool success, bytes memory returndata) = target.staticcall(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
		return functionDelegateCall(target, data, "Address: low-level delegate call failed");
	}
	
	function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
		require(isContract(target), "Address: delegate call to non-contract");
		(bool success, bytes memory returndata) = target.delegatecall(data);
		return _verifyCallResult(success, returndata, errorMessage);
	}

	function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
		if (success) {
		    return returndata;
		} else {
		    if (returndata.length > 0) {
		         assembly {
		            let returndata_size := mload(returndata)
		            revert(add(32, returndata), returndata_size)
		        }
		    } else {
		        revert(errorMessage);
		    }
		}
	}
}

abstract contract Ownable is Context {
	address private _owner;


    event OwnershipRenounced(address indexed previousOwner);

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	constructor () {
		_owner = _msgSender();
		emit OwnershipTransferred(address(0), _owner);
	}
	
	function owner() public view virtual returns (address) {
		return _owner;
	}
	
	modifier onlyOwner() {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }
    
	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}



contract BULLOTOKEN is Context, IERC20, Ownable {
	using Address for address;

	mapping (address => uint256) public _balance_reflected;
	mapping (address => uint256) public _balance_total;
	mapping (address => mapping (address => uint256)) private _allowances;
	
	mapping (address => bool) public _isExcluded;
	
	bool public blacklistMode = true;
	mapping (address => bool) public isBlacklisted;

	bool public tradingOpen = true;
	bool public BULLO = true;
	
	uint256 private constant MAX = ~uint256(0);

	uint8 public constant decimals = 18;
	uint256 public constant totalSupply = 1 * 10**12 * 10**decimals;

	uint256 private _supply_reflected   = (MAX - (MAX % totalSupply));

	string public constant name = "BULLO TOKEN";
	string public constant symbol = "BULLO";

	uint256 public _maxWalletToken = totalSupply / 50;
	uint256 public _maxTxAmount =  totalSupply / 50;
	
	uint256 public _fee_reflection = 51;
	uint256 private _fee_reflection_old = _fee_reflection;
	uint256 public _contractReflectionStored = 0;
	
	uint256 public _fee_operations = 1;
	uint256 private _fee_operations_old = _fee_operations;
	address payable public _operations;

	uint256 public _fee_deadAddress = 25;
	uint256 private _fee_deadAddress_old = _fee_deadAddress;
	address payable public _deadAddress;    

    address constant deadAddress = 0x000000000000000000000000000000000000dEaD;

	uint256 public _fee_denominator = 1000;


	mapping (address => bool) public isFeeExempt;
	mapping (address => bool) public isTxLimitExempt;
	mapping (address => bool) public isWalletLimitExempt;
	address[] public _excluded;

	uint256 public swapThreshold =  ( totalSupply * 2 ) / 1000;

	uint256 public sellMultiplier = 200;
	uint256 public buyMultiplier = 100;
	uint256 public transferMultiplier = 200;

	
	
	
	constructor () {
		_balance_reflected[owner()] = _supply_reflected;

		_operations = payable(0x9D762e77222Bb1E60821174841fe5C2ba1A086BF);
		
        _deadAddress = payable(0x000000000000000000000000000000000000dEaD);
		
		

		isFeeExempt[msg.sender] = true;
		isFeeExempt[address(this)] = true;
		isFeeExempt[deadAddress] = true;

		isTxLimitExempt[msg.sender] = true;
		isTxLimitExempt[deadAddress] = true;
		isTxLimitExempt[_deadAddress] = true;
		isTxLimitExempt[_operations] = true;
		

		isWalletLimitExempt[msg.sender] = true;
		isWalletLimitExempt[address(this)] = true;
		isWalletLimitExempt[deadAddress] = true;
		isWalletLimitExempt[_deadAddress] = true;
		
		
		emit Transfer(address(0), owner(), totalSupply);
	}

	function balanceOf(address account) public view override returns (uint256) {
		if (_isExcluded[account]) return _balance_total[account];
		return tokenFromReflection(_balance_reflected[account]);
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
		_transfer(sender, recipient, amount);
		require (_allowances[sender][_msgSender()] >= amount,"ERC20: transfer amount exceeds allowance");
		_approve(sender, _msgSender(), (_allowances[sender][_msgSender()]-amount));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, (_allowances[_msgSender()][spender] + addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		require (_allowances[_msgSender()][spender] >= subtractedValue,"ERC20: decreased allowance below zero");
		_approve(_msgSender(), spender, (_allowances[_msgSender()][spender] - subtractedValue));
		return true;
	}

	function excludeFromFee(address[] calldata addresses, bool status) external onlyOwner {
		for (uint256 i; i < addresses.length; ++i) {
			isFeeExempt[addresses[i]] = status;
		}
	}    

	function BULLOInfo () public view returns(
		uint256 MaxTxAmount,
		uint256 MaxWalletToken,
		uint256 TotalSupply,
		uint256 Reflected_Supply,
		uint256 Reflection_Rate,
		bool TradingOpen
		) {
		return (MaxTxAmount, MaxWalletToken, totalSupply, _supply_reflected, _getRate(), tradingOpen );
	}

	function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
		require(rAmount <= _supply_reflected, "Amount must be less than total reflections");
		uint256 currentRate =  _getRate();
		return (rAmount / currentRate);
	}

	//core
	function _getRate() private view returns(uint256) {
		(uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
		return rSupply / tSupply;
	}

	function _getCurrentSupply() private view returns(uint256, uint256) {
		uint256 rSupply = _supply_reflected;
		uint256 tSupply = totalSupply;
		for (uint256 i = 0; i < _excluded.length; i++) {
			if (_balance_reflected[_excluded[i]] > rSupply || _balance_total[_excluded[i]] > tSupply) return (_supply_reflected, totalSupply);
			rSupply = rSupply - _balance_reflected[_excluded[i]];
			tSupply = tSupply - _balance_total[_excluded[i]];
		}
		if (rSupply < (_supply_reflected/totalSupply)) return (_supply_reflected, totalSupply);
		return (rSupply, tSupply);
	}


	function _getValues(uint256 tAmount, address recipient, address sender) private view returns (
		uint256 rAmount, uint256 rTransferAmount, uint256 rReflection,
		uint256 tTransferAmount, uint256 tOperations, uint256 tDeadAddress, uint256 tReflection) {

		uint256 multiplier = transferMultiplier;

		

		tOperations = ( tAmount * _fee_operations ) * multiplier / (_fee_denominator * 100);
		
		tDeadAddress = ( tAmount * _fee_deadAddress ) * multiplier / (_fee_denominator * 100);
		
		tReflection = ( tAmount * _fee_reflection ) * multiplier  / (_fee_denominator * 100);

		tTransferAmount = tAmount - ( tOperations + tDeadAddress + tReflection);
		rReflection = tReflection * _getRate();
		rAmount = tAmount * _getRate();
		rTransferAmount = tTransferAmount * _getRate();
	}

	function _takeFee(uint256 feeAmount, address receiverWallet) private {
		uint256 reflectedReeAmount = feeAmount * _getRate();
		_balance_reflected[receiverWallet] = _balance_reflected[receiverWallet] + reflectedReeAmount;

		if(_isExcluded[receiverWallet]){
			_balance_total[receiverWallet] = _balance_total[receiverWallet] + feeAmount;
		}
		if(feeAmount > 0){
			emit Transfer(msg.sender, receiverWallet, feeAmount);
		}
	}

	function _approve(address owner, address spender, uint256 amount) private {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _transfer(address from, address to, uint256 amount) private {

		if(from != owner() && to != owner()){
			require(tradingOpen,"Trading not open yet");

		}

		
		require((amount <= _maxTxAmount) || isTxLimitExempt[from] || isTxLimitExempt[to], "Max TX Limit Exceeded");
		
		bool takeFee = true;
		if(isFeeExempt[from] || isFeeExempt[to]){
		    takeFee = false;
		}
		
		(uint256 rAmount, uint256 rTransferAmount, uint256 rReflection, uint256 tTransferAmount, uint256 tOperations, uint256 tDeadAddress,  uint256 tReflection) = _getValues(amount, to, from);

		_transferStandard(from, to, amount, rAmount, tTransferAmount, rTransferAmount);

		_supply_reflected = _supply_reflected - rReflection;
		_contractReflectionStored = _contractReflectionStored + tReflection;

		if(!takeFee){
		} else{
		    _takeFee(tOperations,_operations);
		   
		    _takeFee(tDeadAddress,_deadAddress);
		    
		}

	}

	function _transferStandard(address from, address to, uint256 tAmount, uint256 rAmount, uint256 tTransferAmount, uint256 rTransferAmount) private {
		_balance_reflected[from]    = _balance_reflected[from]  - rAmount;

		if (_isExcluded[from]){
		    _balance_total[from]    = _balance_total[from]      - tAmount;
		}

		if (_isExcluded[to]){
		    _balance_total[to]      = _balance_total[to]        + tTransferAmount;
		}
		_balance_reflected[to]      = _balance_reflected[to]    + rTransferAmount;

		if(tTransferAmount > 0){
			emit Transfer(from, to, tTransferAmount);	
		}
	}

	receive() external payable {}
}