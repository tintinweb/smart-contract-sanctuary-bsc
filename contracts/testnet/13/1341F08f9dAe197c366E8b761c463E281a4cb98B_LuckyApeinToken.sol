/**
 *Submitted for verification at BscScan.com on 2022-06-28
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.15;

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed value);
    event Approval(address indexed owner, address indexed spender, uint256 indexed value);
}

contract LuckyApeinToken is IBEP20 {
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) internal _balances;
    mapping (address => bool) internal isHolder;
 
    address[] internal holders;
    mapping(address => uint256) public holderShares; 

    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        owner = msg.sender;
        _name = "Lucky Apein";
        _symbol = "LAI";
        _decimals = 0;
        _totalSupply = 1000000;
        _balances[owner] = _totalSupply;
        holders.push(msg.sender);
        isHolder[msg.sender] = true;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function renounceOwnership() public {
        require(msg.sender == owner, "Only owner can renounce ownership");
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    function getHolders() external view returns (address[] memory) {
        return holders;
    }

    function getHolderShare(address holder) external view returns (uint) {
        return holderShares[holder];
    }

    function addHolderShare(address holder, uint value) external {
        holderShares[holder] += value;
    }

    function deductHolderShare(address holder, uint amount) external {
        holderShares[holder] -= amount;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address tokenOwner, address tokenSpender) external view returns (uint256) {
        return _allowances[tokenOwner][tokenSpender];
    }

    function approve(address tokenSpender, uint256 amount) external returns (bool) {
        _approve(msg.sender, tokenSpender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address tokenSpender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, tokenSpender, _allowances[msg.sender][tokenSpender] + addedValue);
        return true;
    }

    function decreaseAllowance(address tokenSpender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, tokenSpender, _allowances[msg.sender][tokenSpender] - subtractedValue);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Can't transfer from the zero address");
        require(recipient != address(0), "Can't transfer to the zero address");

        // if the recepient is not a holder then add him to the holders list because this is a new member
        if (isHolder[recipient] == false) {
            holders.push(recipient);
            isHolder[recipient] = true;
        }
        
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address tokenOwner, address tokenSpender, uint256 amount) internal {
        require(tokenOwner != address(0), "The approver can't be the zero address");
        require(tokenSpender != address(0), "The spender can't be the zero address");

        _allowances[tokenOwner][tokenSpender] = amount;
        emit Approval(tokenOwner, tokenSpender, amount);
    }

    function calculateShare(address tokenOwner) public view returns(uint) {
        uint multiplier = 10 ** 6; 
        uint share = uint(_balances[tokenOwner] * multiplier) / uint(_totalSupply);
        return share;
    }
}