// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./IBEP20.sol";

contract CLDToken is IBEP20 {
  address owner;
  uint256 private _totalSupply;
  mapping(address => uint) public override balanceOf;
  mapping(address => mapping(address => uint)) public override allowance;
  mapping(address => uint256) private balances;
  string public name = "CLD Token";
  string public symbol = "CLDToken";
  uint8 public decimals = 18;
  bool frozen = false;
  mapping(address => bool) frozenWallets;
  bool isTEGStarted = false;

//  Private sale vesting
  address privateSaleWallet;
  uint256 constant privateSaleAllocation = 95e10;
  uint256 public privateSaleAllocationRemaining = 95e10;
  uint constant privateSaleVestingTime = 365 days;
  uint constant public privateSaleTGEAllocationPercent = 10;
  uint constant public privateSaleLockTime = 180 days;
  uint public privateSaleLastAllocationTime = 0;

//  Public sale vesting
  address publicSaleWallet;
  uint constant publicSaleAllocation = 15e10;
  uint public publicSaleAllocationRemaining = 15e10;
  uint constant publicSaleVestingTime = 180 days;
  uint constant public publicSaleTGEAllocationPercent = 20;
  uint constant public publicSaleLockTime = 0 days;
  uint public publicSaleLastAllocationTime = 0;

  //  Community vesting
  address communityWallet;
  uint constant communityAllocation = 65e10;
  uint public communityAllocationRemaining = 65e10;
  uint constant public communityTGEAllocationPercent = 0;
  uint constant public communityLockTime = 0 days;
  uint public communityLastAllocationTime = 0;
  uint constant communityVestingTime = 0 days;

  //  Marketing and Dev vesting
  address devWallet;
  uint constant devAllocation = 4e10;
  uint public devAllocationRemaining = 4e10;
  uint constant public devTGEAllocationPercent = 5;
  uint constant public devLockTime = 180 days;
  uint constant devVestingTime = 450 days;
  uint public devLastAllocationTime = 0;

  //  Liquidity and listing
  address lnlWallet;
  uint constant lnlAllocation = 5e10;
  uint public lnlAllocationRemaining = 5e10;
  uint constant public lnlTGEAllocationPercent = 0;
  uint constant public lnlLockTime = 180 days;
  uint constant lnlVestingTime = 450 days;
  uint public lnlLastAllocationTime = 0;

  //  Foundation vesting
  address foundationWallet;
  uint constant foundationAllocation = 10e10;
  uint public foundationAllocationRemaining = 10e10;
  uint constant public foundationTGEAllocationPercent = 0;
  uint constant public foundationLockTime = 365 days;
  uint constant foundationVestingTime = 730 days;
  uint public foundationLastAllocationTime = 0;

//  Team and advisor
  address tnaWallet;
  uint constant tnaAllocation = 10e10;
  uint public tnaAllocationRemaining = 10e10;
  uint constant public tnaTGEAllocationPercent = 0;
  uint constant public tnaLockTime = 365 days;
  uint constant tnaVestingTime = 730 days;
  uint public tnaLastAllocationTime = 0;

//  Events
  event FreezeWallet(address indexed target, uint time, uint blockNumber);
  event BeginTokenEventGeneration(uint time, uint blockNumber);
  event ReleasePrivateSaleAllocation(uint256 time, uint256 blockNumber);
  event ReleasePublicSaleAllocation(uint256 time, uint256 blockNumber);
  event ReleaseCommunityAllocation(uint256 time, uint256 blockNumber);
  event ReleaseDevAllocation(uint256 time, uint256 blockNumber);
  event ReleaseLnLAllocation(uint256 time, uint256 blockNumber);
  event ReleaseFoundationAllocation(uint256 time, uint256 blockNumber);
  event ReleaseTnAAllocation(uint256 time, uint256 blockNumber);
  event ReleaseAllocation(address indexed target, uint time, uint blockNumber, uint amount);
  event SetDevAddress(address indexed target, uint time, uint blockNumber);
  event SetPrivateSaleAddress(address indexed target, uint time, uint blockNumber);
  event SetPublicSaleAddress(address indexed target, uint time, uint blockNumber);
  event SetCommunityAddress(address indexed target, uint time, uint blockNumber);
  event SetLnLAddress(address indexed target, uint time, uint blockNumber);
  event SetFoundationAddress(address indexed target, uint time, uint blockNumber);
  event SetTnAAddress(address indexed target, uint time, uint blockNumber);

  constructor() public{
    owner = msg.sender;
    _totalSupply = 10e11;
    balances[msg.sender] = _totalSupply;
  }

  modifier ownerOnly () {
    require(msg.sender == owner, 'Only owner can call.');
    _;
  }

  modifier privateSaleOnly () {
    require(msg.sender == privateSaleWallet, 'Only private sale address can access this function.');
    _;
  }

  modifier publicSaleOnly () {
    require(msg.sender == publicSaleWallet, 'Only public sale address can access this function.');
    _;
  }

  modifier communityOnly () {
    require(msg.sender == communityWallet, 'Only community address can access this function.');
    _;
  }

  modifier devOnly () {
    require(msg.sender == devWallet, 'Only dev address can access this function.');
    _;
  }

//  Liquidity and listing
  modifier lnlOnly () {
    require(msg.sender == lnlWallet, 'Only liquidity and listing address can access this function.');
    _;
  }

  modifier foundationOnly () {
    require(msg.sender == foundationWallet, 'Only foundation address can access this function.');
    _;
  }

//  Team and advisor
  modifier tnaOnly () {
    require(msg.sender == tnaWallet , 'Only team and advisor address can access this function.');
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
    _totalSupply += amount;
    emit Transfer(address(0), msg.sender, amount);
  }

  function totalSupply() public view virtual returns (uint256) {
    return _totalSupply;
  }

  //  A2: Burn token, when burn totalSupply is decrease
  function burn(uint amount) ownerOnly activeTokens external {
    balanceOf[msg.sender] -= amount;
    _totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
  }

  function setPrivateSaleAddress (address newAddress) ownerOnly public {
    privateSaleWallet = newAddress;
    emit SetPrivateSaleAddress(privateSaleWallet, block.timestamp, block.number);
  }

  function setPublicSaleAddress (address newAddress) ownerOnly public {
    publicSaleWallet = newAddress;
    emit SetPublicSaleAddress(publicSaleWallet, block.timestamp, block.number);
  }

  function setCommunityAddress (address newAddress) ownerOnly public {
    communityWallet = newAddress;
    emit SetCommunityAddress(communityWallet, block.timestamp, block.number);
  }

  function setDevAddress (address newAddress) ownerOnly public {
    devWallet = newAddress;
    emit SetDevAddress(devWallet, block.timestamp, block.number);
  }

  function setLnLAddress (address newAddress) ownerOnly public {
    lnlWallet = newAddress;
    emit SetLnLAddress(lnlWallet, block.timestamp, block.number);
  }

  function setFoundationAddress (address newAddress) ownerOnly public {
    foundationWallet = newAddress;
    emit SetFoundationAddress(foundationWallet, block.timestamp, block.number);
  }

  function setTnAAddress (address newAddress) ownerOnly public {
    tnaWallet = newAddress;
    emit SetTnAAddress(tnaWallet, block.timestamp, block.number);
  }

  //  A2: Freeze/Unfreeze a certain wallet
  function freezeWallet (address frozenWallet, bool isFrozen) ownerOnly public {
    frozenWallets[frozenWallet] = isFrozen;
    emit FreezeWallet(frozenWallet, block.timestamp, block.number);
  }

  function beginTokenEventGeneration () ownerOnly public {
    require(isTEGStarted == false, 'The TGE has started, cannot start again.');
    isTEGStarted = true;
    // Set TGE allocation time
    privateSaleLastAllocationTime = block.timestamp;
    publicSaleLastAllocationTime = block.timestamp;
    communityLastAllocationTime = block.timestamp;
    devLastAllocationTime = block.timestamp;
    lnlLastAllocationTime = block.timestamp;
    foundationLastAllocationTime = block.timestamp;
    tnaLastAllocationTime = block.timestamp;
    emit BeginTokenEventGeneration(block.timestamp, block.number);
  }

  function releasePrivateSaleAllocation () privateSaleOnly tgeStarted public {
    require(privateSaleWallet != address(0), 'Private sale wallet was not setup.');
    if (privateSaleAllocationRemaining == privateSaleAllocation) {
      releaseAllocationByPercent(privateSaleTGEAllocationPercent, privateSaleWallet, privateSaleAllocation, privateSaleAllocationRemaining);
    } else {
      uint percent = ((block.timestamp - privateSaleLastAllocationTime) / privateSaleVestingTime) * 100;
      releaseAllocationByPercent(percent, privateSaleWallet, privateSaleAllocation, privateSaleAllocationRemaining);
    }
    emit ReleasePrivateSaleAllocation(block.timestamp, block.number);
  }

  function releasePublicSaleAllocation () publicSaleOnly tgeStarted public {
    require(publicSaleWallet != address(0), 'Public wallet was not setup.');
    if (publicSaleAllocationRemaining == publicSaleAllocation) {
      releaseAllocationByPercent(publicSaleTGEAllocationPercent, publicSaleWallet, publicSaleAllocation, publicSaleAllocationRemaining);
    } else {
      uint percent = ((block.timestamp - publicSaleLastAllocationTime) / publicSaleVestingTime) * 100;
      releaseAllocationByPercent(percent, publicSaleWallet, publicSaleAllocation, publicSaleAllocationRemaining);
    }

    emit ReleasePublicSaleAllocation(block.timestamp, block.number);
  }

  function releaseCommunityAllocation () communityOnly tgeStarted public {
    require(communityWallet != address(0), 'Community wallet was not setup.');
    require(communityAllocation == communityAllocationRemaining, 'Community wallet allocation was already released fully.');
    if (communityAllocationRemaining == communityAllocation) {
      releaseAllocationByPercent(communityTGEAllocationPercent, communityWallet, communityAllocation, communityAllocationRemaining);
    }
    emit ReleaseCommunityAllocation(block.timestamp, block.number);
  }

  function releaseDevAllocation () devOnly tgeStarted public {
    require(devWallet != address(0), 'Dev wallet was not setup.');
    if (devAllocationRemaining == devAllocation) {
      releaseAllocationByPercent(devTGEAllocationPercent, devWallet, devAllocation, devAllocationRemaining);
    } else {
      uint percent = ((block.timestamp - devLastAllocationTime) / devVestingTime) * 100;
      releaseAllocationByPercent(percent, devWallet, devAllocation, devAllocationRemaining);
    }
    emit ReleaseDevAllocation(block.timestamp, block.number);
  }

  function releaseLnLAllocation () lnlOnly tgeStarted public {
    require(lnlWallet != address(0), 'Liquidity and Listing wallet was not setup.');
    if (lnlAllocation == lnlAllocationRemaining) {
      releaseAllocationByPercent(lnlTGEAllocationPercent, lnlWallet, lnlAllocation, lnlAllocationRemaining);
    } else {
      uint percent = ((block.timestamp - lnlLastAllocationTime) / lnlVestingTime) * 100;
      releaseAllocationByPercent(percent, devWallet, lnlAllocation, lnlAllocationRemaining);
    }
    emit ReleaseLnLAllocation(block.timestamp, block.number);
  }

  function releaseFoundationAllocation () foundationOnly tgeStarted public {
    require(foundationWallet != address(0), 'Foundation wallet was not setup.');
    if (foundationAllocationRemaining == foundationAllocation) {
      releaseAllocationByPercent(foundationTGEAllocationPercent, foundationWallet, foundationAllocation, foundationAllocationRemaining);
    } else {
      uint percent = ((block.timestamp - foundationLastAllocationTime) / foundationVestingTime) * 100;
      releaseAllocationByPercent(percent, foundationWallet, foundationAllocation, foundationAllocationRemaining);
    }

    emit ReleaseFoundationAllocation(block.timestamp, block.number);
  }

  function releaseTnAAllocation () tnaOnly tgeStarted public {
    require(tnaWallet != address(0), 'Team and Advisor wallet was not setup.');
    if (tnaAllocationRemaining == tnaAllocation) {
      releaseAllocationByPercent(tnaTGEAllocationPercent, tnaWallet, tnaAllocation, tnaAllocationRemaining);
    } else {
      uint percent = ((block.timestamp - tnaLastAllocationTime) / tnaVestingTime) * 100;
      releaseAllocationByPercent(percent, tnaWallet, tnaAllocation, tnaAllocationRemaining);
    }
    emit ReleaseTnAAllocation(block.timestamp, block.number);
  }

  function releaseAllocationByPercent(uint percent, address receivedAddress, uint256 totalAllocation, uint256 allocationRemaining) internal {
    uint256 amount = (totalAllocation * percent) / 100;
    balances[receivedAddress] = balances[receivedAddress] + amount;
    allocationRemaining = allocationRemaining - amount;
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