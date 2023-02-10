/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: GPLv3

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

}

interface IToken {
  function mint(address to, uint amount) external;
  function burn(address owner, uint amount) external;
  function transferOwnership(address  _newOwner) external;

}

contract BridgeBase {
  
  address public admin;
  IToken public token;
  
  uint public ethNonce;
  uint public bscNonce;
  uint public maticNonce;
  uint public avaxNonce;

  uint256 public fee;
  uint256 public swapLimit;

  mapping(uint => bool) public processedNoncesEth;
  mapping(uint => bool) public processedNoncesBsc;
  mapping(uint => bool) public processedNoncesMatic;
  mapping(uint => bool) public processedNoncesAvax;

  mapping(uint => bool) public networks;
  
  enum Step { Burn, Mint }

  event Transfer(
    address from,
    address to,
    uint amount,
    uint fee,
    uint date,
    uint nonce,
    uint network,
    Step indexed step
  );

  constructor(address _token) {
    admin = msg.sender;
    token = IToken(_token);
    fee = 3300000000000000;
    swapLimit = 50000 * 10e10;
    networks[43114] = true; //avax 43113 testnet --------- 43114 Mainnet
    networks[137] = true; // matic 80001 testnet -------- 137 Mainnet
    networks[1] = true; // eth goerli 5 testnet -------- 1 Mainnet
    networks[56] = true; // binance 97 testnet --------56 Mainnet
  }

  
  function burn(address to, uint amount, uint network) external payable {
    require(networks[network]==true, "unregistered network");
    require(msg.value == fee, "amount is less than fee");
    require(amount <= swapLimit, "swap limit exceeded");

    token.burn(msg.sender, amount);
    
    uint nonce;
    
    if (network == 1) {
      ethNonce++;
      nonce = ethNonce; 
    } else if (network == 56) {
      bscNonce++;
      nonce = bscNonce; 
    } else if (network == 137) {
      maticNonce++;
      nonce = maticNonce; 
    }else if (network == 43114) {
      avaxNonce++;
      nonce = avaxNonce; 
    }

    emit Transfer(
      msg.sender,
      to,
      amount,
      fee,
      block.timestamp,
      nonce,
      network,
      Step.Burn
    );
  
  }

  function mint(address to, uint amount, uint otherChainNonce, uint network) external {
    require(msg.sender == admin, "only admin");
    require(networks[network]==true, "unregistered network");
    require(amount <= swapLimit, "swap limit exceeded");

    if (network == 1) {
      require(processedNoncesEth[otherChainNonce] == false, "transfer already processed");
      processedNoncesEth[otherChainNonce] = true;
    } else if (network == 56) {
      require(processedNoncesBsc[otherChainNonce] == false, "transfer already processed");
      processedNoncesBsc[otherChainNonce] = true;
    } else if (network == 137) {
      require(processedNoncesMatic[otherChainNonce] == false, "transfer already processed");
      processedNoncesMatic[otherChainNonce] = true;
    }else if (network == 43114) {
      require(processedNoncesAvax[otherChainNonce] == false, "transfer already processed");
      processedNoncesAvax[otherChainNonce] = true;
    }


    token.mint(to,amount);
    
    emit Transfer(
      msg.sender,
      to,
      amount,
      fee,
      block.timestamp,
      otherChainNonce,
      network,
      Step.Mint
    );
  }

  function setNewToken(address _token) external {
    require(msg.sender == admin, "only admin");
    token = IToken(_token);
  }

  function addNewNetwork(uint _network) external {
    require(msg.sender == admin, "only admin");
    require(networks[_network]==false, "registered network");
    networks[_network] = true;
  }

  function setFee(uint _fee) external {
    require(msg.sender == admin, "only admin");
    fee = _fee;
  }

   function setSwapLimit(uint _swapLimit) external {
    require(msg.sender == admin, "only admin");
    swapLimit = _swapLimit;
  }

  function setNewOwnerOfToken(address _tokenOwner) external {
    require(msg.sender == admin, "only admin");
    token.transferOwnership(_tokenOwner);
  }

}