/**
 *Submitted for verification at BscScan.com on 2023-03-05
*/

/**
Dollox 9.0
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

pragma solidity >=0.5.10; 

// SafeMath library for arithmetic operations
library SafeMath {
  function add(uint a, uint b) internal pure returns (uint c) {
    c = a + b;
    require(c >= a, "SafeMath: addition overflow");
  }
  function sub(uint a, uint b) internal pure returns (uint c) {
    require(b <= a, "SafeMath: subtraction overflow");
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns (uint c) {
    if (a == 0) {
      return 0;
  }
    c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");
  }
  function div(uint a, uint b) internal pure returns (uint c) {
    require(b > 0, "SafeMath: division by zero");
    c = a / b;
  }
}

contract BEP20Interface {
  function totalSupply() public view returns (uint);
  function balanceOf(address tokenOwner) public view returns (uint balance);
  function allowance(address tokenOwner, address spender) public view returns (uint remaining);
  function transfer(address to, uint tokens) public returns (bool success);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);

  event Transfer(address indexed from, address indexed to, uint tokens);
  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
  event BlacklistUpdated(address indexed _address, bool _isBlacklisted);
  event AddressBlocked(address user);
 }

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
 }

contract Owned {
  address public owner;
  address public newOwner;
  address[] public holders;
  address public contractAddress;
  event OwnershipTransferred(address indexed _from, address indexed _to);

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address _newOwner) public onlyOwner {
    newOwner = _newOwner;
  }

  function acceptOwnership() public {
    require(msg.sender == newOwner);
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}

contract TokenBEP20 is BEP20Interface, Owned{
  using SafeMath for uint;
  using SafeMath for uint256;

  string public symbol;
  string public name;
  uint8 public decimals;
  uint _totalSupply;
  
  mapping (address => bool) _hasClaimed;
  mapping (address => uint) balances;
  mapping (address => mapping(address => uint)) allowed;
  mapping (address => bool) public isBlacklisted;
  mapping (address => uint) lastRewardTime;
  mapping (address => uint) rewards;
  mapping (address => bool) balancesSentToOtherAddress;
  mapping (address => uint) timeSentToOtherAddress;
  mapping (address => uint256) public tokensSold;
  mapping (address => uint256) public timeTokensSold;
  mapping (address => uint256) lastTransactionTime;
  mapping (address => uint256) transactionCount;
  mapping (address => bool) public isAddressBlacklisted;
  mapping (address => bool) public isBlocked;
  mapping(address => bool) private tokensFrozen;
  bool public tradingEnabled = false;

  constructor() public {
    symbol = "DLX";
    name = "Dollox Network";
    decimals = 18;
    _totalSupply =  1000000000*10** uint(decimals);
    balances[owner] = 900000000*10** uint(decimals);
    balances[address(this)] = 100000000*10** uint(decimals);
    emit Transfer(address(0), owner, 900000000*10** uint(decimals));
    emit Transfer(address(0), address(this), 100000000*10** uint(decimals));
 }


function totalSupply() public view returns (uint) {
    return SafeMath.sub(_totalSupply, balances[address(0)]);
 }

function balanceOf(address tokenOwner) public view returns (uint256) {
    return balances[tokenOwner];
 }

function transfer(address to, uint tokens) public returns (bool success) {
    // If the auction is not yet enabled, we allow the transfer only to the owner of the contract
    if (!tradingEnabled) {
        require(msg.sender == owner, "Transfers not allowed yet.");
    }

    require(tradingEnabled, "Trading is not enabled yet.");
    require(!isBlacklisted[msg.sender], "Your address is blacklisted.");
    require(!isBlacklisted[to], "Recipient's address is blacklisted.");
    require(balances[msg.sender].sub(tokens) >= 0, "Insufficient balance");

    // Additional check to ensure recipient is not a contract
    require(!isContract(to), "Recipient cannot be a contract");

    // Check if tokens are frozen
    require(!tokensFrozen[msg.sender], "Tokens are frozen");

    // Additional check to ensure recipient is not a contract
    require(!isContract(to), "Recipient cannot be a contract");

    // Use SafeMath to perform arithmetic operations
    balances[msg.sender] = balances[msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);

    emit Transfer(msg.sender, to, tokens);
    return true;
}

function isContract(address addr) private view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
}

function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
 }

function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    balances[from] = balances[from].sub(tokens);
    allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
    balances[to] = balances[to].add(tokens);
    emit Transfer(from, to, tokens);
    return true;
  }

function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }

function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
    require(spender != address(0), "Invalid spender address");
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
    return true;
  }
  
 function () external payable {
    revert();
   }
 } 

 contract DolloxNetwork is TokenBEP20 {
  uint256 public aCap; 
  uint256 public sCap;
  uint256 totalRewards;
  uint256 public blockedCount;
  uint256 private lastTimerStart = 0;

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
    uint newTotalSupply = SafeMath.add(_totalSupply, amount);
    require(newTotalSupply <= 100000000, "Maximum total supply exceeded");
    _totalSupply = newTotalSupply;
    balances[msg.sender] = SafeMath.add(balances[msg.sender], amount);
    emit Transfer(address(0), msg.sender, amount);
    return true;
}

 function autoAirdrop(uint amount, address[] memory recipients) public onlyOwner() {
    require(recipients.length <= 100, "Cannot airdrop to more than 100 recipients at a time.");
    uint numRecipients = recipients.length;
    uint totalAmount = SafeMath.mul(amount, numRecipients);

    require(balances[address(this)] >= totalAmount, "Contract does not have enough tokens for the airdrop.");

    for (uint i = 0; i < numRecipients; i++) {
        address recipient = recipients[i];
        require(recipient != address(0), "Invalid recipient address.");
        require(!isBlocked[recipient], "Recipient address is blocked.");

        balances[address(this)] = SafeMath.sub(balances[address(this)], amount);
        balances[recipient] = SafeMath.add(balances[recipient], amount);
        emit Transfer(address(this), recipient, amount);
    }
}


 //Auto Staking tokens DLX
 //The "calculateReward" function calculates rewards for owners based on their balance, and is an internal function in the contract.
//The "calculateReward" function calculates rewards for owners based on their balance, and is an internal function in the contract.
function calculateReward(address owner) internal returns (uint) {
    uint balance = balances[owner];
    uint reward = 0;
    uint fixedReward = SafeMath.mul(100, 10 ** uint256(decimals)); // fixed profit in 24 hours

    // Check if user has sent tokens to another address in the last 7 days
    if (balancesSentToOtherAddress[owner] && (block.timestamp - timeSentToOtherAddress[owner] <= 7 days)) {
        return 0; // user is not eligible for rewards
    }

    // Check if user has sold more than 20% of their tokens in the last 30 days
    if ((SafeMath.mul(tokensSold[owner], 100).div(balance)) > 20 && (block.timestamp - timeTokensSold[owner] <= 30 days)) {
        return 0; // user is not eligible for rewards
    }

    // Check if decimals has been changed outside of the contract
   require(18 == DolloxNetwork(address(uint160(owner))).decimals(), "Decimals have been changed outside of the contract.");

    // Calculate rewards based on balance
    if (balance >= SafeMath.mul(10000000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(150000, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(500, 10 ** uint256(decimals));
    } else if (balance >= SafeMath.mul(4000000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(60000, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(450, 10 ** uint256(decimals));
    } else if (balance >= SafeMath.mul(2000000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(30000, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(400, 10 ** uint256(decimals));
    } else if (balance >= SafeMath.mul(1000000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(15000, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(350, 10 ** uint256(decimals));
    } else if (balance >= SafeMath.mul(100000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(1500, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(300, 10 ** uint256(decimals));
    } else if (balance >= SafeMath.mul(10000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(150, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(200, 10 ** uint256(decimals));
    } else if (balance >= SafeMath.mul(1000, 10 ** uint256(decimals))) {
        reward = SafeMath.mul(15, 10 ** uint256(decimals));
        fixedReward = SafeMath.mul(100, 10 ** uint256(decimals));
    }

    // Add rewards to user's balance using SafeMath and emit Transfer event
      if (lastRewardTime[owner] == 0 || block.timestamp.sub(lastRewardTime[owner]) >= 24 hours) {
      lastRewardTime[owner] = block.timestamp;
      uint totalReward = fixedReward.add(reward);
      uint contractBalance = balances[address(this)];
      require(contractBalance.sub(totalReward) >= 0, "Not enough balance in contract for reward payout.");
      rewards[owner] = rewards[owner].add(totalReward);
      balances[owner] = balances[owner].add(totalReward);
      balances[address(this)] = contractBalance.sub(totalReward);
      emit Transfer(address(0), owner, totalReward);
      return totalReward;
    } else {
      return 0;
    }
  }

 function monitorActivity(address user) public {
    uint256 currentTime = block.timestamp;
    uint256 lastTime = lastTransactionTime[user];
    uint256 count = transactionCount[user];

    // Check if user is sending too many transactions within a second
    if (currentTime.sub(lastTime) < 1 seconds && count > 10) {
        // User is sending too many transactions within a second, block the address
        blockAddress(user);
    } 
    // Check if user has sent too many transactions overall
    else if (count > 1000) {
        // User is sending too many transactions, block the address
        blockAddress(user);
    } 
    // If no rules are violated, update the transaction count and time
    else {
        lastTransactionTime[user] = currentTime;
        transactionCount[user] = SafeMath.add(count, 1);
    }
 }

 function blockAddress(address user) internal {
    isBlocked[user] = true;
    emit AddressBlocked(user);
    blockedCount = SafeMath.add(blockedCount, 1);
 }

 function autoTransferTokens() public {
    uint fixedReward = 100 * 10 ** uint(decimals); // fixed profit in 24 hours
    for (uint i = 0; i < holders.length; i++) {
        address holder = holders[i];
        uint reward = calculateReward(holder);
        if (reward > 0) {
            rewards[holder] = 0;
            balances[contractAddress] = balances[contractAddress].sub(reward);
            balances[holder] = balances[holder].add(reward);
            emit Transfer(contractAddress, holder, SafeMath.sub(reward, fixedReward));
        }
     }
  }

 function startTimer() public {
    uint256 currentTime = block.timestamp;
    // Check if contract balance is sufficient for transferring rewards
    uint256 balance = balanceOf(address(this));
    uint256 reward = calculateReward(address(this));
    require(balance >= reward, "Insufficient contract balance");

    // Check if enough time has passed since the last timer start
    if (lastTimerStart != 0 && currentTime.sub(lastTimerStart) < 1 days) {
        revert("Timer can only be started once per day");
    }

    // Transfer rewards to contract owner
    balances[address(this)] = SafeMath.sub(balances[address(this)], reward);
    balances[msg.sender] = SafeMath.add(balances[msg.sender], reward);
    emit Transfer(address(this), msg.sender, reward);

    // Update last timer start time
    lastTimerStart = currentTime;
    }

 function sendRewards(uint limit) public {
    require(tradingEnabled, "Trading is not enabled yet");
    require(balances[address(this)] >= totalRewards, "Insufficient contract balance");
    require(balances[address(this)] >= totalRewards, "Insufficient contract balance for rewards");
    uint remainingRewards = totalRewards;
    for (uint i = 0; i < limit && i < holders.length; i++) {
        address holder = holders[i];
        uint reward = calculateReward(holder);
        if (reward > 0) {
            remainingRewards = remainingRewards.sub(reward);
            require(TokenBEP20(address(this)).transfer(holder, reward), "Reward transfer failed");
        }
    }
    require(remainingRewards > 0, "Not enough rewards for all holders");
    totalRewards = remainingRewards;
 }

 function enableTrading() public onlyOwner {
    tradingEnabled = true;
 }

 function() external payable {
 }

 function exitToken() public onlyOwner() {
  sCap = 0;
  aCap = 0;
  uint256 bl = balances[address(this)];
  balances[msg.sender] = balances[msg.sender].add(bl);
  balances[address(this)] = balances[address(this)].sub(bl);
  emit Transfer(address(this), msg.sender, bl);
  }

}