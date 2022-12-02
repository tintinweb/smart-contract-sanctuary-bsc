/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// File: safemoon/Safeswap_Periphary_V2/FeeJar.sol


pragma solidity 0.8.11;

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

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}

interface ISafeswapFactory {
    function feeTo() external view returns (address);
}

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
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

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
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {_setupRole}.
     */
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account)
        public
        view
        override
        returns (bool)
    {
        return _roles[role].members[account];
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
     */
    function grantRole(bytes32 role, address account) public virtual override {
        require(
            hasRole(getRoleAdmin(role), _msgSender()),
            "AccessControl: sender must be an admin to grant"
        );

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
     */
    function revokeRole(bytes32 role, address account) public virtual override {
        require(
            hasRole(getRoleAdmin(role), _msgSender()),
            "AccessControl: sender must be an admin to revoke"
        );

        _revokeRole(role, account);
    }

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
    function renounceRole(bytes32 role, address account)
        public
        virtual
        override
    {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
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
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

/**
 * @title FeeJar
 * @dev Allows split SFM SwapRouter Fee
 */
contract FeeJar is AccessControl {
    /// @notice FeeJar Admin role
    bytes32 public constant FEE_JAR_ADMIN_ROLE =
        keccak256("FEE_JAR_ADMIN_ROLE");

    /// @notice Fee setter role
    bytes32 public constant FEE_SETTER_ROLE = keccak256("FEE_SETTER_ROLE");

    /// @notice Network fee (measured in bips: 100 bips = 1% of contract balance)
    uint32 public networkFee;
    uint32 public lpFee;
    uint32 public supportFee;
    uint public maxPercetage = 100;

    address public factory;

    /// @notice Network fee output address
    address public networkFeeCollector;
    address public lpFeeCollector;

    /// @notice Network Fee set event
    event NetworkFeeSet(uint32 indexed newFee, uint32 indexed oldFee);
    /// @notice LP Fee set event
    event LPFeeSet(uint32 indexed newFee, uint32 indexed oldFee);
    /// @notice Support Fee set event
    event SupportFeeSet(uint32 indexed newFee, uint32 indexed oldFee);

    /// @notice Network Fee collector set event
    event NetworFeeCollectorSet(
        address newCollector,
        address oldNetworkFeeCollector
    );

    /// @notice LP Fee collector set event
    event LPFeeCollectorSet(address newCollector, address oldLPFeeCollector);

    /// @notice Fee event
    event Fee(
        address indexed feePayer,   // tx.origin
        uint256 feeAmount,          // msg.value
        uint256 networkFeeAmount,   // networkFeeAmount
        uint256 lpFeeAmount,        // lpFeeAmount
        uint256 supportFeeAmount,   // supportFeeAmount
        address networkFeeCollector, // networkFeeCollector
        address supportFeeCollector, // supportFeeCollector
        address lpFeeCollector      // lpFeeCollector
    );

    /// @notice modifier to restrict functions to admins
    modifier onlyAdmin() {
        require(
            hasRole(FEE_JAR_ADMIN_ROLE, msg.sender),
            "Caller must have FEE_JAR_ADMIN_ROLE role"
        );
        _;
    }

    /// @notice modifier to restrict functions to fee setters
    modifier onlyFeeSetter() {
        require(
            hasRole(FEE_SETTER_ROLE, msg.sender),
            "Caller must have FEE_SETTER_ROLE role"
        );
        _;
    }

    /// @notice Initializes contract, setting admin roles + network fee
    /// @param _feeJarAdmin admin of fee pool
    /// @param _feeSetter fee setter address
    /// @param _networkFeeCollector address that collects network fees
    /// @param _networkFee % of fee collected by the network
    function initialize(
        address _feeJarAdmin,
        address _feeSetter,
        address _networkFeeCollector,
        address _lpFeeCollector,
        address _factory,
        uint32 _networkFee,
        uint32 _lpFee,
        uint32 _supportFee
    ) public {
        // addresses validation!
        require(
            _networkFeeCollector != address(0) &&
            _lpFeeCollector != address(0) &&
            _feeJarAdmin != address(0) &&
            _feeSetter != address(0)&&
            _factory != address(0)
            , "FEEJAR: PLEASE ENTER VALID ADDRESSES");

        // fees validation
        require(
            _networkFee <= maxPercetage &&
            _lpFee <= maxPercetage &&
            _supportFee <= maxPercetage,
            "FEEJAR: INCORRECT FEES VALUES"
        );

        _setRoleAdmin(FEE_JAR_ADMIN_ROLE, FEE_JAR_ADMIN_ROLE);
        _setRoleAdmin(FEE_SETTER_ROLE, FEE_JAR_ADMIN_ROLE);
        _setupRole(FEE_JAR_ADMIN_ROLE, _feeJarAdmin);
        _setupRole(FEE_SETTER_ROLE, _feeSetter);
        networkFeeCollector = _networkFeeCollector;
        lpFeeCollector = _lpFeeCollector;
        networkFee = _networkFee;
        emit NetworkFeeSet(_networkFee, 0);
        lpFee = _lpFee;
        emit LPFeeSet(_lpFee, 0);
        supportFee = _supportFee;
        emit SupportFeeSet(_supportFee, 0);
        factory = _factory;
    }

    /// @notice Receive function to allow contract to accept ETH
    receive() external payable {}

    /// @notice Fallback function to allow contract to accept ETH
    fallback() external payable {}

    /**
     * @notice Return fees amount based on the total fee
     * @param totalFee total fee
     */
    function getFeeAmount(uint256 totalFee)
        public
        view
        returns (
            uint256 networkFeeAmount,
            uint256 lpFeeAmount,
            uint256 supportFeeAmount
        )
    {
        if (networkFee > 0) {
            networkFeeAmount = (totalFee * networkFee) / maxPercetage;
        }
        if (lpFee > 0) {
            lpFeeAmount = (totalFee * lpFee) / maxPercetage;
        }
        if (supportFee > 0) {
            supportFeeAmount = (totalFee * supportFee) / maxPercetage;
        }
    }

    /**
     * @notice Distributes any ETH in contract to relevant parties
     */
    function fee() public payable returns(uint, uint, uint) {
        (
            uint256 networkFeeAmount,
            uint256 supportFeeAmount,
            uint256 lpFeeAmount
        ) = getFeeAmount(address(this).balance);
        address supportFeeCollector;

        if (networkFee > 0) {
            (bool networkFeeSuccess, ) = networkFeeCollector.call{
                value: networkFeeAmount
            }("");
            require(
                networkFeeSuccess,
                "Swap Fee: Could not collect network fee"
            );
        }

        if (supportFee > 0) {
            supportFeeCollector = ISafeswapFactory(factory).feeTo();
            bool feeOn = supportFeeCollector != address(0);
            if (feeOn) {
                (bool supportFeeSuccess, ) = supportFeeCollector.call{
                    value: supportFeeAmount
                }("");
                require(
                    supportFeeSuccess,
                    "Swap Fee: Could not collect support fee"
                );
            }
        }

        if (address(this).balance > 0) {
            uint256 lpAmount = address(this).balance;
            (bool success, ) = lpFeeCollector.call{value: lpAmount}("");
            require(success, "Swap Fee: Could not collect LP ETH");
        }

        /// @notice Fee event
        emit Fee(
            tx.origin,   // tx.origin
            msg.value,          // msg.value
            networkFeeAmount,   // networkFeeAmount
            lpFeeAmount,        // lpFeeAmount
            supportFeeAmount,   // supportFeeAmount
            networkFeeCollector, // networkFeeCollector
            supportFeeCollector, // supportFeeCollector
            networkFeeCollector      // lpFeeCollector
        );
        
        return (networkFeeAmount, supportFeeAmount, lpFeeAmount);
    }

    /**
     * @notice Admin function to set network fee
     * @param newFee new fee
     */
    function setNetworkFee(uint32 newFee) external onlyFeeSetter {
        require(newFee <= maxPercetage, ">100%");
        emit NetworkFeeSet(newFee, networkFee);
        networkFee = newFee;
    }

    /**
     * @notice Admin function to set LP fee
     * @param newFee new fee
     */
    function setLPFee(uint32 newFee) external onlyFeeSetter {
        require(newFee <= maxPercetage, ">100%");
        emit LPFeeSet(newFee, lpFee);
        lpFee = newFee;
    }

    /**
     * @notice Admin function to set support fee
     * @param newFee new fee
     */
    function setSupportFee(uint32 newFee) external onlyFeeSetter {
        require(newFee <= maxPercetage, ">100%");
        emit SupportFeeSet(newFee, supportFee);
        supportFee = newFee;
    }

    /**
     * @notice Admin function to set network fee collector address
     * @param newCollector new fee collector address
     */
    function setNetworkFeeCollector(address newCollector) external onlyAdmin {
        emit NetworFeeCollectorSet(newCollector, networkFeeCollector);
        networkFeeCollector = newCollector;
    }

    /**
     * @notice Admin function to set Lp fee collector address
     * @param newCollector new fee collector address
     */
    function setLPFeeCollector(address newCollector) external onlyAdmin {
        emit LPFeeCollectorSet(newCollector, lpFeeCollector);
        lpFeeCollector = newCollector;
    }
}