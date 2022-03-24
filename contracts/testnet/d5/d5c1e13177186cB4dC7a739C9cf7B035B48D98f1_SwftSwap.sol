// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./lib/TransferHelper.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

/// @notice SWFT Swap V2
contract SwftSwap is ReentrancyGuard, Ownable, EIP712 {
    using SafeMath for uint256;
    using ECDSA for bytes32;

    string public name;

    string public symbol;

    address public agent;

    address public dev;

    address public usdtAddress;

    // uint256 public fee = 3_000_000_000_000_000; // wei, default 0.3%

    mapping(string => uint256) public fee; // wei

    mapping(address => bool) public depositWhiteList;
    mapping(address => bool) public withdrawWhiteList;
    mapping(address => bool) public dexWhiteList;

    bool public depositPaused = false;

    bool public agentFrozen = false;

    struct Order {
        string partnerNO;
        address fromToken;
        uint256 destination;
        address receiptAddress;
        address toToken;
        uint256 depositAmount;
        uint256 minReturnAmount;
        address _dex;
        bytes _data;
    }

    string private constant SIGNING_DOMAIN = "SWFT-SWAP";

    string private constant SIGNATURE_VERSION = "2.1";

    bytes32 private constant ORDER_TYPE =
        keccak256(
            "Order(string partnerNO,address fromToken,uint256 destination,address receiptAddress,address toToken,uint256 depositAmount,uint256 minReturnAmount,address _dex,bytes _data)"
        );

    event Deposit(
        string partnerNO,
        address fromToken, // 源币地址
        uint256 destination, // 目标链chainid
        address receiptAddress, // 目标链上的接收地址
        address toToken, // 目标币地址
        address depositer, // 存入资金的钱包地址
        uint256 depositAmount, // 存入源币的数量
        uint256 usdtAmount, // 实际兑换成usdt的数量
        uint256 minReturnAmount // 能够接受的最小目标币的数量
    );

    event DepositUSDT(
        string partnerNO,
        address fromToken, // 源币地址
        uint256 destination, // 目标链chainid
        address receiptAddress, // 目标链上的接收地址
        address toToken, // 目标币地址
        address depositer, // 存入资金的钱包地址
        uint256 depositAmount, // 存入源币的数量
        uint256 usdtAmount, // 实际兑换成usdt的数量
        uint256 minReturnAmount // 能够接受的最小目标币的数量
    );

    event DepositETH(
        string partnerNO,
        uint256 destination, // 目标链chainid
        address receiptAddress, // 目标链上的接收地址
        address toToken, // 目标币的地址
        address depositer, // 存入主网币的钱包地址
        uint256 depositAmount, // 存入的主网币数量
        uint256 usdtAmount, // 实际兑换成usdt的数量
        uint256 minReturnAmount // 能够接受的最小的目标币的数量
    );

    event Withdraw(
        address toToken, // 币的地址
        address to, // 接收地址
        uint256 usdtAmt, // 使用usdt的数量
        uint256 tokenAmt // 实际收到币的数量
    );

    event WithdrawETH(
        address to, // 接收地址
        uint256 usdtAmt, // 使用usdt的数量
        uint256 ethAmt // 收到eth的数量
    );

    event TransferAgentTo(address _to);

    event TransferTokenTo(address token, address to, uint256 amount);

    event TransferETHTo(address to, uint256 amount);

    event PauseDeposit(address sender);

    event RecoverDeposit(address sender);

    event FrozeAgent(address sender);

    event ReleaseAgent(address sender);

    event AddCoinWhiteList(address _coin);

    event RemoveCoinWhiteList(address _coin);

    event AddDexWhiteList(address _dex);

    event RemoveDexWhiteList(address _dex);

    event SetDev(address _dev);

    event SetFee(string partnerNO, uint256 _fee);

    event SwapTokenToToken(
        string partnerNO,
        address fromToken,
        uint256 depositAmount,
        address toToken,
        uint256 minReturnAmount,
        address receiptAddress,
        address _dex,
        uint256 returnAmount
    );
    event SwapTokenToETH(
        string partnerNO,
        address fromToken,
        uint256 depositAmount,
        uint256 minReturnAmount,
        address receiptAddress,
        address _dex,
        uint256 returnAmount
    );
    event SwapETHToToken(
        string partnerNO,
        uint256 depositAmount,
        address toToken,
        uint256 minReturnAmount,
        address receiptAddress,
        address _dex,
        uint256 returnAmount
    );

    modifier onlyAgent() {
        require(msg.sender == agent, "ONLY_AGENT");
        _;
    }

    constructor(
        address _usdtAddress, // usdt 地址
        address _agent, // agent 地址
        address _dev // dev 地址，手续费的地址
    ) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        name = "SWFT Swap V2";
        symbol = "SSWAP-V2";
        usdtAddress = _usdtAddress;
        agent = _agent;
        dev = _dev;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function getChainId() external view returns (uint256) {
        return block.chainid;
    }

    function _hashOrder(Order memory _order) private pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    ORDER_TYPE,
                    keccak256(bytes(_order.partnerNO)),
                    _order.fromToken,
                    _order.destination,
                    _order.receiptAddress,
                    _order.toToken,
                    _order.depositAmount,
                    _order.minReturnAmount,
                    _order._dex,
                    keccak256(_order._data)
                )
            );
    }

    function getSigner(Order memory _order, bytes memory _sign)
        external
        view
        returns (address)
    {
        return _hashTypedDataV4(_hashOrder(_order)).recover(_sign);
    }

    /// @notice token to token
    function swapTokenToToken(Order memory order, bytes memory _sign) external {
        require(order.receiptAddress != address(0), "RECIEPT_CAN_NOT_BE_0");
        require(order.fromToken != address(0), "FROM_TOKEN_CAN_NOT_BE_0");
        require(
            depositWhiteList[order.fromToken] == true,
            "FROM_TOKEN_NOT_IN_WHITE_LIST"
        );
        require(order.toToken != address(0), "TO_TOKEN_CAN_NOT_BE_0");
        require(order.depositAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        require(order.minReturnAmount > 0, "MIN_RETURN_AMOUNT_CAN_NOT_BE_0");
        require(order._dex != address(0), "DEX_ADDRESS_CAN_NOT_BE_0");
        require(
            dexWhiteList[order._dex] == true,
            "DEX_ADDRESS_NOT_IN_WHITE_LIST"
        );
        require(
            agent ==
                _hashTypedDataV4(_hashOrder(order))
                    .toEthSignedMessageHash()
                    .recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_AGENT"
        );
        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.depositAmount
        );
        uint256 _inputAmount = IERC20(order.fromToken)
            .balanceOf(address(this))
            .sub(_fromTokenBalanceOrigin);
        require(
            _inputAmount >= order.depositAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSITAMOUNT"
        );
        uint256 feeAmount = _inputAmount.mul(fee[order.partnerNO]).div(10**18);
        TransferHelper.safeTransfer(order.fromToken, dev, feeAmount);
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
            _toTokenInputAmt > order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        TransferHelper.safeTransfer(
            order.toToken,
            order.receiptAddress,
            _toTokenInputAmt
        );
        emit SwapTokenToToken(
            order.partnerNO,
            order.fromToken,
            order.depositAmount,
            order.toToken,
            order.minReturnAmount,
            order.receiptAddress,
            order._dex,
            _toTokenInputAmt
        );
    }

    /// @notice token to eth
    function swapTokenToETH(Order memory order, bytes memory _sign) external {
        require(order.receiptAddress != address(0), "RECIEPT_CAN_NOT_BE_0");
        require(order.fromToken != address(0), "FROM_TOKEN_CAN_NOT_BE_0");
        require(
            depositWhiteList[order.fromToken] == true,
            "FROM_TOKEN_NOT_IN_WHITE_LIST"
        );
        require(order.depositAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        require(order.minReturnAmount > 0, "MIN_RETURN_AMOUNT_CAN_NOT_BE_0");
        require(order._dex != address(0), "DEX_ADDRESS_CAN_NOT_BE_0");
        require(
            dexWhiteList[order._dex] == true,
            "DEX_ADDRESS_NOT_IN_WHITE_LIST"
        );
        require(
            agent ==
                _hashTypedDataV4(_hashOrder(order))
                    .toEthSignedMessageHash()
                    .recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_AGENT"
        );
        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.depositAmount
        );
        uint256 _inputAmount = IERC20(order.fromToken)
            .balanceOf(address(this))
            .sub(_fromTokenBalanceOrigin);
        require(
            _inputAmount >= order.depositAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSITAMOUNT"
        );
        uint256 feeAmount = _inputAmount.mul(fee[order.partnerNO]).div(10**18);
        TransferHelper.safeTransfer(order.fromToken, dev, feeAmount);
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            _inputAmount.sub(feeAmount)
        );
        uint256 _toTokenBalanceOrigin = address(this).balance;
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _toTokenInputAmt = address(this).balance.sub(
            _toTokenBalanceOrigin
        );
        require(
            _toTokenInputAmt > order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        TransferHelper.safeTransferETH(order.receiptAddress, _toTokenInputAmt);
        emit SwapTokenToETH(
            order.partnerNO,
            order.fromToken,
            order.depositAmount,
            order.minReturnAmount,
            order.receiptAddress,
            order._dex,
            _toTokenInputAmt
        );
    }

    /// @notice eth to token
    function swapETHToToken(Order memory order, bytes memory _sign)
        external
        payable
    {
        require(order.receiptAddress != address(0), "RECIEPT_CAN_NOT_BE_0");
        require(order.toToken != address(0), "TO_TOKEN_CAN_NOT_BE_0");
        require(order.depositAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        require(order.minReturnAmount > 0, "MIN_RETURN_AMOUNT_CAN_NOT_BE_0");
        require(order._dex != address(0), "DEX_ADDRESS_CAN_NOT_BE_0");
        require(
            dexWhiteList[order._dex] == true,
            "DEX_ADDRESS_NOT_IN_WHITE_LIST"
        );
        require(
            agent ==
                _hashTypedDataV4(_hashOrder(order))
                    .toEthSignedMessageHash()
                    .recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_AGENT"
        );

        require(
            msg.value >= order.depositAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSITAMOUNT"
        );
        uint256 feeAmount = msg.value.mul(fee[order.partnerNO]).div(10**18);
        TransferHelper.safeTransferETH(dev, feeAmount);
        uint256 _toTokenBalanceOrigin = IERC20(order.toToken).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call{value: msg.value.sub(feeAmount)}(
            order._data
        );
        require(success, "DEX_SWAP_FAILED");
        uint256 _toTokenInputAmt = IERC20(order.toToken)
            .balanceOf(address(this))
            .sub(_toTokenBalanceOrigin);
        require(
            _toTokenInputAmt > order.minReturnAmount,
            "NO_ENOUGH_TOTOKEN_FROM_DEX"
        );
        TransferHelper.safeTransfer(
            order.toToken,
            order.receiptAddress,
            _toTokenInputAmt
        );
        // todo: 换出来的eth没处理
        emit SwapETHToToken(
            order.partnerNO,
            order.depositAmount,
            order.toToken,
            order.minReturnAmount,
            order.receiptAddress,
            order._dex,
            _toTokenInputAmt
        );
    }

    /// @notice Deposit ERC20
    function deposit(Order memory order, bytes memory _sign)
        external
        nonReentrant
    {
        require(
            agent == _hashTypedDataV4(_hashOrder(order)).recover(_sign), //.toEthSignedMessageHash()
            "CALL_DATA_MUST_SIGNED_BY_AGENT"
        );
        require(depositPaused == false, "DEPOSIT_PAUSED");
        require(order.destination != block.chainid, "THE_SAME_CHAIN_ID");
        require(order.receiptAddress != address(0), "RECIEPT_CAN_NOT_BE_0");
        require(order.fromToken != address(0), "FROM_TOKEN_CAN_NOT_BE_0");
        require(order.fromToken != usdtAddress, "FROM_TOKEN_CAN_NOT_BE_USDT");
        require(
            depositWhiteList[order.fromToken] == true,
            "FROM_TOKEN_NOT_IN_WHITE_LIST"
        );
        require(order.toToken != address(0), "TO_TOKEN_CAN_NOT_BE_0");
        require(order.depositAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        require(order.minReturnAmount > 0, "MIN_RETURN_AMOUNT_CAN_NOT_BE_0");
        require(order._dex != address(0), "DEX_ADDRESS_CAN_NOT_BE_0");
        require(
            dexWhiteList[order._dex] == true,
            "DEX_ADDRESS_NOT_IN_WHITE_LIST"
        );

        uint256 _fromTokenBalanceOrigin = IERC20(order.fromToken).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            order.fromToken,
            msg.sender,
            address(this),
            order.depositAmount
        );
        require(
            IERC20(order.fromToken).balanceOf(address(this)).sub(
                _fromTokenBalanceOrigin
            ) >= order.depositAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSITAMOUNT"
        );
        TransferHelper.safeApprove(
            order.fromToken,
            order._dex,
            IERC20(order.fromToken).balanceOf(address(this)).sub(
                _fromTokenBalanceOrigin
            )
        );
        uint256 _usdtBalanceOrigin = IERC20(usdtAddress).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call(order._data);
        require(success, "DEX_SWAP_FAILED");
        require(
            IERC20(usdtAddress).balanceOf(address(this)).sub(
                _usdtBalanceOrigin
            ) > 0,
            "NO_USDT_FROM_DEX"
        );
        emit Deposit(
            order.partnerNO,
            order.fromToken,
            order.destination,
            order.receiptAddress,
            order.toToken,
            msg.sender,
            order.depositAmount,
            IERC20(usdtAddress).balanceOf(address(this)).sub(
                _usdtBalanceOrigin
            ),
            order.minReturnAmount
        );
    }

    /// @notice Deposit USDT
    function depositUSDT(Order memory order, bytes memory _sign)
        external
        nonReentrant
    {
        require(depositPaused == false, "DEPOSIT_PAUSED");
        require(order.destination != block.chainid, "THE_SAME_CHAIN_ID");
        require(order.receiptAddress != address(0), "RECIEPT_CAN_NOT_BE_0");
        require(order.toToken != address(0), "TO_TOKEN_CAN_NOT_BE_0");
        require(order.depositAmount > 0, "DEPOSIT_AMOUNT_CAN_NOT_BE_0");
        require(order.minReturnAmount > 0, "MIN_RETURN_AMOUNT_CAN_NOT_BE_0");
        require(
            agent ==
                _hashTypedDataV4(_hashOrder(order))
                    .toEthSignedMessageHash()
                    .recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_AGENT"
        );
        uint256 _fromTokenBalanceOrigin = IERC20(usdtAddress).balanceOf(
            address(this)
        );
        TransferHelper.safeTransferFrom(
            usdtAddress,
            msg.sender,
            address(this),
            order.depositAmount
        );
        uint256 _inputAmount = IERC20(usdtAddress).balanceOf(address(this)).sub(
            _fromTokenBalanceOrigin
        );
        require(
            _inputAmount >= order.depositAmount,
            "TOKEN_AMOUNT_MUST_NOT_SMALL_THAN_DEPOSITAMOUNT"
        );
        emit DepositUSDT(
            order.partnerNO,
            usdtAddress,
            order.destination,
            order.receiptAddress,
            order.toToken,
            msg.sender,
            order.depositAmount,
            _inputAmount,
            order.minReturnAmount
        );
    }

    /// @notice DepositETH
    function depositETH(Order memory order, bytes memory _sign)
        external
        payable
    {
        require(depositPaused == false, "DEPOSIT_PAUSED");
        require(order.destination != block.chainid, "THE_SAME_CHAIN_ID");
        require(order.receiptAddress != address(0), "RECIEPT_CAN_NOT_BE_0");
        require(msg.value > 0, "NO_ETH_INPUT");
        require(
            msg.value == order.depositAmount,
            "MSG_VALUE_MUST_EQUAL_DEPOSITAMMOUNT"
        );
        require(order.toToken != address(0), "TO_TOKEN_CAN_NOT_BE_0");
        require(order.minReturnAmount > 0, "MIN_RETURN_AMOUNT_CAN_NOT_BE_0");
        require(order._dex != address(0), "DEX_ADDRESS_CAN_NOT_BE_0");
        require(
            dexWhiteList[order._dex] == true,
            "DEX_ADDRESS_NOT_IN_WHITE_LIST"
        );
        require(
            agent ==
                _hashTypedDataV4(_hashOrder(order))
                    .toEthSignedMessageHash()
                    .recover(_sign),
            "CALL_DATA_MUST_SIGNED_BY_AGENT"
        );
        uint256 _usdtBalanceOrigin = IERC20(usdtAddress).balanceOf(
            address(this)
        );
        (bool success, ) = order._dex.call{value: msg.value}(order._data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _usdtInputAmt = IERC20(usdtAddress)
            .balanceOf(address(this))
            .sub(_usdtBalanceOrigin);
        require(_usdtInputAmt > 0, "NO_USDT_FROM_DEX");
        emit DepositETH(
            order.partnerNO,
            order.destination,
            order.receiptAddress,
            order.toToken,
            msg.sender,
            msg.value,
            _usdtInputAmt,
            order.minReturnAmount
        );
    }

    function withdrawETH(
        address to,
        uint256 usdtAmt,
        address _dex,
        bytes calldata data
    ) external onlyAgent {
        require(agentFrozen == false, "AGENT_FROZEN");
        require(to != address(0), "TO_CAN_NOT_BE_0_ADDRESS");
        require(usdtAmt != 0, "USDT_AMOUNT_CAN_NOT_BE_0");
        require(_dex != address(0), "DEX_CAN_NOT_BE_0");
        require(dexWhiteList[_dex] == true, "DEX_NOT_IN_WHITE_LIST");
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        require(usdtAmt <= usdtBalance, "INSUFFICIENT_USDT");
        TransferHelper.safeApprove(usdtAddress, _dex, usdtAmt);
        uint256 _ethBalanceOrigin = address(this).balance;
        (bool success, ) = _dex.call(data);
        require(success, "DEX_SWAP_FAILED");
        uint256 _inputEth = address(this).balance.sub(_ethBalanceOrigin);
        require(_inputEth > 0, "NO_ETH_FROM_SWAP");
        TransferHelper.safeTransferETH(to, _inputEth);
        emit WithdrawETH(to, usdtAmt, _inputEth);
    }

    function withdraw(
        address toToken,
        address to,
        uint256 usdtAmt,
        address _dex,
        bytes calldata data
    ) external onlyAgent {
        require(agentFrozen == false, "AGENT_FROZEN");
        require(toToken != address(0), "TOKEN_CAN_NOT_BE_0_ADDRESS");
        require(withdrawWhiteList[toToken] == true, "TOKEN_NOT_IN_WHITE_LIST");
        require(to != address(0), "TO_CAN_NOT_BE_0_ADDRESS");
        require(usdtAmt != 0, "USDT_AMOUNT_CAN_NOT_BE_0");
        require(_dex != address(0), "DEX_CAN_NOT_BE_0");
        require(dexWhiteList[_dex] == true, "DEX_NOT_IN_WHITE_LIST");
        uint256 usdtBalance = IERC20(usdtAddress).balanceOf(address(this));
        require(usdtAmt <= usdtBalance, "INSUFFIENT_USDT");
        uint256 _inputToken;
        if (toToken != usdtAddress) {
            TransferHelper.safeApprove(usdtAddress, _dex, usdtAmt);
            uint256 _tokenBalanceOrigin = IERC20(toToken).balanceOf(
                address(this)
            );
            (bool success, ) = _dex.call(data);
            require(success, "DEX_SWAP_FAILED");
            _inputToken = IERC20(toToken).balanceOf(address(this)).sub(
                _tokenBalanceOrigin
            );
            require(_inputToken > 0, "NO_TOKEN_FROM_SWAP");
            TransferHelper.safeTransfer(toToken, to, _inputToken);
        } else {
            _inputToken = usdtAmt;
            require(
                IERC20(usdtAddress).balanceOf(address(this)) >= usdtAmt,
                "INSUFFICIENT_USDT"
            );
            TransferHelper.safeTransfer(usdtAddress, to, usdtAmt);
        }
        emit Withdraw(toToken, to, usdtAmt, _inputToken);
    }

    function transferAgentTo(address _to) external onlyAgent {
        require(_to != address(0), "CAN_NOT_TRANFER_TO_0");
        agent = _to;
        emit TransferAgentTo(_to);
    }

    function transferTokenTo(
        address token,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(token != address(0), "CAN_NOT_TRANFER_0");
        require(to != address(0), "CAN_NOT_TRANSFER_TO_0");
        require(amount != 0, "AMOUNT_CAN_NOT_BE_0");
        TransferHelper.safeTransfer(token, to, amount);
        emit TransferTokenTo(token, to, amount);
    }

    function transferETHTo(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "CAN_NOT_TRANSFER_TO_0");
        require(amount != 0, "AMOUNT_CAN_NOT_BE_0");
        TransferHelper.safeTransferETH(to, amount);
        emit TransferETHTo(to, amount);
    }

    function pauseDeposit() external onlyOwner {
        depositPaused = true;
        emit PauseDeposit(msg.sender);
    }

    function recoverDeposit() external onlyOwner {
        depositPaused = false;
        emit RecoverDeposit(msg.sender);
    }

    function frozeAgent() external onlyOwner {
        agentFrozen = true;
        emit FrozeAgent(msg.sender);
    }

    function releaseAgent() external onlyOwner {
        agentFrozen = false;
        emit ReleaseAgent(msg.sender);
    }

    function addDepositWhiteList(address _coin) external onlyOwner {
        require(_coin != address(0), "CAN_NOT_ADD_0_ADDRESS");
        require(depositWhiteList[_coin] == false, "EXISTS");
        depositWhiteList[_coin] = true;
        emit AddCoinWhiteList(_coin);
    }

    function removeDepositWhiteList(address _coin) external onlyOwner {
        require(_coin != address(0), "CAN_NOT_REMOVE_0_ADDRESS");
        require(depositWhiteList[_coin] == true, "NOT_EXISTS");
        depositWhiteList[_coin] = false;
        emit RemoveCoinWhiteList(_coin);
    }

    function addWithdrawWhiteList(address _coin) external onlyOwner {
        require(_coin != address(0), "CAN_NOT_ADD_0_ADDRESS");
        require(withdrawWhiteList[_coin] == false, "EXISTS");
        withdrawWhiteList[_coin] = true;
        emit AddCoinWhiteList(_coin);
    }

    function removeWithdrawWhiteList(address _coin) external onlyOwner {
        require(_coin != address(0), "CAN_NOT_REMOVE_0_ADDRESS");
        require(withdrawWhiteList[_coin] == true, "NOT_EXISTS");
        withdrawWhiteList[_coin] = false;
        emit RemoveCoinWhiteList(_coin);
    }

    function addDexWhiteList(address _dex) external onlyOwner {
        require(_dex != address(0), "CAN_NOT_ADD_0_ADDRESS");
        require(dexWhiteList[_dex] == false, "EXISTS");
        dexWhiteList[_dex] = true;
        emit AddDexWhiteList(_dex);
    }

    function removeDexWhiteList(address _dex) external onlyOwner {
        require(_dex != address(0), "CAN_NOT_REMOVE_0_ADDRESS");
        require(dexWhiteList[_dex] == true, "NOT_EXISTS");
        dexWhiteList[_dex] = false;
        emit RemoveDexWhiteList(_dex);
    }

    function setDev(address _dev) external onlyOwner {
        require(_dev != address(0), "DEV_CAN_NOT_BE_0");
        dev = _dev;
        emit SetDev(_dev);
    }

    function setFee(string memory partnerNO, uint256 _fee) external onlyOwner {
        fee[partnerNO] = _fee;
        emit SetFee(partnerNO, _fee);
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
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
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
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/draft-EIP712.sol)

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
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    /**
     * @dev Returns the domain separator for the current chain.
     */
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/cryptography/ECDSA.sol)

pragma solidity ^0.8.0;

import "../Strings.sol";

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
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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
     * @dev Returns an Ethereum Signed Message, created from `s`. This
     * produces hash corresponding to the one signed with the
     * https://eth.wiki/json-rpc/API#eth_sign[`eth_sign`]
     * JSON-RPC method as part of EIP-191.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
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
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

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

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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