// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@ankr.com/contracts/earn/BearingToken.sol";

import "../interfaces/ITokenHub.sol";
import "../interfaces/ICertToken.sol";
import "../interfaces/IBondToken.sol";
import "../interfaces/IBinancePool.sol";

contract BinancePool_R11 is
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    OwnableUpgradeable,
    IBinancePool
{
    /**
     * Variables
     */

    uint256 private _minimumStake;
    uint256 private _expireTime;
    uint256 private _pendingGap;

    address private _operator;
    address private _intermediary;
    address private _bondContract;

    address[] private _pendingClaimers;
    mapping(address => uint256) public pendingClaimerUnstakes;

    ITokenHub private _tokenHub;

    uint256 public stashedForManualDistributes;
    mapping(uint256 => bool) public markedForManualDistribute;

    address private _certContract;

    mapping(address => bool) private _claimersForManualDistribute;

    uint256 private _DISTRIBUTE_GAS_LEFT;

    uint256 public failedStakesAmount;

    modifier onlyOperator() {
        require(msg.sender == _operator, "sender is not an operator");
        _;
    }

    modifier badClaimer() {
        require(
            !_claimersForManualDistribute[msg.sender],
            "the address has a request for manual distribution"
        );
        _;
    }

    function initialize(
        address operator,
        address bcOperator,
        address tokenHubAddress,
        uint64 expireTime
    ) public initializer {
        __Pausable_init();
        __ReentrancyGuard_init();
        __Ownable_init();
        _operator = operator;
        _intermediary = bcOperator;
        _expireTime = expireTime;
        _minimumStake = 5e17;
        _tokenHub = ITokenHub(tokenHubAddress);
    }

    function stake() external payable override nonReentrant {
        _stake();
        emit isRebasing(true);
    }

    function stakeAndClaimBonds() external payable override nonReentrant {
        _stake();
        emit isRebasing(true);
    }

    function stakeAndClaimBondsWithCode(uint256 code)
        external
        payable
        override
        nonReentrant
    {
        _stake();
        emit ReferralCode(code);
        emit isRebasing(true);
    }

    function stakeAndClaimCerts() external payable override nonReentrant {
        uint256 sharesAmount = _stake();
        IBondToken(_bondContract).unlockSharesFor(msg.sender, sharesAmount);
        emit isRebasing(false);
    }

    function stakeAndClaimCertsWithCode(uint256 code)
        external
        payable
        override
        nonReentrant
    {
        uint256 sharesAmount = _stake();
        IBondToken(_bondContract).unlockSharesFor(msg.sender, sharesAmount);
        emit ReferralCode(code);
        emit isRebasing(false);
    }

    function _stake() private returns (uint256) {
        uint256 relayerFee = _tokenHub.getMiniRelayFee();
        require(
            msg.value - relayerFee >= _minimumStake,
            "value must be greater than min stake amount"
        );
        uint256 realAmount = msg.value - relayerFee;
        uint64 expireTime = uint64(block.timestamp + _expireTime);
        // executes transferOut of TokenHub
        require(
            _tokenHub.transferOut{value: msg.value}(
                address(0x0),
                _intermediary,
                realAmount,
                expireTime
            ),
            "could not transferOut"
        );

        uint256 shares = IBondToken(_bondContract).bondsToShares(realAmount);
        IBondToken(_bondContract).mint(msg.sender, shares);
        ICertToken(_certContract).mint(_bondContract, shares);

        emit Staked(msg.sender, _intermediary, realAmount);
        return shares;
    }

    function unstake(uint256 amount) external override badClaimer nonReentrant {
        address ownerAddress = msg.sender;
        require(
            amount >= _minimumStake,
            "value must be greater than min unstake amount"
        );
        require(
            ICertificateToken(_bondContract).balanceOf(ownerAddress) >= amount,
            "cannot unstake more than have on address"
        );
        if (pendingClaimerUnstakes[ownerAddress] == 0) {
            _pendingClaimers.push(ownerAddress);
        }
        pendingClaimerUnstakes[ownerAddress] += amount;

        uint256 shares = IBondToken(_bondContract).bondsToShares(amount);
        ICertToken(_certContract).burn(_bondContract, shares);
        IBondToken(_bondContract).burnAndSetPending(ownerAddress, amount);

        emit UnstakePending(ownerAddress, amount);
        emit isRebasing(true);
    }

    function unstakeBonds(uint256 amount)
        external
        override
        badClaimer
        nonReentrant
    {
        address ownerAddress = msg.sender;
        require(
            amount >= _minimumStake,
            "value must be greater than min unstake amount"
        );
        require(
            ICertificateToken(_bondContract).balanceOf(ownerAddress) >= amount,
            "cannot unstake more than have on address"
        );
        if (pendingClaimerUnstakes[ownerAddress] == 0) {
            _pendingClaimers.push(ownerAddress);
        }
        pendingClaimerUnstakes[ownerAddress] += amount;

        uint256 shares = IBondToken(_bondContract).bondsToShares(amount);
        ICertToken(_certContract).burn(_bondContract, shares);
        IBondToken(_bondContract).burnAndSetPending(ownerAddress, amount);

        emit UnstakePending(ownerAddress, amount);
        emit isRebasing(true);
    }

    function unstakeBondsFor(address recipient, uint256 amount)
        external
        override
        badClaimer
        nonReentrant
    {
        require(
            !_claimersForManualDistribute[recipient],
            "recipient has a request for manual distribution"
        );
        require(
            amount >= _minimumStake,
            "value must be greater than min unstake amount"
        );
        require(
            ICertificateToken(_bondContract).balanceOf(msg.sender) >= amount,
            "cannot unstake more than have on address"
        );
        if (pendingClaimerUnstakes[recipient] == 0) {
            _pendingClaimers.push(recipient);
        }
        pendingClaimerUnstakes[recipient] += amount;

        uint256 shares = IBondToken(_bondContract).bondsToShares(amount);
        ICertToken(_certContract).burn(_bondContract, shares);
        IBondToken(_bondContract).burnAndSetPendingFor(
            msg.sender,
            recipient,
            amount
        );

        emit UnstakePending(recipient, amount);
        emit isRebasing(true);
    }

    function unstakeCerts(uint256 shares)
        external
        override
        badClaimer
        nonReentrant
    {
        address ownerAddress = msg.sender;
        uint256 amount = IBondToken(_bondContract).sharesToBonds(shares);
        require(
            amount >= _minimumStake,
            "value must be greater than min unstake amount"
        );
        require(
            ICertToken(_certContract).balanceWithRewardsOf(ownerAddress) >=
                amount,
            "cannot unstake more than have on address"
        );
        if (pendingClaimerUnstakes[ownerAddress] == 0) {
            _pendingClaimers.push(ownerAddress);
        }
        pendingClaimerUnstakes[ownerAddress] += amount;

        IBondToken(_bondContract).lockSharesFor(ownerAddress, shares);
        ICertToken(_certContract).burn(_bondContract, shares);
        IBondToken(_bondContract).burnAndSetPending(ownerAddress, amount);

        emit UnstakePending(ownerAddress, amount);
        emit isRebasing(false);
    }

    function unstakeCertsFor(address recipient, uint256 shares)
        external
        override
        badClaimer
        nonReentrant
    {
        require(
            !_claimersForManualDistribute[recipient],
            "recipient has a request for manual distribution"
        );
        address ownerAddress = msg.sender;
        uint256 amount = IBondToken(_bondContract).sharesToBonds(shares);
        require(
            amount >= _minimumStake,
            "value must be greater than min unstake amount"
        );
        require(
            ICertToken(_certContract).balanceWithRewardsOf(ownerAddress) >=
                amount,
            "cannot unstake more than have on address"
        );
        if (pendingClaimerUnstakes[recipient] == 0) {
            _pendingClaimers.push(recipient);
        }

        pendingClaimerUnstakes[recipient] += amount;
        IBondToken(_bondContract).lockSharesFor(ownerAddress, shares);
        ICertToken(_certContract).burn(_bondContract, shares);
        IBondToken(_bondContract).burnAndSetPendingFor(
            ownerAddress,
            recipient,
            amount
        );

        emit UnstakePending(recipient, amount);
        emit isRebasing(false);
    }

    function distributeRewards() external payable override nonReentrant {
        uint256 poolBalance = address(this).balance -
            stashedForManualDistributes;
        require(
            poolBalance >= _minimumStake,
            "must be greater than min unstake amount"
        );
        address[] memory claimers = new address[](
            _pendingClaimers.length - _pendingGap
        );
        uint256[] memory amounts = new uint256[](
            _pendingClaimers.length - _pendingGap
        );
        uint256 j = 0;
        uint256 gaps = 0;
        uint256 i = _pendingGap;
        while (
            i < _pendingClaimers.length &&
            poolBalance > 0 &&
            gasleft() > _DISTRIBUTE_GAS_LEFT
        ) {
            address claimer = _pendingClaimers[i];
            if (_claimersForManualDistribute[claimer]) {
                i++;
                continue;
            }
            uint256 toDistribute = pendingClaimerUnstakes[claimer];
            /* we might have gaps lets just skip them (we shrink them on full claim) */
            if (claimer == address(0) || toDistribute == 0) {
                i++;
                gaps++;
                continue;
            }
            if (poolBalance < toDistribute) {
                toDistribute = poolBalance;
            }
            address payable wallet = payable(address(claimer));
            bool success;
            assembly {
                success := call(10000, wallet, toDistribute, 0, 0, 0, 0)
            }
            /* when we delete items from array we generate new gap, lets remember how many gaps we did to skip them in next claim */
            if (!success) {
                gaps++;
                markedForManualDistribute[i] = true;
                _claimersForManualDistribute[claimer] = true;
                toDistribute = pendingClaimerUnstakes[claimer];
                stashedForManualDistributes += toDistribute;
                emit ManualDistributeExpected(claimer, toDistribute, i);
                i++;
                continue;
            }
            claimers[j] = claimer;
            amounts[j] = toDistribute;
            IBondToken(_bondContract).updatePendingBurning(
                claimer,
                toDistribute
            );
            poolBalance -= toDistribute;
            pendingClaimerUnstakes[claimer] -= toDistribute;
            j++;
            if (pendingClaimerUnstakes[claimer] != 0) {
                break;
            }
            delete _pendingClaimers[i];
            i++;
            gaps++;
        }
        _pendingGap += gaps;
        /* decrease arrays */
        uint256 removeCells = claimers.length - j;
        if (removeCells > 0) {
            assembly {
                mstore(claimers, j)
            }
            assembly {
                mstore(amounts, j)
            }
        }
        emit RewardsDistributed(claimers, amounts, 0);
    }

    function distributeManual(uint256 id) external override nonReentrant {
        require(
            markedForManualDistribute[id],
            "not marked for manual distributing"
        );
        address[] memory claimers = new address[](1);
        uint256[] memory amounts = new uint256[](1);

        address claimer = _pendingClaimers[id];
        address payable wallet = payable(claimer);
        uint256 amount = pendingClaimerUnstakes[claimer];

        require(
            address(this).balance >= stashedForManualDistributes,
            "insufficient pool balance"
        );

        markedForManualDistribute[id] = false;
        _claimersForManualDistribute[claimer] = false;
        stashedForManualDistributes -= amount;

        claimers[0] = claimer;
        amounts[0] = amount;
        IBondToken(_bondContract).updatePendingBurning(claimer, amount);
        pendingClaimerUnstakes[claimer] = 0;

        (bool result, ) = wallet.call{value: amount}("");
        require(result, "failed to send rewards to claimer");
        delete _pendingClaimers[id];

        emit RewardsDistributed(claimers, amounts, 0);
    }

    function pendingUnstakesOf(address claimer)
        external
        view
        override
        returns (uint256)
    {
        return pendingClaimerUnstakes[claimer];
    }

    function pendingGap() public view returns (uint256) {
        return _pendingGap;
    }

    function calcPendingGap() external onlyOwner {
        uint256 gaps = 0;
        for (uint256 i = 0; i < _pendingClaimers.length; i++) {
            address claimer = _pendingClaimers[i];
            if (
                claimer != address(0) && !_claimersForManualDistribute[claimer]
            ) {
                break;
            }
            gaps++;
        }
        _pendingGap = gaps;
    }

    function getMinimumStake() external view override returns (uint256) {
        return _minimumStake;
    }

    function resetPendingGap() external onlyOwner {
        _pendingGap = 0;
        emit PendingGapReseted();
    }

    function recoverFromSnapshot(
        address[] memory claimers,
        uint256[] memory amounts
    ) external onlyOwner {
        require(
            claimers.length == amounts.length,
            "wrong length of input arrays"
        );

        // let's add into pending state for the future distribution rewards
        for (uint256 i = 0; i < claimers.length; i++) {
            if (pendingClaimerUnstakes[claimers[i]] == 0) {
                _pendingClaimers.push(claimers[i]);
            }
            pendingClaimerUnstakes[claimers[i]] += amounts[i];
        }
    }

    function setMinimumStake(uint256 minStake) external onlyOperator {
        _minimumStake = minStake;
        emit MinimalStakeChanged(minStake);
    }

    function setDistributeGasLeft(uint256 gasLeft) external onlyOwner {
        _DISTRIBUTE_GAS_LEFT = gasLeft;
        emit DistributeGasLeftChanged(gasLeft);
    }

    function getRelayerFee() external view override returns (uint256) {
        return _tokenHub.getMiniRelayFee();
    }

    function changeIntermediary(address intermediary) external onlyOwner {
        require(intermediary != address(0), "zero address");
        _intermediary = intermediary;
        emit IntermediaryChanged(intermediary);
    }

    function changeBondContract(address bondContract) external onlyOwner {
        require(bondContract != address(0), "zero address");
        require(
            AddressUpgradeable.isContract(bondContract),
            "non-contract address"
        );
        _bondContract = bondContract;
        emit BondContractChanged(bondContract);
    }

    function changeCertContract(address certToken) external onlyOwner {
        require(certToken != address(0), "zero address");
        require(
            AddressUpgradeable.isContract(certToken),
            "non-contract address"
        );
        _certContract = certToken;
        emit CertContractChanged(certToken);
    }

    function changeTokenHub(address tokenHub) external onlyOwner {
        require(tokenHub != address(0), "zero address");
        require(
            AddressUpgradeable.isContract(tokenHub),
            "non-contract address"
        );
        _tokenHub = ITokenHub(tokenHub);
        emit TokenHubChanged(tokenHub);
    }

    receive() external payable {
        if (msg.sender == address(_tokenHub)) {
            failedStakesAmount += msg.value;
        }
        emit Received(msg.sender, msg.value);
    }

    function withdrawFailedStakes() external nonReentrant onlyOperator {
        uint256 amount = failedStakesAmount;
        require(amount > 0, "nothing to withdraw");

        address payable wallet = payable(address(_operator));
        (bool result, ) = wallet.call{value: amount}("");
        require(result, "failed to send failed stakes amount");

        failedStakesAmount = 0;

        emit FailedStakesWithdrawn(amount);
    }

    function removeUnburnedSupply(uint256 shares) external onlyOperator {
        ICertToken(_certContract).burn(_bondContract, shares);
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

interface ITokenHub {
    function getMiniRelayFee() external view returns (uint256);

    function getContractAddrByBEP2Symbol(bytes32 bep2Symbol)
        external
        view
        returns (address);

    function getBep2SymbolByContractAddr(address contractAddr)
        external
        view
        returns (bytes32);

    function bindToken(
        bytes32 bep2Symbol,
        address contractAddr,
        uint256 decimals
    ) external;

    function unbindToken(bytes32 bep2Symbol, address contractAddr) external;

    function transferOut(
        address contractAddr,
        address recipient,
        uint256 amount,
        uint64 expireTime
    ) external payable returns (bool);

    /* solium-disable-next-line */
    function batchTransferOutBNB(
        address[] calldata recipientAddrs,
        uint256[] calldata amounts,
        address[] calldata refundAddrs,
        uint64 expireTime
    ) external payable returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@ankr.com/contracts/interfaces/ICertificateToken.sol";

interface ICertToken is ICertificateToken {
    event AirDropFinished();

    function balanceWithRewardsOf(address account) external returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

import "@ankr.com/contracts/interfaces/IBearingToken.sol";

interface IBondToken is IBearingToken {
    /**
    //  * Events
    //  */

    // event Locked(address indexed account, uint256 amount);
    // event Unlocked(address indexed account, uint256 amount);

    // function transferAndLockShares(address account, uint256 shares) external;

    // function mintBonds(address account, uint256 amount) external;

    // function burnBonds(address account, uint256 amount) external;

    function pendingBurn(address account) external view returns (uint256);

    function burnAndSetPending(address account, uint256 amount) external;

    function burnAndSetPendingFor(
        address owner,
        address account,
        uint256 amount
    ) external;

    function updatePendingBurning(address account, uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.16;

interface IBinancePool {
    /**
     * Events
     */

    event isRebasing(bool isRebasing);

    event Staked(
        address indexed delegator,
        address intermediary,
        uint256 amount
    );
    event UnstakePending(address indexed claimer, uint256 amount);
    event RewardsDistributed(
        address[] claimers,
        uint256[] amounts,
        uint256 missing /* total amount of claims still waiting to be served*/
    );

    event ManualDistributeExpected(
        address indexed claimer,
        uint256 amount,
        uint256 indexed id
    );

    event MinimalStakeChanged(uint256 minStake);
    event PendingGapReseted();

    event BondContractChanged(address indexed bondContract);
    event CertContractChanged(address indexed bondContract);
    event IntermediaryChanged(address indexed intermediary);
    event TokenHubChanged(address indexed tokenHub);
    event DistributeGasLeftChanged(uint256 gasLeft);
    event ReferralCode(uint256 code);

    event Received(address indexed from, uint256 amount);

    event FailedStakesWithdrawn(uint256 amount);

    function stake() external payable;

    function unstake(uint256 amount) external;

    function distributeManual(uint256 wrId) external;

    function distributeRewards() external payable;

    function pendingUnstakesOf(address account) external returns (uint256);

    function getMinimumStake() external view returns (uint256);

    function getRelayerFee() external view returns (uint256);

    function stakeAndClaimBonds() external payable;

    function stakeAndClaimBondsWithCode(uint256 code) external payable;

    function stakeAndClaimCerts() external payable;

    function stakeAndClaimCertsWithCode(uint256 code) external payable;

    function unstakeBonds(uint256 amount) external;

    function unstakeCerts(uint256 shares) external;

    function unstakeCertsFor(address recipient, uint256 shares) external;

    function unstakeBondsFor(address recipient, uint256 shares) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
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
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20Upgradeable.sol";
import "./extensions/IERC20MetadataUpgradeable.sol";
import "../../utils/ContextUpgradeable.sol";
import "../../proxy/utils/Initializable.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[45] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
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
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

library MathUtils {

    function saturatingMultiply(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        if (a == 0) return 0;
        uint256 c = a * b;
        if (c / a != b) return type(uint256).max;
        return c;
    }
    }

    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    unchecked {
        uint256 c = a + b;
        if (c < a) return type(uint256).max;
        return c;
    }
    }

    // Preconditions:
    //  1. a may be arbitrary (up to 2 ** 256 - 1)
    //  2. b * c < 2 ** 256
    // Returned value: min(floor((a * b) / c), 2 ** 256 - 1)
    function multiplyAndDivideFloor(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256) {
        return
        saturatingAdd(
            saturatingMultiply(a / c, b),
            ((a % c) * b) / c // can't fail because of assumption 2.
        );
    }

    // Preconditions:
    //  1. a may be arbitrary (up to 2 ** 256 - 1)
    //  2. b * c < 2 ** 256
    // Returned value: min(ceil((a * b) / c), 2 ** 256 - 1)
    function multiplyAndDivideCeil(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256) {
        return
        saturatingAdd(
            saturatingMultiply(a / c, b),
            ((a % c) * b + (c - 1)) / c // can't fail because of assumption 2.
        );
    }
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

import "./IGovernable.sol";

interface IStakingConfig is IGovernable {

    function getActiveValidatorsLength() external view returns (uint32);

    function setActiveValidatorsLength(uint32 newValue) external;

    function getEpochBlockInterval() external view returns (uint32);

    function setEpochBlockInterval(uint32 newValue) external;

    function getMisdemeanorThreshold() external view returns (uint32);

    function setMisdemeanorThreshold(uint32 newValue) external;

    function getFelonyThreshold() external view returns (uint32);

    function setFelonyThreshold(uint32 newValue) external;

    function getValidatorJailEpochLength() external view returns (uint32);

    function setValidatorJailEpochLength(uint32 newValue) external;

    function getUndelegatePeriod() external view returns (uint32);

    function setUndelegatePeriod(uint32 newValue) external;

    function getMinValidatorStakeAmount() external view returns (uint256);

    function setMinValidatorStakeAmount(uint256 newValue) external;

    function getMinStakingAmount() external view returns (uint256);

    function setMinStakingAmount(uint256 newValue) external;

    function getGovernanceAddress() external view override returns (address);

    function setGovernanceAddress(address newValue) external;

    function getTreasuryAddress() external view returns (address);

    function setTreasuryAddress(address newValue) external;

    function getLockPeriod() external view returns (uint64);

    function setLockPeriod(uint64 newValue) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

interface IPausable {
    event Paused(address account);
    event Unpaused(address account);

    function pause() external;

    function unpause() external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ILiquidTokenStakingPool {

    event BearingTokenChanged(address prevValue, address newValue);

    event CertificateTokenChanged(address prevValue, address newValue);

    event MinimumStakeChanged(uint256 prevValue, uint256 newValue);

    event Staked(address indexed staker, uint256 amount, uint256 shares, bool indexed isRebasing);

    event Received(address indexed from, uint256 value);

    function setBearingToken(address newValue) external;

    function setCertificateToken(address newValue) external;

    function setMinimumStake(uint256 newValue) external;

    function stakeBonds() external payable;

    function stakeCerts() external payable;

    function getMinStake() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

interface IInternetBondRatioFeed {

    function updateRatioBatch(address[] calldata addresses, uint256[] calldata ratios) external;

    function getRatioFor(address) external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

interface IGovernable {

    function getGovernanceAddress() external view returns (address);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

import "./IGovernable.sol";

interface IEarnConfig is IGovernable {

    function getConsensusAddress() external view returns (address);

    function setConsensusAddress(address newValue) external;

    function getGovernanceAddress() external view override returns (address);

    function setGovernanceAddress(address newValue) external;

    function getTreasuryAddress() external view returns (address);

    function setTreasuryAddress(address newValue) external;

    function getSwapFeeRatio() external view returns (uint16);

    function setSwapFeeRatio(uint16 newValue) external;

    function pauseBondStaking() external;

    function unpauseBondStaking() external;

    function isBondStakingPaused() external view returns (bool);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface ICertificateToken is IERC20Upgradeable {

    function sharesToBonds(uint256 amount) external view returns (uint256);

    function bondsToShares(uint256 amount) external view returns (uint256);

    function ratio() external view returns (uint256);

    function isRebasing() external pure returns (bool);

    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

import "./ICertificateToken.sol";

interface IBearingToken is ICertificateToken {

    function lockShares(uint256 shares) external;

    function lockSharesFor(address account, uint256 shares) external;

    function unlockShares(uint256 shares) external;

    function unlockSharesFor(address account, uint256 shares) external;

    function totalSharesSupply() external view returns (uint256);
}

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "../libs/MathUtils.sol";

import "../interfaces/IBearingToken.sol";
import "../interfaces/ILiquidTokenStakingPool.sol";
import "../interfaces/IStakingConfig.sol";
import "../interfaces/IInternetBondRatioFeed.sol";
import "../interfaces/IEarnConfig.sol";
import "../interfaces/IPausable.sol";

contract BearingToken is
    OwnableUpgradeable,
    ERC20Upgradeable,
    IBearingToken,
    IPausable
{
    event LiquidStakingPoolChanged(address prevValue, address newValue);
    event InternetBondRatioFeedChanged(address prevValue, address newValue);
    event CertificateTokenChanged(address prevValue, address newValue);

    // other contract references
    ILiquidTokenStakingPool internal _liquidStakingPool;
    IInternetBondRatioFeed internal _internetBondRatioFeed;
    ICertificateToken internal _certificateToken;

    // earn config
    IEarnConfig internal _earnConfig;

    // re-defined ERC20 fields
    mapping(address => uint256) internal _shares;
    uint256 internal _totalSupply;

    // specific bond fields
    int256 internal _lockedShares;

    // pausable
    bool private _paused;

    // reserve
    uint256[100 - 8] private __reserved;

    function initialize(
        IEarnConfig earnConfig,
        string memory name,
        string memory symbol
    ) external initializer {
        __Ownable_init();
        __ERC20_init(name, symbol);
        __BearingToken_init(earnConfig);
    }

    function __BearingToken_init(IEarnConfig earnConfig) internal {
        _earnConfig = earnConfig;
    }

    modifier onlyGovernance() virtual {
        require(
            msg.sender == _earnConfig.getGovernanceAddress(),
            "BearingToken: only governance allowed"
        );
        _;
    }

    modifier onlyConsensus() virtual {
        require(
            msg.sender == _earnConfig.getConsensusAddress(),
            "BearingToken: only consensus allowed"
        );
        _;
    }

    modifier onlyLiquidStakingPool() virtual {
        require(
            msg.sender == address(_liquidStakingPool),
            "BearingToken: only liquid staking pool"
        );
        _;
    }

    modifier onlyInternetBondRatioFeed() virtual {
        require(
            msg.sender == address(_internetBondRatioFeed),
            "BearingToken: only internet bond ratio feed"
        );
        _;
    }

    modifier whenNotPaused() virtual {
        require(!paused(), "BearingToken: paused");
        _;
    }

    modifier whenPaused() virtual {
        require(paused(), "BearingToken: not paused");
        _;
    }

    function setLiquidStakingPool(address newValue) external onlyGovernance {
        address prevValue = address(_liquidStakingPool);
        _liquidStakingPool = ILiquidTokenStakingPool(newValue);
        emit LiquidStakingPoolChanged(prevValue, newValue);
    }

    function setInternetBondRatioFeed(address newValue)
        external
        onlyGovernance
    {
        address prevValue = address(_internetBondRatioFeed);
        _internetBondRatioFeed = IInternetBondRatioFeed(newValue);
        emit InternetBondRatioFeedChanged(prevValue, newValue);
    }

    function setCertificateToken(address newValue) external onlyGovernance {
        address prevValue = address(_certificateToken);
        _certificateToken = ICertificateToken(newValue);
        emit CertificateTokenChanged(prevValue, newValue);
    }

    function mint(address account, uint256 shares)
        external
        override
        whenNotPaused
        onlyLiquidStakingPool
    {
        _mint(account, shares);
    }

    function burn(address account, uint256 shares)
        external
        override
        whenNotPaused
        onlyLiquidStakingPool
    {
        _burn(account, shares);
    }

    function sharesToBonds(uint256 amount)
        public
        view
        override
        returns (uint256)
    {
        return MathUtils.multiplyAndDivideFloor(amount, 1 ether, ratio());
    }

    function bondsToShares(uint256 amount)
        public
        view
        override
        returns (uint256)
    {
        return MathUtils.multiplyAndDivideCeil(amount, ratio(), 1 ether);
    }

    function ratio() public view override returns (uint256) {
        return _internetBondRatioFeed.getRatioFor(address(this));
    }

    function isRebasing() public pure override returns (bool) {
        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override(ERC20Upgradeable, IERC20Upgradeable)
        whenNotPaused
        returns (bool)
    {
        address ownerAddress = _msgSender();
        _transfer(ownerAddress, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        virtual
        override(ERC20Upgradeable, IERC20Upgradeable)
        whenNotPaused
        returns (bool)
    {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function lockShares(uint256 shares) external override whenNotPaused {
        address treasury = _earnConfig.getTreasuryAddress();
        uint16 swapFeeRatio = _earnConfig.getSwapFeeRatio();
        // transfer tokens from aETHc to aETHb
        require(
            _certificateToken.transferFrom(msg.sender, address(this), shares),
            "BearingToken: can't transfer"
        );
        // calc swap fee
        uint256 fee = (shares * swapFeeRatio) / 1e4;
        if (msg.sender == treasury) {
            fee = 0;
        }
        uint256 sharesWithFee = shares - fee;
        if (fee > 0) {
            _mint(treasury, fee);
        }
        _mint(msg.sender, sharesWithFee);
    }

    function lockSharesFor(address account, uint256 shares)
        external
        override
        whenNotPaused
        onlyLiquidStakingPool
    {
        require(
            _certificateToken.transferFrom(account, address(this), shares),
            "BearingToken: failed to transfer"
        );
        _mint(account, shares);
    }

    function unlockShares(uint256 shares) external override whenNotPaused {
        address treasury = _earnConfig.getTreasuryAddress();
        uint16 swapFeeRatio = _earnConfig.getSwapFeeRatio();
        // calc swap fee
        uint256 fee = (shares * swapFeeRatio) / 1e4;
        if (msg.sender == treasury) {
            fee = 0;
        }
        uint256 sharesWithFee = shares - fee;
        if (fee > 0) {
            _transfer(msg.sender, treasury, sharesToBonds(fee));
        }
        _burn(msg.sender, sharesWithFee);
        // transfer tokens
        require(
            _certificateToken.transfer(msg.sender, sharesWithFee),
            "BearingToken: can't transfer"
        );
    }

    function unlockSharesFor(address account, uint256 shares)
        external
        override
        whenNotPaused
        onlyLiquidStakingPool
    {
        _burn(account, shares);
        _certificateToken.transfer(account, shares);
    }

    function totalSupply()
        public
        view
        virtual
        override(ERC20Upgradeable, IERC20Upgradeable)
        returns (uint256)
    {
        uint256 supply = totalSharesSupply();
        return sharesToBonds(supply);
    }

    function totalSharesSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override(ERC20Upgradeable, IERC20Upgradeable)
        returns (uint256)
    {
        return sharesToBonds(_shares[account]);
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override(ERC20Upgradeable, IERC20Upgradeable)
        whenNotPaused
        returns (bool)
    {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        uint256 shares = bondsToShares(amount);
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _shares[from];
        require(
            fromBalance >= shares,
            "ERC20: transfer amount exceeds balance"
        );
        _shares[from] = fromBalance - shares;
        _shares[to] += shares;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 shares) internal virtual override {
        uint256 amount = sharesToBonds(shares);
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, shares);
        _totalSupply += shares;
        _shares[account] += shares;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, shares);
    }

    function _burn(address account, uint256 shares) internal virtual override {
        uint256 amount = sharesToBonds(shares);
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), shares);
        uint256 accountBalance = _shares[account];
        require(accountBalance >= shares, "ERC20: burn amount exceeds balance");
        _shares[account] = accountBalance - shares;
        _totalSupply -= shares;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), shares);
    }

    // Pausable

    function paused() public view returns (bool) {
        return _paused;
    }

    function pause() external whenNotPaused onlyGovernance {
        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() external whenPaused onlyGovernance {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}