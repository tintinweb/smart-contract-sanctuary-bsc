// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity 0.8.9;

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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity 0.8.9;

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
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.9;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IBEP20 {
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
     * @dev Burns the {amount} amount of tokens from account .
     */
    function burn(address account, uint256 amount) external returns(bool);


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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IInsuranceInvestment {
    function getNoOfInvestmentsArray(address investor)
        external
        view
        returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IRegularInvestment {
    function getNoOfInvestmentsArray(address investor)
        external
        view
        returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;


import "./ReferralFetchers.sol";

contract Referral is ReferralFetchers {

    function initializeContract(
        address _insuranceInvestment,
        address _regularInvestment,
        address _flexvis
    ) external onlyOwner {
        if (
            _insuranceInvestment == address(0) ||
            _regularInvestment == address(0) ||
            _flexvis == address(0)
        ) {
            revert AddressCannotBeZero();
        }
        insuranceInvestment = _insuranceInvestment;
        regularInvestment = _regularInvestment;
        flexvis = _flexvis;

        insuranceInvestmentContract = IInsuranceInvestment(
            _insuranceInvestment
        );
        regularInvestmentContract = IRegularInvestment(_regularInvestment);
        flexvisContract = IBEP20(_flexvis);

        emit InitializedContract(_insuranceInvestment, _regularInvestment, _flexvis);
    }

    // The friend invokes this method to be added as one of friends of this customer.
    function addAsAFriend(address customerAddress) external {

        if (customerAddress == address(0)){
            revert AddressCannotBeZero();
        }
        if (msg.sender == customerAddress) {
            revert SelfReferrerNotAllowed();
        }

        // Check if the friend is valid to be added.
        Friend[] memory allFriends = customerAddressToFriend[customerAddress];

        int256 index = friendIndexOf(msg.sender, allFriends);

        // Checks if the caller is already a friend of the customer
        if (index >= 0) {
            revert AlreadyAFriend();
        }

        // Checks if the caller is already a friend of anybody else
        int256 friendIndex = checkIfIncluded(msg.sender, allFriendAddresses);
        if (friendIndex >= 0) {
            revert AlreadyReferred();
        }

        // Check if the fried(msg.sender) has insurance investment, regular investment and flexvis balance
        uint256 flexvisBalance = flexvisContract.balanceOf(msg.sender);

        uint256[]
            memory noOfInsuranceInvestmentsArray = insuranceInvestmentContract
                .getNoOfInvestmentsArray(msg.sender);

        uint256[] memory noOfRegularInvestmentsArray = regularInvestmentContract
            .getNoOfInvestmentsArray(msg.sender);

        uint256 noOfActiveInsuranceInvestment = noOfInsuranceInvestmentsArray[
            1
        ];
        uint256 noOfActiveRegularInvestment = noOfRegularInvestmentsArray[1];

        uint256 totalRewardAmount = 0;

        if (noOfActiveInsuranceInvestment >= minInsuranceInvestmentCount) {
            totalRewardAmount += insuranceInvestmentReward;
        }
        if (noOfActiveRegularInvestment >= minRegularInvestmentCount) {
            totalRewardAmount += regularInvestmentReward;
        }
        if (flexvisBalance >= minFlexvisAmount) {
            totalRewardAmount += flexvisBalanceReward;
        }

        if (totalRewardAmount == 0) {
            revert NoReward();
        }

        Friend memory friend;
        Reward memory reward;

        reward.totalRewardAmount = totalRewardAmount;
        reward.rewardClaimed = 0;
        reward.rewardCount = 0;
        reward.lastClaimingDay = 0;
        reward.percentageSumUp = 0;
        reward.claimCount = 0;

        uint256[] memory _rewardDays = rewardDays;
        uint256[] memory _rewardPercentages = rewardPercentages;

        reward.rewardDays = _rewardDays;
        reward.rewardPercentages = _rewardPercentages;

        friend.friendAddress = msg.sender;
        friend.reward = reward;

        customerAddressToFriend[customerAddress].push(friend);
        allFriendAddresses.push(msg.sender);

        emit AddedAsAFriend(msg.sender, customerAddress);
    }

    // This method will be invoked by the customer to know the reward to claim
    function claimReward(address friendAddress) external {
        if (friendAddress == address(0)){
            revert AddressCannotBeZero();
        }

        uint256 flexvisBalance = flexvisContract.balanceOf(friendAddress);

        uint256[]
            memory noOfInsuranceInvestmentsArray = insuranceInvestmentContract
                .getNoOfInvestmentsArray(friendAddress);

        uint256[] memory noOfRegularInvestmentsArray = regularInvestmentContract
            .getNoOfInvestmentsArray(friendAddress);

        uint256 noOfActiveInsuranceInvestment = noOfInsuranceInvestmentsArray[1];
        uint256 noOfActiveRegularInvestment = noOfRegularInvestmentsArray[1];
        
        if (noOfActiveInsuranceInvestment < minInsuranceInvestmentCount || noOfActiveRegularInvestment < minRegularInvestmentCount || flexvisBalance < minFlexvisAmount ) {
            revert ClaimingRewardNotSatisfied();
        }
    
        // Make sure that friend is part the customer's friend
        Friend[] memory customerFriends = customerAddressToFriend[msg.sender];

        int256 friendIndex = friendIndexOf(friendAddress, customerFriends);
        if (friendIndex == -1) {
            revert NotAFriendOfCustomer();
        }

        Friend memory friend = customerFriends[uint256(friendIndex)];
        Reward memory reward  = friend.reward;
    
        // Calculate the amount to be claimed and the duration
        uint256 totalRewardAmount = reward.totalRewardAmount;
        uint256 rewardCount = reward.rewardCount;
        uint256 claimCount = reward.claimCount;

         if (claimCount == 3 || rewardCount == 3) {
            revert NothingToClaim();
        }
        
        uint256 percentageSumUp = reward.percentageSumUp;

        if (percentageSumUp >= 100){
            revert HundredPercentReached();
        }

        uint256 lastClaimingDay = reward.lastClaimingDay;
        uint256[] memory rewardPercentagesArray = reward.rewardPercentages;
        uint256[] memory rewardDaysArray = reward.rewardDays;

        uint256 rewardPercentage = rewardPercentagesArray[rewardCount];
        uint256 rewardClaimed = reward.rewardClaimed;

        Friend memory newFriend;
        Reward memory newReward;

        newReward.totalRewardAmount = totalRewardAmount;
        newReward.rewardDays = rewardDaysArray;
        newReward.rewardPercentages = rewardPercentagesArray;

        uint256 rewardToClaim;

        // First time;
        if (rewardCount == 0 && claimCount == 0) {
            // Get the reward to claim;
            rewardToClaim = (rewardPercentage * totalRewardAmount) /
                100;

            // Claim the reward
            flexvisContract.transfer(msg.sender, rewardToClaim);
           
            newReward.rewardClaimed = rewardToClaim;
            newReward.rewardCount = rewardCount + 1;
            newReward.lastClaimingDay = block.timestamp;
            newReward.percentageSumUp = percentageSumUp + rewardPercentage;
            newReward.claimCount = claimCount + 1;
        }
        // Second time
        else if (
            lastClaimingDay != 0 &&
            block.timestamp >= (lastClaimingDay + rewardDaysArray[1]) &&
            (claimCount < 2)
        ) {
            // Get the reward to claim;
            rewardToClaim = (rewardPercentage * totalRewardAmount) /
                100;

            // Claim the reward
            flexvisContract.transfer(msg.sender, rewardToClaim);

            newReward.rewardClaimed = rewardClaimed + rewardToClaim;
            newReward.rewardCount = rewardCount + 1;
            newReward.lastClaimingDay = lastClaimingDay;
            newReward.percentageSumUp = rewardPercentage + percentageSumUp;
            newReward.claimCount = claimCount + 1;
        }
        // Last time
        else if (
            block.timestamp >= (lastClaimingDay + rewardDaysArray[2]) &&
            (claimCount < 3)
        ) {
            
            uint256 newRewardPercentage = rewardCount == 1
                ? 100 - percentageSumUp
                : rewardPercentage;

            // Get the reward to claim;
            rewardToClaim = (newRewardPercentage * totalRewardAmount) /
                100;

            // Claim the reward
            flexvisContract.transfer(msg.sender, rewardToClaim);

            uint256 newPercentageSumUp = percentageSumUp + newRewardPercentage;
            uint256 newRewardClaimed = rewardClaimed + rewardToClaim;

            newReward.rewardClaimed = newRewardClaimed;
            newReward.rewardCount = rewardCount == 1
                ? rewardCount + 2
                : rewardCount + 1;
            newReward.lastClaimingDay = lastClaimingDay;
            newReward.percentageSumUp = newPercentageSumUp;
            newReward.claimCount = rewardCount == 1
                ? claimCount + 2
                : claimCount + 1;
        } else {
            revert CannotClaimToday();
        }

        newFriend.friendAddress = friend.friendAddress;
        newFriend.reward = newReward;
        totalRewardClaimed += rewardToClaim;

        updateFriendsArray(newFriend);

        emit ClaimedReward(rewardToClaim, newFriend.friendAddress, msg.sender);
    }

    function setRewardPercentages(uint256[] calldata _rewardPercentages)
        external
        onlyOwner
    {   
        if (_rewardPercentages.length > 3) {
            revert MaxLengthExceeded();
        }
        if (_rewardPercentages.length == 0) {
            revert InvalidRewardPercentages();
        }
        rewardPercentages = _rewardPercentages;

        emit RewardPercentagesSet(_rewardPercentages);
    }

    function setRewardDays(uint256[] calldata _rewardDays) external onlyOwner {

        if (_rewardDays.length > 3) {
            revert MaxLengthExceeded();
        }

        if (_rewardDays.length == 0) {
            revert InvalidRewardDays();
        }
        rewardDays = _rewardDays;

        emit RewardDaysSet(_rewardDays);
    }

    function setMinValue(
        uint256 minFlexvisAmount,
        uint256 minInsuranceCount,
        uint256 minRegularCount
    ) external onlyOwner {
        if (
            minFlexvisAmount <= 0 ||
            minInsuranceCount <= 0 ||
            minRegularCount <= 0
        ) {
            revert AmountNotGreaterThanZero();
        }

        minFlexvisAmount = minFlexvisAmount;
        minInsuranceInvestmentCount = minInsuranceCount;
        minRegularInvestmentCount = minRegularCount;

        emit MinValueSet(minFlexvisAmount, minInsuranceCount, minRegularCount);
    }

    function setReward(
        uint256 _flexvisReward,
        uint256 _insuranceInvestmentReward,
        uint256 _regularInvestmentReward
    ) external onlyOwner {
        if (
            _flexvisReward <= 0 ||
            _insuranceInvestmentReward <= 0 ||
            _regularInvestmentReward <= 0
        ) {
            revert AmountNotGreaterThanZero();
        }

        flexvisBalanceReward = _flexvisReward;
        insuranceInvestmentReward = _insuranceInvestmentReward;
        regularInvestmentReward = _regularInvestmentReward;

        emit RewardSet(_flexvisReward, _insuranceInvestmentReward, _regularInvestmentReward);
    }

    function updateFriendsArray(Friend memory friend) internal {
        Friend[] storage friends = customerAddressToFriend[msg.sender];

        int256 friendIndex = friendIndexOf(friend.friendAddress, friends);

        if (friendIndex < 0) {
            revert NotAFriendOfCustomer();
        }

        friends[uint256(friendIndex)] = friend;
    }

    function checkIfIncluded(address userAddress, address[] memory usersArray)
        internal
        pure
        returns (int256)
    {
        for (uint256 i = 0; i < usersArray.length; i++) {
            address currentAddress = usersArray[i];
            if (userAddress == currentAddress) {
                return int256(i);
            }
        }

        return -1;
    }

    function friendIndexOf(address userAddress, Friend[] memory friendArray)
        internal
        pure
        returns (int256 index)
    {
        for (uint256 i = 0; i < friendArray.length; i++) {
            address currentAddress = friendArray[i].friendAddress;
            if (userAddress == currentAddress) {
                return int256(i);
            }
        }

        return -1;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

// import {IInsuranceInvestment, IRegularInvestment, IBEP20} from "../interfaces";
import "../interfaces/IInsuranceInvestment.sol";
import "../interfaces/IRegularInvestment.sol";
import "../interfaces/IBEP20.sol";

import "./ReferralError.sol";

abstract contract ReferralDeclaration is ReferralError   {
    
    struct Friend {
        address friendAddress;
        Reward reward;
    }

    struct Reward {
        uint256 totalRewardAmount;
        uint256 rewardClaimed;
        uint256 rewardCount;
        uint256 lastClaimingDay;
        uint256 percentageSumUp;
        uint256 claimCount;
        uint256[] rewardDays;
        uint256[] rewardPercentages;
    }

    uint256 public totalRewardClaimed;

    uint256  public minFlexvisAmount = 10E18;
    uint256 public minInsuranceInvestmentCount = 2;
    uint256 public minRegularInvestmentCount = 1;

    uint256 public insuranceInvestmentReward = 100E18;
    uint256 public regularInvestmentReward = 50E18;
    uint256 public flexvisBalanceReward = 100E18;

    address[] public allCustomerAddresses;
    address[] public allFriendAddresses;
    uint[] public rewardIndex;
    uint[] public rewardPercentages;
    uint[] public rewardDays;

    mapping(address => Friend[]) public customerAddressToFriend;

    address internal insuranceInvestment;
    address internal regularInvestment;
    address internal flexvis;

    IInsuranceInvestment internal insuranceInvestmentContract ;
    IRegularInvestment internal regularInvestmentContract;  
    IBEP20 internal flexvisContract;

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

abstract contract ReferralError  {
  
    error AlreadyACustomer();
    error AlreadyAFriend();
    error AlreadyReferred();
    error NotACustomer();
    error NotAFriendOfCustomer();
    error InsufficientReward();
    error InvalidRewardPercentages();
    error InvalidRewardDays();
    error AmountNotGreaterThanZero();
    error SelfReferrerNotAllowed();
    error NoReward();
    error CannotClaimToday();
    error NothingToClaim();
    error AddressCannotBeZero();
    error ClaimingRewardNotSatisfied();
    error HundredPercentReached();
    error MaxLengthExceeded();
    error CanOnlyBeInvokedByCustomer();
    

}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./ReferralDeclaration.sol";

abstract contract ReferralEvents is ReferralDeclaration   {
    
     event AddedAsAFriend(
        address friendAddress,
        address customerAddress
    );

    event ClaimedReward(uint256 rewardToClaim, address friendAddress, address customerAddress);

    event InitializedContract(address _insuranceInvestment, address _regularInvestment, address _flexvis);

    event RewardPercentagesSet(uint256[] _rewardPercentages);

    event RewardDaysSet(uint256[]  _rewardDays);
    event MinValueSet(uint256 minFlexvisAmount, uint256 minInsuranceCount, uint256 minRegularCount);
    event RewardSet(uint256 _flexvisReward, uint256 _insuranceInvestmentReward, uint256 _regularInvestmentReward);
    

}

// SPDX-License-Identifier: MIT

import "./ReferralEvents.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity 0.8.9;

abstract contract ReferralFetchers is ReferralEvents, Ownable {
    function getAllFriends(address customerAddress)
        external
        view
        returns (Friend[] memory)
    {
        if (customerAddress == address(0)) {
            revert AddressCannotBeZero();
        }
        if (msg.sender != customerAddress) {
            revert CanOnlyBeInvokedByCustomer();
        }
        return customerAddressToFriend[customerAddress];
    }

    function getNoOfFriends(address customerAddress)
        external
        view
        returns (uint256)
    {
        if (customerAddress == address(0)) {
            revert AddressCannotBeZero();
        }

        Friend[] memory friends = customerAddressToFriend[customerAddress];
        return friends.length;
    }
}