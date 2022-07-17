/**
 *Submitted for verification at BscScan.com on 2022-07-16
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

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
    address private _pendingOwner;

    event OwnershipTransferRequested(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferAccepted(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "TWC: caller is not the owner");
        _;
    }

    modifier onlyPendingOwner() {
        require(pendingOwner() == _msgSender(), "TWC: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "TWC: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        _pendingOwner = newOwner;

        emit OwnershipTransferRequested(_owner, _pendingOwner);
    }

    function claimOwnership() public onlyPendingOwner {
        _claimOwnership();
    }

    function _claimOwnership() internal {
        emit OwnershipTransferAccepted(_owner, _pendingOwner);

        _owner = _pendingOwner;
        _pendingOwner = address(0);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

abstract contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    uint8 private constant _decimals = 2;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account_) public view override returns (uint256) {
        return _balances[account_];
    }

    function allowance(address owner_, address spender_) public view override returns (uint256) {
        return _allowances[owner_][spender_];
    }

    function approve(address spender_, uint256 amount_) public override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender_, amount_);

        return true;
    }

    function increaseAllowance(address spender_, uint256 addedValue_) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender_, _allowances[owner][spender_] + addedValue_);

        return true;
    }

    function decreaseAllowance(address spender_, uint256 subtractedValue_) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender_];
        require(currentAllowance >= subtractedValue_, "TWC: decreased allowance below zero");
        unchecked {
            _approve(owner, spender_, currentAllowance - subtractedValue_);
        }

        return true;
    }

    function _transfer(address from_, address to_, uint256 amount_) internal {
        require(from_ != address(0), "TWC: transfer from the zero address");
        require(to_ != address(0), "TWC: transfer to the zero address");

        uint256 fromBalance = _balances[from_];
        require(fromBalance >= amount_, "TWC: transfer amount exceeds balance");
        unchecked {
            _balances[from_] = fromBalance - amount_;
        }
        _balances[to_] += amount_;

        emit Transfer(from_, to_, amount_);
    }

    function _mint(address account_, uint256 amount_) virtual internal {
        require(account_ != address(0), "TWC: mint to the zero address");

        _totalSupply += amount_;
        _balances[account_] += amount_;
        emit Transfer(address(0), account_, amount_);
    }

    function _burn(address account_, uint256 amount_) virtual internal {
        require(account_ != address(0), "TWC: burn from the zero address");

        uint256 accountBalance = _balances[account_];
        require(accountBalance >= amount_, "TWC: burn amount exceeds balance");
        unchecked {
            _balances[account_] = accountBalance - amount_;
        }
        _totalSupply -= amount_;

        emit Transfer(account_, address(0), amount_);
    }

    function _approve(address owner_, address spender_, uint256 amount_) internal {
        require(owner_ != address(0), "TWC: approve from the zero address");
        require(spender_ != address(0), "TWC: approve to the zero address");

        _allowances[owner_][spender_] = amount_;
        emit Approval(owner_, spender_, amount_);
    }

    function _spendAllowance(address owner_, address spender_, uint256 amount_) internal {
        uint256 currentAllowance = allowance(owner_, spender_);

        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount_, "TWC: insufficient allowance");
            unchecked {
                _approve(owner_, spender_, currentAllowance - amount_);
            }
        }
    }
}

contract TWCoin is Context, Ownable, ERC20 {
    // Additional variables for use if transaction fees ever become necessary
    uint256 private _feePointRate = 0;
    uint8 private _feeDecimals = 8; // 0.01% when feePointRate is 1

    uint256 private _feeMaximum = 0;

    event FeeMaximumAmountUpdated(uint256 indexed feeMaximum_);
    event FeePointRateUpdated(uint256 indexed feePointRate_);

    constructor (string memory name_, string memory symbol_, uint256 initialSupply_) ERC20 (name_, symbol_) {
        uint256 initialSupply = initialSupply_ * 10 ** decimals();

        _mint(_msgSender(), initialSupply);
    }

    function feePointRate () public view returns (uint256) {
        return _feePointRate;
    }

    function feeDecimals () public view returns (uint256) {
        return _feeDecimals;
    }

    function feeMaximum () public view returns (uint256) {
        return _feeMaximum;
    }

    function setFeeMaximum (uint256 feeMaximum_) public onlyOwner {
        _feeMaximum = feeMaximum_;

        emit FeeMaximumAmountUpdated(_feeMaximum);
    }

    function setFeePointRate (uint8 feePointRate_) public onlyOwner {
        _feePointRate = feePointRate_;

        emit FeePointRateUpdated(feePointRate_);
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function transfer(address to_, uint256 amount_) public override returns (bool) {
        address sender = _msgSender();

        uint256 fee = amount_ * _feePointRate / (10 ** _feeDecimals);
        if (fee > _feeMaximum) {
            fee = _feeMaximum;
        }

        uint256 transferAmount = amount_ - fee;

        _transfer(sender, owner(), fee);
        _transfer(sender, to_, transferAmount);

        return true;
    }

    function transferFrom(address from_, address to_, uint256 amount_) public override returns (bool) {
        address spender = _msgSender();

        uint256 fee = amount_ * _feePointRate / (10 ** _feeDecimals);
        if (fee > _feeMaximum) {
            fee = _feeMaximum;
        }

        uint256 transferAmount = amount_ - fee;

        _spendAllowance(from_, spender, transferAmount);
        _transfer(from_, owner(), fee);
        _transfer(from_, to_, transferAmount);

        return true;
    }

    function reClaimCoin (address to_) public onlyOwner {
        require(to_ != address(0), "TWC: claim to the zero address");

        payable(to_).transfer(address(this).balance);
    }

    function reClaimToken (address token_, address to_) public onlyOwner {
        require(to_ != address(0), "TWC: claim to the zero address");
        require(token_ != address(0), "TWC: claim to the zero address");
        require(token_ != address(this), "TWC: self withdraw");

        uint256 tokenBalance = IERC20(token_).balanceOf(address(this));
        IERC20(token_).transfer(to_, tokenBalance);
    }
}