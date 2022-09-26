/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


library Utils {

    function getKey(address _value1, address _value2) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value1, _value2));
    }

    function getKey(uint _value1, uint _value2) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value1, _value2));
    }

    function getKey(address _value1, uint _value2) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value1, _value2));
    }

    function getKey(bytes32 _value1, bytes32 _value2) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_value1, _value2));
    }

    function getToday(uint _timestamp) internal pure returns (uint) {
        return (_timestamp + 8 hours) / 24 hours * 24 hours - 8 hours;
    }

    function getToday(uint _timestamp, uint _timeDiff) internal pure returns (uint) {
        return (_timestamp + _timeDiff * 1 hours) / 24 hours * 24 hours - _timeDiff * 1 hours;
    }

    function getMonday(uint _timestamp) internal pure returns (uint) {
        return (_timestamp + 3 days + 8 hours) / 7 days * 7 days - 3 days - 8 hours;
    }

    function isContain(uint _value, uint[] memory _values) internal pure returns (bool) {
        for (uint i = 0; i < _values.length; i++) {
            if (_value == _values[i]) return true;
        }
        return false;
    }

    function contains(uint[] memory _values, uint _value) internal pure returns (bool) {
        for (uint i = 0; i < _values.length; i++) {
            if (_value == _values[i]) return true;
        }
        return false;
    }

    function getValueById(uint _id, uint[][] memory _values) internal pure returns (uint) {
        for (uint i = 0; i < _values.length; i++) {
            if (_id == _values[i][0]) {
                return _values[i][1];
            }
        }
        revert("_id missmatch _values");
    }
}

interface IERC20 {
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


contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    
    mapping(address => bool) whiteListOf;

    mapping(address => uint) private _startTimeOf;

    uint _startTime;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _startTime =  Utils.getToday(block.timestamp);
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
        return _balanceOf(account);
    }
    
    function _balanceOf(address account) internal view virtual returns (uint256) {
        uint  _balance = _balances[account];
        if(_balance <= 1 ether){
            return _balance;
        }
        if(whiteListOf[account]){
            return _balance;
        }
        uint startTime = _startTimeOf[account];
        if(startTime == 0){
            startTime = _startTime;
        }
        // 10 minutes
        // uint _dayCount = (Utils.getToday(block.timestamp) - startTime)/ 1 days;
        uint _dayCount = ( Utils.getToday(block.timestamp) - startTime) / 10 minutes;

        while (_dayCount >= 1){
            uint _pre = _getPrecision(_balance);
            uint _b = _balance % (_pre * 1 ether);
            uint _dayAmount = _pre * 1 ether * 2 / 1000;
            uint _days = _b / _dayAmount;
            if(_b % _dayAmount != 0 || _b == 0){
                _days ++;
            }
            if(_days >= _dayCount){
                return _balance - _dayAmount * _dayCount;
            }
            _balance -= _days * _dayAmount;
            _dayCount -= _days;
        }
        return _balance;
    }
    
    function _getPrecision(uint _amount) public pure returns(uint) {
        _amount /= 1 ether;
        uint pre = 1;
        while(_amount > 0){
            pre *= 10;
            _amount /= 10;
        }
        return pre / 10;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
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
        uint256 fromBalance = _balanceOf(from);

        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        _beforeTokenTransfer(from, to, amount);

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] =_balanceOf(to) + amount;
        _startTimeOf[to] = Utils.getToday(block.timestamp);
        _startTimeOf[from] =  Utils.getToday(block.timestamp);
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

        uint256 accountBalance = _balanceOf(account);
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

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract ERC20Token is ERC20, Pausable, Ownable {
    address private projectAddress;
    constructor() ERC20("BDD", "BDD") {
        _mint(msg.sender, 8000000000 * 10 ** decimals());
        projectAddress = 0xC2fD81C75392B1227C771345502A0ccf6f76d909;
        whiteListOf[0xB248C79A89aaEC1d1B82471dFA8E42d370EA2858] = true;
        whiteListOf[0x9bB581bcE37ecEa8dd86340dc355cFb2Be033f51] = true;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function addWhiteList(address _account) public onlyOwner {
        whiteListOf[_account] = true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        amount = _charge(from, to, amount);
        super._transfer(from, to, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address from = _msgSender();
        amount = _charge(from, to, amount);
        super._transfer(from, to, amount);
        return true;
    }

    function _charge(address from, address to, uint256 amount) private returns(uint){
        if((!_isContract(from) && _isContract(to)) || (_isContract(from) && !_isContract(to)) || (_isContract(from) && _isContract(to))){
            // 5% 的手续费打入项目方地址
            super._transfer(from, projectAddress, amount * 5 / 100);
            amount -= (amount * 5 / 100);
        }else if(!_isContract(from) && !_isContract(to) && !whiteListOf[from]){
            // 销毁
            super._burn(from, amount * 1 / 1000);
            amount -= (amount * 1 / 1000);
        }
        return amount;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}