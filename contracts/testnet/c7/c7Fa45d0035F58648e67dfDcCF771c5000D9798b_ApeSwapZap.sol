// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.6;

/*
  ______                     ______                                 
 /      \                   /      \                                
|  ▓▓▓▓▓▓\ ______   ______ |  ▓▓▓▓▓▓\__   __   __  ______   ______  
| ▓▓__| ▓▓/      \ /      \| ▓▓___\▓▓  \ |  \ |  \|      \ /      \ 
| ▓▓    ▓▓  ▓▓▓▓▓▓\  ▓▓▓▓▓▓\\▓▓    \| ▓▓ | ▓▓ | ▓▓ \▓▓▓▓▓▓\  ▓▓▓▓▓▓\
| ▓▓▓▓▓▓▓▓ ▓▓  | ▓▓ ▓▓    ▓▓_\▓▓▓▓▓▓\ ▓▓ | ▓▓ | ▓▓/      ▓▓ ▓▓  | ▓▓
| ▓▓  | ▓▓ ▓▓__/ ▓▓ ▓▓▓▓▓▓▓▓  \__| ▓▓ ▓▓_/ ▓▓_/ ▓▓  ▓▓▓▓▓▓▓ ▓▓__/ ▓▓
| ▓▓  | ▓▓ ▓▓    ▓▓\▓▓     \\▓▓    ▓▓\▓▓   ▓▓   ▓▓\▓▓    ▓▓ ▓▓    ▓▓
 \▓▓   \▓▓ ▓▓▓▓▓▓▓  \▓▓▓▓▓▓▓ \▓▓▓▓▓▓  \▓▓▓▓▓\▓▓▓▓  \▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓ 
         | ▓▓                                             | ▓▓      
         | ▓▓                                             | ▓▓      
          \▓▓                                              \▓▓         

 * App:             https://apeswap.finance
 * Medium:          https://ape-swap.medium.com
 * Twitter:         https://twitter.com/ape_swap
 * Discord:         https://discord.com/invite/apeswap
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/ApeSwapFinance
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/IApeRouter02.sol";
import "./lib/IApeFactory.sol";
import "./lib/IApePair.sol";
import "./lib/IWETH.sol";
import "./lib/ICustomBill.sol";

contract ApeSwapZap {
    IApeRouter02 public router;
    IApeFactory public factory;
    address WNATIVE;

    constructor(address _router) {
        router = IApeRouter02(_router);
        factory = IApeFactory(router.factory());
        WNATIVE = router.WETH();
    }

    /// @notice get min amounts for swaps
    /// @param _inputAmount total input amount for swap
    /// @param _path0 path from input token to LP token0
    /// @param _path1 path from input token to LP token1
    function getMinAmounts(
        uint256 _inputAmount,
        address[] calldata _path0,
        address[] calldata _path1
    )
        external
        view
        returns (
            uint256[2] memory _minAmountsSwap,
            uint256[2] memory _minAmountsLP
        )
    {
        require(
            _path0.length >= 2 || _path1.length >= 2,
            "ApeSwapZap: Needs at least one path"
        );

        uint256 _inputAmountHalf = _inputAmount / 2;

        uint256 _minAmountSwap0 = _inputAmountHalf;
        if (_path0.length != 0) {
            uint256[] memory amountsOut0 = router.getAmountsOut(
                _inputAmountHalf,
                _path0
            );
            _minAmountSwap0 = amountsOut0[amountsOut0.length - 1];
        }

        uint256 _minAmountSwap1 = _inputAmountHalf;
        if (_path1.length != 0) {
            uint256[] memory amountsOut1 = router.getAmountsOut(
                _inputAmountHalf,
                _path1
            );
            _minAmountSwap1 = amountsOut1[amountsOut1.length - 1];
        }

        address token0 = _path0.length == 0
            ? _path1[0]
            : _path0[_path0.length - 1];
        address token1 = _path1.length == 0
            ? _path0[0]
            : _path1[_path1.length - 1];

        IApePair lp = IApePair(factory.getPair(token0, token1));
        (uint256 reserveA, uint256 reserveB, ) = lp.getReserves();
        if (token0 == lp.token1()) {
            (reserveA, reserveB) = (reserveB, reserveA);
        }
        uint256 amountB = router.quote(_minAmountSwap0, reserveA, reserveB);

        _minAmountsSwap = [_minAmountSwap0, _minAmountSwap1];
        _minAmountsLP = [_minAmountSwap0, amountB];
    }

    /// @notice Zap single token to LP
    /// @param _inputToken Input token
    /// @param _inputAmount Input amount
    /// @param _lpTokens Tokens of LP to zap to
    /// @param _path0 Path from input token to LP token0
    /// @param _path1 Path from input token to LP token1
    /// @param _minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param _minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param _to address to receive LPs
    /// @param _deadline Unix timestamp after which the transaction will revert
    function zap(
        IERC20 _inputToken,
        uint256 _inputAmount,
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        address _to,
        uint256 _deadline
    ) public {
        uint256 _balanceBefore = _getBalance(address(_inputToken));
        _inputToken.transferFrom(msg.sender, address(this), _inputAmount);
        _inputAmount = _getBalance(address(_inputToken)) - _balanceBefore;

        _zap(
            _inputToken,
            _inputAmount,
            _lpTokens,
            _path0,
            _path1,
            _minAmountsSwap,
            _minAmountsLP,
            _to,
            _deadline
        );
    }

    /// @notice Zap native token to LP
    /// @param _lpTokens Tokens of LP to zap to
    /// @param _path0 Path from input token to LP token0
    /// @param _path1 Path from input token to LP token1
    /// @param _minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param _minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param _to address to receive LPs
    /// @param _deadline Unix timestamp after which the transaction will revert
    function zapNative(
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        address _to,
        uint256 _deadline
    ) public payable {
        uint256 _inputAmount = msg.value;
        IERC20 _inputToken = IERC20(WNATIVE);
        IWETH(WNATIVE).deposit{ value: _inputAmount }();
        if (_to == address(0)) {
            _to = msg.sender;
        }

        _zap(
            _inputToken,
            _inputAmount,
            _lpTokens,
            _path0,
            _path1,
            _minAmountsSwap,
            _minAmountsLP,
            _to,
            _deadline
        );
    }

    function _zap(
        IERC20 _inputToken,
        uint256 _inputAmount,
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        address _to,
        uint256 _deadline
    ) internal {
        require(
            _lpTokens.length == 2,
            "ApeSwapZap: need exactly 2 tokens to form a LP"
        );
        require(
            factory.getPair(_lpTokens[0], _lpTokens[1]) != address(0),
            "ApeSwapZap: Pair doesn't exist"
        );

        _inputToken.approve(address(router), _inputAmount);

        uint256 amount0 = _inputAmount / 2;
        if (_lpTokens[0] != address(_inputToken)) {
            require(
                _path0[0] == address(_inputToken),
                "ApeSwapZap: wrong path _path0[0]"
            );
            require(
                _path0[_path0.length - 1] == _lpTokens[0],
                "ApeSwapZap: wrong path _path0[-1]"
            );
            uint256 _balanceBefore = _getBalance(_lpTokens[0]);
            router.swapExactTokensForTokens(
                _inputAmount / 2,
                _minAmountsSwap[0],
                _path0,
                address(this),
                _deadline
            );
            amount0 = _getBalance(_lpTokens[0]) - _balanceBefore;
        }

        uint256 amount1 = _inputAmount / 2;
        if (_lpTokens[1] != address(_inputToken)) {
            require(
                _path1[0] == address(_inputToken),
                "ApeSwapZap: wrong path _path1[0]"
            );
            require(
                _path1[_path1.length - 1] == _lpTokens[1],
                "ApeSwapZap: wrong path _path1[-1]"
            );
            uint256 _balanceBefore = _getBalance(_lpTokens[1]);
            router.swapExactTokensForTokens(
                _inputAmount / 2,
                _minAmountsSwap[1],
                _path1,
                address(this),
                _deadline
            );
            amount1 = _getBalance(_lpTokens[1]) - _balanceBefore;
        }

        IERC20(_lpTokens[0]).approve(address(router), amount0);
        IERC20(_lpTokens[1]).approve(address(router), amount1);
        router.addLiquidity(
            _lpTokens[0],
            _lpTokens[1],
            amount0,
            amount1,
            _minAmountsLP[0],
            _minAmountsLP[1],
            _to,
            _deadline
        );

        uint256 _balance0 = _getBalance(_lpTokens[0]);
        if (_balance0 > 0) {
            _transfer(_lpTokens[0], _balance0);
        }
        uint256 _balance1 = _getBalance(_lpTokens[1]);
        if (_balance1 > 0) {
            _transfer(_lpTokens[1], _balance1);
        }
    }

    function _getBalance(address _token)
        internal
        view
        returns (uint256 _balance)
    {
        _balance = IERC20(_token).balanceOf(address(this));
    }

    function _transfer(address _token, uint256 _amount) internal {
        if (_token == WNATIVE) {
            IWETH(WNATIVE).withdraw(_amount);
            payable(msg.sender).transfer(_amount);
        } else {
            IERC20(_token).transfer(msg.sender, _amount);
        }
    }

    /// @notice Zap native token to LP
    /// @param _lpTokens Tokens of LP to zap to
    /// @param _path0 Path from input token to LP token0
    /// @param _path1 Path from input token to LP token1
    /// @param _minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param _minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param _deadline Unix timestamp after which the transaction will revert
    /// @param _bill Treasury bill address
    /// @param _maxPrice Max price of treasury bill
    function zapTBills(
        IERC20 _inputToken,
        uint256 _inputAmount,
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        uint256 _deadline,
        ICustomBill _bill,
        uint256 _maxPrice
    ) public {
        IApePair _pair = IApePair(_bill.principalToken());
        require(
            (_lpTokens[0] == _pair.token0() &&
                _lpTokens[1] == _pair.token1()) ||
                (_lpTokens[1] == _pair.token0() &&
                    _lpTokens[0] == _pair.token1()),
            "Wrong LP pair for TBill"
        );

        zap(
            _inputToken,
            _inputAmount,
            _lpTokens,
            _path0,
            _path1,
            _minAmountsSwap,
            _minAmountsLP,
            address(this),
            _deadline
        );

        uint256 balance = _pair.balanceOf(address(this));
        _pair.approve(address(_bill), balance);
        _bill.deposit(balance, _maxPrice, msg.sender);
    }

    /// @notice Zap native token to Treasury Bill
    /// @param _lpTokens Tokens of LP to zap to
    /// @param _path0 Path from input token to LP token0
    /// @param _path1 Path from input token to LP token1
    /// @param _minAmountsSwap The minimum amount of output tokens that must be received for swap
    /// @param _minAmountsLP AmountAMin and amountBMin for adding liquidity
    /// @param _deadline Unix timestamp after which the transaction will revert
    /// @param _bill Treasury bill address
    /// @param _maxPrice Max price of treasury bill
    function zapNativeTBills(
        address[] memory _lpTokens, //[tokenA, tokenB]
        address[] calldata _path0,
        address[] calldata _path1,
        uint256[] memory _minAmountsSwap, //[A, B]
        uint256[] memory _minAmountsLP, //[amountAMin, amountBMin]
        uint256 _deadline,
        ICustomBill _bill,
        uint256 _maxPrice
    ) public payable{
        IApePair _pair = IApePair(_bill.principalToken());
        require(
            (_lpTokens[0] == _pair.token0() &&
                _lpTokens[1] == _pair.token1()) ||
                (_lpTokens[1] == _pair.token0() &&
                    _lpTokens[0] == _pair.token1()),
            "Wrong LP pair for TBill"
        );

        zapNative(
            _lpTokens,
            _path0,
            _path1,
            _minAmountsSwap,
            _minAmountsLP,
            address(this),
            _deadline
        );

        uint256 balance = _pair.balanceOf(address(this));
        _pair.approve(address(_bill), balance);
        _bill.deposit(balance, _maxPrice, msg.sender);
    }

    /// @notice Zap non APE-LPs to APE-LPs
    /// @param _router The non APE-LP router
    /// @param _lp LP address to zap
    /// @param _amount Amout of LPs to zap
    /// @param _amountAMinRemove The minimum amount of token0 to receive after removing liquidity
    /// @param _amountBMinRemove The minimum amount of token1 to receive after removing liquidity
    /// @param _amountAMinAdd The minimum amount of token0 to add to APE-LP on add liquidity
    /// @param _amountBMinAdd The minimum amount of token1 to add to APE-LP on add liquidity
    /// @param _deadline Unix timestamp after which the transaction will revert
    function zapLP(
        IApeRouter02 _router,
        IApePair _lp,
        uint256 _amount,
        uint256 _amountAMinRemove,
        uint256 _amountBMinRemove,
        uint256 _amountAMinAdd,
        uint256 _amountBMinAdd,
        uint256 _deadline
    ) external {
        address token0 = _lp.token0();
        address token1 = _lp.token1();

        _lp.transferFrom(msg.sender, address(this), _amount);
        _lp.approve(address(_router), _amount);
        (uint256 amountAReceived, uint256 amountBReceived) = _router
            .removeLiquidity(
                token0,
                token1,
                _amount,
                _amountAMinRemove,
                _amountBMinRemove,
                address(this),
                _deadline
            );

        IERC20(token0).approve(address(router), amountAReceived);
        IERC20(token1).approve(address(router), amountBReceived);
        (uint256 amountASent, uint256 amountBSent, ) = router.addLiquidity(
            token0,
            token1,
            amountAReceived,
            amountBReceived,
            _amountAMinAdd,
            _amountBMinAdd,
            msg.sender,
            _deadline
        );

        if (amountAReceived - amountASent > 0) {
            IERC20(token0).transfer(msg.sender, amountAReceived - amountASent);
        }
        if (amountBReceived - amountBSent > 0) {
            IERC20(token1).transfer(msg.sender, amountBReceived - amountBSent);
        }
    }

    /// @dev The receive method is used as a fallback function in a contract and is called when ether is sent to a contract with no calldata.
    receive() external payable {
        if (msg.sender != address(router)) {
            payable(msg.sender).transfer(msg.value);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

interface ICustomBill {
    function principalToken() external returns (address);

    function deposit(
        uint256 _amount,
        uint256 _maxPrice,
        address _depositor
    ) external returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./IApeRouter01.sol";

interface IApeRouter02 is IApeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
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
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IApeRouter01 {
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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.6;

interface IApePair {
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

// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.6.6;

interface IApeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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