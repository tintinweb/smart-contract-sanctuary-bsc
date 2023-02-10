// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

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

interface IsCRSS is IERC20 {
    function enter(uint256 _amount) external;

    function leave(uint256 _amount) external;

    function enterFor(uint256 _amount, address _to) external;

    function killswitch() external;

    function rescueToken(address _token, uint256 _amount) external;

    function rescueETH(uint256 _amount) external;

    function impactFeeStatus(bool _value) external;

    function setImpactFeeReceiver(address _feeReceiver) external;

    function CRSStoSCRSS(uint256 _crssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    function sCRSStoCRSS(uint256 _sCrssAmount, bool _impactFeeOn)
        external
        view
        returns (
            uint256 crssAmount,
            uint256 swapFee,
            uint256 impactFee
        );

    event TradingHalted(uint256 timestamp);
    event TradingResumed(uint256 timestamp);
}

interface ICRSS is IERC20 {
    function controlledMint(uint256 _amount) external;

    function controlledMintTo(address _to, uint256 _amount) external;
}

contract CRSSCompensator is Ownable, ReentrancyGuard {
    //this object is used during initialization
    struct CompensationObject {
        address userAddress;
        uint128 crssOwed;
    }
    //this represent core info of every users compensation
    struct UserCompensation {
        uint128 totalCrssOwed;
        uint128 crssClaimed;
    }
    //object for CRSS that was claimed and vested
    struct VestingObject {
        uint128 crssAmount;
        uint128 startTimestamp;
    }
    address public accountant; //this is where instant claim fees go to
    address public crssToken;
    address public sCrssToken;
    uint256 public compensationStartBlock; //cannot be changed once initialized
    uint256 public compensationEndBlock; //derived from startBlock and lengthInBlocks
    uint256 public immutable compensationLengthInBlocks;
    uint256 public constant totalCompensationInCrss = 5111110238318922 * 10**9; //5111110.238318922 CRSS as per total crssOwed of official CrosswiseCompensationEntitlement Google spreadsheet

    uint256 public constant vestDuration = 5 * (6 * 6 * 24 * 3044); //5months, 13150080s
    UserCompensation[] public orderedCompensations; //this corresponds to our google sheet compensation list, so addresses can be checked by google sheet index
    uint256 private totalVesting; //total non-withdrawn and non-minted CRSS that was claimed
    uint256 private totalWithdrawn; //total withdrawn from vesting
    mapping(address => UserCompensation) private userCompensation;
    mapping(address => VestingObject[]) private userVestingInstances;
    mapping(address => uint256) private userWithdrawn;

    constructor(
        address _crssToken,
        address _sCrssToken,
        uint256 _compensationLength
    ) Ownable() ReentrancyGuard() {
        compensationLengthInBlocks = _compensationLength;
        crssToken = _crssToken;
        sCrssToken = _sCrssToken;
        IERC20(_crssToken).approve(_sCrssToken, type(uint256).max); //make sure sCRSS enterFor() works indefinetly
    }

    function getUserAmount() public view returns (uint256) {
        return orderedCompensations.length;
    }

    function addUsers(CompensationObject[] memory _userCompensations)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < _userCompensations.length; i++) {
            UserCompensation memory userObject = UserCompensation({
                totalCrssOwed: _userCompensations[i].crssOwed,
                crssClaimed: 0
            });
            orderedCompensations.push(userObject);
            userCompensation[_userCompensations[i].userAddress] = userObject;
        }
    }

    function startCompensation() public onlyOwner {
        require(compensationStartBlock == 0, "cCRSS:Already started");
        compensationStartBlock = block.number;
        compensationEndBlock = block.number + compensationLengthInBlocks;
    }

    function claimCompensation(uint128 _amount, bool _vesting)
        public
        nonReentrant
    {
        address msg_sender = _msgSender();
        uint128 percentageClaimable;
        UserCompensation storage user = userCompensation[msg_sender];
        if (
            compensationLengthInBlocks > block.number - compensationStartBlock
        ) {
            percentageClaimable = uint128(
                ((block.number - compensationStartBlock) * 1000000) /
                    compensationLengthInBlocks
            );
        } else percentageClaimable = 1000000; //100%

        uint128 crssClaimable = (user.totalCrssOwed * percentageClaimable) /
            1000000 -
            user.crssClaimed;

        if (_amount <= crssClaimable) {
            uint256 amount0 = uint256(_amount);
            user.crssClaimed += _amount;

            if (_vesting) {
                userVestingInstances[msg_sender].push(
                    VestingObject({
                        crssAmount: _amount,
                        startTimestamp: uint128(block.timestamp)
                    })
                );
                totalVesting += amount0;
            } else {
                ICRSS(crssToken).controlledMint(amount0);
                uint256 adjustedAmount = (amount0 * 3) / 4;
                userWithdrawn[msg_sender] += adjustedAmount;
                totalWithdrawn += amount0;
                ICRSS(crssToken).transfer(msg_sender, adjustedAmount);
                ICRSS(crssToken).transfer(accountant, amount0 - adjustedAmount);
            }
        }
    }

    function claimAll(bool _vesting) public nonReentrant {
        address msg_sender = _msgSender();
        UserCompensation storage user = userCompensation[msg_sender];
        uint128 percentageClaimable;
        if (
            compensationLengthInBlocks > block.number - compensationStartBlock
        ) {
            percentageClaimable = uint128(
                ((block.number - compensationStartBlock) * 1000000) /
                    compensationLengthInBlocks
            );
        } else percentageClaimable = 1000000; //100%
        uint128 crssClaimable = (user.totalCrssOwed * percentageClaimable) /
            1000000 -
            user.crssClaimed;
        if (crssClaimable > 0) {
            uint256 amount0 = uint256(crssClaimable);
            user.crssClaimed += crssClaimable;

            if (_vesting) {
                userVestingInstances[msg_sender].push(
                    VestingObject({
                        crssAmount: crssClaimable,
                        startTimestamp: uint128(block.timestamp)
                    })
                );
                totalVesting += amount0;
            } else {
                ICRSS(crssToken).controlledMint(amount0);
                uint256 adjustedAmount = (amount0 * 3) / 4;
                userWithdrawn[msg_sender] += adjustedAmount;
                totalWithdrawn += amount0;
                ICRSS(crssToken).transfer(accountant, amount0 - adjustedAmount);
                ICRSS(crssToken).transfer(msg_sender, adjustedAmount);
            }
        }
    }

    function massWithdrawVested() public nonReentrant {
        address msg_sender = _msgSender();
        VestingObject[] storage userVestArray = userVestingInstances[
            msg_sender
        ];
        uint128 totalCrss = 0;
        for (uint256 i = 0; i < userVestArray.length; i) {
            if (
                userVestArray[i].startTimestamp + vestDuration <=
                block.timestamp
            ) {
                totalCrss += userVestArray[i].crssAmount;
                userVestingInstances[msg_sender][i] = userVestingInstances[
                    msg_sender
                ][userVestingInstances[msg_sender].length - 1];
                userVestingInstances[msg_sender].pop();
            } else i++;
        }
        uint256 adjustedVestAmount = uint256(totalCrss);
        userWithdrawn[msg_sender] += adjustedVestAmount;
        totalWithdrawn += adjustedVestAmount;
        ICRSS(crssToken).controlledMintTo(msg_sender, adjustedVestAmount);
    }

    function withdrawVested(uint256 _id) public nonReentrant {
        address msg_sender = _msgSender();
        VestingObject memory vestingInstance = userVestingInstances[msg_sender][
            _id
        ];
        require(
            vestingInstance.startTimestamp + vestDuration <= block.timestamp,
            "cCRSS:Not unlocked yet"
        );

        userVestingInstances[msg_sender][_id] = userVestingInstances[
            msg_sender
        ][userVestingInstances[msg_sender].length - 1];
        userVestingInstances[msg_sender].pop();
        uint256 adjustedVestAmount = uint256(vestingInstance.crssAmount);
        userWithdrawn[msg_sender] += adjustedVestAmount;
        totalWithdrawn += adjustedVestAmount;
        ICRSS(crssToken).controlledMintTo(msg_sender, adjustedVestAmount);
    }

    function withdrawAndGetSCRSS(uint256 _id) public nonReentrant {
        address msg_sender = _msgSender();

        VestingObject memory vestingInstance = userVestingInstances[msg_sender][
            _id
        ];
        require(
            vestingInstance.startTimestamp + vestDuration <= block.timestamp,
            "cCRSS:Not unlocked yet"
        );

        userVestingInstances[msg_sender][_id] = userVestingInstances[
            msg_sender
        ][userVestingInstances[msg_sender].length - 1];
        userVestingInstances[msg_sender].pop();
        uint256 adjustedVestAmount = uint256(vestingInstance.crssAmount);
        userWithdrawn[msg_sender] += adjustedVestAmount;
        totalWithdrawn += adjustedVestAmount;
        ICRSS(crssToken).controlledMint(adjustedVestAmount);
        IsCRSS(sCrssToken).enterFor(adjustedVestAmount, msg_sender);
    }

    function massWithdrawAndGetSCRSS() public nonReentrant {
        address msg_sender = _msgSender();
        VestingObject[] storage userVestArray = userVestingInstances[
            msg_sender
        ];
        uint128 totalCrss = 0;
        for (uint256 i = 0; i < userVestArray.length; i) {
            if (
                userVestArray[i].startTimestamp + vestDuration <=
                block.timestamp
            ) {
                totalCrss += userVestArray[i].crssAmount;
                userVestingInstances[msg_sender][i] = userVestingInstances[
                    msg_sender
                ][userVestingInstances[msg_sender].length - 1];
                userVestingInstances[msg_sender].pop();
            } else i++;
        }
        uint256 adjustedVestAmount = uint256(totalCrss);
        userWithdrawn[msg_sender] += adjustedVestAmount;
        totalWithdrawn += adjustedVestAmount;
        ICRSS(crssToken).controlledMint(adjustedVestAmount);
        IsCRSS(sCrssToken).enterFor(adjustedVestAmount, msg_sender);
    }

    function getUserInfo(address _user)
        public
        view
        returns (
            uint256 userClaimed,
            uint256 userClaimable,
            uint256 userVested,
            uint256 userWithdrawnAmount,
            uint256 userTotalOwed
        )
    {
        UserCompensation memory userComp = userCompensation[_user];
        userClaimed = userComp.crssClaimed;
        userClaimable = getUserClaimable(_user);
        userTotalOwed = userComp.totalCrssOwed;
        userWithdrawnAmount = getUserWithdrawn(_user);
        userVested = getUserWithdrawable(_user);
    }

    function getGlobalCompensationData()
        public
        view
        returns (
            uint256 totalWithdrawnCRSS,
            uint256 totalVestingCRSS,
            uint256 totalCompensationCRSS
        )
    {
        totalWithdrawnCRSS = getTotalWithdrawn();
        totalVestingCRSS = getTotalVesting();
        totalCompensationCRSS = totalCompensationInCrss;
    }

    function getUserVestingInstance(address _user, uint256 _id)
        public
        view
        returns (VestingObject memory userObject)
    {
        return userVestingInstances[_user][_id];
    }

    function getAllUserVestingInstances(address _user)
        public
        view
        returns (VestingObject[] memory vestingArray)
    {
        return userVestingInstances[_user];
    }

    function getUserCompensation(address _user)
        public
        view
        returns (UserCompensation memory userObject)
    {
        return userCompensation[_user];
    }

    function getUserCompensationById(uint256 _id)
        public
        view
        returns (UserCompensation memory userObject)
    {
        return orderedCompensations[_id];
    }

    function getUserClaimed(address _user)
        public
        view
        returns (uint256 crssAmount)
    {
        crssAmount = uint256(userCompensation[_user].crssClaimed);
    }

    function getUserWithdrawn(address _user)
        public
        view
        returns (uint256 withdrawnCrss)
    {
        return userWithdrawn[_user];
    }

    function getTotalWithdrawn()
        public
        view
        returns (uint256 totalWithdrawnCrss)
    {
        return totalWithdrawn;
    }

    function getTotalVesting() public view returns (uint256 totalVestingCrss) {
        return totalVesting;
    }

    //emission of 0.35 CRSS/block
    function getLockedCrssRemaining()
        public
        view
        returns (uint256 unmintedCrss)
    {
        return
            (35 *
                (compensationLengthInBlocks -
                    (block.number - compensationStartBlock))) / 100;
    }

    function getUserWithdrawable(address _user)
        public
        view
        returns (uint256 withdrawableCrss)
    {
        VestingObject[] memory userVestArray = userVestingInstances[_user];

        for (uint256 i = 0; i < userVestArray.length; i++) {
            if (
                userVestArray[i].startTimestamp + vestDuration <=
                block.timestamp
            ) {
                uint256 vestedAmount = uint256(userVestArray[i].crssAmount);
                withdrawableCrss += vestedAmount;
            }
        }
    }

    function getUserClaimable(address _user)
        public
        view
        returns (uint256 crssClaimable)
    {
        UserCompensation memory user = userCompensation[_user];
        uint128 percentageClaimable;
        if (
            compensationLengthInBlocks > block.number - compensationStartBlock
        ) {
            percentageClaimable = uint128(
                ((block.number - compensationStartBlock) * 1000000) /
                    compensationLengthInBlocks
            );
        } else percentageClaimable = 1000000;

        crssClaimable = uint256(
            (user.totalCrssOwed * percentageClaimable) /
                1000000 -
                user.crssClaimed
        );
    }

    function getUserVesting(address _user)
        public
        view
        returns (uint128 crssVesting)
    {
        VestingObject[] memory userVestArray = userVestingInstances[_user];

        for (uint256 i = 0; i < userVestArray.length; i++) {
            crssVesting += userVestArray[i].crssAmount;
        }
    }

    function setAccountant(address _accountant) external onlyOwner {
        accountant = _accountant;
    }

    function unlockVestingInstance(address _user, uint256 _vestId) public {
        userVestingInstances[_user][_vestId].startTimestamp = 0;
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