/**
 *Submitted for verification at BscScan.com on 2022-05-22
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed


interface IPancakeV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Token {
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint8 public _taxFee;
    uint8 private _previousTaxFee;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    
    uint256 private _tTotal; 
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    constructor () {
        _tTotal = 100 * 10**6 * 10**9;
        _tOwned[msg.sender] = _tTotal;
        // Create a pancakeswap pair for this new token
        IPancakeV2Factory(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73).createPair(address(this), 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _name = "Swag Time";
        _symbol = "UHOH";
        _decimals = 9;
        _taxFee = 6;
        _previousTaxFee = _taxFee;
        emit Transfer(address(0), msg.sender, _tTotal);
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        _transfer(from, to, amount);
        _approve(from, msg.sender, _allowances[from][msg.sender] - amount);
        return true;
    }

    receive() external payable {}

    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tFee = (tAmount * _taxFee)/100;
        uint256 tTransferAmount = tAmount - tFee;
        return (tTransferAmount, tFee);
    }
    
    function removeAllFee() private {
        if( _taxFee == 0) return;      
        _previousTaxFee = _taxFee;
        _taxFee = 0;
    }
    
    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
    }
    
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    
    function _tokenTransfer(address from, address to, uint256 amount,bool takeFee) private {
        address burn = 0x000000000000000000000000000000000000dEaD;
        if(!takeFee)
            removeAllFee();
        (uint256 tTransferAmount, uint256 tFee) = _getValues(amount);
        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + tTransferAmount;
        _tOwned[burn] = _tOwned[burn] + tFee;
        if(!takeFee)
            restoreAllFee();
        emit Transfer(from, to, tTransferAmount);
    }
    
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        
        //indicates if fee should be deducted from transfer
        bool takeFee = true;
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }
        
        //transfer amount, it will burn the transaction tax
        _tokenTransfer(from,to,amount,takeFee);
    }
}