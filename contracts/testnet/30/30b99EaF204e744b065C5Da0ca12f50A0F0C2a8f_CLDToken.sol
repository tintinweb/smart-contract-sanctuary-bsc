// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./IBEP20.sol";

contract CLDToken is IBEP20 {
  address owner;
  uint public totalSupply;
  mapping(address => uint) public override balanceOf;
  mapping(address => mapping(address => uint)) public override allowance;
  string public name = "LDC Token";
  string public symbol = "LDCToken";
  uint8 public decimals = 18;
  address devWallet;
  bool frozen = false;
  mapping(address => bool) frozenWallets;
  bool isTEGReady = false;
  uint constant devAllocation = 1000000;


  constructor() public{
    owner = msg.sender;
  }

  //  A2: setup owner validation
  modifier ownerOnly () {
    require(msg.sender == owner);
    _;
  }
  //  A2: setup dev validation
  modifier devOnly () {
    require(msg.sender == owner);
    _;
  }

  // Only allow active wallet to work
  modifier activeWalletOnly () {
    require(frozenWallets[msg.sender], 'This address has been frozen.');
    _;
  }

  function transfer(address recipient, uint amount) activeWalletOnly external override returns (bool) {
    // Validate frozen status
    require(frozen == true, 'Tokens are frozen.');

    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }

  function transferFrom(
    address sender,
    address recipient,
    uint amount
  ) activeWalletOnly external override returns (bool) {
    require(frozen == true, 'Tokens are frozen.');
    allowance[sender][msg.sender] -= amount;
    balanceOf[sender] -= amount;
    balanceOf[recipient] += amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }

  //  A2: Admin can mint new token
  function mint(uint amount) ownerOnly external {
    require(frozen == true, 'Tokens are frozen.');
    balanceOf[msg.sender] += amount;
    totalSupply += amount;
    emit Transfer(address(0), msg.sender, amount);
  }

  //  A2: Burn token, when burn totalSupply is decrease
  function burn(uint amount) ownerOnly external {
    require(frozen == true, 'Tokens are frozen.');
    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;
    emit Transfer(msg.sender, address(0), amount);
  }

  //  A2: Admin can setup new dev address
  function updateDevAccount (address newAddress) ownerOnly public {
    devWallet = newAddress;
  }

  //  A2: Freeze a certain wallet
  function freezeWallet (address frozenWallet) ownerOnly public {
    frozenWallets[frozenWallet] = true;
  }
  // A2: Unfreeze a certain wallet
  function unFreezeWallet (address activeWallet) ownerOnly public {
    frozenWallets[activeWallet] = false;
  }

  function beginTokenEventGeneration () ownerOnly public {
    isTEGReady = true;
  }

  function releaseDevAllocation () devOnly public {
    require(devWallet != address(0), 'Dev wallet was not setup.');
    require(isTEGReady, 'The TEG is not ready');
    // First time allocation: 10%
    this.transfer(devWallet, devAllocation * 1 / 10);
    // Setup
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