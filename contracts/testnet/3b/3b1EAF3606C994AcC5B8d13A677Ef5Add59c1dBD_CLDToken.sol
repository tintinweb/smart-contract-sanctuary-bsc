// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./IBEP20.sol";

contract CLDToken is IBEP20 {
  address owner;
  uint public totalSupply;
  mapping(address => uint) public override balanceOf;
  mapping(address => mapping(address => uint)) public override allowance;
  mapping(address => uint256) private balances;
  string public name = "CLD Token";
  string public symbol = "CLDToken";
  uint8 public decimals = 18;
  address devWallet;
  bool frozen = false;
  mapping(address => bool) frozenWallets;
  bool isTEGStarted = false;
  uint constant devAllocation = 10e14;
  uint public devAllocationRemaining = 10e14;
  uint constant totalDevAllocationTime = 31104000; //12*30*24*60*60
  uint constant public tgeAllocationPercentage = 10;
  uint public lastAllocationTime = 0;

//  Events
  event FreezeWallet(address indexed target, uint time, uint blockNumber);
  event SetDev(address indexed target, uint time, uint blockNumber);
  event BeginTokenEventGeneration(uint time, uint blockNumber);
  event ReleaseAllocation(address indexed target, uint time, uint blockNumber, uint amount);


  constructor() public{
    owner = msg.sender;
    totalSupply = 10e16;
    balances[msg.sender] = 10e16;
  }

  //  A2: setup owner validation
  modifier ownerOnly () {
    require(msg.sender == owner);
    _;
  }
  //  A2: setup dev validation
  modifier devOnly () {
    require(msg.sender == devWallet);
    _;
  }

  // Only allow active wallet to work
  modifier activeWalletOnly () {
    require(frozenWallets[msg.sender], 'This address has been frozen.');
    _;
  }

  modifier activeTokens () {
    require(frozen == true, 'Tokens are frozen.');
    _;
  }

  modifier tgeStarted () {
    require(isTEGStarted == true, 'The TGE not stated yet.');
    _;
  }

  function transfer(address recipient, uint amount) activeWalletOnly activeTokens external override returns (bool) {
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint amount
  ) activeWalletOnly activeTokens external override returns (bool) {
    allowance[sender][msg.sender] -= amount;
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  //  A2: Admin can mint new token
  function mint(uint amount) ownerOnly activeTokens external {
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
    emit Transfer(address(0), msg.sender, amount);
  }

  //  A2: Burn token, when burn totalSupply is decrease
  function burn(uint amount) ownerOnly activeTokens external {
    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
  }

  //  A2: Admin can setup new dev address
  function updateDevAccount (address newAddress) ownerOnly public {
    devWallet = newAddress;
    emit SetDev(devWallet, block.timestamp, block.number);
  }

  //  A2: Freeze/Unfreeze a certain wallet
  function freezeWallet (address frozenWallet, bool isFrozen) ownerOnly public {
    frozenWallets[frozenWallet] = isFrozen;
    emit FreezeWallet(frozenWallet, block.timestamp, block.number);
  }

  function beginTokenEventGeneration () ownerOnly public {
    require(isTEGStarted == false, 'The TGE has started, cannot start again.');
    isTEGStarted = true;
    lastAllocationTime = block.timestamp;
    emit BeginTokenEventGeneration(block.timestamp, block.number);
  }

  function releaseDevAllocation () devOnly tgeStarted public {
    require(devWallet != address(0), 'Dev wallet was not setup.');
    if (devAllocationRemaining == devAllocation) {
      releaseAllocationByPercent(tgeAllocationPercentage);
    } else {
      uint percent = ((block.timestamp - lastAllocationTime) / totalDevAllocationTime) / 100;
      releaseAllocationByPercent(percent);
    }
  }

  function releaseAllocationByPercent(uint percent) internal {
    uint amount = devAllocation / percent * 100;
    balances[devWallet] = balances[devWallet] + amount;
    devAllocationRemaining = devAllocationRemaining - amount;
    emit ReleaseAllocation(devWallet, block.timestamp, block.number, amount);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}