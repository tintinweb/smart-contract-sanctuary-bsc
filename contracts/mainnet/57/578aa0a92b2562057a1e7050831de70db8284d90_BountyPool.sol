//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
// import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "./SaloonWallet.sol";

/*
BountyPool handles all logic for a bounty.
- Projects can set different APYs and poolCaps at any time (timelock applies).
- Stakers can stake or unstake any time (timelock applies for unstaking).
- Premium calculations are made dynamically according to users balance, APY and staking period duration.
*/

contract BountyPool is Ownable, Initializable {
    using SafeERC20 for IERC20;
    //#################### State Variables *****************\\

    address public manager;

    uint256 public constant VERSION = 1;
    uint256 public constant PRECISION = 100;
    uint256 public constant YEAR = 365 days;
    uint256 public constant PERIOD = 1 weeks;

    uint256 public decimals;
    uint256 public bountyCommission;
    uint256 public premiumCommission;
    uint256 public denominator;

    uint256 public saloonBountyCommission;
    uint256 public saloonPremiumFees;
    uint256 public premiumBalance;

    uint256 public desiredAPY;
    uint256 public poolCap;
    uint256 public lastTimePaid;
    uint256 public projectDeposit;
    uint256 public requiredPremiumBalancePerPeriod;
    uint256 public stakingPause;

    // staker => last time premium was claimed
    mapping(address => uint256) public lastClaimed;
    // staker address => StakingInfo array
    mapping(address => StakingInfo[]) public staker;

    // staker address => amount => timelock time
    mapping(address => TimelockInfo) public stakerTimelock;

    // staker address => reimbursement amount
    mapping(address => uint256) public stakerReimbursement;

    TimelockInfo public poolCapTimelock;
    TimelockInfo public APYTimelock;
    TimelockInfo public withdrawalTimelock;

    struct StakingInfo {
        uint256 stakeBalance;
        uint256 balanceTimeStamp;
    }

    struct APYperiods {
        uint256 timeStamp;
        uint256 periodAPY;
    }

    struct TimelockInfo {
        uint256 timelock;
        uint256 timeLimit;
        uint256 amount;
        bool executed;
    }

    address[] public stakerList;

    APYperiods[] public APYrecords;

    StakingInfo[] public stakersDeposit;
    uint256[] private APYChanges;
    uint256[] private stakeChanges;
    uint256[] private stakerChange;

    bool public APYdropped;
    bool public firstDeposit;

    //#################### State Variables End *****************\\

    /// @dev Initializes new bounty pool
    function initializeImplementation(address _manager, uint256 _decimals)
        public
        initializer
    {
        manager = _manager;
        decimals = _decimals;
        bountyCommission = 10 * (10**_decimals);
        premiumCommission = 10 * (10**_decimals);
        denominator = 100 * (10**_decimals);
    }

    //#################### Modifiers *****************\\

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager allowed");
        _;
    }

    modifier onlyManagerOrSelf() {
        require(
            msg.sender == manager || msg.sender == address(this),
            "Only manager or self allowed"
        );
        _;
    }

    //#################### Modifiers END *****************\\

    //#################### Functions *******************\\

    /// @dev Pays bounty and subtracts staker balances according to weight in pool.
    /// This implementation uses stakers funds to pay the bounty first before using project deposit.
    /// @param _token Token the bounty is going to be paid in.
    /// @param _saloonWallet Address the Saloon commission will be sent to.
    /// @param _hunter Hunter wallet address the bounty will be paid to.
    /// @param _amount Amount to be paid including Hunter payout + Saloon commission.
    function payBounty(
        address _token,
        address _saloonWallet,
        address _hunter,
        uint256 _amount
    ) public onlyManager returns (bool) {
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length - 1;

        // cache list
        address[] memory stakersList = stakerList;
        // cache length
        uint256 length = stakersList.length;
        if (stakersList.length > 0) {
            // check if stakersDeposit is enough
            if (stakersDeposits[stakingLenght].stakeBalance >= _amount) {
                // decrease stakerDeposit
                uint256 newStakersDeposit = stakersDeposits[stakingLenght]
                    .stakeBalance - _amount;
                // push new value to array
                StakingInfo memory stakingInfo;
                stakingInfo.balanceTimeStamp = block.timestamp;
                stakingInfo.stakeBalance = newStakersDeposit;

                // if staker deposit == 0
                // check new pushed value
                if (newStakersDeposit == 0) {
                    for (uint256 i; i < length; ++i) {
                        // update StakingInfo struct
                        StakingInfo memory newInfo;
                        newInfo.balanceTimeStamp = block.timestamp;
                        newInfo.stakeBalance = 0;

                        address stakerAddress = stakersList[i];
                        staker[stakerAddress].push(newInfo);
                    }

                    // deduct saloon commission and transfer
                    calculateCommissioAndTransferPayout(
                        _token,
                        _hunter,
                        _saloonWallet,
                        _amount
                    );

                    // update stakersDeposit
                    stakersDeposit.push(stakingInfo);
                    // clean stakerList array
                    delete stakerList;
                    return true;
                }
                // calculate percentage of stakersDeposit
                // note should we increase precision?
                uint256 percentage = (_amount * (10**decimals)) /
                    stakersDeposits[stakingLenght].stakeBalance;
                // loop through all stakers and deduct percentage from their balances
                for (uint256 i; i < length; ++i) {
                    address stakerAddress = stakersList[i];
                    uint256 arraySize = staker[stakerAddress].length - 1;
                    uint256 oldStakerBalance = staker[stakerAddress][arraySize]
                        .stakeBalance;

                    // update StakingInfo struct
                    StakingInfo memory newInfo;
                    newInfo.balanceTimeStamp = block.timestamp;

                    newInfo.stakeBalance =
                        oldStakerBalance -
                        ((oldStakerBalance * percentage) / (10**decimals));

                    staker[stakerAddress].push(newInfo);
                }
                // push to
                stakersDeposit.push(stakingInfo);

                // deduct saloon commission and transfer
                calculateCommissioAndTransferPayout(
                    _token,
                    _hunter,
                    _saloonWallet,
                    _amount
                );

                return true;
            } else {
                // reset baalnce of all stakers
                for (uint256 i; i < length; ++i) {
                    // update StakingInfo struct
                    StakingInfo memory newInfo;
                    newInfo.balanceTimeStamp = block.timestamp;
                    newInfo.stakeBalance = 0;

                    address stakerAddress = stakersList[i];
                    staker[stakerAddress].push(newInfo);
                }
                // clean stakerList array
                delete stakerList;
                // if stakersDeposit not enough use projectDeposit to pay the rest
                uint256 remainingCost = _amount -
                    stakersDeposits[stakingLenght].stakeBalance;
                // descrease project deposit by the remaining amount
                projectDeposit -= remainingCost;

                // set stakers deposit to 0
                StakingInfo memory stakingInfo;
                stakingInfo.balanceTimeStamp = block.timestamp;
                stakingInfo.stakeBalance = 0;
                stakersDeposit.push(stakingInfo);

                // deduct saloon commission and transfer
                calculateCommissioAndTransferPayout(
                    _token,
                    _hunter,
                    _saloonWallet,
                    _amount
                );

                return true;
            }
        } else {
            // deduct saloon commission and transfer
            calculateCommissioAndTransferPayout(
                _token,
                _hunter,
                _saloonWallet,
                _amount
            );

            projectDeposit -= _amount;

            return true;
        }
    }

    /// @dev Calculates Saloon commission and transfers it to _saloonWallet,
    /// as well as transferring the hunter payout to _hunter.
    /// @param _token Token the bounty is going to be paid in.
    /// @param _saloonWallet Address the Saloon commission will be sent to.
    /// @param _hunter Hunter wallet address the bounty will be paid to.
    /// @param _amount Amount to be paid including Hunter payout + Saloon commission.
    function calculateCommissioAndTransferPayout(
        address _token,
        address _hunter,
        address _saloonWallet,
        uint256 _amount
    ) internal returns (bool) {
        // deduct saloon commission
        uint256 saloonCommission = (_amount * bountyCommission) / denominator;
        uint256 hunterPayout = _amount - saloonCommission;
        // transfer to hunter
        IERC20(_token).safeTransfer(_hunter, hunterPayout);
        // transfer commission to saloon address
        IERC20(_token).safeTransfer(_saloonWallet, saloonCommission);

        return true;
    }

    /// @dev Transfer already collected Saloon premium fees to _saloonWallet.
    /// @param _token Token the fees are paid in.
    /// @param _saloonWallet Address the Saloon commission will be sent to.
    function collectSaloonPremiumFees(address _token, address _saloonWallet)
        external
        onlyManager
        returns (uint256)
    {
        uint256 totalCollected = saloonPremiumFees;

        // reset claimable fees
        saloonPremiumFees = 0;

        // send current fees to saloon address
        IERC20(_token).safeTransfer(_saloonWallet, totalCollected);

        return totalCollected;
    }

    /// @dev Makes a payout deposit for the proejct.
    // project must approve this address first.
    /// @param _token Token the bounty is going to be paid in.
    /// @param _projectWallet Project address deposint the payout.
    /// @param _amount Amount to be paid including Hunter payout + Saloon commission.
    function bountyDeposit(
        address _token,
        address _projectWallet,
        uint256 _amount
    ) external onlyManager returns (bool) {
        // transfer from project account
        IERC20(_token).safeTransferFrom(_projectWallet, address(this), _amount);

        if (firstDeposit == false) {
            stakingPause = block.timestamp + PERIOD;
            firstDeposit = true;
        }

        // update deposit variable
        projectDeposit += _amount;

        return true;
    }

    /// @dev Schedules a change in Pool Cap for a determined amount.
    /// @param _newPoolCap Amount the new Pool Cap is going to be set to once timelock is over.
    function schedulePoolCapChange(uint256 _newPoolCap) external onlyManager {
        poolCapTimelock.timelock = block.timestamp + PERIOD;
        poolCapTimelock.amount = _newPoolCap;
        poolCapTimelock.executed = false;
        // note should this have a timelimit??
    }

    /// @dev Set new Pool Cap as scheduled.
    /// if poolCap = 0 scheduling is not necessary
    /// @param _amount New pool cap as specificied when scheduling(if necessary).
    function setPoolCap(uint256 _amount) external onlyManager {
        // check timelock if current poolCap != 0
        if (poolCap != 0) {
            TimelockInfo memory poolCapLock = poolCapTimelock;
            // Check If queued check time has passed && its hasnt been executed && timestamp cant be =0
            require(
                poolCapLock.timelock < block.timestamp &&
                    poolCapLock.executed == false &&
                    poolCapLock.amount == _amount &&
                    poolCapLock.timelock != 0,
                "Timelock not set or not completed in time"
            );
            // set executed to true
            poolCapTimelock.executed = true;
        }
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;

        // if stakers deposit > newPoolcap reimburse different to users
        if (stakingLenght > 0) {
            uint256 totalStakingBalance = stakersDeposits[stakingLenght - 1]
                .stakeBalance;
            if (totalStakingBalance > _amount) {
                address[] memory stakersList = stakerList;
                uint256 length = stakersList.length;
                // calculate difference = (stakers deposit - newPoolcap)
                uint256 diff = totalStakingBalance - _amount;
                // loop through stakers

                for (uint256 i; i < length; ) {
                    address stakerAddress = stakersList[i];
                    uint256 arraySize = staker[stakerAddress].length - 1;
                    uint256 dec = decimals;
                    // calculate current stakersDeposit individual percentage of each staker
                    uint256 percentage = (staker[stakerAddress][arraySize]
                        .stakeBalance * (10**dec)) / totalStakingBalance;

                    // amount = calculate individual difference percentage per staker
                    uint256 amount = (diff * percentage) / (10**dec);

                    // add amount to instant claim mapping variable that gets added and reset in claimPremium
                    stakerReimbursement[stakerAddress] += amount;
                    // decrease stakerBalance by amount
                    StakingInfo memory newInfo;
                    // update balance
                    newInfo.stakeBalance =
                        staker[stakerAddress][arraySize].stakeBalance -
                        amount;
                    // update current time
                    newInfo.balanceTimeStamp = block.timestamp;
                    // push to array
                    staker[stakerAddress].push(newInfo);

                    unchecked {
                        ++i;
                    }
                }

                //  subtract and update: stakersDeposit - diff
                StakingInfo memory newDepositInfo;
                newDepositInfo.balanceTimeStamp = block.timestamp;
                newDepositInfo.stakeBalance =
                    stakersDeposits[stakingLenght - 1].stakeBalance -
                    diff;
                stakersDeposit.push(newDepositInfo);
            }
        }

        poolCap = _amount;
    }

    /// @dev Schedules a change in APY for a determined amount.
    /// @param _newAPY Amount the new APY is going to be set to once timelock is over.
    function scheduleAPYChange(uint256 _newAPY) external onlyManager {
        APYTimelock.timelock = block.timestamp + PERIOD;
        APYTimelock.amount = _newAPY;
        APYTimelock.executed = false;
        // note should this have a timelimit??
    }

    /// @dev Set new APY as scheduled.
    /// If APY = 0 scheduling is not required.
    /// project must approve this address first.
    /// project will have to pay upfront cost of full period on the first time.
    /// this will serve two purposes:
    /// 1. sign of good faith and working payment system
    /// 2. if theres is ever a problem with payment the initial premium deposit can be used as a buffer so users can still be paid while issue is fixed.
    /// @param _desiredAPY New apy as specificied when scheduling (if necessary).
    /// @param _token Token the premium is going to be paid in.
    /// @param _projectWallet Project address that will continuously be billed for premium payments.
    function setDesiredAPY(
        address _token,
        address _projectWallet,
        uint256 _desiredAPY // make sure APY has right amount of decimals (1e18)
    ) public onlyManagerOrSelf returns (bool) {
        // check timelock if current APY != 0
        if (desiredAPY != 0) {
            TimelockInfo memory APYLock = APYTimelock;
            // Check If queued check time has passed && its hasnt been executed && timestamp cant be =0
            require(
                APYLock.timelock < block.timestamp &&
                    APYLock.executed == false &&
                    APYLock.amount == _desiredAPY &&
                    APYLock.timelock != 0,
                "Timelock not set or not completed"
            );
            // set executed to true
            APYTimelock.executed = true;
        }
        uint256 currentPremiumBalance = premiumBalance;
        uint256 newRequiredPremiumBalancePerPeriod;
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;
        if (stakingLenght != 0) {
            if (stakersDeposits[stakingLenght - 1].stakeBalance != 0) {
                // bill all premium due before changing APY
                billPremium(_token, _projectWallet);
            }
        } else {
            // ensure there is enough premium balance to pay stakers new APY for one period
            newRequiredPremiumBalancePerPeriod =
                (((poolCap * _desiredAPY) / denominator) / YEAR) *
                PERIOD;
            // note: this might lead to leftover premium if project decreases APY, we will see what to do about that later
            if (currentPremiumBalance < newRequiredPremiumBalancePerPeriod) {
                // calculate difference to be paid
                uint256 difference = newRequiredPremiumBalancePerPeriod -
                    currentPremiumBalance;
                // transfer to this address
                IERC20(_token).safeTransferFrom(
                    _projectWallet,
                    address(this),
                    difference
                );
                // increase premium
                premiumBalance += difference;
            }
        }

        requiredPremiumBalancePerPeriod = newRequiredPremiumBalancePerPeriod;

        // register new APYperiod
        APYperiods memory newAPYperiod;
        newAPYperiod.timeStamp = block.timestamp;
        newAPYperiod.periodAPY = _desiredAPY;
        APYrecords.push(newAPYperiod);

        // set APY
        desiredAPY = _desiredAPY;

        // loop through stakerList array and push new balance for new APY period time stamp for every staker

        address[] memory stakersList = stakerList;
        if (stakersList.length > 0) {
            uint256 length = stakersList.length - 1;
            for (uint256 i; i < length; ) {
                address stakerAddress = stakersList[i];
                uint256 arraySize = staker[stakerAddress].length - 1;

                StakingInfo memory newInfo;
                // get last balance
                newInfo.stakeBalance = staker[stakerAddress][arraySize]
                    .stakeBalance;
                // update current time
                newInfo.balanceTimeStamp = block.timestamp;
                // push to array so user can claim it.
                staker[stakerAddress].push(newInfo);

                unchecked {
                    ++i;
                }
            }
        }
        // disable instant withdrawals ? note this is not in effect
        APYdropped = false;

        return true;
    }

    /// @dev Calculates how much premium is owed since last time it was paid.
    /// Loops through variance in total staking balance and takes into account how long it lasted.
    function calculatePremiumOwed(
        uint256 _apy,
        uint256 _stakingLenght,
        uint256 _lastPaid,
        StakingInfo[] memory _stakersDeposits
    ) internal returns (uint256) {
        uint256 premiumOwed;
        for (uint256 i; i < _stakingLenght; ++i) {
            // see how many changes since lastPaid
            if (_stakersDeposits[i].balanceTimeStamp > _lastPaid) {
                stakeChanges.push(i);
                // premiumOwed = _stakersDeposits[1].balanceTimeStamp;
            }
        }

        uint256[] memory stakingChanges = stakeChanges;
        uint256 length = stakingChanges.length;
        uint256 duration;

        // if no staking happened since lastPaid
        if (length == 0) {
            duration = block.timestamp - _lastPaid;

            premiumOwed =
                ((
                    ((_stakersDeposits[_stakingLenght - 1].stakeBalance *
                        _apy) / denominator)
                ) / YEAR) *
                duration;

            // if only one change was made between lastPaid and now
        } else if (length == 1) {
            if (_lastPaid == 0) {
                duration =
                    block.timestamp -
                    _stakersDeposits[0].balanceTimeStamp;
                premiumOwed =
                    ((
                        ((_stakersDeposits[0].stakeBalance * _apy) /
                            denominator)
                    ) / YEAR) *
                    duration;
            } else {
                duration = (_stakersDeposits[stakingChanges[0]]
                    .balanceTimeStamp - _lastPaid);

                premiumOwed +=
                    ((
                        ((_stakersDeposits[stakingChanges[0] - 1].stakeBalance *
                            _apy) / denominator)
                    ) / YEAR) *
                    duration;

                uint256 duration2 = (block.timestamp -
                    _stakersDeposits[stakingChanges[0]].balanceTimeStamp);

                premiumOwed +=
                    ((
                        ((_stakersDeposits[stakingChanges[0]].stakeBalance *
                            _apy) / denominator)
                    ) / YEAR) *
                    duration2;
            }
            // if there were multiple changes in stake balance between lastPaid and now
        } else {
            for (uint256 i; i < length; ++i) {
                // calculate payout for every change in staking according to time

                if (_lastPaid == 0) {
                    if (i == length - 1) {
                        duration =
                            block.timestamp -
                            _stakersDeposits[stakingChanges[i]]
                                .balanceTimeStamp;

                        premiumOwed +=
                            ((
                                ((_stakersDeposits[stakingChanges[i]]
                                    .stakeBalance * _apy) / denominator)
                            ) / YEAR) *
                            duration;
                    } else {
                        duration =
                            _stakersDeposits[stakingChanges[i + 1]]
                                .balanceTimeStamp -
                            _stakersDeposits[stakingChanges[i]]
                                .balanceTimeStamp;
                        premiumOwed +=
                            ((
                                ((_stakersDeposits[stakingChanges[i]]
                                    .stakeBalance * _apy) / denominator)
                            ) / YEAR) *
                            duration;
                    }
                } else {
                    if (i == 0) {
                        // calculate duration from lastPaid with last value
                        duration =
                            _stakersDeposits[stakingChanges[i]]
                                .balanceTimeStamp -
                            _lastPaid;

                        premiumOwed +=
                            ((
                                ((_stakersDeposits[stakingChanges[i] - 1]
                                    .stakeBalance * _apy) / denominator)
                            ) / YEAR) *
                            duration;
                        // calculate duration from current i to next i with current value
                        uint256 duration2 = _stakersDeposits[
                            stakingChanges[i] + 1
                        ].balanceTimeStamp -
                            _stakersDeposits[stakingChanges[i]]
                                .balanceTimeStamp;

                        premiumOwed +=
                            ((
                                ((_stakersDeposits[stakingChanges[i]]
                                    .stakeBalance * _apy) / denominator)
                            ) / YEAR) *
                            duration2;
                    } else if (i == length - 1) {
                        duration =
                            block.timestamp -
                            _stakersDeposits[stakingChanges[i]]
                                .balanceTimeStamp;
                        premiumOwed +=
                            ((
                                ((_stakersDeposits[stakingChanges[i]]
                                    .stakeBalance * _apy) / denominator)
                            ) / YEAR) *
                            duration;
                    } else {
                        // if i is in between first and last
                        duration =
                            _stakersDeposits[stakingChanges[i + 1]]
                                .balanceTimeStamp -
                            _stakersDeposits[stakingChanges[i]]
                                .balanceTimeStamp;

                        premiumOwed +=
                            ((
                                ((_stakersDeposits[stakingChanges[i]]
                                    .stakeBalance * _apy) / denominator)
                            ) / YEAR) *
                            duration;
                    }
                }
            }
        }

        delete stakeChanges;
        return premiumOwed;
    }

    /// @notice Bill premium owned since last time paid.
    /// this address needs to be approved first
    function billPremium(address _token, address _projectWallet)
        public
        onlyManagerOrSelf
        returns (bool)
    {
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;
        uint256 lastPaid = lastTimePaid;
        uint256 apy = desiredAPY;

        /* 
        check when function was called last time and pay premium according to how much time has passed since then.
        - average variance since last paid
            - needs to take into account how long each variance is...
        obs: this could probably be done more efficiently...
        */
        uint256 premiumOwed = calculatePremiumOwed(
            apy,
            stakingLenght,
            lastPaid,
            stakersDeposits
        );
        // note try/catch should handle both revert and fails from transferFrom;
        try
            IERC20(_token).transferFrom(
                _projectWallet,
                address(this),
                premiumOwed
            )
        returns (bool result) {
            // If return valid is 0 run same things on catch block
            if (result == false) {
                // if transfer fails APY is reset and premium is paid with new APY
                uint256 newAPY = viewcurrentAPY();
                // register new APYperiod
                APYperiods memory newAPYperiod;
                newAPYperiod.timeStamp = block.timestamp;
                newAPYperiod.periodAPY = newAPY;
                APYrecords.push(newAPYperiod);
                // set new APY
                // register new APYperiod
                desiredAPY = newAPY;

                address[] memory stakersList = stakerList;
                if (stakersList.length > 0) {
                    uint256 length = stakersList.length - 1;
                    for (uint256 i; i < length; ) {
                        address stakerAddress = stakersList[i];
                        uint256 arraySize = staker[stakerAddress].length - 1;

                        StakingInfo memory newInfo;
                        // get last balance
                        newInfo.stakeBalance = staker[stakerAddress][arraySize]
                            .stakeBalance;
                        // update current time
                        newInfo.balanceTimeStamp = block.timestamp;
                        // push to array so user can claim it.
                        staker[stakerAddress].push(newInfo);

                        unchecked {
                            ++i;
                        }
                    }
                }
                return false;
            }
        } catch {
            // if transfer fails APY is reset and premium is paid with new APY
            uint256 newAPY = viewcurrentAPY();
            // register new APYperiod
            APYperiods memory newAPYperiod;
            newAPYperiod.timeStamp = block.timestamp;
            newAPYperiod.periodAPY = newAPY;
            APYrecords.push(newAPYperiod);
            // set new APY
            // register new APYperiod
            desiredAPY = newAPY;

            address[] memory stakersList = stakerList;
            if (stakersList.length > 0) {
                uint256 length = stakersList.length - 1;
                for (uint256 i; i < length; ) {
                    address stakerAddress = stakersList[i];
                    uint256 arraySize = staker[stakerAddress].length - 1;

                    StakingInfo memory newInfo;
                    // get last balance
                    newInfo.stakeBalance = staker[stakerAddress][arraySize]
                        .stakeBalance;
                    // update current time
                    newInfo.balanceTimeStamp = block.timestamp;
                    // push to array so user can claim it.
                    staker[stakerAddress].push(newInfo);

                    unchecked {
                        ++i;
                    }
                }
            }

            return false;
        }

        // Calculate saloon fee
        uint256 saloonFee = (premiumOwed * premiumCommission) / denominator;

        // update saloon claimable fee
        saloonPremiumFees += saloonFee;

        // update premiumBalance
        premiumBalance += premiumOwed;

        lastTimePaid = block.timestamp;

        // disable instant withdrawals
        APYdropped = false;

        return true;
    }

    /// @dev Schedules project deposit withdrawal.
    /// @param _amount Amount to be withdrawn once timelock is over.
    function scheduleprojectDepositWithdrawal(uint256 _amount)
        external
        onlyManager
        returns (bool)
    {
        require(projectDeposit >= _amount, "Amount bigger than deposit");

        withdrawalTimelock.timelock = block.timestamp + PERIOD;
        withdrawalTimelock.timeLimit = block.timestamp + PERIOD + 3 days;
        withdrawalTimelock.amount = _amount;
        withdrawalTimelock.executed = false;
        // note timelock should have a limit window. Currently discussing how long that window should be
        return true;
    }

    /// @dev Withdraws the _amount sechuduled.
    function projectDepositWithdrawal(
        address _token,
        address _projectWallet,
        uint256 _amount
    ) external onlyManager returns (bool) {
        TimelockInfo memory withdrawalLock = withdrawalTimelock;
        // time lock check
        // Check If queued check time has passed && its hasnt been executed && timestamp cant be =0
        require(
            withdrawalLock.timelock < block.timestamp &&
                withdrawalLock.timeLimit > block.timestamp &&
                withdrawalLock.executed == false &&
                withdrawalLock.amount >= _amount &&
                withdrawalLock.timelock != 0,
            "Timelock not set or not completed in time"
        );
        withdrawalTimelock.executed = true;

        projectDeposit -= _amount;
        IERC20(_token).safeTransfer(_projectWallet, _amount);
        return true;
    }

    /// @dev Stake funds into the bounty pool
    /// staker needs to approve this address first
    function stake(
        address _token,
        address _staker,
        uint256 _amount
    ) external onlyManager returns (bool) {
        //check if initial post staking period has passed
        require(stakingPause < block.timestamp, "Staking not open just yet");
        // dont allow staking if stakerDeposit >= poolCap
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;

        if (stakingLenght == 0) {
            StakingInfo memory init;
            init.stakeBalance = 0;
            init.balanceTimeStamp = 0;
            stakersDeposit.push(init);
        }
        uint256 positioning = stakersDeposit.length - 1;

        require(
            stakersDeposit[positioning].stakeBalance + _amount <= poolCap,
            "Staking Pool already full"
        );

        uint256 arrayLength = staker[_staker].length;

        //  if array length is  == 0 we must push first
        if (arrayLength == 0) {
            StakingInfo memory init;
            init.stakeBalance = 0;
            init.balanceTimeStamp = 0;
            staker[_staker].push(init);
        }

        uint256 position = staker[_staker].length - 1;

        // Push to stakerList array if previous balance = 0
        if (staker[_staker][position].stakeBalance == 0) {
            stakerList.push(_staker);
        }

        // update StakingInfo struct
        StakingInfo memory newInfo;
        newInfo.balanceTimeStamp = block.timestamp;
        newInfo.stakeBalance = staker[_staker][position].stakeBalance + _amount;

        // if staker is new update array[0] created earlier
        if (arrayLength == 0) {
            staker[_staker][position] = newInfo;
        } else {
            // if staker is not new:
            // save info to storage
            staker[_staker].push(newInfo);
        }

        StakingInfo memory depositInfo;
        depositInfo.stakeBalance =
            stakersDeposit[positioning].stakeBalance +
            _amount;

        depositInfo.balanceTimeStamp = block.timestamp;

        if (stakingLenght == 0) {
            stakersDeposit[positioning] = depositInfo;
        } else {
            // push to global stakersDeposit
            stakersDeposit.push(depositInfo);
        }

        // transferFrom to this address
        IERC20(_token).safeTransferFrom(_staker, address(this), _amount);

        return true;
    }

    /// @dev Schedules unstake for a determined amount.
    /// @param _staker Staker address where the unstaked funds we be returned to.
    /// @param _amount Amount to be unstaked from _staker balance once timelock is over.
    function scheduleUnstake(address _staker, uint256 _amount)
        external
        onlyManager
        returns (bool)
    {
        StakingInfo[] memory stakr = staker[_staker];
        uint256 arraySize = stakr.length - 1;

        require(
            stakr[arraySize].stakeBalance >= _amount,
            "Insuficcient balance"
        );

        stakerTimelock[_staker].timelock = block.timestamp + PERIOD;
        stakerTimelock[_staker].timeLimit = block.timestamp + PERIOD + 3 days;
        stakerTimelock[_staker].amount = _amount;
        stakerTimelock[_staker].executed = false;

        return true;
    }

    /// @dev Unstakes _amount as previously scheduled
    function unstake(
        address _token,
        address _staker,
        uint256 _amount
    ) external onlyManager returns (bool) {
        // note allow for immediate withdrawal if APY drops from desired APY ??
        // if (desiredAPY != 0 || APYdropped == true) {
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length - 1;

        if (
            desiredAPY != 0 ||
            poolCap > stakersDeposits[stakingLenght].stakeBalance
        ) {
            TimelockInfo memory stakrTimelock = stakerTimelock[_staker];
            // time lock check
            // Check If queued check time has passed && its hasnt been executed && timestamp cant be =0
            require(
                stakrTimelock.timelock < block.timestamp &&
                    stakrTimelock.timeLimit > block.timestamp &&
                    stakrTimelock.executed == false &&
                    stakrTimelock.amount >= _amount &&
                    stakrTimelock.timelock != 0,
                "Timelock not set or not completed"
            );
            stakerTimelock[_staker].executed = true;
        }
        uint256 arraySize = staker[_staker].length - 1;

        // decrease staker balance
        // update StakingInfo struct
        StakingInfo memory newInfo;
        newInfo.balanceTimeStamp = block.timestamp;
        newInfo.stakeBalance =
            staker[_staker][arraySize].stakeBalance -
            _amount;

        address[] memory stakersList = stakerList;
        // delete from staker list
        // note if 18 decimals are not used properly at some stage this might never be true.
        if (newInfo.stakeBalance == 0) {
            // loop through stakerlist
            uint256 length = stakersList.length;
            for (uint256 i; i < length; ) {
                // find staker
                if (stakersList[i] == _staker) {
                    // get value in the last array position
                    address lastAddress = stakersList[length - 1];
                    // replace it to the current position
                    stakerList[i] = lastAddress;

                    // pop last array value
                    stakerList.pop();
                    break;
                }

                unchecked {
                    ++i;
                }
            }
        }
        // save info to storage
        staker[_staker].push(newInfo);

        StakingInfo memory depositInfo;
        depositInfo.stakeBalance =
            stakersDeposits[stakingLenght].stakeBalance -
            _amount;
        depositInfo.balanceTimeStamp = block.timestamp;

        // decrease global stakersDeposit
        stakersDeposit.push(depositInfo);

        // transfer it out
        IERC20(_token).safeTransfer(_staker, _amount);

        return true;
    }

    /// @dev Claim premium for a specifc staker.
    /// @param _token Token the premium is going to be paid in.
    /// @param _staker Staker address that is claiming the premium.
    /// @param _projectWallet Project address to bill premium if current balance is not sufficient.
    function claimPremium(
        address _token,
        address _staker,
        address _projectWallet
    ) external onlyManager returns (uint256, bool) {
        // how many chunks of time (currently = 2 weeks) since lastclaimed?
        uint256 lastTimeClaimed = lastClaimed[_staker];
        // uint lastTimeClaimed = 0;

        StakingInfo[] memory stakerInfo = staker[_staker];
        uint256 stakerLength = stakerInfo.length;
        uint256 currentPremiumBalance = premiumBalance;

        uint256 totalPremiumToClaim = calculatePremiumToClaim(
            lastTimeClaimed,
            stakerInfo,
            stakerLength
        );
        // Calculate saloon fee
        uint256 saloonFee = (totalPremiumToClaim * premiumCommission) /
            denominator;
        // subtract saloon fee
        totalPremiumToClaim -= saloonFee;
        // sum stakerReimbursement in case there is any. Not very gas efficicent at the moment.
        uint256 owedPremium = totalPremiumToClaim;

        // if premium balance < owedPremium
        if (currentPremiumBalance < owedPremium) {
            //  call billpremium
            if (billPremium(_token, _projectWallet) == false) {
                uint256 reimbursement = stakerReimbursement[_staker];
                IERC20(_token).safeTransfer(_staker, reimbursement);
                stakerReimbursement[_staker] = 0;

                return (reimbursement, false);
            }
            // sum owedPremium to reibursement amount
            owedPremium += stakerReimbursement[_staker];
            // reset reimbursement amount
            stakerReimbursement[_staker] = 0;

            IERC20(_token).safeTransfer(_staker, owedPremium);

            // update last time claimed
            premiumBalance -= totalPremiumToClaim;
            lastClaimed[_staker] = block.timestamp;
            return (owedPremium, true);
        } else {
            // sum owedPremium to reibursement amount
            owedPremium += stakerReimbursement[_staker];
            // reset reimbursement amount
            stakerReimbursement[_staker] = 0;

            IERC20(_token).safeTransfer(_staker, owedPremium);

            // update premiumBalance
            premiumBalance -= totalPremiumToClaim;

            // update last time claimed
            lastClaimed[_staker] = block.timestamp;
            return (owedPremium, true);
        }
    }

    ///@dev Calculates staker premium to claim
    /// Iterates over periods with different APYs and/or staking amounts
    /// @param _lastTimeClaimed Last time user claimed premium.
    /// @param _stakerInfo Record of staker balance changes
    /// @param _stakerInfo length of record of staker balance changes
    /// @param APYrecord Record of APY changes since _lastTimeClaimed
    function calculateBalancePerPeriod(
        uint256 _lastTimeClaimed,
        StakingInfo[] memory _stakerInfo,
        uint256 _stakerLength,
        APYperiods[] memory APYrecord
    ) internal returns (uint256) {
        uint256 length = APYrecord.length;
        uint256 totalPeriodClaim;
        uint256 periodStart;
        uint256 periodEnd;
        if (_lastTimeClaimed == 0) {
            for (uint256 i; i < length; ++i) {
                periodStart = APYrecord[i].timeStamp;

                // period end is equal NOW for last APY that has been set
                if (i == length - 1) {
                    periodEnd = block.timestamp;
                } else {
                    periodEnd = APYrecord[i + 1].timeStamp;
                }
                uint256 apy = APYrecord[i].periodAPY;
                // loop through stakers balance fluctiation during this period
                totalPeriodClaim += calculateBalance(
                    apy,
                    periodStart,
                    periodEnd,
                    _stakerInfo,
                    _stakerLength,
                    false
                );
            }
        } else {
            for (uint256 i; i < length; ++i) {
                /* 
                - See what's the last one to be < lastTimeClaimed
                - calculate distance between last time claimed and 
                APYrecords.TimeStamp[i+1] period start 
                - judge distance in comparison with i+1 until last i that compares distance to block.timestamp
                */
                if (APYrecord[i].timeStamp > _lastTimeClaimed) {
                    APYChanges.push(i - 1);
                    // push last period too
                    if (i == length - 1) {
                        APYChanges.push(i);
                    }
                }
            }
            uint256[] memory APYChange = APYChanges;
            uint256 len = APYChange.length;

            // if APYChanges len = 0 use timestamp of last APYperiod or _lastTimeClaimed as periodStart
            if (len == 0) {
                totalPeriodClaim += noAPYChangeBalance(
                    _stakerLength,
                    length,
                    _lastTimeClaimed,
                    _stakerInfo,
                    APYrecord
                );
            } else {
                // else do loop
                totalPeriodClaim += APYChangeBalance(
                    _stakerLength,
                    length,
                    _lastTimeClaimed,
                    _stakerInfo,
                    APYrecord,
                    APYChange
                );
            }
        }
        return totalPeriodClaim;
    }

    /// @dev Calculates premium owed during a period where APY hasn't changed.
    function noAPYChangeBalance(
        uint256 _stakerLength,
        uint256 length,
        uint256 _lastTimeClaimed,
        StakingInfo[] memory _stakerInfo,
        APYperiods[] memory APYrecord
    ) internal returns (uint256) {
        bool pStartIsLastClaimed;
        uint256 periodStart;
        uint256 periodEnd;
        uint256 totalPeriodClaim;
        if (_lastTimeClaimed < APYrecord[length - 1].timeStamp) {
            periodStart = APYrecord[length - 1].timeStamp;
        } else {
            //if _lastTimeClaimed the stakerBalance needs to be the last one...
            // this could be fixed by setting a bool input if _lastTimeClaimed is periodStart
            periodStart = _lastTimeClaimed;
            pStartIsLastClaimed = true;
        }

        periodEnd = block.timestamp;
        uint256 apy = APYrecord[length - 1].periodAPY;
        // loop through stakers balance fluctiation during this period

        totalPeriodClaim += calculateBalance(
            apy,
            periodStart,
            periodEnd,
            _stakerInfo,
            _stakerLength,
            pStartIsLastClaimed
        );
        return totalPeriodClaim;
    }

    /// @dev Calculates premium owed during a period where APY has changed at least once.
    function APYChangeBalance(
        uint256 _stakerLength,
        uint256 length,
        uint256 _lastTimeClaimed,
        StakingInfo[] memory _stakerInfo,
        APYperiods[] memory APYrecord,
        uint256[] memory APYChange
    ) internal returns (uint256) {
        bool pStartIsLastClaimed;
        uint256 periodStart;
        uint256 periodEnd;
        uint256 totalPeriodClaim;
        uint256 len = APYChange.length;

        uint256 stkrLen = _stakerLength; // making compiler happy, avoiding stack too deep

        for (uint256 i; i < len; ++i) {
            if (i == 0) {
                periodStart = _lastTimeClaimed;
                // if _lastTimeClaimed the stakerBalance needs to be i - 1 in calculateBalance()...
                pStartIsLastClaimed = true;
            } else {
                periodStart = APYrecord[APYChange[i]].timeStamp;
            }

            // period end is equal NOW for last APY that has been set

            if (i == length - 1) {
                periodEnd = block.timestamp;
            } else {
                periodEnd = APYrecord[APYChange[i + 1]].timeStamp;
            }

            uint256 apy = APYrecord[APYChange[i]].periodAPY;

            {
                // loop through stakers balance fluctiation during this period
                totalPeriodClaim += calculateBalance(
                    apy,
                    periodStart,
                    periodEnd,
                    _stakerInfo,
                    stkrLen,
                    pStartIsLastClaimed
                );
            }
        }
        return totalPeriodClaim;
    }

    function calculateBalance(
        uint256 _apy,
        uint256 _periodStart,
        uint256 _periodEnd,
        StakingInfo[] memory _stakerInfo,
        uint256 _stakerLength,
        bool _pStartIsLastClaimed
    ) internal returns (uint256) {
        uint256 balanceClaim;
        uint256 duration;
        uint256 apy = _apy;
        {
            for (uint256 i; i < _stakerLength; ++i) {
                // check staker balance at that moment
                if (
                    _stakerInfo[i].balanceTimeStamp >= _periodStart &&
                    _stakerInfo[i].balanceTimeStamp < _periodEnd
                ) {
                    stakerChange.push(i);
                }
            }
        }
        {
            uint256[] memory stakrChange = stakerChange;
            uint256 len = stakrChange.length;
            //if len = 0 (no staking change)
            if (len == 0) {
                duration = block.timestamp - _periodStart;
                balanceClaim =
                    (((_stakerInfo[_stakerLength - 1].stakeBalance * apy) /
                        denominator) / YEAR) *
                    duration;
            } else {
                // else loop
                uint256 periodClaim;
                for (uint256 i; i < len; ++i) {
                    // check distance difference to period start

                    if (i == len - 1) {
                        duration =
                            _periodEnd -
                            _stakerInfo[stakrChange[i]].balanceTimeStamp;
                    } else {
                        duration =
                            _stakerInfo[stakrChange[i + 1]].balanceTimeStamp -
                            _stakerInfo[stakrChange[i]].balanceTimeStamp;
                    }

                    // calculate timestampClaim
                    // if periodStart = _LastClaimed use i -1 staker Balance
                    if (_pStartIsLastClaimed == true) {
                        uint256 duration2;
                        if (i == 0) {
                            // calculate duration from lastClaimed until new staking change
                            duration = (_stakerInfo[stakrChange[i]]
                                .balanceTimeStamp - _periodStart);

                            // calculate duration from current i to next stake change or period end
                            if (i == len - 1) {
                                duration2 =
                                    _periodEnd -
                                    _stakerInfo[stakrChange[i]]
                                        .balanceTimeStamp;
                            } else {
                                duration2 =
                                    _stakerInfo[stakrChange[i + 1]]
                                        .balanceTimeStamp -
                                    _stakerInfo[stakrChange[i]]
                                        .balanceTimeStamp;
                            }
                            // calcualte amount to claim from lastClaim to stake change
                            periodClaim =
                                (((_stakerInfo[stakrChange[i] - 1]
                                    .stakeBalance * apy) / denominator) /
                                    YEAR) *
                                duration;
                            // add amount to claim from current i to i+1 or period end
                            periodClaim +=
                                (((_stakerInfo[stakrChange[i]].stakeBalance *
                                    apy) / denominator) / YEAR) *
                                duration2;
                        }
                    } else {
                        periodClaim =
                            (((_stakerInfo[stakrChange[i]].stakeBalance * apy) /
                                denominator) / YEAR) *
                            duration;
                    }

                    balanceClaim += periodClaim;
                }
            }
        }
        delete stakerChange;
        return balanceClaim;
    }

    /// @dev Calculates premium to claim for staker
    function calculatePremiumToClaim(
        uint256 _lastTimeClaimed,
        StakingInfo[] memory _stakerInfo,
        uint256 _stakerLength
    ) internal returns (uint256) {
        // cache APY records
        APYperiods[] memory APYregistries = APYrecords;
        // loop through APY periods  until last missed period is found
        uint256 claim;
        claim = calculateBalancePerPeriod(
            _lastTimeClaimed,
            _stakerInfo,
            _stakerLength,
            APYregistries
        );

        return claim;
    }

    ///// VIEW FUNCTIONS /////

    // View currentAPY
    function viewcurrentAPY() public view returns (uint256) {
        uint256 apy = (premiumBalance * PRECISION) / poolCap;
        return apy;
    }

    // View total balance
    function viewHackerPayout() external view returns (uint256) {
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;
        uint256 totalBalance;
        if (stakingLenght == 0) {
            totalBalance = projectDeposit;
        } else {
            totalBalance =
                projectDeposit +
                stakersDeposits[stakingLenght - 1].stakeBalance;
        }
        uint256 saloonCommission = (totalBalance * bountyCommission) /
            denominator;

        return totalBalance - saloonCommission;
    }

    function viewBountyBalance() external view returns (uint256) {
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;
        uint256 totalBalance;
        if (stakingLenght == 0) {
            totalBalance = projectDeposit;
        } else {
            totalBalance =
                projectDeposit +
                stakersDeposits[stakingLenght - 1].stakeBalance;
        }

        return totalBalance;
    }

    // View stakersDeposit balance
    function viewStakersDeposit() external view returns (uint256) {
        StakingInfo[] memory stakersDeposits = stakersDeposit;
        uint256 stakingLenght = stakersDeposits.length;
        if (stakingLenght == 0) {
            return 0;
        } else {
            return stakersDeposit[stakingLenght - 1].stakeBalance;
        }
    }

    // View deposit balance
    function viewProjecDeposit() external view returns (uint256) {
        return projectDeposit;
    }

    // view premium balance
    function viewPremiumBalance() external view returns (uint256) {
        return premiumBalance;
    }

    // view required premium balance
    function viewRequirePremiumBalance() external view returns (uint256) {
        return requiredPremiumBalancePerPeriod;
    }

    // View APY
    function viewDesiredAPY() external view returns (uint256) {
        return desiredAPY;
    }

    // View Cap
    function viewPoolCap() external view returns (uint256) {
        return poolCap;
    }

    // View user staking balance
    function viewUserStakingBalance(address _staker)
        external
        view
        returns (uint256, uint256)
    {
        uint256 length = staker[_staker].length;
        if (length == 0) {
            return (0, 0);
        } else {
            return (
                staker[_staker][length - 1].stakeBalance,
                staker[_staker][length - 1].balanceTimeStamp
            );
        }
    }

    function viewUserTimelock(address _staker)
        external
        view
        returns (
            uint256 timelock,
            uint256 amount,
            bool executed
        )
    {
        timelock = stakerTimelock[_staker].timelock;
        amount = stakerTimelock[_staker].amount;
        executed = stakerTimelock[_staker].executed;
    }

    //note view version function??

    ///// VIEW FUNCTIONS END /////
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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
    ) internal returns (bool) {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
        return true;
    }

    // THIS FUNCTION HAS BEEN EDITED TO RETURN A VALUE
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
        return true;
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

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/Address.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!Address.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract SaloonWallet {
    using SafeERC20 for IERC20;

    uint256 public constant BOUNTY_COMMISSION = 10;
    uint256 public constant DENOMINATOR = 100;

    address public immutable manager;

    // premium fees to collect
    uint256 public premiumFees;
    uint256 public saloonTotalBalance;
    uint256 public cummulativeCommission;
    uint256 public cummulativeHackerPayouts;

    // hunter balance per token
    // hunter address => token address => amount
    mapping(address => mapping(address => uint256)) public hunterTokenBalance;

    // saloon balance per token
    // token address => amount
    mapping(address => uint256) public saloonTokenBalance;

    constructor(address _manager) {
        manager = _manager;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager allowed");
        _;
    }

    // bountyPaid
    function bountyPaid(
        address _token,
        uint256 _decimals,
        address _hunter,
        uint256 _amount
    ) external onlyManager {
        // handle decimals
        uint256 decimals = 18 - _decimals == 0 ? 18 : 18 - _decimals;
        // calculate commision
        uint256 saloonCommission = (_amount *
            10**decimals *
            (BOUNTY_COMMISSION)) / (DENOMINATOR);

        uint256 amount = _amount * (10**decimals);

        uint256 hunterPayout = (amount) - saloonCommission;
        // update variables and mappings
        hunterTokenBalance[_hunter][_token] += hunterPayout;
        cummulativeHackerPayouts += hunterPayout;
        saloonTokenBalance[_token] += saloonCommission;
        saloonTotalBalance += saloonCommission;
        cummulativeCommission += saloonCommission;
    }

    function premiumFeesCollected(address _token, uint256 _amount)
        external
        onlyManager
    {
        saloonTokenBalance[_token] += _amount;
        premiumFees += _amount;
        saloonTotalBalance += _amount;
    }

    //
    // WITHDRAW FUNDS TO ANY ADDRESS saloon admin
    function withdrawSaloonFunds(
        address _token,
        address _to,
        uint256 _amount,
        uint256 _decimals
    ) external onlyManager returns (bool) {
        require(_amount <= saloonTokenBalance[_token], "not enough balance");

        //  handle decimals to change state variables
        uint256 decimals = 18 - _decimals == 0 ? 18 : 18 - _decimals;
        uint256 amount = _amount * (10**decimals);
        // decrease saloon funds variable
        saloonTokenBalance[_token] -= amount;
        saloonTotalBalance -= amount;

        IERC20(_token).safeTransfer(_to, amount);

        return true;
    }

    ///////////////////////   VIEW FUNCTIONS  ////////////////////////

    // VIEW saloon CURRENT TOTAL BALANCE
    function viewSaloonBalance() external view returns (uint256) {
        return saloonTotalBalance;
    }

    // VIEW COMMISSIONS PLUS PREMIUM
    function viewTotalEarnedSaloon() external view returns (uint256) {
        uint256 premiums = viewTotalPremiums();
        uint256 commissions = viewTotalSaloonCommission();

        return premiums + commissions;
    }

    // VIEW TOTAL PAYOUTS MADE - commission - fees
    function viewTotalHackerPayouts() external view returns (uint256) {
        return cummulativeHackerPayouts;
    }

    // view hacker payouts by hunter
    function viewHunterTotalTokenPayouts(address _token, address _hunter)
        external
        view
        returns (uint256)
    {
        return hunterTokenBalance[_hunter][_token];
    }

    // VIEW TOTAL COMMISSION
    function viewTotalSaloonCommission() public view returns (uint256) {
        return cummulativeCommission;
    }

    // VIEW TOTAL IN PREMIUMS
    function viewTotalPremiums() public view returns (uint256) {
        return premiumFees;
    }

    ///////////////////////    VIEW FUNCTIONS END  ////////////////////////
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}