// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./lib/TransferHelper.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

/// @notice Aggregator
contract AggregatorV2 is ReentrancyGuard, Ownable, EIP712 {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    string public name;
    string public symbol;
    struct SwapOrder {
        uint256 fee; 
        address fromToken; // deposit token address
        address toToken; // dest token address
        address destination; // dest address
        uint256 fromAmount; // deposit amt
        uint256 minReturnAmount; // min receive amt
        address _dex; // dex address
        bytes _data; // dex calldata
    }

    struct SwapNftOrder {
        uint256 fee;
        address fromToken; // deposit token address
        address toToken; // dest token address
        address destination; // dest address
        uint256 fromAmount; // deposit amt
        uint256 minReturnAmount; // min receive amt
        address _dex; // dex address
        bytes _data; // dex calldata
        address _nftDex;
        bytes _nftData;
        address nftToken; // deposit token address
        uint256 tokenId;
        uint256 nftBaseAmount;
    }
    struct CallNftDex {
        uint256 fromAmt;
        address toToken;
        address destination;
        uint256 toMinAmt;
        address _dex;
        bytes  data;
        address _nftDex;
        bytes  nftData;
        address nftToken ;
        uint256 tokenId;
        uint256 nftBaseAmount;
    }

    struct SwapWithDexOrder {
        address fromToken; // deposit token address
        string toTokenName; // dest token name
        string desName; // dest name
        uint256 fromAmount; // deposit amt
        uint256 minReturnAmount; // min receive amt
        address midToken;  // mid token address
        uint256 minMidAmount; // min middle amt
        address _dex; // dex address
        bytes _data; // dex calldata
    }

    struct CoinOrder{
        address _dex; // dex address
        uint256 fromAmt;
        bytes _data; // dex calldata
    }

    string private constant SIGNING_DOMAIN = "Aggregator";
    string private constant SIGNATURE_VERSION = "1";

    bytes32 private constant SWAP_ORDER_TYPE =
        keccak256(
            "SwapOrder(uint256 fee,address fromToken,address toToken,address destination,uint256 fromAmount,uint256 minReturnAmount,address _dex,bytes _data)"
        );

    bytes32 private constant SWAP_NFT_ORDER_TYPE =
        keccak256(
            "SwapNftOrder(uint256 fee,address fromToken,address toToken,address destination,uint256 fromAmount,uint256 minReturnAmount,address _dex,bytes _data,address _nftDex,bytes _nftData,address nftToken,uint256 tokenId)"
        );

    bytes32 private constant SWAP_WITH_DEX_ORDER_TYPE =
        keccak256(
            "SwapWithDexOrder(address fromToken,string toTokenName,string desName,uint256 fromAmount,uint256 minReturnAmount,address midToken,uint256 minMidAmount,address _dex,bytes _data)"
        );

    event SwapWithDex(uint256 fromAmount, address fromToken, uint256 minReturnAmount, string toTokenName, string desName ,address midToken,uint256 midAmount);
    event SwapFromEthWithDex(uint256 fromAmount, uint256 minReturnAmount, string toTokenName, string desName,address midToken,uint256 midAmount);
    event SwapToEthWithDex(uint256 fromAmount, address fromToken, uint256 minReturnAmount, string toTokenName, string desName,uint256 midAmount);

    event Swap(uint256 fromAmount, address fromToken, uint256 minReturnAmount, string toToken, string destination);
    event SwapFromEth(uint256 fromAmount, uint256 minReturnAmount, string toToken, string destination);

    event CallDexToETH(uint256 fromAmt, address fromToken, uint256 toMinAmt, uint256 toAmt);
    event CallDexFromETH(uint256 fromAmt, uint256 toMinAmt, address toToken, uint256 toAmt);
    event Calldex(uint256 fromAmt, address fromToken, uint256 toMinAmt, address toToken, uint256 toAmt);

    event Withdtraw(address token, address destination, uint256 amount);
    event WithdrawETH(address destination, uint256 amount);

    event SwapTokenToToken( uint256 fromAmount,  address fromToken, uint256 toTokenAmount, address toToken, address destination, address _dex);
    event SwapTokenToETH(uint256 fromAmount, address fromToken, uint256 toAmount, address destination, address _dex);
    event SwapETHToToken(uint256 fromAmount, uint256 toTokenAmount, address toToken, address destination, address _dex);
    event CallDexList( address _dex);

    event SwapTokenToETHNft( uint256 fromAmount,  address fromToken, uint256 toTokenAmount, address destination, address _dex,address _nftDex, uint256 tokenId,address nftToken);
    event SwapTokenToNft( uint256 fromAmount,  address fromToken,  address destination, address _nftDex, uint256 tokenId,address nftToken);
    event SwapETHToTokenNft( uint256 fromAmount,  uint256 toTokenAmount, address toToken, address destination, address _dex,address _nftDex, uint256 tokenId,address nftToken);
    event SwapETHToNft( uint256 fromAmount,   address destination, address _nftDex, uint256 tokenId,address nftToken);
    event SwapTokenToTokenNft( uint256 fromAmount,  address fromToken, uint256 toTokenAmount, address toToken, address destination,  uint256 tokenId,address nftToken);
    constructor() EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        name = "Aggregator V1";
        symbol = "AGGREGATOR-V1";
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function _hashSwapOrder(SwapOrder memory _order) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    SWAP_ORDER_TYPE,
                    _order.fee,
                    _order.fromToken,
                    _order.toToken,
                    _order.destination,
                    _order.fromAmount,
                    _order.minReturnAmount,
                    _order._dex,
                    keccak256(_order._data)
                )
            );
    }

    function _hashNftSwapOrder(SwapNftOrder memory _order) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    SWAP_NFT_ORDER_TYPE,
                    _order.fee,
                    _order.fromToken,
                    _order.toToken,
                    _order.destination,
                    _order.fromAmount,
                    _order.minReturnAmount,
                    _order._dex,
                    keccak256(_order._data),
                    _order._nftDex,
                    keccak256(_order._nftData),
                    _order.nftToken,
                    _order.tokenId
                )
            );
    }

    function _hashSwapWithDexOrder(SwapWithDexOrder memory _order) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    SWAP_WITH_DEX_ORDER_TYPE,
                    _order.fromToken,
                    keccak256(bytes(_order.toTokenName)),
                    keccak256(bytes(_order.desName)),
                    _order.fromAmount,
                    _order.minReturnAmount,
                    _order.midToken,
                    _order.minMidAmount,
                    _order._dex,
                    keccak256(_order._data)
                )
            );
    }

    /// @notice single chain - token to token
    function swapTokenToToken(SwapOrder memory order, bytes memory _sign) external nonReentrant {
        require(
            owner() == _hashTypedDataV4(_hashSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        uint256 _inputAmount = IERC20(order.fromToken)
            .balanceOf(address(this))
            .sub(_fromTokenBalanceOrigin);
        require(
            _inputAmount >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_FROM_AMOUNT"
        );
        uint256 feeAmount = _inputAmount.mul(order.fee).div(1000000);
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            _inputAmount.sub(feeAmount)
        );
        uint256 _toTokenBalanceOrigin = IERC20(order.toToken).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _toTokenInputAmt = IERC20(order.toToken)
            .balanceOf(address(this))
            .sub(_toTokenBalanceOrigin);
        require(
            _toTokenInputAmt >= order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        TransferHelper.safeTransfer(
            order.toToken,
            order.destination,
            _toTokenInputAmt
        );
        emit SwapTokenToToken(
            order.fromAmount,
            order.fromToken,
            _toTokenInputAmt,
            order.toToken,
            order.destination,
            order._dex
        );
    }

    /// @notice single chain - token to eth
    function swapTokenToETH(SwapOrder memory order, bytes memory _sign) external nonReentrant {
        require(
            owner() == _hashTypedDataV4(_hashSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        uint256 _inputAmount = IERC20(order.fromToken)
            .balanceOf(address(this))
            .sub(_fromTokenBalanceOrigin);
        require(
            _inputAmount >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );
        uint256 feeAmount = _inputAmount.mul(order.fee).div(1000000);
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            _inputAmount.sub(feeAmount)
        );
        uint256 _toBalanceOrigin = address(this).balance;
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _toInputAmt = address(this).balance.sub(_toBalanceOrigin);
        require(_toInputAmt >= order.minReturnAmount, "NO_ENOUGH_TOTOKEN_FROM_DEX");
        TransferHelper.safeTransferETH(order.destination, _toInputAmt);
        emit SwapTokenToETH(
            order.fromAmount,
            order.fromToken,
            _toInputAmt,
            order.destination,
            order._dex
        );
    }

    /// @notice single chain - eth to token
    function swapETHToToken(SwapOrder memory order, bytes memory _sign) external payable nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(
            msg.value >= order.fromAmount && order.fromAmount > 0,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );
        uint256 feeAmount = order.fromAmount.mul(order.fee).div(1000000);
        uint256 _toTokenBalanceOrigin = IERC20(order.toToken).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call{value: order.fromAmount.sub(feeAmount)}(
            order._data
        );
        require(success, "DEX_SWAP_FAILED");
        uint256 _toTokenInputAmt = IERC20(order.toToken)
            .balanceOf(address(this))
            .sub(_toTokenBalanceOrigin);
        require(
            _toTokenInputAmt >= order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        TransferHelper.safeTransfer(
            order.toToken,
            order.destination,
            _toTokenInputAmt
        );
        emit SwapETHToToken(
            order.fromAmount,
            _toTokenInputAmt,
            order.toToken,
            order.destination,
            order._dex
        );
    }

    /// @notice cross chain with dex - token to token
    function swapWithDex(SwapWithDexOrder memory order, bytes memory _sign)
        external
        nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashSwapWithDexOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");

        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        require(
            IERC20(order.fromToken).balanceOf(address(this)).sub(
                _fromTokenBalanceOrigin
            ) >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            order.fromAmount
        );
        uint256 _toBalanceOrigin = IERC20(order.midToken).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 midInputAmt = IERC20(order.midToken)
        .balanceOf(address(this))
        .sub(_toBalanceOrigin);
        require(midInputAmt >= order.minMidAmount, "LESS_THAN_MIN");
        emit SwapWithDex(
            order.fromAmount,
            order.fromToken,
            order.minReturnAmount,
            order.toTokenName,
            order.desName,
            order.midToken,
            midInputAmt
        );
    }

    /// @notice cross chain with dex - token to eth
    function swapToETHWithDex(SwapWithDexOrder memory order, bytes memory _sign) external nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashSwapWithDexOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");

        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        require(
            IERC20(order.fromToken).balanceOf(address(this)).sub(
                _fromTokenBalanceOrigin
            ) >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            order.fromAmount
        );
        uint256 _toBalanceOrigin = address(this).balance;
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _toInputAmt = address(this).balance.sub(_toBalanceOrigin);
        require(_toInputAmt >= order.minMidAmount, "LESS_THAN_MIN");
        emit SwapToEthWithDex(
            order.fromAmount,
            order.fromToken,
            order.minReturnAmount,
            order.toTokenName,
            order.desName,
            _toInputAmt
        );
    }

    /// @notice cross chain with dex - eth to token
    function swapFromEthWithDex(SwapWithDexOrder memory order, bytes memory _sign) external payable nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashSwapWithDexOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(msg.value > 0, "NO_ETH_INPUT");
        require(
            msg.value == order.fromAmount,
            "MSG_VALUE_MUST_EQUAL_DEPOSIT_AMMOUNT"
        );

        uint256 midBalanceOrigin = IERC20(order.midToken).balanceOf(address(this));
        (bool success, ) = order._dex.call{value: msg.value}(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 midInputAmt = IERC20(order.midToken)
            .balanceOf(address(this))
            .sub(midBalanceOrigin);
        require(midInputAmt >= order.minMidAmount, "LESS_THAN_MIN");
        emit SwapFromEthWithDex(
            order.fromAmount,
            order.minReturnAmount,
            order.toTokenName,
            order.desName,
            order.midToken,
            midInputAmt
        );
    }

    /// @notice cross chain - token to others
    function swap(address fromToken, string memory toToken, string memory destination, uint256 fromAmount, uint256 minReturnAmount
    ) external nonReentrant {
        require(fromToken != address(0), "FROMTOKEN_CANT_T_BE_0"); 
        require(fromAmount > 0, "FROM_TOKEN_AMOUNT_MUST_BE_MORE_THAN_0");
        uint256 _inputAmount; 
        uint256 _fromTokenBalanceOrigin = IERC20(fromToken).balanceOf(address(this));
        TransferHelper.safeTransferFrom(fromToken, msg.sender, address(this), fromAmount);
        uint256 _fromTokenBalanceNew = IERC20(fromToken).balanceOf(address(this));
        _inputAmount = _fromTokenBalanceNew.sub(_fromTokenBalanceOrigin);
        require(_inputAmount >= fromAmount, "TRANSFER_LESS_THAN_FROM_AMT");
        emit Swap(fromAmount, fromToken, minReturnAmount, toToken, destination);
    }

    /// @notice cross chain - eth to others
    function swapFromEth(string memory toToken, string memory destination, uint256 minReturnAmount
    ) external payable nonReentrant {
        uint256 _ethAmount = msg.value;
        require(_ethAmount > 0, "ETH_AMOUNT_MUST_BE_MORE_THAN_0");
        emit SwapFromEth(_ethAmount, minReturnAmount, toToken, destination);
    }


    function callDexFromETH(uint256 fromAmt, address toToken, address destination, uint256 toMinAmt, address _dex, bytes calldata data
    ) external payable onlyOwner {
        require(_dex != address(0), "DEX_CAN_NOT_BE_0");
        require(destination != address(0), "DESTINATION_CANNT_BE_0_ADDRESS");
        require(toMinAmt > 0, "MIN_AMOUNT_MUST_BE_MORE_THAN_0");
        require(fromAmt > 0, "VALUE_MUST_BE_MORE_THAN_0");
        uint256 ethBalance = address(this).balance;
        require(fromAmt <= ethBalance, "INSUFFIENT_BALANCE");
        uint256 _toBalanceOrigin = IERC20(toToken).balanceOf(address(this));
        (bool success, ) = _dex.call{value: fromAmt}(data);
        require(success, "DEX_SWAP_FAILED");
        uint256 toTokenAmt = IERC20(toToken).balanceOf(address(this)).sub(_toBalanceOrigin);
        require(toTokenAmt >= toMinAmt, "LESS_THAN_MIN_AMT");
        if (destination != address(this)) {
            TransferHelper.safeTransfer(toToken, destination, toTokenAmt);
        }
        emit CallDexFromETH( fromAmt, toMinAmt, toToken,toTokenAmt);
    }

    function callDexToETH(address fromToken, uint256 fromAmt, address destination, uint256 toMinAmt, address _dex, bytes calldata data
    ) external onlyOwner {
        require(fromToken != address(0), "FROM_TOKEN_CAN_NOT_BE_0_ADDRESS");
        require(_dex != address(0), "DEX_CAN_NOT_BE_0");
        require(destination != address(0), "DESTINATION_CANNT_BE_0_ADDRESS");
        require(toMinAmt > 0, "MIN_AMOUNT_MUST_BE_MORE_THAN_0");
        uint256 _fromBalance = IERC20(fromToken).balanceOf(address(this));
        require(fromAmt <= _fromBalance, "INSUFFIENT_BALANCE");
        TransferHelper.safeApprove(fromToken, _dex, fromAmt);
        uint256 _ethBalanceOrigin = address(this).balance;
        (bool success, ) = _dex.call(data);
        require(success, "DEX_SWAP_FAILED");
        uint256 toEth = address(this).balance.sub(_ethBalanceOrigin);
        require(toEth >= toMinAmt, "LESS_THAN_MIN_AMT");
        if (destination != address(this)) {
            TransferHelper.safeTransferETH(destination, toEth);
        }
        emit CallDexToETH(fromAmt, fromToken, toMinAmt,toEth);
    }

    function callDex(address fromToken, uint256 fromAmt, address toToken, address destination, uint256 toMinAmt, address _dex, bytes calldata data
    ) external onlyOwner {
        require(fromToken != address(0), "FROM_TOKEN_CAN_NOT_BE_0_ADDRESS");
        require(_dex != address(0), "DEX_CAN_NOT_BE_0");
        require(destination != address(0), "DESTINATION_CANNT_BE_0_ADDRESS");
        require(toMinAmt > 0, "MIN_AMOUNT_MUST_BE_MORE_THAN_0");
        uint256 _fromBalance = IERC20(fromToken).balanceOf(address(this));
        require(fromAmt <= _fromBalance, "INSUFFIENT_BALANCE");
        TransferHelper.safeApprove(fromToken, _dex, fromAmt);
        uint256 _toBalanceOrigin = IERC20(toToken).balanceOf(address(this));
        (bool success, ) = _dex.call(data);
        require(success, "DEX_SWAP_FAILED");
        uint256 toTokenAmt = IERC20(toToken).balanceOf(address(this)).sub(_toBalanceOrigin);
        require(toTokenAmt >= toMinAmt, "LESS_THAN_MIN_AMT");
        if (destination != address(this)) {
            TransferHelper.safeTransfer(toToken, destination, toTokenAmt);
        }
        emit Calldex(fromAmt, fromToken, toMinAmt, toToken,toTokenAmt);
    }

    function withdrawETH(address destination, uint256 amount) external onlyOwner {
        require(destination != address(0), "DESTINATION_CANNT_BE_0_ADDRESS");
        uint256 balance = address(this).balance;
        require(balance >= amount, "AMOUNT_CANNT_MORE_THAN_BALANCE");
        TransferHelper.safeTransferETH(destination, amount);
        emit WithdrawETH(destination, amount);
    }

    function withdraw(address token, address destination, uint256 amount) external onlyOwner {
        require(destination != address(0), "DESTINATION_CANNT_BE_0_ADDRESS");
        require(token != address(0), "TOKEN_MUST_NOT_BE_0");
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance >= amount, "AMOUNT_CANNT_MORE_THAN_BALANCE");
        TransferHelper.safeTransfer(token, destination, amount);
        emit Withdtraw(token, destination, amount);
    }

    function swapTokenToETHNft(SwapNftOrder memory order, bytes memory _sign) external nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashNftSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");

        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        require(
            IERC20(order.fromToken).balanceOf(address(this)).sub(
                _fromTokenBalanceOrigin
            ) >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            order.fromAmount
        );
        uint256 _toBalanceOrigin = address(this).balance;
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _toInputAmt = address(this).balance.sub(_toBalanceOrigin);
        require(_toInputAmt >= order.nftBaseAmount, "LESS_THAN_NFT_NEED_AMOUNT");
        (bool result, ) = order._nftDex.call{value:order.nftBaseAmount}(order._nftData);
        require(result, "NFT_BUY_FAILED");
        if (order.destination != address(this)) {
            IERC721(order.nftToken).transferFrom(
                address(this),
                order.destination,
                order.tokenId
            );
        }
        emit SwapTokenToETHNft(
            order.fromAmount,
            order.fromToken,
            _toInputAmt,
            order.destination,
            order._dex,
            order._nftDex,
            order.tokenId,
            order.nftToken
        );
    }

    /// @notice single chain - token to ETH to NFT
    function swapTokenToTokenNft(SwapNftOrder memory order, bytes memory _sign) external nonReentrant {
        require(
            owner() == _hashTypedDataV4(_hashNftSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        uint256 _inputAmount = IERC20(order.fromToken)
        .balanceOf(address(this))
        .sub(_fromTokenBalanceOrigin);
        require(
            _inputAmount >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_FROM_AMOUNT"
        );
        uint256 feeAmount = _inputAmount.mul(order.fee).div(1000000);
        TransferHelper.safeApprove(order.fromToken, order._dex, _inputAmount.sub(feeAmount));
        uint256 _toTokenBalanceOrigin = IERC20(order.toToken).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _toTokenInputAmt = IERC20(order.toToken)
        .balanceOf(address(this))
        .sub(_toTokenBalanceOrigin);
        require(
            _toTokenInputAmt >= order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        require(_toTokenInputAmt >= order.nftBaseAmount, "LESS_THAN_NFT_NEED_AMOUNT");
        TransferHelper.safeApprove(order.toToken, order._nftDex, order.nftBaseAmount);
        (bool result, ) = order._nftDex.call(order._nftData);
        require(result, "NFT_BUY_FAILED");
        if (order.destination != address(this)) {
            IERC721(order.nftToken).transferFrom(
                address(this),
                order.destination,
                order.tokenId
            );
        }
        emit SwapTokenToTokenNft(
            order.fromAmount,
            order.fromToken,
            _toTokenInputAmt,
            order.toToken,
            order.destination,
            order.tokenId,
            order.nftToken
        );
    }
    /// @notice single chain - token to  NFT
    function swapTokenToNft(SwapNftOrder memory order, bytes memory _sign) external nonReentrant {
        require(
            owner() == _hashTypedDataV4(_hashNftSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(order.fromAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(address(this));
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.fromAmount
        );
        uint256 _inputAmount = IERC20(order.fromToken)
        .balanceOf(address(this))
        .sub(_fromTokenBalanceOrigin);
        require(
            _inputAmount >= order.fromAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_FROM_AMOUNT"
        );
        require(_inputAmount >= order.nftBaseAmount, "LESS_THAN_NFT_NEED_AMOUNT");
        TransferHelper.safeApprove(order.toToken, order._nftDex, order.nftBaseAmount);
        (bool result, ) = order._nftDex.call(order._nftData);
        require(result, "NFT_BUY_FAILED");
        if (order.destination != address(this)) {
            IERC721(order.nftToken).transferFrom(
                address(this),
                order.destination,
                order.tokenId
            );
        }
        emit SwapTokenToNft(
            order.fromAmount,
            order.fromToken,
            order.destination,
            order._nftDex,
            order.tokenId,
            order.nftToken
        );
    }

    /// @notice single chain - eth to token to nft
    function swapETHToTokenNft(SwapNftOrder memory order, bytes memory _sign) external payable nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashNftSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(
            msg.value >= order.fromAmount && order.fromAmount > 0,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );
        uint256 feeAmount = order.fromAmount.mul(order.fee).div(1000000);
        uint256 _toTokenBalanceOrigin = IERC20(order.toToken).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call{value: order.fromAmount.sub(feeAmount)}(
            order._data
        );
        require(success, "DEX_SWAP_FAILED");
        uint256 _toTokenInputAmt = IERC20(order.toToken)
        .balanceOf(address(this))
        .sub(_toTokenBalanceOrigin);
        require(
            _toTokenInputAmt >= order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        require(_toTokenInputAmt >= order.nftBaseAmount, "LESS_THAN_NFT_NEED_AMOUNT");
        TransferHelper.safeApprove(order.toToken, order._nftDex, order.nftBaseAmount);
        (bool result, ) = order._nftDex.call(order._nftData);
        require(result, "NFT_BUY_FAILED");
        if (order.destination != address(this)) {
            IERC721(order.nftToken).transferFrom(
                address(this),
                order.destination,
                order.tokenId
            );
        }
        emit SwapETHToTokenNft(
            order.fromAmount,
            _toTokenInputAmt,
            order.toToken,
            order.destination,
            order._dex,
            order._nftDex,
            order.tokenId,
            order.nftToken
        );
    }

    function swapETHToNft(SwapNftOrder memory order, bytes memory _sign) external payable nonReentrant
    {
        require(
            owner() == _hashTypedDataV4(_hashNftSwapOrder(order)).recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_OWNER"
        );
        require(
            msg.value >= order.fromAmount && order.fromAmount > 0,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSIT_AMOUNT"
        );

        (bool result, ) = order._nftDex.call{value:order.nftBaseAmount}(order._nftData);
        require(result, "NFT_BUY_FAILED");
        if (order.destination != address(this)) {
            IERC721(order.nftToken).transferFrom(
                address(this),
                order.destination,
                order.tokenId
            );
        }
        emit SwapETHToNft(
            order.fromAmount,
            order.destination,
            order._nftDex,
            order.tokenId,
            order.nftToken
        );
    }

    function callDexList(CoinOrder[] memory orders) external payable onlyOwner {
        for (uint256 i = 0; i < orders.length; i++) {
            (bool success, ) = orders[i]._dex.call{value: orders[i].fromAmt}( orders[i]._data);
            require(success, "DEX_MAIN_CALL_FAILED");
        }
        emit CallDexList(orders[0]._dex);
    }

    function withdrawERC721(address token, address destination, uint256 tokenId) external onlyOwner {
        require(destination != address(0), "DESTINATION_CANNT_BE_0_ADDRESS");
        require(token != address(0), "TOKEN_MUST_NOT_BE_0");
        address  nftAddress = IERC721(token).ownerOf(tokenId);
        require(nftAddress == address(this), "NOT_OWNER_OR_NFT");
        IERC721(token).transferFrom(
            address(this),
            destination,
            tokenId
        );
        emit Withdtraw(token, destination, tokenId);
    }

}

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

import "./ECDSA.sol";

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
    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (block.chainid == _CACHED_CHAIN_ID) {
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
        return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
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
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature` or error string. This address can then be used for verification purposes.
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
     *
     * Documentation for signature generation:
     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]
     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]
     *
     * _Available since v4.3._
     */
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        // Check the signature length
        // - case 65: r,s,v signature (standard)
        // - case 64: r,vs signature (cf https://eips.ethereum.org/EIPS/eip-2098) _Available since v4.1._
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            // ecrecover takes the signature parameters, and the only way to get them
            // currently is to use assembly.
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

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
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.
     *
     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {
        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.
     *
     * _Available since v4.2._
     */
    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    /**
     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,
     * `r` and `s` signature fields separately.
     *
     * _Available since v4.3._
     */
    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    /**
     * @dev Overload of {ECDSA-recover} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
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

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
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

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
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
    constructor() {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}