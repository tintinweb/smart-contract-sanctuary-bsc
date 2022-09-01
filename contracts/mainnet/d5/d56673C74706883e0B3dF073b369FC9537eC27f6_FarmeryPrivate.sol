/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

/**
 *Submitted for verification at Etherscan.io on 2022-08-13
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
}

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


contract FarmeryPrivate is Ownable{    
    
   // Our Token Contract
   IERC20 token;
   uint256 public tokensPerBnb = 0;

   // bnb spend per user 
   mapping (address => profile) public buyerProfile;
   struct profile{
        uint256 boughtAmount;
        uint256 claimedAmount;
        bool claimed;
    }

   enum State { active, disabled, finished, claim }
   State public _status;

   uint256 public hardcap;
   uint256 public minBuy;
   uint256 public maxBuy;
   uint256 contributers; 
   
  uint256 totalBought;

  event BuyTokens(address buyer, uint256 amountOfETH);
  event ClaimTokens(address claimer, uint256 amountClaimed);

  constructor(){
    hardcap = 99 ether;
    minBuy = 0.3 ether;
    maxBuy = 3 ether;
    _status = State.disabled;
  }

    // user buys tokens 
    function buyTokens() external payable{
        
        require(_status == State.active, "Sale not active");
        require(msg.value >= minBuy, "Buy amount to low");
        require(buyerProfile[msg.sender].boughtAmount + msg.value <= maxBuy, "Max buy exceeded");
        require(currentRaise() + msg.value <= hardcap, "Hardcap reached" );

        if(buyerProfile[msg.sender].boughtAmount == 0 ){
            contributers++;
        }

        // set bought amount 
        buyerProfile[msg.sender].boughtAmount += msg.value;
        totalBought += msg.value;


        if(totalBought == hardcap){
            _status = State.finished;
        }

        // emit the event
        emit BuyTokens(msg.sender, msg.value);
    }

    // user can claim token amount 
    function claimTokens() external{
        require(_status == State.claim, "Claim phase not started");
        require(!buyerProfile[msg.sender].claimed, "Already claimed");

        uint256 tokenRate = calculateTokenAmount();
      
        require(token.transfer(msg.sender, tokenRate),"Failed transfer");

        buyerProfile[msg.sender].claimedAmount = tokenRate;
        buyerProfile[msg.sender].claimed = true;

        emit ClaimTokens(msg.sender, tokenRate);
    }

    // returns bought token amount with current swap rate
    function calculateTokenAmount() public view returns(uint256){
       return(buyerProfile[msg.sender].boughtAmount * tokensPerBnb);
    }

    // returns bought token amount with current swap rate
    function getProfile() public view returns(profile memory){
       return(buyerProfile[msg.sender]);
    }

     function currentRaise() public view returns(uint256){
       return totalBought;
    }

    // set sale state
    function setState(State _state) external onlyOwner{
     _status = _state;
    }

    // update token that gets sold
    function updateToken(IERC20 _token) external onlyOwner {
        token = _token;
    }

    //update buys stats
    function updateBuyLimits(uint256 _min, uint256 _max) external onlyOwner {
        minBuy = _min;
        maxBuy = _max;
    }

    // update hardcap
    function updateHardcap(uint256 _hardcap) external onlyOwner {
        hardcap = _hardcap;
    }

    // update hardcap
    function updateTokenRate(uint256 _rate) external onlyOwner{
        tokensPerBnb = _rate;
    }

    // withdraw current set tokens
    function withdrawTokens() external onlyOwner {        
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    // withdraw collected funds
    function withdrawBnb() external onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }

    function fetchData() external view returns(bytes memory){
        return abi.encode(minBuy, maxBuy, hardcap, _status, contributers, buyerProfile[msg.sender].boughtAmount , calculateTokenAmount(),currentRaise(),tokensPerBnb, buyerProfile[msg.sender].claimed);
    }

    receive() external payable {}
}