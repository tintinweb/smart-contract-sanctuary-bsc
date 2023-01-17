/**
 *Submitted for verification at BscScan.com on 2023-01-17
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface IERC20Upgradeable {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library AddressUpgradeable {
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

abstract contract Initializable {
   
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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}

contract DifiFortuneStaking is Initializable{
    IERC20Upgradeable public token;
    address public owner;

    uint256 public extraRewardPercentage;
    uint256 public percentDivider;
    uint256 public baseWithdrawInterval;

    uint256 public totalWithdraw;
    uint256 public totalStaked;
    uint256 public totalUsers;

    uint256 public totalStakedCap;

    struct Plan {
        bool isExists;
        uint256 percentPerInterval;
        uint256 stakingPeriods;
        uint256 stakingIntervalLimits;
        uint256 minDepositAmount;
        uint256 maxDepositAmount;
        uint256 referralPercentages;
    }

    mapping(uint256 => Plan) public plans;
    uint256 public totalPlans;

    mapping(address => bool) public whitelistedRewardHolder;

    uint256 public openingDate;
    bool public stopParticipation;

    struct userStakeData {
        uint256 amount;
        uint256 totalAmount;
        uint256 remainingAmount;
        uint256 startTime;
        uint256 endTime;
        uint256 lastWithdrawTime;
        uint256 plan;
        uint256 percentPerInterval;
        uint256 intervalLimit;
        uint256 intervalTime;
        bool extraBonus;
        bool isActive;
    }

    struct User {
        bool isExists;
        address referrer;
        userStakeData[] stakes;
        uint256 totalStaked;
        uint256 totalWithdrawn;
        mapping(uint256 => uint256) referalAmounts;
        mapping(uint256 => uint256) referalCounts;
        uint256 stakingCount;
        uint256 teamTurnOver;
    }
    struct Deposit {
        address _user;
        uint256 depositAmount;
        uint256 depositTime;
    }
    struct Withdraw {
        address _user;
        uint256 withdrawAmount;
        uint256 withdrawTime;
    }

    mapping(address => User) public users;
    mapping(uint256 => Deposit) public depositHistory;
    mapping(uint256 => Withdraw) public withdrawHistory;

    uint256 public depositCount;
    uint256 public withdrawCount;

    function initialize(address _owner, address _token, Plan[] memory _plans, uint256 _extraRewardPercentage, uint256 _percentDivider, uint256 _baseWithdrawInterval ) public initializer {
        token = IERC20Upgradeable(_token);
        owner = _owner;

        // Set plans
        for (uint256 i; i < _plans.length; i++) {
            addPlan(_plans[i]);
        }

        extraRewardPercentage = _extraRewardPercentage;
        percentDivider = _percentDivider;
        baseWithdrawInterval = _baseWithdrawInterval;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not Owner");
        _;
    }

    function stake(
        uint256 _amount,
        address _referrer,
        uint256 _plan
    ) external returns (bool) {
        User storage user = users[msg.sender];
        
        if (!user.isExists) {
            require(!stopParticipation, "New Paricipation has been stopped by Owner");
        }

        if(openingDate != 0){
            require(block.timestamp > openingDate, "Contract is closed");
        }
        if(totalStakedCap != 0){
            require(totalStaked < totalStakedCap, "Total staked cap reached");
        }
        
        require(msg.sender != _referrer, "You cannot reffer yourself!");

        require(_plan < totalPlans, "Invalid Plan!");

        require(_amount >= plans[_plan].minDepositAmount, "You cannot stake less than minimum amount of this plan");
        require(_amount <= plans[_plan].maxDepositAmount, "You cannot stake greater than max amount of this plan");

        if (msg.sender == owner) {
            user.referrer = address(0);
        }
        if (_referrer == address(0)) {
            user.referrer = owner;
        }
        if (!users[_referrer].isExists && msg.sender != owner) {
            user.referrer = owner;
        }
        if (
            user.referrer == address(0) &&
            msg.sender != owner &&
            users[_referrer].isExists
        ) {
            user.referrer = _referrer;
        }

        token.transferFrom(msg.sender, address(this), _amount);

        if (!user.isExists) {
            totalUsers++;
            user.isExists = true;
            setRefferalChain(user.referrer, _plan);
            distributeReferalRewardAmount(_amount, _plan);
        }

        uint256 rewardAmount = (_amount * plans[_plan].percentPerInterval * (plans[_plan].stakingPeriods / baseWithdrawInterval)) / percentDivider;

        bool bonusEligibility;

        if (whitelistedRewardHolder[msg.sender]) {
            bonusEligibility = true;
        }

        user.stakes.push(
            userStakeData(
                _amount,
                rewardAmount,
                rewardAmount,
                block.timestamp,
                block.timestamp + plans[_plan].stakingPeriods,
                block.timestamp,
                _plan,
                plans[_plan].percentPerInterval,
                plans[_plan].stakingIntervalLimits,
                baseWithdrawInterval,
                bonusEligibility,
                true
            )
        );

        depositHistory[depositCount] = Deposit(msg.sender, _amount, block.timestamp);

        depositCount++;
        user.totalStaked += _amount;
        user.stakingCount++;
        totalStaked += _amount;
        return true;
    }

    function withdraw(uint256 _index) public {
        User storage user = users[msg.sender];

        require(_index < user.stakes.length, "Invalid Index");
        require(user.stakes[_index].isActive, "Stake is not Active");

        require(block.timestamp - user.stakes[_index].lastWithdrawTime >= user.stakes[_index].intervalLimit, "You cannot withdraw right now. wait for turn!");

        uint256 duration = (block.timestamp - user.stakes[_index].lastWithdrawTime) / user.stakes[_index].intervalTime;
        uint256 currentDividend = (user.stakes[_index].amount * user.stakes[_index].percentPerInterval * duration) / percentDivider;

        if (
            currentDividend >= user.stakes[_index].remainingAmount &&
            block.timestamp >= user.stakes[_index].endTime
        ) {
            currentDividend = user.stakes[_index].remainingAmount;
            user.stakes[_index].isActive = false;
            user.stakes[_index].lastWithdrawTime = user.stakes[_index].endTime;
        } else {
            user.stakes[_index].lastWithdrawTime += (duration * user.stakes[_index].intervalTime);
        }

        token.transfer(msg.sender, currentDividend);

        if (user.stakes[_index].extraBonus) {
            uint256 bonusAmount = (currentDividend * extraRewardPercentage) / percentDivider;
            token.transfer(msg.sender, bonusAmount);
        }

        withdrawHistory[withdrawCount] = Withdraw(
            msg.sender,
            currentDividend,
            block.timestamp
        );

        withdrawCount++;

        user.stakes[_index].remainingAmount -= currentDividend;
        user.totalWithdrawn += currentDividend;
        totalWithdraw += currentDividend;
    }

    function reinvest(uint256 _index, uint256 _plan) public {
        User storage user = users[msg.sender];
        require(_index < user.stakes.length, "Invalid Index");
        require(_plan < totalPlans, "Invalid Plan!");
        require(user.stakes[_index].isActive, "Stake is not Active");

        require( block.timestamp - user.stakes[_index].lastWithdrawTime >= user.stakes[_index].intervalLimit, "You cannot restake right now. wait for turn!");

        uint256 duration = (block.timestamp - user.stakes[_index].lastWithdrawTime) / user.stakes[_index].intervalTime;

        uint256 currentDividend = ((user.stakes[_index].amount * user.stakes[_index].percentPerInterval) * duration) / percentDivider;

        if (
            currentDividend >= user.stakes[_index].remainingAmount &&
            block.timestamp >= user.stakes[_index].endTime
        ) {
            currentDividend = user.stakes[_index].remainingAmount;
            user.stakes[_index].isActive = false;
            user.stakes[_index].lastWithdrawTime = user.stakes[_index].endTime;
        } else {
            user.stakes[_index].lastWithdrawTime += (duration *
                user.stakes[_index].intervalTime);
        }

        if (user.stakes[_index].extraBonus) {
            uint256 bonusAmount = (currentDividend * extraRewardPercentage) / percentDivider; 
            token.transfer(msg.sender, bonusAmount);
        }

        require(currentDividend >= plans[_plan].minDepositAmount, "You cannot stake less than minimum amount of this plan");
        require(currentDividend <= plans[_plan].maxDepositAmount, "You cannot stake greater than max amount of this plan");

        uint256 rewardAmount = (currentDividend * plans[_plan].percentPerInterval * (plans[_plan].stakingPeriods / baseWithdrawInterval)) / percentDivider;

        user.stakes[_index].remainingAmount -= currentDividend;
        bool bonusEligibility;

        if (whitelistedRewardHolder[msg.sender]) {
            bonusEligibility = true;
        }

        user.stakes.push(
            userStakeData(
                currentDividend,
                rewardAmount,
                rewardAmount,
                block.timestamp,
                block.timestamp + plans[_plan].stakingPeriods,
                block.timestamp,
                _plan,
                plans[_plan].percentPerInterval,
                plans[_plan].stakingIntervalLimits,
                baseWithdrawInterval,
                bonusEligibility,
                true
            )
        );

        depositHistory[depositCount] = Deposit(
            msg.sender,
            currentDividend,
            block.timestamp
        );

        depositCount++;

        user.totalWithdrawn += currentDividend;
        user.totalStaked += currentDividend;
        user.stakingCount++;
        totalStaked += currentDividend;
        totalWithdraw += currentDividend;
    }

    function setRefferalChain(address _referrer, uint256 _plan) internal {
        address referal = _referrer;
        User storage user = users[referal];
        if (referal != address(0)) {
            user.referalCounts[_plan]++;
            referal = users[ referal ].referrer;
        }
    }

    function distributeReferalRewardAmount(uint256 _amount, uint256 _plan) internal {
        address referal = users[msg.sender].referrer;

        if (referal != address(0)) {
            User storage user = users[referal];

            user.teamTurnOver += _amount;

            user.referalAmounts[ _plan ] += (_amount * plans[ _plan ].referralPercentages) / percentDivider;
            token.transfer( referal, (_amount * plans[ _plan ].referralPercentages) / percentDivider );

            referal = users[referal].referrer;
        }
    }

    function getCurrentClaimableAmount(address _user, uint256 _index) external view
        returns (uint256 withdrawableAmount, uint256 bonusAmount)
    {
        User storage user = users[_user];

        uint256 duration = (block.timestamp - user.stakes[_index].lastWithdrawTime) / user.stakes[_index].intervalTime;

        withdrawableAmount = (user.stakes[_index].amount * user.stakes[_index].percentPerInterval * duration) / percentDivider;

        if (withdrawableAmount >= user.stakes[_index].remainingAmount) {
            withdrawableAmount = user.stakes[_index].remainingAmount;
        }
        if (user.stakes[_index].extraBonus) {
            bonusAmount = (withdrawableAmount * extraRewardPercentage) / percentDivider;
        }

        return (withdrawableAmount, bonusAmount);
    }

    function getReferalData(address _user) external view
        returns (
            uint256 numOfReferals,
            uint256 activeReferals,
            uint256 earnedCommision
        )
    {
        User storage user = users[_user];

        for (uint256 i; i < totalPlans; i++) {
            numOfReferals += user.referalCounts[i];
            earnedCommision += user.referalAmounts[i];
        }

        activeReferals = user.referalCounts[0];
        return (numOfReferals, activeReferals, earnedCommision);
    }

    function getReferalInfo(address _user) external view
        returns (uint256[] memory, uint256[] memory)
    {
        
        uint256[] memory referalCounts = new uint256[](totalPlans);
        uint256[] memory referalAmounts = new uint256[](totalPlans);

        for (uint256 i; i < totalPlans; i++) {
            referalCounts[ i ] = users[_user].referalCounts[ i ];
            referalAmounts[ i ] = users[_user].referalAmounts[ i ];
        }
        
        return (
            referalCounts,
            referalAmounts
        );
    }
    
    function getDepositHistory(uint256 _cursor, uint256 _size) external view
        returns (address[] memory, uint256[] memory, uint256[] memory, uint256)
    {

        uint256 length = _size;
        if (length > (depositCount - _cursor)) {
            length = depositCount - _cursor;
        }

        address[] memory _users = new address[](length);
        uint256[] memory depositAmounts = new uint256[](length);
        uint256[] memory depositTimes = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            _users[ i ] = depositHistory[ depositCount - 1 - (i + _cursor) ]._user;
            depositAmounts[ i ] = depositHistory[ depositCount - 1 - (i + _cursor) ].depositAmount;
            depositTimes[ i ] = depositHistory[ depositCount - 1 - (i + _cursor) ].depositTime;
        }
        
        return (
            _users,
            depositAmounts,
            depositTimes,
            _cursor + length
        );
    }
    function getWithdrawHistory(uint256 _cursor, uint256 _size) external view
        returns (address[] memory, uint256[] memory, uint256[] memory, uint256)
    {

        uint256 length = _size;
        if (length > (withdrawCount - _cursor)) {
            length = withdrawCount - _cursor;
        }

        address[] memory _users = new address[](length);
        uint256[] memory withdrawAmounts = new uint256[](length);
        uint256[] memory withdrawTimes = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
            _users[ i ] = withdrawHistory[ withdrawCount - 1 - (i + _cursor) ]._user;
            withdrawAmounts[ i ] = withdrawHistory[ withdrawCount - 1 - (i + _cursor) ].withdrawAmount;
            withdrawTimes[ i ] = withdrawHistory[ withdrawCount - 1 - (i + _cursor) ].withdrawTime;
        }
        
        return (
            _users,
            withdrawAmounts,
            withdrawTimes,
            _cursor + length
        );
    }
    
    
    function viewStaking(uint256 _index, address _user) public view
        returns (
            uint256 amount,
            uint256 totalAmount,
            uint256 remainingAmount,
            uint256 startTime,
            uint256 lastWithdrawTime,
            uint256 plan,
            uint256 percentPerIntervall,
            uint256 intervalLimit,
            uint256 intervalTime,
            bool extraBonus,
            bool isActive
        )
    {
        User storage user = users[_user];
        amount = user.stakes[_index].amount;
        totalAmount = user.stakes[_index].totalAmount;
        remainingAmount = user.stakes[_index].remainingAmount;
        startTime = user.stakes[_index].startTime;
        lastWithdrawTime = user.stakes[_index].lastWithdrawTime;
        plan = user.stakes[_index].plan;
        percentPerIntervall = user.stakes[_index].percentPerInterval;
        intervalLimit = user.stakes[_index].intervalLimit;
        intervalTime = user.stakes[_index].intervalTime;
        extraBonus = user.stakes[_index].extraBonus;
        isActive = user.stakes[_index].isActive;
    }

    function calculatePlanReward(uint256 _amount, uint256 _plan) external view
        returns (uint256 totalReward, uint256 hourlyReward)
    {
        require(_plan < totalPlans, "Invalid Plan!");

        totalReward = (_amount * plans[_plan].percentPerInterval * (plans[_plan].stakingPeriods / baseWithdrawInterval)) / percentDivider;
        hourlyReward = (_amount * plans[_plan].percentPerInterval) / percentDivider;

        return (totalReward, hourlyReward);
    }
    
    function addPlan(Plan memory _plan) internal {

        plans[ totalPlans ] = Plan({
            isExists                : true,
            percentPerInterval      : _plan.percentPerInterval,
            stakingIntervalLimits   : _plan.stakingIntervalLimits,
            stakingPeriods          : _plan.stakingPeriods,
            minDepositAmount        : _plan.minDepositAmount * (10**token.decimals()),
            maxDepositAmount        : _plan.maxDepositAmount * (10**token.decimals()),
            referralPercentages     : _plan.referralPercentages
        });
        totalPlans += 1;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function setOpeningDate(uint256 _openingDate) external onlyOwner {
       openingDate = _openingDate;
    }
    function setTotalStakedCap(uint256 _totalStakedCap) external onlyOwner {
       totalStakedCap = _totalStakedCap * ( 10**token.decimals() );
    }

    function enableOrDisableNewParticipations(bool _disable) external onlyOwner
    {
        stopParticipation = _disable;
    }

    function addOrRemoveFromWhitelist(address[] memory _users, bool _enable) external onlyOwner
    {
        for (uint256 i; i < _users.length; i++) {
            whitelistedRewardHolder[_users[i]] = _enable;
        }
    }
}