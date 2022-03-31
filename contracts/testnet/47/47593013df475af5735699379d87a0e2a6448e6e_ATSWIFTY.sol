/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

pragma solidity 0.8.7;
// SPDX-License-Identifier: Unlicensed
// Developer: Cathal Mac Fadden
// [email protected]
// All code is copyrighted and cannot be used unless permission is authorized. Contact me on the email above. 
//  _______ _______          _______ ______ _________     __
// |__   __/ ____\ \        / /_   _|  ____|__   __\ \   / /
//    | | | (___  \ \  /\  / /  | | | |__     | |   \ \_/ / 
//    | |  \___ \  \ \/  \/ /   | | |  __|    | |    \   /  
//    | |  ____) |  \  /\  /   _| |_| |       | |     | |   
//    |_| |_____/    \/  \/   |_____|_|       |_|     |_|   
//


contract Context {
  constructor () { }
  function _msgSender() internal view returns (address payable) {
    return payable(msg.sender);
  }
  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function isContractAddress(address addr) internal view returns(bool) {
    return addr.code.length != 0;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner() {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

interface IBEP20 {

  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address addr) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ATSWIFTY is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  mapping (address => uint256) private _lastAccrueDate; 
  mapping (address => uint256) private _lastSellDate;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  mapping (address => bool) private _isExcludedFromInterest;
  mapping (address => bool) private _isExcludedFromTax;
  mapping (address => uint256) private _accruedInterest;
  mapping (address => uint256) private _interestRates;
  mapping (address => uint256) private _previousInterestRate;
  mapping (address => uint256) private _dateAddressLocked;

  mapping (address => bool) public BlockedAddresses;    // Addresses that are prevented from Buying tokens. (we dont prevent selling). Used for stopping frontrunning bots. 
  mapping (address => bool) public LockedLPTokens;    // LP Tokens which are locked into the contract until the expiry date. 
  uint256 public LPUnlockDate;  // The date when any LockedLPTokens can be withdrawn. 
  address public LockedTeamFundsAddress;    // Team funds are locked into an address that is permanently prevented from selling its initial allocation. Team can only earn interest.
  uint256 public LockedTeamFundsBalance;    // The amount of team funds that cannot be spent. 

  uint256 public MinutesBeforeInterest = 28 * 24 * 60;   // Representing as minutes to make testing easier. 28 days in production.
  address payable public TaxStorageDestination;

  uint256 private _standardInterestRate = 12;   // The standard base rate that everyone gets.
  uint256 private _newAddressInterestRate = 20;   // A bonus rate that new addresses will receive until they sell.
  uint256 private _unlockFeePercentage = 20;
  bool private _allowSettingBonusRateAddresses = true;
  uint256 private _yearInMinutes = 366 * 24 * 60;
  bool private _claimingExternally = false;
  uint256 private _lockMultiplier = 6;

  address payable private _burnAddress = payable(0x000000000000000000000000000000000000dEaD); // Burn address used to burn a portion of tokens
  address payable private _testPancakeswapContract;
  address payable private _productionPancakeswapContract;
  address payable private _pancakeswapRouterContract;

  uint8 private _devPercentage = 1;
  uint8 private _liquidityPercentage = 1; 
  uint8 private _burnPercentage = 1;
  uint256 private _totalSupply;
  uint8 private constant _decimals = 18;
  string private constant _symbol = "TSWIFTY";
  string private _name = _symbol;
  uint256 private constant _billion = 1000000000;
  uint256 private _decimalPointsCalc = 10 ** uint256(_decimals);
  
  address TestnetRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

  IUniswapV2Router02 private _pancakeswapV2Router; // The address of the PancakeSwap V2 Router

  bool currentlySwapping;  

  event Claim(address indexed claimAddress, uint256 interestClaimed);
  event ExternalClaim(address indexed claimAddress, address indexed destinationAddress, uint256 interestClaimed);
  event SwapAndLiquify(uint256 tokensSwapped, uint256 bnbReceived, uint256 tokensIntoLiqudity);
  event AddressLocked(address indexed lockAddress, uint256 unlockDate, uint256 bonusInterestRate);
  event PaidToUnlockAddress(address indexed unlockedAddress, uint256 feePaid);
  event BonusRatesIssued(address[] indexed bonusAddresses, uint256 percentage);
  event TeamFundsAddressChanged(address indexed oldTeamFundsAddress, address indexed newTeamFundsAddress);
  event LPUnlockDateIncreased(uint256 oldDate, uint256 newDate);

  constructor(address teamFundsAddress) payable {

    LockedTeamFundsAddress = teamFundsAddress;
    _totalSupply = 10 * _billion * _decimalPointsCalc;

    uint256 TokensForLiquidity = (_totalSupply * 75) / 100; // 75% for sale and liquidity.
    _balances[owner()] += TokensForLiquidity;
    emit Transfer(address(0), owner(), TokensForLiquidity);   // Dist #1

    uint256 TokensForAirdrop = _totalSupply / 200;  // 0.5% for airdrop
    _balances[owner()] += TokensForAirdrop;
    emit Transfer(address(0), owner(), TokensForAirdrop);           // Dist #2

    uint256 TokensForSwiftDemandDistribution = (_totalSupply * 15) / 100;   // 15% for Swiftdemand conversion
    _balances[owner()] += TokensForSwiftDemandDistribution;
    emit Transfer(address(0), owner(), TokensForSwiftDemandDistribution);   // Dist #3
    
    uint256 TokensForTeam = (_totalSupply * 95) / 1000;    // 9.5% Locked team funds. Team can only spend the interest earned. 
    LockedTeamFundsBalance = TokensForTeam;
    _balances[LockedTeamFundsAddress] += TokensForTeam;
    accrueInterest(LockedTeamFundsAddress, false);
    emit Transfer(address(0), LockedTeamFundsAddress, TokensForTeam);          // Dist #4
  
    _isExcludedFromInterest[owner()] = true;
    _isExcludedFromTax[owner()] = true;
    _isExcludedFromTax[LockedTeamFundsAddress] = true;
    _isExcludedFromTax[address(this)] = true;
    _isExcludedFromTax[address(0x0000000000000000000000000000000000000000)] = true;

    TaxStorageDestination = payable(owner());
    _testPancakeswapContract = payable(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    _productionPancakeswapContract = payable(0x10ED43C718714eb63d5aA57B78B54704E256024E);
  }

  receive() external payable {}
  fallback() external payable {}

  // Used to block certain addresses from buying. Like frontrunning bots. We never prevent anyone from selling.
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(BlockedAddresses[recipient] == false, "Recipient address has been blocked. They cannot buy. Contact dev's if you think this is a mistake");
    
    if(sender == LockedTeamFundsAddress)
    {
      require(_balances[LockedTeamFundsAddress].sub(amount) >= LockedTeamFundsBalance, "Cannot reduce balance below the locked team funds balance");
    }

    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");

    if(!_claimingExternally && whenWillAddressUnlock(sender)  > block.timestamp)
    {
      revert("Transaction reverted because the address has been locked by the address owner.");
    }

    uint256 taxAmount;

    if(!currentlySwapping)
    {
      if(!_claimingExternally)  // If they are claiming externally then we dont want to accrue again, and we dont want to consider it a sale. 
        accrueInterest(sender, true);

      accrueInterest(recipient, false);

      if(_isExcludedFromTax[sender] || sender == TaxStorageDestination || recipient == TaxStorageDestination)
      {
        taxAmount = 0;
      }
      else
      {
        taxAmount = handleTaxes(sender, amount);
      }

      amount = amount.sub(taxAmount);
    }

    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  // Blocked addresses cannot buy. I want to be able to stop frontrunning bots from buying. We dont stop selling EVER.
  function setBlockedAddressStatus(address addr, bool isBlocked) external onlyOwner {
    BlockedAddresses[addr] = isBlocked;
  }

  // Used to maintain the safety of the team funds address. If for any reason we need to move the team funds to a new wallet we can use this.
  // Contract owner has control, not the Team Funds Address. 
  function transferTeamFundsToNewAddress(address newTeamFundsAddress) external onlyOwner {
    require(newTeamFundsAddress != address(0), "Cannot be zero address.");
    require(!isContractAddress(newTeamFundsAddress), "Cannot transfer to contract.");

    uint256 currentTeamFunds = _balances[LockedTeamFundsAddress];
    _balances[LockedTeamFundsAddress] = 0;
    _balances[newTeamFundsAddress] = currentTeamFunds;

    accrueInterest(newTeamFundsAddress, false);   // Perform the initial accrue to setup the address correctly.

    emit Transfer(LockedTeamFundsAddress, newTeamFundsAddress, currentTeamFunds);
    emit TeamFundsAddressChanged(LockedTeamFundsAddress, newTeamFundsAddress);

    LockedTeamFundsAddress = newTeamFundsAddress;
  }



  // This function will lock an address and prevent it from selling any tokens for 6x MinutesBeforeInterest.
  // In exchange for locking your address you can restore your address to immediately earning interest after selling. 
  function lockSalesForBonusInterest() external {

    uint256 unlockDate = whenWillAddressUnlock(msg.sender);
    require(unlockDate < block.timestamp, "Address is already locked.");

    accrueInterest(msg.sender, false);
    _dateAddressLocked[msg.sender] = block.timestamp;
    _previousInterestRate[msg.sender] = _interestRates[msg.sender];   // save the current rate so we can restore it after the address unlocked. 
    _interestRates[msg.sender] = 40;   
    unlockDate = whenWillAddressUnlock(msg.sender);

    emit AddressLocked(msg.sender, unlockDate, _interestRates[msg.sender]);
  }

  // Returns the unix time stamp of when the address will unlock. 
  // If the address is not locked it will return the current block timestamp.
  function whenWillAddressUnlock(address addr) public view returns(uint256) {
      if(_dateAddressLocked[addr] == 0)
        return 0;
      else
        return _dateAddressLocked[addr] + ((MinutesBeforeInterest * 60) * _lockMultiplier);
  }

  function isAddressLocked(address addr) external view returns(bool){
    return (whenWillAddressUnlock(addr) > block.timestamp);
  }

  // If the user has locked their address and they are willing to pay the unlock fee they can allow outbound transfers again.
  // The unlock fee is a percentage of the current balance of the address, not the balance when the address was locked.  
  function payToUnlockAddress() external {
    require(_balances[msg.sender] > 0, "Cannot unlock a zero balance address.");
    require(whenWillAddressUnlock(msg.sender)  > block.timestamp, "Address is not locked.");

    accrueInterest(msg.sender, false);

    uint256 unlockFee = (_balances[msg.sender] * _unlockFeePercentage) / 100; // Unlock fee.

    uint256 burnAmount = unlockFee / 2;
    uint256 taxFee = unlockFee - burnAmount;

    _balances[msg.sender] -= unlockFee;
    _balances[_burnAddress] += burnAmount;
    _balances[TaxStorageDestination] += taxFee;

    _dateAddressLocked[msg.sender] = 0;
    _interestRates[msg.sender] = _interestRates[msg.sender];

    emit Transfer(msg.sender, _burnAddress, burnAmount); 
    emit Transfer(msg.sender, TaxStorageDestination, taxFee); 
    emit PaidToUnlockAddress(msg.sender, unlockFee);
  }


  // Gives the list of addresses a bonus rate which will be revoked if they ever sell even a single token. 
  // This will be used to encourage airdrop and converters to not sell once the trading goes live. 
  function setBonusRateAddresses(address[] calldata addresses, uint256 rate) external onlyOwner() {
   
   if(_allowSettingBonusRateAddresses)
   {
    for (uint i=0; i < addresses.length; i++) {
        _interestRates[addresses[i]] = rate;
    }

    emit BonusRatesIssued(addresses, rate);
   }
  }

  // This function disables the ability to issue new bonus rates. Once the token is stable and initial promotions have been run we should probably disable it. 
  function disableNewBonusRateAddressesPermanently() external onlyOwner() {
     _allowSettingBonusRateAddresses = false;
  }

  function getLastSaleDate(address addr) external view returns(uint256) {
    return _lastSellDate[addr];
  }

  function getAccruedInterest(address addr) external view returns(uint256) {
    return _accruedInterest[addr];
  }

  function getCurrentInterestRateForAddress(address addr) external view returns(uint256) {
    uint256 unlockDate = whenWillAddressUnlock(addr);

    if(_lastSellDate[addr] + (MinutesBeforeInterest * 60) >= block.timestamp)
    {
      return 0;   // The address is still being penalised for making a sale. 
    }
    else if(unlockDate == 0)   // Address was never locked.
    {
      return _interestRates[addr];
    }
    else if(unlockDate != 0 && unlockDate > block.timestamp) // Address is still locked, so it earns the bonus interest currently stored in _interestrates.
    {
      return _interestRates[addr];
    }
    else if (unlockDate != 0 && unlockDate > _lastAccrueDate[addr])   // address has unlocked but no transaction have been performed to update the accrual and change the _interestrates.
    {
      return _previousInterestRate[addr];
    }
    else  // The address has unlocked and transactions have already been performed. 
    {
      return _interestRates[addr];
    }
  }

  // Prevents the supplied address from being charged taxes. 
  // This is necessary for things like airdrops to prevent those values from being taxed. 
  function excludeAddressFromTaxes(address addr) external onlyOwner() {
      _isExcludedFromTax[addr] = true;
  }

  // Specifies that the supplied address should pay taxes. Used to undo a excludeAddressFromTaxes function call. 
  // The default is that all addresses will pay taxes, so we dont need to call this for every address.
  function includeAddressInTaxes(address addr) external onlyOwner() {
    _isExcludedFromTax[addr] = false;
  }

  // Prevents addresses from claiming interest. We exclude contracts, the token owner etc from claiming interest. 
  // This will also be used when the token gets listed on central exchanges. The exchange cant claim interest.
  function excludeAddressFromInterest(address addr) external onlyOwner() {
      _isExcludedFromInterest[addr] = true;
  }

  // Specifies that the supplied address can claim interest. Used to undo a excludeAddressFromInterest function call. 
  // The default is that all the addresses can claim interest (unless its a contract), so we dont need to call this for every address. 
  // Contracts can never claim interest.
  function includeAddressInInterest(address addr) external onlyOwner() {
      _isExcludedFromInterest[addr] = false;
  }

  function enableDefaultPancakeRouter(bool production) public onlyOwner() {

    address contractAddress;

    if(production)
      contractAddress = _productionPancakeswapContract;
    else
      contractAddress = _testPancakeswapContract;

    setPancakeRouterAddress(contractAddress);
  }

  // Sets the router address and creates the trading pair if it doesnt already exist
  function setPancakeRouterAddress(address addr) public onlyOwner() {

    IUniswapV2Router02 newPancakeSwapRouter = IUniswapV2Router02(addr);      
    address newPair = IUniswapV2Factory(newPancakeSwapRouter.factory()).getPair(address(this), newPancakeSwapRouter.WETH());
    if(newPair == address(0)){
      newPair = IUniswapV2Factory(newPancakeSwapRouter.factory()).createPair(address(this), newPancakeSwapRouter.WETH());
      LockedLPTokens[newPair] = true;
      LPUnlockDate = block.timestamp + (1 * 366 * 24 * 60 * 60);  // lock it for 1 year. 
    }
    _pancakeswapV2Router = newPancakeSwapRouter;
  }

  function extendLPUnlockDate(uint256 newUnlockDate) external onlyOwner {

    require(newUnlockDate > LPUnlockDate, "New unlock date must be great than current unlock date");
    emit LPUnlockDateIncreased(LPUnlockDate, newUnlockDate);
    LPUnlockDate = newUnlockDate;
  }

  /// Anybody can call this function to create liquidity. 
  /// If the contract has some tokens then these can be used to generate liquidity.
  /// Half of the tokens are converted to BNB, the other half is paired against the BNB and added to the liquidity pool.
  /// This function is made external so anybody can call it to add the liquidity incase the developer becomes inactive for any reason.
  /// This provides a way for the token community to continue to add more BNB to the liquidity pool from the taxes collected by the contract.
  function generateLiquidityFromContractTokensSupply(uint256 tokenAmount) external returns (bool) {

      currentlySwapping = true;
      require(tokenAmount > 0, "Invalid tokenAmount supplied.");
      require(_balances[address(this)] >= tokenAmount, "The contract does not have a sufficient supply of tokens.");

      uint256 amountToSwap = tokenAmount.div(2);  // The amount to convert to BNB
      uint256 amountToUseForLiquidity = tokenAmount.sub(amountToSwap);   // The amount to pair against the BNB in the liquidity pool

      address[] memory tradingPair = new address[](2);
      tradingPair[0] = address(this); // this contracts tokens
      tradingPair[1] = address(_pancakeswapV2Router.WETH());  // WETH is actually WBNB when used on the Binance Smart Chain.

      _approve(address(this), address(_pancakeswapV2Router), amountToSwap);    // Allow the router to spend the amount.

      uint256 initialBalance = address(this).balance;

      _pancakeswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
          amountToSwap,
          0,
          tradingPair,
          address(this),  // Put the resulting BNB into the contract address
          block.timestamp.add(300));

      uint256 receivedBNB = address(this).balance.sub(initialBalance);  // The amount of BNB generated by the swap

      _approve(address(this), address(_pancakeswapV2Router), amountToUseForLiquidity);

      _pancakeswapV2Router.addLiquidityETH{value: receivedBNB}(
          address(this),
          amountToUseForLiquidity,
          0,
          0,
          address(this),  // Put the LP tokens into the contract
          block.timestamp.add(300)
      );

      emit SwapAndLiquify(amountToSwap, receivedBNB, amountToUseForLiquidity);

      currentlySwapping = false;

      return true;
  }

  function getOwner() override external view returns (address) {
    return owner();
  }

  function decimals() override external pure returns (uint8) {
    return _decimals;
  }

  function symbol() override external pure returns (string memory) {
    return _symbol;
  }

  function name() override external view returns (string memory) {
    return _name;
  }

  function totalSupply() override external view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address addr) override external view returns (uint256) {
    return _balances[addr];
  }

  function transfer(address recipient, uint256 amount) override external returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  function allowance(address owner, address spender) override external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) override external returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) override external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function setDevTaxAddress(address payable taxStorageDestination) external onlyOwner() returns(bool) {
    TaxStorageDestination = taxStorageDestination;
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  // This function allows someone to claim interest on their address and send it to another address. 
  // If this function is used then the taxes apply to the amount claimed. 
  // This is useful if someone wishes to use their interest as an income. They can keep their principal address locked and earn 40% but still be able to spend the earned interest.
  function claimInterestToAnotherAddress(address addr) public {

    uint256 currentBalance = _balances[msg.sender];

    claimInterest();

    uint256 interestEarned = _balances[msg.sender] - currentBalance;

    if(interestEarned != 0)
    {
      _claimingExternally = true;
      _transfer(msg.sender, addr, interestEarned);
      emit ExternalClaim(msg.sender, addr, interestEarned);
      _claimingExternally = false;
    }
  }

  // Claims any interest due and transfers it into the earners wallet. 
  // If you want to send the interest to an external address then use the claimInterestToAnotherAddress function.
  function claimInterest() public returns(uint256) {

    require(msg.sender != address(0), "BEP20: zero address not allowed");
    
    accrueInterest(msg.sender, false);

    uint256 addressesInterest = _accruedInterest[msg.sender];

    _balances[msg.sender] += addressesInterest;
    _totalSupply += addressesInterest;

    emit Transfer(address(0), msg.sender, addressesInterest);
    emit Claim(msg.sender, addressesInterest);

    _lastAccrueDate[msg.sender] = block.timestamp;
    _accruedInterest[msg.sender] = 0;   // sender has claimed their interest so we reset the accrued amount to zero.

    return addressesInterest;
  }

  function accrueInterest(address addr, bool isSelling) private {
    if(_interestRates[addr] == 0 && !_isExcludedFromInterest[addr])
    {
      _interestRates[addr] = _newAddressInterestRate; // We give new addresses a bonus rate.
      _previousInterestRate[addr] = _interestRates[addr];
    }

    if(_lastAccrueDate[addr] == 0) // Happens for the first token transaction on an address.
    {  
      _lastAccrueDate[addr] = block.timestamp;
      _accruedInterest[addr] = 0;      
    }

    if(_lastSellDate[addr] == 0)
    {
      _lastSellDate[addr] == block.timestamp - (MinutesBeforeInterest * 60);   // set the sell date to the past so that addresses are immediately able to earn interest.
    }

    if(_isExcludedFromInterest[addr])
      return;

    _accruedInterest[addr] = calculateClaimableInterest(addr);
    _lastAccrueDate[addr] = block.timestamp;

    uint256 unlockDate = whenWillAddressUnlock(addr);
    if(unlockDate != 0 && unlockDate <= block.timestamp)
    {
      _interestRates[addr] = _previousInterestRate[addr];
    }

    if(isSelling)
    {
      // we downgrade the address rate to the standard rate. They cant get a higher rate unless they lock their address. 
      _lastSellDate[addr] = block.timestamp;
      _interestRates[addr] = _standardInterestRate; // Address performed a sell so they are downgraded to the standard rate forever.
      _previousInterestRate[addr] = _interestRates[addr];
    }
  }

  // Calculates the total interest currently due to an address which can be claimed.
  function calculateClaimableInterest(address addr) public view returns(uint256) {

    if(_interestRates[addr] == 0 || _isExcludedFromInterest[addr])
    {
      return 0;
    }

    if(_lastSellDate[addr] + (MinutesBeforeInterest * 60) >= block.timestamp)
    {
      // The seller still earns 0% interest because of their last sale. 
      return _accruedInterest[addr];    // return previously accrued interest which hasnt been claimed.
    }

    uint256 validStandardMinutes = 0;
    uint256 validLockedMinutes = 0;
    uint256 unlockDate = whenWillAddressUnlock(addr);

    if(unlockDate != 0 && unlockDate > _lastAccrueDate[addr])    // The address is due some locked bonus interest
    {
      if(unlockDate < block.timestamp)  // Address is unlocked.
      {
        validLockedMinutes = (unlockDate - _dateAddressLocked[addr]) / 60;
        validStandardMinutes = (block.timestamp  - unlockDate) / 60;
      } 
      else
      {
        validLockedMinutes = (block.timestamp - _lastAccrueDate[addr]) / 60;
      }
    }
    else    // The address is not locked and has accrued all bonus locked interest.
    {
      validStandardMinutes = (block.timestamp - _lastAccrueDate[addr]) / 60;
    }

    if(validStandardMinutes == 0 && validLockedMinutes == 0)    // no new interest is due. Will only happen if the address is queried within 1 minute of the last accrual.
    {
      return _accruedInterest[addr];
    }
    else
    {
      // calculates the interest due prorated over the number of minutes that the balance has been valid for.
      uint256 standardInterestDue = ((_balances[addr].mul(_previousInterestRate[addr]).div(_yearInMinutes) / 100).mul(validStandardMinutes));
      uint256 lockedInterestDue = ((_balances[addr].mul(_interestRates[addr]).div(_yearInMinutes) / 100).mul(validLockedMinutes));
      return standardInterestDue + lockedInterestDue + _accruedInterest[addr];
    }
  }

  function handleTaxes(address sender, uint256 totalRequestedSpendAmount) private returns (uint256) {

    uint256 devTaxTotal = totalRequestedSpendAmount.div(100).mul(_devPercentage + _liquidityPercentage);
    uint256 burnTaxTotal = totalRequestedSpendAmount.div(100).mul(_burnPercentage);
    uint256 liquidityTotal = devTaxTotal.div(2);  // Half of the tax can be used for liquidity.

    _balances[_burnAddress] = _balances[_burnAddress].add(burnTaxTotal);
    emit Transfer(sender, _burnAddress, burnTaxTotal);

    _balances[TaxStorageDestination] += devTaxTotal.sub(liquidityTotal);   // Send the devTax to the configured address.
    emit Transfer(sender, TaxStorageDestination, devTaxTotal.sub(liquidityTotal));

    _balances[address(this)] += liquidityTotal;   // Send the liquidityTax to the current contract.
    emit Transfer(sender, address(this), liquidityTotal);

    return devTaxTotal + burnTaxTotal;
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  // Used to withdraw any BNB which is in the contract address. BNB should never be in this address, so this will be used if someone accidentally
  // transfers BNB to this address. This can be used to get them back their BNB. 
  function withdrawBNB(uint256 amount) public onlyOwner() {
    
    if(address(this).balance == 0)
      revert("Contract has a zero balance.");
    else
    {
      if(amount == 0) 
        payable(owner()).transfer(address(this).balance);
      else 
        payable(owner()).transfer(amount);
    }
  }

  // Used to withdraw tokens transferred to this address. Used to prevent permanently locking tokens which are accidentally sent to the contract address.
  // Contact the dev if you accidentally send tokens and we will do our best to return your funds. 
  function withdrawToken(address token, uint256 amount) public onlyOwner() {
    require(amount > 0, "Invalid amount supplied.");

    if(LockedLPTokens[token] && block.timestamp < LPUnlockDate)
        revert("This LP Token cannot be withdrawn yet");
    else
        IBEP20(address(token)).transfer(msg.sender, amount);
  }

}   // end of contract


library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

// IUniswapV2Factory interface taken from: https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// IUniswapV2Router01 interface taken from: https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router01.sol
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);    // WETH is actually WBNB when used on the Binance Smart Chain.

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

// IUniswapV2Router02 interface taken from: https://github.com/Uniswap/uniswap-v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol 
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata tradingPair,
        address to,
        uint deadline
    ) external;
}