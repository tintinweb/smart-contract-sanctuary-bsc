// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";
import "./Ownable.sol";

error WaitPeriodNotElapsed();
error TransferLimitReached();
error RewardBalanceZero();
error InvalidLength();
error InvalidData();
error AlreadySet();
error NotEnoughFund();
error NotAuthorised();
error TransferNotAllowed();

contract SPTToken is ERC20, Ownable {
    uint256 public constant maxTotalSupply = 100 * 10**6 * 10**18;
    uint256 private constant initialTotalSupply = 1 * 10**6 * 10**18;
    uint256 private constant minTotalSupplyForStopBurn = 50 * 10**6 * 10**18;
    uint256 public constant denominator = 10000;

    uint256 public dailyRewardRate;
    uint256 public burnFee;
    uint256 public transferFee;

    address public prime_holders_address;
    address public development_address;
    address public management_address;
    address public marketing_address;
    address public core_holders_address;

    bool public shouldTakeSellFee = true;
    bool public shouldBurn = false;
    bool public shouldChargeTransfer = false;

    address[] private holdersArray;
    address[] private holdersArrayCore;
    address[] private isCallerArray;

    mapping(address => bool) public isCallerMap;
    mapping(address => HoldStruct) public holdersMap;
    mapping(address => HoldStructCore) public holdersMapCore;
    mapping(address => bool) public _isExemptFromFee;
    mapping(address => bool) public _isExemptFromReward;
    mapping(address => bool) public _isDex;

    SlotDaysInfo public slotDaysInfo;
    SlotDaysFeeInfo public slotDaysFeeInfo;
    SlotDaysFeeInfo public slotDaysFeeInfoDex;
    SlotDaysRewardInfo public slotDaysRewardInfo;

    struct SlotDaysInfo {
        uint256 slot1Days;
        uint256 slot2Days;
        uint256 slot3Days;
        uint256 slot4Days;
        uint256 slot5Days;
        uint256 slot6Days;
    }

    struct SlotDaysFeeInfo {
        uint256 feeBeforeDaysSlot1;
        uint256 feeBeforeDaysSlot2;
        uint256 feeBeforeDaysSlot3;
        uint256 feeBeforeDaysSlot4;
        uint256 feeBeforeDaysSlot5;
        uint256 feeBeforeDaysSlot6;
    }

    struct SlotDaysRewardInfo {
        uint256 rewardAfterDaysSlot1;
        uint256 rewardAfterDaysSlot2;
        uint256 rewardAfterDaysSlot3;
        uint256 rewardAfterDaysSlot4;
        uint256 rewardAfterDaysSlot5;
        uint256 rewardAfterDaysSlot6;
    }

    struct HoldStruct {
        uint256 start_hold_timestamp;
        uint256 last_daily_reward_timestamp;
        uint256 interestPaid;
        uint256 daysRewarded;
        bool slot1Rewarded;
        bool slot2Rewarded;
        bool slot3Rewarded;
        bool slot4Rewarded;
        bool slot5Rewarded;
        bool slot6Rewarded;
    }

    struct HoldStructCore {
        bool isCoreHolder;
        uint256 last_transfer_timestamp;
        uint256 amount10percent;
        uint256 amount25percent;
        uint256 amount75percent;
        uint256 amountTotal;
    }

    struct LengthInfo {
        uint256 afterSlot1days_length;
        uint256 afterSlot2days_length;
        uint256 afterSlot3days_length;
        uint256 afterSlot4days_length;
        uint256 afterSlot5days_length;
        uint256 afterSlot6days_length;
    }

    struct RewardInfo {
        uint256 rewardAfterSlot1;
        uint256 rewardAfterSlot2;
        uint256 rewardAfterSlot3;
        uint256 rewardAfterSlot4;
        uint256 rewardAfterSlot5;
        uint256 rewardAfterSlot6;
    }

    struct RewardPerUserInfo {
        uint256 rewardAfterSlot1PerUser;
        uint256 rewardAfterSlot2PerUser;
        uint256 rewardAfterSlot3PerUser;
        uint256 rewardAfterSlot4PerUser;
        uint256 rewardAfterSlot5PerUser;
        uint256 rewardAfterSlot6PerUser;
    }

    struct RewardArrayInfo {
        address[] afterSlot1days;
        address[] afterSlot2days;
        address[] afterSlot3days;
        address[] afterSlot4days;
        address[] afterSlot5days;
        address[] afterSlot6days;
    }

    constructor(
        address _development_address,
        address _management_address,
        address _marketing_address,
        address _prime_holders_address,
        address _core_holders_address
    ) ERC20("Supporter Token", "SPT") {
        _mint(msg.sender, (75 * initialTotalSupply) / 100);
        _mint(_core_holders_address, (25 * initialTotalSupply) / 100);

        uint256 block_timestamp = block.timestamp;

        holdersArray.push(msg.sender);
        holdersMap[msg.sender].start_hold_timestamp = block_timestamp;
        _isExemptFromFee[msg.sender] = true;
        _isExemptFromReward[msg.sender] = true;

        development_address = _development_address;
        holdersArray.push(_development_address);
        holdersMap[_development_address].start_hold_timestamp = block_timestamp;
        _isExemptFromFee[_development_address] = true;
        _isExemptFromReward[_development_address] = true;

        management_address = _management_address;
        holdersArray.push(_management_address);
        holdersMap[_management_address].start_hold_timestamp = block_timestamp;
        _isExemptFromFee[_management_address] = true;
        _isExemptFromReward[_management_address] = true;

        marketing_address = _marketing_address;
        holdersArray.push(_marketing_address);
        holdersMap[_marketing_address].start_hold_timestamp = block_timestamp;
        _isExemptFromFee[_marketing_address] = true;
        _isExemptFromReward[_marketing_address] = true;

        prime_holders_address = _prime_holders_address;
        holdersArray.push(_prime_holders_address);
        holdersMap[_prime_holders_address].start_hold_timestamp = block_timestamp;
        _isExemptFromFee[_prime_holders_address] = true;
        _isExemptFromReward[_prime_holders_address] = true;

        core_holders_address = _core_holders_address;
        holdersArray.push(_core_holders_address);
        holdersMap[_core_holders_address].start_hold_timestamp = block_timestamp;
        _isExemptFromFee[_core_holders_address] = true;
        _isExemptFromReward[_core_holders_address] = true;

        slotDaysInfo = SlotDaysInfo(120, 240, 360, 480, 600, 720);

        slotDaysFeeInfo = SlotDaysFeeInfo(3500, 3500, 3000, 2000, 1000, 500);

        slotDaysFeeInfoDex = SlotDaysFeeInfo(3200, 3200, 3000, 2000, 1000, 500);

        slotDaysRewardInfo = SlotDaysRewardInfo(500, 1000, 1500, 2000, 2250, 2750);

        dailyRewardRate = 30;
        burnFee = 100;
        transferFee = 100;

        isCallerArray.push(msg.sender);
        isCallerMap[msg.sender] = true;
    }

    modifier onlyCaller() {
        if (!isCallerMap[msg.sender]) {
            revert NotAuthorised();
        }
        _;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (holdersMapCore[to].isCoreHolder) {
            revert TransferNotAllowed();
        }

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 block_timestamp = block.timestamp;

        if (holdersMapCore[from].isCoreHolder) {
            HoldStructCore memory _holdStructCore = holdersMapCore[from];
            uint256 daysFromLastTransfer = block_timestamp -
                _holdStructCore.last_transfer_timestamp;

            if (amount <= _holdStructCore.amount25percent) {
                holdersMapCore[from].amount25percent -= amount;
                holdersMapCore[from].last_transfer_timestamp = block_timestamp;
            } else if (amount <= _holdStructCore.amount10percent) {
                if (daysFromLastTransfer > 30 days) {
                    uint256 toBeRemovedFromAmount75percent;

                    if (_holdStructCore.amount25percent > 0) {
                        toBeRemovedFromAmount75percent = amount - _holdStructCore.amount25percent;
                        holdersMapCore[from].amount25percent = 0;
                    } else {
                        toBeRemovedFromAmount75percent = amount;
                    }

                    holdersMapCore[from].amount75percent -= toBeRemovedFromAmount75percent;
                    holdersMapCore[from].last_transfer_timestamp = block_timestamp;
                } else {
                    revert WaitPeriodNotElapsed();
                }
            } else {
                revert TransferLimitReached();
            }
        }

        if (
            holdersMap[to].start_hold_timestamp == 0 &&
            holdersMap[to].last_daily_reward_timestamp == 0
        ) {
            holdersArray.push(to);
            holdersMap[to].start_hold_timestamp = block_timestamp;
            holdersMap[to].last_daily_reward_timestamp = block_timestamp;
        } else if (_balances[to] == 0) {
            holdersMap[to].start_hold_timestamp = block_timestamp;
            holdersMap[to].last_daily_reward_timestamp = block_timestamp;
        }

        uint256 holdTime = block_timestamp - holdersMap[from].start_hold_timestamp;
        uint256 sell_fee;
        uint256 transfer_fee;
        uint256 burn_fee;

        if (!_isExemptFromFee[from]) {
            if (shouldTakeSellFee) {
                SlotDaysInfo memory _slotDaysInfo = slotDaysInfo;
                SlotDaysFeeInfo memory _slotDaysFeeInfo = slotDaysFeeInfo;

                if (_isDex[to]) {
                    _slotDaysFeeInfo = slotDaysFeeInfoDex;
                }
                if (holdTime < _slotDaysInfo.slot1Days * 1 days) {
                    sell_fee = (amount * _slotDaysFeeInfo.feeBeforeDaysSlot1) / denominator;
                } else if (
                    holdTime >= _slotDaysInfo.slot1Days * 1 days &&
                    holdTime < _slotDaysInfo.slot2Days * 1 days
                ) {
                    sell_fee = (amount * _slotDaysFeeInfo.feeBeforeDaysSlot2) / denominator;
                } else if (
                    holdTime >= _slotDaysInfo.slot2Days * 1 &&
                    holdTime < _slotDaysInfo.slot3Days * 1 days
                ) {
                    sell_fee = (amount * _slotDaysFeeInfo.feeBeforeDaysSlot3) / denominator;
                } else if (
                    holdTime >= _slotDaysInfo.slot3Days * 1 days &&
                    holdTime < _slotDaysInfo.slot4Days * 1 days
                ) {
                    sell_fee = (amount * _slotDaysFeeInfo.feeBeforeDaysSlot4) / denominator;
                } else if (
                    holdTime >= _slotDaysInfo.slot4Days * 1 days &&
                    holdTime < _slotDaysInfo.slot5Days * 1 days
                ) {
                    sell_fee = (amount * _slotDaysFeeInfo.feeBeforeDaysSlot5) / denominator;
                } else if (
                    holdTime >= _slotDaysInfo.slot5Days * 1 days &&
                    holdTime < _slotDaysInfo.slot6Days * 1 days
                ) {
                    sell_fee = (amount * _slotDaysFeeInfo.feeBeforeDaysSlot6) / denominator;
                } else {
                    sell_fee = 0;
                }
            }

            if (shouldBurn) {
                burn_fee = (amount * burnFee) / denominator;

                uint256 prevTotalSupply = _totalSupply;

                _totalSupply -= burn_fee;

                uint256 currentTotalSupply = _totalSupply;

                if (
                    prevTotalSupply > minTotalSupplyForStopBurn &&
                    currentTotalSupply <= minTotalSupplyForStopBurn
                ) {
                    shouldBurn = false;
                }
            }

            if (shouldChargeTransfer) {
                transfer_fee = (amount * transferFee) / denominator;
            }

            uint256 totalDistribution = sell_fee / 4;

            _balances[development_address] += totalDistribution;
            emit Transfer(from, development_address, totalDistribution);

            _balances[management_address] += (totalDistribution + transfer_fee);
            emit Transfer(from, management_address, totalDistribution + transfer_fee);

            _balances[marketing_address] += totalDistribution;
            emit Transfer(from, marketing_address, totalDistribution);

            _balances[prime_holders_address] += totalDistribution;
            emit Transfer(from, prime_holders_address, totalDistribution);
        }

        uint256 transferAmount = amount - sell_fee - transfer_fee - burn_fee;

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += transferAmount;
        }

        emit Transfer(from, to, transferAmount);

        _afterTokenTransfer(from, to, transferAmount);
    }

    /**
     * @dev this rewards the prime holders from the prime holders' balance.
     */
    function rewardPrimeHolders() public onlyCaller {
        uint256 _prime_holders_balance = _balances[prime_holders_address];

        if (_prime_holders_balance == 0) {
            revert RewardBalanceZero();
        }
        address[] memory _holdersArray = holdersArray;
        uint256 holdersArrayLength = holdersArray.length;
        uint256 _numberDays;
        uint256 block_timestamp = block.timestamp;

        LengthInfo memory length_info;
        RewardArrayInfo memory reward_array_info;
        RewardInfo memory reward_info;
        RewardPerUserInfo memory reward_per_user_info;
        HoldStruct memory _holderStruct;
        SlotDaysInfo memory _slotDaysInfo = slotDaysInfo;
        SlotDaysRewardInfo memory _slotDaysRewardInfo = slotDaysRewardInfo;

        reward_info = RewardInfo(
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot1) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot2) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot3) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot4) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot5) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot6) / denominator
        );

        reward_array_info = RewardArrayInfo(
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength)
        );

        for (uint256 i; i < holdersArrayLength; i++) {
            if (_isExemptFromReward[_holdersArray[i]] || _balances[_holdersArray[i]] == 0) {
                continue;
            }
            _holderStruct = holdersMap[_holdersArray[i]];
            _numberDays = block_timestamp - _holderStruct.start_hold_timestamp;

            if (
                _numberDays >= _slotDaysInfo.slot1Days * 1 days &&
                _numberDays < _slotDaysInfo.slot2Days * 1 days &&
                !_holderStruct.slot1Rewarded
            ) {
                reward_array_info.afterSlot1days[i] = _holdersArray[i];
                length_info.afterSlot1days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot2Days * 1 days &&
                _numberDays < _slotDaysInfo.slot3Days * 1 days &&
                !_holderStruct.slot2Rewarded
            ) {
                reward_array_info.afterSlot2days[i] = _holdersArray[i];
                length_info.afterSlot2days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot3Days * 1 days &&
                _numberDays < _slotDaysInfo.slot4Days * 1 days &&
                !_holderStruct.slot3Rewarded
            ) {
                reward_array_info.afterSlot3days[i] = _holdersArray[i];
                length_info.afterSlot3days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot4Days * 1 days &&
                _numberDays < _slotDaysInfo.slot5Days * 1 days &&
                !_holderStruct.slot4Rewarded
            ) {
                reward_array_info.afterSlot4days[i] = _holdersArray[i];
                length_info.afterSlot4days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot5Days * 1 days &&
                _numberDays < _slotDaysInfo.slot6Days * 1 days &&
                !_holderStruct.slot5Rewarded
            ) {
                reward_array_info.afterSlot5days[i] = _holdersArray[i];
                length_info.afterSlot5days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot6Days * 1 days && !_holderStruct.slot6Rewarded
            ) {
                reward_array_info.afterSlot6days[i] = _holdersArray[i];
                length_info.afterSlot6days_length += 1;
            }
        }

        reward_per_user_info.rewardAfterSlot1PerUser = length_info.afterSlot1days_length != 0
            ? (reward_info.rewardAfterSlot1 / length_info.afterSlot1days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot2PerUser = length_info.afterSlot2days_length != 0
            ? (reward_info.rewardAfterSlot2 / length_info.afterSlot2days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot3PerUser = length_info.afterSlot3days_length != 0
            ? (reward_info.rewardAfterSlot3 / length_info.afterSlot3days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot4PerUser = length_info.afterSlot4days_length != 0
            ? (reward_info.rewardAfterSlot4 / length_info.afterSlot4days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot5PerUser = length_info.afterSlot5days_length != 0
            ? (reward_info.rewardAfterSlot5 / length_info.afterSlot5days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot6PerUser = length_info.afterSlot6days_length != 0
            ? (reward_info.rewardAfterSlot6 / length_info.afterSlot6days_length)
            : 0;

        if (reward_per_user_info.rewardAfterSlot1PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot1;
        }
        if (reward_per_user_info.rewardAfterSlot2PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot2;
        }
        if (reward_per_user_info.rewardAfterSlot3PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot3;
        }
        if (reward_per_user_info.rewardAfterSlot4PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot4;
        }
        if (reward_per_user_info.rewardAfterSlot5PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot5;
        }
        if (reward_per_user_info.rewardAfterSlot6PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot6;
        }

        for (uint256 i; i < reward_array_info.afterSlot1days.length; i++) {
            holdersMap[reward_array_info.afterSlot1days[i]].slot1Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot1days[i],
                reward_per_user_info.rewardAfterSlot1PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot2days.length; i++) {
            holdersMap[reward_array_info.afterSlot2days[i]].slot2Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot2days[i],
                reward_per_user_info.rewardAfterSlot2PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot3days.length; i++) {
            holdersMap[reward_array_info.afterSlot3days[i]].slot3Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot3days[i],
                reward_per_user_info.rewardAfterSlot3PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot4days.length; i++) {
            holdersMap[reward_array_info.afterSlot4days[i]].slot4Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot4days[i],
                reward_per_user_info.rewardAfterSlot4PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot5days.length; i++) {
            holdersMap[reward_array_info.afterSlot5days[i]].slot5Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot5days[i],
                reward_per_user_info.rewardAfterSlot5PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot6days.length; i++) {
            holdersMap[reward_array_info.afterSlot6days[i]].slot6Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot6days[i],
                reward_per_user_info.rewardAfterSlot6PerUser
            );
        }
    }

    /**
     * @dev this rewards the prime holders from the prime holders' balance with manual array inputs.
     */
    function rewardPrimeHoldersWithInput(
        address[][] memory _arrayData,
        uint256[] memory _arrayLengthData
    ) public onlyCaller {
        if (_arrayLengthData.length != 6 || _arrayData.length != 6) {
            revert InvalidLength();
        }

        uint256 _prime_holders_balance = _balances[prime_holders_address];

        if (_prime_holders_balance == 0) {
            revert RewardBalanceZero();
        }

        RewardInfo memory reward_info;
        RewardArrayInfo memory reward_array_info;
        LengthInfo memory length_info;
        RewardPerUserInfo memory reward_per_user_info;
        SlotDaysRewardInfo memory _slotDaysRewardInfo = slotDaysRewardInfo;

        reward_info = RewardInfo(
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot1) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot2) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot3) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot4) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot5) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot6) / denominator
        );

        reward_array_info = RewardArrayInfo(
            _arrayData[0],
            _arrayData[1],
            _arrayData[2],
            _arrayData[3],
            _arrayData[4],
            _arrayData[5]
        );

        length_info = LengthInfo(
            _arrayLengthData[0],
            _arrayLengthData[1],
            _arrayLengthData[2],
            _arrayLengthData[3],
            _arrayLengthData[4],
            _arrayLengthData[5]
        );

        reward_per_user_info.rewardAfterSlot1PerUser = length_info.afterSlot1days_length != 0
            ? (reward_info.rewardAfterSlot1 / length_info.afterSlot1days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot2PerUser = length_info.afterSlot2days_length != 0
            ? (reward_info.rewardAfterSlot2 / length_info.afterSlot2days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot3PerUser = length_info.afterSlot3days_length != 0
            ? (reward_info.rewardAfterSlot3 / length_info.afterSlot3days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot4PerUser = length_info.afterSlot4days_length != 0
            ? (reward_info.rewardAfterSlot4 / length_info.afterSlot4days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot5PerUser = length_info.afterSlot5days_length != 0
            ? (reward_info.rewardAfterSlot5 / length_info.afterSlot5days_length)
            : 0;

        reward_per_user_info.rewardAfterSlot6PerUser = length_info.afterSlot6days_length != 0
            ? (reward_info.rewardAfterSlot6 / length_info.afterSlot6days_length)
            : 0;

        if (reward_per_user_info.rewardAfterSlot1PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot1;
        }
        if (reward_per_user_info.rewardAfterSlot2PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot2;
        }
        if (reward_per_user_info.rewardAfterSlot3PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot3;
        }
        if (reward_per_user_info.rewardAfterSlot4PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot4;
        }
        if (reward_per_user_info.rewardAfterSlot5PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot5;
        }
        if (reward_per_user_info.rewardAfterSlot6PerUser != 0) {
            _balances[prime_holders_address] -= reward_info.rewardAfterSlot6;
        }

        for (uint256 i; i < reward_array_info.afterSlot1days.length; i++) {
            holdersMap[reward_array_info.afterSlot1days[i]].slot1Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot1days[i],
                reward_per_user_info.rewardAfterSlot1PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot2days.length; i++) {
            holdersMap[reward_array_info.afterSlot2days[i]].slot2Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot2days[i],
                reward_per_user_info.rewardAfterSlot2PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot3days.length; i++) {
            holdersMap[reward_array_info.afterSlot3days[i]].slot3Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot3days[i],
                reward_per_user_info.rewardAfterSlot3PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot4days.length; i++) {
            holdersMap[reward_array_info.afterSlot4days[i]].slot4Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot4days[i],
                reward_per_user_info.rewardAfterSlot4PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot5days.length; i++) {
            holdersMap[reward_array_info.afterSlot5days[i]].slot5Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot5days[i],
                reward_per_user_info.rewardAfterSlot5PerUser
            );
        }
        for (uint256 i; i < reward_array_info.afterSlot6days.length; i++) {
            holdersMap[reward_array_info.afterSlot6days[i]].slot6Rewarded = true;
            _distribute(
                prime_holders_address,
                reward_array_info.afterSlot6days[i],
                reward_per_user_info.rewardAfterSlot6PerUser
            );
        }
    }

    function _distribute(
        address _from,
        address _to,
        uint256 _amount
    ) private onlyCaller {
        if (_to != address(0)) {
            _balances[_to] += _amount;

            emit Transfer(_from, _to, _amount);
        }
    }

    /**
     * @dev this rewards users on a daily basis by minting new tokens.
     */
    function rewardUsersDaily() public onlyCaller {
        address[] memory _holdersArray = holdersArray;
        uint256 holdersArrayLength = _holdersArray.length;

        uint256 _maxTotalSupply = maxTotalSupply;

        uint256 _last_daily_reward_timestamp;

        uint256 _daily_reward_days;

        uint256 _daily_reward_amount;

        uint256 block_timestamp = block.timestamp;

        uint256 _numberDaysHold;

        uint256 _principalForReward;

        SlotDaysInfo memory _slotDaysInfo = slotDaysInfo;
        HoldStruct memory _holdStruct;

        for (uint256 i; i < holdersArrayLength; i++) {
            _holdStruct = holdersMap[_holdersArray[i]];
            _numberDaysHold = block_timestamp - _holdStruct.start_hold_timestamp;

            _principalForReward = _balances[_holdersArray[i]] >= _holdStruct.interestPaid
                ? (_balances[_holdersArray[i]] - _holdStruct.interestPaid)
                : 0;

            if (
                _holdStruct.daysRewarded >= _slotDaysInfo.slot6Days ||
                _numberDaysHold > _slotDaysInfo.slot6Days * 1 days ||
                _isExemptFromReward[_holdersArray[i]] ||
                _principalForReward == 0
            ) {
                continue;
            }

            _last_daily_reward_timestamp = _holdStruct.last_daily_reward_timestamp;

            _daily_reward_days = (block_timestamp - _last_daily_reward_timestamp) / (1 days);

            _daily_reward_amount =
                (_principalForReward * dailyRewardRate * _daily_reward_days) /
                denominator;

            if (_totalSupply + _daily_reward_amount <= _maxTotalSupply) {
                _totalSupply += _daily_reward_amount;

                holdersMap[_holdersArray[i]]
                    .last_daily_reward_timestamp = (_last_daily_reward_timestamp +
                    (_daily_reward_days * 1 days));

                holdersMap[_holdersArray[i]].interestPaid += _daily_reward_amount;
                holdersMap[_holdersArray[i]].daysRewarded += _daily_reward_days;

                _balances[_holdersArray[i]] += _daily_reward_amount;

                emit Transfer(prime_holders_address, _holdersArray[i], _daily_reward_amount);
            } else {
                shouldBurn = true;
                shouldChargeTransfer = true;
                break;
            }
        }
    }

    /**
     * @dev exempt an address from paying any fee.
     */
    function exemptFromFee(address _address, bool _value) public onlyCaller {
        if (_isExemptFromFee[_address] == _value) {
            revert AlreadySet();
        }
        _isExemptFromFee[_address] = _value;
    }

    /**
     * @dev exempt an address from getting any reward.
     */
    function exemptFromReward(address _address, bool _value) public onlyCaller {
        if (_isExemptFromReward[_address] == _value) {
            revert AlreadySet();
        }
        _isExemptFromReward[_address] = _value;
    }

    /**
     * @dev set an address a DEX.
     */
    function setIsDex(address _address, bool _value) public onlyCaller {
        if (_isDex[_address] == _value) {
            revert AlreadySet();
        }
        _isDex[_address] = _value;
        _isExemptFromFee[_address] = _value;
        _isExemptFromReward[_address] = _value;
    }

    /**
     * @dev set dynamic days interval for 6 slots.
     */
    function setDaysSlots(
        uint256 _slot1Days,
        uint256 _slot2Days,
        uint256 _slot3Days,
        uint256 _slot4Days,
        uint256 _slot5Days,
        uint256 _slot6Days
    ) public onlyCaller {
        slotDaysInfo = SlotDaysInfo(
            _slot1Days,
            _slot2Days,
            _slot3Days,
            _slot4Days,
            _slot5Days,
            _slot6Days
        );
    }

    /**
     * @dev set dynamic fee for selling before a particular slot days.
     */
    function setFeeBeforeSlotDays(
        uint256 _feeBeforeDaysSlot1,
        uint256 _feeBeforeDaysSlot2,
        uint256 _feeBeforeDaysSlot3,
        uint256 _feeBeforeDaysSlot4,
        uint256 _feeBeforeDaysSlot5,
        uint256 _feeBeforeDaysSlot6
    ) public onlyCaller {
        slotDaysFeeInfo = SlotDaysFeeInfo(
            _feeBeforeDaysSlot1,
            _feeBeforeDaysSlot2,
            _feeBeforeDaysSlot3,
            _feeBeforeDaysSlot4,
            _feeBeforeDaysSlot5,
            _feeBeforeDaysSlot6
        );
    }

    /**
     * @dev set dynamic fee for selling on dex before a particular slot days.
     */
    function setFeeBeforeSlotDaysDex(
        uint256 _feeBeforeDaysSlot1,
        uint256 _feeBeforeDaysSlot2,
        uint256 _feeBeforeDaysSlot3,
        uint256 _feeBeforeDaysSlot4,
        uint256 _feeBeforeDaysSlot5,
        uint256 _feeBeforeDaysSlot6
    ) public onlyCaller {
        slotDaysFeeInfoDex = SlotDaysFeeInfo(
            _feeBeforeDaysSlot1,
            _feeBeforeDaysSlot2,
            _feeBeforeDaysSlot3,
            _feeBeforeDaysSlot4,
            _feeBeforeDaysSlot5,
            _feeBeforeDaysSlot6
        );
    }

    /**
     * @dev set dynamic reward percentage for holding for a particular slot days.
     */
    function setRewardAfterSlotDays(
        uint256 _rewardAfterDaysSlot1,
        uint256 _rewardAfterDaysSlot2,
        uint256 _rewardAfterDaysSlot3,
        uint256 _rewardAfterDaysSlot4,
        uint256 _rewardAfterDaysSlot5,
        uint256 _rewardAfterDaysSlot6
    ) public onlyCaller {
        if (
            (_rewardAfterDaysSlot1 +
                _rewardAfterDaysSlot2 +
                _rewardAfterDaysSlot3 +
                _rewardAfterDaysSlot4 +
                _rewardAfterDaysSlot5 +
                _rewardAfterDaysSlot6) != denominator
        ) {
            revert InvalidData();
        }

        slotDaysRewardInfo = SlotDaysRewardInfo(
            _rewardAfterDaysSlot1,
            _rewardAfterDaysSlot2,
            _rewardAfterDaysSlot3,
            _rewardAfterDaysSlot4,
            _rewardAfterDaysSlot5,
            _rewardAfterDaysSlot6
        );
    }

    /**
     * @dev this set the burn fee
     */
    function setBurnFee(uint256 _burnFee) public onlyCaller {
        burnFee = _burnFee;
    }

    /**
     * @dev this set the transfer fee
     */
    function setTransferFee(uint256 _transferFee) public onlyCaller {
        burnFee = _transferFee;
    }

    /**
     * @dev this set the daily reward percentage
     */
    function setDailyReward(uint256 _dailyReward) public onlyCaller {
        burnFee = _dailyReward;
    }

    /**
     * @dev this set whether the token should be burned while transferring
     */
    function setShouldBurn(bool _shouldBurn) public onlyCaller {
        if (shouldBurn == _shouldBurn) {
            revert AlreadySet();
        }
        shouldBurn = _shouldBurn;
    }

    /**
     * @dev this set whether the transfer should be charged or not for transfer fee
     */
    function setShouldChargeTransfer(bool _shouldChargeTransfer) public onlyCaller {
        if (shouldChargeTransfer == _shouldChargeTransfer) {
            revert AlreadySet();
        }
        shouldChargeTransfer = _shouldChargeTransfer;
    }

    /**
     * @dev this set whether the fee should be deducted on selling for various slots
     */
    function setShouldTakeSellFee(bool _shouldTakeSellFee) public onlyCaller {
        if (shouldTakeSellFee == _shouldTakeSellFee) {
            revert AlreadySet();
        }
        shouldTakeSellFee = _shouldTakeSellFee;
    }

    /**
     * @dev returns the holders array
     */
    function getHoldersArray() public view returns (address[] memory) {
        return holdersArray;
    }

    /**
     * @dev returns the core holders array
     */
    function getCoreHoldersArray() public view returns (address[] memory) {
        return holdersArrayCore;
    }

    /**
     * @dev returns the data for manual reward inputs for the rewardPrimeHoldersWithInput function
     */
    function filterUsers() public view returns (RewardArrayInfo memory, LengthInfo memory) {
        uint256 _prime_holders_balance = _balances[prime_holders_address];
        if (_prime_holders_balance == 0) {
            revert RewardBalanceZero();
        }
        address[] memory _holdersArray = holdersArray;
        uint256 holdersArrayLength = holdersArray.length;
        uint256 _numberDays;
        uint256 block_timestamp = block.timestamp;

        LengthInfo memory length_info;
        RewardArrayInfo memory reward_array_info;
        RewardInfo memory reward_info;
        // RewardPerUserInfo memory reward_per_user_info;
        HoldStruct memory _holderStruct;
        SlotDaysInfo memory _slotDaysInfo = slotDaysInfo;
        SlotDaysRewardInfo memory _slotDaysRewardInfo = slotDaysRewardInfo;

        reward_info = RewardInfo(
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot1) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot2) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot3) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot4) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot5) / denominator,
            (_prime_holders_balance * _slotDaysRewardInfo.rewardAfterDaysSlot6) / denominator
        );

        reward_array_info = RewardArrayInfo(
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength),
            new address[](holdersArrayLength)
        );

        for (uint256 i; i < holdersArrayLength; i++) {
            if (_isExemptFromReward[_holdersArray[i]] || _balances[_holdersArray[i]] == 0) {
                continue;
            }
            _holderStruct = holdersMap[_holdersArray[i]];
            _numberDays = block_timestamp - _holderStruct.start_hold_timestamp;

            if (
                _numberDays >= _slotDaysInfo.slot1Days * 1 days &&
                _numberDays < _slotDaysInfo.slot2Days * 1 days &&
                !_holderStruct.slot1Rewarded
            ) {
                reward_array_info.afterSlot1days[i] = _holdersArray[i];
                length_info.afterSlot1days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot2Days * 1 days &&
                _numberDays < _slotDaysInfo.slot3Days * 1 days &&
                !_holderStruct.slot2Rewarded
            ) {
                reward_array_info.afterSlot2days[i] = _holdersArray[i];
                length_info.afterSlot2days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot3Days * 1 days &&
                _numberDays < _slotDaysInfo.slot4Days * 1 days &&
                !_holderStruct.slot3Rewarded
            ) {
                reward_array_info.afterSlot3days[i] = _holdersArray[i];
                length_info.afterSlot3days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot4Days * 1 days &&
                _numberDays < _slotDaysInfo.slot5Days * 1 days &&
                !_holderStruct.slot4Rewarded
            ) {
                reward_array_info.afterSlot4days[i] = _holdersArray[i];
                length_info.afterSlot4days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot5Days * 1 days &&
                _numberDays < _slotDaysInfo.slot6Days * 1 days &&
                !_holderStruct.slot5Rewarded
            ) {
                reward_array_info.afterSlot5days[i] = _holdersArray[i];
                length_info.afterSlot5days_length += 1;
            } else if (
                _numberDays >= _slotDaysInfo.slot6Days * 1 days && !_holderStruct.slot6Rewarded
            ) {
                reward_array_info.afterSlot6days[i] = _holdersArray[i];
                length_info.afterSlot6days_length += 1;
            }
        }

        return (reward_array_info, length_info);
    }

    /**
     * @dev get Developement Balance.
     */
    function getDevelopmentBalance() public view returns (uint256) {
        return _balances[development_address];
    }

    /**
     * @dev get Marketing Balance.
     */
    function getMarketingBalance() public view returns (uint256) {
        return _balances[marketing_address];
    }

    /**
     * @dev get Management Balance.
     */
    function getManagementBalance() public view returns (uint256) {
        return _balances[management_address];
    }

    /**
     * @dev get Prime Holders' Balance.
     */
    function getPrimeHoldersBalance() public view returns (uint256) {
        return _balances[prime_holders_address];
    }

    /**
     * @dev get Core Holders' Balance.
     */
    function getCoreHoldersBalance() public view returns (uint256) {
        return _balances[core_holders_address];
    }

    /**
     * @dev withdraw Developement balance with amount equal to _amount, recipient is the _to address.
     */
    function withdrawDevelopmentBalance(address _to, uint256 _amount) public onlyCaller {
        _withdrawBalance(development_address, _to, _amount);
    }

    /**
     * @dev withdraw Marketing balance with amount equal to _amount, recipient is the _to address.
     */
    function withdrawMarketingBalance(address _to, uint256 _amount) public onlyCaller {
        _withdrawBalance(marketing_address, _to, _amount);
    }

    /**
     * @dev withdraw Management balance with amount equal to _amount, recipient is the _to address.
     */
    function withdrawManagementBalance(address _to, uint256 _amount) public onlyCaller {
        _withdrawBalance(management_address, _to, _amount);
    }

    /**
     * @dev withdraw Prime Holders' balance with amount equal to _amount, recipient is the _to address.
     */
    function withdrawPrimeHoldersBalance(address _to, uint256 _amount) public onlyCaller {
        _withdrawBalance(prime_holders_address, _to, _amount);
    }

    /**
     * @dev withdraw Core Holders' balance with amount equal to _amount, recipient is the _to address.
     */
    function withdrawCoreHoldersBalance(address _to, uint256 _amount) public onlyCaller {
        _withdrawBalance(core_holders_address, _to, _amount);
    }

    /**
     * @dev helper withdraw function for the above four functions.
     */
    function _withdrawBalance(
        address _from,
        address _to,
        uint256 _amount
    ) private onlyCaller {
        _transfer(_from, _to, _amount);
        _isExemptFromFee[_to] = true;
        _isExemptFromFee[_to] = true;
    }

    /**
     * @dev set the address as the caller of the reward functions.
     */
    function setIsCaller(address _address, bool _value) public onlyOwner {
        if (isCallerMap[_address] == _value) {
            revert AlreadySet();
        }
        isCallerMap[_address] = _value;
        if (_value) {
            isCallerArray.push(_address);
        } else {
            address[] memory _isCallerArray = isCallerArray;
            for (uint256 i = 0; i < _isCallerArray.length; i++) {
                if (_isCallerArray[i] == _address) {
                    isCallerArray[i] = _isCallerArray[_isCallerArray.length - 1];
                    isCallerArray.pop();
                    break;
                }
            }
        }
    }

    /**
     * @dev Returns Callers Array.
     */
    function getCallersArray() public view returns (address[] memory) {
        return isCallerArray;
    }

    /**
     * @dev this function is used for initial private sale owner can send some amount of tokens from core holders fund to the address of initial core investors after than that address will be blocked to receive any other tokens
     */
    function preSale(address _to, uint256 _amount) public onlyCaller {
        if (holdersMapCore[_to].isCoreHolder || _balances[_to] > 0) {
            revert TransferNotAllowed();
        }

        if (_balances[core_holders_address] < _amount) {
            revert NotEnoughFund();
        }

        _transfer(core_holders_address, _to, _amount);
        _isExemptFromFee[_to] = true;
        _isExemptFromReward[_to] = true;

        holdersArrayCore.push(_to);

        if (holdersMapCore[_to].last_transfer_timestamp == 0) {
            holdersMapCore[_to].last_transfer_timestamp = block.timestamp;
        }

        holdersMapCore[_to].isCoreHolder = true;
        holdersMapCore[_to].amount10percent = (_amount * 10) / 100;
        holdersMapCore[_to].amount25percent = (_amount * 25) / 100;
        holdersMapCore[_to].amount75percent = (_amount * 75) / 100;
        holdersMapCore[_to].amountTotal = _amount;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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