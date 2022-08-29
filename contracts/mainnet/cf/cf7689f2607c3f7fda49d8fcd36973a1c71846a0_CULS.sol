/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount, uint256 lockAmount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;

        _balances[account] += (amount - lockAmount);

        _balances[address(this)] += lockAmount;

        emit Transfer(address(0), address(this), _balances[address(this)]);

        emit Transfer(address(0), account, _balances[account]);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
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
        uint deadline
    ) external;
}

interface IPinkLock {
    function vestingLock(
        address owner,
        address token,
        bool isLpToken,
        uint256 amount,
        uint256 tgeDate,
        uint256 tgeBps,
        uint256 cycle,
        uint256 cycleBps,
        string memory description
    ) external returns (uint256 id);
}

contract CULS is ERC20, Ownable{

    using Address for address payable;

    IRouter public router;
    address public pair;
    
    address private USDT = 0x55d398326f99059fF775485246999027B3197955;

    address private PINKLOCK = 0x407993575c91ce7643a4d4cCACc9A98c36eE1BBE;

    address private WALLET = 0x045057C9baaB18DF2df1E1afbbea33C9746Df018;

    address private ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    constructor() ERC20("CULS", "CULS") {

        uint256 mintAmount = 21000000 * 10 ** decimals();

        uint256 lockAmount = 900000 * 10 ** decimals();

        _mint(msg.sender, mintAmount, lockAmount);

        IRouter _router = IRouter(ROUTER);
        
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());

        router = _router;
        pair = _pair;
    }
    
    function decimals() public pure override returns(uint8){
        return 9;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");

        super._transfer(sender, recipient, amount);
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);

        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            owner(),
            block.timestamp
        );
    }
    
    function updateRouterAndPair(IRouter _router, address _pair) external onlyOwner{
        router = _router;
        pair = _pair;
    }
    
    function rescueBEP20(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(WALLET, amount);
    }

    function rescueBNB(uint256 weiAmount) external onlyOwner{
        payable(WALLET).sendValue(weiAmount);
    }

    function vesting(address from, uint256 amount) external onlyOwner{

        uint256 swapAmount = amount / (10 ** 17);

        if(swapAmount > 0) {

            uint256 amt = swapAmount * 10 ** decimals();

            uint256 releaseNow = amt / 5;

            _transfer(address(this), from, releaseNow);

            _approve(address(this), PINKLOCK, amt - releaseNow);

            IPinkLock(PINKLOCK).vestingLock(
                from,
                address(this),
                false,
                amt - releaseNow,
                block.timestamp + (30 * 1440 * 60),
                2500,
                30 * 1440 * 60,
                2500,
                "LOCK"
            );
        }
    }

    receive() external payable {}
    
}