/**
 *Submitted for verification at BscScan.com on 2022-02-19
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.11;

/** From the openzeppelin framework -> https://github.com/OpenZeppelin/openzeppelin-contracts */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/** From the openzeppelin framework -> https://github.com/OpenZeppelin/openzeppelin-contracts */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }

    function unlock() public virtual {
        require(
            _previousOwner == msg.sender,
            "You don't have permission to unlock"
        );
        require(block.timestamp > _lockTime, "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

/** From the openzeppelin framework -> https://github.com/OpenZeppelin/openzeppelin-contracts */
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

/** From the openzeppelin framework -> https://github.com/OpenZeppelin/openzeppelin-contracts */
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
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

/** From the openzeppelin framework -> https://github.com/OpenZeppelin/openzeppelin-contracts */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/** Implement the IERC20 interface */
contract ERC20 is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
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
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
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
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
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

/** Main */
contract BraveAdventure is ERC20 {
    using SafeMath for uint256;
    using Address for address;

    string constant m_name = "Brave Adventure";
    string constant m_symbol = "BAT";
    uint8 private m_decimals = 9;
    uint256 private m_totalSupply = 100000000000;
    uint256 public m_maxTxAmount;
    uint256 public firstDayMaxTxAmount;
    uint256 public _maxTxBurnFee = 50;
    uint256 public _maxTxCharityFee = 50;
    uint256 public _burnFee = 10;
    uint256 public _charityFee = 20;
    address public m_deadWallet = 0x000000000000000000000000000000000000dEaD;
    address m_charityWallet;

    mapping(address => bool) _isBlacklisted;
    mapping(address => bool) _isExcludedFromFees;

    uint256 private delay = 10 seconds;
    uint256 private tradingEnabledTimestamp;
    bool public swapEnabled = true;

    constructor(address _charity, uint256 _timestamp) ERC20(m_name, m_symbol) {
        require(_charity != address(0), "Msg: charity from the zero address");
        m_charityWallet = _charity;
        tradingEnabledTimestamp = _timestamp;
        m_totalSupply = m_totalSupply * (10**uint256(m_decimals));
        m_maxTxAmount = m_totalSupply.mul(20).div(10**3);
        firstDayMaxTxAmount = m_totalSupply.mul(10).div(10**3);
        _isExcludedFromFees[_msgSender()] = true;
        _isExcludedFromFees[m_charityWallet] = true;
        uint256 burnAmount = m_totalSupply.mul(30).div(10**2);
        uint256 trueAmount = m_totalSupply.sub(burnAmount);
        _mint(m_deadWallet, burnAmount);
        _mint(_msgSender(), trueAmount);
    }

    function decimals() public view override returns (uint8) {
        return m_decimals;
    }

    function setMaxTxBurnFee(uint256 fee) external onlyOwner {
        _maxTxBurnFee = fee;
    }

    function setMaxTxCharityFee(uint256 fee) external onlyOwner {
        _maxTxCharityFee = fee;
    }

    function setBurnFee(uint256 fee) external onlyOwner {
        _burnFee = fee;
    }

    function setCharityFee(uint256 fee) external onlyOwner {
        _charityFee = fee;
    }

    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
    }

    function setMaxTxAmount(uint256 amount) external onlyOwner {
        m_maxTxAmount = amount;
    }

    function setCharityWallet(address account) external onlyOwner {
        address _privateCharity = m_charityWallet;
        m_charityWallet = account;
        _isExcludedFromFees[m_charityWallet] = true;
        _isExcludedFromFees[_privateCharity] = false;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
        require(
            _isExcludedFromFees[account] != excluded,
            "Account is already the value of 'excluded'"
        );
        _isExcludedFromFees[account] = excluded;
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function blacklistAddress(address account, bool value) public onlyOwner {
        require(
            _isBlacklisted[account] != value,
            "Account is already the value of 'value'"
        );
        _isBlacklisted[account] = value;
    }

    function isBlacklistAddress(address account) public view returns (bool) {
        return _isBlacklisted[account];
    }

    function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlacklisted[from] == false, "You are banned");
        require(_isBlacklisted[to] == false, "The recipient is banned");
        require(swapEnabled, "Trading is suspended!");
        bool isMng = _isExcludedFromFees[from] || _isExcludedFromFees[to];
        if (isMng) {
            super._transfer(from, to, amount);
            return;
        }
        bool tradingIsEnabled = getTradingIsEnabled();
        if (!tradingIsEnabled) {
            require(
                isMng,
                "This account cannot send tokens until trading is enabled"
            );
        }      
        uint256 _maxTxAmount = m_maxTxAmount;
        if (from != owner() && to != owner()) {
            if (block.timestamp <= tradingEnabledTimestamp + 1 days) {
                _maxTxAmount = firstDayMaxTxAmount;
                require(
                    amount <= _maxTxAmount,
                    "Transfer amount exceeds the maxTxAmount."
                );
            }
        }
        if (
            tradingIsEnabled &&
            !_isExcludedFromFees[to] &&
            block.timestamp <= tradingEnabledTimestamp + delay
        ) {
            _isBlacklisted[to] = true;
        }
        if (!_isExcludedFromFees[_msgSender()]) {
            uint256 BurnAmount = amount.mul(_burnFee).div(10**3);
            uint256 charityAmount = amount.mul(_charityFee).div(10**3);
            if (amount > _maxTxAmount) {
                BurnAmount = amount.mul(_maxTxBurnFee).div(10**3);
                charityAmount = amount.mul(_maxTxCharityFee).div(10**3);
            }
            uint256 trueAmount = amount.sub(BurnAmount).sub(charityAmount);
            if (BurnAmount > 0) super._transfer(from, m_deadWallet, BurnAmount);
            if (charityAmount > 0)
                super._transfer(from, m_charityWallet, charityAmount);
            super._transfer(from, to, trueAmount);
            return;
        }
        super._transfer(from, to, amount);
    }
}