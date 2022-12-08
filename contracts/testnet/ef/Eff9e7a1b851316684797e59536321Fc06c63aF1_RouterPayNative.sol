// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts-newone/access/Ownable.sol";
import "@openzeppelin/contracts-newone/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts-newone/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-newone/utils/Counters.sol";
import "../utils/draft-EIP-712.sol";
import "../interfaces/ICurveProxy.sol";
import "../interfaces/IPortal.sol";
import "../interfaces/ISynthesis.sol";
import "../interfaces/IERC20WithPermit.sol";

contract RouterPayNative is EIP712, Ownable {
    using Counters for Counters.Counter;

    address _curveProxy;
    address _curveProxyV2;
    address _portal;
    address _synthesis;

    bytes32 public constant _SYNTHESIZE_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("synthesizeRequest"));
    bytes32 public constant _UNSYNTHESIZE_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("unsynthesizeRequest"));
    bytes32 public constant _SYNTH_TRANSFER_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("synthTransferRequest"));

    bytes32 public constant _SYNTH_BATCH_MINT_EUSD_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("synthBatchAddLiquidity3PoolMintEUSDRequest"));

    bytes32 public constant _SYNTH_BATCH_META_EXCHANGE_SWAP_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("synthBatchMetaExchangeWithSwapRequestWithPermit"));

    bytes32 public constant _SYNTH_BATCH_META_EXCHANGE_UNWRAP_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("synthBatchMetaExchangeWithUnwrapRequestWithPermit"));  

    bytes32 public constant _SYNTH_BATCH_META_EXCHANGE_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("synthBatchMetaExchangeRequest"));

    bytes32 public constant _LOCAL_META_EXCHANGE_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("metaExchangeRequestVia3pool"));

    bytes32 public constant _REDEEM_EUSD_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("redeemEusdRequest"));

    bytes32 public constant _TOKEN_SWAP_META_EXCHANGE_REQUEST_SIGNATURE_HASH =
        keccak256(abi.encodePacked("tokenSwapWithMetaExchangeRequestPayNative"));
    
    bytes32 public constant _UNSYNTHESIZE_WITH_META_EXCHANGE_REQUEST = 
        keccak256(abi.encodePacked("unsynthesizeWithMetaExchangeRequest"));

    bytes32 public constant _MINT_EUSD_REQUEST = 
        keccak256(abi.encodePacked("mintEusdRequestVia3pool"));
    
    bytes32 public constant _TOKEN_SWAP_HASH =
        keccak256(abi.encodePacked("tokenSwap"));

    bytes32 public constant _TOKEN_SWAP_UNWRAP_HASH =
        keccak256(abi.encodePacked("tokenSwapUnwrap"));

    bytes32 public constant _REMOVE_LIQUIDITY_HASH =
        keccak256(abi.encodePacked("removeLiquidity"));

    mapping(address => bool) public _trustedWorker;
    mapping(address => Counters.Counter) private _nonces;

    event CrosschainPaymentEvent(address indexed userFrom, address indexed worker, uint256 executionPrice);

    struct DelegatedCallReceipt {
        uint256 executionPrice;
        uint256 aggregationFee;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    constructor(
        address portal,
        address synthesis,
        address curveProxy,
        address curveProxyV2,
        uint256 chainID
    ) EIP712("EYWA", "1", chainID) {
        require(portal != address(0), "Router: portal zero address");
        require(synthesis != address(0), "Router: synthesis zero address");
        require(curveProxy != address(0), "Router: curveProxy zero address");
        _portal = portal;
        _synthesis = synthesis;
        _curveProxy = curveProxy;
        _curveProxyV2 = curveProxyV2;
    }

    function setTrustedWorker(address worker) public onlyOwner {
        _trustedWorker[worker] = true;
    }

    function removeTrustedWorker(address worker) public onlyOwner {
        _trustedWorker[worker] = false;
    }

    function _checkWorkerSignature(
        uint256 chainIdTo,
        bytes32 executionHash,
        address uniswapRouter,
        DelegatedCallReceipt calldata receipt
    ) internal returns (address worker) {
        uint256 nonce = _useNonce(msg.sender);
        bytes32 workerStructHash = keccak256(
            abi.encodePacked(
                keccak256(
                    "DelegatedCallWorkerPermit(address from,uint256 chainIdTo,uint256 executionPrice,bytes32 executionHash,address uniswapRouter,uint256 aggregationFee,uint256 nonce,uint256 deadline)"
                ),
                msg.sender,
                chainIdTo,
                receipt.executionPrice,
                executionHash,
                receipt.aggregationFee,
                uniswapRouter,
                nonce,
                receipt.deadline
            )
        );

        bytes32 workerHash = ECDSA.toEthSignedMessageHash(_hashTypedDataV4(workerStructHash));
        worker = ECDSA.recover(workerHash, receipt.v, receipt.r, receipt.s);

        require(block.timestamp <= receipt.deadline, "Router: deadline");
        require(_trustedWorker[worker], "Router: invalid signature from worker");
    }

    function _proceedFees(uint256 executionPrice, address worker) internal {
        // worker fee
        require(msg.value >= executionPrice, "Router: invalid amount");
        (bool sent, ) = worker.call{ value: msg.value }("");
        require(sent, "Router: failed to send Ether");

        emit CrosschainPaymentEvent(msg.sender, worker, executionPrice);
    }

    //==============================PORTAL==============================
    /**
     * @dev Token synthesize request to another EVM chain via native payment.
     * @param token token address to synthesize
     * @param amount amount to synthesize
     * @param to amount recipient address
     * @param synthParams crosschain parameters
     * @param receipt delegated call receipt from worker
     */
    function synthesizeRequestPayNative(
        address token,
        uint256 amount,
        address to,
        IPortal.SynthParams calldata synthParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTHESIZE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, _portal, amount);
        IPortal(_portal).synthesize(token, amount, msg.sender, to, synthParams);
    }

    /**
     * @dev Token synthesize request with permit to another EVM chain via native payment.
     * @param token token address to synthesize
     * @param amount amount to synthesize
     * @param to amount recipient address
     * @param synthParams crosschain parameters
     * @param permitData permit data
     * @param receipt delegated call receipt from worker
     */
    function synthesizeRequestWithPermitPayNative(
        address token,
        uint256 amount,
        address to,
        IPortal.SynthParams calldata synthParams,
        IPortal.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTHESIZE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        IERC20WithPermit(token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );

        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, _portal, amount);
        IPortal(_portal).synthesize(token, amount, msg.sender, to, synthParams);
    }

    //==============================SYNTHESIS==============================
    /**
     * @dev Synthetic token transfer request to another EVM chain via native payment.
     * @param tokenSynth synth token address
     * @param amount amount to transfer
     * @param to recipient address
     * @param synthParams crosschain parameters
     * @param receipt delegated call receipt from worker
     */
    function synthTransferRequestPayNative(
        address tokenSynth,
        uint256 amount,
        address to,
        ISynthesis.SynthParams calldata synthParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_TRANSFER_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenSynth), msg.sender, address(this), amount);
        ISynthesis(_synthesis).synthTransfer(tokenSynth, amount, msg.sender, to, synthParams);
    }

    /**
     * @dev Synthetic token transfer request with permit to another EVM chain via native payment.
     * @param tokenSynth synth token address
     * @param amount amount to transfer
     * @param to recipient address
     * @param synthParams crosschain parameters
     * @param permitData permit data
     * @param receipt delegated call receipt from worker
     */
    function synthTransferRequestWithPermitPayNative(
        address tokenSynth,
        uint256 amount,
        address to,
        ISynthesis.SynthParams calldata synthParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_TRANSFER_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenSynth).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenSynth), msg.sender, address(this), amount);
        ISynthesis(_synthesis).synthTransfer(tokenSynth, amount, msg.sender, to, synthParams);
    }

    /**
     * @dev Unsynthesize request to another EVM chain via native payment.
     * @param tokenSynth synthetic token address for unsynthesize
     * @param amount amount to unsynth
     * @param to recipient address
     * @param synthParams crosschain parameters
     * @param receipt delegated call receipt from worker
     */
    function unsynthesizeRequestPayNative(
        address tokenSynth,
        uint256 amount,
        address to,
        ISynthesis.SynthParams calldata synthParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _UNSYNTHESIZE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenSynth), msg.sender, address(this), amount);
        ISynthesis(_synthesis).burnSyntheticToken(tokenSynth, amount, msg.sender, to, synthParams);
    }

    /**
     * @dev Unsynthesize request to another EVM chain via native payment.
     * @param tokenSynth synthetic token address for unsynthesize
     * @param amount amount to unsynth
     * @param to recipient address
     * @param synthParams crosschain parameters
     * @param permitData permit data
     * @param receipt delegated call receipt from worker
     */
    function unsynthesizeRequestWithPermitPayNative(
        address tokenSynth,
        uint256 amount,
        address to,
        ISynthesis.SynthParams calldata synthParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _UNSYNTHESIZE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenSynth).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenSynth), msg.sender, address(this), amount);
        ISynthesis(_synthesis).burnSyntheticToken(tokenSynth, amount, msg.sender, to, synthParams);
    }

    function unsynthesizeWithMetaExchangePayNative(
        IPortal.SynthesizeParams calldata _tokenParams,
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParams calldata _synthParams,
        DelegatedCallReceipt calldata receipt,
        uint256 _coinIndex
    ) external payable {
        address worker = _checkWorkerSignature(_synthParams.chainId, _UNSYNTHESIZE_WITH_META_EXCHANGE_REQUEST, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        ICurveProxy.FeeParams memory feeParams = ICurveProxy.FeeParams(
            address(0),
            0,
            _coinIndex
        );
        SafeERC20.safeTransferFrom(IERC20(_tokenParams.token), msg.sender, address(this), _tokenParams.amount);
        ISynthesis(_synthesis).burnSyntheticTokenWithMetaExchange(_tokenParams, _exchangeParams, _params, _finalSynthParams, _synthParams, feeParams);
    }

    function unsynthesizeWithMetaExchangeWithPermitPayNative(
        IPortal.SynthesizeParams calldata _tokenParams,
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParams calldata _synthParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt,
        uint256 _coinIndex
    ) external payable {
        address worker = _checkWorkerSignature(_synthParams.chainId, _UNSYNTHESIZE_WITH_META_EXCHANGE_REQUEST, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        ICurveProxy.FeeParams memory feeParams = ICurveProxy.FeeParams(
            address(0),
            0,
            _coinIndex
        );
        IERC20WithPermit(_tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : _tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(_tokenParams.token), msg.sender, address(this), _tokenParams.amount);
        ISynthesis(_synthesis).burnSyntheticTokenWithMetaExchange(_tokenParams, _exchangeParams, _params, _finalSynthParams, _synthParams, feeParams);
    }
    
/////////////////////////////
    function synthBatchAddLiquidity3PoolMintEUSDRequestPayNative(
        address from,
        IPortal.SynthParams memory synthParams,
        ICurveProxy.MetaMintEUSD memory metaParams,
        DelegatedCallReceipt calldata receipt,
        ICurveProxy.TokenInput calldata tokenParams
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_MINT_EUSD_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);
        IPortal(_portal).synthBatchAddLiquidity3PoolMintEUSD(
            from,
            synthParams,
            metaParams,
            tokenParams
        );
    }

    function synthBatchMetaExchangeRequestPayNative(
        address from,
        IPortal.SynthParams memory synthParams,
        ICurveProxy.MetaExchangeParams memory metaParams,
        DelegatedCallReceipt calldata receipt,
        ICurveProxy.TokenInput calldata tokenParams
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_META_EXCHANGE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);
        IPortal(_portal).synthBatchMetaExchange(from, synthParams, metaParams, tokenParams);
    }

    function synthBatchAddLiquidity3PoolMintEUSDRequestWithPermitPayNative(
        address from,
        IPortal.SynthParams memory synthParams,
        ICurveProxy.MetaMintEUSD memory metaParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt,
        ICurveProxy.TokenInput calldata tokenParams
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_MINT_EUSD_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);

        IPortal(_portal).synthBatchAddLiquidity3PoolMintEUSD(
            from,
            synthParams,
            metaParams,
            tokenParams
        );
    }

    function synthBatchMetaExchangeRequestWithPermitPayNative(
        address from,
        IPortal.SynthParams memory synthParams,
        ICurveProxy.MetaExchangeParams memory metaParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt,
        ICurveProxy.TokenInput calldata tokenParams
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_META_EXCHANGE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);
        IPortal(_portal).synthBatchMetaExchange(from, synthParams, metaParams, tokenParams);
    }

     function synthBatchMetaExchangeWithSwapRequestWithPermitPayNative(
        ICurveProxy.TokenInput calldata tokenParams,
        IPortal.SynthParamsMetaSwap memory synthParams,
        IPortal.SynthParams memory finalSynthParams,
        ICurveProxy.MetaExchangeParams memory metaParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable{
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_META_EXCHANGE_SWAP_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);

        IPortal(_portal).synthBatchMetaExchangeWithSwap(tokenParams, synthParams, finalSynthParams, metaParams);
    }

    function synthBatchMetaExchangeWithSwapRequestPayNative(
        ICurveProxy.TokenInput calldata tokenParams,
        IPortal.SynthParamsMetaSwap memory synthParams,
        IPortal.SynthParams memory finalSynthParams,
        ICurveProxy.MetaExchangeParams memory metaParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_META_EXCHANGE_SWAP_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);

        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);

        IPortal(_portal).synthBatchMetaExchangeWithSwap(tokenParams, synthParams, finalSynthParams, metaParams);
    }

    function synthBatchMetaExchangeWithUnwrapRequestWithPermitPayNative(
        ICurveProxy.TokenInput calldata tokenParams,
        IPortal.SynthParamsMetaSwap memory synthParams,
        ICurveProxy.MetaExchangeParams memory metaParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable{
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_META_EXCHANGE_UNWRAP_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);

        IPortal(_portal).synthBatchMetaExchangeWithSwapWithUnwrap(tokenParams, synthParams, metaParams);
    }

    function synthBatchMetaExchangeWithUnwrapRequestPayNative(
        ICurveProxy.TokenInput calldata tokenParams,
        IPortal.SynthParamsMetaSwap memory synthParams,
        ICurveProxy.MetaExchangeParams memory metaParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _SYNTH_BATCH_META_EXCHANGE_UNWRAP_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);

        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _portal, tokenParams.amount);

        IPortal(_portal).synthBatchMetaExchangeWithSwapWithUnwrap(tokenParams, synthParams, metaParams);
    }
    
    /**
     * @dev Direct local meta exchange request (hub chain execution only).
     * @param params meta exchange params
     */
    function metaExchangeRequestVia3poolPayNative(
        ICurveProxy.MetaExchangeParams calldata params,
        ICurveProxy.TokenInput calldata tokenParams,
        DelegatedCallReceipt calldata receipt
    ) external payable{
        address worker = _checkWorkerSignature(params.chainId, _LOCAL_META_EXCHANGE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _curveProxy, tokenParams.amount);
        ICurveProxy(_curveProxy).metaExchange(params, tokenParams);
    }

    function metaExchangeRequestVia3poolWithPermitPayNative(
        ICurveProxy.MetaExchangeParams calldata params,
        ICurveProxy.PermitData calldata permitData,
        ICurveProxy.TokenInput calldata tokenParams,
        DelegatedCallReceipt calldata receipt
    ) external payable{
        address worker = _checkWorkerSignature(params.chainId, _LOCAL_META_EXCHANGE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _curveProxy, tokenParams.amount);
        ICurveProxy(_curveProxy).metaExchange(params, tokenParams);
    }
    
    function mintEusdRequestVia3poolPayNative(
        ICurveProxy.MetaMintEUSD calldata params,
        ICurveProxy.TokenInput calldata tokenParams,
        uint256 chainId,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(chainId, _MINT_EUSD_REQUEST, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _curveProxy, tokenParams.amount);
        ICurveProxy(_curveProxy).addLiquidity3PoolMintEUSD(params, tokenParams);
    }

    function mintEusdRequestVia3poolWithPermitPayNative(
        ICurveProxy.MetaMintEUSD calldata params,
        ICurveProxy.PermitData calldata permitData,
        ICurveProxy.TokenInput calldata tokenParams,
        uint256 chainId,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(chainId, _MINT_EUSD_REQUEST, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenParams.token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : tokenParams.amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenParams.token), msg.sender, _curveProxy, tokenParams.amount);

        ICurveProxy(_curveProxy).addLiquidity3PoolMintEUSD(params, tokenParams);
    }

      /**
     * @dev Direct local EUSD redeem request with unsynth operation (hub chain execution only).
     * @param params meta redeem EUSD params
     * @param payToken pay token
     * @param receiveSide recipient address for unsynth operation
     * @param oppositeBridge opposite bridge contract address
     * @param chainId opposite chain ID
     */
    function redeemEusdRequestPayNative(
        ICurveProxy.MetaRedeemEUSD calldata params,
        address payToken,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(chainId, _REDEEM_EUSD_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(payToken), msg.sender, _curveProxy, params.tokenAmountH);
        ICurveProxy(_curveProxy).redeemEUSD(params, receiveSide, oppositeBridge, chainId);
    }

    /**
     * @dev Direct local EUSD redeem request with unsynth operation (hub chain execution only) with permit.
     * @param params meta redeem EUSD params
     * @param permit permit params
     * @param payToken pay token
     * @param receiveSide recipient address for unsynth operation
     * @param oppositeBridge opposite bridge contract address
     * @param chainId opposite chain ID
     */
    function redeemEusdRequestWithPermitPayNative(
        ICurveProxy.MetaRedeemEUSD calldata params,
        ICurveProxy.PermitData calldata permit,
        address payToken,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(chainId, _REDEEM_EUSD_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(payToken).permit(
            msg.sender,
            address(this),
            permit.approveMax ? uint256(2**256 - 1) : params.tokenAmountH,
            permit.deadline,
            permit.v,
            permit.r,
            permit.s
        );
        SafeERC20.safeTransferFrom(IERC20(payToken), msg.sender, _curveProxy, params.tokenAmountH);
        ICurveProxy(_curveProxy).redeemEUSD(params, receiveSide, oppositeBridge, chainId);
    }

    function tokenSwapWithMetaExchangeRequestPayNative(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _synthParams,
        DelegatedCallReceipt calldata receipt,
        uint256 _coinIndex
    ) external payable {
        address worker = _checkWorkerSignature(_synthParams.chainId, _TOKEN_SWAP_META_EXCHANGE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        ICurveProxy.FeeParams memory feeParams = ICurveProxy.FeeParams(
            address(0),
            0,
            _coinIndex
        );
        SafeERC20.safeTransferFrom(IERC20(_exchangeParams.tokenToSwap), msg.sender, _curveProxyV2, _exchangeParams.amountToSwap);
        ICurveProxy(_curveProxyV2).tokenSwapWithMetaExchange(_exchangeParams, _params, _synthParams, feeParams);
    }

    function tokenSwapWithMetaExchangeRequestWithPermitPayNative(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _synthParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt,
        uint256 _coinIndex
    ) external payable {
        address worker = _checkWorkerSignature(_synthParams.chainId, _TOKEN_SWAP_META_EXCHANGE_REQUEST_SIGNATURE_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        ICurveProxy.FeeParams memory feeParams = ICurveProxy.FeeParams(
            address(0),
            0,
            _coinIndex
        );
        IERC20WithPermit(_exchangeParams.tokenToSwap).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : _exchangeParams.amountToSwap,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(_exchangeParams.tokenToSwap), msg.sender, _curveProxyV2, _exchangeParams.amountToSwap);
        ICurveProxy(_curveProxyV2).tokenSwapWithMetaExchange(_exchangeParams, _params, _synthParams, feeParams);
    }

    function tokenSwapPayNative(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        address from,
        uint256 amount,
        address uniswapRouterV2,
        IPortal.SynthParams calldata finalSynthParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(finalSynthParams.chainId, _TOKEN_SWAP_HASH, uniswapRouterV2, receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenToSwap), msg.sender, _curveProxyV2, amount);
        ICurveProxy(_curveProxyV2).tokenSwapLite(tokenToSwap, to, amountOutMin, tokenToReceive, deadline, from, amount, 0, uniswapRouterV2, finalSynthParams);
    }

    function tokenSwapWithPermitPayNative(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        address from,
        uint256 amount,
        address uniswapRouterV2,
        IPortal.SynthParams calldata finalSynthParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(finalSynthParams.chainId, _TOKEN_SWAP_HASH, uniswapRouterV2, receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenToSwap).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenToSwap), msg.sender, _curveProxyV2, amount);
        ICurveProxy(_curveProxyV2).tokenSwapLite(tokenToSwap, to, amountOutMin, tokenToReceive, deadline, from, amount, 0, uniswapRouterV2, finalSynthParams);
    }

        function tokenSwapUnwrapPayNative(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        uint256 amount,
        address uniswapRouterV2,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(block.chainid, _TOKEN_SWAP_UNWRAP_HASH, uniswapRouterV2, receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(tokenToSwap), msg.sender, _curveProxyV2, amount);
        ICurveProxy(_curveProxyV2).tokenSwapLiteWithUnwrap(tokenToSwap, to, amountOutMin, tokenToReceive, deadline, amount, receipt.aggregationFee, uniswapRouterV2);
    }

    function tokenSwapUnwrapWithPermitPayNative(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        uint256 amount,
        address uniswapRouterV2,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(block.chainid, _TOKEN_SWAP_UNWRAP_HASH, uniswapRouterV2, receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(tokenToSwap).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(tokenToSwap), msg.sender, _curveProxyV2, amount);
        ICurveProxy(_curveProxyV2).tokenSwapLiteWithUnwrap(tokenToSwap, to, amountOutMin, tokenToReceive, deadline, amount, receipt.aggregationFee, uniswapRouterV2);
    }

    function removeLiquidityPayNative(
        address remove,
        int128 x,
        uint256 expectedMinAmount,
        address to,
        address token,
        uint256 amount,
        ISynthesis.SynthParams calldata synthParams,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _REMOVE_LIQUIDITY_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, _curveProxy, amount);
        ICurveProxy(_curveProxy).removeLiquidity(remove, x, expectedMinAmount, to, synthParams);
    }

    function removeLiquidityWithPermitPayNative(
        address remove,
        int128 x,
        uint256 expectedMinAmount,
        address to,
        address token,
        uint256 amount,
        ISynthesis.SynthParams calldata synthParams,
        ISynthesis.PermitData calldata permitData,
        DelegatedCallReceipt calldata receipt
    ) external payable {
        address worker = _checkWorkerSignature(synthParams.chainId, _REMOVE_LIQUIDITY_HASH, address(0), receipt);
        _proceedFees(receipt.executionPrice, worker);
        IERC20WithPermit(token).permit(
            msg.sender,
            address(this),
            permitData.approveMax ? uint256(2**256 - 1) : amount,
            permitData.deadline,
            permitData.v,
            permitData.r,
            permitData.s
        );
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, _curveProxy, amount);
        ICurveProxy(_curveProxy).removeLiquidity(remove, x, expectedMinAmount, to, synthParams);
    }

    function changeProxy(address newAddress) external onlyOwner {
        _curveProxy = newAddress;
    }

    function changeProxyV2(address newAddress) external onlyOwner {
        _curveProxyV2 = newAddress;
    }

    function changePortal(address newAddress) external onlyOwner {
        _portal = newAddress;
    }

    function changeSynthesis(address newAddress) external onlyOwner {
        _synthesis = newAddress;
    }

    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }

    /**
     * @dev "Consume a nonce": return the current value and increment.
     */
    function _useNonce(address owner) internal returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
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
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
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
        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
        } else if (signature.length == 64) {
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            // solhint-disable-next-line no-inline-assembly
            assembly {
                let vs := mload(add(signature, 0x40))
                r := mload(add(signature, 0x20))
                s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                v := add(shr(255, vs), 27)
            }
        } else {
            revert("ECDSA: invalid signature length");
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 */
library Counters {
    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-newone/utils/cryptography/ECDSA.sol";

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
    constructor(
        string memory name,
        string memory version,
        uint256 chainId
    ) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = chainId;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS) {
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
        return keccak256(abi.encode(typeHash, nameHash, versionHash, _CACHED_CHAIN_ID, address(this)));
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

    function getCachedChainId() external view returns (uint256) {
        return _CACHED_CHAIN_ID;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IPortal.sol";
import "./ISynthesis.sol";

interface ICurveProxy {
    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    struct MetaMintEUSD {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
    }

    struct MetaMintEUSDWithSwap {
        //crosschain pool params
        address addAtCrosschainPool;
        uint256 expectedMinMintAmountC;
        //incoming coin index for adding liq to hub pool
        uint256 lpIndex;
        //hub pool params
        address addAtHubPool;
        uint256 expectedMinMintAmountH;
        //recipient address
        address to;
        uint256 amountOutMin;
        address path;
        uint256 deadline;
    }

    struct MetaRedeemEUSD {
        //crosschain pool params
        address removeAtCrosschainPool;
        //outcome index
        int128 x;
        uint256 expectedMinAmountC;
        //hub pool params
        address removeAtHubPool;
        uint256 tokenAmountH;
        //lp index
        int128 y;
        uint256 expectedMinAmountH;
        //recipient address
        address to;
    }

    struct MetaExchangeParams {
        //pool address
        address add;
        address exchange;
        address remove;
        //add liquidity params
        uint256 expectedMinMintAmount;
        //exchange params
        int128 i; //index value for the coin to send
        int128 j; //index value of the coin to receive
        uint256 expectedMinDy;
        //withdraw one coin params
        int128 x; //index value of the coin to withdraw
        uint256 expectedMinAmount;
        //transfer to
        address to;
        //unsynth params
        address chain2address;
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct EmergencyUnsynthParams {
        address initialPortal;
        address initialBridge;
        uint256 initialChainID;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct MetaExchangeSwapParams {
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
    }

    struct MetaExchangeTokenParams {
        address synthToken;
        uint256 synthAmount;
        bytes32 txId;
    }

    struct tokenSwapWithMetaParams {
        address token;
        uint256 amountToSwap;
        address tokenToSwap;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
        address uniswapRouterV2;
        address uniswapFactoryV2;
    }

    struct TokenInput {
        address token;
        uint256 amount;
        uint256 coinIndex;
    }

    struct FeeParams {
        address worker;
        uint256 fee;
        uint256 coinIndex;
    }

    struct LiteSwap {
        address tokenToSwap;
        address to;
        uint256 amountOutMin;
        address tokenToReceive;
        uint256 deadline;
        address from;
        uint256 amount;
        uint256 fee;
        uint256 aggregationFee;
        address uniswapRouterV2;
    }

    function addLiquidity3PoolMintEUSD(
        MetaMintEUSD calldata params,
        TokenInput calldata tokenParams
    ) external;

    function metaExchange(
        MetaExchangeParams calldata params,
        TokenInput calldata tokenParams
    ) external;

    function redeemEUSD(
        MetaRedeemEUSD calldata params,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId
    ) external;

    function transitSynthBatchMetaExchange(
        MetaExchangeParams calldata _params,
        TokenInput calldata tokenParams,
        bytes32 _txId
    ) external;

    function tokenSwap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        IPortal.SynthParams calldata _finalSynthParams,
        uint256 _amount,
        bool stable
    ) external;

    function tokenSwapWithMetaExchange(
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external;

    function removeLiquidity(
        address remove,
        int128 x,
        uint256 expectedMinAmount,
        address to,
        ISynthesis.SynthParams calldata synthParams
    ) external;

    function tokenSwapLite(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        address from,
        uint256 amount,
        uint256 fee,
        address uniswapRouterV2,
        IPortal.SynthParams calldata _finalSynthParams
    ) external;

    function tokenSwapLiteWithUnwrap(
        address tokenToSwap,
        address to,
        uint256 amountOutMin,
        address tokenToReceive,
        uint256 deadline,
        uint256 amount,
        uint256 aggregationFee,
        address uniswapRouterV2
    ) external;

    function tokenSwapWithUnwrap(
        IPortal.SynthParamsMetaSwap calldata _synthParams,
        uint256 _amount
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./ICurveProxy.sol";

interface IPortal {
    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct SynthParamsMetaSwap {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
        address swapReceiveSide;
        address swapOppositeBridge;
        uint256 swapChainId;
        address swappedToken;
        address path;
        address to;
        uint256 amountOutMin;
        uint256 deadline;
        address from;
        uint256 initialChainId;
        address uniswapRouterV2;
        address uniswapFactoryV2;
        uint256 aggregationFee;
    }

    struct SynthesizeParams {
        address token;
        uint256 amount;
        address from;
        address to;
    }

    function synthesize(
        address token,
        uint256 amount,
        address from,
        address to,
        SynthParams calldata params
    ) external;

    function emergencyUnburnRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function synthBatchMetaExchange(
        address _from,
        SynthParams memory _synthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams,
        ICurveProxy.TokenInput calldata tokenParams
    ) external;

    function synthBatchAddLiquidity3PoolMintEUSD(
        address _from,
        SynthParams memory _synthParams,
        ICurveProxy.MetaMintEUSD memory _metaParams,
        ICurveProxy.TokenInput calldata tokenParams
    ) external;

    function synthBatchMetaExchangeWithSwap(
        ICurveProxy.TokenInput calldata _tokenParams,
        SynthParamsMetaSwap memory _synthParams,
        SynthParams memory _finalSynthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams
    ) external;

    function synthBatchMetaExchangeWithSwapWithUnwrap(
        ICurveProxy.TokenInput calldata _tokenParams,
        SynthParamsMetaSwap memory _synthParams,
        ICurveProxy.MetaExchangeParams memory _metaParams
    ) external;
    
    //Deprecated: no use in current cases
    // function tokenSwapRequest(
    //     SynthParamsMetaSwap memory _synthParams,
    //     SynthParams memory _finalSynthParams,
    //     uint256 amount
    // ) external;

}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "./IPortal.sol";
import "./ICurveProxy.sol";

interface ISynthesis {
    struct SynthParams {
        address receiveSide;
        address oppositeBridge;
        uint256 chainId;
    }

    struct PermitData {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
        bool approveMax;
    }

    function mintSyntheticToken(
        bytes32 txId,
        address tokenReal,
        uint256 amount,
        address to
    ) external;

    function burnSyntheticToken(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams
    ) external returns (bytes32 txID);

    function getTxId() external returns (bytes32);

    function synthTransfer(
        address tokenSynth,
        uint256 amount,
        address from,
        address to,
        SynthParams calldata params
    ) external;

    function burnSyntheticTokenToSolana(
        address tokenSynth,
        address from,
        bytes32[] calldata pubkeys,
        uint256 amount,
        uint256 chainId
    ) external;

    function emergencyUnsyntesizeRequest(
        bytes32 txID,
        address receiveSide,
        address oppositeBridge,
        uint256 chainId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function emergencyUnsyntesizeRequestToSolana(
        address from,
        bytes32[] calldata pubkeys,
        bytes1 bumpSynthesizeRequest,
        uint256 chainId
    ) external;

    function burnSyntheticTokenWithSwap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        IPortal.SynthParamsMetaSwap calldata _synthSwapParams,
        IPortal.SynthParams calldata _finalSynthParams
    ) external returns (bytes32 txID);

    function burnSyntheticTokenWithSwapWithUnwrap(
        address _stoken,
        uint256 _amount,
        address _from,
        address _to,
        SynthParams calldata _synthParams,
        IPortal.SynthParamsMetaSwap calldata _synthSwapParams
    ) external returns (bytes32 txID);

    function getRepresentation(bytes32 _rtoken) external view returns (address);

    function burnSyntheticTokenWithMetaExchange(
        IPortal.SynthesizeParams calldata _tokenParams,
        ICurveProxy.tokenSwapWithMetaParams calldata _exchangeParams,
        ICurveProxy.MetaExchangeParams calldata _params,
        IPortal.SynthParams calldata _finalSynthParams,
        IPortal.SynthParams calldata _synthParams,
        ICurveProxy.FeeParams memory _feeParams
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

interface IERC20WithPermit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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