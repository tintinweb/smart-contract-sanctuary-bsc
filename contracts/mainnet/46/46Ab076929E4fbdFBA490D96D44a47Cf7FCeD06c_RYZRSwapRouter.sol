/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

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

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Administration is Context {
    address private _admin;

    event ChangeAdministrator(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @dev Initializes the contract setting the deployer as the initial admin.
     */
    constructor() {
        _changeAdmin(_msgSender());
    }

    /**
     * @dev Returns the address of the current admin.
     */
    function admin() public view virtual returns (address) {
        return _admin;
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(admin() == _msgSender(), "Administration: caller is not the admin");
        _;
    }

    /**
     * @dev Leaves the contract without admin. It will not be possible to call
     * `onlyAdmin` functions anymore. Can only be called by the current admin.
     *
     * NOTE: Renouncing admin role will leave the contract without an admin,
     * thereby removing any functionality that is only available to the admin.
     */
    function renounceAdminRole() external virtual onlyAdmin { // gas optimized
        _changeAdmin(address(0));
    }

    /**
     * @dev Transfers admin role of the contract to a new account (`newAdmin`).
     * Can only be called by the current admin.
     */
    function changeAdmin(address newAdmin) external virtual onlyAdmin { // gas optimized
        require(newAdmin != address(0), "Administration: new admin is the zero address");
        _changeAdmin(newAdmin);
    }

    /**
     * @dev Transfers admin role of the contract to a new account (`newAdmin`).
     * Internal function without access restriction.
     */
    function _changeAdmin(address newAdmin) internal virtual {
        address oldAdmin = _admin;
        _admin = newAdmin;
        emit ChangeAdministrator(oldAdmin, newAdmin);
    }
}

interface IRYZRSwapRouter01 {
    function factory() external view returns (address);
    function WETH() external view returns (address);

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

interface IRYZRSwapRouter is IRYZRSwapRouter01 {
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

interface IToken {
    function addPair(address pair, address token) external;
    function depositLPFee(uint amount, address token) external;
}

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)
library SafeMath { // provides some added gas effeciency
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y > 0, "ds-math-div-underflow");
        z = x / y;
    }
}

interface IRYZRSwapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function baseToken() external view returns (address);
    function getTotalFee() external view returns (uint);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function updateTotalFee(uint totalFee) external returns (bool);

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
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast, address _baseToken);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, uint amount0Fee, uint amount1Fee, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setBaseToken(address _baseToken) external;
}

interface IRYZRSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function pairExist(address pair) external view returns (bool);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function routerInitialize(address) external;
    function routerAddress() external view returns (address);
}

abstract contract FeeStore is Administration {
    uint public adminFee;
    address public adminFeeAddress;
    address public adminFeeSetter;
    address public factoryAddress;
    mapping (address => address) public pairFeeAddress;

    event AdminFeeSet(uint adminFee, address adminFeeAddress);

    function initialize(address _factory, uint256 _adminFee, address _adminFeeAddress, address _adminFeeSetter) internal {
        factoryAddress = _factory;
        adminFee = _adminFee;
        adminFeeAddress = _adminFeeAddress;
        adminFeeSetter = _adminFeeSetter;
    }

    function feeAddressSetWhileSwap(address pair,address tokenAddress) external onlyAdmin {
        require(IRYZRSwapFactory(factoryAddress).pairExist(pair), "FEESTORE: PAIR_DOES_NOT_EXIST");
        require(IRYZRSwapPair(pair).token0() == tokenAddress || IRYZRSwapPair(pair).token1() == tokenAddress, "FEESTORE: INVALID_ADDRESS");

        pairFeeAddress[pair] = tokenAddress;
    }

    function feeAddressGet() public view returns (address) {
        return (adminFeeAddress == address(0) ? address(this) : adminFeeAddress);
    }

    function setAdminFee (address _adminFeeAddress, uint _adminFee) external onlyAdmin {
        require(msg.sender == adminFeeSetter);
        require (_adminFee <= 100, "FEESTORE: CANNOT_EXCEED_1%");
        adminFeeAddress = _adminFeeAddress;
        adminFee = _adminFee;
    }
}

library RYZRSwapLibrary {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "RYZRSwapLibrary: CANNOT_USE_IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "RYZRSwapLibrary: CANNOT_BE_ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(address factory, address tokenA, address tokenB) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(uint160(uint(keccak256(abi.encodePacked(
                hex'ff',
                factory,
                keccak256(abi.encodePacked(token0, token1)),
                hex'16718ce0457c824ba360176fcbd99b75a0039f147bb6a6466f61b4427e3dd385' // init code hash
            )))));
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address factory, address tokenA, address tokenB) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,,) = IRYZRSwapPair(pairFor(factory, tokenA, tokenB)).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, "RYZRSwapLibrary: amountA_TOO_LOW");
        require(reserveA > 0 && reserveB > 0, "RYZRSwapLibrary: INSUFFICIENT_LIQUIDITY");
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut, bool tokenFee, uint totalFee) internal pure returns (uint amountOut) {
        require(amountIn > 0, "RYZRSwapLibrary: amountIn_TOO_LOW");
        require(reserveIn > 0 && reserveOut > 0, "RYZRSwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint amountInMultiplier = tokenFee ? 9975 - totalFee : 9975;
        uint amountInWithFee = amountIn.mul(amountInMultiplier);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut, bool tokenFee, uint totalFee) internal pure returns (uint amountIn) {
        require(amountOut > 0, "RYZRSwapLibrary: amountOut_TOO_LOW");
        require(reserveIn > 0 && reserveOut > 0, "RYZRSwapLibrary: INSUFFICIENT_LIQUIDITY");
        uint amountOutMultiplier = tokenFee ? 9975 - totalFee : 9975;
        uint numerator = reserveIn.mul(amountOut).mul(10000);
        uint denominator = reserveOut.sub(amountOut).mul(amountOutMultiplier);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(address factory, uint amountIn, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "RYZRSwapLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            IRYZRSwapPair pair = IRYZRSwapPair(pairFor(factory, path[i], path[i + 1]));
            address baseToken = pair.baseToken();
            uint totalFee = pair.getTotalFee();
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i], path[i + 1]);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut, baseToken != address(0), totalFee);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(address factory, uint amountOut, address[] memory path) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, "RYZRSwapLibrary: INVALID_PATH");
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            IRYZRSwapPair pair = IRYZRSwapPair(pairFor(factory, path[i - 1], path[i]));
            address baseToken = pair.baseToken();
            uint totalFee = pair.getTotalFee();
            (uint reserveIn, uint reserveOut) = getReserves(factory, path[i - 1], path[i]);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut, baseToken != address(0), totalFee);
        }
    }

    function adminFeeCalculation(uint256 _amounts,uint256 _adminFee) internal pure returns (uint256,uint256) {
        uint adminFeeDeduct = (_amounts.mul(_adminFee)) / (10000);
        _amounts = _amounts.sub(adminFeeDeduct);

        return (_amounts,adminFeeDeduct);
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
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
      "TransferHelper::safeApprove: approve failed"
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
      "TransferHelper::safeTransfer: transfer failed"
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
      "TransferHelper::transferFrom: transferFrom failed"
    );
  }

  function safeTransferETH(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}(new bytes(0));
    require(success, "TransferHelper::safeTransferETH: ETH transfer failed");
  }
}

abstract contract SupportingSwap is FeeStore, IRYZRSwapRouter {
    using SafeMath for uint;

    address public override factory;
    address public override WETH;

    modifier ensure(uint deadline) {
        require(deadline >= block.timestamp, "RYZRSwapRouter: DEADLINE_EXPIRED");
        _;
    }

    function _swap(uint[] memory amounts, address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = RYZRSwapLibrary.sortTokens(input, output);
            uint amountOut = amounts[i + 1];
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOut) : (amountOut, uint(0));
            (uint amount0Fee, uint amount1Fee) = _calculateFees(input, output, amounts[i], amount0Out, amount1Out);
            address to = i < path.length - 2 ? RYZRSwapLibrary.pairFor(factory, output, path[i + 2]) : _to;
            IRYZRSwapPair(RYZRSwapLibrary.pairFor(factory, input, output)).swap(
                amount0Out, amount1Out, amount0Fee, amount1Fee, to, new bytes(0)
            );

        }
    }

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);

        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountIn, adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, feeAddressGet(), adminFeeDeduct
            );
        }

        amounts = RYZRSwapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "RYZRSwapRouter: CHECK_SLIPPAGE");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(amounts, path, to);
    }
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint[] memory amounts) {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);
        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]) {
            amounts = RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
            require(amounts[0] <= amountInMax, "RYZRSwapRouter: amountInMax_TOO_HIGH");
            (amounts[0], adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amounts[0], adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, feeAddressGet(), adminFeeDeduct
            );

            amounts = RYZRSwapLibrary.getAmountsOut(factory, amounts[0], path);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );

        } else {
            amounts = RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
            require(amounts[0] <= amountInMax, "RYZRSwapRouter: amountInMax_TOO_HIGH");
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );
        }

        _swap(amounts, path, to);
    }

    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[0] == WETH, "RYZRSwapRouter: INVALID_PATH");

        uint eth = msg.value;
        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);
        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (eth, adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(eth, adminFee);
            if(address(this) != feeAddressGet()){
                payable(feeAddressGet()).transfer(adminFeeDeduct);
            }
        }

        amounts = RYZRSwapLibrary.getAmountsOut(factory, msg.value, path);
        require(amounts[amounts.length - 1] >= amountOutMin,"RYZRSwapRouter: CHECK_SLIPPAGE");
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(IWETH(WETH).transfer(pair, amounts[0]));
        _swap(amounts, path, to);
    }
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[path.length - 1] == WETH, "RYZRSwapRouter: INVALID_PATH");

        uint adminFeeDeduct;
        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);
        if(path[0] == pairFeeAddress[pair]){
            amounts = RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
            require(amounts[0] <= amountInMax, "RYZRSwapRouter: amountInMax_TOO_HIGH");
            (amounts[0],adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amounts[0],adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, feeAddressGet(), adminFeeDeduct
            );
            amounts = RYZRSwapLibrary.getAmountsOut(factory, amounts[0], path);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );
        } else {
            amounts = RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
            require(amounts[0] <= amountInMax, "RYZRSwapRouter: amountInMax_TOO_HIGH");
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, pair, amounts[0]
            );
        }
        _swap(amounts, path, address(this));

        uint amountETHOut = amounts[amounts.length - 1];
        if(path[1] == pairFeeAddress[pair]){
            (amountETHOut,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountETHOut,adminFee);
        }
        IWETH(WETH).withdraw(amountETHOut);
        TransferHelper.safeTransferETH(to, amountETHOut);
    }
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[path.length - 1] == WETH, "RYZRSwapRouter: INVALID_PATH");

        uint adminFeeDeduct;
        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountIn, adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, feeAddressGet(), adminFeeDeduct
            );
        }

        amounts = RYZRSwapLibrary.getAmountsOut(factory, amountIn, path);
        require(amounts[amounts.length - 1] >= amountOutMin, "RYZRSwapRouter: CHECK_SLIPPAGE");
        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amounts[0]
        );
        _swap(amounts, path, address(this));

        uint amountETHOut = amounts[amounts.length - 1];
        if(path[1] == pairFeeAddress[pair]){
            (amountETHOut,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountETHOut,adminFee);
        }
        IWETH(WETH).withdraw(amountETHOut);
        TransferHelper.safeTransferETH(to, amountETHOut);
    }
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    virtual
    override
    payable
    ensure(deadline)
    returns (uint[] memory amounts)
    {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[0] == WETH, "RYZRSwapRouter: INVALID_PATH");

        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);

        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            amounts = RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
            require(amounts[0] <= msg.value, "RYZRSwapRouter: EXCESSIVE_INPUT_AMOUNT");

            (amounts[0], adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amounts[0], adminFee);
            if(address(this) != feeAddressGet()){
                payable(feeAddressGet()).transfer(adminFeeDeduct);
            }
            amounts = RYZRSwapLibrary.getAmountsOut(factory, amounts[0], path);
            IWETH(WETH).deposit{value: amounts[0]}();
            assert(IWETH(WETH).transfer(pair, amounts[0]));

        } else {
            amounts = RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
            require(amounts[0] <= msg.value, "RYZRSwapRouter: EXCESSIVE_INPUT_AMOUNT");
            IWETH(WETH).deposit{value: amounts[0]}();
            assert(IWETH(WETH).transfer(RYZRSwapLibrary.pairFor(factory, path[0], path[1]), amounts[0]));
        }

        _swap(amounts, path, to);
        // refund dust eth, if any
        uint bal = amounts[0].add(adminFeeDeduct);
        if (msg.value > bal) TransferHelper.safeTransferETH(msg.sender, msg.value - bal);
    }


    function _calculateFees(address input, address output, uint amountIn, uint amount0Out, uint amount1Out) internal view virtual returns (uint amount0Fee, uint amount1Fee) {
        IRYZRSwapPair pair = IRYZRSwapPair(RYZRSwapLibrary.pairFor(factory, input, output));
        (address token0,) = RYZRSwapLibrary.sortTokens(input, output);
        address baseToken = pair.baseToken();
        uint totalFee = pair.getTotalFee();
        amount0Fee = baseToken != token0 ? uint(0) : input == token0 ? amountIn.mul(totalFee).div(10**4) : amount0Out.mul(totalFee).div(10**4);
        amount1Fee = baseToken == token0 ? uint(0) : input != token0 ? amountIn.mul(totalFee).div(10**4) : amount1Out.mul(totalFee).div(10**4);
    }

    function _calculateAmounts(address input, address output, address token0) internal view returns (uint amountInput, uint amountOutput) {
        IRYZRSwapPair pair = IRYZRSwapPair(RYZRSwapLibrary.pairFor(factory, input, output));

        (uint reserve0, uint reserve1,, address baseToken) = pair.getReserves();
        uint totalFee = pair.getTotalFee();
        (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);

        amountInput = IERC20(input).balanceOf(address(pair)).sub(reserveInput);
        amountOutput = RYZRSwapLibrary.getAmountOut(amountInput, reserveInput, reserveOutput, baseToken != address(0), totalFee);
    }
    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    function _swapSupportingFeeOnTransferTokens(address[] memory path, address _to) internal virtual {
        for (uint i; i < path.length - 1; i++) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0,) = RYZRSwapLibrary.sortTokens(input, output);

            (uint amountInput, uint amountOutput) = _calculateAmounts(input, output, token0);
            (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));

            (uint amount0Fee, uint amount1Fee) = _calculateFees(input, output, amountInput, amount0Out, amount1Out);

            address to = i < path.length - 2 ? RYZRSwapLibrary.pairFor(factory, output, path[i + 2]) : _to;

            IRYZRSwapPair pair = IRYZRSwapPair(RYZRSwapLibrary.pairFor(factory, input, output));
            pair.swap(amount0Out, amount1Out, amount0Fee, amount1Fee, to, new bytes(0));
        }
    }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");

        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);
        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountIn,adminFee);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, feeAddressGet(), adminFeeDeduct
            );
        }

        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amountIn
        );
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        if(path[1] == pairFeeAddress[pair]){
            (amountOutMin,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountOutMin,adminFee);
        }
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "RYZRSwapRouter: CHECK_SLIPPAGE"
        );
    }
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    payable
    ensure(deadline)
    {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[0] == WETH, "RYZRSwapRouter: INVALID_PATH");
        uint amountIn = msg.value;

        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);
        uint adminFeeDeduct;
        if(path[0] == pairFeeAddress[pair]){
            (amountIn,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountIn,adminFee);
            if(address(this) != feeAddressGet()){
                payable(feeAddressGet()).transfer(adminFeeDeduct);
            }
        }

        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(pair, amountIn));
        uint balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        if(path[1] == pairFeeAddress[pair]){
            (amountOutMin,adminFeeDeduct) = RYZRSwapLibrary.adminFeeCalculation(amountOutMin,adminFee);
        }
        require(
            IERC20(path[path.length - 1]).balanceOf(to).sub(balanceBefore) >= amountOutMin,
            "RYZRSwapRouter: CHECK_SLIPPAGE"
        );
    }
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    )
    external
    virtual
    override
    ensure(deadline)
    {
        require(path.length == 2, "RYZRSwapRouter: ONLY_TWO_TOKENS_ALLOWED");
        require(path[path.length - 1] == WETH, "RYZRSwapRouter: INVALID_PATH");
        address pair = RYZRSwapLibrary.pairFor(factory, path[0], path[1]);

        if(path[0] == pairFeeAddress[pair]){
            uint adminFeeDeduct = (amountIn.mul(adminFee)) / (10000);
            amountIn = amountIn.sub(adminFeeDeduct);
            TransferHelper.safeTransferFrom(
                path[0], msg.sender, feeAddressGet(), adminFeeDeduct
            );
        }

        TransferHelper.safeTransferFrom(
            path[0], msg.sender, pair, amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint amountOut = IERC20(WETH).balanceOf(address(this));
        amountOutMin;
        if(path[1] == pairFeeAddress[pair]){
            uint adminFeeDeduct = (amountOut.mul(adminFee)) / (10000);
            amountOut = amountOut.sub(adminFeeDeduct);
        }
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    function quote(uint amountA, uint reserveA, uint reserveB) external pure virtual override returns (uint amountB) { // gas optimized
        return RYZRSwapLibrary.quote(amountA, reserveA, reserveB);
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut)
    public
    pure
    virtual
    override
    returns (uint amountOut)
    {
        return RYZRSwapLibrary.getAmountOut(amountIn, reserveIn, reserveOut, false, 0);
    }

    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut)
    public
    pure
    virtual
    override
    returns (uint amountIn)
    {
        return RYZRSwapLibrary.getAmountIn(amountOut, reserveIn, reserveOut, false, 0);
    }

    function getAmountsOut(uint amountIn, address[] memory path)
    public
    view
    virtual
    override
    returns (uint[] memory amounts)
    {
        return RYZRSwapLibrary.getAmountsOut(factory, amountIn, path);
    }

    function getAmountsIn(uint amountOut, address[] memory path)
    public
    view
    virtual
    override
    returns (uint[] memory amounts)
    {
        return RYZRSwapLibrary.getAmountsIn(factory, amountOut, path);
    }
}

contract RYZRSwapRouter is SupportingSwap {
    using SafeMath for uint;

    address private immutable BUSD;

    constructor(address _factory, address _WETH, address _BUSD, uint256 _adminFee, address _adminFeeAddress, address _adminFeeSetter) {
        factory = _factory;
        WETH = _WETH;
        BUSD = _BUSD;
        initialize(_factory, _adminFee, _adminFeeAddress, _adminFeeSetter);
        IRYZRSwapFactory(_factory).routerInitialize(address(this));
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin
    ) internal virtual returns (uint amountA, uint amountB) {
        // create the pair if it doesn't exist yet
        if (getPair(tokenA, tokenB) == address(0)) {
            if(tokenA == WETH) {
                IRYZRSwapFactory(factory).createPair(tokenB, tokenA);
                pairFeeAddress[getPair(tokenA,tokenB)] = tokenA;
            } else {
                IRYZRSwapFactory(factory).createPair(tokenA, tokenB);
                pairFeeAddress[getPair(tokenA,tokenB)] = tokenB;
            }
        }
        (uint reserveA, uint reserveB) = RYZRSwapLibrary.getReserves(factory, tokenA, tokenB);
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
            if (tokenA == WETH) {
                pairFeeAddress[getPair(tokenA,tokenB)] = tokenA;
            } else if (tokenA == BUSD) {
                pairFeeAddress[getPair(tokenA,tokenB)] = tokenA;
            } else {
                pairFeeAddress[getPair(tokenA,tokenB)] = tokenB;
            }
        } else {
            uint amountBOptimal = RYZRSwapLibrary.quote(amountADesired, reserveA, reserveB);
            if (amountBOptimal <= amountBDesired) {
                require(amountBOptimal >= amountBMin, "RYZRSwapRouter: INSUFFICIENT_B_AMOUNT");
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint amountAOptimal = RYZRSwapLibrary.quote(amountBDesired, reserveB, reserveA);
                assert(amountAOptimal <= amountADesired);
                require(amountAOptimal >= amountAMin, "RYZRSwapRouter: INSUFFICIENT_A_AMOUNT");
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    function getPair(address tokenA,address tokenB) public view returns (address){
        return IRYZRSwapFactory(factory).getPair(tokenA, tokenB);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual override ensure(deadline) returns (uint amountA, uint amountB, uint liquidity) {
        (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);
        address pair = RYZRSwapLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IRYZRSwapPair(pair).mint(to);
    }
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external virtual override payable ensure(deadline) returns (uint amountETH, uint amountToken, uint liquidity) {
        (amountETH, amountToken) = _addLiquidity(
            WETH,
            token,
            msg.value,
            amountTokenDesired,
            amountETHMin,
            amountTokenMin
        );
        address pair = RYZRSwapLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IRYZRSwapPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountA, uint amountB) {
        address pair = RYZRSwapLibrary.pairFor(factory, tokenA, tokenB);
        IRYZRSwapPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint amount0, uint amount1) = IRYZRSwapPair(pair).burn(to);
        (address token0,) = RYZRSwapLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);
        require(amountA >= amountAMin, "RYZRSwapRouter: INSUFFICIENT_A_AMOUNT");
        require(amountB >= amountBMin, "RYZRSwapRouter: INSUFFICIENT_B_AMOUNT");
    }
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountToken, uint amountETH) {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountA, uint amountB) {
        address pair = RYZRSwapLibrary.pairFor(factory, tokenA, tokenB);
        uint value = approveMax ? type(uint).max - 1 : liquidity;
        IRYZRSwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
    }
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountToken, uint amountETH) {
        address pair = RYZRSwapLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? type(uint).max - 1 : liquidity;
        IRYZRSwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) public virtual override ensure(deadline) returns (uint amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, IERC20(token).balanceOf(address(this)));
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external virtual override returns (uint amountETH) {
        address pair = RYZRSwapLibrary.pairFor(factory, token, WETH);
        uint value = approveMax ? type(uint).max - 1 : liquidity;
        IRYZRSwapPair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token, liquidity, amountTokenMin, amountETHMin, to, deadline
        );
    }
}