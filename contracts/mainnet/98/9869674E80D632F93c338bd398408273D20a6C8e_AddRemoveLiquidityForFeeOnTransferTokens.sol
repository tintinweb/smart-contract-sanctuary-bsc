// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IBabyDogeRouter.sol";
import "./IBabyDogeFactory.sol";
import "./IBabyDogePair.sol";
import "./IWETH.sol";

// @title Contract is designed to add and remove liquidity for token pairs which contain taxed token
contract AddRemoveLiquidityForFeeOnTransferTokens {
    IBabyDogeRouter immutable public router;
    IBabyDogeFactory immutable public factory;
    address immutable public WETH;

    // user account => lp token address => amount of LP tokens received
    mapping(address => mapping(address => uint256)) public lpReceived;

    event LiquidityAdded (
        address indexed account,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 lpAmount
    );

    event LiquidityRemoved (
        address indexed account,
        address indexed tokenA,
        address indexed tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 lpAmount
    );

    /*
     * @param _router Baby Doge router address
     */
    constructor(
        IBabyDogeRouter _router
    ){
        router = _router;
        factory = IBabyDogeFactory(_router.factory());
        WETH = _router.WETH();
    }

    receive() external payable {}

    /*
     * @param tokenA First token address
     * @param tokenB Second token address
     * @param amountADesired Amount of tokenA that user wants to add to liquidity
     * @param amountBDesired Amount of tokenB that user wants to add to liquidity
     * @param amountAMin Minimum amount of tokenA that must be added to liquidity
     * @param amountBMin Minimum amount of tokenB that must be added to liquidity
     * @param to Account address that should receive LP tokens
     * @param deadline Timestamp, until when this transaction must be executed
     * @return amountA Amount of tokenA added to liquidity
     * @return amountB Amount of tokenB added to liquidity
     * @return liquidity Amount of liquidity received
     */
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
    ) {
        IERC20(tokenA).transferFrom(msg.sender, address(this), amountADesired);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountBDesired);
        _approveIfRequired(tokenA, amountADesired);
        _approveIfRequired(tokenB, amountBDesired);

        (amountA, amountB, liquidity) = router.addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin,
            to,
            deadline
        );

        address lpToken = factory.getPair(tokenA, tokenB);
        lpReceived[msg.sender][lpToken] += liquidity;

        uint256 remainingAmountA = IERC20(tokenA).balanceOf(address(this));
        if (remainingAmountA > 0) {
            IERC20(tokenA).transfer(msg.sender, remainingAmountA);
        }

        uint256 remainingAmountB = IERC20(tokenB).balanceOf(address(this));
        if (remainingAmountB > 0) {
            IERC20(tokenB).transfer(msg.sender, remainingAmountB);
        }

        emit LiquidityAdded(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            liquidity
        );
    }


    /*
     * @param token ERC20 token address to add to liqidity
     * @param amountTokenDesired Amount of ERC20 token that user wants to add to liquidity
     * @param amountTokenMin Minimum amount of ERC20 token that must be added to liquidity
     * @param amountETHMin Minimum amount of BNB that must be added to liquidity
     * @param to Account address that should receive LP tokens
     * @param deadline Timestamp, until when this transaction must be executed
     * @return amountToken Amount of ERC20 token added to liquidity
     * @return amountETH Amount of BNB added to liquidity
     * @return liquidity Amount of liquidity received
     */
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address payable to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    ) {
        IERC20(token).transferFrom(msg.sender, address(this), amountTokenDesired);
        _approveIfRequired(token, amountTokenDesired);

        (amountToken, amountETH, liquidity) = router.addLiquidityETH{value : msg.value}(
            token,
            amountTokenDesired,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );

        address lpToken = factory.getPair(token, WETH);
        lpReceived[msg.sender][lpToken] += liquidity;

        uint256 remainingTokens = IERC20(token).balanceOf(address(this));
        if (remainingTokens > 0) {
            IERC20(token).transfer(msg.sender, remainingTokens);
        }

        uint256 bnbBalance = address(this).balance;
        if (bnbBalance > 0) {
            (bool success,) = payable(msg.sender).call{value : bnbBalance}("");
            require(success, "BNB return failed");
        }

        emit LiquidityAdded(
            msg.sender,
            token,
            WETH,
            amountToken,
            amountETH,
            liquidity
        );
    }


    /*
     * @param tokenA First token address
     * @param tokenB Second token address
     * @param liquidity Amount of LP tokens that should be transferred
     * @param amountAMin Minimum amount of tokenA that must be returned
     * @param amountBMin Minimum amount of tokenB that must be returned
     * @param to Account address that should receive tokens
     * @param deadline Timestamp, until when this transaction must be executed
     * @return amountA Amount of tokenA received
     * @return amountB Amount of tokenB received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) public returns (uint256 amountA, uint256 amountB) {
        address lpToken = factory.getPair(tokenA, tokenB);
        IERC20(lpToken).transferFrom(msg.sender, address(this), liquidity);
        _approveIfRequired(lpToken, liquidity);

        require(liquidity <= lpReceived[msg.sender][lpToken], "Over received amount");
        lpReceived[msg.sender][lpToken] -= liquidity;

        (amountA, amountB) = router.removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            address(this),
            deadline
        );

        IERC20(tokenA).transfer(to, IERC20(tokenA).balanceOf(address(this)));
        IERC20(tokenB).transfer(to, IERC20(tokenB).balanceOf(address(this)));

        emit LiquidityRemoved(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            liquidity
        );
    }


    /*
     * @param token ERC20 token address
     * @param liquidity Amount of LP tokens that should be transferred
     * @param amountTokenMin Minimum amount of ERC20 token that must be returned
     * @param amountETHMin Minimum amount of BNB that must be returned
     * @param to Account address that should receive tokens/BNB
     * @param deadline Timestamp, until when this transaction must be executed
     * @return amountToken Amount of ERC20 token received
     * @return amountETH Amount of BNB received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address payable to,
        uint256 deadline
    ) public returns (uint256 amountToken, uint256 amountETH) {
        address lpToken = factory.getPair(token, WETH);
        IERC20(lpToken).transferFrom(msg.sender, address(this), liquidity);
        _approveIfRequired(lpToken, liquidity);

        require(liquidity <= lpReceived[msg.sender][lpToken], "Over received amount");
        lpReceived[msg.sender][lpToken] -= liquidity;

        (amountToken, amountETH) = router.removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );

        IWETH(WETH).withdraw(amountETH);
        (bool success,) = to.call{value : amountETH}("");
        require(success, "BNB transfer failed");

        IERC20(token).transfer(to, IERC20(token).balanceOf(address(this)));

        emit LiquidityRemoved(
            msg.sender,
            token,
            WETH,
            amountToken,
            amountETH,
            liquidity
        );
    }


    /*
     * @param tokenA First token address
     * @param tokenB Second token address
     * @param liquidity Amount of LP tokens that should be transferred
     * @param amountAMin Minimum amount of tokenA that must be returned
     * @param amountBMin Minimum amount of tokenB that must be returned
     * @param to Account address that should receive tokens
     * @param deadline Timestamp, until when this transaction must be executed
     * @param approveMax Was max uint amount approved for transfer?
     * @param v Signature v part
     * @param r Signature r part
     * @param s Signature s part
     * @return amountA Amount of tokenA received
     * @return amountB Amount of tokenB received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
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
    ) external returns (uint256 amountA, uint256 amountB) {
        address pair = factory.getPair(tokenA, tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IBabyDogePair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }


    /*
     * @param token ERC20 token address
     * @param liquidity Amount of LP tokens that should be transferred
     * @param amountTokenMin Minimum amount of ERC20 token that must be returned
     * @param amountETHMin Minimum amount of BNB that must be returned
     * @param to Account address that should receive tokens/BNB
     * @param deadline Timestamp, until when this transaction must be executed
     * @param approveMax Was max uint amount approved for transfer?
     * @param v Signature v part
     * @param r Signature r part
     * @param s Signature s part
     * @return amountToken Amount of ERC20 token received
     * @return amountETH Amount of BNB received
     * @dev Liquidity can be removed only by address which added liquidity with this smart contract
     * @dev Liquidity amount must not be greater than amount, received with this smart contract
     */
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
    ) external returns (uint256 amountToken, uint256 amountETH) {
        address pair = factory.getPair(token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IBabyDogePair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            payable(to),
            deadline
        );
    }


    /*
     * @notice Approves token to router if required
     * @param token ERC20 token
     * @param minAmount Minimum amount of tokens to spend
     */
    function _approveIfRequired(
        address token,
        uint256 minAmount
    ) private {
        if (IERC20(token).allowance(address(this), address(router)) < minAmount) {
            IERC20(token).approve(address(router), type(uint256).max);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeRouter {
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

  function transactionFee(address _tokenIn, address _tokenOut, address _msgSender)
    external
    view
    returns (uint256);
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

  function getAmountsOut(uint256 amountIn, address[] calldata path)
  external
  view
  returns (uint256[] memory amounts);

  function getAmountsIn(uint256 amountOut, address[] calldata path)
  external
  view
  returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogePair {
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
  function burn(address to) external returns (uint256 amount0, uint256 amount1);

  function swap(
    uint256 amount0Out,
    uint256 amount1Out,
    address to,
    bytes calldata data
  ) external;

  function skim(address to) external;

  function sync() external;

  function initialize(
    address,
    address,
    address
  ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IBabyDogeFactory {
  function feeTo() external view returns (address);
  function feeToTreasury() external view returns (address);
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

  function setRouter(address) external;

  function setFeeTo(
    address _feeTo,
    address _feeToTreasury
  ) external;

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