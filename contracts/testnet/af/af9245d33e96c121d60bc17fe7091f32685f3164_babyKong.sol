/**
 *Submitted for verification at BscScan.com on 2023-01-08
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

// File: contracts/KongProject/babyKong.sol

/*

  _  _____  _   _  ____   ____  _   _ ____  ____  
 | |/ / _ \| \ | |/ ___| | __ )| | | / ___||  _ \ 
 | ' / | | |  \| | |  _  |  _ \| | | \___ \| | | |
 | . \ |_| | |\  | |_| | | |_) | |_| |___) | |_| |
 |_|\_\___/|_| \_|\____| |____/ \___/|____/|____/ 
                                                  
The KONG BUSD is a ROI Dapp and part of the KONG-Eco System. 
The KONG BUSD is crated by combining the great features of the existing and past ROI Dapps. 
KONG BUSD is a 100% decentralized investment platform built on the Binance Smart Chain (BEP20). 
It offers a variable yield % of 1% to 4% with a maximum profit of 300% of the total deposited amount.

Visit website for more details: https://kongbusd.finance
*/




pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function approve(address _spender, uint _value) external returns (bool success);
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

interface KongBusdV2{
    //function users(address _userAddress) external view returns(userV1 memory);
    //function userStakesById(uint256 _id) external view returns(userStakeV1 memory);
    function getUserAllStakeDetailsByAddress(address _userAddress) external view returns(userStakeV2[] memory);
    //function getUserStakeIdsByAddress(address _address) external view returns(uint256[] memory);
    function stake(uint256 _amount, address _referrer) external returns (bool);
    function claim(uint256 _stakeId)  external returns (bool);
    function compound(uint256 _stakeId) external returns (bool);
    function setActionedTime(uint256 _stakeId, uint256 _days)  external;
    function setNextActionTime(uint256 _stakeId, uint256 _days)  external;
    function getClaimableBalance(uint256 _stakeId) external view returns(uint256);
}

/*
struct userV1{   
    uint256 totalStakedBalance;
    uint256 totalClaimed;
    uint256 totalCompounded;
    uint256 totalReferred;
    uint256 unclaimedReferral;
    uint256 createdTime;
}
*/

struct userStakeV2{
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
/*
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
*/

contract babyKong is Ownable, ReentrancyGuard {
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
        uint256 status; //0 : Unstaked, 1 : Staked, 2 : Inactive
        address referrer;
        address owner;
    	uint256 createdTime;
    }

    address public dev1 = 0x66210175567AD8a0414C530F642E2ad889b6c359;
    address public dev2 = 0xBb61125269A86b90b5E1e23547811A3fF04bD11D;
    address public dev3 = 0x02D17fDFdA84eaD75DCF8c9a9a98D8F0F911D155;

    uint256 public minDeposit = 10 ether; //Minimum stake 10 BUSD
    uint256 public baseDailyRoi = 200; //2%
    uint256 public roiBalancer = 5; //0.05%
    uint256 public minDailyRoi = 100; //1%
    uint256 public maxDailyRoi = 500; //5%
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
    mapping (uint256 => uint256) public v1toV2Id;
    mapping (uint256 => bool) public isMigrated;
    mapping (uint256 => bool) public isMigrationActivated;
    mapping (address => bool) public isUnclaimedReferralMigrated;

    uint256 public totalUsers;
    uint256 public totalStaked;
    uint256 public totalClaimed;
    uint256 public totalCompounded;
  
    uint256 public stakeIndex;

    bool public isStarted = false;

    event staked(address _stkaerUser, uint256 _amount, address _referrer);

    /*
    address public busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    IERC20 busd = IERC20(busdAddress);

    address public nftAddress = 0x6E4A8d4244cF0501Ca99E4fFf4CD1b45F8ddb82a;
    IERC20 nft = IERC20(nftAddress);

    address public wmAddress = 0x9B9C918FAC2DFCCaFff3B95b4f46FD9A5D9D701b;
    WM wm = WM(wmAddress);

    address public kongV1Address = 0x597F6c4bf7C4311379c2420589925d0D75404a45;
    KongBusdV1 kongV1 = KongBusdV1(kongV1Address);
    */

    address public busdAddress = 0xAe12F7EeA8FF55383109E0B28B95300082c5f78e;
    IERC20 busd = IERC20(busdAddress);

    address public nftAddress = 0x4c6640cED0d6f2b76F485d80A3871ED9A7deB1AE;
    IERC20 nft = IERC20(nftAddress);

    address public kongV2Address = 0xF6b4F80181edE3BFB25cf3F60c730A5566eA2f16;
    KongBusdV2 kongV2 = KongBusdV2(kongV2Address);

    function stake() external returns (bool) {
        uint256 _amount = 10 ether;
        address _referrer = msg.sender;

        require(busd.allowance(msg.sender, address(this)) >= _amount,"Not enough BUSD approved for transfer"); 
        bool success = busd.transferFrom(msg.sender, address(this), _amount);
        require(success, "BUSD Transfer failed.");
        busd.approve(kongV2Address,_amount);
        kongV2.stake(_amount, _referrer);

        return true;
    }

    
    function claim(uint256 _stakeId) nonReentrant public returns (bool){
        kongV2.claim(_stakeId);
        return true;
    }
    
    function compound(uint256 _stakeId) nonReentrant public returns (bool){
        kongV2.compound(_stakeId);
        return true;
    }
    
    function getClaimableBalance(uint256 _stakeId) public view returns(uint256){    
        return kongV2.getClaimableBalance(_stakeId);
    }

    function getTotalClaimableBalance() public view returns(uint256){    
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));
        uint256 totalClaimableBalance;
        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                totalClaimableBalance += kongV2.getClaimableBalance(userStakesList[i].id);
            }
        }

        return totalClaimableBalance;
    }

    function getUserAllStakeDetailsByAddress(address _userAddress) external view returns(userStakeV2[] memory){
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(_userAddress);
        return userStakesList;
    }

    function claimAllStakes() public {
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.claim(userStakesList[i].id);
            }
        }
    }

    function compoundAllStakes() public {
        userStakeV2[] memory userStakesList = kongV2.getUserAllStakeDetailsByAddress(address(this));

        for(uint256 i = 0; i < userStakesList.length; i++){
            uint256 lapsedDays = ((block.timestamp - userStakesList[i].lastActionedTime)/3600)/24; //3600 seconds per hour so: lapsed days = lapsed time * (3600seconds /24hrs)
            if(lapsedDays >= 1){
                kongV2.compound(userStakesList[i].id);
            }
        }
    }
    //Testing functions

    function setActionedTime(uint256 _stakeId, uint256 _days)  public {
        kongV2.setActionedTime(_stakeId,_days);
    }

    function setNextActionTime(uint256 _stakeId, uint256 _days)  public {
       kongV2.setNextActionTime(_stakeId,_days);
    }
    
    receive() external payable {}
}