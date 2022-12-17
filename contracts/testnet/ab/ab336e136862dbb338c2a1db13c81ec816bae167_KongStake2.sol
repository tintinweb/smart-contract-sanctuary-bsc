/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


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


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: contracts/KongStake.sol





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

contract KongStake2 is Ownable, ReentrancyGuard {
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
	    uint256 stakeAmount;
    	uint256 totalClaimed;
        uint256 totalCompounded;
    	uint256 lastActionedTime;
        uint256 nextActionTime;
        uint256 status; //0 : Unstaked, 1 : Staked
        address referrer;
        address owner;
    	uint256 createdTime;
    }

    userStake[] public userStakeArray;

    address public dev = 0x2DD3a7Ae8B896520794c8DE43358953BD11a6dB2;
    uint256 public minDeposit = 10 ether; //Minimum stake 10 BUSD
    uint256 public baseDailyRoi = 200; //2%
    uint256 public roiBalancer = 5; //0.05%
    uint256 public minDailyRoi = 100; //1%
    uint256 public maxDailyRoi = 100; //1%
    uint256 public stakeFee = 500; //5%
    uint256 public unstakeFee = 1500; //15% (50% remains in TVL and 50% goes to dev)
    uint256 public withdrawalFee = 600; //6% (2% from this goes to referred NFT holder for passive income)
    uint256 public referralFee = 600; //6%
    uint256 public nftHolderReferralFee = 200; //2%
    uint256 public nftHolderExtraRoi = 100; //1%
    uint256 public wmUserExtraRoi = 100; //1%
    uint256 public percentageDivisor = 10000; //Percentage devisor to handle decimal values
    uint256 public maxReturns = 3; //3x max returns
    
    mapping (uint256 => userStake) public userStakesById;
    mapping (address => uint256[]) public userStakeIds;
    mapping (address => userStake[]) public userStakeLists;
    mapping (address => user) public users;
    mapping (address => bool) public WMrecovered;

    uint256 public totalUsers;
    uint256 public totalStaked;
    uint256 public totalClaimed;
    uint256 public totalCompounded;
  
    uint256 public stakeIndex;

    bool public isStarted = false;

    //Testnet
    address public busdAddress = 0xAe12F7EeA8FF55383109E0B28B95300082c5f78e;
    IERC20 busd = IERC20(busdAddress);

    address public nftAddress = 0x27DF936f822CA87b373603a23009779Aae4588C0;
    IERC20 nft = IERC20(nftAddress);

    address public wmAddress = 0x5D0D55b5C0657d394907F2128FB956fE6CE4F529;
    WM wm = WM(wmAddress);
    

    /*
    //local
    address public busdAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138; 
    IERC20 busd = IERC20(busdAddress);

    address public nftAddress = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
    IERC20 nft = IERC20(nftAddress);

    address public wmAddress = 0xf8e81D47203A594245E36C48e151709F0C19fBe8;
    WM wm = WM(wmAddress);
    */

    function startStake() public onlyOwner{
        require(isStarted == false,"Stake is already started");
        isStarted = true;
    }

    function stake(uint256 _amount, address _referrer) external returns (bool) {
        require(isStarted == true,"Staking is not started yet");
        require(_referrer != msg.sender,"You can not refer to yourself");
        require(_amount >= minDeposit,"Stake amount is below minimum limit");
        require(busd.allowance(msg.sender, address(this)) >= _amount,"Not enough BUSD approved for transfer"); 
        bool success = busd.transferFrom(msg.sender, address(this), _amount);
        require(success, "BUSD Transfer failed.");

        userStake memory userStakeDetails;
        uint256 stakeId = stakeIndex++;
        userStakeDetails.id = stakeId;
        userStakeDetails.stakeAmount = _amount;
        userStakeDetails.roi = getApplicableRoi();
        userStakeDetails.lastActionedTime = block.timestamp;
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        userStakeDetails.status = 1;
        userStakeDetails.referrer = _referrer;
        userStakeDetails.owner = msg.sender;
        userStakeDetails.createdTime = block.timestamp;

        userStakesById[stakeId] = userStakeDetails;

        uint256[] storage userStakeIdsArray = userStakeIds[msg.sender];
        userStakeIdsArray.push(stakeId);
        userStakeArray.push(userStakeDetails);

        userStake[] storage userStakeList = userStakeLists[msg.sender];
        userStakeList.push(userStakeDetails);
        user memory userDetails = users[msg.sender];
        if(userDetails.createdTime == 0){ // Staker is a new user
            userDetails.createdTime = block.timestamp;
            totalUsers++;
        }
        userDetails.totalStakedBalance += _amount;
        users[msg.sender] = userDetails;
        totalStaked += _amount;   
        uint256 devStakeFeeAmount = (_amount * stakeFee) / percentageDivisor;
        busd.transfer(dev,devStakeFeeAmount);
        uint256 referrerAmount = (_amount * referralFee) / percentageDivisor;
        if(nft.balanceOf(_referrer) > 0){
            referrerAmount = (_amount * (referralFee + nftHolderReferralFee)) / percentageDivisor;
        }
        
        user memory referralUserDetails = users[_referrer];
        referralUserDetails.totalReferred += referrerAmount;
        referralUserDetails.unclaimedReferral += referrerAmount;
        users[_referrer] = referralUserDetails;
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
        totalStaked -= stakeAmount;
        uint256 referrerAmount = (stakeAmount * referralFee) / percentageDivisor;
        uint256 unstakableAmount = userStakeDetails.stakeAmount - (userStakeDetails.totalClaimed + referrerAmount);
        require(unstakableAmount > 0,"Cannot unstake, already claimed more than staked amount");
        uint256 unstakeFeeAmount = (unstakableAmount * unstakeFee) / percentageDivisor;
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
        require(userStakeDetails.totalClaimed <= (userStakeDetails.stakeAmount * maxReturns),"You can not claim more than 3x of your investment");
        require(userStakeDetails.nextActionTime <= block.timestamp,"You can not withdraw more than once in 24 hours");
        uint256 unclaimedBalance = getClaimableBalance(_stakeId);
        require(unclaimedBalance > 0,"You don't have any unclaimed balance to withdraw");
        uint256 devWithdrawFeeAmount = (unclaimedBalance * withdrawalFee) / percentageDivisor;
        uint256 referrerAmount;
        if(nft.balanceOf(userStakeDetails.referrer) > 0){
            referrerAmount = (unclaimedBalance * (nftHolderReferralFee)) / percentageDivisor;
            devWithdrawFeeAmount -= referrerAmount;
        }
        userStakeDetails.totalClaimed = userStakeDetails.totalClaimed + unclaimedBalance;
        userStakeDetails.lastActionedTime = block.timestamp;
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        if(userStakeDetails.roi > minDailyRoi){
            userStakeDetails.roi -= roiBalancer;
        }
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);
        totalClaimed += unclaimedBalance;
        user memory userDetails = users[msg.sender];
        userDetails.totalClaimed  +=  unclaimedBalance;
        users[msg.sender] = userDetails;
        WMuser memory wmUserDetails =  checkWMuser(msg.sender);
        if(userDetails.totalClaimed < wmUserDetails.totalInits){
            WMrecovered[msg.sender] = true;
        }
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
         require(unclaimedBalance > 0,"You don't have any unclaimed balance to compound");
        userStakeDetails.totalCompounded = userStakeDetails.totalCompounded + unclaimedBalance;
        userStakeDetails.lastActionedTime = block.timestamp;
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        if(userStakeDetails.roi < getApplicableRoi() + maxDailyRoi){
            userStakeDetails.roi += roiBalancer;
        }
        userStakeDetails.stakeAmount += unclaimedBalance;
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);
        totalCompounded += unclaimedBalance;
        user memory userDetails = users[msg.sender];
        userDetails.totalCompounded  +=  unclaimedBalance;
        users[msg.sender] = userDetails;
        return true;
    }

    function claimReferral() public {
        user memory referralUserDetails = users[msg.sender];
        require(referralUserDetails.totalStakedBalance > 0,"You do not have any active stakes");
        uint256 referralClaimAmount = referralUserDetails.unclaimedReferral;
        require(referralClaimAmount > 0,"You don't have any unclaimed referral balance");
        referralUserDetails.unclaimedReferral = 0;
        bool success = busd.transfer(msg.sender, referralClaimAmount);
        require(success, "BUSD Transfer failed.");
    }

    function getClaimableBalance(uint256 _stakeId) public view returns(uint256){
        userStake memory userStakeDetails = userStakeArray[_stakeId];
        uint256 roi = userStakeDetails.roi;
        uint applicableDividends = (userStakeDetails.stakeAmount * roi)/(percentageDivisor); //divided by 10000 to handle decimal percentages like 0.1%
        uint unclaimedDividends = (applicableDividends * getElapsedTime(_stakeId));
        return unclaimedDividends; 
    }

    function getElapsedTime(uint256 _stakeId) public view returns(uint256){
        userStake memory userStakeDetails = userStakesById[_stakeId];
        uint256 lapsedDays = ((block.timestamp - userStakeDetails.lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
        return lapsedDays;  
    }

    function getApplicableRoi() public view returns(uint256) {
        uint256 userROI = baseDailyRoi;
        WMuser memory wmUserDetails =  checkWMuser(msg.sender);
        if(wmUserDetails.totalInits > 0 && (WMrecovered[msg.sender] == false)){
            userROI += wmUserExtraRoi;
        }
        if(nft.balanceOf(msg.sender) > 0){
            userROI += nftHolderExtraRoi;
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

    //Testing functions

    function setActionedTime(uint256 _stakeId, uint256 _days)  public {
        userStake memory userStakeDetails = userStakesById[_stakeId];
        userStakeDetails.lastActionedTime = block.timestamp - (_days * 86400);
        userStakeDetails.nextActionTime = userStakeDetails.lastActionedTime + 1 days;
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);
    }

    function setNextActionTime(uint256 _stakeId, uint256 _days)  public {
        userStake memory userStakeDetails = userStakesById[_stakeId];
        userStakeDetails.nextActionTime = block.timestamp + (_days * 86400);
        userStakesById[_stakeId] = userStakeDetails;
        updateStakeArray(_stakeId);
    }

    receive() external payable {}
}