// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract Staking is Ownable {
    address public Owner;
    IERC20 public token;
    uint256 public lockedPeriod;
    uint256 internal aprPerSecond;
    uint256 public weakNonce;
    uint256 public percentDivider;

    constructor() {
        token = IERC20(0x3E3dd26c2cf50f2b7E5AaB86B0eb916502034c13);
        Owner = msg.sender;
        lockedPeriod = 14 minutes;
        percentDivider = 100000000;
    }

    struct stakerINfo {
        uint256 amount;
        uint256 depositTime;
        uint256 initialApr;
        uint256 aprPerSecond;
        uint256 yourRewardDuration;
        uint256 lastClaimTime;
        uint256 totalReward;
        bool isDeposit;
        uint256 reward_withdrawn;
        
    }
    struct lotteryWeakInfo {
        uint256 startTime;
        uint256 weaknonce;
        uint256 stakingDuration;
        uint256 initialApr;
        bool active;
    }
    mapping(address => stakerINfo) public stakes;
    mapping(uint256 => lotteryWeakInfo) public weakInfo;

    function StakingWeakStart(uint256 _enterDuration, uint256 _initialApr)
        external
    {
        weakNonce++;
        weakInfo[weakNonce].active = true;
        weakInfo[weakNonce].startTime = block.timestamp;
        weakInfo[weakNonce].weaknonce = weakNonce;
        weakInfo[weakNonce].stakingDuration = _enterDuration;
        weakInfo[weakNonce].initialApr = _initialApr;
    }

    function stake(uint256 _amount) external  {
        require(_amount > 0, "Amount is less then zero");
        require(
            weakInfo[weakNonce].active == true,
            "There is no staking weak start here"
        );
        require(block.timestamp - weakInfo[weakNonce].startTime <= weakInfo[weakNonce].stakingDuration,"Lottery Time Out" );

        uint256 aprPerHours = weakInfo[weakNonce].initialApr /
            weakInfo[weakNonce].stakingDuration;
        uint256 YourAprTimePerHours = ((block.timestamp -
            weakInfo[weakNonce].startTime) / 60) / 60;
        uint256 yourApr = (YourAprTimePerHours * aprPerHours) -
            weakInfo[weakNonce].initialApr;
            uint256 _yourRewardDuration = (block.timestamp - weakInfo[weakNonce].startTime) - weakInfo[weakNonce].stakingDuration;
            uint256 yourAprPerSeconds = (((((stakes[msg.sender].aprPerSecond * percentDivider) / 365) /
            24) / 60) / 60);
            uint256 _totalReward=_yourRewardDuration * yourAprPerSeconds;
        token.transfer(address(this), _amount);
        stakes[msg.sender].aprPerSecond += yourApr;
        stakes[msg.sender].totalReward += _totalReward;
        stakes[msg.sender].yourRewardDuration = _yourRewardDuration;
        stakes[msg.sender].amount += _amount;
        stakes[msg.sender].depositTime = block.timestamp;
        stakes[msg.sender].isDeposit = true;
        stakes[msg.sender].lastClaimTime = 0;
        stakes[msg.sender].reward_withdrawn = 0;
    }

    function claimReward() external  {
        require(
            stakes[msg.sender].isDeposit == true,
            "You are not stake any amount"
        );
        require(block.timestamp - stakes[msg.sender].lastClaimTime >= 1 minutes,"You are trying to withdraw before minutes");
         uint256 yourAprPerSeconds = (((((stakes[msg.sender].aprPerSecond * percentDivider) / 365) /
            24) / 60) / 60);
            uint256 yourReward=(stakes[msg.sender].amount * yourAprPerSeconds * (block.timestamp -  stakes[msg.sender].lastClaimTime))/percentDivider;

        if(stakes[msg.sender].totalReward >= stakes[msg.sender].reward_withdrawn){

            if(yourReward + stakes[msg.sender].reward_withdrawn >= stakes[msg.sender].totalReward ){
                uint256 remaingReward= stakes[msg.sender].totalReward - stakes[msg.sender].reward_withdrawn;
                token.transferFrom(Owner,msg.sender,remaingReward);
                 stakes[msg.sender].reward_withdrawn=stakes[msg.sender].totalReward;
            }
            else{

                token.transferFrom(Owner,msg.sender,yourReward);
                 stakes[msg.sender].reward_withdrawn +=yourReward;

            }
            stakes[msg.sender].lastClaimTime = block.timestamp;
        }

    }



    function ClaimStakingAmount() external {
        require(
            stakes[msg.sender].isDeposit == true,
            "You are not stake any amount"
        );
        require(
            block.timestamp >= stakes[msg.sender].depositTime + lockedPeriod,
            "You cannot unlock before lock period"
        );
        token.transfer(msg.sender, stakes[msg.sender].amount);
        stakes[msg.sender].amount = 0;
        stakes[msg.sender].isDeposit = false;
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