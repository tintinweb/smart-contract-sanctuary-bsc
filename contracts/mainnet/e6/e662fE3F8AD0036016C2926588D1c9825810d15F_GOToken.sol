/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

// SPDX-License-Identifier: MIT
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

pragma solidity ^0.8.0;

contract GOToken is IERC20 {
    string public constant _name = "GO-TOKEN";
    string public constant _symbol = "GOT";
    uint8 public constant _decimals = 18;
    uint256 public _totalSupply = 1000000000 * 10 ** _decimals;
    
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) allowed;

    mapping(address => bool) public isOwnerAddress;
    
    // Blacklisted addresses will not be allowed to aquire new token.
    // They can still move / sell token if they already have aquired it before adding.

    mapping(address => bool) public isBlackListed;
    address[] private blackList;
    address public owner;

    constructor() {
        owner = msg.sender;
        isOwnerAddress[msg.sender] = true;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier onlyOwner() {
        require(isOwnerAddress[msg.sender] , "Only owner!");
        _;
    }

    function addOwner(address _address) public onlyOwner {
        isOwnerAddress[_address] = true;
    }
    function removeOwner(address _address) public onlyOwner {
        require (_address != owner, "Restricted Address");
        isOwnerAddress[_address] = false;
    }
    function addToBlackList(address _address) public onlyOwner {
        require (!isBlackListed[_address] , "address exsit in blackList");     
        isBlackListed[_address] = true;
        blackList.push(_address);
    }
    function removeFromBlackList(address _address) public onlyOwner {
        require (isBlackListed[_address] , "address doesnot exsit in blackList");
        isBlackListed[_address] = false;
        uint len = blackList.length;
        for(uint i = 0; i < len; i++) {
            if(blackList[i] == _address) {
                blackList[i] = blackList[len-1];
                blackList.pop();
                break;
            }
        }
    }
    function getBlackList() public view returns (address[] memory list){
        list = blackList;
    }
    function getBlackListLength() public view returns (uint256) {
        return blackList.length;
    }

    // ERC20 Functions

    function burnFrom(address from, uint256 value) public onlyOwner {
        require (_balances[from]>=value, "insuffincent burn amount");
        _balances[from] -= value;
        _balances[address(0)] += value;
        emit Transfer(from, address(0), value);
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        // _approve(_msgSender(), spender, amount);
        // return true;
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function allowance(address tokenOwner, address spender) public view virtual override returns (uint256) {
        return allowed[tokenOwner][spender];
    }
    function transfer(address receiver, uint256 amount) public virtual override returns (bool) {
        return _transfer(msg.sender, receiver, amount);
    }
    function transferFrom(address tokenOwner, address receiver, uint256 amount) public virtual override returns (bool) {
        require(amount <= allowed[tokenOwner][msg.sender],"Invalid number of tokens allowed by owner");
        allowed[tokenOwner][msg.sender] -= amount;
        return _transfer(tokenOwner, receiver, amount);
    }
    function _transfer(address sender, address receiver, uint256 amount) internal virtual returns (bool) {
        require(sender!= address(0) && receiver!= address(0), "invalid send or receiver address");
        require(amount <= _balances[sender], "Invalid number of tokens");
        require(!isBlackListed[receiver] , "Address is blacklisted and cannot own this token");

        _balances[sender] -= amount;
        _balances[receiver] += amount;

        emit Transfer(sender, receiver, amount);
        return true;
    }
}