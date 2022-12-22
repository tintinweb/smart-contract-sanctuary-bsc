// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20MetadataUpgradeable.sol";

contract VOWLaunchpad is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    uint256 public constant PERCENT_DENOMINATOR = 10000;

    struct IDO {
        address idoOwner; // Address of the IDO owner
        address paymentToken; // Address of the payment token
        uint256 targetAmount; // Funds targeted to be raised for the project
        uint256 minInvestmentAmount; // Minimum amount of payment token that can be invested
        address idoToken; // Address of the IDO token
        uint256 tokensForDistribution; // Number of tokens to be distributed
        uint256 tokenPrice; // Token price in payment token (Decimals same as payment token)
        uint256 idoOpenTimestamp; // Timestamp at which the IDO is open
        uint256 idoCloseTimestamp; // Timestamp at which the IDO is closed
        bool cancelled; // Boolean indicating if IDO is cancelled
    }

    struct IDOInvestment {
        uint256 totalInvestment; // Total investment in payment token
        uint256 totalIDOTokensClaimed; // Total number of IDO tokens claimed
        uint256 totalInvestors; // Total number of investors
        bool collected; // Boolean indicating if the investment raised in IDO collected
    }

    struct Investor {
        uint256 investment; // Amount of payment tokens invested by the investor
        bool claimed; // Boolean indicating if user has claimed IDO tokens
        bool refunded; // Boolean indicating if user is refunded
    }

    address public owner; // Owner of the Smart Contract
    address public potentialOwner; // Potential owner's address
    uint256 public feePercentage; // Percentage of Funds raised to be paid as fee
    uint256 public ETHFromFailedTransfers; // ETH left in the contract from failed transfers

    mapping(string => IDO) private _idos; // IDO ID => IDO{}

    mapping(string => IDOInvestment) private _idoInvestments; // IDO ID => IDOInvestment{}

    mapping(string => mapping(address => Investor)) private _idoInvestors; // IDO ID => userAddress => Investor{}

    mapping(address => bool) private _paymentSupported; // tokenAddress => Is token supported as payment

    /* Events */
    event OwnerChange(address newOwner);
    event NominateOwner(address potentialOwner);
    event SetFeePercentage(uint256 feePercentage);
    event AddPaymentToken(address indexed paymentToken);
    event RemovePaymentToken(address indexed paymentToken);
    event IDOAdd(string idoID, address idoOwner, address idoToken);
    event IDOChangeCloseTimestamp(string idoID, uint256 newIdoClosetimestamp);
    event IDOCancel(string idoID);
    event IDOInvestmentCollect(string idoID);
    event IDOInvest(string idoID, address indexed investor, uint256 investment);
    event IDOInvestmentClaim(
        string idoID,
        address indexed investor,
        uint256 tokenAmount
    );
    event IDOInvestmentRefund(
        string idoID,
        address indexed investor,
        uint256 refundAmount
    );
    event TransferOfETHFail(address indexed receiver, uint256 indexed amount);

    /* Modifiers */
    modifier onlyOwner() {
        require(owner == msg.sender, "VOWLaunchpad: Only owner allowed");
        _;
    }

    modifier onlyValidIDO(string calldata idoID) {
        require(idoExist(idoID), "VOWLaunchpad: invalid IDO");
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {}

    function initialize() public initializer {
        owner = msg.sender;
    }

    /* Owner Functions */

    /**
     * @notice This function is used to add a potential owner of the contract
     * @dev Only the owner can call this function
     * @param _potentialOwner Address of the potential owner
     */
    function addPotentialOwner(address _potentialOwner) external onlyOwner {
        require(
            _potentialOwner != address(0),
            "VOWLaunchpad: potential owner zero"
        );
        require(
            _potentialOwner != owner,
            "VOWLaunchpad: potential owner same as owner"
        );
        potentialOwner = _potentialOwner;
        emit NominateOwner(_potentialOwner);
    }

    /**
     * @notice This function is used to accept ownership of the contract
     */
    function acceptOwnership() external {
        require(
            msg.sender == potentialOwner,
            "VOWLaunchpad: only potential owner"
        );
        owner = potentialOwner;
        delete potentialOwner;
        emit OwnerChange(owner);
    }

    /**
     * @notice This method is used to set commission percentage for the launchpad
     * @param _feePercentage Percentage from raised funds to be set as fee
     */
    function setFee(uint256 _feePercentage) external onlyOwner {
        require(
            _feePercentage <= 10000,
            "VOWLaunchpad: fee Percentage should be less than 10000"
        );
        feePercentage = _feePercentage;
        emit SetFeePercentage(_feePercentage);
    }

    /* Payment Token */
    /**
     * @notice This method is used to add Payment token
     * @param _paymentToken Address of payment token to be added
     */
    function addPaymentToken(address _paymentToken) external onlyOwner {
        require(
            !_paymentSupported[_paymentToken],
            "VOWLaunchpad: token already added"
        );
        _paymentSupported[_paymentToken] = true;
        emit AddPaymentToken(_paymentToken);
    }

    /**
     * @notice This method is used to remove Payment token
     * @param _paymentToken Address of payment token to be removed
     */
    function removePaymentToken(address _paymentToken) external onlyOwner {
        require(
            _paymentSupported[_paymentToken],
            "VOWLaunchpad: token not added"
        );
        _paymentSupported[_paymentToken] = false;
        emit RemovePaymentToken(_paymentToken);
    }

    /**
     * @notice This method is used to check if a payment token is supported
     * @param _paymentToken Address of the token
     */
    function isPaymentTokenSupported(address _paymentToken)
        external
        view
        returns (bool)
    {
        return _paymentSupported[_paymentToken];
    }

    /* Helper Functions */
    /**
     * @notice Helper function to transfer tokens based on type
     * @param receiver Address of the receiver
     * @param paymentToken Address of the token to be transferred
     * @param amount Number of tokens to transfer
     */
    function transferTokens(
        address receiver,
        address paymentToken,
        uint256 amount
    ) internal {
        if (amount != 0) {
            if (paymentToken != address(0)) {
                IERC20Upgradeable(paymentToken).safeTransfer(receiver, amount);
            } else {
                (bool success, ) = payable(receiver).call{value: amount}("");
                if (!success) {
                    ETHFromFailedTransfers += amount;
                    emit TransferOfETHFail(receiver, amount);
                }
            }
        }
    }

    /**
     * @notice Helper function to estimate IDO token amount for payment
     * @param amount Amount of payment tokens
     * @param idoToken Address of the IDO token
     * @param tokenPrice Price for IDO token
     */
    function estimateIDOTokens(
        address idoToken,
        uint256 tokenPrice,
        uint256 amount
    ) public view returns (uint256 idoTokenCount) {
        uint256 idoTokenDecimals = uint256(
            IERC20MetadataUpgradeable(idoToken).decimals()
        );
        idoTokenCount = (amount * 10**idoTokenDecimals) / tokenPrice;
    }

    /**
     * @notice Helper function to estimate IDO token amount for payment
     * @param idoID ID of the IDO
     * @param amount Amount of payment tokens
     */
    function estimateIDOTokensById(string calldata idoID, uint256 amount)
        external
        view
        onlyValidIDO(idoID)
        returns (uint256 idoTokenCount)
    {
        uint256 idoTokenDecimals = uint256(
            IERC20MetadataUpgradeable(_idos[idoID].idoToken).decimals()
        );
        idoTokenCount =
            (amount * 10**idoTokenDecimals) /
            _idos[idoID].tokenPrice;
    }

    /* IDO */
    /**
     * @notice This method is used to check if an IDO exist
     * @param idoID ID of the IDO
     */
    function idoExist(string calldata idoID) public view returns (bool) {
        return _idos[idoID].idoToken != address(0) ? true : false;
    }

    /**
     * @notice This method is used to get IDO details
     * @param idoID ID of the IDO
     */
    function getIDO(string calldata idoID)
        external
        view
        onlyValidIDO(idoID)
        returns (IDO memory)
    {
        return _idos[idoID];
    }

    /**
     * @notice This method is used to get IDO Investment details
     * @param idoID ID of the IDO
     */
    function getIDOInvestment(string calldata idoID)
        external
        view
        onlyValidIDO(idoID)
        returns (IDOInvestment memory)
    {
        return _idoInvestments[idoID];
    }

    /**
     * @notice This method is used to get IDO Investment details of an investor
     * @param idoID ID of the IDO
     * @param investor Address of the investor
     */
    function getInvestor(string calldata idoID, address investor)
        external
        view
        onlyValidIDO(idoID)
        returns (Investor memory)
    {
        return _idoInvestors[idoID][investor];
    }

    /**
     * @notice This method is used to add a new IDO project
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO to be added
     * @param idoOwner Address of the IDO owner
     * @param paymentToken Payment token to be used for the IDO
     * @param targetAmount Targeted amount to be raised in IDO
     * @param minInvestmentAmount Minimum amount of payment token that can be invested in IDO
     * @param idoToken Address of IDO token
     * @param tokensForDistribution Number of IDO tokens to be distributed
     * @param tokenPrice IDO token price in terms of payment token
     * @param idoOpenTimestamp IDO open timestamp
     * @param idoCloseTimestamp IDO close timestamp
     */
    function addIDO(
        string calldata idoID,
        address idoOwner,
        address paymentToken,
        uint256 targetAmount,
        uint256 minInvestmentAmount,
        address idoToken,
        uint256 tokensForDistribution,
        uint256 tokenPrice,
        uint256 idoOpenTimestamp,
        uint256 idoCloseTimestamp
    ) external onlyOwner {
        require(!idoExist(idoID), "VOWLaunchpad: IDO id already exist");
        require(idoOwner != address(0), "VOWLaunchpad: IDO owner zero");
        require(
            _paymentSupported[paymentToken],
            "VOWLaunchpad: payment token not supported"
        );
        require(targetAmount != 0, "VOWLaunchpad: target amount zero");
        require(idoToken != address(0), "VOWLaunchpad: IDO token address zero");
        require(tokenPrice != 0, "VOWLaunchpad: token price zero");
        require(
            tokensForDistribution >=
                estimateIDOTokens(idoToken, tokenPrice, targetAmount),
            "VOWLaunchpad: tokensForDistribution would not suffice"
        );
        require(
            block.timestamp <= idoOpenTimestamp &&
                idoOpenTimestamp < idoCloseTimestamp,
            "VOWLaunchpad: IDO invalid timestamps"
        );

        _idos[idoID] = IDO(
            idoOwner,
            paymentToken,
            targetAmount,
            minInvestmentAmount,
            idoToken,
            tokensForDistribution,
            tokenPrice,
            idoOpenTimestamp,
            idoCloseTimestamp,
            false
        );

        IERC20Upgradeable(_idos[idoID].idoToken).safeTransferFrom(
            idoOwner,
            address(this),
            tokensForDistribution
        );
        emit IDOAdd(idoID, idoOwner, idoToken);
    }

    /**
     * @notice This method is used to change IDO close time
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     * @param newIdoClosetimestamp new close timestamp for IDO
     */
    function changeIDOCloseTimestamp(
        string calldata idoID,
        uint256 newIdoClosetimestamp
    ) external onlyOwner onlyValidIDO(idoID) {
        IDO memory ido = _idos[idoID];
        require(
            block.timestamp < ido.idoCloseTimestamp,
            "VOWLaunchpad: IDO is closed"
        );
        require(!ido.cancelled, "VOWLaunchpad: IDO is cancelled");
        require(
            block.timestamp < newIdoClosetimestamp,
            "VOWLaunchpad: new IDO close time is less than current time"
        );

        _idos[idoID].idoCloseTimestamp = newIdoClosetimestamp;

        emit IDOChangeCloseTimestamp(idoID, newIdoClosetimestamp);
    }

    /**
     * @notice This method is used to cancel an IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function cancelIDO(string calldata idoID)
        external
        onlyOwner
        onlyValidIDO(idoID)
    {
        IDO memory ido = _idos[idoID];
        require(!ido.cancelled, "VOWLaunchpad: IDO already cancelled");
        require(
            block.timestamp < ido.idoCloseTimestamp,
            "VOWLaunchpad: IDO is closed"
        );

        _idos[idoID].cancelled = true;

        IERC20Upgradeable(ido.idoToken).safeTransfer(
            ido.idoOwner,
            ido.tokensForDistribution
        );

        emit IDOCancel(idoID);
    }

    /**
     * @notice This method is used to distribute investment raised in IDO
     * @dev This method can only be called by the contract owner
     * @param idoID ID of the IDO
     */
    function collectIDOInvestment(string calldata idoID)
        external
        onlyOwner
        onlyValidIDO(idoID)
    {
        IDO memory ido = _idos[idoID];
        require(!ido.cancelled, "VOWLaunchpad: IDO is cancelled");
        require(
            block.timestamp > ido.idoCloseTimestamp,
            "VOWLaunchpad: IDO is open"
        );

        IDOInvestment memory idoInvestment = _idoInvestments[idoID];

        require(
            !idoInvestment.collected,
            "VOWLaunchpad: IDO investment already collected"
        );
        require(
            idoInvestment.totalInvestment != 0,
            "VOWLaunchpad: IDO investment zero"
        );

        uint256 platformShare = feePercentage == 0
            ? 0
            : (feePercentage * idoInvestment.totalInvestment) /
                PERCENT_DENOMINATOR;

        _idoInvestments[idoID].collected = true;

        transferTokens(owner, ido.paymentToken, platformShare);
        transferTokens(
            ido.idoOwner,
            ido.paymentToken,
            idoInvestment.totalInvestment - platformShare
        );

        uint256 idoTokensLeftover = ido.tokensForDistribution -
            estimateIDOTokens(
                ido.idoToken,
                ido.tokenPrice,
                idoInvestment.totalInvestment
            );
        transferTokens(ido.idoOwner, ido.idoToken, idoTokensLeftover);

        emit IDOInvestmentCollect(idoID);
    }

    /**
     * @notice This method is used to invest in an IDO
     * @dev User must send _amount in order to invest
     * @param idoID ID of the IDO
     */
    function invest(string calldata idoID, uint256 _amount)
        external
        payable
        onlyValidIDO(idoID)
    {
        require(_amount != 0, "VOWLaunchpad: investment zero");

        IDO memory ido = _idos[idoID];
        require(
            block.timestamp >= ido.idoOpenTimestamp,
            "VOWLaunchpad: IDO is not open"
        );
        require(
            block.timestamp < ido.idoCloseTimestamp,
            "VOWLaunchpad: IDO has closed"
        );
        require(!ido.cancelled, "VOWLaunchpad: IDO cancelled");
        require(
            _amount >= ido.minInvestmentAmount,
            "VOWLaunchpad: amount less than minimum investment"
        );
        IDOInvestment storage idoInvestment = _idoInvestments[idoID];

        require(
            ido.targetAmount >= idoInvestment.totalInvestment + _amount,
            "VOWLaunchpad: amount exceeds target"
        );

        idoInvestment.totalInvestment += _amount;
        if (_idoInvestors[idoID][msg.sender].investment == 0)
            ++idoInvestment.totalInvestors;
        _idoInvestors[idoID][msg.sender].investment += _amount;

        if (ido.paymentToken == address(0)) {
            require(
                msg.value == _amount,
                "VOWLaunchpad: msg.value not equal to amount"
            );
        } else
            IERC20Upgradeable(ido.paymentToken).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );

        emit IDOInvest(idoID, msg.sender, _amount);
    }

    /**
     * @notice This method is used to refund investment if IDO is cancelled
     * @param idoID ID of the IDO
     */
    function refundInvestment(string calldata idoID)
        external
        onlyValidIDO(idoID)
    {
        IDO memory ido = _idos[idoID];
        require(ido.cancelled, "VOWLaunchpad: IDO is not cancelled");

        Investor memory user = _idoInvestors[idoID][msg.sender];
        require(!user.refunded, "VOWLaunchpad: already refunded");
        require(user.investment != 0, "VOWLaunchpad: no investment found");

        _idoInvestors[idoID][msg.sender].refunded = true;
        transferTokens(msg.sender, ido.paymentToken, user.investment);

        emit IDOInvestmentRefund(idoID, msg.sender, user.investment);
    }

    function claimIDOTokens(string calldata idoID)
        external
        onlyValidIDO(idoID)
    {
        IDO memory ido = _idos[idoID];

        require(!ido.cancelled, "VOWLaunchpad: IDO is cancelled");
        require(
            block.timestamp > ido.idoCloseTimestamp,
            "VOWLaunchpad: IDO not closed yet"
        );

        Investor memory user = _idoInvestors[idoID][msg.sender];
        require(!user.claimed, "VOWLaunchpad: already claimed");
        require(user.investment != 0, "VOWLaunchpad: no investment found");

        uint256 idoTokens = estimateIDOTokens(
            ido.idoToken,
            ido.tokenPrice,
            user.investment
        );
        _idoInvestors[idoID][msg.sender].claimed = true;
        _idoInvestments[idoID].totalIDOTokensClaimed += idoTokens;

        IERC20Upgradeable(ido.idoToken).safeTransfer(msg.sender, idoTokens);

        emit IDOInvestmentClaim(idoID, msg.sender, idoTokens);
    }

    /**
     * @notice This method is to collect any ETH left from failed transfers.
     * @dev This method can only be called by the contract owner
     */
    function collectETHFromFailedTransfers() external onlyOwner {
        uint256 ethToSend = ETHFromFailedTransfers;
        ETHFromFailedTransfers = 0;
        (bool success, ) = payable(owner).call{value: ethToSend}("");
        require(success, "VOWLaunchpad: ETH transfer failed");
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

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
     * `onlyInitializing` functions can be used to initialize parent contracts.
     *
     * Similar to `reinitializer(1)`, except that functions marked with `initializer` can be nested in the context of a
     * constructor.
     *
     * Emits an {Initialized} event.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
     * A reinitializer may be used after the original initialization step. This is essential to configure modules that
     * are added through upgrades and that require initialization.
     *
     * When `version` is 1, this modifier is similar to `initializer`, except that functions marked with `reinitializer`
     * cannot be nested. If one is invoked in the context of another, execution will revert.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     *
     * WARNING: setting the version to 255 will prevent any future reinitialization.
     *
     * Emits an {Initialized} event.
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
     *
     * Emits an {Initialized} event the first time it is successfully executed.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initialized`
     */
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }

    /**
     * @dev Internal function that returns the initialized version. Returns `_initializing`
     */
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}