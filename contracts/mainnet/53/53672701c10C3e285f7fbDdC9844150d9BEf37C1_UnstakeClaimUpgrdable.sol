// SPDX-License-Identifier: GNU GPLv3

pragma solidity =0.8.9;

import {Initializable} from "./proxy/Initializable.sol";
import {OwnableUpgradeable} from "./access/OwnableUpgradeable.sol";
import {IUnifarmNFTManagerUpgradeable} from "./interfaces/IUnifarmNFTManagerUpgradeable.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {TransferHelpers} from "./library/TransferHelpers.sol";

/// @title UnstakeClaimUpgrdable Contract
/// @author UNIFARM
/// @notice Unstake Claim handles Unifarm cohort Unstake

contract UnstakeClaimUpgrdable is OwnableUpgradeable {
    // nft manager
    address public nftManager;

    // admin wallet address
    address public adminWallet;

    // nft rewards mapping
    mapping(uint256 => address[]) public rewardTokenAddresses;
    // nft rewards mapping
    mapping(uint256 => uint256[]) public rewardTokenAmounts;

    /// @notice struct to hold cohort fees configuration
    struct FeeConfiguration {
        // protocol fee wallet address
        address payable feeWalletAddress;
        // protocol fee amount
        uint256 feeAmount;
    }

    /// @notice global fees pointer for all cohorts
    FeeConfiguration public fees;

    event FeeConfigurtionAdded(address feeWalletAddress, uint256 feeAmount);

    // constructor
    function __UnstakeClaimUpgrdable__init(
        address _nftManager,
        address _master,
        address _adminWallet,
        address _trustForwarder,
        address payable _feeWallet,
        uint256 _feeAmount
    ) external initializer {
        __UnstakeClaimUpgrdable__init_unchained(
            _nftManager,
            _adminWallet,
            _feeWallet,
            _feeAmount
        );
        __Ownable_init(_master, _trustForwarder);
    }

    function __UnstakeClaimUpgrdable__init_unchained(
        address _nftManager,
        address _adminWallet,
        address payable _feeWallet,
        uint256 _feeAmount
    ) internal {
        nftManager = _nftManager;
        adminWallet = _adminWallet;
        setFeeConfiguration(_feeWallet, _feeAmount);
    }

    function setFeeConfiguration(
        address payable feeWalletAddress_,
        uint256 feeAmount_
    ) internal {
        require(feeWalletAddress_ != address(0), "IFWA");
        require(feeAmount_ > 0, "IFA");
        fees = FeeConfiguration({
            feeWalletAddress: feeWalletAddress_,
            feeAmount: feeAmount_
        });
        emit FeeConfigurtionAdded(feeWalletAddress_, feeAmount_);
    }

    // getReward token `nftId`
    function getRewardTokens(uint256 nftId)
        external
        view
        returns (address[] memory, uint256[] memory)
    {
        return (rewardTokenAddresses[nftId], rewardTokenAmounts[nftId]);
    }

    // setNft details for nft
    function setRewards(
        uint256 nftId,
        address[] memory _rewardTokenAddresses,
        uint256[] memory _rewards
    ) external onlyOwner returns (bool) {
        require(
            _rewardTokenAddresses.length == _rewards.length,
            "Invalid rewards length"
        );
        rewardTokenAddresses[nftId] = _rewardTokenAddresses;
        rewardTokenAmounts[nftId] = _rewards;

        return true;
    }

    // transfer nft and claim rewards
    function claimRewards(uint256 nftId) external returns (bool) {
        // check ownership
        require(
            IUnifarmNFTManagerUpgradeable(nftManager).ownerOf(nftId) ==
                _msgSender(),
            "Invalid NFT owner"
        );

        IUnifarmNFTManagerUpgradeable(nftManager).transferFrom(
            _msgSender(),
            adminWallet,
            nftId
        );
        // get rewards
        address[] storage _tokenAddresses = rewardTokenAddresses[nftId];
        uint256[] storage _tokenAmount = rewardTokenAmounts[nftId];
        // distribute all rewards
        for (uint256 i = 0; i < _tokenAddresses.length; i++) {
            IERC20(_tokenAddresses[i]).transfer(_msgSender(), _tokenAmount[i]);
            rewardTokenAmounts[nftId][i] = 0;
        }

        TransferHelpers.safeTransferParentChainToken(
            fees.feeWalletAddress,
            fees.feeAmount
        );

        return true;
    }

    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external onlyOwner {
        require(withdrawableAddress != address(0), "IWA");
        require(tokens.length == amounts.length, "SF");
        uint8 i = 0;
        uint8 tokensLength = uint8(tokens.length);
        while (i < tokensLength) {
            TransferHelpers.safeTransfer(
                tokens[i],
                withdrawableAddress,
                amounts[i]
            );
            i++;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/utils/Initializable.sol)

pragma solidity =0.8.9;

import '../utils/AddressUpgradeable.sol';

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
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
 * Avoid leaving a contract uninitialized
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
     * @dev Indicates that the contract has been initialized
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice
     */
    modifier initializer() {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, because in other contexts the
        // contract may have been reentered
        require(_initializing ? _isConstructor() : !_initialized, 'CIAI');

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

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} modifier, directly or indirectly
     */
    modifier onlyInitializing() {
        require(_initializing, 'CINI');
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: GNU GPLv3

// OpenZeppelin Contracts v4.3.2 (access/Ownable.sol)

pragma solidity =0.8.9;

import {ERC2771ContextUpgradeable} from "../metatx/ERC2771ContextUpgradeable.sol";
import {Initializable} from "../proxy/Initializable.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner
 */

abstract contract OwnableUpgradeable is
    Initializable,
    ERC2771ContextUpgradeable
{
    address private _owner;
    address private _master;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner
     */
    function __Ownable_init(address master, address trustedForwarder)
        internal
        initializer
    {
        __Ownable_init_unchained(master);
        __ERC2771ContextUpgradeable_init(trustedForwarder);
    }

    function __Ownable_init_unchained(address masterAddress)
        internal
        initializer
    {
        _transferOwnership(_msgSender());
        _master = masterAddress;
    }

    /**
     * @dev Returns the address of the current owner
     * @return _owner - _owner address
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "ONA");
        _;
    }

    /**
     * @dev Throws if called by any account other than the master
     */
    modifier onlyMaster() {
        require(_master == _msgSender(), "OMA");
        _;
    }

    /**
     * @dev Transfering the owner ship to master role in case of emergency
     *
     * NOTE: Renouncing ownership will transfer the contract ownership to master role
     */

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(_master);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`)
     * Can only be called by the current owner
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "INA");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`)
     * Internal function without access restriction
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: GNU GPLv3

pragma solidity =0.8.9;

// solhint-disable  avoid-low-level-calls

/// @title TransferHelpers library
/// @author UNIFARM
/// @notice handles token transfers and ethereum transfers for protocol
/// @dev all the functions are internally used in the protocol

library TransferHelpers {
    /**
     * @dev make sure about approval before use this function
     * @param target A ERC20 token address
     * @param sender sender wallet address
     * @param recipient receiver wallet Address
     * @param amount number of tokens to transfer
     */

    function safeTransferFrom(
        address target,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
        require(success && data.length > 0, 'STFF');
    }

    /**
     * @notice transfer any erc20 token
     * @param target ERC20 token address
     * @param to receiver wallet address
     * @param amount number of tokens to transfer
     */

    function safeTransfer(
        address target,
        address to,
        uint256 amount
    ) internal {
        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && data.length > 0, 'STF');
    }

    /**
     * @notice transfer parent chain token
     * @param to receiver wallet address
     * @param value of eth to transfer
     */

    function safeTransferParentChainToken(address to, uint256 value) internal {
        (bool success, ) = to.call{value: uint128(value)}(new bytes(0));
        require(success, 'STPCF');
    }
}

// SPDX-License-Identifier: GNU GPLv3

// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

pragma solidity =0.8.9;

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

// SPDX-License-Identifier: GNU GPLv3

pragma solidity =0.8.9;

/// @title IUnifarmNFTManagerUpgradeable Interface
/// @author UNIFARM
/// @notice All External functions of Unifarm NFT Manager

interface IUnifarmNFTManagerUpgradeable {
    /**
     * @notice stake on unifarm
     * @dev make sure approve before calling this function
     * @dev minting NFT's
     * @param cohortId cohort contract address
     * @param referralAddress referral address
     * @param farmToken farm token address
     * @param sAmount staking amount
     * @param farmId cohort farm Id
     * @return tokenId the minted NFT Token Id
     */

    function stakeOnUnifarm(
        address cohortId,
        address referralAddress,
        address farmToken,
        uint256 sAmount,
        uint32 farmId
    ) external returns (uint256 tokenId);

    /**
     * @notice a payable function use to unstake farm tokens
     * @dev burn NFT's
     * @param tokenId NFT token Id
     */

    function unstakeOnUnifarm(uint256 tokenId) external payable;

    /**
     * @notice claim rewards without removing the pricipal staked amount
     * @param tokenId NFT tokenId
     */

    function claimOnUnifarm(uint256 tokenId) external payable;

    /**
     * @notice function is use to buy booster pack
     * @param cohortId cohort address
     * @param bpid  booster pack id to purchase booster
     * @param tokenId NFT tokenId
     */

    function buyBoosterPackOnUnifarm(
        address cohortId,
        uint256 bpid,
        uint256 tokenId
    ) external payable;

    /**
     * @notice use to stake + buy booster pack on unifarm cohort
     * @dev make sure approve before calling this function
     * @dev minting NFT's
     * @param cohortId cohort Address
     * @param referralAddress referral wallet address
     * @param farmToken farm token address
     * @param bpid booster package id
     * @param sAmount stake amount
     * @param farmId farm id
     */

    function stakeAndBuyBoosterPackOnUnifarm(
        address cohortId,
        address referralAddress,
        address farmToken,
        uint256 bpid,
        uint256 sAmount,
        uint32 farmId
    ) external payable returns (uint256 tokenId);

    /**
     * @notice use to burn portion on unifarm in very rare situation
     * @dev use by only owner access
     * @param user user wallet address
     * @param tokenId NFT tokenId
     */

    function emergencyBurn(address user, uint256 tokenId) external;

    /**
     * @notice update fee structure for protocol
     * @dev can only be called by the current owner
     * @param feeWalletAddress_ - new fee Wallet address
     * @param feeAmount_ - new fee amount for protocol
     */

    function updateFeeConfiguration(
        address payable feeWalletAddress_,
        uint256 feeAmount_
    ) external;

    /**
     * @notice event triggered on each update of protocol fee structure
     * @param feeWalletAddress fee wallet address
     * @param feeAmount protocol fee Amount
     */

    event FeeConfigurtionAdded(
        address indexed feeWalletAddress,
        uint256 feeAmount
    );

    /**
     * @notice ownerOf function
     * @dev check ownership
     * @param tokenId - nft Id
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity =0.8.9;

/**
 * @dev Collection of functions related to the address type
 */
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        require(isContract(target), 'Address: call to non-contract');

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
        return functionStaticCall(target, data, 'Address: low-level static call failed');
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
        require(isContract(target), 'Address: static call to non-contract');

        (bool success, bytes memory returndata) = target.staticcall(data);
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

// SPDX-License-Identifier: GNU GPLv3

pragma solidity =0.8.9;

import {Initializable} from '../proxy/Initializable.sol';

/**
 * @dev Context variant with ERC2771 support
 */

// solhint-disable
abstract contract ERC2771ContextUpgradeable is Initializable {
    /**
     * @dev holds the trust forwarder
     */

    address public trustedForwarder;

    /**
     * @dev context upgradeable initializer
     * @param tForwarder trust forwarder
     */

    function __ERC2771ContextUpgradeable_init(address tForwarder) internal initializer {
        __ERC2771ContextUpgradeable_init_unchained(tForwarder);
    }

    /**
     * @dev called by initializer to set trust forwarder
     * @param tForwarder trust forwarder
     */

    function __ERC2771ContextUpgradeable_init_unchained(address tForwarder) internal {
        trustedForwarder = tForwarder;
    }

    /**
     * @dev check if the given address is trust forwarder
     * @param forwarder forwarder address
     * @return isForwarder true/false
     */

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == trustedForwarder;
    }

    function _updateTrustedForwarder(address tForwarder) internal {
        trustedForwarder = tForwarder;
    }

    /**
     * @dev if caller is trusted forwarder will return exact sender.
     * @return sender wallet address
     */

    function _msgSender() internal view virtual returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }

    /**
     * @dev returns msg data for called function
     * @return function call data
     */

    function _msgData() internal view virtual returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return msg.data;
        }
    }
}