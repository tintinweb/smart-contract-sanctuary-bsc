// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../functioncall/interface/NonAtomicHiddenAuthParameters.sol";
import "../functioncall/interface/CrosschainFunctionCallInterface.sol";
import "../common/System.sol";

contract PosiBridge is
    NonAtomicHiddenAuthParameters,
    AccessControl,
    Initializable,
    System
{
    // Access role
    bytes32 public constant MAPPING_ROLE = keccak256("MAPPING_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ADMINTRANSFER_ROLE = keccak256("ADMINTRANSFER_ROLE");

    IERC20 erc20token;
    // Simple Function Call bridge.
    CrosschainFunctionCallInterface private crosschainBridge;

    // TODO config: posi chain id
    uint256 posiChainId = 920000;

    // Mapping of destination blockchain to Posi contract address on that blockchain
    // Map (destination blockchain Id => address on remote contract)
    mapping (uint256 => address) private tokenContractAddressMapping;

    // Addresses of ERC 20 bridges on other blockchains.
    mapping(uint256 => address) private remoteErc20Bridges;

    /**
     * Indicates a request to transfer some tokens has occurred on this blockchain.
     *
     * @param _destBcId           Blockchain the tokens are being transferred to.
     * @param _srcTokenContract   Address of the ERC 20 token contract on this blockchain.
     * @param _destTokenContract  Address of the ERC 20 token contract on the blockchain
     *                            the tokens are being transferred to.
     * @param _sender             Address sending the tokens.
     * @param _recipient          Address to transfer the tokens to on the target blockchain.
     * @param _amount             Number of tokens to transfer.
     */
    event TransferTo(
        uint256 _destBcId,
        address _srcTokenContract,
        address _destTokenContract,
        address _sender,
        address _recipient,
        uint256 _amount
    );

    /**
     * Indicates a transfer request has been received on this blockchain.
     *
     * @param _srcBcId            Blockchain the tokens are being transferred from.
     * @param _recipient          Address to transfer the tokens to on the this blockchain.
     * @param _amount             Number of tokens to transfer.
     */
    event ReceivedFrom(
        uint256 _srcBcId,
        address _srcTokenContract,
        address _destTokenContract,
        address _recipient,
        uint256 _amount
    );

    /**
     * Update the mapping between other blockchain id and an ERC 20
     * contract on that blockchain.
     *
     * @param _otherBcId            Blockchain ID where the corresponding ERC 20 contract resides.
     * @param _othercTokenContract  Address of ERC 20 contract on the other blockchain.
     */
    event TokenContractAddressMappingChanged(
        uint256 _otherBcId,
        address _othercTokenContract
    );

    function initialize() public initializer {
        // TODO: can hardcode admin role wallet address
        address sender = _msgSender();
        // NOTE: maybe no need to setupRole
        _setupRole(DEFAULT_ADMIN_ROLE, sender);

        _setupRole(MAPPING_ROLE, sender);
        _setupRole(PAUSER_ROLE, sender);
        _setupRole(ADMINTRANSFER_ROLE, sender);

        crosschainBridge = CrosschainFunctionCallInterface(CROSS_CHAIN_ADDR);
    }

    /**
     * @dev Set token contract address mapping.
     *
     * Requirements:
     * - the caller must have the `MAPPING_ROLE`.
     *
     * @param _otherBcId            Blockchain ID where the corresponding ERC 20 contract resides.
     * @param _otherTokenContract   Address of ERC 20 contract on the other blockchain.
     */
    function setTokenContractAddressMapping(
        uint256 _otherBcId,
        address _otherTokenContract
    ) external {
        require(
            hasRole(MAPPING_ROLE, _msgSender()),
            "ERC20 Bridge: Must have MAPPING role"
        );

        changeContractMappingInternal(
            _otherBcId,
            _otherTokenContract
        );
    }

    /**
     * @dev Unset token contract address mapping.
     *
     * Requirements:
     * - the caller must have the `MAPPING_ROLE`.
     *
     * @param _otherBcId            Blockchain ID where the corresponding ERC 20 contract resides.
     */
    function unsetTokenContractAddressMapping(
        uint256 _otherBcId
    ) external {
        require(
            hasRole(MAPPING_ROLE, _msgSender()),
            "ERC20 Bridge: Must have MAPPING role"
        );

        changeContractMappingInternal(
            _otherBcId,
            address(0)
        );
    }

    /**
     * Connect this ERC20 Bridge contract to an ERC20 Bridge contract on another blockchain.
     *
     * Requirements:
     * - the caller must have the `MAPPING_ROLE`.
     *
     * @param _otherBcId            Blockchain ID where the corresponding ERC 20 bridge contract resides.
     * @param _otherErc20Bridge     Address of ERC 20 Bridge contract on other blockchain.
     */
    function changeBlockchainBridgeMapping(
        uint256 _otherBcId,
        address _otherErc20Bridge
    ) external {
        require(
            hasRole(MAPPING_ROLE, _msgSender()),
            "ERC20 Bridge: Must have MAPPING role"
        );
        remoteErc20Bridges[_otherBcId] = _otherErc20Bridge;
    }

    /**
     * Transfer tokens or coin (in posi chain) from msg.sender to this contract on this blockchain,
     * and request tokens or coin on the remote blockchain be given to the requested
     * account on the destination blockchain.
     *
     * NOTE: msg.sender must have called approve() on the token contract.
     *
     * @param _destBcId         Id of destination blockchain.
     * @param _srcTokenContract Address of ERC 20 contract on this blockchain.
     * @param _recipient        Address of account to transfer tokens to on the destination blockchain.
     * @param _amount           The number of tokens to transfer.
     */
    function transferToOtherBlockchain(
        uint256 _destBcId,
        address _srcTokenContract,
        address _recipient,
        uint256 _amount
    ) public payable {

        address destErc20BridgeContract = remoteErc20Bridges[_destBcId];
        require(
            destErc20BridgeContract != address(0),
            "ERC20 Bridge: Blockchain not supported"
        );

        // The token must be able to be transferred to the target blockchain.
        address destTokenContract = tokenContractAddressMapping[_destBcId];
        // require destTokenContract must exist or if _destBcId == posiChainId then token contract might be address(0)
        require(
            destTokenContract != address(0) || _destBcId == posiChainId,
            "ERC20 Bridge: Token not transferable to requested blockchain"
        );

        // if _srcTokenContract == address(0) then transferring Posi coin
        if (_srcTokenContract == address(0)) {
            require(_amount <= msg.value, "ERC20 Bridge: Transferred value is less than expected amount");
        } else {
            // transfer token from msg.sender to this contract address
            if (
                !IERC20(_srcTokenContract).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                )
            ) {
                revert("transferFrom failed");
            }
        }

        crosschainBridge.crossBlockchainCall(
            _destBcId,
            destErc20BridgeContract,
            abi.encodeWithSelector(
                this.receiveFromOtherBlockchain.selector,
                destTokenContract,
                _recipient,
                _amount
            )
        );

        emit TransferTo(
            _destBcId,
            _srcTokenContract,
            destTokenContract,
            msg.sender,
            _recipient,
            _amount
        );
    }

    /**
     * Transfer tokens/coins that are owned by this contract to a recipient. The tokens have
     * effectively been transferred from another blockchain to this blockchain.
     *
     * @param _destTokenContract  ERC 20 contract of the token being transferred.
     * @param _recipient          Account to transfer ownership of the tokens to.
     * @param _amount             The number of tokens to be transferred.
     */
    function receiveFromOtherBlockchain(
        address _destTokenContract,
        // NOTE: recipient must be payable in case transferring coin
        address payable _recipient,
        uint256 _amount
    ) external {
        require(
            _msgSender() == address(crosschainBridge),
            "ERC20 Bridge: Can not process transfers from contracts other than the bridge contract"
        );

        // Decode and verify sourceBcId and sourceContract
        (
        uint256 sourceBcId,
        address sourceContract
        ) = decodeNonAtomicAuthParams();
        // The source blockchain id is validated at the function call layer. No need to check
        // that it isn't zero.

        require(
            sourceContract != address(0),
            "ERC 20 Bridge: caller contract is 0"
        );
        address remoteErc20Bridge = remoteErc20Bridges[sourceBcId];
        require(
            remoteErc20Bridge != address(0),
            "ERC20 Bridge: No ERC 20 Bridge supported for source blockchain"
        );
        require(
            sourceContract == remoteErc20Bridge,
            "ERC20 Bridge: Incorrect source ERC 20 Bridge"
        );

        // if _destTokenContract == address(0) then transferring Posi coin
        if (_destTokenContract == address(0)) {
            (bool sent,) = _recipient.call{value: _amount}("");
            require(sent, "Failed to send Ether");
        } else {
            if (!IERC20(_destTokenContract).transfer(_recipient, _amount)) {
                revert("transfer failed");
            }
        }

        emit ReceivedFrom(
            sourceBcId,
            sourceContract,
            _destTokenContract,
            _recipient,
            _amount
        );
    }

    /**
     * Indicates whether a token can be transferred to (or from) a blockchain.
     *
     * @param _bcId          Blockchain id of other blockchain.
     * @return bool          True if the token can be transferred to (or from) a blockchain.
     */
    function isBcIdTokenAllowed(uint256 _bcId)
    public
    view
    returns (bool)
    {
        if (_bcId != posiChainId) {
            return address(0) != tokenContractAddressMapping[_bcId];
        } else {
            return true;
        }
    }

    /**
     * Get the ERC 20 contract on a blockchain by blockchain ID.
     *
     * @param _bcId          Blockchain id of other blockchain.
     * @return address       Contract address of ERC 20 token contract on other blockchain.
     */
    function getBcIdTokenMaping(uint256 _bcId)
    public
    view
    returns (address)
    {
        return tokenContractAddressMapping[_bcId];
    }

    /**
     * Get the bridge contract on a blockchain by blockchain ID.
     *
     * @param _bcId          Blockchain id of other blockchain.
     * @return address       Contract address of bridge contract on other blockchain.
     */
    function getRemoteErc20BridgeContract(uint256 _bcId)
    external
    view
    returns (address)
    {
        return remoteErc20Bridges[_bcId];
    }

    function changeContractMappingInternal(
        uint256 _otherBcId,
        address _otherTokenContract
    ) private {
        tokenContractAddressMapping[_otherBcId] = _otherTokenContract;
        emit TokenContractAddressMappingChanged(
            _otherBcId,
            _otherTokenContract
        );
    }

    function updateCBC(address _cbcAddress) public {
        crosschainBridge = CrosschainFunctionCallInterface(_cbcAddress);
    }
}

// SPDX-License-Identifier: MIT

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
        _checkRole(role, _msgSender());
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
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view {
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
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
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
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
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

/*
 * Copyright 2021 ConsenSys AG.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

abstract contract NonAtomicHiddenAuthParameters {
    /**
     * Add authentication parameters to the end of an existing function call.
     *
     * @param _functionCall       Function selector and an arbitrary list of parameters.
     * @param _sourceBlockchainId Blockchain identifier of the blockchain that is calling the function.
     * @param _sourceContract     The address of the contract that is calling the function.
     */
    function encodeNonAtomicAuthParams(
        bytes memory _functionCall,
        uint256 _sourceBlockchainId,
        address _sourceContract
    ) internal pure returns (bytes memory) {
        return
            bytes.concat(
                _functionCall,
                abi.encodePacked(_sourceBlockchainId, _sourceContract)
            );
    }

    /**
     * Extract authentication values from the end of the call data. The parameters are expected to have been
     * added to the end of the function call using encodeNonAtomicAuthParams.
     *
     * @return _sourceBlockchainId Blockchain identifier of the blockchain that is calling the function.
     * @return _sourceContract     The address of the contract that is calling the function.
     */
    function decodeNonAtomicAuthParams()
        internal
        pure
        returns (uint256 _sourceBlockchainId, address _sourceContract)
    {
        bytes calldata allParams = msg.data;
        uint256 len = allParams.length;

        assembly {
            calldatacopy(0x0, sub(len, 52), 32)
            _sourceBlockchainId := mload(0)
            calldatacopy(12, sub(len, 20), 20)
            _sourceContract := mload(0)
        }
    }
}

/*
 * Copyright 2021 ConsenSys Software Inc
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity >=0.8;

/**
 * Crosschain Function Call Interface allows applications to call functions on other blockchains
 * and to get information about the currently executing function call.
 *
 */
interface CrosschainFunctionCallInterface {
    /**
     * Call a function on another blockchain. All function call implementations must implement
     * this function.
     *
     * @param _bcId Blockchain identifier of blockchain to be called.
     * @param _contract The address of the contract to be called.
     * @param _functionCallData The function selector and parameter data encoded using ABI encoding rules.
     */
    function crossBlockchainCall(
        uint256 _bcId,
        address _contract,
        bytes calldata _functionCallData
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.0;

abstract contract System {

    bool public alreadyInit;

    // TODO CHANGE GENESIS ADDRESS
    address public POSITION_ADMIN_ADDR = 0x0000000000000000000000000000000000001001;
    address public GOVERNANCE_HUB_ADDR = 0x0000000000000000000000000000000000001002;
    address public SYSTEM_REWARD_ADDR = 0x0000000000000000000000000000000000001003;
    address public RELAYER_HUB_ADDR = 0x0000000000000000000000000000000000001004;
    address public RELAYER_INCENTIVE_ADDR = 0x0000000000000000000000000000000000001005;

    // NOTE: only init those two address on Posi chain
    address public TOKEN_HUB_ADDR = 0x0000000000000000000000000000000000001006;
    address public CROSS_CHAIN_ADDR = 0x0000000000000000000000000000000000001007;

    modifier onlyPositionAdmin() {
        require(
            msg.sender == POSITION_ADMIN_ADDR,
            "Only Position Admin Address"
        );
        _;
    }

    modifier onlyGovernmentHub() {
        require(
            msg.sender == GOVERNANCE_HUB_ADDR,
            "Only Governance Hub Contract"
        );
        _;
    }

    modifier onlySystemReward() {
        require(
            msg.sender == SYSTEM_REWARD_ADDR,
            "Only System Reward Contract"
        );
        _;
    }

    modifier onlyRelayerHub() {
        require(
            msg.sender == RELAYER_HUB_ADDR,
            "Only Relayer Hub Contract"
        );
        _;
    }

    modifier onlyRelayerIncentive() {
        require(
            msg.sender == RELAYER_INCENTIVE_ADDR,
            "Only Relayer Incentive Contract"
        );
        _;
    }

    modifier onlyTokenHub() {
        require(
            msg.sender == TOKEN_HUB_ADDR,
            "Only Token Hub Contract"
        );
        _;
    }

    modifier onlyCrosschain() {
        require(
            msg.sender == CROSS_CHAIN_ADDR,
            "Only Cross-chain Contract"
        );
        _;
    }

    function updateContractAddress(
        address _POSITION_ADMIN_ADDR,
        address _GOVERNANCE_HUB_ADDR,
        address _SYSTEM_REWARD_ADDR,
        address _RELAYER_HUB_ADDR,
        address _RELAYER_INCENTIVE_ADDR,
        address _TOKEN_HUB_ADDR,
        address _CROSS_CHAIN_ADDR
    ) external {
         POSITION_ADMIN_ADDR = _POSITION_ADMIN_ADDR;
         GOVERNANCE_HUB_ADDR = _GOVERNANCE_HUB_ADDR;
         SYSTEM_REWARD_ADDR = _SYSTEM_REWARD_ADDR;
         RELAYER_HUB_ADDR = _RELAYER_HUB_ADDR;
         RELAYER_INCENTIVE_ADDR = _RELAYER_INCENTIVE_ADDR;
         TOKEN_HUB_ADDR = _TOKEN_HUB_ADDR;
         CROSS_CHAIN_ADDR = _CROSS_CHAIN_ADDR;
    }
}

// SPDX-License-Identifier: MIT

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
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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
}

// SPDX-License-Identifier: MIT

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