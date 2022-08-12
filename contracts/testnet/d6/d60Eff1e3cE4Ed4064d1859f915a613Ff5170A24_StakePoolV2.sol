pragma solidity 0.8.9;

/**
      Tasks:
    - Unit tests for AtpadNFT
    - Unit tests for modular stakepool
    - Unit tests for stakepoolV2
    - Docs for AtpadNFT                             Done
    - Docs for StakePool V2                         Done     
    - Frontend implementation guide
    - Hardhat Tasks for deploy, mint                Done
        
        - ERC20 Mintable
        - AtpadNFT
        - StakePoolV2
        - Mint Tokens
        - Mint NFTs
 */
/** 
    @title StakePoolV2
    @notice This is a Natspec commented contract by AtomPad Development Team
    @notice Version v2.0.0 date: may 26, 2022
    @author AtomPad Dev Team
    @author JaWsome Orbit
    @author Rufi Web
*/

import "./StakePool.sol";
import "../interfaces/IAtpadNFT.sol";

contract StakePoolV2 is StakePool {
    IAtpadNFT private nft;

    /// @dev Mappings
    mapping(uint256 => address) private _nftOwners;
    mapping(uint256 => uint256) private _values;

    ///@dev Events
    event NFTStaked(address indexed user, uint256 indexed tokenId);
    event NFTWithdrawn(address indexed user, uint256 indexed tokenId);

    constructor(address _stakeToken, IAtpadNFT _nft) StakePool(_stakeToken) {
        nft = _nft;
    }

    ///@dev Admin

    /**
        @dev Assign a value to weight
        @param _weight - weight of tier
        @param _value - value of tier
    
     */
    function createValue(uint256 _weight, uint256 _value) external onlyOwner {
        require(_weight > 0, "!weight");
        require(_value > 0, "!value");
        _values[_weight] = _value;
    }

    /**
        @notice Stake Atompad NFT
        @dev Anyone can call it to stake NFT
        @param _tokenId - Id of NFT. User wanted to stake
     */
    function stakeNFT(uint256 _tokenId) external {
        require(_tokenId != 0, "!TokenID");

        nft.safeTransferFrom(_msgSender(), address(this), _tokenId);
        uint256 _weight = nft.getWeight(_tokenId);

        _nftOwners[_tokenId] = _msgSender();
        allocPoints[msg.sender] += _weight;
        timeLocks[msg.sender] = block.timestamp;

        totalAllocPoint += _weight;

        emit NFTStaked(msg.sender, _tokenId);
    }

    /**
        @notice Withdraw Atompad NFT
        @dev Anyone can call it to withdraw thier staked NFT
        @param _tokenId - Id of NFT. User wanted to withdraw
        @param _feeAmount - Fee for withdrawing early
     */
    function withdrawNFT(uint256 _tokenId, uint256 _feeAmount) external {
        require(_nftOwners[_tokenId] == msg.sender, "!Owner");

        uint256 _weight = nft.getWeight(_tokenId);

        uint256 _amount = _values[_weight];
        uint256 _fee = calculateWithdrawFees(_amount, msg.sender);
        require(_feeAmount >= _fee, "!Fee");

        stakeToken.transferFrom(msg.sender, address(this), _fee);

        allocPoints[msg.sender] -= _weight;
        _nftOwners[_tokenId] = address(0);

        totalAllocPoint -= _weight;
        collectedFee += _fee;

        emit NFTWithdrawn(msg.sender, _tokenId);
    }

    ///@dev Getters

    /**
        @dev Get the owner of staked nft.
        @param _tokenId - Id of NFT
        @return Owner of staked nft 
     */
    function ownerOf(uint256 _tokenId) external view returns (address) {
        return _nftOwners[_tokenId];
    }

    /**
        @dev Get the value of weight
        @param _weight - weight of tier
        @return Value of tier
     */
    function valueOf(uint256 _weight) external view returns (uint256) {
        return _values[_weight];
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

///@dev  OpenZeppelin modules
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

///@dev Base Modules
import "../base/stakepool/StakePoolAlloc.sol";
import "../base/stakepool/StakePoolControl.sol";
import "../base/stakepool/StakePoolFee.sol";
import "../base/stakepool/StakePoolTier.sol";
import "../base/stakepool/StakePoolUser.sol";

/** 
    @title StakePool
    @notice This is a Natspec commented contract by AtomPad Development Team
    @notice Version v1.1.0 date: may 24, 2022
*/

/// @author AtomPad Dev Team
/// @author JaWsome Orbit
/// @author Rufi Web

contract StakePool is
    ReentrancyGuard,
    Ownable,
    Pausable,
    StakePoolAlloc,
    StakePoolControl,
    StakePoolFee,
    StakePoolTier,
    StakePoolUser
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /// @dev State Variables
    uint8 internal decimals = 18;
    uint256 public totalStaked;

    /// @dev Mapping
    mapping(address => uint256) private _tokenBalances;

    /// @dev Events
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    /// @param _stakeToken The token will be the rewarded for stakingTime
    constructor(address _stakeToken) {
        require(_stakeToken != address(0), "!address");

        stakeToken = IERC20(_stakeToken);

        // Fill Tiers
        addTier(20000 ether, 750, uint32(1 days));
        addTier(10000 ether, 300, uint32(1 days));
        addTier(5000 ether, 130, uint32(1 days));
        addTier(2000 ether, 40, uint32(1 days));
        addTier(1000 ether, 15, uint32(1 days));

        stakeOn = true;
        withdrawOn = true;
    }

    /**
        @notice Stake Atpad 
        @dev Anyone can call it to stake Atpad
        @param _amount - The amount of tokens to stake by this user
     */
    function stake(uint256 _amount)
        external
        stakeEnabled
        nonReentrant
        whenNotPaused
    {
        // @dev Do some checks .
        require(_amount > (10 * 10**decimals), "minimum 10!");
        require(
            (_amount + _tokenBalances[msg.sender]) >= (1000 * 10**decimals),
            "!amount"
        );

        ///@dev Transfer tokens from participant to this contract.
        stakeToken.safeTransferFrom(msg.sender, address(this), _amount);

        ///@dev Update  participant states
        _tokenBalances[msg.sender] += _amount;
        uint256 _allocPoints = allocPoints[msg.sender];
        uint256 _newAllocPoints = _reBalance(_tokenBalances[msg.sender]);
        allocPoints[msg.sender] = _newAllocPoints;
        timeLocks[msg.sender] = block.timestamp;

        ///@dev Update global states .
        totalAllocPoint += _newAllocPoints - _allocPoints;
        totalStaked += _amount;

        ///@dev Emit event .
        emit Staked(msg.sender, _amount);
    }

    /**
        @notice Withdraw Atpad
        @dev Anyone can call it to withdraw thier staked Atpad
        @param _amount - The amount of tokens to withdraw from stakepool by this user
     */
    function withdraw(uint256 _amount)
        public
        withdrawEnabled
        nonReentrant
        whenNotPaused
    {
        // @dev do some checks .
        require(balanceOf(msg.sender) >= _amount, "!StakeAmount");

        /// @dev Calculate withdraw fee .
        uint256 _fee = calculateWithdrawFees(_amount, msg.sender);

        ///@dev Update  participant states .
        _tokenBalances[msg.sender] -= _amount;
        uint256 _points = allocPoints[msg.sender];
        uint256 _newPoints = _reBalance(_tokenBalances[msg.sender]);
        allocPoints[msg.sender] = _newPoints;
        uint256 _transferAmount = _amount - _fee;

        ///@dev Transfer tokens from contract to participant account.
        stakeToken.safeTransfer(_msgSender(), _transferAmount);

        ///@dev Update Global states .
        totalAllocPoint -= (_newPoints - _points);
        collectedFee += _fee;
        totalStaked -= _amount;

        ///@dev Emit event .
        emit Withdrawn(_msgSender(), _amount);
    }

    /**
        @notice Withdraw all staked Atpad
        @dev Anyone can call to withdraw all of thier staked Atpad
     */
    function withdrawAll() external virtual withdrawEnabled {
        withdraw(_tokenBalances[msg.sender]);
    }

    /**
        @dev Get the staking balance of staker
        @param _sender - Staker address
        @return The balance of staker
     */
    function balanceOf(address _sender) public view returns (uint256) {
        return _tokenBalances[_sender];
    }
}

pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAtpadNFT is IERC721 {
    function getWeight(uint256 _tokenId)
        external
        view
        returns (uint256 _weight);

    function getValue(uint256 _tokenId) external view returns (uint256 _value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

/** 
    Tests Needed:

    - allocPoints map update on STAKE & WITHDRAW 
    - totalAllocPoint update on STAKE & WITHDRAW
    - allocPointsOf returns current allocpoint of participant
    - allocPercentageOf returns current alloc% of participant
*/

contract StakePoolAlloc {
    /// @dev State Vars
    uint256 public totalAllocPoint;

    /// @dev Mapping
    mapping(address => uint256) internal allocPoints;

    /// @dev Getters

    /**
        @dev Get the allocpoints of staker
        @param _sender - Staker address
        @return Allocpoints of staker
     */
    function allocPointsOf(address _sender) public view returns (uint256) {
        return allocPoints[_sender];
    }

    /**
        @dev Get the alloc perercentage of of staker
        @param _sender - Staker address
        @return Alloc perercentage of staker
     */
    function allocPercentageOf(address _sender) public view returns (uint256) {
        uint256 points = allocPointsOf(_sender) * 10**6;

        uint256 millePercentage = points / totalAllocPoint;

        return millePercentage;
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakePoolControl is Ownable {
    /** 
    Tests Needed:

    - setDisableStake should turn ON/OFF stakeOn  
    - setDisableWithdraw should turn ON/OFF withdrawOn  
    - stakeEnabled should stop stake() if stakeOn == false 
    - withdrawEnabled should stop stake() if withdrawOn == false 

*/
    ///@dev State Control Vars
    bool public stakeOn;
    bool public withdrawOn;

    ///@dev Modifiers
    modifier stakeEnabled() {
        require(stakeOn == true, "Staking is paused !");
        _;
    }

    modifier withdrawEnabled() {
        require(withdrawOn == true, "Withdrawing is paused !");
        _;
    }

    /**
        @dev Enable/Disable staking using it
        @param _flag Boolean constant.
        @dev True representing enable
        @dev False representing disable
     */
    function setDisableStake(bool _flag) external onlyOwner {
        stakeOn = _flag;
    }

    /**
        @dev Enable/Disable withdraw using it
        @param _flag Boolean constant.
        @dev True representing enable
        @dev False representing disable
     */
    function setDisableWithdraw(bool _flag) external onlyOwner {
        withdrawOn = _flag;
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "contracts/libraries/StakePoolV2Library.sol";

/** 
    Tests Needed:

    - should update timeLocks on stake()
    - should calculate withraw fee based on timelock  
    - should return collected fee
    - should withdraw fee collected

*/

contract StakePoolFee is Ownable {
    using SafeERC20 for IERC20;
    ///@dev State Vars
    uint256 internal collectedFee;
    IERC20 public stakeToken;

    ///@dev Mapping
    mapping(address => uint256) internal timeLocks;

    ///@dev Events

    event FeeWithdrawn(address indexed user, uint256 amount);

    ///@dev Admin
    function withdrawCollectedFee() external onlyOwner {
        /// @dev do some checks
        require(collectedFee > 0, "!Fee");

        uint256 _amount = collectedFee;

        stakeToken.safeTransfer(msg.sender, collectedFee);

        collectedFee = 0;

        emit FeeWithdrawn(msg.sender, _amount);
    }

    ///@dev Getters

    /**
        @dev Calculates withdraw fee
        @param _amount no of tokens to calculate fee
     */

    function calculateWithdrawFees(uint256 _amount, address _account)
        public
        view
        returns (uint256 _fee)
    {
        uint256 _timeLock = timeLocks[_account];
        _fee = StakePoolV2Library.calculateWithdrawFees(_amount, _timeLock);
    }

    ///@return The collected fee in wei
    function viewCollectedFee() external view returns (uint256) {
        return collectedFee;
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

/** 
    Tests Needed:

    - tiers should update on addTier
    - should calculate allocpoints based on balance
    - getTiers should return tiers array
    - tierCount should return tiers array length

*/

contract StakePoolTier is Ownable {
    ///@dev Struct
    struct Tier {
        uint256 stake;
        uint256 weight;
        uint256 unlockTime;
    }

    ///@dev Array
    Tier[] internal tiers;

    ///@dev Admin

    /**
        @dev Admin can add new tier using it
        @param _stake the number of tokens to meet this tier
        @param _weight the weight of this tier
        @param _unlockTime the time of unlocking for this tier
     */

    function addTier(
        uint256 _stake,
        uint32 _weight,
        uint256 _unlockTime
    ) public onlyOwner {
        tiers.push(
            Tier({stake: _stake, weight: _weight, unlockTime: _unlockTime})
        );
    }

    ///@dev Getters

    /**
        @dev Calculate allocpoints based on balance
        @param _balance is the number of tokens staked
        @return _points -  this is the allocation points calculated based on number of tokens
     */

    function _reBalance(uint256 _balance)
        internal
        view
        returns (uint256 _points)
    {
        _points = 0;

        Tier[] memory _tiers = tiers;
        uint256 _smallest = _tiers[_tiers.length - 1].stake;
        uint256 _tiersLength = _tiers.length;
        while (_balance >= _smallest) {
            for (uint256 i = 0; i < _tiersLength; i++) {
                if (_balance >= _tiers[i].stake) {
                    _points += _tiers[i].weight;
                    _balance -= _tiers[i].stake;
                    i = _tiers.length;
                }
            }
        }
        return _points;
    }

    /// @return Tiers Array
    function getTiers() external view returns (Tier[] memory) {
        return tiers;
    }

    /// @return tiers count
    function tierCount() public view returns (uint8) {
        return uint8(tiers.length);
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";

/** 
    Tests Needed:

    - userAdresses should update on _checkOrAddUser
    - users should return userAdresses array
    - user should return user from array by providing index
    - usersLength should return userAdresses array length

*/

contract StakePoolUser is Ownable {
    ///@dev Array
    address[] internal userAdresses;

    ///@dev Admin

    /// @return user address on the provided index
    function user(uint256 _index) external view returns (address) {
        return userAdresses[_index];
    }

    /// @return list of users
    function users() external view returns (address[] memory) {
        return userAdresses;
    }

    /// @return Length of user array
    function usersLength() external view returns (uint256) {
        return userAdresses.length;
    }

    /// @dev  Subroutine
    /// @notice update or insert the userArrray
    function _checkOrAddUser(address _user) internal returns (bool) {
        address[] memory _userAdresses = userAdresses;
        uint256 _userAdressesLength = _userAdresses.length;
        bool _new = true;
        for (uint256 i = 0; i < _userAdressesLength; i++) {
            if (_userAdresses[i] == _user) {
                _new = false;
                i = _userAdresses.length;
            }
        }
        if (_new) {
            _userAdresses[_userAdressesLength] = _user;
        }
        userAdresses = _userAdresses;
        return _new;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

/// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

library StakePoolV2Library {
    /// @dev calculateWithdrawFees
    /// @param _amount no of tokens to calculate fee
    function calculateWithdrawFees(uint256 _amount, uint256 _timeLock)
        internal
        view
        returns (uint256 _fee)
    {
        _fee = 0;

        uint256 _now = block.timestamp;

        if (_now > _timeLock + uint256(8 weeks)) {
            _fee = 0;
        }

        if (_now <= _timeLock + uint256(8 weeks)) {
            _fee = (_amount * 2) / 100;
        }

        if (_now <= _timeLock + uint256(6 weeks)) {
            _fee = (_amount * 5) / 100;
        }

        if (_now <= _timeLock + uint256(4 weeks)) {
            _fee = (_amount * 10) / 100;
        }

        if (_now <= _timeLock + uint256(2 weeks)) {
            _fee = (_amount * 20) / 100;
        }

        return _fee;
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}