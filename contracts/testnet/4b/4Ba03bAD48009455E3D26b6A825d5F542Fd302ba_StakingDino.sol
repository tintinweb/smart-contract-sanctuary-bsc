// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../core/interface/IDinolandNFT.sol";

contract StakingDino is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using Counters for Counters.Counter;
    Counters.Counter internal _tokenIdCounter;
    
    /*** CONSTRUCTOR ***/
    constructor(address _tokenAddress, address _nftAddress) {
        tokenContract = IERC20(_tokenAddress);
        nftContract = IDinolandNFT(_nftAddress);
        startStakingAt = block.timestamp;
        endStakingAt = block.timestamp + 7 days;
        nondinoDailyAPR = 50;
        dinoDailyAPR = 68;
        /// Mapping rarity to multiplier
        rarityToMultiplier[11] = 12000;
        rarityToMultiplier[12] = 13000;
        rarityToMultiplier[13] = 15000;
        rarityToMultiplier[14] = 17500;
        rarityToMultiplier[15] = 20000;
    }

    /*** EVENTS ***/
    /// @dev Event emmitted when a new staking is created
    event Staked(
        address indexed staker,
        uint256 indexed stakeId,
        uint256 amount,
        uint256 dinoId
    );
    /// @dev Event emmitted when a staking is requested to be claim
    event RequestClaimed(address indexed staker, uint256 indexed stakeId);
    /// @dev Event emmitted when a staking is claimed
    event Claimed(
        address indexed staker,
        uint256 indexed stakeId,
        uint256 amount,
        uint256 dinoId
    );

    /*** DATA TYPES ***/
    /// @dev DNL token Address
    IERC20 public tokenContract;
    /// @dev Dinoland NFT Address
    IDinolandNFT public nftContract;
    /// @dev Array of staking addresses
    address[] internal _addresses;
    /// @dev Whitelisted admin
    mapping(address => bool) whitelistAdmin;
    /// @dev Address to their staking Ids
    mapping(address => uint256[]) private addressToIds;
    /// @dev Claimable time of specific stake id
    mapping(uint256 => uint256) public idToClaimAbleAt;
    /// @dev Id to stake detail
    mapping(uint256 => StakeDetail) public idToStakeDetail;
    /// @dev Id to stake status
    mapping(uint256 => StakeStatus) public idToStakeStatus;
    /// @dev Daily APR when stake without dino
    uint256 public nondinoDailyAPR = 50;
    /// @dev Daily APR when stake with dino
    uint256 public dinoDailyAPR = 68;
    /// @dev Time point begin and end staking
    uint256 public startStakingAt;
    uint256 public endStakingAt;
    /// @dev Total staked DNL
    uint256 public totalDNLStaked;
    /// @dev Total staked DINO
    uint256 public totalDINOStaked;
    /// @dev Pool or not's lock duration
    // uint256 public stakeLockDuration = 7 days;
    uint256 public stakeLockDuration = 24 * 60;
    /// @dev Claim lock duration
    // uint256 public claimLockDuration = 7 days;
    uint256 public claimLockDuration = 24 * 60;
    
    /// @dev Constants for interest calculation
    // uint256 constant ONE_DAY_IN_SECONDS = 24 * 60 * 60;
    // uint256 constant ONE_HOUR_IN_SECONDS = 60 * 60;
    uint256 constant ONE_DAY_IN_SECONDS =  60;
    uint256 constant ONE_HOUR_IN_SECONDS = 60;

    /// @dev Mapping that map rarity to its Multiplier
    mapping(uint256 => uint256) public rarityToMultiplier;

    /// @dev The pool is enabled or not
    bool public enabled = true;

    /// @dev Struct that specify detail of a staking id
    struct StakeDetail {
        /// @dev When stake was created
        uint256 startAt;
        /// @dev When stake will be requested to be claimed
        uint256 endAt;
        /// @dev Stake amount
        uint256 amount;
        /// @dev When dino was staked
        uint256 startStakeDinoAt;
        /// @dev Current stake daily APR
        uint256 currentDailyAPR;
        /// @dev Owner of this stake id
        address owner;
        /// @dev Total interest rate before stake dino to this Id
        uint256 totalInterestBeforeStakeDino;
        /// @dev Total point before stake dino to this id
        uint256 totalPointBeforeStakeDino;
        /// @dev Staked Dino Id
        uint256 stakedDinoId;
    }

    /// @dev Enum that specify status of a staking id
    enum StakeStatus {
        Staked,
        ClaimRequested,
        Claimed
    }

    /*** MODIFIERS ***/

    /// @dev Access modifier for StakeHolder-only functionality
    /// @param _id Id of the stake
    modifier onlyStakeholder(uint256 _id) {
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        require(
            stakeDetail.owner == msg.sender,
            "Caller is not the stakeholder"
        );
        _;
    }

    /// @dev Access modifier for AdminOrOwner-only functionality
    modifier onlyAdminOrOwner() {
        require(
            msg.sender == owner() || whitelistAdmin[msg.sender] == true,
            "You don't have permission to perform action"
        );
        _;
    }

    /*** FUNCTIONS ***/
    /// @dev Update enabled Pool
    /// @param _enabled Enabled Pool or not
    function setEnabled(bool _enabled) external onlyAdminOrOwner {
        enabled = _enabled;
    }

    /// @dev Set start time of this staking pool
    /// @param _time When the staking will start
    function setStartStakingAt(uint256 _time) external onlyAdminOrOwner {
        startStakingAt = _time;
    }

    /// @dev Set end time of this staking pool
    /// @param _time When the staking will end
    function setEndStakingAt(uint256 _time) external onlyAdminOrOwner {
        endStakingAt = _time;
    }

    /// @dev Set nft contract
    /// @param _nftAddress Address of the nft contract
    function setNftContractAddress(address _nftAddress) external onlyOwner {
        nftContract = IDinolandNFT(_nftAddress);
    }

    /// @dev Change token contract address staking
    /// @param _newTokenAddress Address of the token contract
    function setTokenContractAddress(address _newTokenAddress)
        external
        onlyOwner
    {
        tokenContract = IERC20(_newTokenAddress);
    }

    /// @dev Update white list admin for runing autotask
    /// @param _admin Address of the admin
    /// @param _isAdmin Is admin or not
    function setWhitelistAdmin(address _admin, bool _isAdmin)
        external
        onlyOwner
    {
        whitelistAdmin[_admin] = _isAdmin;
    }

    /// @dev Update non dino daily apr
    /// @param _apr Daily apr of non dino staking
    function setNondinoDailyAPR(uint256 _apr) external onlyAdminOrOwner {
        nondinoDailyAPR = _apr;
    }

    /// @dev Update dino daily apr
    /// @param _apr Daily apr of dino staking
    function setDinoDailyAPR(uint256 _apr) external onlyAdminOrOwner {
        dinoDailyAPR = _apr;
    }

    /// @dev Set stake lock duration
    /// @param _duration Lock duration of staking
    function setStakeLockDuration(uint256 _duration) external onlyAdminOrOwner {
        stakeLockDuration = _duration;
    }

    /// @dev Set claim lock duration
    /// @param _duration Lock duration of claiming
    function setClaimLockDuration(uint256 _duration) external onlyAdminOrOwner {
        claimLockDuration = _duration;
    }

    /// @dev Get Stake detail by Id
    /// @param _id Id of the stake
    function getStakeDetail(uint256 _id)
        external
        view
        returns (StakeDetail memory)
    {
        return idToStakeDetail[_id];
    }

    /// @dev set multiplier for rarity
    /// @param _rarity Rarity of the dino Eg: 11, 12, 13, 14, 15
    /// @param _multiplier Multiplier of the rarity
    function setRarityMultiplier(uint256 _rarity, uint256 _multiplier)
        external
        onlyAdminOrOwner
    {
        rarityToMultiplier[_rarity] = _multiplier;
    }

    /// @dev Stake with dino or not
    /// @param _amount Amount of DNL to stake
    /// @param _dinoId Id of the staked dino (equal to zero if not stake dino)
    function stake(uint256 _amount, uint256 _dinoId) external nonReentrant {
        uint256 currentTimestamp = block.timestamp;
        require(enabled, "Staking is disabled");
        require(_amount > 0, "Amount must be greater than 0");
        require(
            currentTimestamp >= startStakingAt &&
                currentTimestamp <= endStakingAt,
            "Staking is not availabe at this time"
        );
        if (_dinoId > 0) {
            require(
                nftContract.ownerOf(_dinoId) == msg.sender,
                "You are not the owner of this dino"
            );
            totalDINOStaked = totalDINOStaked.add(1);
        }
        totalDNLStaked = totalDNLStaked + _amount;
        uint256 currentId = _tokenIdCounter.current();
        /// @dev When stake dino
        if (_dinoId > 0) {
            StakeDetail memory stakeDetail = StakeDetail(
                currentTimestamp,
                currentTimestamp + stakeLockDuration,
                _amount,
                currentTimestamp,
                dinoDailyAPR,
                msg.sender,
                0,
                0,
                _dinoId
            );
            idToStakeDetail[currentId] = stakeDetail;
            nftContract.transferFrom(msg.sender, address(this), _dinoId);
        } else {
            StakeDetail memory stakeDetail = StakeDetail(
                currentTimestamp,
                currentTimestamp + stakeLockDuration,
                _amount,
                0,
                nondinoDailyAPR,
                msg.sender,
                0,
                0,
                0
            );
            idToStakeDetail[currentId] = stakeDetail;
        }
        if (addressToIds[msg.sender].length == 0) {
            _addresses.push(msg.sender);
        }
        addressToIds[msg.sender].push(currentId);
        tokenContract.transferFrom(msg.sender, address(this), _amount);
        _tokenIdCounter.increment();
        emit Staked(msg.sender, currentId, _amount, _dinoId);
    }

    /// @dev Get current interest by Id
    /// @param _id Id of the stake
    function getCurrentInterestById(uint256 _id) public view returns (uint256) {
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        uint256 stakePeriod;
        if (block.timestamp >= stakeDetail.endAt) {
            stakePeriod = stakeDetail.endAt - stakeDetail.startAt;
        } else {
            stakePeriod = block.timestamp - stakeDetail.startAt;
        }

        /// @dev Case 1: when not staked dino from beginning
        uint256 currentInterest;
        if (stakeDetail.stakedDinoId == 0) {
            currentInterest = stakeDetail
                .amount
                .mul(stakePeriod)
                .mul(stakeDetail.currentDailyAPR)
                .div(ONE_DAY_IN_SECONDS)
                .div(10000);
            return currentInterest;
        }
        /// @dev Case 2: when staked dino from beginning
        if (
            stakeDetail.stakedDinoId > 0 &&
            stakeDetail.startAt == stakeDetail.startStakeDinoAt
        ) {
            currentInterest = stakeDetail
                .amount
                .mul(stakePeriod)
                .mul(stakeDetail.currentDailyAPR)
                .div(ONE_DAY_IN_SECONDS)
                .div(10000);
            return currentInterest;
        }
        /// @dev Case 3: when stake dino to boost apy later
        uint256 stakeDinoPeriod;
        if (block.timestamp >= stakeDetail.endAt) {
            stakeDinoPeriod =
                stakeDetail.endAt -
                stakeDetail.startStakeDinoAt +
                1;
        } else {
            stakeDinoPeriod =
                block.timestamp -
                stakeDetail.startStakeDinoAt +
                1;
        }
        currentInterest = stakeDetail.totalInterestBeforeStakeDino.add(
            stakeDetail
                .amount
                .mul(stakeDinoPeriod)
                .mul(stakeDetail.currentDailyAPR)
                .div(ONE_DAY_IN_SECONDS)
                .div(10000)
        );
        return currentInterest;
    }

    /// @dev Get current point by Id
    /// @param _id Id of the stake
    function getCurrentPointById(uint256 _id) public view returns (uint256) {
        StakeDetail memory stakeDetail = idToStakeDetail[_id];

        uint256 stakePeriod;
        if (block.timestamp >= endStakingAt) {
            stakePeriod = endStakingAt - stakeDetail.startAt;
        } else {
            stakePeriod = block.timestamp - stakeDetail.startAt;
        }
        uint256 currentPoint;
        uint256 stakeDurationInHour = stakePeriod.div(ONE_HOUR_IN_SECONDS);
        /// @dev Get multiplier
        uint256 multiplier = 10000;
        if (stakeDetail.stakedDinoId > 0) {
            multiplier = getDinoMultiplier(stakeDetail.stakedDinoId);
        }
        /// @dev Case 1: when not stake dino from beginning
        if (stakeDetail.stakedDinoId == 0) {
            currentPoint = stakeDetail.amount.div(1e18).div(250);
            return currentPoint.mul(stakeDurationInHour).mul(10);
        }
        /// @dev Case 2: when stake dino from beginning
        if (
            stakeDetail.stakedDinoId > 0 &&
            stakeDetail.startAt == stakeDetail.startStakeDinoAt
        ) {
            currentPoint = stakeDetail.amount.div(1e18).div(250);
            return
                currentPoint
                    .mul(stakeDurationInHour)
                    .mul(10)
                    .mul(multiplier)
                    .div(10000);
        }
        /// @dev Case 3: when stake dino to boost point later
        uint256 stakeDinoPeriod;
        if (block.timestamp >= endStakingAt) {
            stakeDinoPeriod = endStakingAt - stakeDetail.startStakeDinoAt;
        } else {
            stakeDinoPeriod = block.timestamp - stakeDetail.startStakeDinoAt;
        }
        currentPoint = stakeDetail.totalPointBeforeStakeDino;
        uint256 currentAdditionalPoint = stakeDetail.amount.div(1e18).div(250);
        uint256 stakeDinoDurationInHour = stakeDinoPeriod.div(
            ONE_HOUR_IN_SECONDS
        );
        currentPoint = currentPoint.add(
            currentAdditionalPoint
                .mul(stakeDinoDurationInHour)
                .mul(10)
                .mul(multiplier)
                .div(10000)
        );
        return currentPoint;
    }

    /// @dev Get current point of an address
    /// @param _address Address of the staker
    function getCurrentTotalPointOfAddress(address _address)
        public
        view
        returns (uint256)
    {
        uint256 currentPoint = 0;
        for (uint256 i = 0; i < addressToIds[_address].length; i++) {
            currentPoint = currentPoint.add(
                getCurrentPointById(addressToIds[_address][i])
            );
        }
        return currentPoint;
    }

    /// @dev Get current total interest of an address
    /// @param _address Address of the staker
    function getCurrentTotalInterestOfAddress(address _address)
        public
        view
        returns (uint256)
    {
        uint256 currentInterest = 0;
        for (uint256 i = 0; i < addressToIds[_address].length; i++) {
            currentInterest = currentInterest.add(
                getCurrentInterestById(addressToIds[_address][i])
            );
        }
        return currentInterest;
    }

    /// @dev Get Dino rarity by id
    /// @param _dinoId Id of the dino
    function getDinoRarity(uint256 _dinoId) public view returns (uint256) {
        (uint256 genes, , , , ) = nftContract.getDino(_dinoId);
        return genes - (genes / 100) * 100;
    }

    /// @dev Get Dino multiplier by id
    /// @param _dinoId Id of the dino
    function getDinoMultiplier(uint256 _dinoId) public view returns (uint256) {
        return rarityToMultiplier[getDinoRarity(_dinoId)];
    }

    /// @dev Boost apy by stake dino to the current existing Id
    /// @param _id Id of the stake
    /// @param _dinoId Id of the staked Dino
    function stakeDinoToId(uint256 _id, uint256 _dinoId) external nonReentrant {
        StakeDetail storage stakeDetail = idToStakeDetail[_id];
        require(stakeDetail.stakedDinoId == 0, "You already staked with dino");
        require(
            nftContract.ownerOf(_dinoId) == msg.sender,
            "You are not the owner of this dino"
        );
        require(
            stakeDetail.owner == msg.sender,
            "You are not the owner of this id"
        );
        require(
            block.timestamp <= endStakingAt,
            "Staking is not availabe at this time"
        );
        /// @dev Transfer dino from user to contract
        nftContract.transferFrom(msg.sender, address(this), _dinoId);
        /// @dev Increase total staked dino
        totalDINOStaked = totalDINOStaked.add(1);
        /// @dev Calculate current interest and point
        uint256 currentInterest = getCurrentInterestById(_id);
        uint256 currentPoint = getCurrentPointById(_id);
        /// @dev Update stake detail
        stakeDetail.startStakeDinoAt = block.timestamp;
        stakeDetail.stakedDinoId = _dinoId;
        stakeDetail.currentDailyAPR = dinoDailyAPR;
        stakeDetail.totalInterestBeforeStakeDino = currentInterest;
        stakeDetail.totalPointBeforeStakeDino = currentPoint;
    }

    /// @dev Request Claim Token by staking id
    /// @param _id Id of the stake
    function requestClaim(uint256 _id)
        external
        nonReentrant
        onlyStakeholder(_id)
    {
        uint256 currentTimestamp = block.timestamp;
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        require(
            currentTimestamp >= stakeDetail.endAt,
            "You can not request claim at this time"
        );
        idToStakeStatus[_id] = StakeStatus.ClaimRequested;
        idToClaimAbleAt[_id] = currentTimestamp.add(claimLockDuration);

        emit RequestClaimed(msg.sender, _id);
    }

    /// @dev Claim Token  by staking id
    /// @param _id Id of the stake
    function claim(uint256 _id) external nonReentrant onlyStakeholder(_id) {
        uint256 currentTimestamp = block.timestamp;
        StakeDetail memory stakeDetail = idToStakeDetail[_id];
        require(
            idToStakeStatus[_id] == StakeStatus.ClaimRequested &&
                currentTimestamp >= idToClaimAbleAt[_id],
            "You can not claim at this time"
        );
        uint256 interest = getCurrentInterestById(_id);
        // If stake id exists dino
        if (stakeDetail.stakedDinoId > 0) {
            nftContract.transferFrom(
                address(this),
                stakeDetail.owner,
                stakeDetail.stakedDinoId
            );
        }

        tokenContract.transfer(msg.sender, stakeDetail.amount + interest);
        idToStakeStatus[_id] = StakeStatus.Claimed;
        emit Claimed(msg.sender, _id, interest, stakeDetail.stakedDinoId);
    }

    /// @dev Get staking ids by address
    /// @param _address Address of the staker
    function getStakingIdsByAddress(address _address)
        external
        view
        returns (uint256[] memory)
    {
        return addressToIds[_address];
    }

    /// @dev Get stake holders count
    function getStakeHoldersCount() external view returns (uint256) {
        return _addresses.length;
    }

    /// @dev Get address of stake holder by index
    function getAddressByIndex(uint256 _index) external view returns (address) {
        return _addresses[_index];
    }

    /// @dev Get total staked DNL
    function getTotalStaked() public view returns (uint256) {
        return totalDNLStaked;
    }

    /// @dev Return all of addresses and their total point
    function getAllAddressAndTotalPoint()
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        address[] memory addresses = new address[](_addresses.length);
        uint256[] memory points = new uint256[](_addresses.length);
        for (uint256 i = 0; i < _addresses.length; i++) {
            addresses[i] = _addresses[i];
            points[i] = getCurrentTotalPointOfAddress(_addresses[i]);
        }
        return (addresses, points);
    }

    /// @dev Transfer Fund
    /// @param _recipient Address of the recipient
    /// @param _amount Amount of the transfer
    function transfer(address _recipient, uint256 _amount)
        external
        onlyOwner
        returns (bool)
    {
        return tokenContract.transfer(_recipient, _amount);
    }

    /// @dev Transfer Dino
    /// @param _recipient Address of the recipient
    /// @param _dinoId Id of the dino
    function transferDino(address _recipient, uint256 _dinoId)
        external
        onlyOwner
        returns (bool)
    {
        nftContract.transferFrom(address(this), _recipient, _dinoId);
        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
interface IDinolandNFT is IERC721 {
    function createDino(
        uint256 _dinoGenes,
        address _ownerAddress,
        uint128 _gender,
        uint128 _generation
    ) external returns (uint256);

    function getDinosByOwner(address _owner)
        external
        returns (uint256[] memory);

    function getDino(uint256 _dinoId)
        external
        view
        returns (
            uint256 genes,
            uint256 bornAt,
            uint256 cooldownEndAt,
            uint128 gender,
            uint128 generation
        );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
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
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

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
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

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
}

// SPDX-License-Identifier: MIT

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
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
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

// SPDX-License-Identifier: MIT

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
     * by making the `nonReentrant` function external, and make it call a
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
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}