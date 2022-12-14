// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.2;

import "AccessControlUpgradeable.sol";
import "UUPSUpgradeable.sol";
import "PausableUpgradeable.sol";
import "SafeERC20.sol";
import "ERC20.sol";
import { Address } from "Address.sol";
import { XYWrappedToken } from "XYWrappedToken.sol";
import "IGasPriceConsumer.sol";

/// @title YPoolVault provides cross-chain liquidity for swap between chains.
/// Users are allowed to supply the designated deposit token to the pool to earn
/// cross-chain swap fees, and request to withdraw anytime.
contract YPoolVault is AccessControlUpgradeable, UUPSUpgradeable, PausableUpgradeable {
    using SafeERC20 for IERC20;

    /* ========== STRUCTURE ========== */

    // request to deposit
    struct DepositRequest {
        // amount of the deposit token
        uint256 amountDepositToken;
        // depositor
        address sender;
        // is the request completed yet
        bool isComplete;
    }

    // request to withdraw
    struct WithdrawalRequest {
        // amount of xy-wrapped token to be withdrawn
        uint256 amountXYWrappedToken;
        // withdrawer
        address sender;
        // is the request completed yet
        bool isComplete;
    }

    /* ========== STATE VARIABLES ========== */

    // Roles in this contract
    // Owner: able to upgrade contract and change swapper contract address
    bytes32 public constant ROLE_OWNER = keccak256("ROLE_OWNER");
    // Manager: able to pause/unpause contract, set gas provider / gas collector address
    bytes32 public constant ROLE_MANAGER = keccak256("ROLE_MANAGER");
    // Staff: able to set required gas for different requests
    bytes32 public constant ROLE_STAFF = keccak256("ROLE_STAFF");
    // Liquidity Worker: complete the requests
    bytes32 public constant ROLE_LIQUIDITY_WORKER = keccak256("ROLE_LIQUIDITY_WORKER");

    // Native token address
    address public constant ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // XY token deciamls
    uint256 public constant XY_TOKEN_DECIMALS = 18;
    // Yield rate decimals
    uint256 public constant YIELD_RATE_DECIMALS = 8;
    // Base point (the denominator) of the reserves ratio. 1 base point means 0.01%.
    uint256 public constant BASE_POINT_RESERVES_RATIO = 10000;

    // Max yield rate bound of deposit/withdraw
    uint256 public maxYieldRateBound;
    // Min yield rate bound of deposit/withdraw
    uint256 public minYieldRateBound;

    // Swapper address
    address public swapper;
    // The address receive the collected gas fee
    address public gasFeeReceiver;
    // The address of token to deposit
    IERC20 public depositToken;
    // Deposit token decimal
    uint8 public depositTokenDecimal;
    // XY-Wrapped token address
    XYWrappedToken public xyWrappedToken;

    // Address of gas consumer
    address public gasPriceConsumer;
    // Gas limit that YPool need to proceed deposit request
    uint256 public completeDepositGasLimit;
    // Gas limit that YPool need to proceed withdraw request
    uint256 public completeWithdrawGasLimit;
    // Current fees collected from deposit and withdraw request gas fee
    uint256 public depositAndWithdrawFees;
    // Swap fees current accumulated
    uint256 public closeSwapGasFees;
    // Number of the deposits
    uint256 public numDeposits;
    // Number of the withdrawal
    uint256 public numWithdrawals;

    // The numerator of the reserves ratio. Reserves ratio is the ratio of XY Fee kept by Y Pool as reserves,
    // and is calcuated by `reservesRate / BASE_POINT_RESERVES_RATIO`.
    // For example, if `reservesRate` is 1, the reserves ratio is `1 / BASE_POINT_RESERVES_RATIO = 0.01%`.
    uint256 public reservesRate;
    // Address who receives the reserves.
    address public reservesReceiver;

    // Mapping of the depsit ID to deposit request struct
    mapping (uint256 => DepositRequest) public depositRequests;
    // Mapping of the withdraw ID to withdraw request struct
    mapping (uint256 => WithdrawalRequest) public withdrawalRequests;

    receive() external payable {}

    function _authorizeUpgrade(address) internal override onlyRole(ROLE_OWNER) {}

    /// @notice Initialize YPoolVault by owner, manager, staff, liquidity worker, deposit token address, wrapped token address, and deposit token decimal
    /// @param owner The owner address
    /// @param manager The manager address
    /// @param staff The staff address
    /// @param liquidityWorker The liquidity worker address
    /// @param _depositToken The deposit token address
    /// @param _xyWrappedToken The XY-Wrapped token address
    /// @param _depositTokenDecimal The deposit token decimal
    function initialize(address owner, address manager, address staff, address liquidityWorker, address _depositToken, address _xyWrappedToken, uint8 _depositTokenDecimal) initializer public {
        if (_depositToken != ETHER_ADDRESS) {
            require(Address.isContract(_depositToken), "ERR_DEPOSIT_TOKEN_NOT_CONTRACT");
        }
        require(Address.isContract(_xyWrappedToken), "ERR_XY_WRPAPPED_TOKEN_NOT_CONTRACT");
        depositToken = IERC20(_depositToken);
        xyWrappedToken = XYWrappedToken(_xyWrappedToken);

        depositTokenDecimal = _depositTokenDecimal;

        _setRoleAdmin(ROLE_OWNER, ROLE_OWNER);
        _setRoleAdmin(ROLE_MANAGER, ROLE_OWNER);
        _setRoleAdmin(ROLE_STAFF, ROLE_OWNER);
        _setRoleAdmin(ROLE_LIQUIDITY_WORKER, ROLE_OWNER);
        _setupRole(ROLE_OWNER, owner);
        _setupRole(ROLE_MANAGER, manager);
        _setupRole(ROLE_STAFF, staff);
        _setupRole(ROLE_LIQUIDITY_WORKER, liquidityWorker);
    }

    /* ========== MODIFIERS ========== */

    modifier onlySwapper() {
        require(msg.sender == swapper, "ERR_NOT_SWAPPER");
        _;
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    /// @notice Get currnet gas price from price consumer
    function _getGasPrice() private view returns (uint256) {
        require(gasPriceConsumer != address(0), "ERR_GAS_PRICE_CONSUMER_NOT_SET");
        return uint256(IGasPriceConsumer(gasPriceConsumer).getLatestGasPrice());
    }

    /// @notice Unify transfer interface for native token and ERC20 token
    /// @param receiver The address to reveice token
    /// @param token The token to be transferred
    /// @param amount Amount of the token to be transferred
    function _safeTransferAsset(address receiver, IERC20 token, uint256 amount) private {
        if (address(token) == ETHER_ADDRESS) {
            payable(receiver).transfer(amount);
        } else {
            token.safeTransfer(receiver, amount);
        }
    }

    /// @notice Transfer ERC20 token from sender to receiver
    /// @param token The token to be transferred
    /// @param sender The address to transfer token from
    /// @param receiver The address to receive token
    /// @param amount Amount of the token to be transferred
    function _safeTransferAssetFrom(IERC20 token, address sender, address receiver, uint256 amount) private {
        require(address(token) != ETHER_ADDRESS, "ERR_TOKEN_ADDRESS");
        uint256 bal = token.balanceOf(receiver);
        token.safeTransferFrom(sender, receiver, amount);
        bal = token.balanceOf(receiver) - bal;
        require(bal == amount, "ERR_AMOUNT_NOT_ENOUGH");
    }

    /// @notice Transfer collected deposit and withdraw request fees to receiver
    /// @param receiver The address to receive fees
    function _collectDepositAndWithdrawGasFees(address receiver) private {
        uint256 _depositAndWithdrawFees = depositAndWithdrawFees;
        depositAndWithdrawFees = 0;
        payable(receiver).transfer(_depositAndWithdrawFees);
        emit DepositAndWithdrawGasFeesCollected(receiver, _depositAndWithdrawFees);
    }

    /// @notice Transfer collected swap fees to receiver
    /// @param receiver The address to receive fees
    function _collectCloseSwapGasFees(address receiver) private {
        uint256 _closeSwapGasFees = closeSwapGasFees;
        closeSwapGasFees = 0;
        if (address(depositToken) == ETHER_ADDRESS) {
            payable(receiver).transfer(_closeSwapGasFees);
        } else {
            depositToken.safeTransfer(receiver, _closeSwapGasFees);
        }
        emit CloseSwapGasFeesCollected(depositToken, receiver, _closeSwapGasFees);
    }

    /* ========== RESTRICTED FUNCTIONS (OWNER) ========== */

    /// @notice Connect YPoolVault to a certain XSwapper (could be set only by owner)
    /// @param _swapper New swapper address
    function setSwapper(address _swapper) external onlyRole(ROLE_OWNER) {
        require(Address.isContract(_swapper), "ERR_SWAPPER_NOT_CONTRACT");
        swapper = _swapper;
    }

    /// @notice Rescue fund accidentally sent to this contract. Can not rescue deposit token or xyWrappedToken
    /// @param tokens List of token address to rescue
    function rescue(IERC20[] memory tokens) external onlyRole(ROLE_OWNER) {
        for (uint256 i; i < tokens.length; i++) {
            IERC20 token = tokens[i];
            require(token != depositToken, "ERR_CAN_NOT_RESCUE_DEPOSIT_TOKEN");
            require(address(token) != address(xyWrappedToken), "ERR_CAN_NOT_RESCUE_XY_WRAPPED_TOKEN");
            uint256 _tokenBalance = token.balanceOf(address(this));
            token.safeTransfer(msg.sender, _tokenBalance);
        }
    }

    /* ========== RESTRICTED FUNCTIONS (MANAGER) ========== */

    /// @notice Set new gas fee receiver. This address receives fees accumulated from deposit / withdraw
    /// requests and swap fees when staff role calls one of the collect fee methods. (could be set only by manager)
    /// @param _gasFeeReceiver New gas receiver address
    function setGasFeeReceiver(address _gasFeeReceiver) external onlyRole(ROLE_MANAGER) {
        gasFeeReceiver = _gasFeeReceiver;
    }

    /// @notice Set the reserves rate. Reserves rate is the numerator of the reserves ratio.
    /// @dev Can only be called by `ROLE_MANAGER`
    /// @param _reservesRate New reserves rate
    function setReservesRate(uint256 _reservesRate) external onlyRole(ROLE_MANAGER) {
        require(_reservesRate <= BASE_POINT_RESERVES_RATIO, "ERR_RESERVES_RATIO_NOT_LESS_THAN_OR_EQUAL_1");
        reservesRate = _reservesRate;
        emit ReservesRateSet(_reservesRate);
    }

    /// @notice Set reserves receiver. This address receives a portion of xy fees accumulated from cross-chain swaps
    /// @dev Can only be called by `ROLE_MANAGER`
    /// @param _reservesReceiver New reserves receiver address
    function setReservesReceiver(address _reservesReceiver) external onlyRole(ROLE_MANAGER) {
        require(_reservesReceiver != address(0), "ERR_ZERO_ADDRESS");
        reservesReceiver = _reservesReceiver;
        emit ReservesReceiverSet(_reservesReceiver);
    }

    /// @notice Set new gas price consumer address that conforms to `IGasPriceConsumer` protocol (could be set only by manager)
    /// @param _gasPriceConsumer New gas price consumer address
    function setGasPriceConsumer(address _gasPriceConsumer) external onlyRole(ROLE_MANAGER) {
        require(Address.isContract(_gasPriceConsumer), "ERR_GAS_PRICE_CONSUMER_NOT_CONTRACT");
        gasPriceConsumer = _gasPriceConsumer;
    }

    /// @notice Set maximum and minimum value of yield rate bound. (could be set only by manager)
    /// These bounds are to make sure the withdraw amount and deposit amount are within a safe range of yields
    /// as unexpected amounts would lead to false yield rate.
    /// This is particularly useful if the Y Pool worker is unfortunately compromised in the worst case.
    /// The bounds can be loosened gradually if there are more fees accumulated and the yield rate has increased.
    /// @param _maxYieldRateBound Maximum yield rate bound
    /// @param _minYieldRateBound Minimum yield rate bound
    function setYieldRateBound(uint256 _maxYieldRateBound, uint256 _minYieldRateBound) external onlyRole(ROLE_MANAGER) {
        require(_maxYieldRateBound >= 10 ** YIELD_RATE_DECIMALS);
        maxYieldRateBound = _maxYieldRateBound;
        minYieldRateBound = _minYieldRateBound;
    }

    /// @notice Pause YPool vault (could be executed only by manager)
    function pause() external onlyRole(ROLE_MANAGER) {
        _pause();
    }

    /// @notice Unpause YPool vault (could be executed only by manager)
    function unpause() external onlyRole(ROLE_MANAGER) {
        _unpause();
    }

    /* ========== RESTRICTED FUNCTIONS (STAFF) ========== */

    /// @notice Set deposit gas limit. This is one of the factors to determine how much gas fee should user paid
    /// upon the deposit request. (could be set only by staff)
    /// @dev Request fee is calculated as `completeDepositGasLimit` * gas price provided from `gasPriceConsumer`
    /// @param gasLimit New deposit gas limit
    function setCompleteDepositGasLimit(uint256 gasLimit) external onlyRole(ROLE_STAFF) {
        completeDepositGasLimit = gasLimit;
    }

    /// @notice Set withdraw gas limit. This is one of the factors to determine how much gas fee should user paid
    /// upon the withdraw request. (could be set only by staff)
    /// @dev Request fee is calculated as `completeWithdrawGasLimit` * gas price provided from `gasPriceConsumer`
    /// @param gasLimit New withdraw gas limit
    function setCompleteWithdrawGasLimit(uint256 gasLimit) external onlyRole(ROLE_STAFF) {
        completeWithdrawGasLimit = gasLimit;
    }

    /// @notice Transfer current accumulated deposit / withdraw request fees to `gasFeeReceiver` (could be executed only by staff)
    function collectDepositAndWithdrawGasFees() external whenNotPaused onlyRole(ROLE_STAFF) {
        _collectDepositAndWithdrawGasFees(gasFeeReceiver);
    }

    /// @notice Transfer current accumulated swap fees to `gasFeeReceiver` (could be executed only by staff)
    function collectCloseSwapGasFees() external whenNotPaused onlyRole(ROLE_STAFF) {
        _collectCloseSwapGasFees(gasFeeReceiver);
    }

    /// @notice Transfer current accumulated deposit / withdraw request fees and swap fees to `gasFeeReceiver` (could be executed only by staff)
    function collectFees() external whenNotPaused onlyRole(ROLE_STAFF) {
        _collectDepositAndWithdrawGasFees(gasFeeReceiver);
        _collectCloseSwapGasFees(gasFeeReceiver);
    }

    /* ========== RESTRICTED FUNCTIONS (SWAPPER) ========== */

    /// @notice Transfer token from YPool liquidity to swapper contract. (could be executed only by swapper)
    /// XSwapper calls this method within `closeSwap` to transfer token from YPool liquidity to swapper
    /// contract in order to close a cross-chain swap request. See XSwapper.sol for more info.
    /// @param token Token to be transferred
    /// @param amount Amount of token to be transferred
    function transferToSwapper(IERC20 token, uint256 amount) external whenNotPaused onlySwapper {
        require(token == depositToken, "ERR_TRANSFER_WRONG_TOKEN_TO_SWAPPER");
        emit TransferToSwapper(swapper, token, amount);
        _safeTransferAsset(swapper, token, amount);
    }

    /// @notice Transfer token from swapper contract to YPool. (could be executed only by swapper)
    /// XSwapper calls this method within `claim` or `batchClaim` to transfer token from XSwapper to YPool
    /// contract in order to claim token back to YPool after liquidity worker completed a cross-chain request.
    /// See XSwapper.sol for more info.
    /// @param token Token to be transferred
    /// @param amount Amount of token to be transferred
    /// @param xyFeeAmount Amount of xyFee colleted
    /// @param gasFeeAmount Amount of gas fee colleted
    function receiveAssetFromSwapper(IERC20 token, uint256 amount, uint256 xyFeeAmount, uint256 gasFeeAmount) external payable whenNotPaused onlySwapper {
        require(token == depositToken, "ERR_TRANSFER_WRONG_TOKEN_FROM_SWAPPER");
        if (address(token) == ETHER_ADDRESS) {
            require(msg.value == amount, "ERR_INVALID_AMOUNT");
        } else {
            _safeTransferAssetFrom(token, swapper, address(this), amount);
        }

        closeSwapGasFees += gasFeeAmount;

        uint256 xyFeeReserves = calculateReserves(xyFeeAmount);

        emit AssetReceived(token, amount, xyFeeAmount, gasFeeAmount, xyFeeReserves);

        _safeTransferAsset(reservesReceiver, token, xyFeeReserves);
    }

    /* ========== RESTRICTED FUNCTIONS (LIQUIDITY WORKER) ========== */

    /// @notice Complete a deposit request by minting XY-Wrapped tokens
    /// according to liquidity condition on settlement chain. (could be executed only by liquidity worker)
    /// @param _depositId The deposit ID to be processed
    /// @param amountXYWrappedToken Amount of XY-Wrapped token to be minted
    function completeDeposit(uint256 _depositId, uint256 amountXYWrappedToken) external whenNotPaused onlyRole(ROLE_LIQUIDITY_WORKER) {
        require(_depositId < numDeposits, "ERR_INVALID_DEPOSIT_ID");
        DepositRequest storage request = depositRequests[_depositId];
        require(!request.isComplete, "ERR_DEPOSIT_ALREADY_COMPLETE");
        // yield rate = (amount ypool token) / (amount wrapped token)
        require(request.amountDepositToken * 10 ** (YIELD_RATE_DECIMALS + XY_TOKEN_DECIMALS - depositTokenDecimal) / amountXYWrappedToken <= maxYieldRateBound, "ERR_YIELD_RATE_OUT_OF_MAX_BOUND");
        require(request.amountDepositToken * 10 ** (YIELD_RATE_DECIMALS + XY_TOKEN_DECIMALS - depositTokenDecimal) / amountXYWrappedToken >= minYieldRateBound, "ERR_YIELD_RATE_OUT_OF_MIN_BOUND");
        emit DepositFulfilled(request.sender, _depositId, amountXYWrappedToken);
        request.isComplete = true;
        xyWrappedToken.mint(request.sender, amountXYWrappedToken);
    }

    /// @notice Complete a withdraw request by burning XY-Wrapped tokens
    /// and transferring back deposit token according to liquidity condition on settlement chain
    /// (could be executed only by liquidity worker)
    /// @param _withdrawId The withdraw ID to be processed
    /// @param amount Amount of the deposit token to be returned to request sender
    /// @param withdrawFee Fee for completing withdraw request
    function completeWithdraw(uint256 _withdrawId, uint256 amount, uint256 withdrawFee) external whenNotPaused onlyRole(ROLE_LIQUIDITY_WORKER) {
        require(_withdrawId < numWithdrawals, "ERR_INVALID_WITHDRAW_ID");
        require(amount > 0, "ERR_WITHDRAW_FEE_NOT_LESS_THAN_AMOUNT");
        WithdrawalRequest storage request = withdrawalRequests[_withdrawId];
        require(!request.isComplete, "ERR_ALREADY_COMPLETED");
        // yield rate = (amount ypool token) / (amount wrapped token)
        require((amount + withdrawFee) * 10 ** (YIELD_RATE_DECIMALS + XY_TOKEN_DECIMALS - depositTokenDecimal) / request.amountXYWrappedToken <= maxYieldRateBound, "ERR_YIELD_RATE_OUT_OF_MAX_BOUND");
        require((amount + withdrawFee) * 10 ** (YIELD_RATE_DECIMALS + XY_TOKEN_DECIMALS - depositTokenDecimal) / request.amountXYWrappedToken >= minYieldRateBound, "ERR_YIELD_RATE_OUT_OF_MIN_BOUND");
        emit WithdrawalFulfilled(request.sender, _withdrawId, amount, withdrawFee);
        request.isComplete = true;
        xyWrappedToken.burn(request.amountXYWrappedToken);
        _safeTransferAsset(request.sender, depositToken, amount);
    }

    /* ========== WRITE FUNCTIONS ========== */

    /// @notice Request to deposit
    /// @dev Gas fee is required and checked upon the deposit request based on current gas
    /// price and deposit gas limit.
    /// @param amount Amount of deposit token to deposit
    function deposit(uint256 amount) external whenNotPaused payable {
        require(amount > 0, "ERR_INVALID_DEPOSIT_AMOUNT");
        uint256 gasFee = completeDepositGasLimit * _getGasPrice();
        uint256 requiredValue = (address(depositToken) == ETHER_ADDRESS) ? gasFee + amount : gasFee;
        require(msg.value >= requiredValue, "ERR_NOT_ENOUGH_FEE");

        depositAndWithdrawFees += gasFee;
        uint256 id = numDeposits++;
        depositRequests[id] = DepositRequest(amount, msg.sender, false);
        payable(msg.sender).transfer(msg.value - requiredValue);
        if (address(depositToken) != ETHER_ADDRESS) {
            _safeTransferAssetFrom(depositToken, msg.sender, address(this), amount);
        }

        emit DepositRequested(msg.sender, id, amount, gasFee);
    }

    /// @notice Request to withdraw
    /// @dev Gas fee is required and checked upon the withdraw request based on current gas
    /// price and withdraw gas limit.
    /// @param amountXYWrappedToken Amount of XY-Wrapped token used to withdraw
    function withdraw(uint256 amountXYWrappedToken) external payable whenNotPaused {
        require(amountXYWrappedToken > 0, "ERR_INVALID_WITHDRAW_AMOUNT");
        uint256 gasFee = completeWithdrawGasLimit * _getGasPrice();
        require(msg.value >= gasFee, "ERR_NOT_ENOUGH_FEE");

        depositAndWithdrawFees += gasFee;
        uint256 id = numWithdrawals++;
        withdrawalRequests[id] = WithdrawalRequest(amountXYWrappedToken, msg.sender, false);
        payable(msg.sender).transfer(msg.value - gasFee);
        _safeTransferAssetFrom(xyWrappedToken, msg.sender, address(this), amountXYWrappedToken);
        emit WithdrawalRequested(msg.sender, id, amountXYWrappedToken, gasFee);
    }

    /* ========== READ-ONLY FUNCTIONS ========== */

    /// @notice Calculate the the expected reserves given `xyFee`.
    /// @param xyFee xy fee amount
    function calculateReserves(uint256 xyFee) public view returns (uint256) {
        return xyFee * reservesRate / BASE_POINT_RESERVES_RATIO;
    }

    /* ========== EVENTS ========== */

    event TransferToSwapper(address swapper, IERC20 token, uint256 amount);
    event DepositRequested(address indexed sender, uint256 indexed depositId, uint256 amountDepositToken, uint256 gasFee);
    event DepositFulfilled(address indexed recipient, uint256 indexed depositId, uint256 amountXYWrappedToken);
    event WithdrawalRequested(address indexed sender, uint256 indexed withdrawId, uint256 amountXYWrappedToken, uint256 gasFee);
    event WithdrawalFulfilled(address indexed recipient, uint256 indexed withdrawId, uint256 amountDepositToken, uint256 withdrawFee);
    event AssetReceived(IERC20 token, uint256 assetAmount, uint256 xyFeeAmount, uint256 gasFeeAmount, uint256 xyFeeReserves);
    event DepositAndWithdrawGasFeesCollected(address recipient, uint256 gasFees);
    event CloseSwapGasFeesCollected(IERC20 token, address recipient, uint256 gasFees);
    event ReservesRateSet(uint256 _reservesRate);
    event ReservesReceiverSet(address _reservesReceiver);
}