//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./interfaces.sol";


contract HealthverseCrowdsale is Context {

  using SafeMath for uint256;

  //Tracks Admin and who is whitelisted
  mapping(address => bool) public isAdmin;
  mapping(address => bool) isWhitelisted;
  mapping(address => string) AdressWhitlistType;

  uint256 isWhitelistedImmortalCount;
  uint256 isWhitelistedHerculesCount;
  uint256 isWhitelistedHealthyCount;

  // Track investor contributions
  mapping(address => uint256) public contributions;

  // Track Founder withdrawel, Founders and Percentages
  mapping(address => bool) founderShareWithdrawn;
  mapping(address => bool) founder;
  mapping(address => uint256) founderMinPercentageTokenAmount;


  // Tokenbuyer Caps
  uint256  tokenbuyerMinCap;
  uint256  tokenbuyerHardCap;
  
  // Token reserve funds
  uint256 foundersFund;

  // Token time lock
  uint256 public releaseTime;

  uint256 totalSupply;

  // Crowdsale Cap
  uint256 private cap;

  //whitelistFunction
  string private secretCodeWord;
  string private immortalType;
  string private herculesType;
  string private healthyType;

  

  //Crowsale.sol///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // The token being sold
    IBEP20 private healthverseToken;

    // Token Decimals
    uint8 private decimals;

    // Address where funds are collected
    address payable private adminWallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.
    uint256 private tokenPriceInBNB;

    // Amount of wei raised
    uint256 private _weiRaised;

    // Variable for ReEntryGuard
    bool private _notEntered;

    //@dev Prevents a contract from calling itself, directly or indirectly.
    //Calling a `nonReentrant` function from another `nonReentrant`
    //function is not supported. It is possible to prevent this from happening
    //by making the `nonReentrant` function external, and make it call a
    //`private` function that does the actual work.
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;
        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    //Event for token purchase logging
    //@param purchaser who paid for the tokens
    //@param beneficiary who got the tokens
    //@param value weis paid for purchase
    //@param amount amount of tokens purchased
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    //@dev Emitted when `value` tokens are moved from one account (`from`) to
    //another (`to`).
    //Note that `value` may be zero.
    event Transfer(address indexed from, address indexed to, uint256 value);

   //Finalized-TimedCrowsale///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    uint256 private icoStartTime;
    uint256 private icoEndTime;

    bool private _finalized;

    //@dev Reverts if not in crowdsale time range.
    modifier onlyWhileOpen {
        require(isOpen(), "TimedCrowdsale: not open");
        _;
    }


  constructor(

    address payable _adminWallet, 
    IBEP20 _healthverseToken,  
    uint256 _totalSupply,
    uint8 _decimals
    
     
  )

  {
     require(_adminWallet != address(0), "Crowdsale: wallet is the zero address");
     require(address(_healthverseToken) != address(0), "Crowdsale: token is the zero address");
     adminWallet = _adminWallet;
     healthverseToken = _healthverseToken;     
     totalSupply = _totalSupply * (10**_decimals);
     decimals = _decimals;
     isAdmin[adminWallet] = true;
     _notEntered = true;     
  } 


  function whitelistFunction(string memory _secretCodeWord, string memory _immortalType, string memory _herculesType, string memory _healthyType) public {
        require(isAdmin[msg.sender],"only-admin");
        secretCodeWord = _secretCodeWord;
        immortalType = _immortalType;
        herculesType  = _herculesType;
        healthyType = _healthyType;

  }


    function rateAndBuyerCap(uint256 _tokenPriceInBNB, uint256 _tokenbuyerMinCap, uint256 _tokenbuyerHardCap) public
  {
    require(isAdmin[msg.sender],"only-admin");
    require(_tokenPriceInBNB > 0, "rateAndBuyerCap: rate is 0");
    require( 0 <= _tokenbuyerMinCap && _tokenbuyerMinCap < _tokenbuyerHardCap , "rateAndBuyerCap: BuyerMinCap is under 0 or equal to BuyerMaxCap");
    tokenPriceInBNB = _tokenPriceInBNB;
    tokenbuyerMinCap = _tokenbuyerMinCap;
    tokenbuyerHardCap = _tokenbuyerHardCap;  
  }


  function vesting(uint256 _releaseTime) public
  {
    require(isAdmin[msg.sender],"only-admin");
    require(_releaseTime > block.timestamp, "vesting: release time is before current time");
    releaseTime = _releaseTime;
   
  }

  
  function finalizedTimedCrowdsale(uint256 _icoStartTime, uint256 _icoEndTime) public
  { 
    require(isAdmin[msg.sender],"only-admin");
    require(_icoStartTime >= block.timestamp, "TimedCrowdsale: opening time is before current time");
    require(_icoEndTime > _icoStartTime, "TimedCrowdsale: opening time is not before closing time");
    icoStartTime = _icoStartTime;
    icoEndTime = _icoEndTime;
    _finalized = false;
  }
   

   function cappedCrowdsale(uint256 _cap) public
  {
   require(isAdmin[msg.sender],"only-admin"); 
   require(_cap > 0, "CappedCrowdsale: cap is 0");
   cap = _cap *(10**decimals);   
  }


  function timeLock(uint256 _foundersFund, address founderOne, address founderTwo, address founderThree,
                    uint founderOnePercentage, uint founderTwoPercentage, uint founderThreePercentage)  
  public { 
   require(isAdmin[msg.sender],"only-admin");
   foundersFund = _foundersFund * (10**decimals);
   founder[founderOne]  = true;
   founder[founderTwo]  = true;
   founder[founderThree]  = true;
   founderMinPercentageTokenAmount[founderOne] = founderOnePercentage *(10**decimals);  
   founderMinPercentageTokenAmount[founderTwo] = founderTwoPercentage *(10**decimals);  
   founderMinPercentageTokenAmount[founderThree] = founderThreePercentage *(10**decimals);  
  }

    //Crowsale.sol/////////////////////////////////////////////////////////////////////////////////////////////

    //@dev fallback function ***DO NOT OVERRIDE***
    //Note that other contracts will transfer funds with a base gas stipend
    //of 2300, which is not enough to call buyTokens. Consider calling
    //buyTokens directly when purchasing tokens from a contract.
    receive () external payable {
        buyTokens(_msgSender());
    }

    //@return the token being sold.
    function token() public view returns (IBEP20) {
        return healthverseToken;
    }

    //@return the amount of wei raised. 
    function weiRaised() internal view returns (uint256) {
        return _weiRaised;
    }

    //@dev low level token purchase ***DO NOT OVERRIDE***
    //This function has a non-reentrancy guard, so it shouldn't be called by
    //another `nonReentrant` function.
    //@param beneficiary Recipient of the token purchase
    function buyTokens(address beneficiary) public nonReentrant payable {
        uint256 weiAmount = msg.value;
        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);

        // update state
        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    //@dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
    //Use `super` in contracts that inherit from Crowdsale to extend their validations.
    //Example from CappedCrowdsale.sol's _preValidatePurchase method:
    //    super._preValidatePurchase(beneficiary, weiAmount);
    //    require(weiRaised().add(weiAmount) <= cap);
    //@param beneficiary Address performing the token purchase
    //@param weiAmount Value in wei involved in the purchase
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
       // require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(isWhitelisted[beneficiary], "WhitelistCrowdsale: beneficiary  is not in the Whitelisted List");
        require(weiRaised().add(weiAmount) <= cap, "CappedCrowdsale: cap exceeded");

        uint256 _existingContribution = contributions[beneficiary];
        uint256 _newContribution = _existingContribution.add(weiAmount);
        require(_newContribution >= tokenbuyerMinCap && _newContribution <= tokenbuyerHardCap, "Tokenpurchase: beneficiary contribution under MinCap or over MaxCap" );
        contributions[beneficiary] = _newContribution;

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

     //@dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     //conditions are not met.
     //@param beneficiary Address performing the token purchase
     //@param weiAmount Value in wei involved in the purchase
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        // solhint-disable-previous-line no-empty-blocks
    }

    //@dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
    //its tokens.
    //@param beneficiary Address performing the token purchase
    //@param tokenAmount Number of tokens to be emitted
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        healthverseToken.transfer( beneficiary,tokenAmount);
    }

     //@dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     //tokens.
     //@param beneficiary Address receiving the tokens
     //@param tokenAmount Number of tokens to be purchased
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

     // @param beneficiary Address receiving the tokens
     // @param weiAmount Value in wei involved in the purchase
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    //@param weiAmount Value in wei to be converted into tokens
    //@return Number of tokens that can be purchased with the specified _weiAmount
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(tokenPriceInBNB);
    }

    //@dev Determines how ETH / BNB is stored/forwarded on purchases.
    function _forwardFunds() internal {
        adminWallet.transfer(msg.value);
    }


  //Crowsale.sol ENDE////////////////////////////////////////////////////////////////////////////////////////

  //setAdmin and setWhitelisted//////////////////////////////////////////////////////////////////////////////

    function setAdmin(address anotherAdmin) public{
        require(isAdmin[msg.sender],"only-admin");
        isAdmin[anotherAdmin] = true;
    }

    function removeAdmin(address anotherAdmin) public{
        require(isAdmin[msg.sender],"only-admin");
        require(isAdmin[anotherAdmin],"not-admin");
        isAdmin[anotherAdmin] = false;
    }

    function isOnWhitelist(address whitelisted) public view returns (bool) {      
        return isWhitelisted[whitelisted]; 
    }

    function setWhitelisted(address whitelisted, string memory secretWord, string memory whitelistType) public{
        require(isAdmin[msg.sender] || keccak256(abi.encodePacked(secretCodeWord)) == keccak256(abi.encodePacked(secretWord)),"only-admin");

        if(keccak256(abi.encodePacked(whitelistType)) == keccak256(abi.encodePacked(immortalType))) { isWhitelistedImmortalCount++; AdressWhitlistType[whitelisted] = "Immortal"; }
        if(keccak256(abi.encodePacked(whitelistType)) == keccak256(abi.encodePacked(herculesType))) { isWhitelistedHerculesCount++; AdressWhitlistType[whitelisted] = "Hercules"; }
        if(keccak256(abi.encodePacked(whitelistType)) == keccak256(abi.encodePacked(healthyType))) { isWhitelistedHealthyCount++; AdressWhitlistType[whitelisted] = "Healthy"; }
        isWhitelisted[whitelisted] = true;
    }

    function removeWhitelisted(address whitelisted, string memory secretWord, string memory whitelistType) public{
        require(isAdmin[msg.sender] || keccak256(abi.encodePacked(secretCodeWord)) == keccak256(abi.encodePacked(secretWord)),"only-admin");
        require(isWhitelisted[whitelisted],"not-whitelisted");

        if(keccak256(abi.encodePacked(whitelistType)) == keccak256(abi.encodePacked(immortalType))) { isWhitelistedImmortalCount--; AdressWhitlistType[whitelisted] = "NULL";}
        if(keccak256(abi.encodePacked(whitelistType)) == keccak256(abi.encodePacked(herculesType))) { isWhitelistedHerculesCount--; AdressWhitlistType[whitelisted] = "NULL";}
        if(keccak256(abi.encodePacked(whitelistType)) == keccak256(abi.encodePacked(healthyType))) { isWhitelistedHealthyCount--; AdressWhitlistType[whitelisted] = "NULL";}
        isWhitelisted[whitelisted] = false;
    }

    function showWhitelistCounts(uint256 choice) public view returns (uint256) {      
       if(choice == 1){ return isWhitelistedImmortalCount;} else
       if(choice == 2){ return isWhitelistedHerculesCount;} else
       if(choice == 3){ return isWhitelistedHealthyCount;} else
       {return isWhitelistedImmortalCount + isWhitelistedHerculesCount + isWhitelistedHealthyCount;}
    }

    function showAdressWhitelistType(address whitelisted) public view returns (string memory) {      
        return AdressWhitlistType[whitelisted]; 
    }

  //setAdmin and setWhitelisted End////////////////////////////////////////////////////////////////////////////

    //CappedCrowsale/////////////////////////////////////////////////////////////////////////////////////////////////

    //@dev Checks whether the cap has been reached.
    //@return Whether the cap was reached
    function capReached() public view returns (bool) {
        return weiRaised() >= cap;
    }

   //CappedCrowsale  End///////////////////////////////////////////////////////////////////////////////////////////

  //Finalized-TimedCrowsale ///////////////////////////////////////////////////////////////////////////////////

    //@return true if the crowdsale is open, false otherwise.
    function isOpen() public view returns (bool) {
        return block.timestamp >= icoStartTime && block.timestamp <= icoEndTime;
    }

     //@dev Checks whether the period in which the crowdsale is open has already elapsed.
     //@return Whether crowdsale period has elapsed
    function hasClosed() public view returns (bool) {
        return block.timestamp > icoEndTime;
    }

    function extendTime(uint256 newIcoEndTime) public {
        require(!hasClosed(), "TimedCrowdsale: already closed");
        require(isAdmin[msg.sender],"only-admin");
        require(newIcoEndTime > icoEndTime, "TimedCrowdsale: new closing time is before current closing time");
        icoEndTime = newIcoEndTime;
    }

    //return true if the crowdsale is finalized, false otherwise.
    function finalized() public view returns (bool) {
        return _finalized;
    }

    //@dev Finalizing Crowdsale,enables Founder-Token transfers
    function finalization() public {
          require(isAdmin[msg.sender],"only-admin");
          require(!_finalized, "FinalizableCrowdsale: already finalized");
          require(hasClosed(), "FinalizableCrowdsale: not closed");
          _finalized = true; 
          
          // Transfer remaining Tokens that were not sold 
          healthverseToken.transfer( adminWallet,   healthverseToken.balanceOf(address(this)).sub(foundersFund));        
   
    }

  //Finalized-TimedCrowsale End////////////////////////////////////////////////////////////////////////////////////
  
  //Founder Vesting////////////////////////////////////////////////////////////////////////////////////////////////

    //@return the Holding Address of Founder Token.
    function balancefounderFund() public view returns (uint256) {
        return healthverseToken.balanceOf(address(this));
    }  

    //@returns if the Founders has already withrawn his shares.
    function showIfAlreadyWhithdrawn(address founderAddress) public view returns (bool){
        require(founder[founderAddress],"You are no Founder");
        
        return founderShareWithdrawn[founderAddress];    
    }

    // withdraws the available Percentage of Founder Share.
    function withdrawFounderShareAvailable(address  beneficiaryFounderAddress) public {

        require(founder[msg.sender],"Vesting: You are no Founder");
        require(!founderShareWithdrawn[msg.sender],"Vesting: You have already withdrawn 100%");
        require(block.timestamp >= releaseTime, "Vesting: Your Shares are not released yet");

        transferFounderShare(beneficiaryFounderAddress, founderMinPercentageTokenAmount[msg.sender]);
        founderShareWithdrawn[msg.sender] = true;
                     
    }  

    function transferFounderShare(address beneficiary, uint256 tokenAmount) internal {
            healthverseToken.transfer(beneficiary, tokenAmount);
    }

    //Founder Vesting  END///////////////////////////////////////////////////////////////////////////////////////// 

}