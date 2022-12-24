// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

import "./HENToken.sol";

/**
 * @title HENVesting
 */
contract HENVesting {
    /**
     * The struct of one admin.
     */
    struct Admin {
        // enabled/disabled flag
        bool enabled;
        // the number of admins that request a ban on this account
        uint numBanRequests;
    }

    /**
     * Structure of one period for the schedule.
     */
    struct SchedulePeriod {
        // duration of vesting period in seconds
        uint duration;
        // the number of tokens to be released after the end of the period
        uint amount;
    }

    /**
     * Structure of the schedule for one vesting.
     */
    struct Schedule {
        // beneficiary account address
        address account;
        // start time (unix timestamp)
        uint startAt;
        // schedule periods
        SchedulePeriod[] periods;
        // total duration of all periods (in seconds)
        uint duration;
        // total number of reserved tokens for all periods
        uint reservedTokens;
        // the number of released tokens
        uint releasedTokens;
        // the number of revoked tokens. if value > 0 that means this schedule is revoked.
        uint revokedTokens;
        // is this schedule revocable?
        bool revocable;
        // is this schedule enabled?
        bool enabled;
        // the number of administrators who have approved the creation of the schedule
        uint numCreationApprovals;
        // the number of administrators who have approved the revocation of the schedule
        uint numRevocationApprovals;
    }

    /**
     * The struct of one withdrawal request.
     */
    struct WithdrawalRequest {
        // recipient of tokens
        address recipient;
        // amount of tokens
        uint amount;
        // the number of admins approvals for this request
        uint numApprovals;
        // executed/not executed flag
        bool executed;
    }

    // address of the ERC20 token
    IERC20 immutable private _token;

    // total number of reserved tokens for all schedules
    uint private _totalReservedTokens;
    // total number of released tokens for all schedules
    uint private _totalReleasedTokens;
    // total number of revoked tokens for all schedules
    uint private _totalRevokedTokens;
    // total number of schedules for all beneficiaries
    uint private _totalSchedules;
    // total number of enabled schedules
    uint private _totalEnabledSchedules;
    // total number of revoked schedules
    uint private _totalRevokedSchedules;
    // total number of beneficiaries
    uint private _totalBeneficiaries;
    // map: scheduleId -> schedule
    mapping(bytes32 => Schedule) private _schedules;
    // the list of all addresses that have voted for the creation of the schedule
    mapping(bytes32 => mapping(address => bool)) private _creationApprovals;
    // the list of all addresses that have voted for the revocation of the schedule
    mapping(bytes32 => mapping(address => bool)) private _revocationApprovals;
    // map: account -> total number of schedules
    mapping(address => uint) private _beneficiaries;

    // list of all withdrawal requests
    WithdrawalRequest[] private _withdrawalRequests;
    // list of all addresses that have voted for approval a request (rIdx => (address => isApproved))
    mapping(uint => mapping(address => bool)) private _withdrawalRequestApprovals;

    // list of all administrators (address => Admin struct)
    mapping(address => Admin) private _admins;
    // list of all addresses that request for admin ban (account for ban => (requester account => isRequested))
    mapping(address => mapping(address => bool)) private _adminBanRequests;
    // total number of administrators
    uint private _totalAdmins;
    // how many admins must approve a create/revoke/withdraw/ban request
    uint private _minApprovalsRequired;

    event BanRequest(address indexed requester, address indexed account);
    event BanRevocation(address indexed requester, address indexed account);
    event Ban(address indexed requester, address indexed account);

    event CreationRequest(address indexed admin, bytes32 scheduleId, address indexed recepient, uint amount);
    event CreationRequestApproval(address indexed admin, bytes32 scheduleId);
    event CreationRequestRevocation(address indexed admin, bytes32 scheduleId);
    event Creation(address indexed admin, bytes32 scheduleId, uint numTokens);

    event RevocationRequest(address indexed admin, bytes32 scheduleId);
    event RevocationRequestRevocation(address indexed admin, bytes32 scheduleId);
    event Revocation(address indexed admin, bytes32 scheduleId, uint numTokens);

    event Release(address indexed requester, bytes32 scheduleId, uint releasedTokens);

    event WithdrawalRequestCreation(address indexed admin, uint rIdx, address indexed recepient, uint amount);
    event WithdrawalRequestApproval(address indexed admin, uint rIdx);
    event WithdrawalRequestRevocation(address indexed admin, uint rIdx);
    event Withdrawal(address indexed admin, uint rIdx);


    constructor(
        address token,
        address[] memory admins,
        uint minApprovalsRequired
    ) {
        require(token != address(0));
        require(admins.length > 0, "HENVesting: Admins are required.");
        require(
            minApprovalsRequired > 0 &&
            minApprovalsRequired <= admins.length,
            "HENVesting: Invalid number of minimum votes."
        );

        for (uint i=0; i<admins.length; i++) {
            require(admins[i] != address(0), "HENVesting: Zero address.");
            require(!_admins[admins[i]].enabled, "HENVesting: Admins are not unique.");

            Admin storage admin = _admins[admins[i]];
            admin.enabled = true;
        }

        _totalAdmins = admins.length;
        _minApprovalsRequired = minApprovalsRequired;

        _token = IERC20(token);
    }

    /**
     * Returns the schedule by ID.
     *
     * @param scheduleId - uniq schedule ID
     */
    function getScheduleById(bytes32 scheduleId) external view returns (Schedule memory) {
        return _schedules[scheduleId];
    }

    /**
     * Returns the schedule by a beneficiary address.
     *
     * @param account - a beneficiary address
     * @param index - index of schedule
     */
    function getScheduleByAccount(address account, uint index) external view returns (Schedule memory) {
        return _schedules[generateScheduleId(account, index)];
    }

    /**
     * Returns the total amount of schedules.
     */
    function getTotalSchedules() external view returns (uint) {
        return _totalSchedules;
    }

    /**
     * Returns the total amount of enabled schedules.
     */
    function getTotalEnabledSchedules() external view returns (uint) {
        return _totalEnabledSchedules;
    }

    /**
     * Returns the total number of tokens in this contract (balance of the contract).
     */
    function getTotalTokens() public view returns (uint) {
        return _token.balanceOf(address(this));
    }

    /**
     * Returns the total number of reserved tokens.
     */
    function getTotalReservedTokens() public view returns (uint) {
        return _totalReservedTokens;
    }

    /**
     * Returns the total number of released tokens.
     */
    function getTotalReleasedTokens() external view returns (uint) {
        return _totalReleasedTokens;
    }

    /**
     * Returns the total number of revoked tokens.
     */
    function getTotalRevokedTokens() external view returns (uint) {
        return _totalRevokedTokens;
    }

    /**
     * Returns the total number of available tokens.
     */
    function getTotalAvailableTokens() public view returns (uint) {
        return getTotalTokens() - getTotalReservedTokens();
    }

    /**
     * Returns the total amount of schedules for the beneficiary.
     *
     * @param account - a beneficiary address
     */
    function getTotalSchedulesByAccount(address account) external view returns (uint) {
        return _beneficiaries[account];
    }

    /**
     * Returns the total number of reserved tokens for the beneficiary.
     *
     * @param account - a beneficiary address
     */
    function getTotalReservedTokensByAccount(address account) external view returns (uint) {
        Schedule memory schedule;
        uint totalAmount;
        for (uint i=0; i<_beneficiaries[account]; i++) {
            schedule = _schedules[generateScheduleId(account, i)];
            if (schedule.enabled) {
                totalAmount += schedule.reservedTokens;
            }
        }
        return totalAmount;
    }

    /**
     * Returns the total number of released tokens for the beneficiary.
     *
     * @param account - a beneficiary address
     */
    function getTotalReleasedTokensByAccount(address account) external view returns (uint) {
        Schedule memory schedule;
        uint totalAmount;
        for (uint i=0; i<_beneficiaries[account]; i++) {
            schedule = _schedules[generateScheduleId(account, i)];
            totalAmount += schedule.releasedTokens;
        }
        return totalAmount;
    }

    /**
     * Returns the total number of tokens which ready to release for the beneficiary.
     *
     * @param account - a beneficiary address
     */
    function getTotalUnreleasedTokensByAccount(address account) external view returns (uint) {
        uint totalAmount;
        for (uint i=0; i<_beneficiaries[account]; i++) {
            totalAmount += computeReleasableAmount(generateScheduleId(account, i));
        }
        return totalAmount;
    }

    /**
     * Returns the total number of revoked tokens for the beneficiary.
     *
     * @param account - a beneficiary address
     */
    function getTotalRevokedTokensByAccount(address account) external view returns (uint) {
        Schedule memory schedule;
        uint totalAmount;
        for (uint i=0; i<_beneficiaries[account]; i++) {
            schedule = _schedules[generateScheduleId(account, i)];
            totalAmount += schedule.revokedTokens;
        }
        return totalAmount;
    }

    // ---------------------------------------------------------------------------------------------------------------
    // The creation of a schedule
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Creates the schedule.
     *
     * - the schedule must be approved by _minApprovalsRequired admins.
     * - the requested amount of tokens must be less than or equal to the amount available in this contract.
     */
    function create(bytes32 scheduleId) external onlyAdmin {
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Schedule does not exist.");
        require(!_schedules[scheduleId].enabled, "HENVesting: Schedule is already created.");
        require(_schedules[scheduleId].numCreationApprovals >= _minApprovalsRequired, "HENVesting: Not enough approves.");
        require(_schedules[scheduleId].reservedTokens <= getTotalAvailableTokens(), "HENVesting: Not enough sufficient tokens.");

        _schedules[scheduleId].enabled = true;

        _totalReservedTokens += _schedules[scheduleId].reservedTokens;
        _totalEnabledSchedules++;

        emit Creation(msg.sender, scheduleId, _schedules[scheduleId].reservedTokens);
    }

    /**
     * Creates a vesting request for a new schedule.
     *
     * @param account - address of the beneficiary
     * @param startAt - start time of the schedule (unix timestamp)
     * @param periods - array of vesting periods
     * @param revocable - whether the vesting is revocable or not
     *
     * @return vesting schedule id
     */
    function requestCreation(
        address account,
        uint startAt,
        SchedulePeriod[] memory periods,
        bool revocable
    ) external onlyAdmin returns (bytes32) {
        require(account != address(0), "HENVesting: Zero address.");
        require(periods.length > 0, "HENVesting: Empty periods.");

        uint totalAmount;
        uint totalDuration;

        for (uint i=0; i<periods.length; i++) {
            require(periods[i].duration > 0, "HENVesting: Empty duration.");
            require(periods[i].amount > 0, "HENVesting: Empty amount.");

            totalDuration += periods[i].duration;
            totalAmount   += periods[i].amount;
        }

        bytes32 scheduleId = generateScheduleId(account, _beneficiaries[account]);
        Schedule storage schedule = _schedules[scheduleId];

        schedule.account = account;
        schedule.startAt = startAt;
        schedule.revocable = revocable;
        schedule.reservedTokens = totalAmount;
        schedule.duration = totalDuration;
        schedule.enabled = false;
        schedule.numCreationApprovals = 1;
        for (uint i=0; i<periods.length; i++) {
            schedule.periods.push(
                SchedulePeriod({
                    duration: periods[i].duration,
                    amount:   periods[i].amount
                })
            );
        }

        if (_beneficiaries[account] == 0) {
            _totalBeneficiaries++;
        }
        _beneficiaries[account]++;

        _totalSchedules++;

        _creationApprovals[scheduleId][msg.sender] = true;

        emit CreationRequest(msg.sender, scheduleId, account, totalAmount);

        return scheduleId;
    }

    /**
     * Approves the creation request that was created by the requestCreation function.
     */
    function approveCreationRequest(bytes32 scheduleId) external onlyAdmin returns (uint) {
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Schedule does not exist.");
        require(!_schedules[scheduleId].enabled, "HENVesting: Schedule is already created.");
        require(!_creationApprovals[scheduleId][msg.sender], "HENVesting: Request is already approved.");

        _creationApprovals[scheduleId][msg.sender] = true;
        _schedules[scheduleId].numCreationApprovals++;

        emit CreationRequestApproval(msg.sender, scheduleId);

        return _schedules[scheduleId].numCreationApprovals;
    }

    /**
     * Revokes the already approved creation request.
     */
    function revokeCreationRequest(bytes32 scheduleId) external onlyAdmin {
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Schedule does not exist.");
        require(!_schedules[scheduleId].enabled, "HENVesting: Schedule is already created.");
        require(_creationApprovals[scheduleId][msg.sender], "HENVesting: Request is not approved.");

        _creationApprovals[scheduleId][msg.sender] = false;
        _schedules[scheduleId].numCreationApprovals--;

        emit CreationRequestRevocation(msg.sender, scheduleId);
    }


    // ---------------------------------------------------------------------------------------------------------------
    // The revocation of a schedule
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Revokes a vesting schedule.
     *
     * @param scheduleId - a vesting schedule ID
     *
     * @return amount of unreleased tokens
     */
    function revoke(bytes32 scheduleId) external onlyAdmin returns (uint) {
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Schedule does not exist.");
        require(_schedules[scheduleId].enabled, "HENVesting: Schedule is not created.");
        require(_schedules[scheduleId].revocable, "HENVesting: Schedule is not revocable.");
        require(_schedules[scheduleId].revokedTokens == 0, "HENVesting: Schedule is already revoked.");
        require(_schedules[scheduleId].numRevocationApprovals >= _minApprovalsRequired, "HENVesting: Not enough approves.");
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Nothing to revoke.");

        _schedules[scheduleId].revokedTokens  = _schedules[scheduleId].reservedTokens;
        _schedules[scheduleId].reservedTokens = 0;
        _totalRevokedTokens  += _schedules[scheduleId].revokedTokens;
        _totalReservedTokens -= _schedules[scheduleId].revokedTokens;

        emit Revocation(msg.sender, scheduleId, _schedules[scheduleId].revokedTokens);

        return _schedules[scheduleId].revokedTokens;
    }

    /**
     * Creates a revocation request.
     */
    function requestRevocation(bytes32 scheduleId) external onlyAdmin {
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Schedule does not exist.");
        require(_schedules[scheduleId].enabled, "HENVesting: Schedule is not created.");
        require(_schedules[scheduleId].revocable, "HENVesting: Schedule is not revocable.");
        require(_schedules[scheduleId].revokedTokens == 0, "HENVesting: Schedule is already revoked.");
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Nothing to revoke.");
        require(!_revocationApprovals[scheduleId][msg.sender], "HENVesting: Revocation is already requested.");

        _schedules[scheduleId].numRevocationApprovals++;
        _revocationApprovals[scheduleId][msg.sender] = true;

        emit RevocationRequest(msg.sender, scheduleId);
    }

    /**
     * Revokes the already approved revocation request.
     */
    function revokeRevocationRequest(bytes32 scheduleId) external onlyAdmin {
        require(_schedules[scheduleId].reservedTokens > 0, "HENVesting: Schedule does not exist.");
        require(_schedules[scheduleId].revokedTokens == 0, "HENVesting: Schedule is already revoked.");
        require(_revocationApprovals[scheduleId][msg.sender], "HENVesting: Revocation is not requested.");

        _schedules[scheduleId].numRevocationApprovals--;
        _revocationApprovals[scheduleId][msg.sender] = false;

        emit RevocationRequestRevocation(msg.sender, scheduleId);
    }

    // ---------------------------------------------------------------------------------------------------------------
    // The release of a schedule
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Releases tokens.
     *
     * @param scheduleId - a vesting schedule ID
     * @param amount      - the amount to release
     *
     * @return amount of released tokens
     */
    function release(bytes32 scheduleId, uint amount) public returns (uint) {
        require(
            (msg.sender == _schedules[scheduleId].account) || _admins[msg.sender].enabled,
            "HENVesting: Only beneficiary or admin can release vested tokens."
        );

        require(_schedules[scheduleId].enabled, "HENVesting: Schedule is not created.");
        require(_schedules[scheduleId].revokedTokens == 0, "HENVesting: Schedule is revoked.");
        require(amount != 0, "HENVesting: Zero amount.");
        require(amount <= computeReleasableAmount(scheduleId), "HENVesting: Not enough sufficient tokens.");

        address payable accountPayable = payable(_schedules[scheduleId].account);
        _token.transfer(accountPayable, amount);

        _schedules[scheduleId].reservedTokens -= amount;
        _schedules[scheduleId].releasedTokens += amount;
        _totalReservedTokens -= amount;
        _totalReleasedTokens += amount;

        emit Release(msg.sender, scheduleId, amount);

        return amount;
    }

    /**
     * Releases all ready to release tokens.
     *
     * @param scheduleId - a vesting schedule ID
     *
     * @return amount of released tokens
     */
    function releaseAllByScheduleId(bytes32 scheduleId) external returns (uint) {
        require(
            (msg.sender == _schedules[scheduleId].account) || _admins[msg.sender].enabled,
            "HENVesting: Only beneficiary or admin can release vested tokens."
        );

        return release(scheduleId, computeReleasableAmount(scheduleId));
    }

    /**
     * Releases all ready to release tokens in all beneficiary schedules.
     *
     * @param account - a beneficiary address
     *
     * @return amount of released tokens
     */
    function releaseAllByAccount(address account) external returns (uint) {
        require(
            (msg.sender == account) || _admins[msg.sender].enabled,
            "HENVesting: Only beneficiary or admin can release vested tokens."
        );

        bytes32 scheduleId;
        uint totalAmount;
        for (uint i=0; i<_beneficiaries[account]; i++) {
            scheduleId   = generateScheduleId(account, i);
            totalAmount += release(scheduleId, computeReleasableAmount(scheduleId));
        }
        return totalAmount;
    }

    /**
     * Computes ready to release tokens for the vesting schedule.
     *
     * @return amount of releasable tokens
     */
    function computeReleasableAmount(bytes32 scheduleId) public view returns (uint) {
        Schedule memory schedule = _schedules[scheduleId];

        if (getCurrentTime() < schedule.startAt || schedule.revokedTokens > 0 || !schedule.enabled) {
            return 0;
        }

        uint releasableAmount;
        uint elapsedPeriodsTime;
        uint elapsedTime = getCurrentTime() - schedule.startAt;

        for (uint i=0; i<schedule.periods.length; i++) {
            elapsedPeriodsTime += schedule.periods[i].duration;
            if (elapsedPeriodsTime > elapsedTime) {
                break;
            }

            releasableAmount += schedule.periods[i].amount;
        }
        
        return releasableAmount > schedule.releasedTokens
            ? releasableAmount - schedule.releasedTokens
            : 0;
    }



    // ---------------------------------------------------------------------------------------------------------------
    // Withdrawal
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Withdraws tokens
     */
    function withdraw(uint rIdx) external onlyAdmin {
        require(rIdx < _withdrawalRequests.length, "HENVesting: Request does not exist.");
        require(!_withdrawalRequests[rIdx].executed, "HENVesting: Request is already executed.");
        require(_withdrawalRequests[rIdx].numApprovals >= _minApprovalsRequired, "HENVesting: Not enough approves.");
        require(getTotalAvailableTokens() >= _withdrawalRequests[rIdx].amount, "HENVesting: Not enough funds.");

        _token.transfer(_withdrawalRequests[rIdx].recipient, _withdrawalRequests[rIdx].amount);

        _withdrawalRequests[rIdx].executed = true;

        emit Withdrawal(msg.sender, rIdx);
    }

    /**
     * Creates a withdrawal request. Each request gets an index "rIdx".
     *
     * @param recipient - address for withdrawal of tokens
     * @param amount    - number of tokens
     *
     * @return - index of the request (rIdx)
     */
    function requestWithdrawal(address recipient, uint amount) external onlyAdmin returns (uint) {
        require(recipient != address(0), "HENVesting: Zero address.");
        require(amount > 0, "HENVesting: Zero amount.");

        uint rIdx = _withdrawalRequests.length;

        _withdrawalRequests.push(
            WithdrawalRequest({
                recipient: recipient,
                amount: amount,
                numApprovals: 1,
                executed: false
            })
        );

        _withdrawalRequestApprovals[rIdx][msg.sender] = true;

        emit WithdrawalRequestCreation(msg.sender, rIdx, recipient, amount);

        return rIdx;
    }

    /**
     * Approves the minting request that was created by the requestMinting function.
     */
    function approveRequestWithdrawal(uint rIdx) external onlyAdmin returns (uint) {
        require(rIdx < _withdrawalRequests.length, "HENVesting: Request does not exist.");
        require(!_withdrawalRequests[rIdx].executed, "HENVesting: Request is already executed.");
        require(!_withdrawalRequestApprovals[rIdx][msg.sender], "HENVesting: Request is already approved.");

        _withdrawalRequestApprovals[rIdx][msg.sender] = true;
        _withdrawalRequests[rIdx].numApprovals++;

        emit WithdrawalRequestApproval(msg.sender, rIdx);

        return _withdrawalRequests[rIdx].numApprovals;
    }

    /**
     * Revokes the already approved request.
     */
    function revokeWithdrawalRequest(uint rIdx) external onlyAdmin {
        require(rIdx < _withdrawalRequests.length, "HENVesting: Request does not exist.");
        require(!_withdrawalRequests[rIdx].executed, "HENVesting: Request is already executed.");
        require(_withdrawalRequestApprovals[rIdx][msg.sender], "HENVesting: Request is not approved.");

        _withdrawalRequestApprovals[rIdx][msg.sender] = false;
        _withdrawalRequests[rIdx].numApprovals--;

        emit WithdrawalRequestRevocation(msg.sender, rIdx);
    }

    /**
     * Returns the total number of withdrawal requests, which is also the index for the next withdrawal request.
     */
    function getTotalWithdrawalRequests() external view returns (uint) {
        return _withdrawalRequests.length;
    }

    /**
     * Returns data about the withdrawal request
     */
    function getWithdrawalRequest(uint rIdx) external view returns (WithdrawalRequest memory) {
        return _withdrawalRequests[rIdx];
    }

    /**
     * Returns data about all withdrawal requests
     */
    function getAllWithdrawalRequests() external view returns (WithdrawalRequest[] memory) {
        return _withdrawalRequests;
    }



    // ---------------------------------------------------------------------------------------------------------------
    // The section of work with administrators
    // ---------------------------------------------------------------------------------------------------------------
    modifier onlyAdmin() {
        require(_admins[msg.sender].enabled, "HENVesting: You are not an admin.");
        _;
    }

    /**
     * Requests the ban for the admin.
     * It's needed _minApprovalsRequired confirms to allow the ban.
     */
    function requestAdminBan(address account) external onlyAdmin {
        require(_admins[account].enabled, "HENVesting: The account is not an admin.");
        require(account != msg.sender, "HENVesting: It is forbidden to ban yourself.");
        require(!_adminBanRequests[account][msg.sender], "HENVesting: The request already exists.");

        _adminBanRequests[account][msg.sender] = true;
        _admins[account].numBanRequests++;

        emit BanRequest(msg.sender, account);
    }

    /**
     * Revokes a previous ban request
     */
    function revokeAdminBanRequest(address account) external onlyAdmin {
        require(_adminBanRequests[account][msg.sender], "HENVesting: The request does not exists.");

        _adminBanRequests[account][msg.sender] = false;
        _admins[account].numBanRequests--;

        emit BanRevocation(msg.sender, account);
    }

    /**
     * Bans the admin
     * It's needed _minApprovalsRequired confirms to allow the ban.
     */
    function banAdmin(address account) external onlyAdmin {
        require(_admins[account].enabled, "HENVesting: The account is not an admin.");
        require(account != msg.sender, "HENVesting: It is forbidden to ban yourself.");
        require(_admins[account].numBanRequests >= _minApprovalsRequired, "HENVesting: Not enough requests.");

        _admins[account].enabled = false;
        _totalAdmins--;

        emit Ban(msg.sender, account);
    }

    /**
     * Returns the total number of admin
     */
    function getTotalAdmins() external view returns (uint) {
        return _totalAdmins;
    }

    /**
     * Check if the account is an admin
     */
    function isAdmin(address account) external view returns (bool) {
        return _admins[account].enabled;
    }


    // ---------------------------------------------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------------------------------------------
    /**
     * Generates the vesting schedule identifier.
     *
     * @param account - account address
     * @param index - next schedule index
     *
     * @return unique vesting schedule id
     */
    function generateScheduleId(address account, uint index) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(account, index));
    }

    /**
     * Returns time of the current block. (for using in mock)
     */
    function getCurrentTime() public virtual view returns (uint) {
        return block.timestamp;
    }
}