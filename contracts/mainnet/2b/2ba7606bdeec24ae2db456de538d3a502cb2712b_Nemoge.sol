/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract Nemoge is Context, IERC20, IERC20Metadata,Ownable {
    using Address for address payable;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isAccountBanned;
    
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 10_000_000 * 10**_decimals;
    string private _name = "Nemoge";
    string private _symbol = "NDOGE";

    address public treasuryWallet = 0xc958049a10A3E6cB6FD52E4Aac5CE313c7811a24;
    uint8 public buyTax = 8;
    uint8 public sellTax = 8;

    IRouter public router;
    address public pair;
    
    uint256 private _swapTokensAmount = _totalSupply * 5 / 1000;
    bool private _swapping;

    bool public tradingEnabled;
    uint256 private _dangerTime = 240;
    uint256 private _dangeTimeStart;

    modifier lockTheSwap {
        _swapping = true;
        _;
        _swapping = false;
    }

    constructor() {

        IRouter _router = IRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        _approve(address(this), address(router), ~uint256(0));

        _isExcludedFromFees[owner()] = true;
        _isExcludedFromFees[treasuryWallet] = true;

        _balances[owner()] +=_totalSupply;
        emit Transfer(address(0),owner(), _totalSupply);
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() external view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) external virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address from,address to,uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(!_isAccountBanned[from] && !_isAccountBanned[to], "Banned account cannot trade.");

        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
            require(tradingEnabled, "Trading not active");
        }

        if(block.timestamp < _dangeTimeStart && from == pair){
            _isAccountBanned[to] = true;
        }

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        if(_balances[address(this)] >= _swapTokensAmount && !_swapping && from != pair)
            _swapAndLiquify();

        _balances[from] = fromBalance - amount;

        uint256 fAmount = amount;
        if(!_isExcludedFromFees[from] && !_isExcludedFromFees[to]){
           fAmount = _getTaxes(amount, from, to == pair);
        }

        _balances[to] += fAmount;
        emit Transfer(from, to, fAmount);
    }

    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _getTaxes(uint256 amount,address from,bool isSell) private returns(uint256){
        uint8 tmpTax = buyTax;
        if(isSell)
            tmpTax = sellTax;

        uint256 taxAmount = amount * tmpTax / 100;
        _balances[address(this)] += taxAmount;
        emit Transfer(from, address(this), taxAmount);
        return amount - taxAmount;
    }

    function _swapAndLiquify() private lockTheSwap{
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(_balances[address(this)], 0, path, treasuryWallet, block.timestamp);
    }

    function _setTradingStatus(bool status_) external onlyOwner{
        tradingEnabled = status_;
        _dangeTimeStart = block.timestamp + _dangerTime;
    }

    function setIsBanned(address account, bool isBanned) external onlyOwner{
        _isAccountBanned[account] = isBanned;
    }

    function setIsExcludedFromFee(address account, bool isExcluded) external onlyOwner{
        _isExcludedFromFees[account] = isExcluded;
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner{
        require(address(this).balance >= weiAmount, "insufficient BNB balance");
        payable(msg.sender).transfer(weiAmount);
    }
    
    function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amountExact, uint _decimal) public onlyOwner {
        IERC20(_tokenAddr).transfer(_to, _amountExact *10**_decimal);
    }

    receive() external payable{
    }


}