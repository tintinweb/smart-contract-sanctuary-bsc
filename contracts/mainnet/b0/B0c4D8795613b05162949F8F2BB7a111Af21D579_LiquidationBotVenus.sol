//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "./uniswap-contracts/interfaces/IUniswapV2Router02.sol";
import "./uniswap-contracts/interfaces/IUniswapV2Pair.sol";
import "./uniswap-contracts/interfaces/IUniswapV2Factory.sol";
import "./uniswap-contracts/interfaces/IUniswapV2Callee.sol";
import "./LiquidationBotInterface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


interface CToken {
    function balanceOf(address owner) external view returns (uint256);
    function redeem(uint redeemTokens) external returns (uint256);
}

interface CERC20Token is CToken {
    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint256);
    function underlying() external returns (address);
}

interface CETHToken is CToken {
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface WrappedNative is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

interface Comptroller {
    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount
    ) external returns (uint256);
}

interface VenusLiquidator {
    function liquidateBorrow(
        address vTokenBorrow,
        address borrower,
        uint256 repayAmount,
        address vTokenCollateral
    ) external payable;
}

error LiquidationNotAllowed(uint256 errCode);


contract LiquidationBotVenus is LiquidationBotInterface, IUniswapV2Callee{
    enum LiquidationType {
        TokenToToken,
        EthToToken,
        TokenToEth
    }
    event FailedLiquidation(
        address comptroller,
        address borrower, 
        address cTokenBorrow, 
        address cTokenCollateral, 
        uint256 repayAmount,
        uint256 errCode
    );
    event SuccessfulLiquidation(
        address profitReceiver,
        address borrower,
        address cTokenCollateral, 
        address cTokenborrow,
        uint256 repayAmount,
        uint256 redeemAmount,
        uint256 amountReturnToDEX
    );

    address owner;
    mapping(address => bool) internal allowedBots;

    struct LiquidationLocalVars {
        address factory;
        address router;
        address comptroller;
        address borrower;
        address cTokenBorrow;
        address cTokenCollateral;
        address collateralToken;
        address borrowToken;
        address pairAddress;
        address profitReceiver;
        uint256 repayAmount;
        uint256 amountToken;
        address[] path;
        LiquidationType liquidationType;
        address liquidatorContract;
    }

    function packArgs(
        LiquidationLocalVars memory vars
    ) internal pure returns (bytes memory) {
        return abi.encode(vars);
    }

    function unpackArgs(bytes calldata data) internal pure returns (LiquidationLocalVars memory vars) {
        vars = abi.decode(data, (LiquidationLocalVars));
    }

    constructor(address[] memory bots) {
        owner = msg.sender;
        _addAllowedBotAddresses(bots);
    }

    receive() external payable {
    }

    modifier checkBotAddressIsAllowed() {
        require(allowedBots[msg.sender], "Not allowed bot");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function isAllowedBot(address bot) external view onlyOwner returns(bool) {
        return allowedBots[bot];
    }

    function addAllowedBotAddresses(address[] memory bots) external onlyOwner {
        _addAllowedBotAddresses(bots);
    }

    function _addAllowedBotAddresses(address[] memory bots) internal {
        for (uint256 i = 0; i < bots.length; i++) {
            allowedBots[bots[i]] = true;
        }
    }

    function removeAllowedBotAddresses(address[] memory bots) external onlyOwner {
        for (uint256 i = 0; i < bots.length; i++) {
            delete allowedBots[bots[i]];
        }
    }

    struct LiquidateArgs {
        address router;
        address comptroller;
        address borrower;
        address cTokenBorrow; 
        address cTokenCollateral;
        uint256 repayAmount;
        address profitReceiver;
        address liquidatorContract;
    }

    function unpackLiquidateArgs(bytes memory data) internal pure returns (LiquidateArgs memory vars) {
        (
            vars.router, 
            vars.comptroller, 
            vars.borrower, 
            vars.cTokenBorrow, 
            vars.cTokenCollateral, 
            vars.repayAmount, 
            vars.profitReceiver, 
            vars.liquidatorContract
        ) = abi.decode(data, (address, address, address, address, address, uint256 ,address, address));
    }

    function liquidateTokenToToken(
        bytes memory data
    ) external override checkBotAddressIsAllowed {
        LiquidateArgs memory args = unpackLiquidateArgs(data);

        address factory = IUniswapV2Router02(args.router).factory();
        address borrowUnderlyingToken = CERC20Token(args.cTokenBorrow).underlying();
        address collateralUnderlyingToken = CERC20Token(args.cTokenCollateral).underlying();
        (address token0, address token1) = borrowUnderlyingToken < collateralUnderlyingToken ? (borrowUnderlyingToken, collateralUnderlyingToken) : (collateralUnderlyingToken, borrowUnderlyingToken);

        bool isToken0IsBorrow = token0 == borrowUnderlyingToken;
        address pairAddress = IUniswapV2Factory(factory).getPair(token0, token1);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        LiquidationLocalVars memory vars;
        vars.router = args.router;
        vars.comptroller = args.comptroller;
        vars.borrower = args.borrower;
        vars.cTokenBorrow = args.cTokenBorrow;
        vars.cTokenCollateral = args.cTokenCollateral;
        vars.repayAmount = args.repayAmount;
        vars.pairAddress = pairAddress;
        vars.profitReceiver = args.profitReceiver;
        vars.liquidationType = LiquidationType.TokenToToken;
        vars.liquidatorContract = args.liquidatorContract;

        // Possible take repay amount from comptroller
        swap(vars, isToken0IsBorrow, pair);
    }

    function liquidateTokenToEth(
        bytes memory data
    ) external override checkBotAddressIsAllowed {
        LiquidateArgs memory args = unpackLiquidateArgs(data);

        address factory = IUniswapV2Router02(args.router).factory();
        address borrowUnderlyingToken = CERC20Token(args.cTokenBorrow).underlying();
        address collateralUnderlyingToken = IUniswapV2Router02(args.router).WETH();
        (address token0, address token1) = borrowUnderlyingToken < collateralUnderlyingToken ? (borrowUnderlyingToken, collateralUnderlyingToken) : (collateralUnderlyingToken, borrowUnderlyingToken);

        bool isToken0IsBorrow = token0 == borrowUnderlyingToken;
        address pairAddress = IUniswapV2Factory(factory).getPair(token0, token1);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        LiquidationLocalVars memory vars;
        vars.router = args.router;
        vars.comptroller = args.comptroller;
        vars.borrower = args.borrower;
        vars.cTokenBorrow = args.cTokenBorrow;
        vars.cTokenCollateral = args.cTokenCollateral;
        vars.repayAmount = args.repayAmount;
        vars.pairAddress = pairAddress;
        vars.profitReceiver = args.profitReceiver;
        vars.liquidationType = LiquidationType.TokenToEth;
        vars.liquidatorContract = args.liquidatorContract;

        swap(vars, isToken0IsBorrow, pair);
    }

    function liquidateEthToToken(
        bytes memory data
    ) external override checkBotAddressIsAllowed {
        LiquidateArgs memory args = unpackLiquidateArgs(data);

        address factory = IUniswapV2Router02(args.router).factory();
        address borrowUnderlyingToken = IUniswapV2Router02(args.router).WETH();
        address collateralUnderlyingToken = CERC20Token(args.cTokenCollateral).underlying();
        (address token0, address token1) = borrowUnderlyingToken < collateralUnderlyingToken ? (borrowUnderlyingToken, collateralUnderlyingToken) : (collateralUnderlyingToken, borrowUnderlyingToken);

        bool isToken0IsBorrow = token0 == borrowUnderlyingToken;
        address pairAddress = IUniswapV2Factory(factory).getPair(token0, token1);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        LiquidationLocalVars memory vars;
        vars.router = args.router;
        vars.comptroller = args.comptroller;
        vars.borrower = args.borrower;
        vars.cTokenBorrow = args.cTokenBorrow;
        vars.cTokenCollateral = args.cTokenCollateral;
        vars.repayAmount = args.repayAmount;
        vars.pairAddress = pairAddress;
        vars.profitReceiver = args.profitReceiver;
        vars.liquidationType = LiquidationType.EthToToken;
        vars.liquidatorContract = args.liquidatorContract;

        swap(vars, isToken0IsBorrow, pair);
    }

    function swap(LiquidationLocalVars memory vars, bool isToken0IsBorrow, IUniswapV2Pair pair) internal {
        if (isToken0IsBorrow) {
            (uint112 reserve0, , ) = pair.getReserves();
            if (reserve0 <= vars.repayAmount) {
                vars.repayAmount = reserve0 - 1;
            }
            bytes memory liquidateData = packArgs(vars);
            pair.swap(vars.repayAmount, 0, address(this), liquidateData);
            return;
        }
        (, uint112 reserve1, ) = pair.getReserves();
        if (reserve1 <= vars.repayAmount) {
            vars.repayAmount = reserve1 - 1;
        }
        bytes memory liquidateData = packArgs(vars);
        pair.swap(0, vars.repayAmount, address(this), liquidateData);
    }

    function uniswapV2Call(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external override {
        LiquidationLocalVars memory vars = unpackArgs(_data);
        vars.factory = IUniswapV2Router02(vars.router).factory();

        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        require(
            msg.sender == vars.pairAddress,
            "Unauthorized"
        );
        require(_amount0 == 0 || _amount1 == 0, "Both amounts non zero");
        vars.amountToken = _amount0 == 0 ? _amount1 : _amount0;

        vars.path = new address[](2);
        // examples
        // _amount0 = 123 -> means token0 is borrow token
        // path[0] = token0 (borrow)
        // path[1] = token1 (collateral)

        // _amount0 = 0 -> means token0 is collateral
        // path[0] = token1 (borrow)
        // path[1] = token0 (collateral)
        vars.path[0] = _amount0 == 0 ? token1 : token0;
        vars.path[1] = _amount0 == 0 ? token0 : token1;

        // So path[0] is always borrow token address
        vars.borrowToken = vars.path[0];
        // So path[1] is always collateral token address
        vars.collateralToken = vars.path[1];


        if (vars.liquidationType == LiquidationType.TokenToToken) {
            _liquidateTokenToToken(vars);
        }
        if (vars.liquidationType == LiquidationType.TokenToEth) {
            _liquidateTokenToETH(vars);
        }
        if (vars.liquidationType == LiquidationType.EthToToken) {
            _liquidateEthToToken(vars);
        }
        // TODO ETH to ETH or TokenA to TokenA is not so simple because DEX doesn't have pair where token0 == token1
    }

    function _liquidateTokenToToken(LiquidationLocalVars memory vars) internal {
        CERC20Token cERC20CollateralToken = CERC20Token(vars.cTokenCollateral);

        IERC20 erc20Collateral = IERC20(vars.collateralToken);
        // Approve liquidatorContract to CTokenBorrow by underlying ERC20 Token
        IERC20(vars.borrowToken).approve(address(vars.liquidatorContract), vars.repayAmount);
        VenusLiquidator liquidationContract = VenusLiquidator(vars.liquidatorContract);
        liquidationContract.liquidateBorrow(
            vars.cTokenBorrow,
            vars.borrower, 
            vars.repayAmount, 
            vars.cTokenCollateral
        );
        uint errCode;

        uint256 balanceBeforeRedeem = erc20Collateral.balanceOf(address(this));
        errCode = cERC20CollateralToken.redeem(cERC20CollateralToken.balanceOf(address(this)));
        require(errCode == 0, "Err while redeem");

        uint256 balanceAfterRedeem = erc20Collateral.balanceOf(address(this));
        require(balanceAfterRedeem > balanceBeforeRedeem, "insufficent collateral balance");
        uint256 profit = balanceAfterRedeem - balanceBeforeRedeem;

        // Amount required to return for DEX
        uint256 amountRequired = IUniswapV2Router02(vars.router).getAmountsIn(
            vars.amountToken,
            vars.path
        )[0];
        require(amountRequired < profit, noProfitDealMessage(amountRequired, profit));

        // Return debt + % to DEX
        erc20Collateral.transfer(msg.sender, amountRequired);
        // Send rest of the profit to profitReceiver address
        erc20Collateral.transfer(vars.profitReceiver, profit - amountRequired);

        emit SuccessfulLiquidation(
            vars.profitReceiver, 
            vars.borrower,
            vars.cTokenCollateral, 
            vars.cTokenBorrow,
            vars.repayAmount,
            profit,
            amountRequired
        );
    }

    function _liquidateTokenToETH(LiquidationLocalVars memory vars) internal {
        CETHToken cETHCollateralToken = CETHToken(vars.cTokenCollateral);

        // WETH
        IERC20 wethCollateral = IERC20(vars.collateralToken);
        // Approve liquidatorContract to CTokenBorrow by underlying ERC20 Token
        IERC20(vars.borrowToken).approve(address(vars.liquidatorContract), vars.repayAmount);

        VenusLiquidator liquidationContract = VenusLiquidator(vars.liquidatorContract);
        liquidationContract.liquidateBorrow(
            vars.cTokenBorrow,
            vars.borrower, 
            vars.repayAmount, 
            vars.cTokenCollateral
        );
        uint errCode;

        uint256 balanceBeforeRedeem = wethCollateral.balanceOf(address(this));

        uint256 ethBalanceBefore = address(this).balance;

        // In case of cETH collateral token redeem will trasnfer ether to address
        errCode = cETHCollateralToken.redeem(cETHCollateralToken.balanceOf(address(this)));
        require(errCode == 0, "Err while redeem");
        uint256 ethBalanceAfter = address(this).balance;

        // Deposit ether to WETH contract for return WETH to DEX
        WrappedNative(vars.collateralToken).deposit{value: ethBalanceAfter - ethBalanceBefore}();

        uint256 balanceAfterRedeem = wethCollateral.balanceOf(address(this));
        require(balanceAfterRedeem > balanceBeforeRedeem, "insufficent collateral balance");
        uint256 profit = balanceAfterRedeem - balanceBeforeRedeem;

        // Amount required to return for DEX
        uint256 amountRequired = IUniswapV2Router02(vars.router).getAmountsIn(
            vars.amountToken,
            vars.path
        )[0];
        require(amountRequired < profit, noProfitDealMessage(amountRequired, profit));

        // Return debt + % to DEX
        wethCollateral.transfer(msg.sender, amountRequired);
        // Send rest of the profit to profitReceiver address
        wethCollateral.transfer(vars.profitReceiver, profit - amountRequired);

        emit SuccessfulLiquidation(
            vars.profitReceiver, 
            vars.borrower,
            vars.cTokenCollateral, 
            vars.cTokenBorrow,
            vars.repayAmount,
            profit,
            amountRequired
        );
    }

    function _liquidateEthToToken(LiquidationLocalVars memory vars) internal {
        CERC20Token cERC20CollateralToken = CERC20Token(vars.cTokenCollateral);

        IERC20 erc20Collateral = IERC20(vars.collateralToken);
        // Move ether from weth to this contract
        WrappedNative(vars.borrowToken).withdraw(vars.repayAmount);

        // Send ether to VenusLiquidator as repayAmount
        // Raise revert in case of error
        VenusLiquidator liquidationContract = VenusLiquidator(vars.liquidatorContract);
        liquidationContract.liquidateBorrow{value: vars.repayAmount}(
            vars.cTokenBorrow,
            vars.borrower, 
            vars.repayAmount, 
            vars.cTokenCollateral
        );

        uint256 balanceBeforeRedeem = erc20Collateral.balanceOf(address(this));

        uint256 errCode = cERC20CollateralToken.redeem(cERC20CollateralToken.balanceOf(address(this)));
        require(errCode == 0, "Err while redeem");

        uint256 balanceAfterRedeem = erc20Collateral.balanceOf(address(this));
        require(balanceAfterRedeem > balanceBeforeRedeem, "insufficent collateral balance");
        uint256 profit = balanceAfterRedeem - balanceBeforeRedeem;

        // Amount required to return for DEX
        uint256 amountRequired = IUniswapV2Router02(vars.router).getAmountsIn(
            vars.amountToken,
            vars.path
        )[0];
        require(amountRequired < profit, noProfitDealMessage(amountRequired, profit));

        // Return debt + % to DEX
        erc20Collateral.transfer(msg.sender, amountRequired);
        // Send rest of the profit to profitReceiver address
        erc20Collateral.transfer(vars.profitReceiver, profit - amountRequired);

        emit SuccessfulLiquidation(
            vars.profitReceiver, 
            vars.borrower,
            vars.cTokenCollateral, 
            vars.cTokenBorrow,
            vars.repayAmount,
            profit,
            amountRequired
        );
    }

    function noProfitDealMessage(uint256 amountRequired, uint256 profit) internal pure returns(string memory) {
        return string(abi.encodePacked(
            "no profit deal. ", 
            "profit ", Strings.toString(profit), ". " 
            "amountRequired ", Strings.toString(amountRequired)
        ));
    }
}

// SPDX-License-Identifier: GPL-3.0
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

// SPDX-License-Identifier: GPL-3.0
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

// SPDX-License-Identifier: GPL-3.0
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

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

interface IUniswapV2Callee {
    function uniswapV2Call(address sender, uint amount0, uint amount1, bytes calldata data) external;
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

interface LiquidationBotInterface {
    function liquidateTokenToToken(bytes memory argsData) external;
    function liquidateTokenToEth(bytes memory argsData) external;
    function liquidateEthToToken(bytes memory argsData) external;
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

// SPDX-License-Identifier: GPL-3.0
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