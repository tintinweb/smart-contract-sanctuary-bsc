/**
 *Submitted for verification at BscScan.com on 2022-08-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    function transferFrom( address from, address to, uint256 amount ) external returns (bool);
}

contract SuperCommunityToken is Ownable, IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    string private m_name = "Super Community Token";
    string private m_symbol = "SCT";
    uint8 private m_decimals = 9;
    uint256 private m_totalSupply = 1000000;
    address private m_dead = 0x000000000000000000000000000000000000dEaD;
    address private m_devAddress = 0x9Fb2D58757d4A970ffA0d3402f960CeEE37C209B;
    uint256 private m_burnRatio = 2;
    uint256 private m_taxRatio = 1;
    constructor() {
        require(m_devAddress != address(0), "Msg: charity from the zero address");
        uint256 _total = m_totalSupply * (10**uint256(decimals()));
        address sender = _msgSender();
        m_totalSupply += _total;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[sender] += _total;
        }
        emit Transfer(address(0), sender, _total);
    }
    function name() public view returns (string memory) {
        return m_name;
    }
    function symbol() public view returns (string memory) {
        return m_symbol;
    }
    function decimals() public view returns (uint8) {
        return m_decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return m_totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom( address from,  address to,  uint256 amount ) public override returns (bool) {
        _spendAllowance(from, _msgSender(), amount);
        _transfer(from, to, amount);
        return true;
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) private {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
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
        require(amount > 0, "ERC20: transfer amount must be greater than zero");
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        uint256 trueAmount = amount;
        uint256 burnAmount = 0;
        uint256 cAmount = 0;
        bool isMng = from == m_devAddress ||  to == m_devAddress || from == owner() || to == owner();
        if(!isMng){
            burnAmount = amount * m_burnRatio / (10**2);
            cAmount = amount*m_taxRatio/(10**2);
            trueAmount = amount-(burnAmount+cAmount);
        }
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += trueAmount;
            if(burnAmount > 0) _balances[m_dead] += burnAmount;
            if(cAmount > 0) _balances[m_devAddress] += cAmount;
        }
        emit Transfer(from, to, trueAmount);
    }
}