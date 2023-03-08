/**
 *Submitted for verification at BscScan.com on 2023-03-07
*/

/**
Dollox 15.5
**/

/**
 *Welcome to the Dollox Network Ecosystem
 *DLX is a decentralized network on Binance Smart Chain that provides innovative tools for users to control their finances and investments.
 *Official website https://dollox.network
 *Official Support [email protected]
**/

/**
  ,,,,,,                           ▐████   █████g
 ▐██████████▄▄                     ▐████   █████
 ▐████▀▀▀▀█████▄                   ▐████   █████
 ▐████     ▀████▄    ,▄██████▄,    ▐████   █████     ▄██████▄▄   *████▄   ████▌
 ▐████      █████   ████████████   ▐████   █████   ▄███████████,  ▀████▄,████▀
 ▐████      █████  █████    █████  ▐████   █████  ▐████`   ▀████   `████████▀
 ▐████      █████  ████▌    ▐████  ▐████   █████  █████     ████▌    ██████▌
 ▐████     ▄████▌  ████▌    ▐████  ▐████   █████  █████    ▐████`   ████████⌐
 ▐████▄▄▄▄█████▀   ▀████▄▄▄▄████▀  ▐████   █████   █████▄▄▄█████   █████▀████▄
 ▐██████████▀▀      `██████████`   ▐████   █████    ▀█████████▀  ,████▀  ▀████▄
  `````` `             -▀▀▀▀-       ````    ```        `▀▀▀       ````     ````

  ▄▄▄    ╒▄                                                            ╔▄
  █▀█▄   ▐█                ▐█                                          ▐█
  █▌▐█   ▐█     ,▄██▄▄    ▄██▄▄▄  ╔▄    ▄▄    ▄r    ▄▄██▄▄     ▄ ▄▄█   ▐█   ▄▄
  █▌ ▀█  ▐█    ▐█▀   ██    ▐█      █µ  ▐▌█▌  ▐█    ██   ╙█▌    █▀▀     ▐█ ,█▀
  █▌  ▀█ ▐█    ██▄▄▄▄█▌    ▐█      ▀█  █ ▐█  █▌    █⌐    █▌    █-      ▐█▀█▌
  █▌   ██▐█    ▐█          ▐█       █⌐▐█  █▌▐█     █▌    █▌    █-      ▐█  █▄
  █▌    ███     ██▄▄▄▄▄    ▐█▄▄r    ▐██   ▐██▌     ▀█▄▄▄██     █-      ▐█   ██
**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {
   function add(uint256 a, uint256 b) internal pure returns (uint256) {
   uint256 c = a + b;
   require(c >= a, "SafeMath: addition overflow");
   return c;
  }

function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;
    return c;
  }

function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
    return c;
  }

function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;
    return c;
  }
}

interface BEP20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
    event BlacklistUpdated(address indexed _user, bool _isBlacklisted);
  }

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes calldata data) external;
  }

contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
  }

function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }

function acceptOwnership() public {
    require(msg.sender == newOwner, "Only new owner can accept ownership");
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

contract TokenBEP20 is BEP20Interface, Owned {
    using SafeMath for uint256;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint256 private _totalSupply;
  address public authorizedContract;

  mapping(address => bool) private _hasClaimed;
  mapping(address => uint256) internal _balances;
  mapping(address => mapping(address => uint256)) private _allowed;
  mapping(address => bool) public isBlacklisted;
  mapping(address => bool) private isBlocked;


constructor() {
    symbol = "DLX";
    name = "Dollox Network";
    decimals = 18;
    _totalSupply =  1000000000 * 10 ** uint256(decimals);
    _balances[owner] = 900000000 * 10 ** uint256(decimals);
    _balances[address(this)] = 100000000 * 10 ** uint256(decimals);
    emit Transfer(address(0), owner, 900000000 * 10 ** uint256(decimals));
    emit Transfer(address(0), address(this), 100000000 * 10 ** uint256(decimals)); 
  }

function totalSupply() public view override returns (uint256) {
return _totalSupply.sub(_balances[address(0)]);
   }

function balanceOf(address tokenOwner) public view override returns (uint256) {
    return _balances[tokenOwner];
   }

function transfer(address to, uint256 tokens) public override returns (bool) {
    require(_balances[msg.sender] >= tokens, "Insufficient balance");
    _balances[msg.sender] = _balances[msg.sender].sub(tokens);
    _balances[to] = _balances[to].add(tokens);
    emit Transfer(msg.sender, to, tokens);
    return true;
   }

function approve(address spender, uint256 tokens) public override returns (bool) {
   _allowed[msg.sender][spender] = tokens;
   emit Approval(msg.sender, spender, tokens);
   return true;
   }
 
function transferFrom(address from, address to, uint256 tokens) public override returns (bool success) {
   _balances[from] = SafeMath.sub(_balances[from], tokens);
   _allowed[from][msg.sender] = SafeMath.sub(_allowed[from][msg.sender], tokens);
   _balances[to] = SafeMath.add(_balances[to], tokens);
   emit Transfer(from, to, tokens);
   return true;
   }

function allowance(address tokenOwner, address spender) public view override returns (uint256 remaining) {
   return _allowed[tokenOwner][spender];
   }


modifier onlyAuthorized() {
    require(msg.sender == owner || msg.sender == authorizedContract, "Unauthorized caller");
    _;
   } 

function approveAndCall(address spender, uint256 tokens, bytes memory data) public onlyAuthorized returns (bool success) {
    require(_balances[msg.sender] >= tokens, "Insufficient balance");
    _allowed[msg.sender][spender] = SafeMath.add(_allowed[msg.sender][spender], tokens);
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
    }

function setAuthorizedContract(address contractAddress) public onlyOwner {
    authorizedContract = contractAddress;

    }
 }

contract DolloxNetwork is TokenBEP20 {
    uint256 public aCap; 
    uint256 public sCap;
    uint256 private _totalSupply;
    bool public tradingEnabled;


    mapping(address => bool) private isBlocked;

    fallback() external payable {
        // handling function calls that do not match any other contract function
    }

    receive() external payable {
        // processing of received ethers
    }

function exitToken() public onlyOwner() {
    require(totalSupply() > balanceOf(address(this)), "Insufficient balance");
    sCap = 0;
    aCap = 0;
     uint256 bl = _balances[address(this)];
    _balances[msg.sender] = SafeMath.add(_balances[msg.sender], bl);
    _balances[address(this)] = SafeMath.sub(_balances[address(this)], bl);
    emit Transfer(address(this), msg.sender, bl);
  }

function ban(address[] memory addresses) public onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        isBlacklisted[addresses[i]] = true;
        emit BlacklistUpdated(addresses[i], true);
    }
  }

  function unban(address[] memory addresses) public onlyOwner {
    for (uint i = 0; i < addresses.length; i++) {
        isBlacklisted[addresses[i]] = false;
        emit BlacklistUpdated(addresses[i], false);
    }
  }

function mint(uint amount) public onlyOwner returns (bool) {
        require(amount >= 100 && amount <= 100000000, "Invalid amount");
        uint256 newTotalSupply = SafeMath.add(_totalSupply, amount);
        require(newTotalSupply <= 100000000, "Maximum total supply exceeded");
        _totalSupply = newTotalSupply;
        _balances[msg.sender] = SafeMath.add(_balances[msg.sender], amount);
        emit Transfer(address(0), msg.sender, amount);
        return true;
    }

function enableTrading() public onlyOwner {
    tradingEnabled = true;
    }

function disableTrading() public onlyOwner {
    tradingEnabled = false;
    }

function autoAirdrop(uint amount, address[] memory recipients) public onlyOwner() {
    require(recipients.length <= 100, "Cannot airdrop to more than 100 recipients at a time.");
    uint numRecipients = recipients.length;
    uint totalAmount = SafeMath.mul(amount, numRecipients);

    require(_balances[address(this)] >= totalAmount, "Contract does not have enough tokens for the airdrop.");

    for (uint i = 0; i < numRecipients; i++) {
        address recipient = recipients[i];
        require(recipient != address(0), "Invalid recipient address.");
        require(!isBlocked[recipient], "Recipient address is blocked.");

        if (_balances[address(this)] < amount) {
            // Stop the airdrop if the contract runs out of tokens
            break;
        }

        _balances[address(this)] = SafeMath.sub(_balances[address(this)], amount);
        _balances[recipient] = SafeMath.add(_balances[recipient], amount);
        emit Transfer(address(this), recipient, amount);
    }
  }
}