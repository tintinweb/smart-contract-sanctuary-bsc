// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

import { AbstractBhavishSDK } from "./AbstractBhavishSDK.sol";
import { IBhavishNativeSDK, IBhavishPredictionNative } from "../../Interface/IBhavishNativeSDK.sol";
import { IBhavishPrediction } from "../../Interface/IBhavishPrediction.sol";
import { BhavishSwap } from "../../Integrations/Swap/BhavishSwap.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract NativeSDK is AbstractBhavishSDK, IBhavishNativeSDK {
    using Address for address;
    using SafeERC20 for IERC20;

    BhavishSwap public bhavishSwap;

    constructor(
        IBhavishPredictionNative[] memory _bhavishPrediction,
        bytes32[] memory _underlying,
        bytes32[] memory _strike,
        BhavishSwap _bhavishSwap
    ) {
        require(_bhavishPrediction.length == _underlying.length, "Invalid array arguments passed");
        require(_strike.length == _underlying.length, "Invalid array arguments passed");
        require(address(_bhavishSwap).isContract(), "Swapper is not a contract");
        bhavishSwap = _bhavishSwap;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        for (uint256 i = 0; i < _bhavishPrediction.length; i++) {
            predictionMap[_underlying[i]][_strike[i]] = _bhavishPrediction[i];
            activePredictionMap[_bhavishPrediction[i]] = true;
        }
    }

    function _getNativePredictionMap(IBhavishPrediction _bhavishPrediction)
        private
        pure
        returns (IBhavishPredictionNative bhavishPrediction)
    {
        return IBhavishPredictionNative(address(_bhavishPrediction));
    }

    function predict(
        PredictionStruct memory _predStruct,
        address _userAddress,
        address _provider
    ) external payable override {
        IBhavishPredictionNative bhavishPrediction = _getNativePredictionMap(
            predictionMap[_predStruct.underlying][_predStruct.strike]
        );

        require(address(bhavishPrediction) != address(0), "Prediction Market for the asset is not present");
        require(activePredictionMap[bhavishPrediction], "Prediction Market for the asset is not active");

        address userAddress_;
        if (address(msg.sender).isContract() && validContracts[msg.sender]) {
            userAddress_ = _userAddress;
        } else {
            require(msg.sender == _userAddress, "Buyer and msg.sender cannot be different");
            userAddress_ = msg.sender;
        }

        if (_predStruct.directionUp) bhavishPrediction.predictUp{ value: msg.value }(_predStruct.roundId, userAddress_);
        else bhavishPrediction.predictDown{ value: msg.value }(_predStruct.roundId, userAddress_);

        _populateProviderInfo(_provider, msg.value);
    }

    function predictWithGasless(PredictionStruct memory _predStruct, address _provider) external payable override {
        IBhavishPredictionNative bhavishPrediction = _getNativePredictionMap(
            predictionMap[_predStruct.underlying][_predStruct.strike]
        );
        require(address(bhavishPrediction) != address(0), "Prediction Market for the asset is not active");
        require(activePredictionMap[bhavishPrediction], "Prediction Market for the asset is not active");
        require(msg.value > minimumGaslessBetAmount, "Bet amount is not eligible for gasless");

        if (_predStruct.directionUp) bhavishPrediction.predictUp{ value: msg.value }(_predStruct.roundId, msgSender());
        else bhavishPrediction.predictDown{ value: msg.value }(_predStruct.roundId, msgSender());

        _populateProviderInfo(_provider, msg.value);
    }

    function _swapAndPredict(
        BhavishSwap.SwapStruct memory _swapStruct,
        PredictionStruct memory _predStruct,
        uint256 _slippage,
        bool _isGasless,
        address _provider
    ) internal {
        IBhavishPredictionNative bhavishPrediction = _getNativePredictionMap(
            predictionMap[_predStruct.underlying][_predStruct.strike]
        );

        require(address(bhavishPrediction) != address(0), "Prediction Market for the asset is not present");
        require(activePredictionMap[bhavishPrediction], "Prediction Market for the asset is not active");
        // Fetch the path to get the erc20 token address and transfer the amountIn to sdk contract.
        address[] memory path = bhavishSwap.getPath(_swapStruct.fromAsset, _swapStruct.toAsset);
        IERC20(path[0]).safeTransferFrom(msgSender(), address(bhavishSwap), _swapStruct.amountIn);

        uint256[] memory amounts = bhavishSwap.swapExactTokensForETH(_swapStruct, address(this), _slippage);

        if (_isGasless) {
            require(amounts[amounts.length - 1] > minimumGaslessBetAmount, "Bet amount is not eligible for gasless");
        }

        if (_predStruct.directionUp)
            bhavishPrediction.predictUp{ value: amounts[amounts.length - 1] }(_predStruct.roundId, msgSender());
        else bhavishPrediction.predictDown{ value: amounts[amounts.length - 1] }(_predStruct.roundId, msgSender());

        _populateProviderInfo(_provider, amounts[amounts.length - 1]);
    }

    function swapAndPredict(
        BhavishSwap.SwapStruct memory _swapStruct,
        PredictionStruct memory _predStruct,
        uint256 slippage,
        address _provider
    ) external override {
        _swapAndPredict(_swapStruct, _predStruct, slippage, false, _provider);
    }

    function swapAndPredictWithGasless(
        BhavishSwap.SwapStruct memory _swapStruct,
        PredictionStruct memory _predStruct,
        uint256 slippage,
        address _provider
    ) external override {
        _swapAndPredict(_swapStruct, _predStruct, slippage, true, _provider);
    }

    function _claim(
        IBhavishPrediction bhavishPredict,
        uint256[] calldata roundIds,
        address userAddress,
        IBhavishPredictionNative.SwapParams memory _swapParams
    ) internal {
        IBhavishPredictionNative(address(bhavishPredict)).claim(roundIds, userAddress, _swapParams);
    }

    function claim(
        PredictionStruct memory _predStruct,
        uint256[] calldata roundIds,
        IBhavishPredictionNative.SwapParams memory _swapParams
    ) external {
        _claim(predictionMap[_predStruct.underlying][_predStruct.strike], roundIds, msg.sender, _swapParams);
    }

    function claimWithGasless(
        PredictionStruct memory _predStruct,
        uint256[] calldata roundIds,
        IBhavishPredictionNative.SwapParams memory _swapParams
    ) external {
        IBhavishPrediction bhavishPrediction = predictionMap[_predStruct.underlying][_predStruct.strike];

        uint256 avgBetAmount = bhavishPrediction.getAverageBetAmount(roundIds, msgSender());
        require(avgBetAmount > minimumGaslessBetAmount, "Not eligible for gasless");

        _claim(bhavishPrediction, roundIds, msgSender(), _swapParams);
    }

    /**
     * @notice set the bhavish swap
     * @param _bhavishSwap bhavish swap address
     */
    function setBhavishSwap(BhavishSwap _bhavishSwap) external onlyAdmin(msg.sender) {
        require(address(_bhavishSwap).isContract(), "Swapper is not a contract");
        bhavishSwap = _bhavishSwap;
    }
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

import "./IBhavishSDK.sol";
import "./../Integrations/Swap/BhavishSwap.sol";
import { IBhavishPredictionNative } from ".././Interface/IBhavishPredictionNative.sol";

interface IBhavishNativeSDK is IBhavishSDK {
    function predict(
        PredictionStruct memory _predStruct,
        address _userAddress,
        address _provider
    ) external payable;

    function predictWithGasless(PredictionStruct memory _predStruct, address _provider) external payable;

    function swapAndPredict(
        BhavishSwap.SwapStruct memory _swapStruct,
        PredictionStruct memory _predStruct,
        uint256 slippage,
        address _provider
    ) external;

    function swapAndPredictWithGasless(
        BhavishSwap.SwapStruct memory _swapStruct,
        PredictionStruct memory _predStruct,
        uint256 slippage,
        address _provider
    ) external;

    function claim(
        PredictionStruct memory _predStruct,
        uint256[] calldata roundIds,
        IBhavishPredictionNative.SwapParams memory _swapParams
    ) external;
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

interface IBhavishPrediction {
    enum RoundState {
        CREATED,
        STARTED,
        ENDED,
        CANCELLED
    }

    struct Round {
        uint256 roundId;
        RoundState roundState;
        uint256 upPredictAmount;
        uint256 downPredictAmount;
        uint256 totalAmount;
        uint256 rewardBaseCalAmount;
        uint256 rewardAmount;
        uint256 startPrice;
        uint256 endPrice;
        uint256 roundStartTimestamp;
        uint256 roundEndTimestamp;
    }

    struct BetInfo {
        uint256 upPredictAmount;
        uint256 downPredictAmount;
        uint256 amountDispersed;
    }

    struct AssetPair {
        bytes32 underlying;
        bytes32 strike;
    }

    struct PredictionMarketStatus {
        bool startPredictionMarketOnce;
        bool createPredictionMarketOnce;
    }

    /**
     * @notice Create Round Zero round
     * @dev callable by Operator
     * @param _roundzeroStartTimestamp: round zero round start timestamp
     */
    function createPredictionMarket(uint256 _roundzeroStartTimestamp) external;

    /**
     * @notice Start Zero round
     * @dev callable by Operator
     */
    function startPredictionMarket() external;

    /**
     * @notice Execute round
     * @dev Callable by Operator
     */
    function executeRound() external;

    function getCurrentRoundDetails() external view returns (IBhavishPrediction.Round memory);

    function refundUsers(uint256 _predictRoundId, address userAddress) external;

    function getAverageBetAmount(uint256[] calldata roundIds, address userAddress) external returns (uint256);
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

import { IBhavishSDK } from "../../Interface/IBhavishSDK.sol";
import { IBhavishPrediction } from "../../Interface/IBhavishPrediction.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { BaseRelayRecipient } from "../../Integrations/Gasless/BaseRelayRecipient.sol";
import { DateTimeLibrary } from "../../Libs/DateTimeLibrary.sol";

abstract contract AbstractBhavishSDK is IBhavishSDK, BaseRelayRecipient, AccessControl {
    using Address for address;

    mapping(bytes32 => mapping(bytes32 => IBhavishPrediction)) public predictionMap;
    mapping(IBhavishPrediction => bool) public activePredictionMap;
    uint256 public decimals = 3;
    mapping(bytes32 => bool) public usersForTheMonth;
    // Month -> Amount
    mapping(uint256 => uint256) public totalWeeklyPremiumCollected;
    mapping(uint256 => uint256) public totalMonthlyPremiumCollected;
    mapping(uint256 => uint256) public totalYearlyPremiumCollected;
    mapping(uint256 => uint256) public totalBhavishAllocated;
    // Address -> Month -> Amount
    mapping(address => mapping(uint256 => uint256)) public premiumCollected;
    mapping(address => bool) public validContracts;

    /**
     * @dev minimum gasless bet amount
     */
    uint256 public override minimumGaslessBetAmount = 0.1 ether;

    modifier onlyAdmin(address _address) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _address), "SDK: caller has no access to the method");
        _;
    }

    /**
     * @notice Add funds
     */
    receive() external payable {}

    function addPredictionMarket(
        IBhavishPrediction[] memory _bhavishPrediction,
        bytes32[] memory _underlying,
        bytes32[] memory _strike
    ) external onlyAdmin(msg.sender) {
        require(_bhavishPrediction.length == _underlying.length, "Invalid array arguments passed");
        require(_strike.length == _underlying.length, "Invalid array arguments passed");
        for (uint256 i = 0; i < _bhavishPrediction.length; i++) {
            predictionMap[_underlying[i]][_strike[i]] = _bhavishPrediction[i];
            require(!activePredictionMap[_bhavishPrediction[i]], "Prediction Market is already active");
            activePredictionMap[_bhavishPrediction[i]] = true;
        }
    }

    function updatePredictionMarket(
        IBhavishPrediction _bhavishPrediction,
        bytes32 _underlying,
        bytes32 _strike
    ) external onlyAdmin(msg.sender) {
        require(address(predictionMap[_underlying][_strike]) != address(0), "Prediction market doesn't exist");
        predictionMap[_underlying][_strike] = _bhavishPrediction;
        activePredictionMap[_bhavishPrediction] = true;
    }

    function removePredictionMarket(IBhavishPrediction _bhavishPrediction) external onlyAdmin(msg.sender) {
        require(activePredictionMap[_bhavishPrediction], "Prediction market is not in active state");
        activePredictionMap[_bhavishPrediction] = false;
    }

    function setTrustedForwarder(address forwarderAddress) public onlyAdmin(msg.sender) {
        require(forwarderAddress != address(0), "SDK: Forwarder Address cannot be 0");
        trustedForwarder.push(forwarderAddress);
    }

    function removeTrustedForwarder(address forwarderAddress) public onlyAdmin(msg.sender) {
        bool found = false;
        uint256 i;
        for (i = 0; i < trustedForwarder.length; i++) {
            if (trustedForwarder[i] == forwarderAddress) {
                found = true;
                break;
            }
        }
        if (found) {
            trustedForwarder[i] = trustedForwarder[trustedForwarder.length - 1];
            trustedForwarder.pop();
        }
    }

    function versionRecipient() external view virtual override returns (string memory) {
        return "1";
    }

    function _populateProviderInfo(address _provider, uint256 _predAmt) internal {
        (, uint256 month, uint256 year, uint256 week) = DateTimeLibrary.getAll(block.timestamp);

        if (!usersForTheMonth[keccak256(abi.encode(_provider, month))]) {
            usersForTheMonth[keccak256(abi.encode(_provider, month))] = true;
            emit PredictionMarketProvider(month, _provider);
        }
        premiumCollected[_provider][month] += _predAmt;
        totalMonthlyPremiumCollected[month] += _predAmt;
        totalYearlyPremiumCollected[year] += _predAmt;
        totalWeeklyPremiumCollected[week] += _predAmt;
    }

    function setMinimumGaslessBetAmount(uint256 _amount) external onlyAdmin(msg.sender) {
        require(_amount >= 0.1 ether && _amount < 100 ether, "invalid minimum gasless premium");
        minimumGaslessBetAmount = _amount;
    }

    function _refundUsers(
        IBhavishPrediction bhavishPredict,
        uint256 roundId,
        address userAddress
    ) internal {
        bhavishPredict.refundUsers(roundId, userAddress);
    }

    function refundUsers(PredictionStruct memory _predStruct, uint256 roundId) external {
        _refundUsers(predictionMap[_predStruct.underlying][_predStruct.strike], roundId, msg.sender);
    }

    function refundUsersWithGasless(PredictionStruct memory _predStruct, uint256 roundId) external {
        IBhavishPrediction bhavishPrediction = predictionMap[_predStruct.underlying][_predStruct.strike];
        uint256[] memory roundArr = new uint256[](1);
        roundArr[0] = roundId;
        uint256 avgBetAmount = bhavishPrediction.getAverageBetAmount(roundArr, msgSender());

        require(avgBetAmount > minimumGaslessBetAmount, "Not eligible for gasless");

        _refundUsers(bhavishPrediction, roundId, msgSender());
    }

    function addContract(address _contract) external onlyAdmin(msg.sender) {
        require(_contract.isContract(), "invalid address");
        validContracts[_contract] = true;
    }

    function removeContract(address _contract) external onlyAdmin(msg.sender) {
        validContracts[_contract] = false;
    }
}

// SPDX-License-Identifier: BSD-4-Clause

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "../../Interface/IBhavishSDK.sol";

pragma solidity ^0.8.13;

contract BhavishSwap is AccessControl {
    using SafeERC20 for IERC20;

    address public UNISWAP_FACTORY;
    address public UNISWAP_ROUTER;
    mapping(bytes32 => address[]) public pathMapper;
    uint256 public decimals = 3;

    struct SwapStruct {
        uint256 amountIn;
        uint256 deadline;
        bytes32 fromAsset;
        bytes32 toAsset;
    }

    modifier onlyAsset(bytes32 fromAsset, bytes32 toAsset) {
        address[] memory path = getPath(fromAsset, toAsset);
        require(path.length > 1, "Asset swap not supported");
        _;
    }

    modifier onlyAdmin(address _address) {
        require(hasRole(DEFAULT_ADMIN_ROLE, _address), "Address not an admin");
        _;
    }

    constructor(address uniswapFactory, address uniswapRouter) {
        UNISWAP_FACTORY = uniswapFactory;
        UNISWAP_ROUTER = uniswapRouter;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Add funds
     */
    receive() external payable {}

    function setPath(
        bytes32 fromAsset,
        bytes32 toAsset,
        address[] memory path
    ) external onlyAdmin(msg.sender) {
        require(path.length > 1, "Path cannot be empty or 1");
        pathMapper[keccak256((abi.encode(fromAsset, toAsset)))] = path;
    }

    function getPath(bytes32 fromAsset, bytes32 toAsset) public view returns (address[] memory) {
        return pathMapper[keccak256(abi.encode(fromAsset, toAsset))];
    }

    // Get the amounts out for the specified path
    function getAmountsOut(
        uint256 amountIn,
        bytes32 fromAsset,
        bytes32 toAsset
    ) public view onlyAsset(fromAsset, toAsset) returns (uint256[] memory amounts) {
        address[] memory path = getPath(fromAsset, toAsset);
        amounts = new uint256[](path.length);
        amounts = IUniswapV2Router02(UNISWAP_ROUTER).getAmountsOut(amountIn, path);
    }

    function swapExactTokensForETH(
        SwapStruct memory _swapStruct,
        address to,
        uint256 slippage
    ) external onlyAsset(_swapStruct.fromAsset, _swapStruct.toAsset) returns (uint256[] memory amounts) {
        address[] memory path = getPath(_swapStruct.fromAsset, _swapStruct.toAsset);
        uint256[] memory amountsOut = getAmountsOut(_swapStruct.amountIn, _swapStruct.fromAsset, _swapStruct.toAsset);
        uint256 amountOut = amountsOut[amountsOut.length - 1] -
            ((amountsOut[amountsOut.length - 1] * slippage) / 10**decimals);
        IERC20(path[0]).safeApprove(UNISWAP_ROUTER, _swapStruct.amountIn);
        amounts = IUniswapV2Router02(UNISWAP_ROUTER).swapExactTokensForETH(
            _swapStruct.amountIn,
            amountOut,
            path,
            to,
            _swapStruct.deadline
        );
    }

    function swapExactETHForTokens(
        SwapStruct memory _swapStruct,
        address to,
        uint256 slippage
    ) external payable onlyAsset(_swapStruct.fromAsset, _swapStruct.toAsset) returns (uint256[] memory amounts) {
        address[] memory path = getPath(_swapStruct.fromAsset, _swapStruct.toAsset);
        uint256[] memory amountsOut = getAmountsOut(msg.value, _swapStruct.fromAsset, _swapStruct.toAsset);
        uint256 amountOut = amountsOut[amountsOut.length - 1] -
            ((amountsOut[amountsOut.length - 1] * slippage) / 10**decimals);
        amounts = IUniswapV2Router02(UNISWAP_ROUTER).swapExactETHForTokens{ value: msg.value }(
            amountOut,
            path,
            to,
            _swapStruct.deadline
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
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

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

interface IBhavishSDK {
    event PredictionMarketProvider(uint256 indexed _month, address indexed _provider);

    struct PredictionStruct {
        bytes32 underlying;
        bytes32 strike;
        uint256 roundId;
        bool directionUp;
    }

    function minimumGaslessBetAmount() external returns (uint256);

    function refundUsers(PredictionStruct memory _predStruct, uint256 roundId) external;
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;
import "./IBhavishPrediction.sol";

interface IBhavishPredictionNative is IBhavishPrediction {
    struct SwapParams {
        uint256 slippage;
        bytes32 toAsset;
        bytes32 fromAsset;
        bool convert;
    }

    /**
     * @notice Bet Bull position
     * @param roundId: Round Id
     * @param userAddress: Address of the user
     */
    function predictUp(uint256 roundId, address userAddress) external payable;

    /**
     * @notice Bet Bear position
     * @param roundId: Round Id
     * @param userAddress: Address of the user
     */
    function predictDown(uint256 roundId, address userAddress) external payable;

    function claim(
        uint256[] calldata _roundIds,
        address _userAddress,
        SwapParams memory _swapParams
    ) external returns (uint256);
}

pragma solidity >=0.5.0;

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

pragma solidity >=0.5.0;

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
interface IERC20Permit {
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

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.01
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018-2019. The MIT Licence.

library DateTimeLibrary {
    uint256 public constant SECONDS_PER_DAY = 24 * 60 * 60;
    int256 public constant OFFSET19700101 = 2440588;
    uint256 public constant WEEK_OFFSET = 345600;
    uint256 public constant DOW_FRI = 5;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   https://aa.usno.navy.mil/faq/JD_formula.html
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970, "Year not in range");
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);

        int256 __days = _day -
            32075 +
            (1461 * (_year + 4800 + (_month - 14) / 12)) /
            4 +
            (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
            12 -
            (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
            4 -
            OFFSET19700101;

        _days = uint256(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);

        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }

    function timestampToDay(uint256 timestamp) internal pure returns (uint256 today) {
        uint256 year;
        uint256 month;
        uint256 day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        today = _daysFromDate(year, month, day);
    }

    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function getWeek(uint256 timestamp) internal pure returns (uint256 week) {
        week = ((timestamp + WEEK_OFFSET) / SECONDS_PER_DAY) / 7;
    }

    function getDayOfWeek(uint256 timestamp) internal pure returns (uint256 dayOfWeek) {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }

    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }

    function startTimestampOfDay(
        uint256 day,
        uint256 month,
        uint256 year
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }

    function getAll(uint256 timestamp)
        internal
        pure
        returns (
            uint256 day,
            uint256 month,
            uint256 year,
            uint256 week
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        week = getWeek(timestamp);
    }

    function getPresentDayTimestamp() internal view returns (uint256 todayTimestamp) {
        (uint256 year, uint256 month, uint256 day) = timestampToDate(block.timestamp);
        todayTimestamp = DateTimeLibrary.timestampFromDate(year, month, day);
    }

    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }

    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

import "./IRelayRecipient.sol";

/**
 * A base contract to be inherited by any contract that want to receive relayed transactions
 * A subclass must use "_msgSender()" instead of "msg.sender"
 */
abstract contract BaseRelayRecipient is IRelayRecipient {
    /*
     * Forwarder singleton we accept calls from
     */

    address[] public trustedForwarder;

    /*
     * require a function to be called through GSN only
     */
    modifier trustedForwarderOnly() {
        require(isTrustedForwarder(msg.sender), "Function can only be called through the trusted Forwarder");
        _;
    }

    function isTrustedForwarder(address forwarder) public view override returns (bool) {
        for (uint256 i = 0; i < trustedForwarder.length; i++) if (forwarder == trustedForwarder[i]) return true;
        return false;
    }

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, return the original sender.
     * otherwise, return `msg.sender`.
     * should be used in the contract anywhere instead of msg.sender
     */
    function msgSender() internal view virtual override returns (address ret) {
        if (msg.data.length >= 24 && isTrustedForwarder(msg.sender)) {
            // At this point we know that the sender is a trusted forwarder,
            // so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            assembly {
                ret := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return msg.sender;
        }
    }
}

// SPDX-License-Identifier: BSD-4-Clause

pragma solidity ^0.8.13;

/**
 * a contract must implement this interface in order to support relayed transaction.
 * It is better to inherit the BaseRelayRecipient as its implementation.
 */
abstract contract IRelayRecipient {
    /**
     * return if the forwarder is trusted to forward relayed transactions to us.
     * the forwarder is required to verify the sender's signature, and verify
     * the call is not a replay.
     */
    function isTrustedForwarder(address forwarder) public view virtual returns (bool);

    /**
     * return the sender of this call.
     * if the call came through our trusted forwarder, then the real sender is appended as the last 20 bytes
     * of the msg.data.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function msgSender() internal view virtual returns (address);

    function versionRecipient() external view virtual returns (string memory);
}