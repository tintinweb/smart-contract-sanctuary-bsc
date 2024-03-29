/**
 *Submitted for verification at BscScan.com on 2022-04-08
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

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

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }

    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
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


contract LINE is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint private _totalSupply;
    string private _name;
    string private _symbol;
    address public Admin;

    uint public ErectRatio = 1;   //生态建设
    uint public UnionRatio = 1;   //联创
    uint public LpRatio = 3;      //LP分配
    uint public BurnRatio = 2;    //销毁
    uint public ChildRatio = 2;   //子币生态

    address public ErectAddress = 0x7E3fd1A88d090d814Cce5057936FD396dDB22222;  //生态建设
    address public UnionAddress = 0x7E3fd1A88d090d814Cce5057936FD396dDB22222;  //联创
    address public LpAddress    = 0x7E3fd1A88d090d814Cce5057936FD396dDB22222;  //LP分配
    address public ChildAddress = 0x7E3fd1A88d090d814Cce5057936FD396dDB22222;  //子币生态

    modifier onlyAdmin() {require(Admin == _msgSender());
        _;}
    mapping(address => bool) public Excludes;
    constructor () {
        Admin = _msgSender();
        _mint(Admin, 99999 * 1e18);
    }

    function name() public view virtual override returns (string memory) {
        return "Coin Aine";
    }

    function symbol() public view virtual override returns (string memory) {
        return "CA";
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint) {
        return _balances[account];
    }

    function batchBalanceOf(address[] memory _accounts) public view returns (uint[] memory) {
        uint[] memory balances = new uint[](_accounts.length);
        for (uint i = 0; i < _accounts.length; i++) {
            balances[i] = _balances[_accounts[i]];
        }
        return balances;
    }

    function transfer(address recipient, uint amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "LINE: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
        uint currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "LINE: decreased allowance below zero");
    unchecked {
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
    }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint amount
    ) internal virtual {
        require(sender != address(0), "LINE: transfer from the zero address");
        require(recipient != address(0), "LINE: transfer to the zero address");
        uint senderBalance = _balances[sender];
        require(senderBalance >= amount, "LINE: transfer amount exceeds balance");
        uint _amount = amount;
        if (!Excludes[sender] && !Excludes[recipient]) {
            //LP分配
            if (LpRatio > 0) {
                uint lpAmount = amount * LpRatio / 100;
                _amount -= lpAmount;
                _balances[address(LpAddress)] += lpAmount;
                emit Transfer(sender, address(LpAddress), lpAmount);
            }
            //生态建设
            if (ErectRatio > 0) {
                uint erectAmount = amount * ErectRatio / 100;
                _amount -= erectAmount;
                _balances[address(ErectAddress)] += erectAmount;
                emit Transfer(sender, address(ErectAddress), erectAmount);
            }
            //联创
            if (UnionRatio > 0) {
                uint unionAmount = amount * UnionRatio / 100;
                _amount -= unionAmount;
                _balances[address(UnionAddress)] += unionAmount;
                emit Transfer(sender, address(UnionAddress), unionAmount);
            }
            //子币
            if (ChildRatio > 0) {
                uint childAmount = amount * ChildRatio / 100;
                _amount -= childAmount;
                _balances[address(ChildAddress)] += childAmount;
                emit Transfer(sender, address(ChildAddress), childAmount);
            }
            //销毁
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

    function _mint(address account, uint amount) internal virtual {
        _balances[account] += amount;
        _totalSupply += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint amount) internal virtual {
        require(account != address(0), "LINE: burn from the zero address");
        uint accountBalance = _balances[account];
        require(accountBalance >= amount, "LINE: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function burn(uint amount) external {
        _burn(_msgSender(), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function setRatio(uint _erect, uint _union, uint _lp, uint _bu, uint _child) external onlyAdmin {
        ErectRatio = _erect;
        UnionRatio = _union;
        LpRatio = _lp;
        BurnRatio = _bu;
        ChildRatio = _child;
    }

    function setAddress(address _erect, address _union, address _lp, address _child) external onlyAdmin {
        ErectAddress = _erect;
        UnionAddress = _union;
        LpAddress = _lp;
        ChildAddress = _child;
    }

    function addExclude(address _pair) external onlyAdmin {
        if (Excludes[_pair]) {
            Excludes[_pair] = false;
        } else {
            Excludes[_pair] = true;
        }
    }

    receive() external payable {}
}