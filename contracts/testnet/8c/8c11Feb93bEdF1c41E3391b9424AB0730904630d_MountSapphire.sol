//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
//BNF-02
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MountSapphire is Pausable, Ownable, ReentrancyGuard, IERC721Receiver {
    using SafeMath for uint256;

    // Info of each user
    struct UserInfo {
        uint256[] blucamonTokenIds;
        uint256 powerAll;
        uint256 finalPower;
        uint256 lastTransaction;
    }

    struct Blucamon {
        uint256 tokenId;
        uint256 power;
        uint256 element1;
        uint256 element2;
        uint256 element3;
        uint256 rarity;
        uint256 guardian;
        uint256 purity;
        uint256 species;
    }

    struct RewardToken {
        address tokenAddress;
        uint256 startTime;
        bool enabled;
    }

    struct Transaction {
        uint256 totalPower;
        uint256 rewardPerDay;
        uint256 timestamp;
    }

    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;
    uint256 public totalRewardSupply;
    uint256 public totalDistributedReward;
    bool public isRewardEmpty = false;
    RewardToken public rewardToken;
    address[] public listUserUpdate;
    IERC721 private nftToken;
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant EXA_CONSTANT = 10**18;
    uint256 constant LIMITED_BLUCAMON_SIZE = 10;
    address payable public treasury;
    address payable public buybackWallet;
    uint256 public stakingFee = 0.001 ether;
    uint256 buybackPercent = 20_00;

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public hasUser;
    mapping(uint256 => bool) public hasBlucamon;
    mapping(uint256 => Blucamon) public blucamonMapping;
    uint256[] public powerList;
    uint256[] public tokenPerDayList;

    event SetRewardToken(address _tokenAddress, uint256 _totalRewardSupply);
    event DisableRewardToken();
    event EnableRewardToken();
    event StakeTokens(address indexed user, uint256 power, uint256[] blucamons);
    event UnstakeToken(address indexed user, uint256[] blucamons);
    event EmergencyWithdraw(address indexed user, uint256 tokenCount);
    event SetIsRewardEmpty(bool _isRewardEmpty);

    constructor(
        address _nftTokenAddress,
        address _treasury,
        address _buybackWallet
    ) {
        require(_nftTokenAddress != address(0), "S_MTS_0100");
        require(_treasury != address(0), "S_MTS_0101");
        require(_buybackWallet != address(0), "S_MTS_0102");
        nftToken = IERC721(_nftTokenAddress);
        treasury = payable(_treasury);
        buybackWallet = payable(_buybackWallet);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setOwner(address _address) external onlyOwner {
        require(_address != address(0), "S_MTS_0200");
        transferOwnership(_address);
    }

    function setCondition(
        uint256[] memory _powerList,
        uint256[] memory _tokenPerDayList
    ) external onlyOwner {
        require(_tokenPerDayList.length - _powerList.length == 1, "S_MTS_0300");
        powerList = _powerList;
        tokenPerDayList = _tokenPerDayList;
        _updateTokenRewardFromCondition();
    }

    function _updateTokenRewardFromCondition() internal {
        uint256 totalPower = getTotalPowerInPool();
        uint256 lastRewardPerDay = getRewardToken();
        uint256 newRewardPerDay = _getRewardPerDayFromPower(totalPower);
        if (lastRewardPerDay != newRewardPerDay) {
            _newTransaction(totalPower, newRewardPerDay);
        }
    }

    function _updateTokenReward(uint256 _power) internal {
        uint256 newRewardPerDay = _getRewardPerDayFromPower(_power);
        _newTransaction(_power, newRewardPerDay);
    }

    function _getRewardPerDayFromPower(uint256 _power)
        private
        view
        returns (uint256)
    {
        uint256 newRewardPerDay = tokenPerDayList[tokenPerDayList.length - 1];
        for (uint256 index = 0; index < powerList.length; index++) {
            if (_power <= powerList[index]) {
                newRewardPerDay = tokenPerDayList[index];
                break;
            }
        }

        return newRewardPerDay;
    }

    function _initListUser(address _user) internal {
        if (hasUser[_user] != true) {
            listUserUpdate.push(_user);
            hasUser[_user] = true;
        }
    }

    function setIsRewardEmpty(bool _isRewardEmpty) external onlyOwner {
        isRewardEmpty = _isRewardEmpty;
        emit SetIsRewardEmpty(_isRewardEmpty);
    }

    function setBuybackPercent(uint256 _buybackPercent) external onlyOwner {
        require(_buybackPercent <= 100_00, "S_MTS_0400");
        buybackPercent = _buybackPercent;
    }

    function setStakingFee(uint256 _stakingFee) external onlyOwner {
        stakingFee = _stakingFee;
    }

    function getUserStakedTokens(address _user)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory blucamonTokenIds = new uint256[](
            userInfo[_user].blucamonTokenIds.length
        );
        for (uint256 i = 0; i < userInfo[_user].blucamonTokenIds.length; i++) {
            blucamonTokenIds[i] = userInfo[_user].blucamonTokenIds[i];
        }
        return blucamonTokenIds;
    }

    function getListBlucamonDetail(uint256[] memory tokenIds)
        external
        view
        returns (Blucamon[] memory)
    {
        Blucamon[] memory blucamons = new Blucamon[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            blucamons[i] = blucamonMapping[tokenIds[i]];
        }
        return blucamons;
    }

    function getUserFinalStakedPower(address _user)
        external
        view
        returns (uint256)
    {
        return userInfo[_user].finalPower;
    }

    function getUserStakedPower(address _user) public view returns (uint256) {
        return userInfo[_user].powerAll;
    }

    function getRewardToken() public view returns (uint256) {
        return transactions[transactionCount].rewardPerDay;
    }

    function getTotalPowerInPool() public view returns (uint256) {
        return transactions[transactionCount].totalPower;
    }

    function getListUserUpdate() external view returns (address[] memory) {
        // address[] memory list = new address[](listUserUpdate.length);
        // list = listUserUpdate;
        // return list;
        return listUserUpdate;
    }

    function setRewardToken(address _tokenAddress, uint256 _totalRewardSupply)
        external
        onlyOwner
    {
        require(_tokenAddress != address(0), "S_MTS_0500");
        rewardToken.tokenAddress = _tokenAddress;
        rewardToken.startTime = block.timestamp;
        rewardToken.enabled = true;
        totalRewardSupply = _totalRewardSupply;
        totalDistributedReward = 0;
        isRewardEmpty = false;
        emit SetRewardToken(_tokenAddress, _totalRewardSupply);
    }

    function disableTokenReward() external onlyOwner {
        require(rewardToken.enabled, "S_MTS_0600");
        rewardToken.enabled = false;
        emit DisableRewardToken();
    }

    function enableTokenReward() external onlyOwner {
        require(!rewardToken.enabled, "S_MTS_0601");
        rewardToken.enabled = true;
        emit EnableRewardToken();
    }

    function getPendingReward(address _user) external view returns (uint256) {
        if (!rewardToken.enabled || !hasUser[_user]) {
            return 0;
        }
        UserInfo memory _userInfo = userInfo[msg.sender];
        uint256 lastUserTransaction = _userInfo.lastTransaction;
        uint256 power = _userInfo.finalPower;
        uint256 reward = 0;
        for (uint256 i = lastUserTransaction; i < transactionCount; i++) {
            Transaction memory eachTransaction = transactions[i];
            uint256 eachDuration = getDuration(i);
            uint256 eachWeight = getUserWeight(
                power,
                eachTransaction.totalPower
            );
            uint256 eachRewardPerSecond = eachTransaction.rewardPerDay /
                SECONDS_PER_DAY;
            reward = reward.add(
                eachRewardPerSecond.mul(eachWeight).div(EXA_CONSTANT).mul(
                    eachDuration
                )
            );
        }
        Transaction memory lastTransaction = transactions[transactionCount];
        uint256 lastDuration = block.timestamp - lastTransaction.timestamp;
        uint256 weight = getUserWeight(power, lastTransaction.totalPower);
        uint256 rewardPerSecond = lastTransaction.rewardPerDay /
            SECONDS_PER_DAY;
        reward = reward.add(
            rewardPerSecond.mul(weight).div(EXA_CONSTANT).mul(lastDuration)
        );
        return reward;
    }

    function withdrawReward() external whenNotPaused {
        _checkIsRewardEmpty();
        _newTransaction(getTotalPowerInPool(), getRewardToken());
        _withdrawReward(userInfo[msg.sender].finalPower);
        userInfo[msg.sender].lastTransaction = transactionCount;
    }

    function _newTransaction(uint256 _power, uint256 _rewardPerDay) internal {
        transactionCount = transactionCount.add(1);
        transactions[transactionCount] = Transaction({
            totalPower: _power,
            timestamp: block.timestamp,
            rewardPerDay: _rewardPerDay
        });
    }

    function getUserWeight(uint256 _userPower, uint256 _totalPower)
        internal
        pure
        returns (uint256)
    {
        uint256 power = _userPower * EXA_CONSTANT;
        return power.div(_totalPower);
    }

    function _withdrawReward(uint256 _power) internal {
        uint256 lastUserTransaction = userInfo[msg.sender].lastTransaction;
        uint256 reward = 0;
        for (uint256 i = lastUserTransaction; i < transactionCount; i++) {
            Transaction memory transaction = transactions[i];
            if (transaction.totalPower == 0) {
                continue;
            }
            uint256 duration = getDuration(i);
            uint256 weight = getUserWeight(_power, transaction.totalPower);
            uint256 rewardPerSecond = transaction.rewardPerDay /
                SECONDS_PER_DAY;
            reward = reward.add(
                rewardPerSecond.mul(weight).div(EXA_CONSTANT).mul(duration)
            );
        }
        if (reward > 0) {
            uint256 balance = IERC20(rewardToken.tokenAddress).balanceOf(
                address(this)
            );
            if (reward > balance) {
                reward = balance;
                isRewardEmpty = true;
            }
            IERC20(rewardToken.tokenAddress).transfer(
                address(msg.sender),
                reward
            );
        }
    }

    function _removeBlucamonFromUserInfo(uint256 index, address user) internal {
        uint256[] storage blucamonTokenIds = userInfo[user].blucamonTokenIds;
        blucamonTokenIds[index] = blucamonTokenIds[blucamonTokenIds.length - 1];
        blucamonTokenIds.pop();
    }

    function getDuration(uint256 transactionNumber)
        private
        view
        returns (uint256)
    {
        return
            transactions[transactionNumber.add(1)].timestamp -
            transactions[transactionNumber].timestamp;
    }

    function isBlucamonPowerExist(uint256[] memory _blucamonIds)
        public
        view
        returns (bool)
    {
        bool isExist = true;
        for (uint256 i = 0; i < _blucamonIds.length; i++) {
            if (!hasBlucamon[_blucamonIds[i]]) {
                isExist = false;
                break;
            }
        }

        return isExist;
    }

    function _validateStaking(address _sender, uint256[] memory blucamonIds)
        internal
        view
    {
        require(isBlucamonPowerExist(blucamonIds), "S_MTS_0700");
        uint256 blucamonCount = blucamonIds.length;
        require(blucamonCount > 0, "S_MTS_0800");
        require(
            userInfo[_sender].blucamonTokenIds.length + blucamonCount <=
                LIMITED_BLUCAMON_SIZE,
            "S_MTS_0900"
        );
    }

    function _validateWithdrawal(address _sender, uint256[] memory blucamonIds)
        internal
        view
    {
        require(blucamonIds.length > 0, "S_MTS_1000");
        require(
            userInfo[_sender].blucamonTokenIds.length >= blucamonIds.length,
            "S_MTS_1100"
        );
    }

    function _checkIsRewardEmpty() internal view {
        require(!isRewardEmpty, "");
    }

    function stake(uint256[] memory _blucamonTokenIds)
        external
        payable
        whenNotPaused
    {
        _checkIsRewardEmpty();
        _validateStaking(msg.sender, _blucamonTokenIds);
        _initListUser(msg.sender);
        for (uint256 i = 0; i < _blucamonTokenIds.length; i++) {
            nftToken.safeTransferFrom(
                msg.sender,
                address(this),
                _blucamonTokenIds[i]
            );
            userInfo[msg.sender].blucamonTokenIds.push(_blucamonTokenIds[i]);
            uint256 eachPower = blucamonMapping[_blucamonTokenIds[i]].power;
            userInfo[msg.sender].powerAll = userInfo[msg.sender].powerAll.add(
                eachPower
            );
        }
        uint256 power = getUserStakedPower(msg.sender);
        uint256 bonusPercent = getBonusPercent(
            userInfo[msg.sender].blucamonTokenIds
        );
        power = power.add(power.mul(bonusPercent).div(100_00));
        uint256 totalPower = getTotalPowerInPool()
            .sub(userInfo[msg.sender].finalPower)
            .add(power);
        uint256 recentPower = userInfo[msg.sender].finalPower;
        userInfo[msg.sender].finalPower = power;
        _updateTokenReward(totalPower);
        _withdrawReward(recentPower);
        userInfo[msg.sender].lastTransaction = transactionCount;
        uint256 totalFee = stakingFee.mul(_blucamonTokenIds.length);
        require(msg.value == totalFee, "S_MTS_1200");
        if (msg.value > 0) {
            uint256 buybackAmount = totalFee.mul(buybackPercent).div(10000);
            uint256 treasuryAmount = totalFee - buybackAmount;
            if (buybackAmount > 0) {
                buybackWallet.transfer(buybackAmount);
            }
            if (treasuryAmount > 0) {
                treasury.transfer(treasuryAmount);
            }
        }
        emit StakeTokens(
            msg.sender,
            userInfo[msg.sender].powerAll,
            _blucamonTokenIds
        );
    }

    function unstake(uint256[] memory _blucamonTokenIds)
        public
        nonReentrant
        whenNotPaused
    {
        _validateWithdrawal(msg.sender, _blucamonTokenIds);
        bool findToken;
        for (uint256 i = 0; i < _blucamonTokenIds.length; i++) {
            findToken = false;
            for (
                uint256 j = 0;
                j < userInfo[msg.sender].blucamonTokenIds.length;
                j++
            ) {
                if (
                    _blucamonTokenIds[i] ==
                    userInfo[msg.sender].blucamonTokenIds[j]
                ) {
                    nftToken.safeTransferFrom(
                        address(this),
                        msg.sender,
                        _blucamonTokenIds[i]
                    );
                    uint256 eachPower = blucamonMapping[_blucamonTokenIds[i]]
                        .power;
                    userInfo[msg.sender].powerAll = userInfo[msg.sender]
                        .powerAll
                        .sub(eachPower);
                    _removeBlucamonFromUserInfo(j, msg.sender);
                    findToken = true;
                    break;
                }
            }
            require(findToken, "S_MTS_1300");
        }
        uint256 power = getUserStakedPower(msg.sender);
        uint256 bonusPercent = getBonusPercent(
            userInfo[msg.sender].blucamonTokenIds
        );
        power = power.add(power.mul(bonusPercent).div(100_00));
        uint256 totalPower = getTotalPowerInPool()
            .sub(userInfo[msg.sender].finalPower)
            .add(power);
        uint256 recentPower = userInfo[msg.sender].finalPower;
        userInfo[msg.sender].finalPower = power;
        _updateTokenReward(totalPower);
        _withdrawReward(recentPower);
        userInfo[msg.sender].lastTransaction = transactionCount;
        emit UnstakeToken(msg.sender, _blucamonTokenIds);
    }

    function emergencyUnstake() external whenNotPaused {
        uint256[] memory blucamonTokenIds = userInfo[msg.sender]
            .blucamonTokenIds;
        uint256 userPower = userInfo[msg.sender].finalPower;
        delete userInfo[msg.sender];
        for (uint256 i = 0; i < blucamonTokenIds.length; i++) {
            nftToken.safeTransferFrom(
                address(this),
                msg.sender,
                blucamonTokenIds[i]
            );
        }
        uint256 newTotalPower = getTotalPowerInPool() - userPower;
        _updateTokenReward(newTotalPower);
        emit EmergencyWithdraw(msg.sender, blucamonTokenIds.length);
    }

    function emergencyRewardTokenWithdraw(address _token, uint256 _amount)
        external
        onlyOwner
    {
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount,
            "S_MTS_1400"
        );
        IERC20(_token).transfer(msg.sender, _amount);
    }

    function updateBlucamonPower(Blucamon[] memory blucamons)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < blucamons.length; i++) {
            uint256 tokenId = blucamons[i].tokenId;
            uint256 power = blucamons[i].power;
            if (!hasBlucamon[tokenId]) {
                hasBlucamon[tokenId] = true;
                blucamonMapping[tokenId] = blucamons[i];
            } else if (blucamonMapping[tokenId].power != power) {
                blucamonMapping[tokenId].power = power;
            }
        }
    }

    function getBonusPercent(uint256[] memory _blucamonTokenIds)
        public
        view
        returns (uint256)
    {
        if (_blucamonTokenIds.length <= 1) {
            return 0;
        }
        uint256 totalPurity = 0;
        uint256 totalPercent = 0;
        uint256[] memory species = new uint256[](_blucamonTokenIds.length);
        uint256[] memory rarities = new uint256[](8);
        uint256[] memory guardians = new uint256[](7);
        uint256[] memory elements = new uint256[](6);
        for (uint256 i = 0; i < _blucamonTokenIds.length; i++) {
            Blucamon memory blucamon = blucamonMapping[_blucamonTokenIds[i]];
            bool isExist = false;
            for (uint256 j = 0; j < species.length; j++) {
                if (species[j] == blucamon.species) {
                    isExist = true;
                    break;
                }
            }
            totalPurity = totalPurity.add(blucamon.purity);
            if (isExist) {
                continue;
            }

            species[i] = blucamon.species;
            rarities[blucamon.rarity] = rarities[blucamon.rarity].add(1);
            if (rarities[blucamon.rarity] == 3) {
                totalPercent = totalPercent.add(1_00);
            } else if (rarities[blucamon.rarity] == 5) {
                totalPercent = totalPercent.add(2_00);
            } else if (rarities[blucamon.rarity] == 10) {
                totalPercent = totalPercent.add(2_00);
            }

            guardians[blucamon.guardian] = guardians[blucamon.guardian].add(1);
            if (guardians[blucamon.guardian] == 3) {
                totalPercent = totalPercent.add(50);
            } else if (guardians[blucamon.guardian] == 5) {
                totalPercent = totalPercent.add(50);
            } else if (guardians[blucamon.guardian] == 10) {
                totalPercent = totalPercent.add(1_00);
            }

            if (blucamon.element1 != 0) {
                elements[blucamon.element1] = elements[blucamon.element1].add(
                    1
                );
                if (elements[blucamon.element1] == 3) {
                    totalPercent = totalPercent.add(50);
                } else if (elements[blucamon.element1] == 5) {
                    totalPercent = totalPercent.add(1_50);
                } else if (elements[blucamon.element1] == 10) {
                    totalPercent = totalPercent.add(2_00);
                }
            }

            if (blucamon.element2 != 0) {
                elements[blucamon.element2] = elements[blucamon.element2].add(
                    1
                );
                if (elements[blucamon.element2] == 3) {
                    totalPercent = totalPercent.add(50);
                } else if (elements[blucamon.element2] == 5) {
                    totalPercent = totalPercent.add(1_50);
                } else if (elements[blucamon.element2] == 10) {
                    totalPercent = totalPercent.add(2_00);
                }
            }

            if (blucamon.element3 != 0) {
                elements[blucamon.element3] = elements[blucamon.element3].add(
                    1
                );
                if (elements[blucamon.element3] == 3) {
                    totalPercent = totalPercent.add(50);
                } else if (elements[blucamon.element3] == 5) {
                    totalPercent = totalPercent.add(1_50);
                } else if (elements[blucamon.element3] == 10) {
                    totalPercent = totalPercent.add(2_00);
                }
            }
        }

        uint256 averagePurity = totalPurity.div(_blucamonTokenIds.length);
        if (averagePurity >= 90) {
            totalPercent = totalPercent.add(7_50);
        } else if (averagePurity >= 80) {
            totalPercent = totalPercent.add(4_00);
        } else if (averagePurity >= 60) {
            totalPercent = totalPercent.add(1_50);
        } else if (averagePurity >= 40) {
            totalPercent = totalPercent.add(50);
        }

        return totalPercent;
    }
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

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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