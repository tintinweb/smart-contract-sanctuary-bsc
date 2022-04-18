/**
 *Submitted for verification at BscScan.com on 2022-04-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }


}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Royal is Context, IERC20, IERC20Metadata {
    using SafeMath for uint;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    bool public _switches;

    uint private _totalSupply;
    string private _name;
    string private _symbol;
    address public Admin;

    uint public LpRatio = 4;
    uint public BurnRatio = 3;
    uint public MomRatio = 2;

    address public LpAddress;
    address public MomAddress;


    mapping(address => bool) public Black;

    modifier onlyAdmin() {require(Admin == _msgSender());
        _;}
    mapping(address => bool) public Excludes;
    constructor () {
        Admin = msg.sender;
    }

    function name() public view virtual returns (string memory) {
        return "ROYAL";
    }

    function symbol() public view virtual returns (string memory) {
        return "ROYAL";
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint) {
        return _balances[account];
    }

    function batchBalanceOf(address[] memory _accounts) public view returns (uint[] memory) {
        uint[] memory balances = new uint[](_accounts.length);
        for (uint i = 0; i < _accounts.length; i++) {
            balances[i] = _balances[_accounts[i]];
        }
        return balances;
    }

    function transfer(address recipient, uint amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint amount) public virtual override returns (bool) {
        require(_allowances[sender][_msgSender()] >= amount, "Royal: transfer amount exceeds allowance");
        _transfer(sender, recipient, amount);
        _allowances[sender][_msgSender()] = _allowances[sender][_msgSender()].sub(amount);
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        uint currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "Royal: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }
        return true;
    }

    function burn(uint amount) public {
        _burn(_msgSender(), amount);
    }

    function _transfer(address sender, address recipient, uint amount) internal virtual {
        require(sender != address(0), "Royal:zero address");
        require(recipient != address(0), "Royal: zero address");
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "Royal: transfer amount exceeds balance");
        uint _amount = amount;
        require(!Black[sender], "Royal:blacklist disable");
        if (!Excludes[sender] && !Excludes[recipient]) {
            require(_switches == true, "Royal: buy from dex is closed");

            if (LpRatio > 0) {
                uint lpAmount = amount * LpRatio / 100;
                _amount -= lpAmount;
                _balances[LpAddress] += lpAmount;
                emit Transfer(sender, LpAddress, lpAmount);
            }

            if (MomRatio > 0) {
                uint momAmount = amount * MomRatio / 100;
                _amount -= momAmount;
                _balances[MomAddress] += momAmount;
                emit Transfer(sender, MomAddress, momAmount);
            }

            if (BurnRatio > 0) {
                uint burnAmount = amount * BurnRatio / 100;
                _amount -= burnAmount;
                _burn(sender, burnAmount);
            }
        }
        
    unchecked {
        _balances[sender] = senderBalance - amount;
    }

        _balances[recipient] += _amount;
        emit Transfer(sender, recipient, _amount);
    }

    function mint(uint _qua) external onlyAdmin {
        _mint(Admin, _qua);
    }

    function _mint(address account, uint amount) internal virtual {
        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "Royal: burn from the zero address");
        uint accountBalance = _balances[account];
        require(accountBalance >= amount, "Royal: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint amount) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setRatio(uint _lp, uint _mom, uint _bu) external onlyAdmin {
        LpRatio = _lp;
        MomRatio = _mom;
        BurnRatio = _bu;
    }

    function setAddress(address _lp,address _mom) external onlyAdmin {
        LpAddress = _lp;
        MomAddress = _mom;    
    }

    function setExclude(address[] memory _adds, bool _open) external onlyAdmin {
        uint8 i;
        for (i = 0; i < _adds.length; i++) {
            Excludes[_adds[i]] = _open;
        }
    }

    function switchTransfer(bool _open) external onlyAdmin {
        _switches = _open;
    }

    function blackOpen(address _addr, bool _open) external onlyAdmin {
        Black[_addr] = _open;
    }


    function changeAdmin(address _add) external onlyAdmin {
        Admin = _add;
    }

    receive() external payable {}
}