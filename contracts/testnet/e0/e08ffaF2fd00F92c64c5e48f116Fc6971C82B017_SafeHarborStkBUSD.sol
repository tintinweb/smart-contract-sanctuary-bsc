/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;


// Strings

library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}


// Context

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _msgValue() internal view virtual returns (uint256) {
        return msg.value;
    }
}


// Ownable

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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


// ERC20

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
    
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string private _name;
    string private _symbol;
    uint256 private _totalSupply;
    uint8 private _decimals;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
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
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);
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
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
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


// SafeHarbor Staking Contract for BUSD

contract SafeHarborStkBUSD is ERC20, Ownable {

    string constant private _name = "SafeHarbor staked BUSD";
    string constant private _symbol = "haBUSD";
    uint8 constant  private _decimals = 18;

    uint256 constant private _totalSupply = 800000000000000000000000000; // 4850999388629409465655005581;

    address private _stableTokenAddr = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
   
    uint256 private _minStakeAmount = 1e18; // 1
    uint256 private _minUnstakeAmount = 1e18; // 1
    uint256 private _stakingFee = 1e17; // 0.1
    uint256 private _unstakingFee = 1e17; // 0.1
    
    uint private _apy = 1700; // 17%

    address[] private _depositaries;
    mapping(address => uint) private _lastRewardTime;

    struct PendingStk {
        address from;
        uint256 amount;
    }

    PendingStk[] private _pendingStake;
    PendingStk[] private _pendingUnstake;


    constructor() ERC20(_name, _symbol, _decimals) {
		_mint(address(this), _totalSupply);
    }


    function depositaries() public view virtual onlyOwner returns (address[] memory) {
        return _depositaries;
    }

    function pendingStake() public view virtual onlyOwner returns (PendingStk[] memory) {
        return _pendingStake;
    }    

    function pendingUnstake() public view virtual onlyOwner returns (PendingStk[] memory) {
        return _pendingUnstake;
    }    

    function lastRewardTime(address adr) public view virtual onlyOwner returns (uint) {
        return _lastRewardTime[adr];
    }

    function stableTokenAddrSet(address stableTokenAddr) public virtual onlyOwner {
       _stableTokenAddr = stableTokenAddr;
    }

    function stableTokenAddrGet() public view virtual returns (address) {
        return _stableTokenAddr;
    }

    function stakingFee(uint256 fee) public virtual onlyOwner {
        require(fee < _minStakeAmount, "StakingFee must be less than minStakeAmount");
       _stakingFee = fee;
    }

    function stakingFee() public view virtual returns (uint256) {
        return _stakingFee;
    }

    function unstakingFee(uint256 fee) public virtual onlyOwner {
        require(fee < _minUnstakeAmount, "UnstakingFee must be less than minUnstakeAmount");
       _unstakingFee = fee;
    }

    function unstakingFee() public view virtual returns (uint256) {
        return _unstakingFee;
    }

    function minStakeAmount(uint256 amount) public virtual onlyOwner {
        require(amount > _stakingFee, "MinStakeAmount must be greater than stakingFee");
       _minStakeAmount = amount;
    }

    function minStakeAmount() public view virtual returns (uint256) {
        return _minStakeAmount;
    }

    function minUnstakeAmount(uint256 amount) public virtual onlyOwner {
        require(amount > _unstakingFee, "MinUnstakeAmount must be greater than unstakingFee");
       _minUnstakeAmount = amount;
    }

    function minUnstakeAmount() public view virtual returns (uint256) {
        return _minUnstakeAmount;
    }

    function apy(uint value) public virtual onlyOwner {
       _apy = value;
    }

    function apy() public view virtual returns (uint) {
        return _apy;
    }

    function stake(uint256 amount) public virtual  {

        _stake(_msgSender(), amount);
    }

    function stake(address depositary, uint256 amount) public virtual onlyOwner {

        _stake(depositary, amount);
    }

    function finalizeStake(address depositary) public virtual onlyOwner {

        _finalizeStake(depositary);
    }

    function unstake(uint256 amount) public virtual  {

        _unstake(_msgSender(), amount);
    }

    function unstake(address depositary, uint256 amount) public virtual onlyOwner {

        _unstake(depositary, amount);
    }

    function finalizeUnstake(address depositary) public virtual onlyOwner {

        _finalizeUnstake(depositary);
    }

    function sendRewards() public virtual onlyOwner {

        _sendRewards();
    }

    function _stake(address depositary, uint256 amount) internal virtual  {

        require(amount >= _minStakeAmount, "Too small staking amount");

        for (uint i=0; i < _pendingStake.length; i++)
            if (_pendingStake[i].from == depositary)
                revert("Previous staking operation is still being processed. Please Wait.");
   
        IERC20(_stableTokenAddr).transferFrom(depositary, address(this), amount);

        _pendingStake.push(PendingStk(depositary, amount));
        emit PendingStake(depositary, amount);
    }

    function _finalizeStake(address depositary) internal virtual  {

        uint256 amount = 0;
        uint idx;

        for (uint i=0; i < _pendingStake.length; i++)
            if (_pendingStake[i].from == depositary) {
                amount = _pendingStake[i].amount;
                idx = i;
            }
                
        if (amount == 0)
            revert("Pending staking operation non found.");
   
        _transfer(address(this), depositary, amount - _stakingFee);

        _removeByIndex(_pendingStake, idx);

        if (_lastRewardTime[depositary] <= 0) {           
            _depositaries.push(depositary);
        }

        _lastRewardTime[depositary] = block.timestamp;

        emit Staked(depositary, amount);
    }

    function _unstake(address depositary, uint256 amount) internal virtual  {

        require(amount >= _minUnstakeAmount, "Too small unstaking amount");

        for (uint i=0; i < _pendingUnstake.length; i++)
            if (_pendingUnstake[i].from == depositary)
                revert("Previous unstaking operation is still being processed. Please Wait.");

        _transfer(depositary, address(this), amount);

        _pendingUnstake.push(PendingStk(depositary, amount));
        emit PendingUnstake(depositary, amount);
    }
   
    function _finalizeUnstake(address depositary) internal virtual  {

        uint256 amount = 0;
        uint idx = 0;
        
        for (uint i=0; i < _pendingUnstake.length; i++)
            if (_pendingUnstake[i].from == depositary) {
                amount = _pendingUnstake[i].amount;
                idx = i;
            }

        if (amount == 0)
            revert("Pending unstaking operation non found.");
        
        IERC20(_stableTokenAddr).transfer(depositary, amount - _unstakingFee);

        _removeByIndex(_pendingUnstake, idx);

        if (balanceOf(depositary) <= 0) {
            for (uint i = 0; i < _depositaries.length; i++) {
                if (_depositaries[i] == depositary) {
                    _lastRewardTime[depositary] = 0;
                    _removeByIndex(_depositaries, i);
                    break;
                }
            }
        }

        emit Unstaked(depositary, amount);
    }
    
    function _sendRewards() internal virtual {

        uint currentTime = block.timestamp;
       
        for (uint i = 0; i < _depositaries.length; i++) {

            address depositary = _depositaries[i];

            uint timeDiff = currentTime - _lastRewardTime[depositary];
            _lastRewardTime[depositary] = currentTime;

            uint256 balance = balanceOf(depositary);
            if (balance <= 0) continue;
            if (_apy <= 0) continue;

            uint256 yearReward = balance * _apy / 10000;
            uint256 secondReward = yearReward / 365 days;	
            uint256 reward = secondReward * timeDiff;

            if (reward > 0) {
                _transfer(address(this), depositary, reward);
                emit Reward(depositary, reward);
            }
        }
    }

    function _removeByIndex(address[] storage array, uint i) private {
        while (i < array.length - 1) {
            array[i] = array[i + 1];
            i++;
        }
        array.pop();
    }

    function _removeByIndex(PendingStk[] storage array, uint i) private {
        while (i < array.length - 1) {
            array[i] = array[i + 1];
            i++;
        }
        array.pop();
    }
   

    event Reward(address depositary, uint256 amount);
    event Staked(address depositary, uint256 amount);
    event Unstaked(address depositary, uint256 amount);
    event PendingStake(address depositary, uint256 amount);
    event PendingUnstake(address depositary, uint256 amount);
}