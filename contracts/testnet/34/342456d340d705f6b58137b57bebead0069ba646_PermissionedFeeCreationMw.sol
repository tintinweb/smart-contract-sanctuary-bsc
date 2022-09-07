// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { Address } from "openzeppelin-contracts/contracts/utils/Address.sol";

import { IProfileMiddleware } from "../../interfaces/IProfileMiddleware.sol";

import { Constants } from "../../libraries/Constants.sol";
import { DataTypes } from "../../libraries/DataTypes.sol";

import { EIP712 } from "../../base/EIP712.sol";
import { PermissionedMw } from "../base/PermissionedMw.sol";
import { FeeMw } from "../base/FeeMw.sol";

/**
 * @title Permissioned Fee Creation Middleware
 * @author CyberConnect
 * @notice This contract is a middleware to create permissioned fee.
 */
contract PermissionedFeeCreationMw is
    IProfileMiddleware,
    EIP712,
    PermissionedMw,
    FeeMw
{
    event SetFeeByTier(
        address indexed namespace,
        Tier tier,
        uint256 indexed amount
    );

    /*//////////////////////////////////////////////////////////////
                                STATES
    //////////////////////////////////////////////////////////////*/

    struct MiddlewareData {
        address signer;
        address recipient;
        mapping(address => uint256) nonces;
        mapping(Tier => uint256) feeMapping;
    }

    enum Tier {
        Tier0,
        Tier1,
        Tier2,
        Tier3,
        Tier4,
        Tier5,
        Tier6
    }

    mapping(address => MiddlewareData) internal _mwDataByNamespace;

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks that the namespace is valid.
     */
    modifier onlyValidNamespace(address namespace) {
        address mwData = _mwDataByNamespace[namespace].recipient;
        require(mwData != address(0), "INVALID_NAMESPACE");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address engine, address treasury)
        PermissionedMw(engine)
        FeeMw(treasury)
    {}

    /*//////////////////////////////////////////////////////////////
                                 EXTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @inheritdoc IProfileMiddleware
    function preProcess(
        DataTypes.CreateProfileParams calldata params,
        bytes calldata data
    ) external payable override onlyValidNamespace(msg.sender) {
        MiddlewareData storage mwData = _mwDataByNamespace[msg.sender];

        (uint8 v, bytes32 r, bytes32 s, uint256 deadline) = abi.decode(
            data,
            (uint8, bytes32, bytes32, uint256)
        );

        _requiresValidHandle(params.handle);
        _requiresEnoughFee(msg.sender, params.handle, msg.value);
        _requiresValidSig(params, v, r, s, deadline, mwData);

        uint256 treasuryCollected = (msg.value * _treasuryFee()) /
            Constants._MAX_BPS;
        uint256 actualCollected = msg.value - treasuryCollected;

        Address.sendValue(payable(mwData.recipient), actualCollected);
        if (treasuryCollected > 0) {
            Address.sendValue(payable(_treasuryAddress()), treasuryCollected);
        }
    }

    /// @inheritdoc IProfileMiddleware
    function postProcess(
        DataTypes.CreateProfileParams calldata params,
        bytes calldata data
    ) external override {
        // do nothing
    }

    /// @inheritdoc IProfileMiddleware
    function setProfileMwData(address namespace, bytes calldata data)
        external
        override
        onlyEngine
        returns (bytes memory)
    {
        (
            address signer,
            address recipient,
            uint256 tier0Fee,
            uint256 tier1Fee,
            uint256 tier2Fee,
            uint256 tier3Fee,
            uint256 tier4Fee,
            uint256 tier5Fee,
            uint256 tier6Fee
        ) = abi.decode(
                data,
                (
                    address,
                    address,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256
                )
            );

        require(
            signer != address(0) && recipient != address(0),
            "INVALID_SIGNER_OR_RECIPIENT"
        );

        _setFeeByTier(namespace, Tier.Tier0, tier0Fee);
        _setFeeByTier(namespace, Tier.Tier1, tier1Fee);
        _setFeeByTier(namespace, Tier.Tier2, tier2Fee);
        _setFeeByTier(namespace, Tier.Tier3, tier3Fee);
        _setFeeByTier(namespace, Tier.Tier4, tier4Fee);
        _setFeeByTier(namespace, Tier.Tier5, tier5Fee);
        _setFeeByTier(namespace, Tier.Tier6, tier6Fee);

        _mwDataByNamespace[namespace].signer = signer;
        _mwDataByNamespace[namespace].recipient = recipient;

        return data;
    }

    /*//////////////////////////////////////////////////////////////
                            EXTERNAL VIEW
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Gets the signer address.
     *
     * @param namespace The namespace address.
     * @return address The signer address.
     */
    function getSigner(address namespace) external view returns (address) {
        return _mwDataByNamespace[namespace].signer;
    }

    /**
     * @notice Gets the recipient address.
     *
     * @param namespace The namespace address.
     * @return address The recipient address.
     */
    function getRecipient(address namespace) external view returns (address) {
        return _mwDataByNamespace[namespace].recipient;
    }

    /**
     * @notice Gets the nonce of the address.
     *
     * @param namespace The namespace address.
     * @param user The user address.
     * @return uint256 The nonce.
     */
    function getNonce(address namespace, address user)
        external
        view
        returns (uint256)
    {
        return _mwDataByNamespace[namespace].nonces[user];
    }

    /**
     * @notice Gets the tier's fee.
     *
     * @param namespace The namespace address.
     * @param tier The tier.
     * @return uint256 The fee amount.
     */
    function getFeeByTier(address namespace, Tier tier)
        external
        view
        returns (uint256)
    {
        return _mwDataByNamespace[namespace].feeMapping[tier];
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _setFeeByTier(
        address namespace,
        Tier tier,
        uint256 amount
    ) internal {
        _mwDataByNamespace[namespace].feeMapping[tier] = amount;
        emit SetFeeByTier(namespace, tier, amount);
    }

    function _requiresEnoughFee(
        address namespace,
        string calldata handle,
        uint256 amount
    ) internal view {
        bytes memory byteHandle = bytes(handle);
        MiddlewareData storage mwData = _mwDataByNamespace[namespace];
        uint256 fee = mwData.feeMapping[Tier.Tier6];

        if (byteHandle.length < 7) {
            fee = mwData.feeMapping[Tier(byteHandle.length - 1)];
        }
        require(amount >= fee, "INSUFFICIENT_FEE");
    }

    function _requiresValidHandle(string calldata handle) internal pure {
        bytes memory byteHandle = bytes(handle);
        require(
            byteHandle.length <= Constants._MAX_HANDLE_LENGTH &&
                byteHandle.length > 0,
            "HANDLE_INVALID_LENGTH"
        );

        uint256 byteHandleLength = byteHandle.length;
        for (uint256 i = 0; i < byteHandleLength; ) {
            bytes1 b = byteHandle[i];
            require(
                (b >= "0" && b <= "9") || (b >= "a" && b <= "z") || b == "_",
                "HANDLE_INVALID_CHARACTER"
            );
            unchecked {
                ++i;
            }
        }
    }

    function _domainSeparatorName()
        internal
        pure
        override
        returns (string memory)
    {
        return "PermissionedFeeCreationMw";
    }

    function _requiresValidSig(
        DataTypes.CreateProfileParams calldata params,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 deadline,
        MiddlewareData storage mwData
    ) internal {
        _requiresExpectedSigner(
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        Constants._CREATE_PROFILE_TYPEHASH,
                        params.to,
                        keccak256(bytes(params.handle)),
                        keccak256(bytes(params.avatar)),
                        keccak256(bytes(params.metadata)),
                        params.operator,
                        mwData.nonces[params.to]++,
                        deadline
                    )
                )
            ),
            mwData.signer,
            v,
            r,
            s,
            deadline
        );
    }
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface IProfileMiddleware {
    /**
     * @notice Sets namespace related data for middleware.
     *
     * @param namespace The related namespace address.
     * @param data Extra data to set.
     */
    function setProfileMwData(address namespace, bytes calldata data)
        external
        returns (bytes memory);

    /**
     * @notice Process that runs before the profileNFT creation happens.
     *
     * @param params The params for creating profile.
     * @param data Extra data to process.
     */
    function preProcess(
        DataTypes.CreateProfileParams calldata params,
        bytes calldata data
    ) external payable;

    /**
     * @notice Process that runs after the profileNFT creation happens.
     *
     * @param params The params for creating profile.
     * @param data Extra data to process.
     */
    function postProcess(
        DataTypes.CreateProfileParams calldata params,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

library Constants {
    // Access Control for CyberEngine
    uint8 internal constant _ENGINE_GOV_ROLE = 1;
    bytes4 internal constant _AUTHORIZE_UPGRADE =
        bytes4(keccak256(bytes("_authorizeUpgrade(address)")));

    // EIP712 TypeHash
    bytes32 internal constant _PERMIT_TYPEHASH =
        keccak256(
            "permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CREATE_PROFILE_TYPEHASH =
        keccak256(
            "createProfile(address to,string handle,string avatar,string metadata,address operator,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SUBSCRIBE_TYPEHASH =
        keccak256(
            "subscribeWithSig(uint256[] profileIds,bytes[] preDatas,bytes[] postDatas,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _COLLECT_TYPEHASH =
        keccak256(
            "collectWithSig(address collector,uint256 profileId,uint256 essenceId,bytes data,bytes postDatas,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _REGISTER_ESSENCE_TYPEHASH =
        keccak256(
            "registerEssenceWithSig(uint256 profileId,string name,string symbol,string essenceTokenURI,address essenceMw,bool transferable,bytes initData,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_METADATA_TYPEHASH =
        keccak256(
            "setMetadataWithSig(uint256 profileId,string metadata,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_OPERATOR_APPROVAL_TYPEHASH =
        keccak256(
            "setOperatorApprovalWithSig(uint256 profileId,address operator,bool approved,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_SUBSCRIBE_DATA_TYPEHASH =
        keccak256(
            "setSubscribeDataWithSig(uint256 profileId,string tokenURI,address mw,bytes data,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_ESSENCE_DATA_TYPEHASH =
        keccak256(
            "setEssenceDataWithSig(uint256 profileId,uint256 essenceId,string tokenURI,address mw,bytes data,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_AVATAR_TYPEHASH =
        keccak256(
            "setAvatarWithSig(uint256 profileId,string avatar,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _SET_PRIMARY_PROFILE_TYPEHASH =
        keccak256(
            "setPrimaryProfileWithSig(uint256 profileId,uint256 nonce,uint256 deadline)"
        );
    bytes32 internal constant _CLAIM_BOX_TYPEHASH =
        keccak256("claimBox(address to,uint256 nonce,uint256 deadline)");
    bytes32 internal constant _CLAIM_TYPEHASH =
        keccak256(
            "claim(uint256 profileId,address to,address currency,uint256 amount,uint256 nonce,uint256 deadline)"
        );

    // Parameters
    uint8 internal constant _MAX_HANDLE_LENGTH = 20;
    uint8 internal constant _MAX_NAME_LENGTH = 20;
    uint8 internal constant _MAX_SYMBOL_LENGTH = 20;
    uint16 internal constant _MAX_URI_LENGTH = 2000;
    uint16 internal constant _MAX_BPS = 10000;

    // Access Control for UpgradeableBeacon
    bytes4 internal constant _BEACON_UPGRADE_TO =
        bytes4(keccak256(bytes("upgradeTo(address)")));

    // Subscribe NFT
    string internal constant _SUBSCRIBE_NFT_NAME_SUFFIX = "_subscriber";
    string internal constant _SUBSCRIBE_NFT_SYMBOL_SUFFIX = "_SUB";
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

library DataTypes {
    struct EIP712Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }

    struct CreateProfileParams {
        address to;
        string handle;
        string avatar;
        string metadata;
        address operator;
    }

    struct CreateProfilePostProcessData {
        uint256 tokenID;
        bytes32 handleHash;
        address profileMw;
    }

    struct CreateNamespaceParams {
        string name;
        string symbol;
        address owner;
        ComputedAddresses addrs;
    }

    struct RegisterEssenceParams {
        uint256 profileId;
        string name;
        string symbol;
        string essenceTokenURI;
        address essenceMw;
        bool transferable;
        bool deployAtRegister;
    }

    struct SubscribeParams {
        uint256[] profileIds;
    }

    struct CollectParams {
        address collector;
        uint256 profileId;
        uint256 essenceId;
    }

    struct RegisterEssenceData {
        uint256 profileId;
        string name;
        string symbol;
        string essenceTokenURI;
        bytes initData;
        address essenceMw;
        bool transferable;
        bool deployAtRegister;
        address essBeacon;
    }

    struct SubscribeData {
        address sender;
        uint256[] profileIds;
        bytes[] preDatas;
        bytes[] postDatas;
        address subBeacon;
        address engine;
    }

    struct CollectData {
        address collector;
        uint256 profileId;
        uint256 essenceId;
        bytes preData;
        bytes postData;
        address essBeacon;
        address engine;
    }

    struct ProfileStruct {
        string handle;
        string avatar;
        uint256 essenceCount;
    }

    struct SubscribeStruct {
        string tokenURI;
        address subscribeNFT;
        address subscribeMw;
    }

    struct EssenceStruct {
        address essenceNFT;
        address essenceMw;
        string name;
        string symbol;
        string tokenURI;
        bool transferable;
    }

    struct NamespaceStruct {
        address profileMw;
        string name;
    }

    struct ConstructTokenURIParams {
        uint256 tokenId;
        string handle;
        uint256 subscribers;
    }

    struct ComputedAddresses {
        address profileProxy;
        address profileFactory;
        address subscribeFactory;
        address essenceFactory;
    }

    struct ProfileDeployParameters {
        address engine;
        address subBeacon;
        address essenceBeacon;
    }

    struct SubscribeDeployParameters {
        address profileProxy;
    }

    struct EssenceDeployParameters {
        address profileProxy;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

abstract contract EIP712 {
    /*//////////////////////////////////////////////////////////////
                                STATES
    //////////////////////////////////////////////////////////////*/
    bytes32 internal constant _HASHED_VERSION = keccak256("1");
    bytes32 private constant _TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );

    /*//////////////////////////////////////////////////////////////
                            PUBLIC VIEW
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the contract's {EIP712} domain separator.
     *
     * @return bytes32 the contract's {EIP712} domain separator.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _TYPE_HASH,
                    keccak256(bytes(_domainSeparatorName())),
                    _HASHED_VERSION,
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _requiresExpectedSigner(
        bytes32 digest,
        address expectedSigner,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 deadline
    ) internal view {
        require(deadline >= block.timestamp, "DEADLINE_EXCEEDED");
        require(
            uint256(s) <=
                0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "INVALID_SIGNATURE_S_VAULE"
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress == expectedSigner, "INVALID_SIGNATURE");
    }

    function _requiresExpectedSigner(
        bytes32 digest,
        address expectedSigner,
        DataTypes.EIP712Signature calldata sig
    ) internal view {
        _requiresExpectedSigner(
            digest,
            expectedSigner,
            sig.v,
            sig.r,
            sig.s,
            sig.deadline
        );
    }

    function _hashTypedDataV4(bytes32 structHash)
        internal
        view
        virtual
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
            );
    }

    function _domainSeparatorName()
        internal
        view
        virtual
        returns (string memory);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ICyberEngine } from "../../interfaces/ICyberEngine.sol";

abstract contract PermissionedMw {
    /*//////////////////////////////////////////////////////////////
                                STATES
    //////////////////////////////////////////////////////////////*/
    address public immutable ENGINE; // solhint-disable-line

    /*//////////////////////////////////////////////////////////////
                              MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Checks that the sender is the engine address.
     */
    modifier onlyEngine() {
        require(ENGINE == msg.sender, "NON_ENGINE_ADDRESS");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                 CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address engine) {
        require(engine != address(0), "ENGINE_ADDRESS_ZERO");
        ENGINE = engine;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ITreasury } from "../../interfaces/ITreasury.sol";

abstract contract FeeMw {
    /*//////////////////////////////////////////////////////////////
                              STATES
    //////////////////////////////////////////////////////////////*/
    address public immutable TREASURY; // solhint-disable-line

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address treasury) {
        require(treasury != address(0), "ZERO_TREASURY_ADDRESS");
        TREASURY = treasury;
    }

    /*//////////////////////////////////////////////////////////////
                              INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _currencyAllowed(address currency) internal view returns (bool) {
        return ITreasury(TREASURY).isCurrencyAllowed(currency);
    }

    function _treasuryAddress() internal view returns (address) {
        return ITreasury(TREASURY).getTreasuryAddress();
    }

    function _treasuryFee() internal view returns (uint256) {
        return ITreasury(TREASURY).getTreasuryFee();
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { RolesAuthority } from "../dependencies/solmate/RolesAuthority.sol";

import { ICyberEngineEvents } from "../interfaces/ICyberEngineEvents.sol";

import { DataTypes } from "../libraries/DataTypes.sol";

interface ICyberEngine is ICyberEngineEvents {
    /**
     * @notice Initializes the CyberEngine.
     *
     * @param _owner Owner to set for CyberEngine.
     * @param _rolesAuthority RolesAuthority address to manage access control
     */
    function initialize(address _owner, RolesAuthority _rolesAuthority)
        external;

    /**
     * @notice Allows the profile middleware.
     *
     * @param mw The middleware address.
     * @param allowed The allowance state.
     */
    function allowProfileMw(address mw, bool allowed) external;

    /**
     * @notice Allows the subscriber middleware.
     *
     * @param mw The middleware address.
     * @param allowed The allowance state.
     */
    function allowSubscribeMw(address mw, bool allowed) external;

    /**
     * @notice Allows the essence middleware.
     *
     * @param mw The middleware address.
     * @param allowed The allowance state.
     */
    function allowEssenceMw(address mw, bool allowed) external;

    /**
     * @notice Creates a new namespace.
     *
     * @param params The namespace params:
     *  name: The namespace name.
     *  symbol: The namespace symbol.
     *  owner: The namespace owner.
     * @return profileProxy The profile proxy address.
     * @return subBeacon The Subscribe beacon address.
     * @return essBeacon The Essence beacon address.
     */
    function createNamespace(DataTypes.CreateNamespaceParams calldata params)
        external
        returns (
            address profileProxy,
            address subBeacon,
            address essBeacon
        );

    /**
     * @notice Upgrade SubscribeNFT to new version by namespace.
     *
     * @param newImpl The new SubscribeNFT implementation address.
     * @param namespace The namespace to upgrade.
     */
    function upgradeSubscribeNFT(address newImpl, address namespace) external;

    /**
     * @notice Upgrade EssenceNFT to new version by namespace.
     *
     * @param newImpl The new EssenceNFT implementation address.
     * @param namespace The namespace to upgrade.
     */
    function upgradeEssenceNFT(address newImpl, address namespace) external;

    /**
     * @notice Upgrade ProfileNFT to new version.
     *
     * @param newImpl The new ProfileNFT implementation address.
     * @param namespace The namespace to upgrade.
     */
    function upgradeProfileNFT(address newImpl, address namespace) external;

    /**
     * @notice Sets the profile middleware.
     *
     * @param namespace The namespace address.
     * @param mw The middleware address.
     * @param data The middleware data.
     * @dev the profile middleware needs to be allowed first.
     */
    function setProfileMw(
        address namespace,
        address mw,
        bytes calldata data
    ) external;

    /**
     * @notice Gets the profile name by the namespace.
     *
     * @param namespace The namespace address.
     * @return string The profile name.
     */
    function getNameByNamespace(address namespace)
        external
        view
        returns (string memory);

    /**
     * @notice Gets the profile middleware by the namespace.
     *
     * @param namespace The namespace address.
     * @return address The middleware name.
     */
    function getProfileMwByNamespace(address namespace)
        external
        view
        returns (address);

    /**
     * @notice Checks if the essence middleware is allowed.
     *
     * @param mw The middleware address.
     * @return bool The allowance state.
     */
    function isEssenceMwAllowed(address mw) external view returns (bool);

    /**
     * @notice Checks if the subscriber middleware is allowed.
     *
     * @param mw The middleware address.
     * @return bool The allowance state.
     */
    function isSubscribeMwAllowed(address mw) external view returns (bool);

    /**
     * @notice Checks if the profile middleware is allowed.
     *
     * @param mw The middleware address.
     * @return bool The allowance state.
     */
    function isProfileMwAllowed(address mw) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { ITreasuryEvents } from "../interfaces/ITreasuryEvents.sol";

interface ITreasury is ITreasuryEvents {
    /**
     * @notice Gets the treasury address.
     *
     * @return address The treasury address.
     */
    function getTreasuryAddress() external view returns (address);

    /**
     * @notice Gets the treasury fee. The percentage is calculated as: treasuryFee/_MAX_BPS.
     *
     * @return address The treasury fee.
     */
    function getTreasuryFee() external view returns (uint256);

    /**
     * @notice Checks if the currency is allowed.
     *
     * @return bool The status of allowance for the currency.
     */
    function isCurrencyAllowed(address currency) external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import { Auth, Authority } from "./Auth.sol";
import { Initializable } from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @notice Adapted from Solmate's RolesAuthority.sol using Auth's initializer instead of constructor.

/// @notice Role based Authority that supports up to 256 roles.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)
contract RolesAuthority is Initializable, Auth, Authority {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);

    event PublicCapabilityUpdated(address indexed target, bytes4 indexed functionSig, bool enabled);

    event RoleCapabilityUpdated(uint8 indexed role, address indexed target, bytes4 indexed functionSig, bool enabled);

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _owner, Authority _authority) initializer {
        Auth.__Auth_Init(_owner, _authority);
    }

    /*//////////////////////////////////////////////////////////////
                            ROLE/USER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bytes32) public getUserRoles;

    mapping(address => mapping(bytes4 => bool)) public isCapabilityPublic;

    mapping(address => mapping(bytes4 => bytes32)) public getRolesWithCapability;

    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {
        return (uint256(getUserRoles[user]) >> role) & 1 != 0;
    }

    function doesRoleHaveCapability(
        uint8 role,
        address target,
        bytes4 functionSig
    ) public view virtual returns (bool) {
        return (uint256(getRolesWithCapability[target][functionSig]) >> role) & 1 != 0;
    }

    /*//////////////////////////////////////////////////////////////
                           AUTHORIZATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) public view virtual override returns (bool) {
        return
            isCapabilityPublic[target][functionSig] ||
            bytes32(0) != getUserRoles[user] & getRolesWithCapability[target][functionSig];
    }

    /*//////////////////////////////////////////////////////////////
                   ROLE CAPABILITY CONFIGURATION LOGIC
    //////////////////////////////////////////////////////////////*/

    function setPublicCapability(
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        isCapabilityPublic[target][functionSig] = enabled;

        emit PublicCapabilityUpdated(target, functionSig, enabled);
    }

    function setRoleCapability(
        uint8 role,
        address target,
        bytes4 functionSig,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getRolesWithCapability[target][functionSig] |= bytes32(1 << role);
        } else {
            getRolesWithCapability[target][functionSig] &= ~bytes32(1 << role);
        }

        emit RoleCapabilityUpdated(role, target, functionSig, enabled);
    }

    /*//////////////////////////////////////////////////////////////
                       USER ROLE ASSIGNMENT LOGIC
    //////////////////////////////////////////////////////////////*/

    function setUserRole(
        address user,
        uint8 role,
        bool enabled
    ) public virtual requiresAuth {
        if (enabled) {
            getUserRoles[user] |= bytes32(1 << role);
        } else {
            getUserRoles[user] &= ~bytes32(1 << role);
        }

        emit UserRoleUpdated(user, role, enabled);
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface ICyberEngineEvents {
    /**
     * @notice Emiited when the engine is initialized
     *
     * @param owner The address of the engine owner.
     * @param rolesAuthority The address of the role authority.
     */
    event Initialize(address indexed owner, address indexed rolesAuthority);

    /**
     * @notice Emitted when a profile middleware has been allowed.
     *
     * @param mw The middleware address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowProfileMw(
        address indexed mw,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a profile middleware has been set.
     *
     * @param namespace The namespace address.
     * @param mw The middleware address.
     * @param returnData The profile middeware data.
     */
    event SetProfileMw(address indexed namespace, address mw, bytes returnData);

    /**
     * @notice Emitted when a subscription middleware has been allowed.
     *
     * @param mw The middleware address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowSubscribeMw(
        address indexed mw,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a essence middleware has been allowed.
     *
     * @param mw The middleware address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowEssenceMw(
        address indexed mw,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a namespace has been created
     *
     * @param namespace The namespace address.
     * @param name The namespace name.
     * @param symbol The namespace symbol.
     */
    event CreateNamespace(
        address indexed namespace,
        string name,
        string symbol
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity 0.8.14;

import { DataTypes } from "../libraries/DataTypes.sol";

interface ITreasuryEvents {
    /**
     * @notice Emitted when a currency has been allowed.
     *
     * @param currency The ERC20 token contract address.
     * @param preAllowed The previously allow state.
     * @param newAllowed The newly set allow state.
     */
    event AllowCurrency(
        address indexed currency,
        bool indexed preAllowed,
        bool indexed newAllowed
    );

    /**
     * @notice Emitted when a new treasuryAddress has been set.
     *
     * @param preTreasuryAddress The previous treasuryAddress.
     * @param treasuryAddress The new treasuryAddress.
     */
    event SetTreasuryAddress(
        address indexed preTreasuryAddress,
        address indexed treasuryAddress
    );

    /**
     * @notice Emitted when a new treasuryFee has been set.
     *
     * @param preTreasuryFee The previous treasuryFee.
     * @param treasuryFee The new treasuryFee.
     */
    event SetTreasuryFee(
        uint16 indexed preTreasuryFee,
        uint16 indexed treasuryFee
    );
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.8.0;

import { Initializable } from "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

/// @notice Adapted from Solmate's Auth.sol with initializer replacing the constructor.

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth is Initializable {
    event OwnerUpdated(address indexed user, address indexed newOwner);

    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);

    address public owner;

    Authority public authority;

    function __Auth_Init(address _owner, Authority _authority) internal onlyInitializing {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }

    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.

        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be
        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }

    function setAuthority(Authority newAuthority) public virtual {
        // We check if the caller is the owner first because we want to ensure they can
        // always swap out the authority even if it's reverting or using up a lot of gas.
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));

        authority = newAuthority;

        emit AuthorityUpdated(msg.sender, newAuthority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/auth/Auth.sol)
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
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