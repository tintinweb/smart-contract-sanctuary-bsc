/**
 *Submitted for verification at BscScan.com on 2022-04-11
*/

// File: Interface/ITree.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.12;


interface ITree {
    function getAllBlacklistedAddresses()
        external
        view
        returns (address[] memory);

    function isBlacklistedAddress(address _checkBlacklistAddress)
        external
        view
        returns (bool);

    function issue(
        address _customerAddress,
        uint256 _amount,
        string memory _comment
    ) external;

    function redeem(uint256 _amount, string memory _comment) external;

    function redeemBoss(
        address _burnAddress,
        uint256 _amount,
        string memory _comment
    ) external;

    function addBlacklisted(address _blacklistAddress, bool _isBlacklisted)
        external;

    function accountTransfer(address _from, address _to) external;
}
// File: @openzeppelin/contracts/utils/Context.sol


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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

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
     * by making the `nonReentrant` function external, and making it call a
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

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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

// File: @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



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

// File: Reseller v1.6.sol


pragma solidity ^0.8.12;






contract Reseller is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    address public boss1;
    address public boss2;
    address public boss3;
    address public boss4;
    address public boss5;

    struct Investor {
        uint256 amount;
        address ref1;
        address ref2;
        address ref3;
        TransferStatus transferStatus;
    }

    struct FullInvestor {
        address investor;
        uint256 amount;
        TransferStatus transferStatus;
        uint256 investmentRound;
    }

    enum TransferStatus {
        OPEN,
        COMPLETED,
        REFUND
    }

    mapping(address => mapping(uint256 => Investor)) public investors;
    mapping(address => uint256) public investmentRounds;
    FullInvestor[] private allInvestors;

    IERC20 public Token;
    ITree public TreeToken;

    uint256 public treePrice;
    uint256 public minAmountBuy;
    uint256[3] public referralPercentages = [10, 6, 4];
    uint256[3] public bossPercentages = [10, 20, 50];
    bool public active;

    modifier onlyActive() {
        require(active, "Not active");
        _;
    }

    modifier isOpenInvestment(
        address _investorAddress,
        uint256 _investmentRound
    ) {
        Investor memory investor = investors[_investorAddress][
            _investmentRound
        ];
        require(
            investor.transferStatus == TransferStatus.OPEN,
            "Transfer status needs to be open"
        );
        require(investor.amount > 0, "Investment amount can not be 0");
        _;
    }

    modifier onlyBoss() {
        require(
            msg.sender == boss1 ||
                msg.sender == boss2 ||
                msg.sender == owner() ||
                msg.sender == boss5,
            "Not allowed to access this function"
        );
        _;
    }

    event OnSentToken(
        address indexed sender,
        address _ref1,
        address _ref2,
        address _ref3,
        uint256 amount
    );
    event OnStatusCompleted(
        address indexed investor,
        uint256 tokenAmount,
        uint256 treeAmount
    );
    event OnRefunded(address indexed investor, uint256 amount);
    event OnRefPayout(address indexed ref, uint256 amount);
    event OnSetPrice(address indexed admin, uint256 newPrice);
    event OnSetMinAmountBuy(address indexed admin, uint256 minAmountBuy);
    event OnSetDistributionAmount(
        address indexed admin,
        uint256 boss2Amount,
        uint256 boss3Amount,
        uint256 boss4Amount,
        uint256 ref1,
        uint256 ref2,
        uint256 ref3
    );
    event OnActiveChange(address indexed admin, bool active);

    constructor(
        address _tokenAddress,
        address _treeTokenAddress,
        uint256 _treePrice,
        uint256 _minAmountBuy,
        address _boss1,
        address _boss2,
        address _boss3,
        address _boss4,
        address _boss5
    ) {
        Token = IERC20(_tokenAddress);
        TreeToken = ITree(_treeTokenAddress);
        treePrice = _treePrice;
        minAmountBuy = _minAmountBuy;
        boss1 = _boss1;
        boss2 = _boss2;
        boss3 = _boss3;
        boss4 = _boss4;
        boss5 = _boss5;
        active = true;
    }

    function sendToken(
        uint256 _amount,
        address _ref1,
        address _ref2,
        address _ref3
    ) external nonReentrant onlyActive {
        require(_amount >= minAmountBuy, "Not enough tokens");
        require(
            _ref1 != msg.sender && _ref2 != msg.sender && _ref3 != msg.sender,
            "Referral to itself is not allowed"
        );
        Token.safeTransferFrom(msg.sender, address(this), _amount);
        _setInvestor(msg.sender, _ref1, _ref2, _ref3, _amount);
        emit OnSentToken(msg.sender, _ref1, _ref2, _ref3, _amount);
    }

    function setStatusCompletedPool(
        uint256 _startIndex,
        address[] memory _investorAddresses
    ) external onlyBoss {
        for (uint256 i = _startIndex; i < _investorAddresses.length; i++) {
            uint256 _investmentRounds = investmentRounds[_investorAddresses[i]];
            for (uint256 u = 1; u <= _investmentRounds; u++) {
                Investor memory _investor = investors[_investorAddresses[i]][u];
                if (_investor.transferStatus == TransferStatus.OPEN) {
                    setStatusCompleted(_investorAddresses[i], u);
                }
            }
        }
    }

    function setStatusCompleted(
        address _investorAddress,
        uint256 _investmentRound
    )
        public
        nonReentrant
        onlyBoss
        isOpenInvestment(_investorAddress, _investmentRound)
    {
        investors[_investorAddress][_investmentRound]
            .transferStatus = TransferStatus.COMPLETED;
        uint256 _amount = investors[_investorAddress][_investmentRound].amount;

        address _ref1 = investors[_investorAddress][_investmentRound].ref1;
        address _ref2 = investors[_investorAddress][_investmentRound].ref2;
        address _ref3 = investors[_investorAddress][_investmentRound].ref3;

        uint256 _refSum = 0;

        if (_ref1 != address(0)) {
            uint256 bonus = (_amount * referralPercentages[0]) / 100;
            Token.safeTransfer(_ref1, bonus);
            _refSum += bonus;
            emit OnRefPayout(_ref1, bonus);
        }
        if (_ref2 != address(0)) {
            uint256 bonus = (_amount * referralPercentages[1]) / 100;
            Token.safeTransfer(_ref2, bonus);
            _refSum += bonus;
            emit OnRefPayout(_ref2, bonus);
        }
        if (_ref3 != address(0)) {
            uint256 bonus = (_amount * referralPercentages[2]) / 100;
            Token.safeTransfer(_ref3, bonus);
            _refSum += bonus;
            emit OnRefPayout(_ref3, bonus);
        }

        uint256 _shareBoss2 = (_amount * bossPercentages[0]) / 100;
        uint256 _shareBoss3 = (_amount * bossPercentages[1]) / 100;
        uint256 _shareBoss4 = (_amount * bossPercentages[2]) / 100;

        uint256 _shareBoss1 = _amount -
            _shareBoss2 -
            _shareBoss3 -
            _shareBoss4 -
            _refSum;

        if (_shareBoss1 > 0) {
            Token.safeTransfer(boss1, _shareBoss1);
        }
        Token.safeTransfer(boss2, _shareBoss2);
        Token.safeTransfer(boss3, _shareBoss3);
        Token.safeTransfer(boss4, _shareBoss4);

        // emit tree token
        TreeToken.issue(
            _investorAddress,
            _amount / treePrice,
            "issue from reseller contract"
        );

        emit OnStatusCompleted(_investorAddress, _amount, _amount / treePrice);
    }

    function refund(address _investorAddress, uint256 _investmentRound)
        external
        nonReentrant
        onlyBoss
        isOpenInvestment(_investorAddress, _investmentRound)
    {
        investors[_investorAddress][_investmentRound]
            .transferStatus = TransferStatus.REFUND;
        uint256 _amount = investors[_investorAddress][_investmentRound].amount;
        Token.safeTransfer(_investorAddress, _amount);
        emit OnRefunded(_investorAddress, _amount);
    }

    function setTreePrice(uint256 _treePrice) external onlyBoss {
        treePrice = _treePrice;
        emit OnSetPrice(msg.sender, treePrice);
    }

    function setMinAmountBuy(uint256 _minAmountBuy) external onlyBoss {
        require(
            _minAmountBuy > 0,
            "Min amount for buy needs to be larger than 0"
        );
        minAmountBuy = _minAmountBuy;
        emit OnSetMinAmountBuy(msg.sender, minAmountBuy);
    }

    function setActive(bool _active) external onlyBoss {
        active = _active;
        emit OnActiveChange(msg.sender, active);
    }

    function setDistribution(
        uint256 _boss2Amount,
        uint256 _boss3Amount,
        uint256 _boss4Amount,
        uint256 _ref1,
        uint256 _ref2,
        uint256 _ref3
    ) external onlyBoss {
        require(
            _boss2Amount +
                _boss3Amount +
                _boss4Amount +
                _ref1 +
                _ref2 +
                _ref3 ==
                100,
            "Distribution need to be 100%"
        );
        referralPercentages[0] = _ref1;
        referralPercentages[1] = _ref2;
        referralPercentages[2] = _ref3;
        bossPercentages[0] = _boss2Amount;
        bossPercentages[1] = _boss3Amount;
        bossPercentages[2] = _boss4Amount;
        emit OnSetDistributionAmount(
            msg.sender,
            _boss2Amount,
            _boss3Amount,
            _boss4Amount,
            _ref1,
            _ref2,
            _ref3
        );
    }

    function deputeBoss1(address _newBoss1Address) external {
        require(msg.sender == boss1);
        boss1 = _newBoss1Address;
    }

    function deputeBoss2(address _newBoss2Address) external {
        require(msg.sender == boss1 || msg.sender == boss2);
        boss2 = _newBoss2Address;
    }

    function deputeBoss3(address _newBoss3Address) external {
        require(msg.sender == boss1 || msg.sender == boss2);
        boss3 = _newBoss3Address;
    }

    function deputeBoss4(address _newBoss4Address) external {
        require(msg.sender == boss1 || msg.sender == boss2);
        boss4 = _newBoss4Address;
    }

    function deputeBoss5(address _newBoss5Address) external {
        require(
            msg.sender == boss1 ||
                msg.sender == boss2 ||
                msg.sender == boss3 ||
                msg.sender == boss4 ||
                msg.sender == owner()
        );
        boss5 = _newBoss5Address;
    }

    function emergencyWithdraw() external onlyBoss {
        uint256 tokenBalance = Token.balanceOf(address(this));
        Token.safeTransfer(boss1, tokenBalance);
    }

    function getAllInvestors()
        public
        view
        returns (FullInvestor[] memory _investors)
    {
        uint256 length = allInvestors.length;
        FullInvestor[] memory fullInvestors = new FullInvestor[](length);
        for (uint256 i = 0; i < allInvestors.length; i++) {
            FullInvestor memory fullInvestor = allInvestors[i];
            TransferStatus transferStatus = investors[fullInvestor.investor][
                fullInvestor.investmentRound
            ].transferStatus;
            fullInvestor.transferStatus = transferStatus;
            fullInvestors[i] = fullInvestor;
        }
        return fullInvestors;
    }

    function _setInvestor(
        address _investorAddress,
        address _ref1,
        address _ref2,
        address _ref3,
        uint256 _investmentAmount
    ) internal {
        uint256 _investmentRound = investmentRounds[_investorAddress];
        _investmentRound++;
        Investor memory _investor = Investor(
            _investmentAmount,
            _ref1,
            _ref2,
            _ref3,
            TransferStatus.OPEN
        );
        investors[_investorAddress][_investmentRound] = _investor;
        investmentRounds[_investorAddress] = _investmentRound;
        allInvestors.push(
            FullInvestor(
                _investorAddress,
                _investmentAmount,
                TransferStatus.OPEN,
                _investmentRound
            )
        );
    }
}