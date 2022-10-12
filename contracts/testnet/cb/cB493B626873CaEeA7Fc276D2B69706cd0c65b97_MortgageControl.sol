// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MortgageControl is AccessControl {
    ///@dev developer role created
    bytes32 public constant DEV_ROLE = keccak256("DEV_ROLE");

    struct LocalVars {
        uint256 _mortgageId;
        address _user;
        address _collection;
        uint256 _nftId;
        uint256 _loan;
        uint256 _downPay;
        uint256 _startDate;
        uint256 _period;
        uint64   _interestrate; 
        uint256 _payCounter;
        bool _isPay;
        address _wrapContract;
        bool _mortgageAgain;
        uint256 _linkId;
        uint256 _price;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(DEV_ROLE, msg.sender);
    }

    mapping(address => bool) public mortgage;

    ///@notice structure and mapping that keeps track of mortgage
    struct Information {
        address collection;
        uint256 nftId;
        address wrapContract;
        uint256 loan;  
        uint256 downPay;  
        uint256 price;
        uint256 startDate;
        uint256 period; //Years in months
        uint64  interestrate; //interest in days 
        uint256 payCounter; //Start in zero 
        bool isPay; //default is false 
        bool mortgageAgain; //default is false
        uint256 linkId; //link to the new mortgage
    }

    struct MortgageInterest {
        uint256 totalDebt; 
        uint256 totalMonthlyPay; 
        uint256 amountToPanoram; 
        uint256 amountToPool; 
        uint256 amountToVault; 
        uint256 totalDelayedMonthlyPay; 
        uint256 amountToPanoramDelayed; 
        uint256 amountToPoolDelayed; 
        uint256 totalToPayOnLiquidation; 
        uint256 totalPoolLiquidation; 
        uint256 totalPanoramLiquidation;
        uint256 lastTimePayment;
        uint256 lastTimeCalc; 
        uint8 strikes; 
        bool isMonthlyPaymentPayed; 
        bool isMonthlyPaymentDelayed; 
        bool liquidate; 
    }

    ///@dev address user wallet 
    ///@dev uint256 Mortgage ID
    mapping(address => mapping(uint256 => Information)) private usermortgage;

    mapping(address => mapping(uint256 => MortgageInterest)) private userToMortgageInterest; 

    uint256 private mortgageId = 0;

    ///@dev use Mortgage ID to return user wallet 
    mapping(uint256 => address) private idInfo;

    modifier onlymortgage() {
        if (!mortgage[msg.sender]) {
            revert("you can not modify");
        }
        _;
    }
    
    function getIdInfo(uint256 id) public view returns(address _user) {
        return idInfo[id];
    }

    function getUserInfo(address _user, uint256 _mortgageId)
        public
        view
        returns (
            address,
            uint256,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256, 
            uint64,
            uint256,
            bool,
            bool,
            uint256
        )
    {   
        LocalVars memory vars;
        vars._user = _user;
        vars._mortgageId = _mortgageId;
        return (
        vars._collection = usermortgage[vars._user][vars._mortgageId].collection,
        vars._nftId = usermortgage[vars._user][vars._mortgageId].nftId,
        vars._wrapContract = usermortgage[vars._user][vars._mortgageId].wrapContract,
        vars._loan = usermortgage[vars._user][vars._mortgageId].loan,
        vars._downPay = usermortgage[vars._user][vars._mortgageId].downPay,
        vars._price = usermortgage[vars._user][vars._mortgageId].price,
        vars._startDate = usermortgage[vars._user][vars._mortgageId].startDate,
        vars._period = usermortgage[vars._user][vars._mortgageId].period,
        vars._interestrate= usermortgage[vars._user][vars._mortgageId].interestrate,
        vars._payCounter = usermortgage[vars._user][vars._mortgageId].payCounter,
        vars._isPay = usermortgage[vars._user][vars._mortgageId].isPay,
        vars._mortgageAgain = usermortgage[vars._user][vars._mortgageId].mortgageAgain,
        vars._linkId = usermortgage[vars._user][vars._mortgageId].linkId);
    }

    function getTotalMortgages() public view returns(uint256){
        return mortgageId;
    }

    function addRegistry(uint256 id, address wallet, address _collection, address _wrapContract,uint256 _nftId, uint256 _loan,uint256 _downPay,
    uint256 _price,uint256 _startDate,uint256 _period, uint64 _interestrate) public onlymortgage {
        usermortgage[wallet][id].collection = _collection;
        usermortgage[wallet][id].nftId = _nftId;
        usermortgage[wallet][id].wrapContract= _wrapContract;
        usermortgage[wallet][id].loan= _loan;
        usermortgage[wallet][id].downPay= _downPay;
        usermortgage[wallet][id].price= _price;
        usermortgage[wallet][id].startDate = _startDate;
        usermortgage[wallet][id].period = _period;
        usermortgage[wallet][id].interestrate = _interestrate;
    }

    function updateMortgageLink(uint256 oldId, uint256 newId, address wallet, uint256 _loan,uint256 _downPay,
    uint256 _startDate,uint256 _period, bool _mortageState) public onlymortgage {
        LocalVars memory vars;
        usermortgage[wallet][oldId].mortgageAgain = _mortageState;
        usermortgage[wallet][oldId].linkId = newId;
        (vars._collection,vars._nftId, vars._wrapContract, , ,
        , , ,vars._interestrate, , , , ) = getUserInfo(wallet, oldId);
        usermortgage[wallet][newId].collection = vars._collection;
        usermortgage[wallet][newId].nftId = vars._nftId;
        usermortgage[wallet][newId].wrapContract= vars._wrapContract;
        usermortgage[wallet][newId].loan= _loan;
        usermortgage[wallet][newId].downPay= _downPay;
        usermortgage[wallet][newId].startDate = _startDate;
        usermortgage[wallet][newId].period = _period;
        usermortgage[wallet][newId].interestrate = vars._interestrate;
        usermortgage[wallet][newId].linkId = oldId;
        
    }

    function updateMortgageState(uint256 id,address wallet,  bool _state) public onlymortgage {
        usermortgage[wallet][id].isPay = _state;
    }

    function updateMortgagePayment(uint256 id,address wallet) public onlymortgage {
        usermortgage[wallet][id].payCounter = usermortgage[wallet][id].payCounter + 1;
    }

    function addIdInfo(uint256 id, address wallet) public onlymortgage {
        idInfo[id]= wallet;
        ++mortgageId;
    }

      function getFrontMortgageData(address _wallet, uint256 _IdMortage)
        public
        view
        returns (
            uint256 totalDebt,
            uint256 totalMonthlyPay,
            uint256 totalDelayedMonthlyPay,
            uint256 totalToPayOnLiquidation,
            uint256 lastTimePayment,
            bool isMonthlyPaymentPayed,
            bool isMonthlyPaymentDelayed,
            bool liquidate
        )
    {
        totalDebt = userToMortgageInterest[_wallet][_IdMortage].totalDebt;
        totalMonthlyPay = userToMortgageInterest[_wallet][_IdMortage]
            .totalMonthlyPay;
        totalDelayedMonthlyPay = userToMortgageInterest[_wallet][_IdMortage]
            .totalDelayedMonthlyPay;
        totalToPayOnLiquidation = userToMortgageInterest[_wallet][_IdMortage]
            .totalToPayOnLiquidation;
        lastTimePayment = userToMortgageInterest[_wallet][_IdMortage]
            .lastTimePayment;
        isMonthlyPaymentPayed = userToMortgageInterest[_wallet][_IdMortage]
            .isMonthlyPaymentPayed;
        isMonthlyPaymentDelayed = userToMortgageInterest[_wallet][_IdMortage]
            .isMonthlyPaymentDelayed;
        liquidate = userToMortgageInterest[_wallet][_IdMortage].liquidate;
    }

    function getuserToMortgageInterest(address _wallet, uint256 _IdMortgage)
        public
        view
        returns (MortgageInterest memory mortgageInterest)
    {
        mortgageInterest = userToMortgageInterest[_wallet][_IdMortgage];
        // return (mortgageInterest);
    }

    function addNormalMorgateInterestData(
        address _wallet,
        uint256 _idMortgage,
        MortgageInterest memory _mortgage
    ) public onlymortgage {
        userToMortgageInterest[_wallet][_idMortgage].totalMonthlyPay = _mortgage
            .totalMonthlyPay;
        userToMortgageInterest[_wallet][_idMortgage].amountToPanoram = _mortgage
            .amountToPanoram;
        userToMortgageInterest[_wallet][_idMortgage].amountToPool = _mortgage
            .amountToPool;
        userToMortgageInterest[_wallet][_idMortgage].amountToVault = _mortgage
            .amountToVault;
        userToMortgageInterest[_wallet][_idMortgage].strikes = _mortgage
            .strikes;
        userToMortgageInterest[_wallet][_idMortgage]
            .isMonthlyPaymentPayed = _mortgage.isMonthlyPaymentPayed;
        userToMortgageInterest[_wallet][_idMortgage]
            .isMonthlyPaymentDelayed = _mortgage.isMonthlyPaymentDelayed;
        userToMortgageInterest[_wallet][_idMortgage].lastTimeCalc = _mortgage
            .lastTimeCalc;
    }

    function updateLastTimeCalc(address _wallet, uint256 _idMortgage,uint256 _lastTimeCalc) public {
        userToMortgageInterest[_wallet][_idMortgage].lastTimeCalc = _lastTimeCalc;
    }

    function addDelayedMorgateInterestData(
        address _wallet,
        uint256 _idMortgage,
        MortgageInterest memory _mortgage
    ) public onlymortgage {
        userToMortgageInterest[_wallet][_idMortgage]
            .totalDelayedMonthlyPay = _mortgage.totalDelayedMonthlyPay;
        userToMortgageInterest[_wallet][_idMortgage]
            .amountToPanoramDelayed = _mortgage.amountToPanoramDelayed;
        userToMortgageInterest[_wallet][_idMortgage]
            .amountToPoolDelayed = _mortgage.amountToPoolDelayed;
        userToMortgageInterest[_wallet][_idMortgage].amountToVault = _mortgage
            .amountToVault;
        userToMortgageInterest[_wallet][_idMortgage]
            .totalToPayOnLiquidation = _mortgage.totalToPayOnLiquidation;
        userToMortgageInterest[_wallet][_idMortgage]
            .totalPoolLiquidation = _mortgage.totalPoolLiquidation;
        userToMortgageInterest[_wallet][_idMortgage]
            .totalPanoramLiquidation = _mortgage.totalPanoramLiquidation;
        userToMortgageInterest[_wallet][_idMortgage].strikes = _mortgage
            .strikes;
        userToMortgageInterest[_wallet][_idMortgage]
            .isMonthlyPaymentDelayed = _mortgage.isMonthlyPaymentDelayed;
        userToMortgageInterest[_wallet][_idMortgage].lastTimeCalc = _mortgage
            .lastTimeCalc;
        userToMortgageInterest[_wallet][_idMortgage].liquidate = _mortgage
            .liquidate;
    }

    function updateOnPayMortgageInterest(
        address _wallet,
        uint256 _idMortgage,
        MortgageInterest memory mort
    ) public onlymortgage {
        userToMortgageInterest[_wallet][_idMortgage].totalDebt = mort.totalDebt;
        userToMortgageInterest[_wallet][_idMortgage].totalMonthlyPay = mort
            .totalMonthlyPay;
        userToMortgageInterest[_wallet][_idMortgage].amountToPanoram = mort
            .amountToPanoram;
        userToMortgageInterest[_wallet][_idMortgage].amountToPool = mort
            .amountToPool;
        userToMortgageInterest[_wallet][_idMortgage].amountToVault = mort
            .amountToVault;
        userToMortgageInterest[_wallet][_idMortgage]
            .totalDelayedMonthlyPay = mort.totalDelayedMonthlyPay;
        userToMortgageInterest[_wallet][_idMortgage]
            .amountToPanoramDelayed = mort.amountToPanoramDelayed;
        userToMortgageInterest[_wallet][_idMortgage].amountToPoolDelayed = mort
            .amountToPoolDelayed;
        userToMortgageInterest[_wallet][_idMortgage]
            .totalToPayOnLiquidation = mort.totalToPayOnLiquidation;
        userToMortgageInterest[_wallet][_idMortgage].totalPoolLiquidation = mort
            .totalPoolLiquidation;
        userToMortgageInterest[_wallet][_idMortgage].strikes = mort.strikes;
        userToMortgageInterest[_wallet][_idMortgage]
            .isMonthlyPaymentPayed = mort.isMonthlyPaymentPayed;
        userToMortgageInterest[_wallet][_idMortgage]
            .isMonthlyPaymentDelayed = mort.isMonthlyPaymentDelayed;
    }

    function updateTotalDebtOnAdvancePayment(
        address _wallet,
        uint256 _idMortgage,
        uint256 _totalDebt
    ) public onlymortgage {
        userToMortgageInterest[_wallet][_idMortgage].totalDebt = _totalDebt;
    }


    
    function setMortgageContract(address _mortgage, bool _state) public {
        if (!hasRole(DEV_ROLE, msg.sender)) {
            revert("have no dev role");
        }
        mortgage[_mortgage] = _state;
    }

   
    ///@dev Use this functions only in test, delete when launching official product
    ///@notice Use this function to delete the contract at the end of the tests
    function kill() public {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert("have no admin role");
        }
        address payable addr = payable(address(msg.sender));
        selfdestruct(addr);
    }

    ///@dev only for test erase in production
    function getTestInfo(address _user, uint256 _mortgageId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {   
        LocalVars memory vars;
        vars._user = _user;
        vars._mortgageId = _mortgageId;
        return (
        vars._loan = usermortgage[vars._user][vars._mortgageId].loan,
        vars._downPay = usermortgage[vars._user][vars._mortgageId].downPay,
        vars._startDate = usermortgage[vars._user][vars._mortgageId].startDate,
        vars._period = usermortgage[vars._user][vars._mortgageId].period);
    }

  
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `_msgSender()` is missing `role`.
     * Overriding this function changes the behavior of the {onlyRole} modifier.
     *
     * Format of the revert message is described in {_checkRole}.
     *
     * _Available since v4.6._
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * May emit a {RoleGranted} event.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
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