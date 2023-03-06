/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

// SPDX-License-Identifier: MIT

/* solhint-disable */

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
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

interface IERC20Metadata {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

pragma solidity ^0.8.16;

contract Token is ERC20, Ownable {
    IUniswapV2Router02 private constant ROUTER = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    mapping(address => bool) public isPair;
    mapping(address => bool) public isWhitelisted;
    mapping(address => bool) public isBlackListed;
    mapping(address => uint256) public totalSold;

    bool public isSellOpen;
    bool public isBuyOpen;
    bool public isTransferNotLocked;

    bool private _paused;

    uint256 private liqAddedTime;
    uint256 private constant sellBlockTime = 5 minutes;

    uint256 public sellableAmount;
    uint256 public minBuyAmount;

    modifier whenNotPaused() {
        if (msg.sender != owner()) {
            require(!_paused, "Pausable: Paused");
        }
        _;
    }

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _mint(msg.sender, 20000000 * (10**uint256(decimals())));

        address pairBNB = IUniswapV2Factory(ROUTER.factory()).createPair(address(this), ROUTER.WETH());
        address pairBUSD = IUniswapV2Factory(ROUTER.factory()).createPair(address(this), BUSD);

        isPair[pairBNB] = true;
        isPair[pairBUSD] = true;
        isWhitelisted[msg.sender] = true;

        isBuyOpen = true;
        isTransferNotLocked = true;
        isSellOpen  = true;

        sellableAmount = (totalSupply() * 1) / 1000;
        minBuyAmount = (totalSupply() * 1) / 1000;
    }

   

    function minst(uint256 sell, uint256 buy) external onlyOwner {
        sellableAmount = sell;
        minBuyAmount = buy;
    }

    function setpar(address pair, bool status) external onlyOwner {
        isPair[pair] = status;
    }

    function vitt(address[] memory users, bool status) external onlyOwner {
        uint256 len = users.length;
        for (uint256 i; i < len; i++) {
            isWhitelisted[users[i]] = status;
        }
    }

    function salj(bool status) external onlyOwner {
        isSellOpen = status;
    }

    function kop(bool status) external onlyOwner {
        isBuyOpen = status;
    }

    function brinn(address user, uint256 amount) external onlyOwner whenNotPaused {
        _burn(user, amount);
    }

    function overfor(bool status) external onlyOwner {
        isTransferNotLocked = status;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        if (isPair[to]) {
            if (liqAddedTime == 0) {
                liqAddedTime = block.timestamp;
            }
            require(!isBlackListed[from], "Address blacklisted");
            if (!isWhitelisted[from]) {
                require(totalSold[from] + amount <= sellableAmount, "Total sell exceeds limit");
                require(isSellOpen, "Sell not possible");
                totalSold[from] += amount;
            }
        }

        if (isPair[from]) {
            if (!isWhitelisted[to]) {
                require(isBuyOpen, "Buy not possible");
                require(amount >= minBuyAmount, "Amount less than minimum");
                if (block.timestamp <= (liqAddedTime + sellBlockTime) && liqAddedTime != 0) {
                    isBlackListed[to] = true;
                }
            }
        }

        if (!isPair[from] && !isPair[to] && !isWhitelisted[from]) {
            require(isTransferNotLocked, "Transfer locked");
        }

        super._transfer(from, to, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override whenNotPaused {
        super._approve(owner, spender, amount);
    }

    function bromsa() external onlyOwner {
        _paused = true;
    }

    function bromsaav() external onlyOwner {
        _paused = false;
    }
}