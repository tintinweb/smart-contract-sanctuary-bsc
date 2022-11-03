/**
 *Submitted for verification at BscScan.com on 2022-11-03
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ApprovePoints(address indexed account, uint256 amount);
    event Deposit(address indexed from, uint256 amount);
    event SubmitPoints(address indexed account, uint256 amount, string hash);
    event RankingPayment(address indexed account, uint256 amount, uint256 bnb);
    
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
        this;
        return msg.data;
    }
}

contract GoldenCoinRanking is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _submits;
    address [] _players;
    mapping (address => string) private _hashs;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address private _manager;
    address payable public top1_address;
    uint256 public top1_points = 0;

    constructor (address manager_) {
        _name = "GoldenCoinPoints";
        _symbol = "GC Points";
        _manager = manager_;
    }

    /// @dev Fallback function allows to deposit ether.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(_msgSender(), msg.value);
        }
    }
    modifier onlyManager() {
        require(_msgSender() == _manager, "Only Manager");
        _;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function approvePoints(address account) external onlyManager {
        if (top1_points < _submits[account]) {
            top1_points = _submits[account];
            top1_address = payable(account);
        }
        _totalSupply -= _balances[account];
        _totalSupply += _submits[account];
        _balances[account] = _submits[account];
        emit ApprovePoints(account, _submits[account]);
        emit Transfer(account, address(0), _balances[account]);
        emit Transfer(address(0), account, _submits[account]);
    }
    function resetBalance() internal {
        for (uint i=0; i< _players.length ; i++) {
            emit Transfer(_players[i], address(0), _balances[_players[i]]);
            _balances[_players[i]] = 0;
            _submits[_players[i]] = 0;
        }
    }
    function submmitPoints(uint256 amount, string memory hash) external {
        require(_submits[_msgSender()] < amount, "Can't submit lower score");
        _submits[_msgSender()] = amount;
        _hashs[_msgSender()] = hash;
        _players.push(_msgSender());
        emit SubmitPoints(_msgSender(), amount, hash);
    }
    function rankingPayment() external onlyManager {
        uint256 amount = top1_points;
        uint256 bnb = address(this).balance;
        payable(top1_address).transfer(bnb);
        top1_address = payable(_manager);
        top1_points = 0;
        resetBalance();
        _totalSupply = 0;
        emit RankingPayment(_msgSender(), amount, bnb);
        
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

    function transfer(address recipient, uint256 amount) public virtual onlyManager override returns (bool)  {
         _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual onlyManager override returns (uint256)  {
         return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual onlyManager override returns (bool)  {
         _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual onlyManager override returns (bool)  {
         _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual onlyManager returns (bool)  {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual onlyManager returns (bool)  {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(_msgSender() == _manager, "Only Manager");
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}