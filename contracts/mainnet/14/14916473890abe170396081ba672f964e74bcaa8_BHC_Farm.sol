/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

/*
 ________  ___  ___  ________     
|\   __  \|\  \|\  \|\   ____\    
\ \  \|\ /\ \  \\\  \ \  \___|    
 \ \   __  \ \   __  \ \  \       
  \ \  \|\  \ \  \ \  \ \  \____  
   \ \_______\ \__\ \__\ \_______\
    \|_______|\|__|\|__|\|_______|
                                  
                                  
Written by The Great Engineers @ 21C
[email protected]
flattened 19/07/22
*/


// File @openzeppelin/contracts/token/ERC20/[email protected]

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
interface IAlpaca{
    function deposit(uint256 bnb) external payable;
    function withdraw(uint256 share) external;
}
interface IBHC_Rewards {
    function DepositBNB() external payable;
}

// File contracts/SolStake/sETH.sol
/*
  _________      .__    _________ __          __           
 /   _____/ ____ |  |  /   _____//  |______  |  | __ ____  
 \_____  \ /  _ \|  |  \_____  \\   __\__  \ |  |/ // __ \ 
 /        (  <_> )  |__/        \|  |  / __ \|    <\  ___/ 
/_______  /\____/|____/_______  /|__| (____  /__|_ \\___  >
        \/                    \/           \/     \/    \/ ETHv1

SolStake is a simple solidity scaffolding library for providing User Staking Data when Staking ERC20 or ETH to a Smart Contract

Yielding & Farming must be implemented seperatly

Repo & Implementation Example can be found here: https://github.com/Kwame0/SolStake

*/
contract SolStakeEth is ReentrancyGuard, Ownable {

    uint256 public UNSTAKEABLE_FEE = 9200; // How much can they Unstake? 92% AKA 8% Staking FEE
    uint256 public MINIMUM_CONTRIBUTION_AMOUNT = 0.05 ether; // Minimum Amount to Stake

    uint256 public HOT_BNB;
    uint256 public COLD_BNB;

    uint256 private constant MAX_UINT = type(uint256).max;

    bool public CONTRACT_RENOUNCED = false; // for ownerOnly Functions

    address public constant alBNB = 0xd7D069493685A581d27824Fc46EdA46B7EfC0063;
    address public constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address public constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address public constant PCS_ROUTER_V2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    string private constant NEVER_CONTRIBUTED_ERROR = "This address has never contributed BNB to the protocol";
    string private constant NO_ETH_CONTRIBUTIONS_ERROR = "No BNB Contributions";
    string private constant MINIMUM_CONTRIBUTION_ERROR = "Contributions must be over the minimum contribution amount";

    struct Staker {
      address addr; // The Address of the Staker
      uint256 lifetime_contribution; // The Total Lifetime Contribution of the Staker
      uint256 contribution; // The Current Contribution of the Staker
      uint256 yield; // The Current Yield / Reward amount of the Staker
      uint256 last_yield_time;
      uint256 unstakeable; // How much can the staker withdraw.
      uint256 joined; // When did the Staker start staking
      bool exists;
    }

    mapping(address => Staker) public stakers;
    address[] public stakerList;

    constructor() ReentrancyGuard() {
      IERC20(WBNB).approve(PCS_ROUTER_V2, MAX_UINT);
    }

    receive() external payable {}
    fallback() external payable {}


    function AddStakerYield(address addr, uint256 a) private {
      stakers[addr].yield = stakers[addr].yield + a;
    }

    function RemoveStakerYield(address addr, uint256 a) private {
      stakers[addr].yield = stakers[addr].yield - a;
    }

    function RenounceContract() external onlyOwner {
      CONTRACT_RENOUNCED = true;
    }

    function ChangeMinimumStakingAmount(uint256 a) external onlyOwner {
        MINIMUM_CONTRIBUTION_AMOUNT = a;
    }

    function ChangeUnstakeableFee(uint256 a) external onlyOwner {
        UNSTAKEABLE_FEE = a;
    }

    function UnstakeAll() external onlyOwner {
        if(CONTRACT_RENOUNCED == true){revert("Unable to perform this action");}
        for (uint i = 0; i < stakerList.length; i++) {
            address user = stakerList[i];
            ForceRemoveStake(user);
        }
    }

    function Stake() external nonReentrant payable {
      require(msg.value >= MINIMUM_CONTRIBUTION_AMOUNT, MINIMUM_CONTRIBUTION_ERROR);
      uint256 bnb = msg.value;
      uint256 unstakeable = (bnb * UNSTAKEABLE_FEE) / 10000;

      if(StakerExists(msg.sender)){
        stakers[msg.sender].lifetime_contribution = stakers[msg.sender].lifetime_contribution + bnb;
        stakers[msg.sender].contribution = stakers[msg.sender].contribution + unstakeable;
        stakers[msg.sender].unstakeable = stakers[msg.sender].unstakeable + unstakeable;
      }else{
        // Create new user
        Staker memory user;
        user.addr = msg.sender;
        user.contribution = unstakeable;
        user.lifetime_contribution = bnb;
        user.yield = 0;
        user.exists = true;
        user.unstakeable = unstakeable;
        user.joined = block.timestamp;
        user.last_yield_time = block.timestamp;
        // Add user to Stakers
        stakers[msg.sender] = user;
        stakerList.push(msg.sender);
      }
      
      uint256 c = (10000 - UNSTAKEABLE_FEE);
      uint256 fee = (bnb * c) / 10000;
      IAlpaca(alBNB).deposit{ value: msg.value }(msg.value);
      IncreaseHotBNB(unstakeable);
      IncreaseColdBNB(fee);
    }

    function RemoveStake() external {
      address user = msg.sender;
      if(!StakerExists(user)){ revert(NEVER_CONTRIBUTED_ERROR); }
      uint256 uns = stakers[user].unstakeable;
      if(uns == 0){ revert("This user has nothing to withdraw from the protocol"); }
      // Remove Stake
      DecreaseHotBNB(uns);
      stakers[user].unstakeable = 0;
      stakers[user].contribution = 0;
      // Get from vault
      IAlpaca(alBNB).withdraw(IERC20(alBNB).balanceOf(address(this)));
      payable(user).transfer(uns);
      IAlpaca(alBNB).deposit{ value: address(this).balance }(address(this).balance);
    }

    function ForceRemoveStake(address user) private {
      if(!StakerExists(user)){ revert(NEVER_CONTRIBUTED_ERROR); }
      uint256 uns = stakers[user].unstakeable;
      if(uns == 0){ revert("This user has nothing to withdraw from the protocol"); }
      // Remove Stake
      DecreaseHotBNB(uns);
      stakers[user].unstakeable = 0;
      stakers[user].contribution = 0;
      // Get from vault
      IAlpaca(alBNB).withdraw(IERC20(alBNB).balanceOf(address(this)));
      payable(user).transfer(uns);
      IAlpaca(alBNB).deposit{ value: address(this).balance }(address(this).balance);
    }

    /* 

      CONTRIBUTER GETTERS

    */

    function StakerExists(address a) public view returns(bool){
      return stakers[a].exists;
    }

    function StakerCount() public view returns(uint256){
      return stakerList.length;
    }

    function GetStakeJoinDate(address a) public view returns(uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      return stakers[a].joined;
    }

    function GetStakerYield(address a) public view returns(uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      return stakers[a].yield;
    }
  
    function GetStakingAmount(address a) public view returns (uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      return stakers[a].contribution;
    }

    function GetStakerPercentageByAddress(address a) public view returns(uint256){
      if(!StakerExists(a)){revert(NEVER_CONTRIBUTED_ERROR);}
      uint256 c_total = 0;
      for (uint i = 0; i < stakerList.length; i++) {
         c_total = c_total + stakers[stakerList[i]].contribution;
      }
      if(c_total == 0){revert(NO_ETH_CONTRIBUTIONS_ERROR);}
      return (stakers[a].contribution * 10000) / c_total;
    }

    function GetStakerUnstakeableAmount(address addr) public view returns(uint256) {
      if(StakerExists(addr)){ return stakers[addr].unstakeable; }else{ return 0; }
    }

    function GetLifetimeContributionAmount(address a) public view returns (uint256){
      if(!StakerExists(a)){revert("This address has never contributed DAI to the protocol");}
      return stakers[a].lifetime_contribution;
    }

    function CheckContractRenounced() external view returns(bool){
      return CONTRACT_RENOUNCED;
    }

    function IncreaseHotBNB(uint256 bnb) internal { HOT_BNB = HOT_BNB + bnb; }
    function IncreaseColdBNB(uint256 bnb) internal { COLD_BNB = COLD_BNB + bnb; }

    
    function DecreaseHotBNB(uint256 bnb) internal { HOT_BNB = HOT_BNB - bnb; }
    function DecreaseColdBNB(uint256 bnb) internal { COLD_BNB = COLD_BNB - bnb; }



}
contract BHC_Farm is ReentrancyGuard, Ownable, SolStakeEth {

    string public name = "BitcoinHODLClub Token Farm";
    string public symbol = "BHCFarm";

    address public BHC_ADDRESS = 0x5AC9E12edA36ef773A98a4102DD95c43a1F7e500;
    address public BHC_BTCB_FARM_ADDRESS = 0x32a777c81551CCdd8707c60ad69302Fa4267De27;

    uint256 public HOT_BHC;

    uint256 BIG_NUM = 10 ** 18;
    uint256 EMISSION_RATE = 710; // 710 $BHC A DAY PER 1 BNB

    constructor() {

    }

    function UpdateYields() public {
        for (uint i = 0; i < stakerList.length; i++) {
            address user = stakerList[i];
            uint256 cur_time = block.timestamp;
            uint256 yield_time = cur_time - stakers[user].last_yield_time;
            uint256 yield_day_total = (EMISSION_RATE * BIG_NUM) * stakers[user].contribution;
            uint256 yield_per_second = yield_day_total / (86400 * BIG_NUM);
            uint256 yield = yield_time * yield_per_second;
            if(yield <= HOT_BHC){
                stakers[user].yield = stakers[user].yield + yield;
                stakers[user].last_yield_time = block.timestamp;
                HOT_BHC = HOT_BHC - yield;  
            }else if(HOT_BHC > 0){
                stakers[user].yield = stakers[user].yield + HOT_BHC;
                stakers[user].last_yield_time = block.timestamp;
                HOT_BHC = HOT_BHC - HOT_BHC;  
            }else{
                revert("There is not enough $BHC to yield");
            }
        }
    }

    function CollectYields() public {
        address user = msg.sender;
        if(!StakerExists(user)){revert("This address has never contributed BNB to the protocol");}
        uint256 y = stakers[user].yield;
        stakers[user].yield = 0;
        stakers[user].last_yield_time = block.timestamp;
        if(IERC20(BHC_ADDRESS).balanceOf(address(this)) > 0){
            bool s = IERC20(BHC_ADDRESS).transfer(user, y);
            if(!s){revert("Unable to transfer BHC");}
        }else{
            revert("No BHC to collect!");
        }
    }

    function FarmMyYield() public {
        UpdateYields();
        CollectYields();
    }

    function DepositBHC(uint256 amount) external {
        bool s = IERC20(BHC_ADDRESS).transferFrom(msg.sender, address(this), amount);
        if(s){
            HOT_BHC = HOT_BHC + amount;
        }else{
            revert("Unable to transfer BHC");
        }
        
    }

    function SweepBNB() external onlyOwner {
      uint256 a = address(this).balance;
      IncreaseColdBNB(a);
      IAlpaca(alBNB).deposit{ value: a }(a);
    }

    function BTCRewardCheck() public {
        IAlpaca(alBNB).withdraw(IERC20(alBNB).balanceOf(address(this)));
        uint256 newBNB = address(this).balance - (HOT_BNB + COLD_BNB);
        uint256 d = address(this).balance - newBNB;
        if(newBNB > 0){
            IBHC_Rewards(BHC_BTCB_FARM_ADDRESS).DepositBNB{ value: newBNB }();
            IAlpaca(alBNB).deposit{ value: d }(d);
        }else{
            revert("No new BNB for BTC Rewards");
        }
    }

    function SetEmissionRate(uint256 e) external onlyOwner {
        EMISSION_RATE = e;
    }

    function RescueBHC() external onlyOwner {
        uint256 bal = IERC20(BHC_ADDRESS).balanceOf(address(this));
        IERC20(BHC_ADDRESS).transfer(owner(), bal);
    }

    function RescueiBNB() external onlyOwner {
        IAlpaca(alBNB).withdraw(IERC20(alBNB).balanceOf(address(this)));
        uint256 bal = IERC20(WBNB).balanceOf(address(this));
        IERC20(WBNB).transfer(owner(), bal);
    }

    // For future updates BNB/BTC rewards will be sent to the new contract
    function ChangeRewardStructure(address _a) external onlyOwner {
        BHC_BTCB_FARM_ADDRESS = _a;
    }

}