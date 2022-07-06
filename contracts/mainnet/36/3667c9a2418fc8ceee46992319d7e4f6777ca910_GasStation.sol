//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./Ownable.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./EnumerableSet.sol";
import "./Math.sol";
import "./ITokensApprover.sol";
import "./FeePayerGuard.sol";
import "./EIP712Library.sol";
import "./IExchange.sol";

contract GasStation is Ownable, FeePayerGuard, EIP712Library {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    IExchange public exchange;
    ITokensApprover public approver;

    // Tokens that can be used to pay for gas
    EnumerableSet.AddressSet private _feeTokensStore;
    // Commission as a percentage of the transaction fee, for processing one transaction.
    uint256 public txRelayFeePercent;
    // Post call gas limit (Prevents overspending of gas)
    uint256 public maxPostCallGasUsage = 350000;
    // Gas usage by tokens
    mapping(address => uint256) public postCallGasUsage;
    // Transaction structure
    struct TxRequest {
        address from;
        address to;
        uint256 gas;
        uint256 nonce;
        bytes data;
        uint256 deadline;
    }
    // Transaction fee structure
    struct TxFee {
        // The token used to pay for gas
        address token;
        // Bytes string to send the token approver contract (Can be empty (0x))
        bytes approvalData;
        // Fee per gas in ETH
        uint256 feePerGas;
    }

    event GasStationTxExecuted(address indexed from, address to, address feeToken, uint256 totalFeeInTokens, uint256 txRelayFeeInEth);
    event GasStationExchangeUpdated(address indexed newExchange);
    event GasStationFeeTokensStoreUpdated(address indexed newFeeTokensStore);
    event GasStationApproverUpdated(address indexed newApprover);
    event GasStationTxRelayFeePercentUpdated(uint256 newTxRelayFeePercent);
    event GasStationMaxPostCallGasUsageUpdated(uint256 newMaxPostCallGasUsage);
    event GasStationFeeTokenAdded(address feeToken);
    event GasStationFeeTokenRemoved(address feeToken);

    constructor(address _exchange, address _approver, address _feePayer, uint256 _txRelayFeePercent, address[] memory _feeTokens)  {
        _setExchange(_exchange);
        _setApprover(_approver);
        _addFeePayer(_feePayer);
        _setTxRelayFeePercent(_txRelayFeePercent);

        for (uint256 i = 0; i < _feeTokens.length; i++) {
            _addFeeToken(_feeTokens[i]);
        }
    }

    function setExchange(address _exchange) external onlyOwner {
        _setExchange(_exchange);
    }

    function setApprover(address _approver) external onlyOwner {
        require(_approver != address(0), "Invalid approver address");
        approver = ITokensApprover(_approver);
        emit GasStationApproverUpdated(address(_approver));
    }

    function addFeeToken(address _feeToken) external onlyOwner {
        _addFeeToken(_feeToken);
    }

    function removeFeeToken(address _feePayer) external onlyOwner {
        _removeFeeToken(_feePayer);
    }

    function addFeePayer(address _feePayer) external onlyOwner {
        _addFeePayer(_feePayer);
    }

    function removeFeePayer(address _feePayer) external onlyOwner {
        _removeFeePayer(_feePayer);
    }

    function setTxRelayFeePercent(uint256 _txRelayFeePercent) external onlyOwner {
        _setTxRelayFeePercent(_txRelayFeePercent);
    }

    function setMaxPostCallGasUsage(uint256 _maxPostCallGasUsage) external onlyOwner {
        maxPostCallGasUsage = _maxPostCallGasUsage;
        emit GasStationMaxPostCallGasUsageUpdated(_maxPostCallGasUsage);
    }

    function getEstimatedPostCallGas(address _token) external view returns (uint256) {
        require(_feeTokensStore.contains(_token), "Fee token not supported");
        return _getEstimatedPostCallGas(_token);
    }

    /**
     * @notice Returns an array of addresses of tokens that can be used to pay for gas
     */
    function feeTokens() external view returns (address[] memory) {
        return _feeTokensStore.values();
    }

    /**
     * @notice Perform a transaction, take payment for gas with tokens, and exchange tokens back to ETH
     */
    function sendTransaction(TxRequest calldata _tx, TxFee calldata _fee, bytes calldata _sign) external onlyFeePayer {
        uint256 initialGas = gasleft();
        address txSender = _tx.from;
        IERC20 token = IERC20(_fee.token);

        // Verify sign and fee token
        _verify(_tx, _sign);
        require(_feeTokensStore.contains(address(token)), "Fee token not supported");

        // Execute user's transaction
        _call(txSender, _tx.to, _tx.data);

        // Total gas usage for call.
        uint256 callGasUsed = initialGas - gasleft();
        uint256 estimatedGasUsed = callGasUsed + _getEstimatedPostCallGas(address(token));
        require(estimatedGasUsed < _tx.gas, "Not enough gas");

        // Approve fee token with permit method
        _permit(_fee.token, _fee.approvalData);

        // We calculate and collect tokens to pay for the transaction
        (uint256 maxFeeInEth,) = _calculateCharge(_tx.gas, _fee.feePerGas);
        uint256 maxFeeInTokens = exchange.getEstimatedTokensForETH(token, maxFeeInEth);
        token.safeTransferFrom(txSender, address(exchange), maxFeeInTokens);

        // Exchange user's tokens to ETH and emit executed event
        (uint256 totalFeeInEth, uint256 txRelayFeeInEth) = _calculateCharge(estimatedGasUsed, _fee.feePerGas);
        uint256 spentTokens = exchange.swapTokensToETH(token, totalFeeInEth, maxFeeInTokens, msg.sender, txSender);
        emit GasStationTxExecuted(txSender, _tx.to, _fee.token, spentTokens, txRelayFeeInEth);

        // We check the gas consumption, and save it for calculation in the following transactions
        _setUpEstimatedPostCallGas(_fee.token, initialGas - gasleft() - callGasUsed);
    }

    /**
     * @notice Executes a transaction.
     * @dev Used to calculate the gas required to complete the transaction.
     */
    function execute(address from, address to, bytes calldata data) external onlyFeePayer {
        _call(from, to, data);
    }

    function _setExchange(address _exchange) internal {
        require(_exchange != address(0), "Invalid exchange address");
        exchange = IExchange(_exchange);
        emit GasStationExchangeUpdated(_exchange);
    }

    function _setApprover(address _approver) internal {
        require(_approver != address(0), "Invalid approver address");
        approver = ITokensApprover(_approver);
        emit GasStationApproverUpdated(address(_approver));
    }

    function _addFeeToken(address _token) internal {
        require(_token != address(0), "Invalid token address");
        require(!_feeTokensStore.contains(_token), "Already fee token");
        _feeTokensStore.add(_token);
        emit GasStationFeeTokenAdded(_token);
    }

    function _removeFeeToken(address _token) internal {
        require(_feeTokensStore.contains(_token), "not fee token");
        _feeTokensStore.remove(_token);
        emit GasStationFeeTokenRemoved(_token);
    }

    function _setTxRelayFeePercent(uint256 _txRelayFeePercent) internal {
        txRelayFeePercent = _txRelayFeePercent;
        emit GasStationTxRelayFeePercentUpdated(_txRelayFeePercent);
    }

    function _permit(address token, bytes calldata approvalData) internal {
        if (approvalData.length > 0 && approver.hasConfigured(token)) {
            (bool success,) = approver.callPermit(token, approvalData);
            require(success, "Permit Method Call Error");
        }
    }

    function _call(address from, address to, bytes calldata data) internal {
        bytes memory callData = abi.encodePacked(data, from);
        (bool success,) = to.call(callData);

        require(success, "Transaction Call Error");
    }

    function _verify(TxRequest calldata _tx, bytes calldata _sign) internal {
        require(_tx.deadline > block.timestamp, "Transaction expired");
        require(nonces[_tx.from]++ == _tx.nonce, "Nonce mismatch");

        address signer = _getSigner(_tx.from, _tx.to, _tx.gas, _tx.nonce, _tx.data, _tx.deadline, _sign);

        require(signer != address(0) && signer == _tx.from, 'Invalid signature');
    }

    function _getEstimatedPostCallGas(address _token) internal view returns (uint256) {
        return postCallGasUsage[_token] > 0 ? postCallGasUsage[_token] : maxPostCallGasUsage;
    }

    function _setUpEstimatedPostCallGas(address _token, uint256 _postCallGasUsed) internal {
        require(_postCallGasUsed < maxPostCallGasUsage, "Post call gas overspending");
        postCallGasUsage[_token] = Math.max(postCallGasUsage[_token], _postCallGasUsed);
    }

    function _calculateCharge(uint256 _gasUsed, uint256 _feePerGas) internal view returns (uint256, uint256) {
        uint256 feeForAllGas = _gasUsed * _feePerGas;
        uint256 totalFee = feeForAllGas * (txRelayFeePercent + 100) / 100;
        uint256 txRelayFee = totalFee - feeForAllGas;

        return (totalFee, txRelayFee);
    }
}