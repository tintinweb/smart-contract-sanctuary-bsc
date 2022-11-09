/**
 *Submitted for verification at BscScan.com on 2022-11-09
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
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

    function tryDiv(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b)
        internal
        pure
        returns (bool, uint256)
    {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(
                oldAllowance >= value,
                "SafeERC20: decreased allowance below zero"
            );
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            // Return data is optional
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

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

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

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

interface IWikimetaMaster {
    function _mintWisa(uint256 amount, address account) external returns(uint256);
}

contract Staking is ReentrancyGuard, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */
    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;

    address masterAddr;

    IERC20 public USDT;
    // IERC20[] public stakingToken;
    mapping(uint256 => IERC20) stakingTokens;

    address mAccount; // 营销账号地址
    address adminAddress;


    uint256 public orderCounter;

    OrderInfo[] private orderList; // 质押记录
    // 产品列表
    mapping(uint256 => uint256) public _productList;

    // 锁定用户质押资产
    mapping(address => bool) public stakeWithdrawState;

    // 正常赎回手续费
    uint256 private fee = 3;
    // 未到期手续费
    mapping(uint256 => uint256) private notDueFee;


    modifier onlyAdmin() {
        require(msg.sender == adminAddress, "Admin: caller is not the admin");
        _;
    }

    struct OrderInfo {
        uint256 tokenId; // 质押token
        address account; // 质押人
        uint256 orderNo; // 订单号
        uint256 productId; // 产品id
        uint256 time; // 质押时间
        uint256 value; // 质押金额
        uint256 state; // 状态 1 已赎回
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(address _LPToken, address _wisaToken,address _swapRouter, address _usdtAddress,address _masterAddr,address _mAccount,address _adminAddress) {
        stakingTokens[0] = IERC20(_LPToken);
        stakingTokens[1] = IERC20(_wisaToken);
        mAccount = _mAccount;
        masterAddr = _masterAddr; // master合约
        adminAddress = _adminAddress;

        USDT = IERC20(_usdtAddress);

        _productList[0] = 60 days;
        notDueFee[0] = 6; // 未到期手续费

        _productList[1] = 90 days; // 90天
        notDueFee[1] = 10;

        _productList[2] = 180 days; // 180天
        notDueFee[2] = 10;

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(_swapRouter);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            _wisaToken,
            _usdtAddress
        );
        uniswapV2Router = _uniswapV2Router;
    }

    /* ========== VIEWS ========== */

    // 质押总量
    function totalSupply(uint256 tokenId) external view returns (uint256) {
        uint256 _total = 0;
        for (uint256 i = 0; i < orderList.length; i++) {
            if (orderList[i].tokenId == tokenId) {
                _total = _total.add(orderList[i].value);
            }
        }
        return _total;
    }

    // 产品质押总量
    function totalSupplyByProductId(uint256 tokenId, uint256 productId)
        external
        view
        returns (uint256)
    {
        uint256 _total = 0;
        for (uint256 i = 0; i < orderList.length; i++) {
            if (
                orderList[i].tokenId == tokenId &&
                orderList[i].productId == productId
            ) {
                _total = _total.add(orderList[i].value);
            }
        }
        return _total;
    }

    // 用户产品质押总量
    function balanceOf(
        address account,
        uint256 tokenId,
        uint256 productId
    ) external view returns (uint256) {
        uint256 _balance = 0;
        for (uint256 i = 0; i < orderList.length; i++) {
            if (
                tokenId == orderList[i].tokenId &&
                productId == orderList[i].productId &&
                orderList[i].account == account
            ) {
                _balance = _balance.add(orderList[i].value);
            }
        }
        return _balance;
    }
    
    // 用户tokenId质押总量
    function balanceOfTokenId(address account, uint256 tokenId) external view returns (uint256) {
        uint256 _balance = 0;
        for (uint256 i = 0; i < orderList.length; i++) {
            if (tokenId == orderList[i].tokenId && orderList[i].account == account) {
                _balance = _balance.add(orderList[i].value);
            }
        }
        return _balance;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function _stake(uint256 tokenId, uint256 _productId,uint256 amount, address _account) internal{
        uint256 _orderNo = orderCounter;
        orderList.push(
            OrderInfo({
                tokenId: tokenId,
                state: 0,
                account: _account,
                value: amount,
                time: block.timestamp,
                productId: _productId,
                orderNo: _orderNo
            })
        );


        orderCounter++;

       //质押日志记录(日志类型(20), 账号, 订单号, 质押Token(0LP/1WISA), 质押产品(0活期/1定期90天/2定期180天), 质押金额, 质押时间)
        emit StakeLogs(20, _account, _orderNo, tokenId, _productId, amount, block.timestamp);
    }


    // 质押
    function stake(
        uint256 tokenId,
        uint256 _productId,
        uint256 amount
    ) external nonReentrant {
        require(amount > 0, "Wikimeta_4012: Cannot stake 0");
        require(tokenId == 0 || tokenId == 1, "Wikimeta_4013: Token Id is Not supported");

        stakingTokens[tokenId].safeTransferFrom(msg.sender, address(this), amount);
       _stake(tokenId, _productId, amount, msg.sender);
    }

    // 空投质押
    function stakeDrop(
        uint256 tokenId,
        uint256 _productId,
        uint256 amount,
        address user
    ) external onlyAdmin{
        require(amount > 0, "Wikimeta_4012: Cannot stake 0");
        require(tokenId == 0 || tokenId == 1, "Wikimeta_4013: Token Id is Not supported");

        stakingTokens[tokenId].safeTransferFrom(msg.sender, address(this), amount);
        // 给用户质押
       _stake(tokenId, _productId, amount, user);
    }



    // 赎回
    function withdraw(uint256 orderNo) external nonReentrant {
        require(
            orderList[orderNo].account == msg.sender,
            "Wikimeta_4014: You are not the owner of the order"
        );
        require(orderList[orderNo].state == 0, "Wikimeta_4015: Order has been redeemed");
    
        OrderInfo storage _orderInfo = orderList[orderNo];
        uint256 _amount = _orderInfo.value;
  
        require(stakeWithdrawState[msg.sender] == false, "Wikimeta_4016: Your pledged assets are locked");
        
        uint256 _fee = 0;
        uint256 _productId = _orderInfo.productId;
        uint256 currentFee = fee;

        if (block.timestamp - _orderInfo.time < _productList[_productId]) {
            currentFee = notDueFee[_orderInfo.productId];
        }

        _fee = _amount.mul(currentFee) / 100;

        orderList[orderNo].state = 1; // 更改订单状态
        orderList[orderNo].value = 0; // 订单余额

        uint256 _tAmount = _amount.sub(_fee);

        stakingTokens[_orderInfo.tokenId].safeTransfer(msg.sender, _tAmount);

        stakingTokens[_orderInfo.tokenId].safeTransfer(mAccount,_fee);

        //质押赎回日志记录(日志类型(21), 账号, 订单号, 质押Token(0LP/1WISA), 质押产品(0活期/1定期90天/2定期180天), 赎回到账金额, 赎回手续费, 赎回时间)
        emit StakeWithdrawLogs(21, msg.sender, orderNo, _orderInfo.tokenId, _productId, _tAmount, _fee, block.timestamp);
    }


    // 一键质押
    function swapAndStake(uint256 _amount,uint256 _productId) external nonReentrant {
        require(_amount > 0, "Wikimeta_4017: Cannot stake 0");
        uint _swapAmount = _amount.div(2);
        uint _usdt = _amount.sub(_swapAmount);

        address[] memory path = new address[](2);
        path[0] = address(USDT);
        path[1] = address(stakingTokens[1]);

        USDT.safeTransferFrom(msg.sender, address(this), _amount);
        
   
        // 授权给master合约
        TransferHelper.safeApprove(address(USDT), masterAddr, _swapAmount);
        // 铸造wisa
        uint256 wisaAmount = IWikimetaMaster(masterAddr)._mintWisa(_swapAmount, msg.sender); // LP铸造

        // 授权给交易所合约
        TransferHelper.safeApprove(address(USDT), address(uniswapV2Router), _usdt);
        TransferHelper.safeApprove(path[1], address(uniswapV2Router), wisaAmount);
        
        // 添加流动性
        (uint _amountA, uint _amountB, uint _liquidity) = uniswapV2Router.addLiquidity(path[0], path[1], _usdt, wisaAmount, 0, 0, address(this), block.timestamp);
        
        // 添加质押订单
        _stake(0, _productId, _liquidity, msg.sender);

        uint moreUsdt = _usdt.sub(_amountA);
        if(moreUsdt > 0) {
            // 多余的U转还给用户
            USDT.safeTransfer(msg.sender, moreUsdt);
        }
        uint moreWisa = wisaAmount.sub(_amountB);
        if(moreWisa > 0) {
            stakingTokens[1].safeTransfer(msg.sender, moreWisa);
        }
     
        // 一键质押LP日志记录(日志类型(22), 账号, 输入usdt, 铸造wisa, 入池USDT, 入池wisa, 获得LP, 时间)
        emit SwapAndStakeLogs(22, msg.sender, _amount, wisaAmount, _amountA, _amountB, _liquidity, block.timestamp);
    }


    // 质押赎回锁定
    function stakeWithdrawLocked() external nonReentrant {
        require(stakeWithdrawState[msg.sender] == false, "Wikimeta_4016: Stake withdraw is locked");
        
        stakeWithdrawState[msg.sender] = true;
       
        //质押赎回锁定(日志类型(23), 锁定账号, 锁定状态(0未锁定/1已锁定), 时间)
        emit StakeWithdrawLockedLogs(23, msg.sender, 1, block.timestamp);
    }

    // 修改用户质押赎回锁定状态
    function updateStakeWithdrawLocked(address _account, bool _state) external onlyAdmin {
        stakeWithdrawState[_account] = _state;

        //质押赎回锁定(日志类型(23), 锁定账号, 锁定状态(0未锁定/1已锁定), 时间)
        emit StakeWithdrawLockedLogs(23, _account, _state == true?1:0, block.timestamp);
    }

    // 设置token
    function setTokenConfig(uint256 _fee, uint256 _tokenId, address _stakingToken) external onlyAdmin {
        fee = _fee;
        stakingTokens[_tokenId] = IERC20(_stakingToken);
    }

    // 配置产品
    function setProductConfig(uint256 _productId, uint256 _productTime, uint256 _productnotDueFee)external onlyAdmin {
        notDueFee[_productId] = _productnotDueFee;
        _productList[_productId] = _productTime;
    }
    // 设置master合约
     function setMasterContract(address _masterAddress)external onlyAdmin {
        masterAddr = _masterAddress;
    }

     // 设置管理员账号
    function setAdmin(address _admin) external onlyOwner {
        adminAddress = _admin;
    }

    /* ========== EVENTS ========== */
    //质押日志记录(日志类型(20), 账号, 订单号, 质押Token(0LP/1WISA), 质押产品(0活期/1定期90天/2定期180天), 质押金额, 质押时间)
    event StakeLogs(uint indexed _type, address account, uint256 orderNo, uint256 tokenId, uint256 productId, uint256 amount, uint256 time);

    //质押赎回日志记录(日志类型(21), 账号, 订单号, 质押Token(0LP/1WISA), 质押产品(0活期/1定期90天/2定期180天), 赎回到账金额, 赎回手续费, 赎回时间)
    event StakeWithdrawLogs(uint indexed _type, address account, uint256 orderNo, uint256 tokenId, uint256 productId, uint256 amount, uint256 fee, uint256 time);

    //一键质押LP日志记录(日志类型(22), 账号, 输入usdt, 铸造wisa, 入池USDT, 入池wisa, 获得LP, 时间)
    event SwapAndStakeLogs(uint indexed _type, address account, uint256 amount, uint256 wisaAmount, uint256 amountA, uint256 amountB, uint256 liquidity, uint256 time);

    //质押赎回锁定(日志类型(23), 锁定账号, 锁定状态(0未锁定/1已锁定), 时间)
    event StakeWithdrawLockedLogs(uint indexed _type, address account, uint256 state, uint256 time);

}