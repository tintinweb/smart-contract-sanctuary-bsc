/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
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

interface LPStaking {

    function getReward(address target) external;

    function deposit(address target, uint256 amount) external;
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

contract ERC20 is Context, IERC20, IERC20Metadata, Ownable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    
    address public lpStaking;

    address public settleAddress;

    mapping(address => SwapPairConfig) public spConfig;

    struct SwapPairConfig {
        uint64 _fInNumerator;
        uint64 _fOutNumerator;
        uint64 _fDenominator;
        bool isEnable;
    }

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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        // require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
        // leave 1/1000
        amount = amount - amount / 1000;
        _balances[sender] = senderBalance - amount;
    }
        SwapPairConfig memory sConfig = spConfig[sender];
        SwapPairConfig memory rConfig = spConfig[recipient];
        // swap pair disable, common transfer
        if (!sConfig.isEnable && !rConfig.isEnable) {
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            _afterTokenTransfer(sender, recipient, amount);
            return;
        }
        uint256 fee;
        address toAccount;
        // in 
        if (sConfig.isEnable) {
            if (sConfig._fInNumerator > 0 && sConfig._fDenominator > 0) {
                fee += amount * 10 ** decimals() * sConfig._fInNumerator / sConfig._fDenominator / 10 ** decimals();
                toAccount = recipient;
                if (lpStaking != address(0)) {
                    _getReward(recipient);
                }
            }
        }
        // out
        if (rConfig.isEnable) {
            if (rConfig._fOutNumerator > 0 && rConfig._fDenominator > 0) {
                fee += amount * 10 ** decimals() * rConfig._fOutNumerator / rConfig._fDenominator / 10 ** decimals();
                toAccount = sender;
            }
        }
        // fee
        if (fee != 0) {
            uint256 halfFee = fee / 2;
            if (lpStaking != address(0)) {
                // half fee deposit to lp pool
                _deposit(toAccount, halfFee);
            } else {
                // half fee to a address
                _balances[settleAddress] += halfFee;
                emit Transfer(toAccount, settleAddress, halfFee);
            }
            // another fee to black hole
            _balances[address(0)] += fee - halfFee;
            emit Transfer(toAccount, address(0), fee - halfFee);
        }
        _balances[recipient] += amount - fee;
        emit Transfer(sender, recipient, amount - fee);
        _afterTokenTransfer(sender, recipient, amount);
    }

    function _deposit(address account, uint256 amount) internal virtual {
        _balances[lpStaking] += amount;
        emit Transfer(account, lpStaking, amount);
        LPStaking(lpStaking).deposit(account, amount);
    }

    function _getReward(address account) internal virtual {
        LPStaking(lpStaking).getReward(account);
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

contract RealMan is ERC20 {

    event SetSwapConfig(address indexed swapPair, uint64 inNumerator, uint64 outNumerator, uint64 denominator, bool isEnable);

    constructor() ERC20("Real Man", "RM") {
        _mint(0x6f450bA44EEE9e23D7311c177a783F6a449f5958, 9999 * (10 ** uint256(decimals())));
    }

    function setLpStaking(address staking) public onlyOwner returns (bool) {
        lpStaking = staking;
        return true;
    }

    function setSettleAddress(address addr) public onlyOwner returns (bool) {
        settleAddress = addr;
        return true;
    }

    function setSwapConfig(address swapPair, uint64 inNumerator, uint64 outNumerator, uint64 denominator, bool isEnable) public onlyOwner returns (bool) {
        spConfig[swapPair]._fInNumerator = inNumerator;
        spConfig[swapPair]._fOutNumerator = outNumerator;
        spConfig[swapPair]._fDenominator = denominator;
        spConfig[swapPair].isEnable = isEnable;
        emit SetSwapConfig(swapPair, inNumerator, outNumerator, denominator, isEnable);
        return true;
    }

}