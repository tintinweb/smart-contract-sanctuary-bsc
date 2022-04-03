//SPDX-License-Identifier:MIT
pragma solidity ^0.8.1;
import "./IERC20.sol";
import "./ReentrancyGuard.sol";

contract IDOBase is ReentrancyGuard {
  address payable public factoryAddress;
  address payable public teamAddress;

  IERC20 public token;
  uint256 public maxInvestInWei;
  uint256 public minInvestInWei;
  uint8 public decimals;
  address payable public IDOCreator;
  uint256 public tokenPriceInWei;
  uint256 public totalCollectedWei;
  uint256 public totalInvestors;
  uint256 public totalTokens;
  uint256 public tokensLeft;
  uint256 public openTime;
  uint256 public closeTime;
  uint256 public listingPriceInWei;
  uint256 public hardCapInWei; // maximum wei amount that can be invested in presale
  uint256 public softCapInWei; // minimum wei amount to invest in presale, if not met, invested wei will be returned
  bytes32 public saleTitle;
  bytes32 public linkTelegram;
  bytes32 public linkTwitter;
  bytes32 public linkDiscord;
  bytes32 public linkWebsite;
  uint256 public reservedTokens;
  bool public active = true;
  bool public ready;
  uint256 public idoId;
  bool refundOpen;
  bool approved;
  address[] allInvestors;
  mapping(address => uint256) weiInvestments;
  mapping(address => bool) whitelistedAddresses;
  mapping(address => bool) claimed;

  constructor(address _factoryAddress, address _teamAddress) {
    require(
      _factoryAddress != address(0) && _teamAddress != address(0),
      "args cannot be address 0"
    );
    factoryAddress = payable(_factoryAddress);
    teamAddress = payable(_teamAddress);
  }

  modifier onlyDevOrFactory() {
    require(
      msg.sender == factoryAddress || msg.sender == teamAddress,
      "Not Factory or Dev"
    );
    _;
  }

  modifier onlyDev() {
    require(msg.sender == teamAddress, "Not Dev");
    _;
  }

  modifier onlyFactory() {
    require(msg.sender == factoryAddress, "Not Factory");
    _;
  }

  modifier onlyIDOCreator() {
    require(msg.sender == IDOCreator, "Not IDOCreator");
    _;
  }
  modifier onlyIDOCreatorOrFactory() {
    require(
      msg.sender == IDOCreator || msg.sender == factoryAddress,
      "Not IDOCreator or Factory"
    );
    _;
  }

  modifier refundIsOpen() {
    require(refundOpen, "IDO is not open for refund");
    _;
  }
  modifier isWhitelisted() {
    require(whitelistedAddresses[msg.sender], "Address not whitelisted");
    _;
  }
  modifier IdoActive() {
    require(active, "IDO not active");
    _;
  }

  modifier investorOnly() {
    require(weiInvestments[msg.sender] > 0, "Not an investor");
    _;
  }

  modifier notClaimedOrRefunded() {
    require(!claimed[msg.sender], "Already claimed or refunded");

    _;
  }

  modifier readyForClaim() {
    require(ready, "IDO not ready for claim yet");
    _;
  }

  function setAddresses(address _IdoCreator, address _tokenAddress)
    external
    onlyFactory
  {
    require(_IdoCreator != address(0) && _tokenAddress != address(0));
    IDOCreator = payable(_IdoCreator);
    token = IERC20(_tokenAddress);
  }

  struct Investors {
    address investor;
    uint256 tokensToCollect;
  }

  function setGeneralInfo(
    uint256 _totalTokens,
    uint256 _tokenPriceInWei,
    uint256 _hardCapInWei,
    uint256 _softCapInWei,
    uint256 _maxInvestInWei,
    uint256 _minInvestInWei,
    uint256 _openTime,
    uint256 _closeTime,
    uint8 _decimals
  ) external onlyFactory {
    require(_totalTokens > 0);
    require(_tokenPriceInWei > 0);
    require(_openTime > 0);
    require(_closeTime > 0);
    require(_hardCapInWei > 0);
    require(_hardCapInWei <= _totalTokens * _tokenPriceInWei);
    require(_softCapInWei <= _hardCapInWei);
    require(_minInvestInWei <= _maxInvestInWei);
    require(_openTime < _closeTime);
    totalTokens = _totalTokens;
    tokensLeft = _totalTokens;
    tokenPriceInWei = _tokenPriceInWei;
    hardCapInWei = _hardCapInWei;
    softCapInWei = _softCapInWei;
    maxInvestInWei = _maxInvestInWei;
    minInvestInWei = _minInvestInWei;
    openTime = _openTime;
    closeTime = _closeTime;
    decimals = _decimals;
  }

  function setStringInfo(
    bytes32 _saleTitle,
    bytes32 _linkTelegram,
    bytes32 _linkDiscord,
    bytes32 _linkTwitter,
    bytes32 _linkWebsite
  ) external onlyIDOCreatorOrFactory {
    saleTitle = _saleTitle;
    linkTelegram = _linkTelegram;
    linkDiscord = _linkDiscord;
    linkTwitter = _linkTwitter;
    linkWebsite = _linkWebsite;
  }

  function setIdoInfo(uint256 _idoId) external onlyFactory {
    idoId = _idoId;
  }

  function addwhitelistedAddresses(address[] calldata _toWhitelist)
    external
    onlyIDOCreatorOrFactory
  {
    require(_toWhitelist.length > 0);
    for (uint256 i = 0; i < _toWhitelist.length; i++) {
      whitelistedAddresses[_toWhitelist[i]] = true;
    }
  }

  function approveForTokenTransfer() public onlyDev {
    approved = true;
  }

  function getTokenAmount(uint256 _weiAmount)
    internal
    view
    returns (uint256 _tokens)
  {
    _tokens = (_weiAmount * (10**decimals)) / tokenPriceInWei;
  }

  function openForRefund() public onlyDev {
    require(
      totalCollectedWei < hardCapInWei,
      "Hard cap reached,No need to refund"
    );
    refundOpen = true;
  }

  function invest() public payable nonReentrant isWhitelisted IdoActive {
    require(block.timestamp >= openTime, "Not yet open for investments");
    require(block.timestamp < closeTime, "Closed");
    require(totalCollectedWei < hardCapInWei, "Hard cap reached");
    require(tokensLeft > 0, "No more tokens to sell");
    require(getTokenAmount(msg.value) <= tokensLeft, "Not much tokens left");
    uint256 totalInvestmentInWei = weiInvestments[msg.sender] + msg.value;
    require(
      totalInvestmentInWei >= minInvestInWei ||
        totalCollectedWei >= hardCapInWei,
      "Minimum investments not reached"
    );
    require(
      maxInvestInWei == 0 || totalInvestmentInWei <= maxInvestInWei,
      "Max investment reached"
    );
    if (weiInvestments[msg.sender] == 0) {
      totalInvestors++;
      allInvestors.push(msg.sender);
    }

    totalCollectedWei += msg.value;
    reservedTokens += getTokenAmount(msg.value);
    weiInvestments[msg.sender] = totalInvestmentInWei;
    tokensLeft -= getTokenAmount(msg.value);
    if (tokensLeft == 0) {
      ready = true;
    }
  }

  receive() external payable {
    invest();
  }

  function claimTokens()
    external
    isWhitelisted
    IdoActive
    investorOnly
    notClaimedOrRefunded
    readyForClaim
    nonReentrant
  {
    claimed[msg.sender] = true;
    require(
      token.transfer(msg.sender, getTokenAmount(weiInvestments[msg.sender]))
    );
  }

  function set() external onlyIDOCreator {
    require(totalCollectedWei >= softCapInWei, "Minimum target not reached");
    ready = true;
  }

  function getRefund()
    external
    isWhitelisted
    investorOnly
    refundIsOpen
    notClaimedOrRefunded
    nonReentrant
  {
    if (active) {
      require(block.timestamp >= openTime, "Not yet opened");
      require(block.timestamp >= closeTime, "Not yet closed");
      require(softCapInWei > 0, "No soft cap");
      require(totalCollectedWei < softCapInWei, "Soft cap reached");
      require(!ready, "IDO already reached minimum target");
    }
    claimed[msg.sender] = true;
    uint256 investment = weiInvestments[msg.sender];
    uint256 IdoBalance = address(this).balance;
    require(IdoBalance > 0);
    if (investment > 0) {
      payable(msg.sender).transfer(investment);
    }
  }

  function cancelAndTransferTokensToIdoCreator() external IdoActive {
    if (teamAddress != msg.sender) {
      revert("Cannot cancel, Insufficient Permissions or target reached");
    }
    active = false;

    uint256 balance = token.balanceOf(address(this));
    if (balance > 0) {
      token.transfer(IDOCreator, balance);
    }
  }

  function collectFundsRaised()
    external
    onlyIDOCreator
    IdoActive
    readyForClaim
  {
    if (address(this).balance > 0) {
      IDOCreator.transfer(address(this).balance);
    }
  }

  function transferOutRemainingTokens() public onlyIDOCreator {
    require(approved, "Seek approval from admin");
    if (totalTokens - reservedTokens > 0) {
      require(IERC20(token).transfer(msg.sender, totalTokens - reservedTokens));
    }
  }

  function changeDeadline(uint256 _newDeadline)
    public
    onlyIDOCreator
    IdoActive
  {
    require(
      _newDeadline > block.timestamp,
      "New Deadline must be greater than the current time"
    );
    closeTime = _newDeadline;
  }

  function changeSoftCap(uint256 _newSoftCap) public onlyIDOCreator IdoActive {
    require(_newSoftCap > 0);
    softCapInWei = _newSoftCap;
  }

  function changeHardCap(uint256 _newHardCap) public onlyIDOCreator IdoActive {
    require(_newHardCap > 0);
    hardCapInWei = _newHardCap;
  }

  function getInvestors() public view returns (Investors[] memory inv) {
    inv = new Investors[](allInvestors.length);
    for (uint256 i; i < allInvestors.length; i++) {
      inv[i].investor = allInvestors[i];
      inv[i].tokensToCollect = getTokenAmount(weiInvestments[allInvestors[i]]);
    }
  }
}