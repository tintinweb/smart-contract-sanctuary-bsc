// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../interface/IERC20.sol";
import "../JaxProtection.sol";

contract Ubi is Initializable, JaxProtection {

    event Set_Ajax_Prime(address newUbiAjaxPrime, uint newUbiAjaxPrimeLocktime);
    event Update_Ajax_Prime(address newUbiAjaxPrime);
    event Set_Reward_Token(address rewardToken);
    event Register(address user);
    event Accept_User(address user, uint idHash, uint bonus, string remarks);
    event Reject_User(address user, string remarks);
    event Change_My_JaxCorp_Governor(address jaxCorp_governor);
    event Collect_UBI(address indexed user, uint collect_id, uint amount);
    event Release_Collect(address indexed user, uint collect_id, uint amount);
    event Unlock_Collect(address indexed user, uint collect_id, address jaxCorp_governor);
    event Deposit_Reward(uint amount);
    event Set_Minimum_Reward_Per_Person(uint amount);
    event Set_JaxCorp_Governors(address[] jaxCorp_governors);
    event Set_AjaxPrime_Delegates(address[] jaxCorp_governors);
    event Set_JaxCorp_Governor_Limit(address jaxCorp_governor, uint limit);
    event Set_Locktime(uint locktime);
    event Set_Major_Ajax_Prime_Nominee(address ubi_ajaxPrimeNominee);
    event Withdraw_By_Admin(address token, uint amount);

    address public ubi_ajaxPrime;
    address public new_ubi_ajaxPrime;
    uint public new_ubi_ajaxPrime_locktime;
    address public rewardToken;

    enum Status { Init, Pending, Approved, Rejected }

    struct CollectInfo {
        uint amount;
        uint64 collect_timestamp;
        uint64 unlock_timestamp;
        uint64 release_timestamp;
    }

    struct UserInfo {
        uint harvestedReward;
        uint collectedReward;
        uint releasedReward;
        uint idHash;
        address jaxCorp_governor;
        Status status;
        string remarks;
        CollectInfo[] collects;
    }

    uint public totalRewardPerPerson;
    uint public userCount;
    uint public minimumRewardPerPerson;

    uint public locktime;

    address public majorUbiAjaxPrimeNominee;

    mapping(address => UserInfo) userInfo;
    mapping(address => uint) public jaxCorpGovernorLimitInfo;
    mapping(address => uint) public jaxCorpGovernorAdvanceLimitInfo;
    address[] public jaxCorp_governors;
    address[] public ajaxPrime_delegates;
    mapping(uint => address) public idHashInfo;
    mapping(address => uint) public voteCountInfo;
    mapping(address => address) public ubi_ajaxPrimeNomineeInfo;

    modifier onlyUbiAjaxPrime() {
        require(msg.sender == ubi_ajaxPrime, "Only Ubi Ajax Prime");
        _;
    }

    modifier onlyJaxCorpGovernor() {
        if(isAjaxPrimeDelegate(msg.sender)) {
            _;
            return;
        }
        require(isJaxCorpGovernor(msg.sender), "Only Governor or Ajax Prime Delegate");
        require(jaxCorpGovernorLimitInfo[msg.sender] > 0, "Operating limit reached");
        _;
        jaxCorpGovernorLimitInfo[msg.sender] -= 1;
    }
    
  modifier checkZeroAddress(address account) {
    require(account != address(0x0), "Only non-zero address");
    _;
  }

    function get_user_info(address account) external view returns(Status status, uint idHash, uint collectedReward, uint releasedReward, uint collect_count, uint release_count, address jaxCorp_governor, string memory remarks) {
        UserInfo memory user = userInfo[account];
        status = user.status;
        idHash = user.idHash;
        collectedReward = user.collectedReward;
        releasedReward = user.releasedReward;
        collect_count = user.collects.length;
        jaxCorp_governor = user.jaxCorp_governor;
        for(uint i = 0; i < user.collects.length; i += 1) {
            if(user.collects[i].release_timestamp>0)
                release_count += 1;
        }
        remarks = user.remarks;
    }

    function get_collect_info(address account) external view returns(CollectInfo[] memory) {
        return userInfo[account].collects;
    }

    function isJaxCorpGovernor(address jaxCorp_governor) public view returns (bool) {
        uint jaxCorp_governorCnt = jaxCorp_governors.length;
        uint index = 0;
        for(index; index < jaxCorp_governorCnt; index += 1) {
            if(jaxCorp_governors[index] == jaxCorp_governor){
                return true;
            }
        }
        return false;
    }

    function setJaxCorpGovernors (address[] calldata _jaxCorp_governors) external onlyUbiAjaxPrime runProtection {
        uint jaxCorp_governorsCnt = _jaxCorp_governors.length;
        delete jaxCorp_governors;
        for(uint index = 0; index < jaxCorp_governorsCnt; index += 1 ) {
            jaxCorp_governors.push(_jaxCorp_governors[index]);
        }
        emit Set_JaxCorp_Governors(_jaxCorp_governors);
    }

    function setAjaxPrimeDelegates (address[] calldata _delegates) external onlyUbiAjaxPrime runProtection {
        uint count = _delegates.length;
        delete ajaxPrime_delegates;
        for(uint index = 0; index < count; index += 1 ) {
            ajaxPrime_delegates.push(_delegates[index]);
        }
        emit Set_AjaxPrime_Delegates(_delegates);
    }

    function isAjaxPrimeDelegate(address delegate) public view returns (bool) {
        uint count = ajaxPrime_delegates.length;
        uint index = 0;
        for(index; index < count; index += 1) {
            if(ajaxPrime_delegates[index] == delegate){
                return true;
            }
        }
        return false;
    }

    function setJaxCorpGovernorLimit(address jaxCorp_governor, uint limit, uint advance_limit) external onlyUbiAjaxPrime runProtection {
        require(isJaxCorpGovernor(jaxCorp_governor) || isAjaxPrimeDelegate(jaxCorp_governor), "Needs to be jaxcorp governor or aJax prime delegate");
        jaxCorpGovernorLimitInfo[jaxCorp_governor] = limit;
        jaxCorpGovernorAdvanceLimitInfo[jaxCorp_governor] = advance_limit;
        emit Set_JaxCorp_Governor_Limit(jaxCorp_governor, limit);
    }

    function set_reward_token(address _rewardToken) external checkZeroAddress(_rewardToken) onlyUbiAjaxPrime runProtection {
        rewardToken = _rewardToken;
        emit Set_Reward_Token(_rewardToken);
    }

    function set_minimum_reward_per_person(uint amount) external onlyUbiAjaxPrime runProtection {
        minimumRewardPerPerson = amount;
        emit Set_Minimum_Reward_Per_Person(amount);
    }

    function deposit_reward(uint amount) external {
        require(userCount > 0, "No valid users in UBI");
        uint rewardPerPerson = amount / userCount;
        require(rewardPerPerson >= minimumRewardPerPerson, "Reward is too small");
        IERC20(rewardToken).transferFrom(msg.sender, address(this), amount);
        totalRewardPerPerson += rewardPerPerson;
        emit Deposit_Reward(amount);
    }

    function collect_ubi() external {
        UserInfo storage info = userInfo[msg.sender];
        require(info.status == Status.Approved, "You are not approved");
        require(totalRewardPerPerson > info.harvestedReward, "Nothing to harvest");
        uint reward = totalRewardPerPerson - info.harvestedReward;
        info.harvestedReward = totalRewardPerPerson;
        info.collectedReward += reward;
        CollectInfo memory collect;
        collect.collect_timestamp = uint64(block.timestamp);
        collect.unlock_timestamp = uint64(block.timestamp + locktime);
        collect.amount = reward;
        info.collects.push(collect);
        emit Collect_UBI(msg.sender, info.collects.length - 1, reward);
        if(locktime == 0) {
            _release_collect(msg.sender, info.collects.length - 1);
        }
    }

    function unlock_collect(address user, uint collect_id) external onlyJaxCorpGovernor {
        UserInfo storage info = userInfo[user];
        require(info.jaxCorp_governor == msg.sender || isAjaxPrimeDelegate(msg.sender), "Invalid jaxCorp_governor");
        require(info.collects.length > collect_id, "Invalid collect_id");
        CollectInfo storage collect = info.collects[collect_id];
        require(collect.release_timestamp == 0, "Already released");
        require(uint(collect.unlock_timestamp) > block.timestamp, "Already unlocked");
        collect.unlock_timestamp = uint64(block.timestamp);
        emit Unlock_Collect(user, collect_id, msg.sender);
        _release_collect(user, collect_id);
    }

    function _release_collect(address user, uint collect_id) internal {
        UserInfo storage info = userInfo[user];
        require(info.collects.length > collect_id, "Invalid collect_id");
        CollectInfo storage collect = info.collects[collect_id];
        require(collect.release_timestamp == 0, "Already released");
        require(uint(collect.unlock_timestamp) <= block.timestamp, "Locked");
        collect.release_timestamp = uint64(block.timestamp);
        info.releasedReward += collect.amount;
        IERC20(rewardToken).transfer(user, collect.amount);
        emit Release_Collect(user, collect_id, collect.amount);
    }

    function release_collect(uint collect_id) public {
        _release_collect(msg.sender, collect_id);
    }

    function approveUser(address user, uint idHash, uint advance, string calldata remarks) external onlyJaxCorpGovernor {
        UserInfo storage info = userInfo[user];
        require(info.status != Status.Init, "User is not registered");
        require(info.status != Status.Approved, "Already approved");
        require(idHashInfo[idHash] == address(0), "Id hash should be unique");
        if(info.status == Status.Rejected) {
            require(advance == 0, "Advance should be zero");
        }
        else {
            require(advance <= 10 * (10 ** IERC20(rewardToken).decimals()), "Max 10 advance");
            require(advance <= jaxCorpGovernorAdvanceLimitInfo[msg.sender], "Out of advance limit");
            jaxCorpGovernorAdvanceLimitInfo[msg.sender] -= advance;
        }
        userCount += 1;
        info.harvestedReward = totalRewardPerPerson + advance;
        info.idHash = idHash;
        info.remarks = remarks;
        info.jaxCorp_governor = msg.sender;
        info.status = Status.Approved;
        idHashInfo[idHash] = user;
        if(advance > 0)
            IERC20(rewardToken).transfer(user, advance);
        emit Accept_User(user, idHash, advance, remarks);
    }

    function rejectUser(address user, string calldata remarks) external onlyJaxCorpGovernor {
        UserInfo storage info = userInfo[user];
        require(info.status != Status.Init, "User is not registered");
        if(info.status == Status.Approved) {
            userCount -= 1;
            address ubi_ajaxPrimeNominee = ubi_ajaxPrimeNomineeInfo[user];
            if(ubi_ajaxPrimeNomineeInfo[user] != address(0)) {
                voteCountInfo[ubi_ajaxPrimeNominee] -= 1;
                ubi_ajaxPrimeNomineeInfo[user] = address(0);
                check_major_ubi_ajax_prime_nominee(ubi_ajaxPrimeNominee);
            }
        }
        info.status = Status.Rejected;
        idHashInfo[info.idHash] = address(0);
        info.remarks = remarks;
        emit Reject_User(user, remarks);
    }

    function changeMyJaxCorpGovernor(address jaxCorp_governor) external {
        UserInfo storage info = userInfo[msg.sender];
        require(info.status == Status.Approved, "You are not approved");
        require(isJaxCorpGovernor(jaxCorp_governor), "Only valid jaxCorp_governor");
        info.jaxCorp_governor = jaxCorp_governor;
        emit Change_My_JaxCorp_Governor(jaxCorp_governor);
    }

    function register() external {
        UserInfo storage info = userInfo[msg.sender];
        require(info.status == Status.Init, "You already registered");
        info.status = Status.Pending;
        emit Register(msg.sender);
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize(address _ubi_ajaxPrime, address _rewardToken, uint _locktime) external initializer 
     checkZeroAddress(_ubi_ajaxPrime) checkZeroAddress(_rewardToken)
    {
        ubi_ajaxPrime = _ubi_ajaxPrime;
        rewardToken = _rewardToken;
        locktime = _locktime;
    }

    function set_ubi_ajax_prime(address newUbiAjaxPrime) external onlyUbiAjaxPrime {
        if(newUbiAjaxPrime == address(0x0)){
            ubi_ajaxPrime = address(0x0);
            new_ubi_ajaxPrime = address(0x0);
            emit Update_Ajax_Prime(address(0x0));
            return;
        }
        new_ubi_ajaxPrime = newUbiAjaxPrime;
        new_ubi_ajaxPrime_locktime = block.timestamp + 2 days;
        emit Set_Ajax_Prime(newUbiAjaxPrime, new_ubi_ajaxPrime_locktime);
    }

    function update_ubi_ajax_prime() external {
        require(msg.sender == new_ubi_ajaxPrime, "Only new ajax prime");
        require(block.timestamp >= new_ubi_ajaxPrime_locktime, "New ajax prime is not unlocked yet");
        ubi_ajaxPrime = new_ubi_ajaxPrime;
        new_ubi_ajaxPrime = address(0x0);
        emit Update_Ajax_Prime(ubi_ajaxPrime);
    }

    function set_ubi_ajax_prime_nominee(address ubi_ajaxPrimeNominee) external {
        require(ubi_ajaxPrimeNominee != address(0), "UbiAjaxPrimeNominee should not be zero address");
        UserInfo memory info = userInfo[msg.sender];
        require(info.status == Status.Approved, "You are not approved");
        address old_ubi_ajaxPrimeNominee = ubi_ajaxPrimeNomineeInfo[msg.sender];
        require(old_ubi_ajaxPrimeNominee != ubi_ajaxPrimeNominee, "Voted already");
        if(old_ubi_ajaxPrimeNominee != address(0)) {
            voteCountInfo[old_ubi_ajaxPrimeNominee] -= 1;
        }
        ubi_ajaxPrimeNomineeInfo[msg.sender] = ubi_ajaxPrimeNominee;
        voteCountInfo[ubi_ajaxPrimeNominee] += 1;
        check_major_ubi_ajax_prime_nominee(ubi_ajaxPrimeNominee);
    }

    function check_major_ubi_ajax_prime_nominee(address ubi_ajaxPrimeNominee) public {
        if(voteCountInfo[ubi_ajaxPrimeNominee] > userCount / 2){
            majorUbiAjaxPrimeNominee = ubi_ajaxPrimeNominee;
            emit Set_Major_Ajax_Prime_Nominee(ubi_ajaxPrimeNominee);
        }
        else if(voteCountInfo[majorUbiAjaxPrimeNominee] <= userCount / 2){
            majorUbiAjaxPrimeNominee = address(0);
            emit Set_Major_Ajax_Prime_Nominee(address(0));
        }
    }

    function set_locktime(uint _locktime) external onlyUbiAjaxPrime runProtection {
        locktime = _locktime;
        emit Set_Locktime(_locktime);
    }

    function withdrawByAdmin(address token, uint amount) external onlyUbiAjaxPrime runProtection {
        IERC20(token).transfer(msg.sender, amount);
        emit Withdraw_By_Admin(token, amount);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (proxy/utils/Initializable.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
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
 * contract, which may impact the proxy. To initialize the implementation contract, you can either invoke the
 * initializer manually, or you can include a constructor to automatically mark it as initialized when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() initializer {}
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

/**
 * @dev Interface of the BEP standard.
 */
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function getOwner() external view returns (address);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function mint(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

contract JaxProtection {

    struct RunProtection {
        bytes32 data_hash;
        uint64 request_timestamp;
        address sender;
        bool executed;
    }

    mapping(bytes4 => RunProtection) run_protection_info;

    event Request_Update(bytes4 sig, bytes data);

    modifier runProtection() {
        RunProtection storage protection = run_protection_info[msg.sig];
        bytes32 data_hash = keccak256(msg.data);
        if(data_hash != protection.data_hash || protection.sender != msg.sender) {
        protection.sender = msg.sender;
        protection.data_hash = keccak256(msg.data);
            protection.request_timestamp = uint64(block.timestamp);
            protection.executed = false;
            emit Request_Update(msg.sig, msg.data);
            return;
        }
        require(protection.executed == false, "Already executed");
        require(block.timestamp >= uint(protection.request_timestamp) + 5 minutes, "Running is Locked");
        _;
        protection.executed = true;
    }
}