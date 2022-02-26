// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./externalSwapPair.sol";
import "./externalFunctions.sol";

contract AdventureBox is BEP20Burnable, Ownable{
  using SafeMath for uint256;
  using Address for address;

  modifier isPausable() {
    require(!_pause, "The Contract is paused. Presale is paused");
    _;
  }

  address private burn_Address = 0x0000000000000000000000000000000000000000;
  address private bnb_Address;
  address private busd_Address;
  address private factory_address;
  address payable _withOwner_Address;

  bool _pause = false;
  uint private _boxId;
  uint private _tokensId;
  uint256 private _MAX = ~uint256(0);
  uint256 private _GRANULARITY = 100;
  uint256 private _DECIMALFACTOR = 10 ** uint256(18);

  constructor (
    address tokenOwner,
    address wBNBAddress,
    address busdAddress,
    address factAddress
    ){
    _owner = tokenOwner;
    bnb_Address = wBNBAddress;
    busd_Address = busdAddress;
    factory_address = factAddress;
  }

  /*
  * @dev Sitem of Receive/create/update
  * @param token, amount, boxType
  */
  function buyBoxWithToken(string memory tokenName, address tokenAddress, uint256 boxQuant, uint256 boxPrice, string memory boxName) public isPausable() {
    require(boxQuant > 0, "You need to say how many boxes you want");
    require(tokenAddress != burn_Address, "We do not accept this token");
    require(tokenAddress.isContract(), "We do not accept this token");
    uint256 price = 0;

    uint256 amount = boxQuant.mul(boxPrice);
    if(_compareString(tokenName, "BUSD") || _compareString(tokenName, "USDT")){
      price =  amount;
    }else{
      price = getPriceToken(tokenAddress, amount);
    }

    IBEP20 ContractAdd = IBEP20(tokenAddress);
    uint256 dexBalance = ContractAdd.balanceOf(msg.sender);
    require(price > 0 && price <= dexBalance, "Insufficient amount for this transaction");
    uint256 value = price.mul(_DECIMALFACTOR);
    require(ContractAdd.transferFrom(msg.sender, address(this), value), "A transaction error has occurred. Check for approval.");

    emit Received(msg.sender, price, boxQuant, boxName, tokenName);
  }

  function buyBoxWithBNB(uint256 boxQuant, uint256 boxPrice, string memory boxName) public payable {
    require(boxQuant > 0, "You need to say how many boxes you want");
    uint256 BoxVal = boxQuant.mul(boxPrice);
    uint256 amount = getpriceBNB(BoxVal);
    require(amount > 0 && msg.value >= amount, "Insufficient amount for this transaction");

    emit Received(msg.sender, BoxVal, boxQuant, boxName, "BNB");
  }

  /*
  * @dev gets the price of BNB per BUSD.
  */
  function getPriceToken(address tokenAddress, uint256 amount) public view virtual returns (uint256) {
    address tokenPairAddress = IUniswapV2Factory(factory_address).getPair(tokenAddress, busd_Address);
    require(tokenPairAddress != address(0), "We do not accept this token");
    IUniswapV2Pair _tokenPair = IUniswapV2Pair(tokenPairAddress);
    if(busd_Address == _tokenPair.token0()){
      (uint256 ResBUSD, uint256 ResToken,) = _tokenPair.getReserves();
      uint256 pricebnb = ResBUSD.div(ResToken);
      return (amount.mul(_DECIMALFACTOR)).div(pricebnb); // return amount of Tokens needed to buy Box
    }else{
      (uint256 ResToken,uint256 ResBUSD,) = _tokenPair.getReserves();
      uint256 pricebnb = ResBUSD.div(ResToken);
      return (amount.mul(_DECIMALFACTOR)).div(pricebnb); // return amount of BNB needed to buy Box
    }
  }

  /*
  * @dev gets the price of BNB per BUSD.
  */
  function getpriceBNB(uint256 amount) public view virtual returns (uint256) {
    address tokenPairAddress = IUniswapV2Factory(factory_address).getPair(bnb_Address, busd_Address);
    require(tokenPairAddress != address(0), "We do not accept this token");
    IUniswapV2Pair _tokenPair = IUniswapV2Pair(tokenPairAddress);
    if(bnb_Address == _tokenPair.token0()){
      (uint256 ResBNB,uint256 ResBUSD,) = _tokenPair.getReserves();
      uint256 pricebnb = ResBUSD.div(ResBNB);
      return (amount.mul(_DECIMALFACTOR)).div(pricebnb); // return amount of BNB needed to buy Box
    }else{
      (uint256 ResBUSD, uint256 ResBNB,) = _tokenPair.getReserves();
      uint256 pricebnb = ResBUSD.div(ResBNB);
      return (amount.mul(_DECIMALFACTOR)).div(pricebnb); // return amount of BNB needed to buy Box
    }
  }

  /*
  * @dev Update the bnb busd pair token
  * @param addr of the token address
  */
  function setBnbAdress(address addr) external virtual onlyOwner {
    require(addr.isContract(), "The address entered is not valid");
    bnb_Address = addr;
  }

  /*
  * @dev Update the bnb busd pair token
  * @param addr of the token address
  */
  function setBusdAdress(address addr) external virtual onlyOwner {
    require(addr.isContract(), "The address entered is not valid");
    busd_Address = addr;
  }

  function ContractStatusPause() public view returns (bool) {
    return _pause;
  }

  function setWithAdress(address payable ownerAddress) public onlyOwner() {
    _withOwner_Address = ownerAddress;
  }

  function withdrawAddress() public view returns (address) {
    return _withOwner_Address;
  }

  function withdTokens(address contractAddress) public onlyOwner(){
    require(_withOwner_Address != address(0), "To make the withdrawal, you need to register a valid address.");
      IBEP20 ContractAdd = IBEP20(contractAddress);
      uint256 dexBalance = ContractAdd.balanceOf(address(this));
      ContractAdd.transfer(_withOwner_Address, dexBalance);
  }

  function withdBalance() public onlyOwner(){
    require(_withOwner_Address != address(0), "To make the withdrawal, you need to register a valid address.");
    require(this.totalBalance() > 0, "You do not have enough balance for this withdrawal");
    _withOwner_Address.transfer(this.totalBalance());
  }

  function totalBalance() external view returns(uint256) {
    return payable(address(this)).balance;
  }
  function _compareString(string memory s1, string memory s2) private pure returns (bool) {
    return (keccak256(bytes(s1)) == keccak256(bytes(s2)));
  }

  function setPause() public onlyOwner() {
    if(_pause){
      _pause = false;
    }else{
      _pause = true;
    }
  }

  event Received(address indexed from, uint256 amount, uint256 boxQuant, string boxName, string token);
}