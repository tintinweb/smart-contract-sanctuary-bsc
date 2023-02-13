// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (finance/VestingWallet.sol)
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../contributor/ContributorStructs.sol";
import "../../interfaces/ITokenBridge.sol";
import "../../interfaces/IContributor.sol";

/**
 * @title VestingWallet
 * @dev This contract handles the vesting of Eth and ERC20 tokens for a given beneficiary. Custody of multiple tokens
 * can be given to this contract, which will release the token to the beneficiary following a given vesting schedule.
 * The vesting schedule is customizable through the {vestedAmount} function.
 *
 * Any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 */
contract VestingWallet is Context, ReentrancyGuard {

    event EventClaimAllocation (
        address indexed user,
        uint256 saleId,
        uint256 tokenIndex,
        uint256 amount
    );
    
    struct Vesting {
        uint256 _cliffStartTimeInSeconds;
        uint256 _cliffPercentage;
        uint256 _linearStartTimeInSeconds;
        uint256 _linearEndTimeInSeconds;
    }

    mapping( address => mapping(uint256 => bool) ) public claimedCliff;     // tracks the vesting cliff of each userAddress => tokenIndex => claimedStatus
    mapping( address => mapping(uint256 => uint256) ) public claimedAmount;     // tracks the vesting amount of each userAddress => tokenIndex => claimedAmount

    Vesting public _vestingInformation;
    IContributor public _contributor;
    uint256 public _saleId;

    /**
     * @dev Set the beneficiary, start timestamp and vesting duration of the vesting wallet.
     */
    constructor(Vesting memory vestingDetails, address contributor) {
        _vestingInformation = vestingDetails;
        _contributor = IContributor(contributor);
    }

    /**
     * @dev The contract should be able to receive Eth.
     */
    receive() external payable virtual {}
    fallback() external payable virtual {}

    function setSaleId(uint256 saleId) public returns(bool) {
        // require(_msgSender() == address(_contributor), "Only Contributor Can set SaleId");
        // require(_saleId == 0, "Cannot Set SaleId if once set");
        _saleId = saleId;
        return true;
    }

    function setTime(
        uint256 _cliffStartTimeInSeconds,
        uint256 _cliffPercentage,
        uint256 _linearStartTimeInSeconds,
        uint256 _linearEndTimeInSeconds
        ) public {
            _vestingInformation = Vesting({
            _cliffStartTimeInSeconds: _cliffStartTimeInSeconds,
            _cliffPercentage: _cliffPercentage,
            _linearStartTimeInSeconds: _linearStartTimeInSeconds,
            _linearEndTimeInSeconds: _linearEndTimeInSeconds
        });
    }

    /**
     * @dev Amount of token already released
     */
    function released(address user, uint256 tokenIndex) public view virtual returns (uint256) {
        return claimedAmount[user][tokenIndex];
    }

    function vestedLinearDuration() public view returns (uint256) {
        return (_vestingInformation._linearEndTimeInSeconds - _vestingInformation._linearStartTimeInSeconds);
    }

    function vestedLinearTimePassed() public view returns (uint256) {
        return (block.timestamp - _vestingInformation._linearStartTimeInSeconds);
    }

    function vestedTotalCliffAmount(uint256 totalAllocation) public view returns (uint256){
        if(_vestingInformation._cliffPercentage > 0){
            uint256 amount = totalAllocation * _vestingInformation._cliffPercentage;
            amount = amount / 100;
            return amount;
        }
        else{
            return 0;
        }
    }

    function vestedTotalLinearAmount(uint256 totalAllocation) public view returns (uint256){
        
        uint256 linearAllocation;
        if(_vestingInformation._cliffPercentage > 0){
            linearAllocation = totalAllocation - vestedTotalCliffAmount(totalAllocation);
        }
        else{
            linearAllocation = totalAllocation;
        }

        return linearAllocation;
    }
    
    function vestedLinearUnlocked(uint256 totalAllocation) public view returns (uint256) {
        uint256 linearAllocation = vestedTotalLinearAmount(totalAllocation);
        if(block.timestamp < _vestingInformation._linearStartTimeInSeconds){
            return 0;
        }
        else if(block.timestamp > _vestingInformation._linearEndTimeInSeconds){
            return linearAllocation;
        }
        else {
            uint256 unlocked = (linearAllocation * vestedLinearTimePassed()) / vestedLinearDuration(); 
            return unlocked;
        }
    }

    function vestedLinearClaimable(uint256 totalAllocation, uint256 alreadyClaimedAmount) public view returns(uint256) {
        uint256 linearClaimable; 
        if(_vestingInformation._cliffStartTimeInSeconds > 0){
            linearClaimable = vestedTotalCliffAmount(totalAllocation) + vestedLinearUnlocked(totalAllocation);
        }
        else{
            linearClaimable = vestedLinearUnlocked(totalAllocation);
        }

        if( (linearClaimable - alreadyClaimedAmount) > 0 ){
            linearClaimable = linearClaimable - alreadyClaimedAmount;
        }
        else{
            linearClaimable = 0;
        }

        return linearClaimable;
    }


    function release(uint256 saleId, uint256 tokenIndex) public nonReentrant {

        require(_saleId != 0, "Sale Id needs to be set on vesting contract by the contributor");
        require(_contributor.saleExists(saleId), "sale not initiated");

        /// make sure the sale is sealed and not aborted
        (bool isSealed, bool isAborted) = _contributor.getSaleStatus(saleId);

        require(!isAborted, "token sale is aborted");
        require(isSealed, "token sale is not yet sealed");

        /// cache to save on gas
        uint16 thisChainId = _contributor.chainId();

        /// make sure the contributor is claiming on the right chain
        (uint16 contributedTokenChainId, , ) = _contributor.getSaleAcceptedTokenInfo(saleId, tokenIndex);

        require(contributedTokenChainId == thisChainId, "allocation needs to be claimed on a different chain");

        ContributorStructs.Sale memory sale = _contributor.sales(saleId); 

        /**
         * @dev Cache contribution variables since they're used to calculate
         * the allocation and excess contribution.
         */
        uint256 thisContribution = _contributor.getSaleContribution(saleId, tokenIndex, msg.sender);
        uint256 totalContribution = _contributor.getSaleTotalContribution(saleId, tokenIndex);

        /// calculate the allocation and send to the contributor
        uint256 thisAllocation = (_contributor.getSaleAllocation(saleId, tokenIndex) * thisContribution) / totalContribution;
        require(thisAllocation > 0, "The user has not participated for this tokenIndex and saleId");

        address tokenAddress;
        if (sale.tokenChain == thisChainId) {
            /// normal token transfer on same chain
            tokenAddress = address(uint160(uint256(sale.tokenAddress)));
        } else {
            /// identify wormhole token bridge wrapper
            tokenAddress = _contributor.tokenBridge().wrappedAsset(sale.tokenChain, sale.tokenAddress);
        }

        // handle cliff release
        if(_vestingInformation._cliffStartTimeInSeconds > 0){
            if(claimedCliff[msg.sender][tokenIndex] == false){
                if( block.timestamp >= _vestingInformation._cliffStartTimeInSeconds){
                    uint256 toSend = vestedTotalCliffAmount(thisAllocation);
                    claimedCliff[msg.sender][tokenIndex] = true;
                    claimedAmount[msg.sender][tokenIndex] += toSend;
                    SafeERC20.safeTransfer(IERC20(tokenAddress), msg.sender, toSend);
                    emit EventClaimAllocation(msg.sender, saleId, tokenIndex, toSend);
                }
            }
        }

        // handle linear release
        if(block.timestamp >= _vestingInformation._linearStartTimeInSeconds){
            uint256 toSend = vestedLinearClaimable(thisAllocation, claimedAmount[msg.sender][tokenIndex]);
            require(toSend > 0, "No Claims Available at the moment");
            claimedAmount[msg.sender][tokenIndex] += toSend;
            SafeERC20.safeTransfer(IERC20(tokenAddress), msg.sender, toSend);
            emit EventClaimAllocation(msg.sender, saleId, tokenIndex, toSend);
        }

    }
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// contracts/Bridge.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;


interface ITokenBridge {
    function transferTokens(address token, uint256 amount, uint16 recipientChain, bytes32 recipient, uint256 arbiterFee, uint32 nonce) external payable returns (uint64 sequence);

    function wrappedAsset(uint16 tokenChainId, bytes32 tokenAddress) external view returns (address);
}

// SPDX-License-Identifier: Apache 2
pragma solidity ^0.8.0;

import "../icco/contributor/ContributorStructs.sol";
import "../interfaces/ITokenBridge.sol";


interface IContributor {
    function chainId() external view returns (uint16);
    function conductorChainId() external view returns (uint16);
    function conductorContract() external view returns (bytes32);
    function sales(uint256 saleId_) external view returns (ContributorStructs.Sale memory sale);
    function getSaleAcceptedTokenInfo(uint256 saleId_, uint256 tokenIndex) external view returns (uint16 tokenChainId, bytes32 tokenAddress, uint128 conversionRate);
    function getSaleTimeframe(uint256 saleId_) external view returns (uint256 start, uint256 end, uint256 unlockTimestamp);
    function getSaleStatus(uint256 saleId_) external view returns (bool isSealed, bool isAborted);
    function getSaleTokenAddress(uint256 saleId_) external view returns (bytes32 tokenAddress);
    function getSaleAllocation(uint256 saleId, uint256 tokenIndex) external view returns (uint256 allocation);
    function getSaleExcessContribution(uint256 saleId, uint256 tokenIndex) external view returns (uint256 allocation);
    function getSaleTotalContribution(uint256 saleId, uint256 tokenIndex) external view returns (uint256 contributed);
    function getSaleContribution(uint256 saleId, uint256 tokenIndex, address contributor) external view returns (uint256 contributed);
    function tokenBridge() external view returns (ITokenBridge);
    function saleExists(uint256 saleId) external view returns (bool exists);
}

// contracts/Structs.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8.0;

contract ContributorStructs {
    struct Sale {
        /// sale ID
        uint256 saleID;
        /// address of the token - left-zero-padded if shorter than 32 bytes
        bytes32 tokenAddress;
        /// chain ID of the token
        uint16 tokenChain;
        /// token decimals
        uint8 tokenDecimals;
        /// timestamp raise start
        uint256 saleStart;
        /// timestamp raise end
        uint256 saleEnd;
        /// unlock timestamp (when tokens can be claimed)
        uint256 unlockTimestamp;        
        /// accepted Tokens
        uint16[] acceptedTokensChains;
        bytes32[] acceptedTokensAddresses;
        uint128[] acceptedTokensConversionRates;
        bool[] disabledAcceptedTokens;

        /// recipient of proceeds
        bytes32 recipient;

        /// KYC authority public key
        address authority;

        bool isSealed;
        bool isAborted;

        uint256[] allocations;
        uint256[] excessContributions;

        /// vesting
        bool isVested;
    }
}