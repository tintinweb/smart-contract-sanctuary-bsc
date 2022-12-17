// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getTokenIds(address _owner) external view returns (uint256[] memory);
}

interface WM{
    function UsersKey(address _userAddress) external view returns (WMuser memory);
}

struct WMuser {
    uint256 startDate;
    uint256 divs;
    uint256 refBonus;
    uint256 totalInits;
    uint256 totalWiths;
    uint256 totalAccrued;
    uint256 lastWith;
    uint256 timesCmpd;
    uint256 keyCounter;
}

contract KongStake is Ownable, ReentrancyGuard {
    struct user{   
        uint256 totalStakedBalance;
        uint256 totalClaimed;
        uint256 totalCompounded;
        uint256 totalReferred;
        uint256 unclaimedReferral;
        uint256 createdTime;
    }

    struct userStake{
        uint256 id;
        uint256 roi;
        uint256 unstakeFee;
        uint256 withdrawalFee;
        uint256 compoundFee;
	    uint256 stakeAmount;
    	uint256 totalClaimed;
        //uint256 totalCompounded;
    	uint256 lastActionedTime;
        uint256 nextActionTime;
        uint256 status; //0 : Unstaked, 1 : Staked
        address referrer;
        address owner;
    	//uint256 createdTime;
    }

    userStake[] public userStakeArray;

    address public dev = 0x9B9C918FAC2DFCCaFff3B95b4f46FD9A5D9D701b;
    uint256 public minDeposit = 10 ether; //Minimum stake 10 BUSD
    uint256 public stakeFee = 500; //5%
    uint256 public withdrawalFee = 1000; //10%
    uint256 public minWithdrawalFee = 500; //5%
    uint256 public compoundFee = 500; //5%
    uint256 public unstakeFee = 2000; //20%
    uint256 public minUnstakeFee = 500; //5%
    uint256 public feeBalancer = 5; //0.05%
    uint256 public referralFee = 600; //6%
    uint256 public nftHolderReferralFee = 200; //2%
    uint256 public baseDailyRoi = 200; //2%
    uint256 public minDailyRoi = 100; //1%
    uint256 public nftHolderExtraRoi = 100; //1%
    uint256 public wmUserExtraRoi = 100; //1%
    
    mapping (uint256 => userStake) public userStakesById;
    mapping (address => uint256[]) public userStakeIds;
    mapping (address => userStake[]) public userStakeLists;
    mapping (address => user) public users;

    
    uint256 public totalUsers;
    uint256 public totalStakedBalance;
    uint256 public totalClaimedBalance;
    uint256 public totalCompoundedBalance;
    

    uint256 public stakeIndex;

    bool public isStarted = false;

    //Testnet
    address public busdAddress = 0xAe12F7EeA8FF55383109E0B28B95300082c5f78e;
    IERC20 busd = IERC20(busdAddress);

    address public nftAddress = 0x5d0b33939334F114983d2A2e7a68b2801ee6dc0D;
    IERC20 nft = IERC20(nftAddress);

    address public wmAddress = 0x5D0D55b5C0657d394907F2128FB956fE6CE4F529;
    WM wm = WM(wmAddress);
    
    function startStake() public onlyOwner{
        require(isStarted == false,"Stake is already started");
        isStarted = true;
    }

    function stake(uint256 _amount, address _referrer) external returns (bool) {
        require(isStarted == true,"Staking is not started yet");
        require(_referrer != msg.sender,"You can not refer to yourself");
        require(_amount >= 10 ether,"Stake amount is below minimum limit");
        require(busd.allowance(msg.sender, address(this)) >= _amount,"Not enough BUSD approved for transfer"); 
        bool success = busd.transferFrom(msg.sender, address(this), _amount);
        require(success, "BUSD Transfer failed.");
        userStake memory userStakeDetails;
        uint256 stakeId = stakeIndex++;
        userStakeDetails.id = stakeId;
        userStakeDetails.stakeAmount = _amount;
        userStakeDetails.roi = getApplicableRoi();
        userStakeDetails.unstakeFee = 2000; //Base unstake fee 20% set
        userStakeDetails.withdrawalFee = 1000; //Base withdraw fee 10% set
        userStakeDetails.compoundFee = 500; //Base compound fee 5% set
        userStakeDetails.lastActionedTime = block.timestamp;
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        userStakeDetails.status = 1;
        userStakeDetails.referrer = _referrer;
        userStakeDetails.owner = msg.sender;
        //userStakeDetails.createdTime = block.timestamp;
        userStakesById[stakeId] = userStakeDetails;
        uint256[] storage userStakeIdsArray = userStakeIds[msg.sender];
        userStakeIdsArray.push(stakeId);
        userStakeArray.push(userStakeDetails);
        userStake[] storage userStakeList = userStakeLists[msg.sender];
        userStakeList.push(userStakeDetails);
        user memory userDetails = users[msg.sender];
        if(userDetails.createdTime == 0){ // Staker is a new user
            userDetails.createdTime = block.timestamp;
            //totalUsers++;
        }
        userDetails.totalStakedBalance += _amount;
        users[msg.sender] = userDetails;
        //totalStakedBalance = totalStakedBalance + _amount;   
        uint256 devStakeFeeAmount = (_amount * 500) / 10000; //5% stake fee applied
        busd.transfer(dev,devStakeFeeAmount);
        uint256 referrerAmount = (_amount * 600) / 10000; //Base referral fee
        if(nft.balanceOf(_referrer) > 0){
            referrerAmount = (_amount * (600 + 200)) / 10000; //NFT holder gets 2% extra referral bonus
        }
        user memory referralUserDetails = users[_referrer];
        referralUserDetails.totalReferred += referrerAmount;
        referralUserDetails.unclaimedReferral += referrerAmount;
        users[_referrer] = userDetails;
        return true;
    }

    function unstake(uint256 _stakeId) nonReentrant external returns (bool){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        uint256 stakeAmount = userStakeDetails.stakeAmount;
        require(userStakeDetails.owner == msg.sender,"You don't own this stake");
        require(userStakeDetails.status == 1,"You already have unstaked");
        userStakeDetails.status = 0;
        userStakesById[_stakeId] = userStakeDetails;
        user memory userDetails = users[msg.sender];
        userDetails.totalStakedBalance = userDetails.totalStakedBalance - stakeAmount;
        users[msg.sender] = userDetails;
        updateStakeArray(_stakeId);
        //totalStakedBalance =  totalStakedBalance - stakeAmount;
        uint256 referrerAmount = (stakeAmount * 600) / 10000; //Referral paid deducted from unstake ammount
        uint256 unstakableAmount = userStakeDetails.stakeAmount - (userStakeDetails.totalClaimed + referrerAmount);
        require(unstakableAmount > 0,"Cannot unstake, already claimed more than staked amount");
        uint256 unstakeFeeAmount = (unstakableAmount * userStakeDetails.unstakeFee) / 10000;
        uint256 devFeeAmount = unstakeFeeAmount / 2;
        unstakableAmount = unstakableAmount - unstakeFeeAmount;
        require(busd.balanceOf(address(this)) >= unstakableAmount, "Insufficient contract balance"); 
        bool success = busd.transfer(dev, devFeeAmount);
        require(success, "BUSD Transfer failed.");
        success = busd.transfer(msg.sender, unstakableAmount);
        require(success, "BUSD Transfer failed.");
        return true;
    }

    function claim(uint256 _stakeId) nonReentrant public returns (bool){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        require(userStakeDetails.owner == msg.sender,"You don't own this stake");
        require(userStakeDetails.status == 1, "You can not claim after unstaked");
        require(userStakeDetails.totalClaimed <= (userStakeDetails.stakeAmount * 3),"You can not claim more than 3x of your investment");
        require(userStakeDetails.nextActionTime <= block.timestamp,"You can not withdraw more than once in 24 hours");
        uint256 unclaimedBalance = getClaimableBalance(_stakeId);
        uint256 devWithdrawFeeAmount = (unclaimedBalance * userStakeDetails.withdrawalFee) / 10000;
        uint256 referrerAmount;
        if(nft.balanceOf(userStakeDetails.referrer) > 0){
            referrerAmount = (unclaimedBalance * (200)) / 10000; //NFT holder gets 2% passive income on every withdrawals
            devWithdrawFeeAmount -= referrerAmount;
        }
        userStakeDetails.totalClaimed = userStakeDetails.totalClaimed + 10000;
        userStakeDetails.lastActionedTime = block.timestamp;
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        if(userStakeDetails.roi > 100){ //Can not go below minimum roi 1% 
            userStakeDetails.roi -= 5; //0.05% ROI increased
        }
        if(userStakeDetails.withdrawalFee < 1000){ //Can not go below above 10%
            userStakeDetails.withdrawalFee += 5; //0.05% withdrawl fee incresed
        }
        if(userStakeDetails.unstakeFee < 2000){ //Unstake fee can not go above bas 20% fee
            userStakeDetails.unstakeFee += 5; //0.05% unstake fee increased if current fee is less than 20%
        }
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);
        //totalClaimedBalance += unclaimedBalance;
        user memory userDetails = users[msg.sender];
        userDetails.totalClaimed  +=  unclaimedBalance;
        users[msg.sender] = userDetails;
        require(busd.balanceOf(address(this)) >= unclaimedBalance, "Insufficient contract balance");
        bool success = busd.transfer(msg.sender, unclaimedBalance);
        require(success, "BUSD Transfer failed.");
        success = busd.transfer(dev, devWithdrawFeeAmount);
        require(success, "BUSD Transfer failed.");
        if(referrerAmount > 0){
            success = busd.transfer(userStakeDetails.referrer, referrerAmount);
            require(success, "BUSD Transfer failed.");
        }
        return true;
    }

    function compound(uint256 _stakeId) nonReentrant public returns (bool){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        require(userStakeDetails.owner == msg.sender,"You don't own this stake");
        require(userStakeDetails.status == 1, "You can not claim after unstaked");
        require(userStakeDetails.nextActionTime <= block.timestamp,"You can not compound more than once in 24 hours");
        uint256 unclaimedBalance = getClaimableBalance(_stakeId);
        //userStakeDetails.totalCompounded = userStakeDetails.totalCompounded + unclaimedBalance;
        userStakeDetails.lastActionedTime = block.timestamp;
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        if(userStakeDetails.roi < getApplicableRoi()){
            userStakeDetails.roi += 5; //0.05% ROI increased on compounding
        }
        if(userStakeDetails.withdrawalFee > 500){ //Withdraw fee can not go down below 5%
            userStakeDetails.withdrawalFee -= 5; //0.05% withdraw fee decreased on compounding
        }
        if(userStakeDetails.unstakeFee > 500){ //Unstake fee can not go down below 5%
            userStakeDetails.unstakeFee -= 5; //0.05% unstake fee decreased on compounding
        }
        userStakeDetails.stakeAmount += unclaimedBalance;
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);
        //totalCompoundedBalance += unclaimedBalance;
        user memory userDetails = users[msg.sender];
        userDetails.totalCompounded  +=  unclaimedBalance;
        users[msg.sender] = userDetails;
        return true;
    }

    function claimReferral() public {
        user memory referralUserDetails = users[msg.sender];
        require(referralUserDetails.totalStakedBalance > 0,"You do not have any active stakes");
        uint256 referralClaimAmount = referralUserDetails.unclaimedReferral = 0;
        bool success = busd.transfer(msg.sender, referralClaimAmount);
        require(success, "BUSD Transfer failed.");
    }

    function getClaimableBalance(uint256 _stakeId) public view returns(uint256){
        userStake memory userStakeDetails = userStakeArray[_stakeId];
        uint256 roi = userStakeDetails.roi;
        uint applicableRewards = (userStakeDetails.stakeAmount * roi)/(10000); //divided by 10000 to handle decimal percentages like 0.1%
        uint unclaimedRewards = (applicableRewards * getElapsedTime(_stakeId));
        return unclaimedRewards; 
    }

    function getElapsedTime(uint256 _stakeId) public view returns(uint256){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        uint256 lapsedDays = ((block.timestamp - userStakeDetails.lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
        return lapsedDays;  
    }

    function getApplicableRoi() public view returns(uint256) {
        uint256 userROI = 200; //base 2% ROI
        WMuser memory wmUserDetails =  checkWMuser(msg.sender);
        if(wmUserDetails.totalInits > 0){
            userROI += 100; //Extra 1% ROI for WM users
        }
        if(nft.balanceOf(msg.sender) > 0){
            userROI += 100; //Extra 1% ROI for NFT holders 
        }
        return userROI;
    }
    
    function checkWMuser(address _userAddress) public view returns (WMuser memory){
        return wm.UsersKey(_userAddress);
    }

    function getUserStakeOwner(uint256 _stakeId) public view returns (address){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        return userStakeDetails.owner;
    }

    function getUserStakeIds() public view returns(uint256[] memory){
        return (userStakeIds[msg.sender]);
    }

    function getUserStakeIdsByAddress(address _userAddress) public view returns(uint256[] memory){
         return(userStakeIds[_userAddress]);
    }

    function getUserAllStakeDetails() public view returns(userStake[] memory){
        return (userStakeLists[msg.sender]);
    }

    function getUserAllStakeDetailsByAddress(address _userAddress) public view returns(userStake[] memory){
        return (userStakeLists[_userAddress]);
    }
    
    function updateStakeArray(uint256 _stakeId) internal {
        userStake[] storage userStakesArray = userStakeLists[msg.sender];
        
        for(uint i = 0; i < userStakesArray.length; i++){
            userStake memory userStakeFromArrayDetails = userStakesArray[i];
            if(userStakeFromArrayDetails.id == _stakeId){
                userStake memory userStakeDetails = userStakesById[_stakeId];
                userStakesArray[i] = userStakeDetails;
            }
        }
    }
    receive() external payable {}
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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