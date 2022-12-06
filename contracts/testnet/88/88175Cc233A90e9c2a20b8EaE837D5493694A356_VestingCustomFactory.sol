// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Enjinstarter
pragma solidity 0.8.17;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "./interfaces/IFactoryImplementation.sol";
import "./interfaces/IVestingCustomFactory.sol";
import "./AdminPrivileges.sol";

/**
 * @title VestingCustomFactory
 * @author Tim Loh
 */
contract VestingCustomFactory is AdminPrivileges, EIP712, Pausable, IFactoryImplementation, IVestingCustomFactory {
    using Address for address;
    using Clones for address;
    using ECDSA for bytes32;

    struct DeployInfo {
        address implementation;
        address deployedContract;
        bool isInitialized; // true if initialized
    }

    uint256 public constant FACTORY_IMPLEMENTATION_TYPE = 0x616b2eb572eef33549870a0b95b358b8dbf353bf9649ebe3b797f228a633b563;

    uint256 public constant SIGNATURE_LENGTH = 65;
    uint256 public constant TOKEN_DECIMALS_MAX = 18;

    mapping(bytes32 => DeployInfo) private _deployments;
    mapping(address => bool) private _signerAccounts;

    address public backofficeAdminAddress;
    string public factoryName;
    string public factoryVersion;
    address public implementationAddress;

    constructor(string memory name, string memory version)
        EIP712(name, version)
    {
        _setRoleAdmin(BACKOFFICE_ROLE_ADMIN_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);
        _setRoleAdmin(BACKOFFICE_GOVERNANCE_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);
        _setRoleAdmin(BACKOFFICE_CONTRACT_ADMIN_ROLE, BACKOFFICE_ROLE_ADMIN_ROLE);

        _grantRole(BACKOFFICE_ROLE_ADMIN_ROLE, msg.sender);
        _grantRole(BACKOFFICE_GOVERNANCE_ROLE, msg.sender);
        _grantRole(BACKOFFICE_CONTRACT_ADMIN_ROLE, msg.sender);

        factoryName = name;
        factoryVersion = version;
        _signerAccounts[msg.sender] = true;
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function addSignerAccount(address account)
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        require(
            account != address(0),
            "VCF: account"
        );

        if (!isSignerAccount(account)) {
            _signerAccounts[account] = true;
            emit SignerAccountAdded(account, msg.sender);
        }
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function deployWithTypedSignature(
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external virtual override whenNotPaused {
        _deployWithTypedSignature(deployId, name, tokenAddress, tokenDecimals, allowAccumulate, backofficeAdminAddress, tenantAdminAddress, signature);
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function pauseContract()
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        _pause();
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function removeSignerAccount(address account)
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        require(
            account != address(0),
            "VCF: account"
        );

        if (isSignerAccount(account)) {
            _signerAccounts[account] = false;
            emit SignerAccountRemoved(account, msg.sender);
        }
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function setBackofficeAdminAddress(address newBackofficeAdminAddress)
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        require(
            newBackofficeAdminAddress != address(0),
            "VCF: backoffice admin"
        );

        address oldBackofficeAdminAddress = backofficeAdminAddress;
        backofficeAdminAddress = newBackofficeAdminAddress;

        emit BackofficeAdminAddressChanged(oldBackofficeAdminAddress, newBackofficeAdminAddress, msg.sender);
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function setImplementationAddress(address newImplementation)
        external
        virtual
        override
        onlyRole(BACKOFFICE_GOVERNANCE_ROLE)
    {
        require(
            newImplementation != address(0),
            "VCF: new implementation"
        );

        address oldImplementation = implementationAddress;
        implementationAddress = newImplementation;

        emit ImplementationAddressChanged(oldImplementation, newImplementation, msg.sender);

        uint256 implementationType = IFactoryImplementation(newImplementation).FACTORY_IMPLEMENTATION_TYPE();
        require(implementationType == FACTORY_IMPLEMENTATION_TYPE, "VCF: implementation type");
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function unpauseContract()
        external
        virtual
        override
        onlyRole(BACKOFFICE_CONTRACT_ADMIN_ROLE)
    {
        _unpause();
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function deployInfoFor(bytes32 deployId) external view virtual override returns (address implementation, address deployedContract) {
        require(_deployments[deployId].isInitialized, "VCF: uninitialized");

        implementation = _deployments[deployId].implementation;
        deployedContract = _deployments[deployId].deployedContract;
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function isSignerAccount(address account) public view virtual override returns (bool) {
        require(
            account != address(0),
            "VCF: account"
        );

        return _signerAccounts[account];
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function recoverTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external view virtual override returns (address recovered) {
        recovered = _recoverTypedSignature(implementation, deployId, name, tokenAddress, tokenDecimals, allowAccumulate, tenantAdminAddress, signature);
    }

    /**
     * @inheritdoc IVestingCustomFactory
     */
    function verifyTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external view virtual override returns (bool isAuthorized) {
        isAuthorized = _verifyTypedSignature(implementation, deployId, name, tokenAddress, tokenDecimals, allowAccumulate, tenantAdminAddress, signature);
    }

    function _deployWithTypedSignature(
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address backofficeAddress,
        address tenantAdminAddress,
        bytes memory signature
    ) internal virtual {
        require(!_deployments[deployId].isInitialized, "VCF: exists");
        require(backofficeAddress != address(0), "VCF: backoffice address");

        address recovered = _recoverTypedSignature(implementationAddress, deployId, name, tokenAddress, tokenDecimals, allowAccumulate, tenantAdminAddress, signature);
        require(
            isSignerAccount(recovered),
            "VCF: signature"
        );

        bytes memory saltdata = _encodeSaltData(deployId);
        bytes32 salt = keccak256(saltdata);
        address deployedAddress = implementationAddress.cloneDeterministic(salt);
        require(deployedAddress != address(0), "VCF: deployed address");

        _deployments[deployId] = DeployInfo({
            implementation: implementationAddress,
            deployedContract: deployedAddress,
            isInitialized: true
        });

        bytes memory initializeData = _encodeInitializeData(
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAddress,
            tenantAdminAddress
        );

        emit Deployed(
            implementationAddress,
            deployedAddress,
            deployId,
            name,
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAddress,
            tenantAdminAddress,
            recovered
        );

        // https://github.com/crytic/slither/wiki/Detector-Documentation#unused-return
        // slither-disable-next-line unused-return
        deployedAddress.functionCall(initializeData);
    }

    function _recoverTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) internal view virtual returns (address recovered) {
        require(implementation != address(0), "VCF: implementation");
        require(bytes(name).length > 0, "VCF: name");
        require(tokenAddress != address(0), "VCF: token address");
        require(tokenDecimals <= TOKEN_DECIMALS_MAX, "VCF: token decimals");
        require(tenantAdminAddress != address(0), "VCF: tenant address");
        require(signature.length == SIGNATURE_LENGTH, "VCF: signature");

        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "VestingCustom(address implementation,bytes32 deployId,string name,address tokenAddress,uint256 tokenDecimals,bool allowAccumulate,address tenantAdminAddress)"
                    ),
                    implementation,
                    deployId,
                    keccak256(bytes(name)),
                    tokenAddress,
                    tokenDecimals,
                    allowAccumulate,
                    tenantAdminAddress
                )
            )
        );
        recovered = digest.recover(signature);
        require(recovered != address(0), "VCF: recovered");
    }

    function _verifyTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) internal view virtual returns (bool isAuthorized) {
        address recovered = _recoverTypedSignature(implementation, deployId, name, tokenAddress, tokenDecimals, allowAccumulate, tenantAdminAddress, signature);
        isAuthorized = isSignerAccount(recovered);
    }

    function _encodeInitializeData(
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address backofficeAddress,
        address tenantAdminAddress
    ) internal pure virtual returns (bytes memory encodedData) {
        encodedData = abi.encodeWithSignature(
            "initialize(address,uint256,bool,address,address)",
            tokenAddress,
            tokenDecimals,
            allowAccumulate,
            backofficeAddress,
            tenantAdminAddress
        );
    }

    function _encodeSaltData(
        bytes32 deployId
    ) internal pure virtual returns (bytes memory encodedData) {
        encodedData = abi.encodeWithSignature(
            "salt(bytes32)",
            deployId
        );
    }
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Enjinstarter
pragma solidity 0.8.17;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AdminPrivileges
 * @author Tim Loh
 * @notice Provides role definitions that are inherited by other contracts and grants the owner all the defined roles
 */
contract AdminPrivileges is AccessControl {
    bytes32 public constant BACKOFFICE_ROLE_ADMIN_ROLE = keccak256("BACKOFFICE_ROLE_ADMIN_ROLE");
    bytes32 public constant BACKOFFICE_GOVERNANCE_ROLE = keccak256("BACKOFFICE_GOVERNANCE_ROLE");
    bytes32 public constant BACKOFFICE_CONTRACT_ADMIN_ROLE = keccak256("BACKOFFICE_CONTRACT_ADMIN_ROLE");

    bytes32 public constant TENANT_ROLE_ADMIN_ROLE = keccak256("TENANT_ROLE_ADMIN_ROLE");
    bytes32 public constant TENANT_GOVERNANCE_ROLE = keccak256("TENANT_GOVERNANCE_ROLE");
    bytes32 public constant TENANT_CONTRACT_ADMIN_ROLE =
        keccak256("TENANT_CONTRACT_ADMIN_ROLE");
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Enjinstarter
pragma solidity 0.8.17;

/**
 * @title IFactoryImplementation
 * @author Tim Loh
 */
interface IFactoryImplementation {
    // https://github.com/crytic/slither/wiki/Detector-Documentation#conformance-to-solidity-naming-conventions
    // slither-disable-next-line naming-convention
    function FACTORY_IMPLEMENTATION_TYPE() external view returns (uint256);
    // solhint-disable-previous-line func-name-mixedcase
}

// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Enjinstarter
pragma solidity 0.8.17;

/**
 * @title IVestingCustomFactory
 * @author Tim Loh
 */
interface IVestingCustomFactory {
    /**
     * @notice Emitted when backoffice admin address has been changed from `oldBackofficeAdminAddress` to `newBackofficeAdminAddress`
     * @param oldBackofficeAdminAddress The backoffice admin address before the change
     * @param newBackofficeAdminAddress The backoffice admin address after the change
     * @param sender The address that changes the backoffice admin address
     */
    event BackofficeAdminAddressChanged(
        address indexed oldBackofficeAdminAddress,
        address indexed newBackofficeAdminAddress,
        address indexed sender
    );

    /**
     * @notice Emitted when contract has been successfully deployed
     * @param implementation The reference contract implementation address
     * @param deployedContract The address of the deployed contract
     * @param deployId The deploy identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The vesting token decimals
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if multiple grants is not allowed for the same user
     * @param signer The signer address corresponding to the given signature
     */
    event Deployed(
        address indexed implementation,
        address indexed deployedContract,
        bytes32 indexed deployId,
        string name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address backofficeAddress,
        address tenantAddress,
        address signer
    );

    /**
     * @notice Emitted when implementation address has been changed from `oldImplementation` to `newImplementation`
     * @param oldImplementation The implementation address before the change
     * @param newImplementation The implementation address after the change
     * @param sender The address that changes the implementation address
     */
    event ImplementationAddressChanged(
        address indexed oldImplementation,
        address indexed newImplementation,
        address indexed sender
    );

    /**
     * @notice Emitted when signer account has been added
     * @param account The signer account to be added
     * @param sender The address that adds the signer account
     */
    event SignerAccountAdded(address indexed account, address indexed sender);

    /**
     * @notice Emitted when signer account has been removed
     * @param account The signer account to be removed
     * @param sender The address that removes the signer account
     */
    event SignerAccountRemoved(address indexed account, address indexed sender);

    /**
     * @notice Add signer account
     * @dev Must be called by contract admin role
     * @param account The signer account
     */
    function addSignerAccount(address account) external;

    /**
     * @notice Deploy contract based on given typed signature
     * @param deployId The deploy identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The vesting token decimals
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if multiple grants is not allowed for the same user
     * @param tenantAdminAddress The tenant admin address
     * @param signature The typed signature must be from an authorized signer before contract is deployed
     */
    function deployWithTypedSignature(
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external;

    /**
     * @notice Pause user functions (deploy)
     * @dev Must be called by governance role
     */
    function pauseContract() external;

    /**
     * @notice Remove signer account
     * @dev Must be called by contract admin role
     * @param account The signer account
     */
    function removeSignerAccount(address account) external;

    /**
     * @notice Change backoffice admin address to a new address
     * @dev Must be called by contract admin role
     * @param newBackofficeAdminAddress The new backoffice admin address
     */
    function setBackofficeAdminAddress(address newBackofficeAdminAddress) external;

    /**
     * @notice Change implementation to a new address
     * @dev Must be called by governance role
     * @param newImplementation The new implementation address
     */
    function setImplementationAddress(address newImplementation) external;

    /**
     * @notice Unpause user functions (deploy)
     * @dev Must be called by governance role
     */
    function unpauseContract() external;

    /**
     * @notice Get backoffice admin address
     * @return Returns backoffice admin address
     */
    function backofficeAdminAddress() external view returns (address);

    /**
     * @notice Returns deployment info for given deploy identifier
     * @param deployId The deploy identifier
     * @return implementation The reference contract implementation address
     * @return deployedContract The deployed contract address
     */
    function deployInfoFor(bytes32 deployId) external view returns (address implementation, address deployedContract);

    /**
     * @notice Get factory name
     * @return Returns factory name
     */
    function factoryName() external view returns (string memory);

    /**
     * @notice Get factory version
     * @return Returns factory version
     */
    function factoryVersion() external view returns (string memory);

    /**
     * @notice Get reference implementation contract address
     * @return Returns reference implementation contract address
     */
    function implementationAddress() external view returns (address);

    /**
     * @notice Checks whether given `account` is a signer account
     * @return Returns `true` if given `account` is a signer account
     */
    function isSignerAccount(address account) external view returns (bool);

    /**
     * @notice Returns signer of given typed signature
     * @param implementation The reference contract implementation address
     * @param deployId The deploy identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The vesting token decimals
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if multiple grants is not allowed for the same user
     * @param tenantAdminAddress The tenant admin address
     * @param signature The typed signature is verified to be from an authorized signer before contract is deployed
     * @return recovered The signer address
     */
    function recoverTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external view returns (address recovered);

    /**
     * @notice Verifies whether signer of given typed signature is authorized
     * @param implementation The reference contract implementation address
     * @param deployId The deploy identifier
     * @param name The deployment name
     * @param tokenAddress The vesting token address
     * @param tokenDecimals The vesting token decimals
     * @param allowAccumulate `true` if multiple grant amounts is allowed to accumulate for the same user,
     *                        `false` if multiple grants is not allowed for the same user
     * @param tenantAdminAddress The tenant admin address
     * @param signature The typed signature is verified to be from an authorized signer before contract is deployed
     * @return isAuthorized `true` if the signature corresponds to an authorized signer
     */
    function verifyTypedSignature(
        address implementation,
        bytes32 deployId,
        string memory name,
        address tokenAddress,
        uint256 tokenDecimals,
        bool allowAccumulate,
        address tenantAdminAddress,
        bytes memory signature
    ) external view returns (bool isAuthorized);
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

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
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
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
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "./ECDSA.sol";

/**
 * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
 *
 * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,
 * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding
 * they need in their contracts using a combination of `abi.encode` and `keccak256`.
 *
 * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding
 * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
 * ({_hashTypedDataV4}).
 *
 * The implementation of the domain separator was designed to be as efficient as possible while still properly updating
 * the chain id to protect against replay attacks on an eventual fork of the chain.
 *
 * NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
 * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
 *
 * _Available since v3.4._
 */
abstract contract EIP712 {
    /* solhint-disable var-name-mixedcase */
    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to
    // invalidate the cached domain separator if the chain id changes.
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;

    /* solhint-enable var-name-mixedcase */

    /**
     * @dev Initializes the domain separator and parameter caches.
     *
     * The meaning of `name` and `version` is specified in
     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
     *
     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
     * - `version`: the current major version of the signing domain.
     *
     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
     * contract upgrade].
     */
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
    }

    /**
     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
     * function returns the hash of the fully encoded EIP712 message for this domain.
     *
     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:
     *
     * ```solidity
     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
     *     keccak256("Mail(address to,string contents)"),
     *     mailTo,
     *     keccak256(bytes(mailContents))
     * )));
     * address signer = ECDSA.recover(digest, signature);
     * ```
     */
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.3) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            /// @solidity memory-safe-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    /**
     * @dev Returns an Ethereum Signed Typed Data, created from a
     * `domainSeparator` and a `structHash`. This produces hash corresponding
     * to the one signed with the
     * https://eips.ethereum.org/EIPS/eip-712[`eth_signTypedData`]
     * JSON-RPC method as part of EIP-712.
     *
     * See {recover}.
     */
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
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