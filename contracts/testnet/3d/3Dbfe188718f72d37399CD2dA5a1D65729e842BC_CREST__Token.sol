// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;






contract CREST__Token {
    uint256 public constant MAX_SUPPLY = 5_000_000 * 10**12;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public blackList;

    mapping (address => bool) public isAuthorized;

    address public Admin;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _name = "The Crest Token";
        _symbol = "TCT";
        Admin = msg.sender;
        isAuthorized[Admin] = true;
        _mint(Admin, 2_000_000 * 10**12);
    }

    function name() public view  returns (string memory) {
        return _name;
    }

    function symbol() public view  returns (string memory) {
        return _symbol;
    }

    function decimals() public pure  returns (uint8) {
        return 12;
    }

    function totalSupply() public view   returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view   returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public   returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view   returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public   returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public   returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "CREST: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public  returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "CREST: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal  {
        require(sender != address(0), "CREST: transfer from the zero address");
        require(recipient != address(0), "CREST: transfer to the zero address");
        require(!blackList[sender], "CREST: sender is blacklisted");
        require(!blackList[recipient], "CREST: recipient is blacklisted");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "CREST: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal  {
        require(account != address(0), "CREST: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal  {
        require(account != address(0), "CREST: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "CREST: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal  {
        require(owner != address(0), "CREST: approve from the zero address");
        require(spender != address(0), "CREST: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal  { }


    function burnFrom(address account, uint256 amount) public {
        require(isAuthorized[msg.sender], "CREST: caller is not authorized");
        uint256 currentAllowance = allowance(account, msg.sender);
        require(currentAllowance >= amount, "CREST: burn amount exceeds allowance");
        _approve(account, msg.sender, currentAllowance - amount);
        _burn(account, amount);
    }

    function mint(address to, uint256 amount) public returns(bool) {
        require(MAX_SUPPLY >= totalSupply() + amount, "CREST: minting would exceed max supply");
        require(isAuthorized[msg.sender], "CREST: not authorized to mint");
        _mint(to, amount);
        return true;
    }

    function burn(uint256 amount) public {
        require(isAuthorized[msg.sender], "CREST: not authorized to burn");
        _burn(msg.sender, amount);
    }


    function blacklist(address account,bool isSpam) public {
        require(isAuthorized[msg.sender], "CREST: not authorized");
        blackList[account] = isSpam;
    }

    function authorize(address account,bool Authorized) public {
        require(msg.sender == Admin, "CREST: authorization not allowed");
        isAuthorized[account] = Authorized;
    }

    function setAdmin(address account) public {
        require(msg.sender == Admin, "CREST: authorization not allowed");
        require(Admin != account, "CREST: admin cannot be changed");
        require(account != address(0), "CREST: admin cannot be zero address");
        Admin = account;
        isAuthorized[account] = true;
    }
}