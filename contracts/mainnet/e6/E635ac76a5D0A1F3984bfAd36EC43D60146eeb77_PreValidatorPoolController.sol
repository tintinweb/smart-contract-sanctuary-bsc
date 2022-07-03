/**
 *Submitted for verification at BscScan.com on 2022-07-03
*/

// File: contract/contracts/lib/TimeLib.sol


pragma solidity ^0.8.6;

library TimeLib {
    function getCurrentWeekNumber() internal view returns (uint256) {
        uint256 firstSundayMidnight = 1656288000; // 2022 06 27 00:00:00 GMT
        uint256 secondsInWeek = 604800;
        uint256 secondsThisYear = block.timestamp - firstSundayMidnight;
        uint256 module = secondsThisYear % secondsInWeek;
        return ((secondsThisYear - module) / secondsInWeek) + 1;
    }
}

// File: openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts v4.4.0 (utils/Address.sol)

pragma solidity ^0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

// File: contract/contracts/Roles.sol



pragma solidity =0.8.10;

library Roles {
    uint8 constant OWNER = 0;
    uint8 constant MANAGER = 1;
    uint8 constant WALLETFACTORY_OPERATOR = 2;
    uint8 constant WALLET_OPERATOR = 3;
    uint8 constant KODEXA_MINTER = 4;
    uint8 constant KODEXA_WHITELIST_MANAGER = 5;
    uint8 constant CROWDSALE_MANAGER = 6;
    uint8 constant VALIDATOR_MANAGER = 7;
    uint8 constant VALIDATOR_REWARD_DISTRIBUTOR = 8;
    uint8 constant TOKENDISTRIBUTION_MANGER = 9;
    uint8 constant STAKING_MANAGER = 10;

    function roleToMask(uint8 _role) public pure returns (uint256){
        return (1 << _role);
    }
}
// File: contract/contracts/OwnableManageableChainable.sol


pragma solidity =0.8.10;



interface IExternalOwnerManagerRegistry {
    function isOwner(address) external view returns (bool);
    function isManager(address) external view returns (bool);
    function hasRole(address, uint8) external view returns (bool);
    function hasRoleByMask(address, uint256) external view returns (bool);
    function getAllRoles(address) external view returns (uint256);
}

contract OwnableManageableChainableRoles is IExternalOwnerManagerRegistry {
    address[] public managers;
    address[] public owners;
    mapping(address => uint256) rolesMap;
    address public extRegistry;

    function rolemanager_version() external pure returns (uint256) {
        return 2;
    }

    function hasRole(address _address, uint8 _role) external view returns (bool) {
        return _hasRole(_address, _role);
    }
    function _hasRole(address _address, uint8 _role) internal view returns (bool) {
        return (rolesMap[_address] & (1 << _role)) > 0 || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).hasRole(_address, _role);
    }
    function hasRoleByMask(address _address, uint256 _roleMask) external view returns (bool) {
        return _hasRoleByMask(_address, _roleMask);
    }
    function _hasRoleByMask(address _address, uint256 _roleMask) internal view returns (bool) {
        return rolesMap[_address] & _roleMask > 0 || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).hasRoleByMask(_address, _roleMask);
    }
    function hasLocalRole(address _address, uint8 _role) external view returns (bool) {
        return _hasLocalRole(_address, _role);
    }
    function _hasLocalRole(address _address, uint8 _role) internal view returns (bool) {
        return (rolesMap[_address] & (1 << _role)) > 0;
    }
    function getAllRoles(address _address) external view returns (uint256){
        return _getAllRoles(_address);
    }
    function hasLocalRoleByMask(address _address, uint256 _roleMask) external view returns (bool) {
        return _hasLocalRoleByMask( _address,  _roleMask);
    }
    function _hasLocalRoleByMask(address _address, uint256 _roleMask) internal view returns (bool) {
        return rolesMap[_address] & _roleMask > 0;
    }
    function _getAllRoles(address _address) internal view returns (uint256){
        if (extRegistry == address(0)) {
            return rolesMap[_address];
        } else {
            return rolesMap[_address] | IExternalOwnerManagerRegistry(extRegistry).getAllRoles(_address);
        }
    }
    function getAllLocalRoles(address _address) external view returns (uint256){
        return _getAllLocalRoles(_address);
    }
    function _getAllLocalRoles(address _address) internal view returns (uint256){
        return rolesMap[_address];
    }


    function isOwner(address _address) external view returns (bool) {
        return _isOwner(_address);//ownerMap[_address] || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).isOwner(_address);
    }
    function _isOwner(address _address) internal view returns (bool) {
        //return ownerMap[_address] || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).isOwner(_address);
        return _hasLocalRole(_address, Roles.OWNER) || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).isOwner(_address);
    }
    function isManager(address _address) external view returns (bool) {
        return _isManager(_address);//managerMap[_address] || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).isManager(_address);
    }
    function _isManager(address _address) internal view returns (bool) {
        //return managerMap[_address] || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).isManager(_address);
        return _hasLocalRole(_address, Roles.MANAGER) || extRegistry != address(0) && IExternalOwnerManagerRegistry(extRegistry).isManager(_address);
    }
    function isLocalOwner(address _address) external view returns (bool) {
        return _hasLocalRole(_address, Roles.OWNER) ;
    }
    function _isLocalOwner(address _address) internal view returns (bool) {
        return _hasLocalRole(_address, Roles.OWNER) ;
    }
    function isLocalManager(address _address) external view returns (bool) {
        return _hasLocalRole(_address, Roles.MANAGER) ;
    }
    function _isLocalManager(address _address) internal view returns (bool) {
        return _hasLocalRole(_address, Roles.MANAGER) ;
    }

    modifier onlyOwner() {
        require(_isOwner(msg.sender));
        _;
    }

    modifier onlyManager() {
        require(_isManager(msg.sender));
        _;
    }
    
    modifier onlyWithRole(uint8 _role) {
        require(_hasRole(msg.sender, _role));
        _;
    }

    modifier onlyWithRoleMask(uint256 _roleMask) {
        require(_hasRoleByMask(msg.sender, _roleMask));
        _;
    }

    modifier onlyLocalOwner() {
        require(_isLocalOwner(msg.sender));
        _;
    }

    modifier onlyLocalManager() {
        require(_isLocalManager(msg.sender));
        _;
    }

    modifier onlyWithLocalRole(uint8 _role) {
        require(_hasLocalRole(msg.sender, _role));
        _;
    }

    modifier onlyWithLocalRoleMask(uint256 _roleMask) {
        require(_hasLocalRoleByMask(msg.sender, _roleMask));
        _;
    }


    constructor(address[] memory _ownrs, address _extreg) {
        extRegistry = _extreg;
        for (uint i=0; i < _ownrs.length; i++)
            _addOwner(_ownrs[i]);
    }

    event ExternalRegistryAddressChanged(address addr);
    function setExternalRegistryAddress(address _extreg) external onlyOwner() {
        // avoid accidentaly rendering everything unusable by ensuring that 0 address can't be set unless there are local owners
        require(address(0) == _extreg && owners.length > 0 ||  Address.isContract(_extreg));
        // should revert if not implemented
        if (Address.isContract(_extreg)) {
            IExternalOwnerManagerRegistry(_extreg).isOwner(address(0));
            IExternalOwnerManagerRegistry(_extreg).isManager(address(0));
        }
        extRegistry = _extreg;
        emit ExternalRegistryAddressChanged(_extreg);
    }

    event RoleAdded(address addr, uint8 role);
    function setRole(address _address, uint8 _role) external onlyManager() {
        require(_role != Roles.OWNER && _role != Roles.MANAGER);
        _setRole(_address, _role);
    }

    function _setRole(address _address, uint8 _role) internal {
        require(rolesMap[_address] & (1 << _role) == 0);
        rolesMap[_address] = rolesMap[_address] | (1 << _role);
        if (_role != Roles.OWNER && _role != Roles.MANAGER) emit RoleAdded(_address, _role);
    }

    event RoleRemoved(address addr, uint8 role);
    function unsetRole(address _address, uint8 _role) external onlyManager() {
        require(_role != Roles.OWNER && _role != Roles.MANAGER);
        _unsetRole(_address, _role);
    }

    function _unsetRole(address _address, uint8 _role) internal {
        require((rolesMap[_address] & (1 << _role)) > 0);
        uint256 intmax;
        unchecked { intmax = uint256(0) - 1;}
        uint256 tmp = rolesMap[_address] & (intmax ^ (uint256(1) << _role));

        if (tmp == 0) {
            delete(rolesMap[_address]);
        } else {
            rolesMap[_address] = tmp;
        }
        if (_role != Roles.OWNER && _role != Roles.MANAGER) emit RoleRemoved(_address, _role);
    }

    event AllRolesSet(address addr, uint256 roles);
    function setAllRoles(address _address, uint256 _roles) external onlyOwner() {
        _setAllRoles(_address, _roles);
    }

    function _setAllRoles(address _address, uint256 _roles) internal {
        rolesMap[_address] = _roles;
        emit AllRolesSet(_address, _roles);
    }

    event OwnerAdded(address owner);
    function addOwner(address _ownr) public onlyOwner() {
        _addOwner(_ownr);
    }

    function _addOwner(address _ownr) internal {
        if (!_hasLocalRole(_ownr, Roles.OWNER)) {
            _setRole(_ownr, Roles.OWNER);
            owners.push(_ownr);
            emit OwnerAdded(_ownr);
        } else revert();
    }

    event OwnerRevoked(address owner);
    function revokeOwner(address _ownr) public onlyOwner {
        // cant revoke if not admin and cant revoke last owner
        if (_hasLocalRole(_ownr, Roles.OWNER) && (owners.length > 1 || extRegistry != address(0))) {
            _unsetRole(_ownr, Roles.OWNER);
            for (uint i=0; i < owners.length; i++){
                if (owners[i] == _ownr) {
                    owners[i] = owners[owners.length-1];
                    owners.pop();
                    break;
                }
            }
            emit OwnerRevoked(_ownr);
        } else revert();
    }

    event ManagerAdded(address manager);
    function addManager(address _mgr) public onlyOwner() {
        _addManager(_mgr);
    }
    function _addManager(address _mgr) internal {
        if (!_hasLocalRole(_mgr, Roles.MANAGER)) {
            _setRole(_mgr, Roles.MANAGER);
            managers.push(_mgr);
            emit ManagerAdded(_mgr);
        } else revert();
    }

    event ManagerRevoked(address manager);
    function revokeManager(address _mgr) public onlyOwner() {
        if (_hasLocalRole(_mgr, Roles.MANAGER)) {
            _unsetRole(_mgr, Roles.MANAGER);
            for (uint i=0; i < managers.length; i++){
                if (managers[i] == _mgr) {
                    managers[i] = managers[managers.length-1];
                    managers.pop();
                    break;
                }
            }
            emit ManagerRevoked(_mgr);
        } else revert();
    }
}
// File: contract/contracts/packagesale/PreValidatorPoolControllerV2.sol


pragma solidity ^0.8.10;




interface IPreValidatorPool {
    function distributeReward(uint256 poolId, uint256 amount) external;
}

contract PreValidatorPoolController is OwnableManageableChainableRoles {
    address public pvpool;
    bool stopped = false;

    mapping(uint256 => bool) public weekRewardDistributed;
    mapping(uint256 => uint256) public weekRewardDistributionMultiplier;
    mapping(uint256 => uint256) public poolIdToBaseAmount;
    uint256 public defaultMultiplier = 1;
    uint256 public firstWeek;

    constructor(
        address[] memory _ownrs,
        address _extreg,
        address _pvp,
        uint256 _firstWeek
    ) OwnableManageableChainableRoles(_ownrs, _extreg) {
        pvpool = _pvp;

        poolIdToBaseAmount[0] = 50400 ether;
        poolIdToBaseAmount[1] = 100800 ether;
        poolIdToBaseAmount[2] = 324000 ether;
        poolIdToBaseAmount[3] = 1250 ether;
        poolIdToBaseAmount[4] = 4500 ether;
        poolIdToBaseAmount[5] = 11750 ether;

        firstWeek = _firstWeek;
        if (firstWeek < TimeLib.getCurrentWeekNumber()) {
            firstWeek = TimeLib.getCurrentWeekNumber();
        }
    }

    function getPool() external view returns (address) {
        return pvpool;
    }

    function setPool(address _pvp) external onlyOwner {
        pvpool = _pvp;
    }

    function setStopped(bool _stp) external onlyOwner {
        stopped = _stp;
    }

    function setBaseAmountForPoolId(uint256 _poolId, uint256 _base) external onlyOwner {
        poolIdToBaseAmount[_poolId] = _base;
    }

    function setMultiplierForWeek(uint256 _week, uint256 _multiplier) external onlyOwner {
        weekRewardDistributionMultiplier[_week] = _multiplier;
    }

    function getCurrentWeekNumber() public view returns (uint256) {
        return TimeLib.getCurrentWeekNumber();
    }

    function getAmountForPoolId(uint256 _poolId, uint256 _week)
        public
        view
        returns (uint256)
    {
        if (weekRewardDistributionMultiplier[_week] == 0) {
            return poolIdToBaseAmount[_poolId] * defaultMultiplier;
        }
        return
            poolIdToBaseAmount[_poolId] *
            weekRewardDistributionMultiplier[_week];
    }

    function distributeWeeklyPoolRewards()
        external
        onlyWithRole(Roles.VALIDATOR_REWARD_DISTRIBUTOR)
    {
        require(!stopped, "Contract stopped by owner");
        uint256 week = TimeLib.getCurrentWeekNumber();
        require(week >= firstWeek, "Not reached first distribution week yet");
        require(!weekRewardDistributed[week], "Already distributed");
        weekRewardDistributed[week] = true;
        IPreValidatorPool(pvpool).distributeReward(0, getAmountForPoolId(0, week));
        IPreValidatorPool(pvpool).distributeReward(1, getAmountForPoolId(1, week));
        IPreValidatorPool(pvpool).distributeReward(2, getAmountForPoolId(2, week));
        IPreValidatorPool(pvpool).distributeReward(3, getAmountForPoolId(3, week));
        IPreValidatorPool(pvpool).distributeReward(4, getAmountForPoolId(4, week));
        IPreValidatorPool(pvpool).distributeReward(5, getAmountForPoolId(5, week));
    }
}