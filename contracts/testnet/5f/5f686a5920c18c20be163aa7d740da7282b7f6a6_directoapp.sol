/**
 *Submitted for verification at BscScan.com on 2022-12-21
*/

//SPDX-License-Identifier: GPL-3.0




// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


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

// File: @openzeppelin/contracts/utils/Counters.sol


// OpenZeppelin Contracts v4.4.1 (utils/Counters.sol)

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented, decremented or reset. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

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

// File: directoapp.sol



pragma solidity ^0.8.0;


contract directoapp is Ownable , ReentrancyGuard { 

    using Counters for Counters.Counter;
    Counters.Counter private projectIds_;
    Counters.Counter private completeProject_; 
    Counters.Counter private reviewId_;     
   
    address public wallet_;
    uint256 public shoper_ = 1200;//12%
    uint256 public freelancer_ = 1200;//12%
    mapping(uint256=>proposal) public approve_;
    mapping(uint256=>Review) public review_;

    IERC20 public token_;
    
    
    uint256 public acceptLimit_ = 1200;//offersend seconds
    uint256 public reviewLimit_ = 1200; //changingRequest
    uint256 public withdrawLimit_ = 1200;//offer complete time
    uint256 public completeEnd = 120;//review deny time


    function setShopperPercentage (uint256 __percentage)public onlyOwner{
        shoper_ = __percentage;
    }

    function setFreelancerPercentage (uint256 __percentage)public onlyOwner{
        freelancer_ = __percentage;
    }

    function acceptLimit (uint256 __limit)public onlyOwner{
        acceptLimit_ = __limit;
    }
   
    function reviewLimit (uint256 __limit)public onlyOwner{
        reviewLimit_ = __limit;
    }

    function _withdrawLimit (uint256 __limit)public onlyOwner{
        withdrawLimit_ = __limit;
    }
    
    function CompleteEndTime(uint256 time)public onlyOwner{
        completeEnd=time;
    }
   
   
   
    constructor(address _wallet, address _token )  {
    require(_wallet != address(0),"invalid address");
    require(_token != address(0),"invalid address");  

    wallet_ = _wallet;
    token_ = IERC20(_token);
    
    }
    
    struct proposal{
    uint256 id;
    bool isToken;
    bool accept;
    bool deny;
    bool time;
    uint256 amount;
    address sender;
    address reciver;
    uint256 timeStart; 
    uint256 timeEnd;   
    uint256 offerSend;
    uint256 offerEnd;
    }

    struct Review{
    uint256 ProjectId;
    uint256 reviewId;
    uint256 reviewStart;
    uint256 reviewEnd;
    bool amontFreze;
    bool complete;
    uint256 completeStart;
    uint256 completeEnd;   
    }
  
    
    function shoperPercentageAmount(uint256 amount) private view returns (uint256) {
        return (amount * shoper_) / 10000;
    }

    function freelancerPercentageAmount(uint256 amount) private view returns (uint256) {
        return (amount * freelancer_) / 10000;
    }
  
   function setTokenAddress(address _wallet) public onlyOwner {
    wallet_ =_wallet;
    }

    function setwalletAddress(address _addr) public onlyOwner {
    token_ = IERC20(_addr);
    }
    
      
    function sendofferViaToken(address _addr, uint256 _amount) external  {
       require(_amount>0,"amount must b grater than 0");  
        projectIds_.increment();
        uint256 pIds = projectIds_.current();
      
    bool _transfer = token_.transferFrom(msg.sender,address(this),_amount);
    require(_transfer , "transfer failed");
    approve_[pIds]=proposal(pIds,true,false,false,false,_amount,msg.sender,_addr,0,0,block.timestamp,block.timestamp+acceptLimit_);

    
    }

    function sendofferViaBNB(address _addr) external payable {
         require(msg.value > 0,"BNB value  must b grater than 0"); 
        projectIds_.increment();
        uint256 pIds = projectIds_.current();
         ( bool _transfer,) = address(this).call{value: msg.value}("");
    require(_transfer , "transfer failed");
    approve_[pIds]=proposal(pIds,false,false,false,false,msg.value,msg.sender,_addr,0,0,block.timestamp,block.timestamp+acceptLimit_);
    }
    

    function offerComplete(address _addr, uint256 projectId)external{
    require(approve_[projectId].sender == msg.sender,"you don't assign this offer");
    require(approve_[projectId].reciver == _addr,"you enter address is wrong");
    approve_[projectId].time = true;
    approve_[projectId].timeStart = block.timestamp;
    approve_[projectId].timeEnd = block.timestamp + withdrawLimit_;//mints
    }

    
    function acceptOffer(uint256 projectId) nonReentrant external{  
    require(approve_[projectId].reciver == msg.sender,"dont have offer");
    require(approve_[projectId].accept == false,"you already accept this offer");
    require(approve_[projectId].deny == false,"you deny this offer");
    require(approve_[projectId].offerEnd>block.timestamp,"offer time ended, you lose the offer");
    
   // proposal storage project = approve_[projectId];
    
    uint256 tenPercentage = shoperPercentageAmount(approve_[projectId].amount);
    // uint256 reminAmount = project.amount-tenPercentage;
    //token.transferFrom(project.sender,wallet_, tenPersontage);
    if (approve_[projectId].isToken == true){
    bool _transfer = token_.transfer(wallet_, tenPercentage);
    require(_transfer , "transfer failed");
    }
    if (approve_[projectId].isToken == false){
    (bool _transfer,) = wallet_.call{value:tenPercentage}("");
    require(_transfer , "transfer failed");
    }
    approve_[projectId].amount=approve_[projectId].amount-tenPercentage;
    approve_[projectId].accept=true;
    }

    
    function refuseToOffer(uint256 projectId) nonReentrant public returns(string memory) {
    if(approve_[projectId].reciver == msg.sender){
    require(approve_[projectId].deny == false,"you already approve_");
    approve_[projectId].deny=true;
    // uint256 Transferamount = approve_[projectId].amount;
    if (approve_[projectId].isToken == true){
    bool _transfer = token_.transfer(approve_[projectId].sender, approve_[projectId].amount);
    require(_transfer , "transfer failed");
    }
    if (approve_[projectId].isToken == false){
       ( bool _transfer, )= approve_[projectId].sender.call{value:(approve_[projectId].amount)}("") ;
    require(_transfer , "transfer failed");
    }
    approve_[projectId].amount = 0;
    return "sucessfull";
    }
    else {
        return "id not found";
    }
        
    }

   
    function withdraw(address _addr, uint256 projectId) nonReentrant external {
   
    if (approve_[projectId].accept == false && approve_[projectId].deny == false){
    require(approve_[projectId].reciver == _addr,"you enter address is wrong");
    require(review_[projectId].amontFreze == false,"please respone review_ request");
    require( review_[projectId].complete == false,"please complete the project");
    require(review_[projectId].completeEnd < block.timestamp,"wait for complete review time");
    require(approve_[projectId].offerEnd < block.timestamp,"please wait 48 hours");
    uint256 Transferamount = approve_[projectId].amount;
    if (approve_[projectId].isToken == true){
    bool _transfer = token_.transfer(approve_[projectId].sender , Transferamount);
    require(_transfer , "transfer failed");
    }
    if (approve_[projectId].isToken ==false){
        (bool _transfer,) = approve_[projectId].sender.call{value:  Transferamount}("");
       require(_transfer , "transfer failed");
    }
    approve_[projectId].amount = 0;

    }

    else if (approve_[projectId].accept == true && approve_[projectId].deny == false){

    require(review_[projectId].amontFreze == false,"please respone review_ request");
    require( review_[projectId].complete == false,"please complete the project");
    require(review_[projectId].completeEnd < block.timestamp,"wait for complete review time");
    require(approve_[projectId].reciver == msg.sender,"you are not the owner");
    require(approve_[projectId].time == true,"time is not started");
    require(approve_[projectId].timeEnd <=block.timestamp,"wait for withdraw time");
    uint256 twelve = freelancerPercentageAmount(approve_[projectId].amount);
    uint256 Transferamount = approve_[projectId].amount - twelve;
    if (approve_[projectId].isToken == true){
    bool _transfer = token_.transfer(msg.sender, Transferamount);
    require(_transfer , "transfer failed");
    bool _wallet_transfer = token_.transfer(wallet_, twelve);
    require(_wallet_transfer , "transfer failed");
    }
    if (approve_[projectId].isToken == false){
       (bool _transfer,) =  msg.sender.call{value: Transferamount}("");
    require(_transfer , "transfer failed");
    (bool _wallet_transfer,) = wallet_.call{value: twelve}("");
    require(_wallet_transfer , "transfer failed");
    }
    approve_[projectId].amount = 0;

    }
    
    }

    

    function getIdAddress(uint256 projectId) public view returns( proposal[] memory ){ 
        proposal[] memory items = new proposal[](projectId); 
        proposal storage currentItem = approve_[projectId]; 
        items[0] = currentItem; 
        return items; 
    }


    function changeRequest(address addr, uint256 projectId) public {
    require(approve_[projectId].sender == msg.sender,"you are not the shoper_");
    require(approve_[projectId].time == true,"time is not started"); 
    require(approve_[projectId].timeEnd > block.timestamp,"time is completed");
    if(approve_[projectId].reciver == addr){
    reviewId_.increment();
    uint256 rId = reviewId_.current();
    uint256 endTime=block.timestamp + reviewLimit_ ; //48 hours
    review_[projectId]=Review(projectId,rId,block.timestamp,endTime,true,false,0,0);
    }
    }

    function response (uint256 projectId)public{
        require(approve_[projectId].reciver == msg.sender,"you are not a reciver");
        if(review_[projectId].reviewEnd > block.timestamp){
            review_[projectId].amontFreze = false;
            review_[projectId].complete = true;
            review_[projectId].completeStart= block.timestamp;
            review_[projectId].completeEnd= block.timestamp + completeEnd;     
        }
        else {
            revert("response time is over ");
        }

    }


    function fetchIncomingOffer(address acount) public view returns (proposal[] memory) { 
        uint totalItemCount = projectIds_.current(); 
        uint itemCount = 0; 
        uint currentIndex = 0; 
  
        for (uint i = 0; i < totalItemCount; i++) { 
        if (approve_[i + 1].reciver == acount) { 
        itemCount += 1; 
        } 
        } 
  
        proposal[] memory items = new proposal[](itemCount); 
        for (uint i = 0; i < totalItemCount; i++) { 
         if (approve_[i + 1].reciver ==acount) { 
         uint currentId = i + 1; 
        proposal storage currentItem = approve_[currentId]; 
        items[currentIndex] = currentItem; 
        currentIndex += 1; 
        } 
        } 
    return items; 
         } 


        function fetchOutgoingOffer(address acount) public view returns (proposal[] memory) { 
        uint totalItemCount = projectIds_.current(); 
        uint itemCount = 0; 
        uint currentIndex = 0; 
  
        for (uint i = 0; i < totalItemCount; i++) { 
        if (approve_[i + 1].sender == acount) { 
        itemCount += 1; 
        } 
        } 
  
        proposal[] memory items = new proposal[](itemCount); 
        for (uint i = 0; i < totalItemCount; i++) { 
         if (approve_[i + 1].sender ==acount) { 
         uint currentId = i + 1; 
        proposal storage currentItem = approve_[currentId]; 
        items[currentIndex] = currentItem; 
        currentIndex += 1; 


        } 
        } 
    return items; 
         } 


    function getAllOffers(address account) public view returns(uint256){  
        uint totalItemCount = projectIds_.current(); 
        uint itemCount = 0; 
  
        for (uint i = 0; i < totalItemCount; i++) { 
        if (approve_[i + 1].reciver == account) { 
        itemCount += 1; 
        } 
        } 
            return itemCount;
        }
    function reviewComplete(uint256 projectId, bool value) external {
        if(value == false){
        review_[projectId].completeStart= block.timestamp;
            review_[projectId].completeEnd= block.timestamp + completeEnd;
         }
   
    if (approve_[projectId].reciver == msg.sender){
    require(review_[projectId].amontFreze == false,"please respone review request");
            review_[projectId].complete = !value;//false  
        }
    else if (approve_[projectId].sender == msg.sender){
        require(review_[projectId].completeEnd > block.timestamp,"you draft time is completed");
        review_[projectId].complete = !value;//true 

    }
    

    }
    receive() external payable {}
}