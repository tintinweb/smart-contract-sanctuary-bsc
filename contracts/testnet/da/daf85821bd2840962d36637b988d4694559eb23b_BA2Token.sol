pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed

import "./IERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract BA2Token is IERC20, Ownable {
	using SafeMath for uint256;

	mapping(address => uint256) private _tOwned;
	mapping(address => mapping(address => uint256)) private _allowances;
	mapping(address => bool) private _isSwapExempt;
	mapping(address => bool) private _isExcludedFromFee;

	address public addBurn = 0x000000000000000000000000000000000000dEaD;   
	address public addFoundation;   
	address public addNft;   

	uint256 private _tFeeTotal;

	string private _name = "SATT";
	string private _symbol = "SATT";
	uint8 private _decimals = 6;

	uint256 public _burnFee = 500;
	uint256 public _NftFee = 500;
	uint256 public _FoundationFee = 100;

	uint256 private _tTotal = 1 * 10**7 * 10**6;


	constructor() {
		_tOwned[msg.sender] = _tTotal;
		_isExcludedFromFee[msg.sender] = true;
		_isExcludedFromFee[address(this)] = true;
		_isExcludedFromFee[address(0)] = true;
		_isExcludedFromFee[addBurn] = true;
		emit Transfer(address(0), msg.sender, _tTotal);
	}

	function name() public view returns (string memory) {
		return _name;
	}

	function symbol() public view returns (string memory) {
		return _symbol;
	}

	function decimals() public view returns (uint256) {
		return _decimals;
	}

	function totalSupply() public view override returns (uint256) {
		return _tTotal;
	}

	function balanceOf(address account) public view override returns (uint256) {
		return _tOwned[account];
	}

	function transfer(address recipient, uint256 amount) public override returns (bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view override returns (uint256) {
		return _allowances[owner][spender];
	}

	function approve(address spender, uint256 amount) public override returns (bool) {
		_approve(msg.sender, spender, amount);
		return true;
	}

	function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender,msg.sender,_allowances[sender][msg.sender].sub(amount,"ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
		_approve( msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function totalFees() public view returns (uint256) {
		return _tFeeTotal;
	}

	function isExcludedFromFee(address account) public view returns (bool) {
		return _isExcludedFromFee[account];
	}
	function excludeFromFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = true;
	}

	function includeFromFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = false;
	}

	function isExcludedSwap(address account) public view returns (bool) {
		return _isSwapExempt[account];
	}
	function excludeSwap(address account) public onlyOwner {
		_isSwapExempt[account] = true;
	}

	function includeSwap(address account) public onlyOwner {
		_isSwapExempt[account] = false;
	}

	function setFoundatioAdd(address _addFoundation) public onlyOwner {
		addFoundation = _addFoundation;
	}

	function setNftAdd(address _addNft) public onlyOwner {
		addNft = _addNft;
	}

	function _approve(address owner, address spender, uint256 amount ) private {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _transfer(address from, address to, uint256 amount) private {
		require(from != address(0), "ERC20: transfer from the zero address");
		require(to != address(0), "ERC20: transfer to the zero address");
		require(amount > 0, "Transfer amount must be greater than zero");

		_tokenTransfer(from, to, amount);
	}   

	function _tokenTransfer(
		address sender,
		address recipient,
		uint256 tAmount
	) private {
		uint256 nNftfee = 0;
		uint256 nFoundationfee = _FoundationFee;
		uint256 nBurnfee = 0;
		uint256 nTotalfee = 0;
		
		if (_isSwapExempt[sender]) {
		    nNftfee = _NftFee;
		    nTotalfee = nNftfee.add(nFoundationfee);
		}
		if (nTotalfee==0) {
		    nBurnfee = _burnFee;
		    nTotalfee = nBurnfee.add(nFoundationfee);
		}
		if (_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
		    nNftfee = 0;
		    nFoundationfee = 0;
		    nBurnfee = 0;
		    nTotalfee = 0;
		}
		_tOwned[sender] = _tOwned[sender].sub(tAmount);
		if (nNftfee>0){
			_tOwned[addNft] = _tOwned[addNft].add(tAmount.div(10000).mul(nNftfee));
			emit Transfer(sender, addNft, tAmount.div(10000).mul(nNftfee));
		}
		if (nFoundationfee>0){
			_tOwned[addFoundation] = _tOwned[addFoundation].add(tAmount.div(10000).mul(nFoundationfee));
			emit Transfer(sender, addFoundation, tAmount.div(10000).mul(nFoundationfee));
		}
		if (nBurnfee>0){
			_tOwned[addBurn] = _tOwned[addBurn].add(tAmount.div(10000).mul(nBurnfee));
			emit Transfer(sender, addBurn, tAmount.div(10000).mul(nBurnfee));
		}
		uint256 recipientRate = 10000 - nTotalfee;
		_tOwned[recipient] = _tOwned[recipient].add(tAmount.div(10000).mul(recipientRate));

		emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
	}
}