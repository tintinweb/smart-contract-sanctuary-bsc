// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IHibbyToken.sol";
// import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

interface IBUSDToken {
    

    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
  }

contract HibbyPrivateSale is Context, Ownable {
  address admin;
  // Our Token Contract
  IHibbyToken hibby;
  IBUSDToken busd;


  // token price for BNB
  uint256 public BUSDPerToken = 12 * 10**16; // price of 1 token in wei i.e. $0.12

  bool public priceIncreaseEnabled; // Price of the token is increassing or not

  // Rate in which the price increase
  uint256 public priceChangeRate = 1; // Rate of increase ($0.01) after specific amount sold

  // Price increase after the token sold
  uint256 public increaseAtToken = 100 * 10**18;

  uint256 public tokenSold;  // Total token sold

  //Max token limit to sold by contract
  uint256 public maxSoldLimit = 25000 * 10**18;

  //Reward get by referral in percent
  uint256 public rewardPercent;

  bool public saleEnabled; //Sale is active or not
    
  struct User{
    uint88 tokenBrought;            // Tokens buy by the user
    uint88 tokenGot;                // Token user will get after subtracting the reward amount
    uint88 rewardRecieved;          // Reward recieved by the user 
    uint88 totalBuyerFromReferral;  // Total participant joined by the user
    uint88 totalBuyFromReferral;    // Show how many token are buy by this referral link
    uint88[] buyFromReferral;       // Number of token buy from this link
    address[] buyerFromReferral;    // Address of the buyers from this referral link
    bytes32 userToReferral;         // Referral link of the user
    mapping(address => bool) oldBuyer; // Check if the user buy from this referral before
  }

  uint public startTime;

  uint public endTime;

  mapping(address => User) public users;
  
  mapping(bytes32 => address) public referralToUser;

  mapping(bytes32 => bool) public referralIsValid;

  uint256 public totalBuyers;

  mapping(uint256 => address) public indexToUser;

  // Reward claiming is enable or not
  bool public claimEnable;

  // Check user claim his token or not
  mapping(address => bool) public isTokenClaimed;

  // Event that logs buy operation
  event BuyTokens(address buyer, uint256 amountOfBNB, uint256 amountOfTokens);
  
  constructor(
    address _hibbyTokenAddress,
    address _BUSDTokenaddress    
    ) {
    admin = _msgSender();
    hibby = IHibbyToken(_hibbyTokenAddress);
    busd = IBUSDToken(_BUSDTokenaddress);
    saleEnabled = true;
    priceIncreaseEnabled = true;
    rewardPercent = 5;
    startTime = block.timestamp;
    endTime = block.timestamp + 4 days;    
  }
 
  /**
  * @notice Allow users to buy tokens for BUSD
  */
  
  function buyTokens(uint _amount, bytes32 _referral) external returns (uint256 tokenAmount, bytes32){
    
    tokenAmount = _checkConditions(_amount);
    
    require(referralIsValid[_referral], "Referral is invalid");

    address inviter = referralToUser[_referral];
    address buyer = _msgSender();

    uint rewardAmount = ( tokenAmount * rewardPercent ) / 100;
    
    uint amountYouGet = tokenAmount - rewardAmount;
    
    // Transfer Busd to the Owner address 
    (bool sent) = busd.transferFrom(buyer, admin, _amount);
    require(sent, "Failed to transfer BUSD to owner");
           
    // Updating the buyer data
    users[buyer].tokenBrought += uint88(tokenAmount);
    users[buyer].tokenGot += uint88(amountYouGet);

    bytes32 newReferral = keccak256(abi.encodePacked(_msgSender()));

    if(!referralIsValid[newReferral]){

      // Buyer
      referralIsValid[newReferral] = true;
      users[buyer].userToReferral = newReferral;      
      referralToUser[newReferral] = buyer;
      totalBuyers++;
      indexToUser[totalBuyers] = buyer;
                    
    }
    
    // Updating the inviter data
    users[inviter].rewardRecieved += uint88(rewardAmount);
    
    users[inviter].totalBuyFromReferral += uint88(_amount);
    users[inviter].buyFromReferral.push(uint88(tokenAmount));
    users[inviter].buyerFromReferral.push(buyer);
    tokenSold += tokenAmount;

    if((!users[inviter].oldBuyer[buyer]) && (buyer != inviter)){
      users[inviter].totalBuyerFromReferral += 1;
      users[inviter].oldBuyer[buyer] = true;
    }
       
    // emit the event
    emit BuyTokens(_msgSender(), _amount, tokenAmount);

    return (tokenAmount, newReferral);
  }

  function _checkConditions(uint _amount) private view returns (uint){
    require(block.timestamp <= endTime, "Sale is ended");

    require (saleEnabled && (hibby.allowance(admin, address(this)) > 0), "Sale has stoped");
    
    require(_amount > 0, "Need BUSD to buy some tokens");

    
    uint256 amountToBuy = checkTokenForBUSD(_amount); // checkTokenForBUSD

     
    uint256 userBalance = busd.balanceOf(_msgSender());
    require(userBalance >= _amount, "You don't have enough BUSD");
    
    require(users[_msgSender()].tokenBrought + amountToBuy <= maxSoldLimit, "Max limit to buy from this sale is reched");

    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = hibby.allowance(admin, address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

    return amountToBuy;
    
  }

  // Function to check the referral link is valid or not
  function checkReferral(bytes32 _referral) external view returns(bool){
    return referralIsValid[_referral];
  }
  
  // function to check the how many token you will get if you send specific amount
  function checkTokenForBUSD(uint _amount) public view returns (uint){

    if(priceIncreaseEnabled){
            
          uint beforeToken = (_amount * 10**18)/BUSDPerToken;
          uint i = ( ( ( tokenSold + beforeToken ) ) / increaseAtToken )* priceChangeRate ;
          
          return (( _amount * 10**18 ) / ( BUSDPerToken + (i * 10**16) ));
    }
    else{

          return ( (_amount * 10**18) / BUSDPerToken );

    }
  }

  // Function to check the current price of the token
  function checkBUSDPrice() external view returns(uint256){
    uint i = ( tokenSold/ increaseAtToken ) * priceChangeRate;
    return ( BUSDPerToken + (i * 10**16) );
  }

  // check at the time user can claim his reward or not 
  function checkClaimToken(address _user) public view returns(bool){
    
    require(claimEnable, "At this time claiming token is not active");
    require(!isTokenClaimed[_user], "You already claimed your token");
    require((users[_user].tokenGot + users[_user].rewardRecieved) > 0, "You don't have any token to claim");
    return true;

  }

  // function to claimToken after the token transfer is allowed
  function claimToken() external {
   
    address user = _msgSender();
    checkClaimToken(user);

    isTokenClaimed[user] = true;
    uint88 amountToSend = users[user].tokenGot + users[user].rewardRecieved;

    // Sending tokens to the user
    (bool send) = hibby.transferFrom(admin, user, uint(amountToSend));
    require(send);
  }

  // Function to set the claimEnable 
  function setClaimEnable(bool _value) external onlyOwner{
    claimEnable = _value;
  }

  // Function to make referral link only owner should call this
  function makeReferral(address[] calldata _address) external onlyOwner returns(address[] memory, bytes32[] memory){
    bytes32[] memory referralArray = new bytes32[](_address.length);
    address _user;
    for(uint i ; i < _address.length; i++){
      _user = _address[i];
      bytes32 referral = keccak256(abi.encodePacked(_user));
      referralToUser[referral] = _user;
      users[_user].userToReferral = referral;

      if(!referralIsValid[referral]){
        
        referralIsValid[referral] = true;
        totalBuyers++;
        indexToUser[totalBuyers] = _user;
      }

      referralArray[i] = referral;
    }
    return (_address ,referralArray);
  }

  // Function to get the referral link of the address
  function getReferralByAddress(address _user) external view returns(bytes32){
    return users[_user].userToReferral;
  }

  // Function to get the referral link of the msg.sender
  function getReferral() external view returns(bytes32){
    
    return users[_msgSender()].userToReferral;
  } 

  // Function to get the how many user buy from specific address
  function getAllBuyersOfAddress(address _address) external view returns(address[] memory, uint88[] memory){
    return (users[_address].buyerFromReferral, users[_address].buyFromReferral);
  }

  // Function to get all the Buyer of this contract
  function getAllBuyers() external view returns(address[] memory){
    address[] memory _buyers = new address[](totalBuyers);
    for( uint i ; i < totalBuyers ; i++){
      _buyers[i] = indexToUser[i+1];
    }
    return _buyers;
  }

  // Function to send the remaining tokens to the Gorila Gordo pot
  function sendToPot(address _address) external onlyOwner {

    require(( block.timestamp >= endTime ) || (!saleEnabled), "Sale is running");
   
    uint256 remainAllowance = hibby.allowance(admin, address(this));
    (bool sent) = hibby.transferFrom(admin, _address, remainAllowance);
     require(sent, "Failed to transfer token to address");
  }

  // Function to set the price rate of token
  function setPriceChangeRate(uint _rate) external onlyOwner{
    priceChangeRate = _rate;
  }

  // Function to change the threshold to increase the price
  function setIncreasAtToken(uint _tokenSold) external onlyOwner{
    increaseAtToken = _tokenSold;
  } 

  // Function to change the price of the token 
  function setPriceOfToken(uint _price) external onlyOwner{
    BUSDPerToken = _price;
  }

  // Function to set the sale is active or not 
  function setSale(bool _state) external onlyOwner{
    saleEnabled = _state;
  }

  // Function to change the reward persent of the token
  function setRewardPersent(uint _rate) external onlyOwner{
    rewardPercent = _rate;
  }
   
  function setPriceIncreaseEnabled(bool _value) external onlyOwner{
    priceIncreaseEnabled = _value;
  }

  function extendEndTime(uint _time) external onlyOwner{
    endTime += _time;
  }

  function setHibbyAddress(address _address) external onlyOwner{
    hibby = IHibbyToken(_address);
  }

  function setBUSDAddress(address _address) external onlyOwner{
    busd = IBUSDToken(_address);
  }

  
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface IHibbyToken {
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function burn(uint amount) external;

    function burnFrom(address account, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}