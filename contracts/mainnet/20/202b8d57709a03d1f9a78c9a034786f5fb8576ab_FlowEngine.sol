/**
 *Submitted for verification at BscScan.com on 2022-12-29
*/

/*
    SPDX-License-Identifier: MIT
    A Bankteller Production
    Elephant Money
    Copyright 2022
*/


pragma solidity ^0.6.8;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    bool private _paused;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event RunStatusUpdated(bool indexed paused);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        _paused = false; 
        emit RunStatusUpdated(_paused);
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called when contract is paused
     */
    modifier isRunning() {
        require(_paused == false, "Function unavailable because contract is paused");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    /**
     * @dev Pause the contract for functions that check run status
     * Can only be called by the current owner.
     */
    function updateRunStatus(bool paused) public virtual onlyOwner {      
        emit RunStatusUpdated(paused);
        _paused = paused;
    }

}

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;

    event WhitelistedAddressAdded(address addr);
    event WhitelistedAddressRemoved(address addr);

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], 'not whitelisted');
        _;
    }

    
    function addAddressToWhitelist(address addr) onlyOwner public returns (bool success) {
        if (!whitelist[addr]) {
            whitelist[addr] = true;
            emit WhitelistedAddressAdded(addr);
            success = true;
        }
    }

   
    function addAddressesToWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (addAddressToWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

    
    function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
        if (whitelist[addr]) {
            whitelist[addr] = false;
            emit WhitelistedAddressRemoved(addr);
            success = true;
        }
    }


    function removeAddressesFromWhitelist(address[] memory addrs) onlyOwner public returns(bool success) {
        for (uint256 i = 0; i < addrs.length; i++) {
            if (removeAddressFromWhitelist(addrs[i])) {
                success = true;
            }
        }
    }

}


interface IERC20 {


    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) external returns (bool);

    /**
     * @dev Burns the amount of tokens owned by `msg.sender`.
     */
    function burn(uint256 _value) external;

    
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IElephantReserve  {
    
    
    //Mint backed tokens using collateral tokens
    function mint(uint256 collateralAmount) external returns (uint256 backedAmount, uint256 feeAmount); 

    //Estimate is a simple top level estimate that factors the processingFee
    function estimateMint(uint256 collateralAmount) external view returns (uint256 backedAmount, uint256 feeAmount); 
    
    //Redeem backed token for collateral and core tokens based on the collateralFactor and collateralizationRatio of the treasuries
    function redeem(uint256 backedAmount) external returns (uint collateralAmount, uint coreAmount, uint adjustedCoreAmount, uint feeAmount); 
    
    //Redeems a credit from a whitelisted consumer.  Funds will be pulled from the core treasury
    function redeemCredit(address destination, uint256 creditAmount)  external returns (uint coreAmount, uint adjustedCoreAmount, uint coreAdjustedCreditAmount, uint feeAmount);
    
    //Only whitelisted
    function redeemCreditAsBacked(address destination, uint creditAmount) external returns (uint backedAmount, uint feeAmount); 
    
    //Estimates the redemption and uses collateralizationRatio to scale variable core component
    function estimateRedemption(uint256 backedAmount) external view returns (uint collateralAmount, uint coreAmount, uint adjustedCoreAmount, uint coreAdjustedCreditAmount, uint feeAmount, uint totalCollateralValue); 
    
    // This function is sensitive to slippage and that isn't a bad thing...
    // Don't dump your core or backed tokens... This is a community project
    function estimateCollateralToCore(uint collateralAmount) external view returns (uint wethAmount, uint coreAmount);
    
    // This function is sensitive to slippage and that isn't a bad thing...
    // Estimates the amount of  core tokens getting transfered to USD collateral tokens
    function estimateCoreToCollateral(uint coreAmount) external view returns (uint wethAmount, uint collateralAmount); 
    
    //Returns the ratio of core over collateralization to proportional hard collateral in the treasuries
    function collateralizationRatio() external view returns (uint256 cratio); 

    //Redeem a credit for the rewardpools.  Being sensitive to slippage is OK even though we are pulling from the pools
    function redeemCollateralCreditToWETH(uint256 collateralAmount)  external   returns (uint wethAmount);  
 
}

interface IRaffle {
    
    function add(address participant, uint256 amount) external;

}

interface ITreasury {

    function withdraw(uint256 tokenAmount) external;

}

interface IPcsPeriodicTwapOracle {

    // performs chained update calculations on any number of pairs
    //whitelisted to avoid DDOS attacks since new pairs will be registered
    function updatePath(address[] calldata path) external;

    //updates all pairs registered 
    function updateAll() external;
    
    // performs chained getAmountOut calculations on any number of pairs
    function consultAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);

    // returns the amount out corresponding to the amount in for a given token using the moving average over the time
    // range [now - [windowSize, windowSize - periodSize * 2], now]
    // update must have been called for the bucket corresponding to timestamp `now - windowSize`
    function consult(address tokenIn, uint amountIn, address tokenOut) external view returns (uint amountOut);

}

struct User {
    
    //Deposit Accounting
    uint256 deposits;
    uint256 deposit_time;
    uint256 payouts;

}

struct Sponsorship {

    uint256 pending;
    uint256 total;

}



contract FlowData is Whitelist {
    
    using SafeMath for uint256;
    
    mapping(address => User) public users;
    
    
    uint256 public total_users;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    uint256 public total_txs;

    constructor () public Ownable() {
    }
    
    function total_users_incr() external onlyWhitelisted{
        total_users += 1;
    }
    
    function total_txs_incr() external onlyWhitelisted{
        total_txs += 1;
    }
    
    function total_deposited_add(uint256 _amount) external onlyWhitelisted {
        total_deposited += _amount;
    }
    
    function total_withdraw_add(uint256 _amount) external onlyWhitelisted {
        total_withdraw += _amount;
    }
    
    function user_deposits_add(address _user, uint256 _amount) external onlyWhitelisted {
        users[_user].deposits += _amount;
    }
    
    function user_deposit_time(address _user) external onlyWhitelisted {
        users[_user].deposit_time = block.timestamp;
    }
    
    function user_paypouts_add(address _user, uint256 _amount) external onlyWhitelisted {
        users[_user].payouts += _amount;
    }
    
}

contract SponsorData is Whitelist {
    
    using SafeMath for uint256;
    
    mapping(address => Sponsorship) public users;
    
    
    uint256 public total_sponsored;

    constructor () public Ownable() {
    }
    
    function add(address _user, uint256 _amount) external onlyWhitelisted {
        users[_user].pending += _amount;
        users[_user].total += _amount;
        total_sponsored += _amount;
    }
    
    function settle(address _user) external onlyWhitelisted {
        users[_user].pending = 0;
    }
    
}


///@dev Simple onchain referral storage
contract ReferralData {

    event onReferralUpdate(address indexed participant, address indexed referrer);

    mapping(address => address) private referrals;
    mapping(address => uint256) private refCounts;


    ///@dev Updated the referrer of the participant
    function updateReferral(address referrer) public {
      //non-zero, no self, no duplicate
      require(referrer != address(0) && referrer != msg.sender && referrals[msg.sender] != referrer, "INVALID ADDRESS");
      
      address prevReferrer = referrals[msg.sender];

      //decrement previous referrer
      if (prevReferrer != address(0)){
        if (refCounts[prevReferrer] > 0){
          refCounts[prevReferrer] = refCounts[prevReferrer] - 1;
        }
      }
      //increment new referrer
      refCounts[referrer] = refCounts[referrer] + 1;

      //update to new
      referrals[msg.sender] = referrer;
      emit onReferralUpdate(msg.sender, referrer);
    }

    ///@dev Return the referral of the sender
    function myReferrer() public view returns (address){
      return referrerOf(msg.sender);
    }

    //@dev Return true if referrer of user is sender
    function isMyReferral(address _user) public view returns (bool){
      return referrerOf(_user) == msg.sender;
    }

    //@dev Return true if user has a referrer
    function hasReferrer(address _user) public view returns (bool){
      return referrerOf(_user) != address(0);
    }

    ///@dev Return the referral of a participant 
    function referrerOf(address participant) public view returns (address) {
      return referrals[participant];
    } 

    ///@dev Return the referral count of a participant 
    function referralCountOf(address _user) public view returns (uint) {
      return refCounts[_user];
    } 

}

contract AddressRegistry {

    address public constant coreAddress =  address(0xE283D0e3B8c102BAdF5E8166B73E02D96d92F688); //ELEPHANT
    address public constant coreTreasuryAddress = address(0xAF0980A0f52954777C491166E7F40DB2B6fBb4Fc); //ELEPHANT Treasury
    address public constant collateralAddress = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); //BUSD 
    address public constant collateralTreasuryAddress = address(0xCb5a02BB3a38e92E591d323d6824586608cE8cE4); //BUSD Treasury
    address public constant collateralRedemptionAddress = address(0xD3B4fB63e249a727b9976864B28184b85aBc6fDf); //BUSD Redemption Pool
    address public constant backedAddress = address(0xdd325C38b12903B727D16961e61333f4871A70E0); //TRUNK Stable coin
    address public constant backedTreasuryAddress = address(0xaCEf13009D7E5701798a0D2c7cc7E07f6937bfDd); //TRUNK Treasury
    address public constant backedLPAddress = address(0xf15A72B15fC4CAeD6FaDB1ba7347f6CCD1E0Aede); //TRUNK/BUSD LP
    address public constant routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    address public constant flowDataAddress = address(0x4C64719E524383662232FDb50dfdaDEFB15c09D9); //FlowData 

}

contract FlowEngine is Ownable {

  using SafeMath for uint256;

  IERC20 public backedToken;
  IERC20 public collateralToken;
  ITreasury public backedTreasury;
  ITreasury public collateralTreasury;

  AddressRegistry private registry;


  uint256 public rollBalance;
  uint256 public peanutBonus = 25;

  uint256 public constant DepositTax = 25;    
  uint256 public constant ExitTax = 25;

  uint256 private constant payoutRate = 1;
  uint256 private constant minimumAmount = 1e18;
  uint256 private constant minimumDeposits = 100e18;
  
  uint256 public constant sweepThreshold = 100e18; //large deposits should be processed immediately by those who can afford it
  uint256 public constant MAX_UINT = 2**256 - 1;
  
  FlowData public flowData;
  ReferralData public referralData;
  SponsorData public sponsorData;
  IElephantReserve public reserve;
  IRaffle public raffle;
  IPcsPeriodicTwapOracle public oracle;

  event NewDeposit(address indexed addr, uint256 amount);
  event NewSponsorship(address indexed from, address indexed to, uint256 amount);
  event Leaderboard(address indexed addr, uint256 total_deposits, uint256 total_payouts);
  event Withdraw(address indexed addr, uint256 amount);
  event LimitReached(address indexed addr, uint256 amount);
  event UpdateReserve(address indexed addr);
  event UpdateReferralData(address indexed addr);
  event UpdateSponsorData(address indexed addr);
  event UpdateFlowData(address indexed addr);
  event UpdateRaffle(address indexed addr);
  event UpdatePeanutRaffleBonus(uint amount);
  event UpdateOracle(address indexed addr);

  /* ========== INITIALIZER ========== */

  constructor () public Ownable()    {
    
    //init reg
    registry = new AddressRegistry();

    //setup the core tokens
    backedToken = IERC20(registry.backedAddress());
    collateralToken = IERC20(registry.collateralAddress());
    
    //treasury setup
    backedTreasury = ITreasury(registry.backedTreasuryAddress());
    collateralTreasury = ITreasury(registry.collateralTreasuryAddress());
  
  }

  /****** Administrative Functions *******/

   //update raffle
    function updateRaffle(address raffleAddress) onlyOwner external {
        require(raffleAddress != address(0), "Require valid non-zero addresses");

        raffle = IRaffle(raffleAddress);

        emit UpdateRaffle(raffleAddress);
    }

  function updateFlowData(address flowDataAddress) onlyOwner external {
    require(flowDataAddress != address(0), "Require valid non-zero addresses");

    flowData = FlowData(flowDataAddress);

    emit UpdateFlowData(flowDataAddress);
  }

  function updateSponsorData(address sponsorDataAddress) onlyOwner external {
    require(sponsorDataAddress != address(0), "Require valid non-zero addresses");

    sponsorData = SponsorData(sponsorDataAddress);

    emit UpdateSponsorData(sponsorDataAddress);
  }

  function updateReferralData(address referralDataAddress) onlyOwner external {
    require(referralDataAddress != address(0), "Require valid non-zero addresses");

    referralData = ReferralData(referralDataAddress);

    emit UpdateReferralData(referralDataAddress);
  }
  
  function updateReserve(address reserveAddress) onlyOwner external {
    require(reserveAddress != address(0), "Require valid non-zero addresses");
    
    //the main reeserve fore the backed token
    reserve = IElephantReserve(reserveAddress);

    emit UpdateReserve(reserveAddress);
      
  }

  //@dev Update the oracle used for price info
    function updateOracle(address oracleAddress) external onlyOwner {
        require(
            oracleAddress != address(0),
            "Require valid non-zero addresses"
        );

        //the main oracle 
        oracle = IPcsPeriodicTwapOracle(oracleAddress);

        emit UpdateOracle(oracleAddress);
    }

  function updatePeanutRaffleBonus(uint bonus) onlyOwner external {
    require(bonus >= 1 && bonus <= 100, "Bonus from 1 to 100 percent");

    peanutBonus = bonus;
    
    emit UpdatePeanutRaffleBonus(bonus);
  }


  /********** User Fuctions **************************************************/


  //@dev Deposit specified Flow amount
  function deposit(uint256 _amount) external {

    address _addr = msg.sender;
    
     //Check minimum
    require(_amount >= minimumAmount, "Minimum deposit");
    
    //Roll if divs are greater than 1% of the 
    //If the person wants to claim they can do so
    //sponsorships have no side effects so rolling is the right applications; keeping deposit/claim as the only heavy actions
    uint _available = claimsAvailable(_addr);
    if (_available > _amount / 100){
        _roll(_addr);

        //join raffle
        raffle.add(_addr, _available);
    }

    //Transfer TRUNK to the contract
    require(
      backedToken.transferFrom(
        _addr,
        address(backedTreasury), //directly to TRUNK Treasury
        _amount
      ),
      "TRUNK token transfer failed"
    );

    //Add referral bonus for referrer, 1%
    processReferralBonus(_addr, _amount.div(100));

    Sponsorship memory sponsorship = getSponsorship(_addr);

    //If we have a pending sponsorship let's settle
    if (sponsorship.pending > 0){
        sponsorData.settle(_addr);
    }
    
    //Collect deposit tax
    uint256 _net_amount = _amount.add(sponsorship.pending).mul(SafeMath.sub(100, DepositTax)).div(100); //add pending sponsorship and tax total deposit

    _deposit(_addr, _net_amount);
     
    User memory user = getUser(_addr);
    emit Leaderboard(_addr, user.deposits, user.payouts);
    flowData.total_txs_incr();

    //join raffle
    raffle.add(_addr, _amount);

  
  }

  //@dev Up to 4X on your BUSD based on the peg for a depost and raffle bonus
  function peanuts(uint256 _amount) external {

    address _addr = msg.sender;

    //Checks
    require(_amount >= minimumAmount, "Minimum deposit"); 

    //Update TWAP
    oracle.updateAll();  

    //Roll if divs are greater than 1% of the 
    //If the person wants to claim they can do so
    //sponsorships have no side effects so rolling is the right applications; keeping deposit/claim as the only heavy actions
    uint _available = claimsAvailable(_addr);
    if (_available > _amount / 100){
        _roll(_addr);

        //join raffle
        raffle.add(_addr, _available);
    } 

    //Transfer TRUNK to the contract FROM SENDER //This is a sponsorship
    require(
      collateralToken.transferFrom(
        _addr,
        address(collateralTreasury),
        _amount
      ),
      "BUSD token transfer failed"
    );

    //Add referral bonus for referrer, 1%
    processReferralBonus(_addr, _amount.div(100));

    Sponsorship memory sponsorship = getSponsorship(_addr);

    //If we have a pending sponsorship let's settle
    if (sponsorship.pending > 0){
        sponsorData.settle(_addr);
    }

    //Adjust peg amount 

    uint _adjustedPegAmount = scaleBusdByPeg(_amount); //function enforces policy; the loswest we will go is 0.25 BUSD/TRUNK

    //Collect deposit tax
    uint256 _net_amount = _adjustedPegAmount.add(sponsorship.pending).mul(SafeMath.sub(100, DepositTax)).div(100); //add pending sponsorship and tax total deposit

    _deposit(_addr, _net_amount);
     
    User memory user = getUser(_addr);
    emit Leaderboard(_addr, user.deposits, user.payouts);
    
    flowData.total_txs_incr();

    uint256 _peanutAdjustedAmount = _adjustedPegAmount.mul(peanutBonus.add(100)).div(100);

    //join raffle
    raffle.add(_addr, _peanutAdjustedAmount);

  }


  //@dev Deposit specified Flow account and amount
  function sponsor(address _addr, uint256 _amount) external {

    
    address _sender = msg.sender;

    User memory sUser = getUser(_sender);

    //Checks
    require(_addr != address(0), "Can't send to the zero address");
    require(_addr != _sender, "Can't send to yourself");
    require(sUser.deposits > 0, "Sender must be active");
    require(_amount >= minimumAmount, "Minimum deposit");    

    //Transfer TRUNK to the contract FROM SENDER //This is a sponsorship
    require(
      backedToken.transferFrom(
        _sender,
        address(backedTreasury),
        _amount
      ),
      "TRUNK token transfer failed"
    );

    //We operate side effect free and just add to pending sponsorships

    sponsorData.add(_addr, _amount);

    emit NewSponsorship(_sender, _addr, _amount); 
    
    flowData.total_txs_incr();

  }

  //@dev Roll, reinvest and buyback core
  function roll() external returns (uint _rolledAmount){
    
    address _addr = msg.sender;

    uint256 _available = claimsAvailable(_addr); //use the amount the user sees
    
    _rolledAmount = _roll(_addr);

    //Update stats and user events
    User memory _user = getUser(_addr);
    emit Leaderboard(_addr, _user.deposits, _user.payouts);
    flowData.total_txs_incr();

    //join raffle
    raffle.add(_addr, _available);

  }


  //@dev Claim, transfer, withdraw from vault
  function claim() external {

    address _addr = msg.sender;

    _claim_out(_addr);

    User memory _user = getUser(_addr);
    emit Leaderboard(_addr, _user.deposits, _user.payouts);
    flowData.total_txs_incr();

  }


  /********** Internal Fuctions **************************************************/
  
  
  //@dev Return a user from flowData
  function getUser(address _user) private view returns (User memory) {
  
    (uint256 _deposits, uint256 _deposit_time, uint256 _payouts) =  flowData.users(_user);
    User memory user = User({deposits : _deposits , deposit_time : _deposit_time, payouts : _payouts});
    return user;
  }

  //@dev Return a user from flowData
  function getSponsorship(address _user) private view returns (Sponsorship memory) {
  
    (uint256 _pending, uint256 _total) =  sponsorData.users(_user);
    Sponsorship memory sponsorship = Sponsorship({pending : _pending , total : _total});
    return sponsorship;
  }

  //@dev Add referral bonus if applicable
  function processReferralBonus(address _user, uint256 _amount) private {
    
    address _referrer = referralData.referrerOf(_user);

    //Need to have an upline
    if (_referrer == address(0)){
      return;
    }
    

    //partners split 50/50
    uint _share = _amount.div(2);

    //We operate side effect free and just add to pending sponsorships
    sponsorData.add(_referrer, _share);
    sponsorData.add(_user, _share);

    emit NewSponsorship(_user, _referrer, _share); 
    emit NewSponsorship(_referrer, _user, _share); 

  }


  //@dev Deposit
  function _deposit(address _addr, uint256 _amount) private {
      
    User memory _user = getUser(_addr);  

    //Count user 
    if ( _user.deposit_time == 0){
        flowData.total_users_incr();
    }

    //stats
    flowData.user_deposits_add(_addr, _amount);
    flowData.user_deposit_time(_addr);

    flowData.total_deposited_add(_amount);

    //events
    emit NewDeposit(_addr, _amount);
  }


  //@dev Claim and payout using the reserve
  function _claim_out(address _addr) private {

    uint256 to_payout = _claim(_addr);

    uint256 realizedPayout = to_payout.mul(SafeMath.sub(100, ExitTax)).div(100); // 10% tax on withdraw
    
    //TRUNK Treasury should be large enough to support inflation
    uint256 tshare = backedToken.balanceOf(address(backedTreasury)).div(100);

    //if realizedPayout is greater than 1%
    if(realizedPayout > tshare){
        reserve.redeemCreditAsBacked(address(backedTreasury), realizedPayout.mul(110).div(100)); //Add an additional 10% to the TREASURY of payout
    } 

    //Get TRUNK
    backedTreasury.withdraw(realizedPayout);

    require(backedToken.transfer(_addr, realizedPayout), "Failed to transfer claim");

  }

  //@dev Ultra cheap rolls
  function _roll(address _addr) private returns (uint amount) {

    //claim first
    uint256 to_payout = _claim(_addr);

    //Apply cumulative in/out fees to calculate realized roll
    uint256 realizedPayout = to_payout.mul(SafeMath.sub(100, ExitTax)).div(100); // 10% tax on withdraw

    //Add referral bonus for referrer, 0.1% of potential claim that is rolled
    //Only include exit tax since the sponsorship will be tax a deposit fee when added.
    processReferralBonus(_addr, realizedPayout.div(100));

    //include the 1% processingfee for vanilla redemption
    realizedPayout = realizedPayout.mul(99).div(100);


    //apply deposit fee
    realizedPayout = realizedPayout.mul(SafeMath.sub(100, DepositTax)).div(100); //tax total deposit
    
    //deposit realized
    _deposit(_addr, realizedPayout);

    amount = realizedPayout;


  }


  //@dev Claim current payouts
  function _claim(address _addr) private returns (uint256) {
    (uint256 _gross_payout, uint256 _max_payout) = payoutOf(_addr);
    
    User memory _user = getUser(_addr);
    
    require(_user.payouts < _max_payout, "Full payouts");

    // Deposit payout
    if(_gross_payout > 0) {

      // payout remaining allowable divs if exceeds
      if(_user.payouts + _gross_payout > _max_payout) {
        _gross_payout = _max_payout.safeSub(_user.payouts);
      }

      flowData.user_paypouts_add(_addr, _gross_payout);
      
    }

    require(_gross_payout > 0, "Zero payout");

    //Update the payouts
    flowData.total_withdraw_add(_gross_payout);

    //Update time!
    flowData.user_deposit_time(_addr);

    emit Withdraw(_addr, _gross_payout);
    
    //Get updated user
    _user = getUser(_addr);

    if(_user.payouts >= _max_payout) {
      emit LimitReached(_addr, _user.payouts);
    }

    return _gross_payout;
  }

  /********* Views ***************************************/

  //@dev Returns the total credits and debits for a given address
  function creditsAndDebits(address _addr) external view returns (uint256 _credits, uint256 _debits) {
    User memory _user = getUser(_addr);

    _credits = _user.deposits;
    _debits = _user.payouts;

  }

  //@dev Returns amount of claims available for sender
  function claimsAvailable(address _addr) public view returns (uint256) {
    (uint256 _to_payout, ) = payoutOf(_addr);
    return _to_payout.mul(SafeMath.sub(100, ExitTax)).div(100);
  }

  //@dev Maxpayout of 3.65 of deposit
  function maxPayoutOf(uint256 _amount) public pure returns(uint256) {
    return _amount * 365 / 100;
  }

  //@dev Calculate the current payout and maxpayout of a given address
  function payoutOf(address _addr) public view returns(uint256 payout, uint256 max_payout) {
    
    User memory _user = getUser(_addr);
    
    //The max_payout is a function of deposits
    max_payout = maxPayoutOf(_user.deposits);

    uint256 share;

    // No need for negative fee

    if(_user.payouts < max_payout) {
      //Using 1e18 we capture all significant digits when calculating available divs
      share = _user.deposits.mul(payoutRate * 1e18).div(100e18).div(24 hours); //divide the profit by payout rate and seconds in the day
      payout = scaleByPeg(share * block.timestamp.safeSub(_user.deposit_time)); //scale by 

      // payout remaining allowable divs if exceeds
      if(_user.payouts + payout > max_payout) {
        payout = max_payout.safeSub(_user.payouts);
      }

    }
  }

  //@dev Calculate the current payout and maxpayout of a given address
  function peggedPayoutOf(address _addr) public view returns(uint256 payout, uint256 max_payout) {
    
    User memory _user = getUser(_addr);
    
    //The max_payout is a function of deposits
    max_payout = maxPayoutOf(_user.deposits);

    uint256 share;

    // No need for negative fee

    if(_user.payouts < max_payout) {
      //Using 1e18 we capture all significant digits when calculating available divs
      share = _user.deposits.mul(payoutRate * 1e18).div(100e18).div(24 hours); //divide the profit by payout rate and seconds in the day
      payout = share * block.timestamp.safeSub(_user.deposit_time);

      // payout remaining allowable divs if exceeds
      if(_user.payouts + payout > max_payout) {
        payout = max_payout.safeSub(_user.payouts);
      }

    }
  }



  function scaleByPeg(uint amount) public view returns (uint scaledAmount) {
        address[] memory path = new address[](2);
        uint[] memory amounts = new uint[](2);

        path[0] = address(backedToken);
        path[1] = address(collateralToken);


        amounts = oracle.consultAmountsOut(amount, path);

        scaledAmount = amount.min(amounts[1]); //we don't reward over peg

  }

  function scaleBusdByPeg(uint amount) public view returns (uint scaledAmount) {
        address[] memory path = new address[](2);
        uint[] memory amounts = new uint[](2);

        path[0] = address(collateralToken); 
        path[1] = address(backedToken);


        amounts = oracle.consultAmountsOut(amount, path);

        scaledAmount = amounts[1].min(amount.mul(4)); //we don't reward under 0.25

        scaledAmount = scaledAmount.max(amount); //we don't punish for being over peg

  }


  //@dev Get current user snapshot
  function userInfo(address _addr) external view returns(uint256 deposit_time, uint256 deposits, uint256 payouts, uint256 pending_sponsorship, uint256 total_sponsorship) {
    User memory _user = getUser(_addr);
    Sponsorship memory _sponsorship = getSponsorship(_addr);   
    return (_user.deposit_time, _user.deposits, _user.payouts, _sponsorship.pending, _sponsorship.total);
  }
  
  //@dev Get contract snapshot
  function contractInfo() external view returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint256 _total_txs, uint256 _total_sponsorships) {
    return (flowData.total_users(), flowData.total_deposited(), flowData.total_withdraw(), flowData.total_txs(), sponsorData.total_sponsored());
  }
  
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
   * @dev Multiplies two numbers, throws on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
   * @dev Integer division of two numbers, truncating the quotient.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
   * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /* @dev Subtracts two numbers, else returns zero */
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    if (b > a) {
      return 0;
    } else {
      return a - b;
    }
  }

  /**
   * @dev Adds two numbers, throws on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}