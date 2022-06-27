// SPDX-License-Identifier: UNLICENSED

import "./interfaces/IERC20.sol";

pragma solidity >=0.8.6;

contract Presale {
  address public owner;

  address public presaleToken;
  uint256 public price; // How much Token the address gets for 1 Bnb (only 2 decimals included)
  uint256 public minClaim; // In wei

  uint256 public minBuyBnb; // In wei
  uint256 public maxBuyBnb; // In wei
  uint256 public startDateClaim; // Timestamp
  uint256 public maxPurchase; // In wei (Max amount of Bnb he can spend)

  bool public isBuyPaused = false; // Buy is avaialable from the start
  bool public isClaimPaused = true; // Claiming is not available, would be started later
  bool public isEnded = false; // This ends both buying and claiming

  bool public isMainSalePhase = false;
  bool public isClaimPhase = false;

  uint256 public totalBought; // total bought Bnb in wei
  mapping(address => uint256) public bought; // Bnb spent by account
  mapping(address => uint256) public totalClaimToken;

  mapping(address => address) public migratedWallet; // If the address is migrated, the value will be the new address

  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can access this function");
    _;
  }

  constructor(
    address _presaleToken,
    uint256 _price,
    uint256 _minBuyBnb,
    uint256 _maxBuyBnb,
    uint256 _minClaim,
    uint256 _maxPurchase
  ) {
    owner = msg.sender;

    presaleToken = _presaleToken;
    price = _price;
    minBuyBnb = _minBuyBnb;
    maxBuyBnb = _maxBuyBnb;
    minClaim = _minClaim;
    maxPurchase = _maxPurchase;
  }

  //////////
  // Getters
  function calculateBnbToPresaleToken(uint256 _amount) public view returns (uint256) {
    require(presaleToken != address(0), "Presale token not set");

    uint256 tokens = ((_amount * price) / 100) / (10**(18 - uint256(IERC20(presaleToken).decimals())));
    return tokens;
  }

  function getAvailableTokenToClaim(address _address) public view returns (uint256) {
    uint256 totalToken = calculateBnbToPresaleToken(bought[_address]);
    return totalToken - totalClaimToken[_address];
  }

  /////////////
  // Buy tokens

  receive() external payable {
    buy();
  }

  function buy() public payable {
    require(!isEnded, "Sale has ended");
    require(isMainSalePhase, "Sale is not in the right phase");
    require(!isBuyPaused, "Buying is paused");
    require(bought[msg.sender] + msg.value <= maxPurchase, "Cannot buy more than max purchase amount");
    require(msg.value >= minBuyBnb, "Value is less than minBuyBnb");
    require(msg.value <= maxBuyBnb, "Value is great than maxBuyBnb");

    totalBought += msg.value;
    bought[msg.sender] = bought[msg.sender] + msg.value;
  }

  function claim(uint256 requestedAmount) public {
    require(!isEnded, "Sale has ended");
    require(block.timestamp > startDateClaim, "Claim hasn't started yet");
    require(!isClaimPaused, "Claiming is paused");
    require(isClaimPhase, "Claim is not in the right phase");
    require(requestedAmount >= minClaim, "Value is less than minClaim");
    require(presaleToken != address(0), "Presale token not set");

    uint256 remainingToken = calculateBnbToPresaleToken(bought[msg.sender]) - totalClaimToken[msg.sender];
    require(remainingToken >= requestedAmount, "User don't have enough token to claim");

    require(
      IERC20(presaleToken).balanceOf(address(this)) >= requestedAmount,
      "Contract doesn't have enough presale tokens. Please contact owner to add more supply"
    );
    require(
      (requestedAmount <= getAvailableTokenToClaim(msg.sender)),
      "User claim more than max claim amount in this interval"
    );

    totalClaimToken[msg.sender] += requestedAmount;

    IERC20(presaleToken).transfer(msg.sender, requestedAmount);
  }

  //////////////////
  // Owner functions

  function enterMainSalePhase() external onlyOwner {
    isMainSalePhase = true;
    isClaimPhase = false;

    isBuyPaused = false;
    isClaimPaused = true;
  }

  function enterClaimPhase() external onlyOwner {
    require(presaleToken != address(0), "Presale token not set");
    isMainSalePhase = false;
    isClaimPhase = true;

    isBuyPaused = true;
    isClaimPaused = false;
    startDateClaim = block.timestamp;
  }

  function setOwner(address _owner) external onlyOwner {
    owner = _owner;
  }

  function withdrawBnb(uint256 _amount, address _receiver) external onlyOwner {
    payable(_receiver).transfer(_amount);
  }

  function setPresaleToken(address _presaleToken, address _receiver) external onlyOwner {
    if (presaleToken != address(0)) {
      uint256 contractBal = IERC20(presaleToken).balanceOf(address(this));
      if (contractBal > 0) IERC20(presaleToken).transfer(_receiver, contractBal);
    }

    presaleToken = _presaleToken;
  }

  function setStartDateClaim(uint256 _startDateClaim) external onlyOwner {
    startDateClaim = _startDateClaim;
  }

  function setPrice(uint256 _price) external onlyOwner {
    price = _price;
  }

  function setMaxPurchase(uint256 _maxPurchase) external onlyOwner {
    maxPurchase = _maxPurchase;
  }

  function setMinBuyBnb(uint256 _minBuyBnb) external onlyOwner {
    minBuyBnb = _minBuyBnb;
  }

  function setMaxBuyBnb(uint256 _maxBuyBnb) external onlyOwner {
    maxBuyBnb = _maxBuyBnb;
  }

  function toggleIsBuyPaused() external onlyOwner {
    isBuyPaused = !isBuyPaused;
  }

  function setMinClaim(uint256 _minClaim) external onlyOwner {
    minClaim = _minClaim;
  }

  function toggleIsClaimPaused() external onlyOwner {
    if (isClaimPaused) {
      require(presaleToken != address(0), "Presale token not set");
    }
    isClaimPaused = !isClaimPaused;
  }

  function endSale(address _receiver) external onlyOwner {
    require(presaleToken != address(0), "Presale token not set");

    isEnded = true;
    isBuyPaused = true;
    isClaimPaused = true;
    isMainSalePhase = false;
    isClaimPhase = false;

    uint256 contractBal = IERC20(presaleToken).balanceOf(address(this));
    if (contractBal > 0) IERC20(presaleToken).transfer(_receiver, contractBal);
  }

  function migrateWallet(address _previous, address _new) external onlyOwner {
    require(migratedWallet[_previous] == address(0), "You have already done migration with these wallets");

    migratedWallet[_previous] = _new;
    bought[_new] += bought[_previous];
    totalClaimToken[_new] += totalClaimToken[_previous];
    delete bought[_previous];
    delete totalClaimToken[_previous];
  }
}

//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0;

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
}