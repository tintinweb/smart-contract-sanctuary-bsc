// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IRouter.sol";
import "./interfaces/IFactory.sol";
import "./interfaces/IPair.sol";
import "./interfaces/IFarm.sol";
import "./interfaces/ITreatToken.sol";
import "./interfaces/ITreatLiquidity.sol";
import "./SafeOwnable.sol";

contract TreatZAP is SafeOwnable{
    struct TokensAddresses {
        address tokenIn;
        address tokenB;
        address lpToken;
    }

    struct LpData {
        address tokenB;
        uint256 reserveTreat;
        uint256 reserveB;
        uint256 totalSupply;
    }

    struct PermitData {
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    // remaining tokens after adding liquidity won't be returned
    // to users account if amount is below this threshold
    uint256 private constant THRESHOLD = 1e9;

    ITreatToken public immutable treatToken;
    IWETH public immutable WBNB;

    event LpBought (
        address treatLiquidity,
        address router,
        address indexed account,
        address tokenIn,
        address lpToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 returnedAmount
    );

    event LpBoughtAndDeposited (
        address treatLiquidity,
        address router,
        address farm,
        address indexed account,
        address tokenIn,
        address lpToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 returnedAmount
    );

    event LpBoughtAndDepositedToStrategy (
        address treatLiquidity,
        address router,
        address farm,
        address strategy,
        address indexed account,
        address tokenIn,
        address lpToken,
        uint256 amountIn,
        uint256 amountOut,
        uint256 returnedAmount
    );

    event ERC20Recovered(address token, uint256 amount, address account);

    /*
     * @param _WBNB WBNB address
     * @param _treatToken Treat token address
     */
    constructor(
        IWETH _WBNB,
        ITreatToken _treatToken
    ) {
        require(address(_treatToken) != address(0) && address(_WBNB) != address(0));
        
        WBNB = _WBNB;
        treatToken = _treatToken;
    }

    // to receive BNB
    receive() payable external {}


    /*
     * @notice Swaps input token to LP token and returns remaining amount of tokens, swapped back to input token
     * @param treatLiquidity TreatLiquidity contract address, that will be used for adding liquidity
     * @param router Router address, which will be user for token swaps
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @return Received LP amount. Use for callStatic to estimate slippage
     * @dev Last element of `pathTreat` must be TreatToken. Last element of pathB must be tokenB
     * @dev If input token is tokenB, leave pathB empty
     * @dev First element of pathTreat and pathB must be input token (if not empty)
     * @dev Should be used for front end estimation with static call after input tokens approval
     */
    function buyLpTokens(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata pathTreat,
        address[] calldata pathB
    ) external payable returns(uint256) {
        (
            uint256 lpAmount,
            TokensAddresses memory tokens,
            uint256 returnedAmount
        ) = _buyLpTokens(
            treatLiquidity,
            router,
            amountIn,
            amountOutMin,
            pathTreat,
            pathB
        );

        emit LpBought (
            address(treatLiquidity),
            address(router),
            msg.sender,
            tokens.tokenIn,
            tokens.lpToken,
            amountIn,
            lpAmount,
            returnedAmount
        );

        return(lpAmount);
    }


    /*
     * @notice Swaps input token to LP token and deposits on behalf of msg.sender to specific farm
     * @param treatLiquidity TreatLiquidity contract address, that will be used for adding liquidity
     * @param router Router address, which will be user for token swaps
     * @param farm Farm address, where LP tokens should be deposited
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @param permitData Permit signature and deadline to spend lp tokens. Required only once, with uint256.max value
     * May be set as zero values if allowance of LP token (msg.sender -> address(this)) is greater than expected LP tokens amount
     * @return Received LP amount. Use for callStatic to estimate slippage
     * @dev Last element of `pathTreat` must be TreatToken. Last element of pathB must be tokenB
     * @dev If input token is tokenB, leave pathB empty
     * @dev First element of pathTreat and pathB must be input token (if not empty)
     * @dev Should be used for front end estimation with static call after input tokens approval
     * @dev If LP token doesn't support Permit approval, use `lpToken.approve(TreatZap, uint256.max)` instead
     */
    function buyLpTokensAndDepositOnBehalf(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        IFarm farm,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata pathTreat,
        address[] calldata pathB,
        PermitData calldata permitData
    ) external payable returns(uint256) {
        (
            uint256 lpAmount,
            TokensAddresses memory tokens,
            uint256 returnedAmount
        ) = _buyLpTokens(
            treatLiquidity,
            router,
            amountIn,
            amountOutMin,
            pathTreat,
            pathB
        );
        require(tokens.lpToken == farm.stakeToken(), "Not a stake token");

        _getLpTokensWithPermit(tokens.lpToken, lpAmount, permitData);
        _approveIfRequired(tokens.lpToken, address(farm), lpAmount);
        farm.depositOnBehalf(lpAmount, msg.sender);

        _emitLpBoughtAndDeposited(
            treatLiquidity,
            router,
            farm,
            amountIn,
            tokens.tokenIn,
            tokens.lpToken,
            lpAmount,
            returnedAmount
        );

        return(lpAmount);
    }


    /*
     * @notice Swaps input token to LP token and deposits on behalf of msg.sender to specific farm
     * @param treatLiquidity TreatLiquidity contract address, that will be used for adding liquidity
     * @param router Router address, which will be user for token swaps
     * @param farm Farm address, where LP tokens should be deposited
     * @param strategy Strategy address, to which LP tokens should be deposited to
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @param permitData Permit signature and deadline to spend lp tokens. Required only once, with uint256.max value
     * May be set as zero values if allowance of LP token (msg.sender -> address(this)) is greater than expected LP tokens amount
     * @return Received LP amount. Use for callStatic to estimate slippage
     * @dev Last element of `pathTreat` must be TreatToken. Last element of pathB must be tokenB
     * @dev If input token is tokenB, leave pathB empty
     * @dev First element of pathTreat and pathB must be input token (if not empty)
     * @dev Should be used for front end estimation with static call after input tokens approval
     * @dev If LP token doesn't support Permit approval, use `lpToken.approve(TreatZap, uint256.max)` instead
     */
    function buyLpTokensAndDepositToStrategyOnBehalf(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        IStrategyFarm farm,
        address strategy,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata pathTreat,
        address[] calldata pathB,
        PermitData calldata permitData
    ) public payable returns(uint256) {
        (
            uint256 lpAmount,
            TokensAddresses memory tokens,
            uint256 returnedAmount
        ) = _buyLpTokens(
            treatLiquidity,
            router,
            amountIn,
            amountOutMin,
            pathTreat,
            pathB
        );
        require(tokens.lpToken == IStrategy(strategy).stakeToken(), "Not a stake token");

        _getLpTokensWithPermit(tokens.lpToken, lpAmount, permitData);
        _approveIfRequired(tokens.lpToken, address(farm), lpAmount);
        farm.depositOnBehalf(strategy, msg.sender, lpAmount);

        _emitLpBoughtAndDepositedToStrategy(
            treatLiquidity,
            router,
            farm,
            strategy,
            amountIn,
            tokens.tokenIn,
            tokens.lpToken,
            lpAmount,
            returnedAmount
        );

        return(lpAmount);
    }


    /*
     * @notice Estimates amount of Lp tokens based on input amount
     * @param treatLiquidity TreatLiquidity contract address, that will be used for adding liquidity
     * @param router Router address, which will be user for token swaps
     * @param amountIn Amount of input tokens
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @dev Should be used for front end estimation before input tokens approval
     * @dev Should NOT be used for front end estimation AFTER input tokens approval. Use `callStatic` instead
     */
    function estimateAmountOfLpTokens(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        uint256 amountIn,
        address[] calldata pathTreat,
        address[] calldata pathB
    ) public view returns(uint256){
        LpData memory lpData = _getLpData(treatLiquidity.factory(), pathTreat, pathB);
        if (lpData.totalSupply == 0) {
            return 0;
        }

        uint256 amountTreat = _getAmountOut(router, amountIn/2, pathTreat);
        uint256 amountB = _getAmountOut(router, amountIn/2, pathB);

        (uint256 liquidity, uint256 amountTreatAdded, uint256 amountBAdded) = _estimateLpAmount(
            amountTreat,
            amountB,
            lpData
        );

        if (amountTreat > amountTreatAdded) {
            uint256 remaining = amountTreat - amountTreatAdded;

            (uint256 leftoverLiquidity,,) = _estimateLpAmount(
                remaining/2,
                remaining/2 * amountBAdded / amountTreatAdded,
                lpData
            );
            liquidity += leftoverLiquidity;
        } else if (amountB > amountBAdded) {
            uint256 remaining = amountB - amountBAdded;

            (uint256 leftoverLiquidity,,) = _estimateLpAmount(
                remaining/2 * amountTreatAdded / amountBAdded,
                remaining/2,
                lpData
            );
            liquidity += leftoverLiquidity;
        }

        return liquidity;
    }


    /*
     * @notice Recovers stuck tokens. Use in case of emergency
     * @param token ERC20 token address
     * @param amount Amount of tokens to recover
     * @param account Tokens receiver
     * @dev Only Owner can call this function
     */
    function recoverERC20(
        IERC20 token,
        uint256 amount,
        address account
    ) external onlyOwner {
        token.transfer(account, amount);

        emit ERC20Recovered(address(token), amount, account);
    }


    /*
     * @notice Swaps input token to LP token. Internal function
     * @param treatLiquidity TreatLiquidity contract address, that will be used for adding liquidity
     * @param router Router address, which will be user for token swaps
     * @param amountIn Amount of input tokens
     * @param amountOutMin Minimum amount of LP tokens to receive
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @return lpAmount Amount of LP tokens received
     * @return tokens Addresses of input token, tokenB, lpToken and WBNB
     * @return returnedAmount amount of input tokens returned to user
     */
    function _buyLpTokens(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata pathTreat,
        address[] calldata pathB
    ) internal returns (
        uint256 lpAmount,
        TokensAddresses memory tokens,
        uint256 returnedAmount
    ) {
        require(msg.sender == tx.origin, "Smart contracts not allowed");
        tokens = _checkBeforeGettingLp(
            treatLiquidity.factory(),
            amountIn,
            pathTreat,
            pathB
        );

        (
            uint256 amountTreatDesired,
            uint256 amountBDesired,
            uint256 initialTreatBalance
        ) = _swapInputToTokens(
            router,
            pathTreat,
            pathB
        );

        uint256 _lpAmount = _addLiquidity(
            treatLiquidity,
            tokens,
            amountTreatDesired,
            amountBDesired
        );
        require(_lpAmount >= amountOutMin, "Below amountOutMin");

        // return remaining tokens
        returnedAmount = _returnTokens(
            router,
            tokens,
            pathTreat,
            pathB,
            initialTreatBalance
        );

        return (_lpAmount, tokens, returnedAmount);
    }


    /*
     * @notice Transfers input token to the contract and checks if paths are correct
     * @param factory LP token origin factory address
     * @param amountIn Amount of input tokens
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @return Addresses of input token, tokenB, lpToken and WBNB
     */
    function _checkBeforeGettingLp(
        IFactory factory,
        uint256 amountIn,
        address[] calldata pathTreat,
        address[] calldata pathB
    ) private returns(TokensAddresses memory) {
        address tokenIn = pathTreat[0];
        require(tokenIn != address(treatToken), "Can't ZAP Treat token");

        if (msg.value > 0) {
            require(
                (tokenIn == address(WBNB)),
                "Input token != WBNB"
            );
            require(amountIn == msg.value, "Invalid msg.value");
            WBNB.deposit{value: msg.value}();
        } else {
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        }

        require(
            (pathTreat.length >= 2)
            && (pathB.length == 0 || pathB.length >= 2),
            "Invalid path"
        );
        require(
            pathB.length == 0 || pathTreat[0] == pathB[0],
            "Invalid input token"
        );
        address tokenB = pathB.length > 0 ? pathB[pathB.length - 1] : pathTreat[0];
        require(address(treatToken) != tokenB, "Same tokens");
        require(pathTreat[pathTreat.length - 1] == address(treatToken), "Wrong LP");

        address lpAddress = factory.getPair(address(treatToken), tokenB);
        require(lpAddress != address(0), "Pair doesn't exist");
        {
            (uint112 reserve0, uint112 reserve1,) = IPair(lpAddress).getReserves();
            require(reserve0 > 0 && reserve1 > 0, "Empty reserves");
            require(treatToken.isExchangeAddress(lpAddress), "Not approved pair");
        }

        return TokensAddresses({
            tokenIn: tokenIn,
            tokenB: tokenB,
            lpToken: lpAddress
        });
    }


    /*
     * @notice Adds liquidity, then balances remaining token to liquidity again
     * @param treatLiquidity TreatLiquidity contract address, that will be used for adding liquidity
     * @param tokens Addresses of input token, tokenB, lpToken and WBNB
     * @param amountTreatDesired Amount of TreatToken to add to liquidity
     * @param amountBDesired Amount of tokenB to add to liquidity
     * @return liquidity Amount of LP tokens received
     */
    function _addLiquidity(
        ITreatLiquidity treatLiquidity,
        TokensAddresses memory tokens,
        uint256 amountTreatDesired,
        uint256 amountBDesired
    ) private returns(uint256 liquidity) {
        uint256 initialLiquidity = IERC20(tokens.lpToken).balanceOf(msg.sender);
        uint256 initialTreatBalance = treatToken.balanceOf(address(this)) - amountTreatDesired;
        _approveIfRequired(address(treatToken), address(treatLiquidity), amountTreatDesired);
        _approveIfRequired(tokens.tokenB, address(treatLiquidity), amountBDesired);

        (uint256 amountA, uint256 amountB,) = treatLiquidity.addLiquidityOnBehalf(
            msg.sender,
            tokens.tokenB,
            amountTreatDesired,
            amountBDesired,
            0,
            0,
            block.timestamp + 1200
        );

        IRouter liquidityRouter = IRouter(treatLiquidity.router());
        if (amountTreatDesired > amountA) {
            uint256 reserveTreat = treatToken.balanceOf(tokens.lpToken);
            uint256 remaining = amountTreatDesired - amountA;
            uint256 amountIn = _getPerfectAmountIn(remaining, reserveTreat);
            amountTreatDesired = remaining - amountIn;

            address[] memory path = new address[](2);
            path[0] = address(treatToken);
            path[1] = tokens.tokenB;
            _approveIfRequired(address(treatToken), address(liquidityRouter), amountIn);
            liquidityRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
            amountBDesired = IERC20(tokens.tokenB).balanceOf(address(this));
        } else if (amountBDesired > amountB) {
            uint256 reserveB = IERC20(tokens.tokenB).balanceOf(tokens.lpToken);
            uint256 remaining = amountBDesired - amountB;
            uint256 amountIn = _getPerfectAmountIn(remaining, reserveB);
            amountBDesired = remaining - amountIn;

            address[] memory path = new address[](2);
            path[0] = tokens.tokenB;
            path[1] = address(treatToken);
            _approveIfRequired(tokens.tokenB, address(liquidityRouter), amountIn);
            liquidityRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountIn,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
            amountTreatDesired = treatToken.balanceOf(address(this)) - initialTreatBalance;
        }

        // add to liquidity remaining tokens after splitting amounts in perfect ratio
        treatLiquidity.addLiquidityOnBehalf(
            msg.sender,
            tokens.tokenB,
            amountTreatDesired,
            amountBDesired,
            0,
            0,
            block.timestamp + 1200
        );

        liquidity = IERC20(tokens.lpToken).balanceOf(msg.sender) - initialLiquidity;
    }


    /*
     * @notice Swaps input token to LP token
     * @param router Router address
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @return amountTreat - Received amount of TreatToken
     * @return amountB - Received amount of tokenB
     * @dev Internal function without checks
     */
    function _swapInputToTokens(
        IRouter router,
        address[] calldata pathTreat,
        address[] calldata pathB
    ) internal returns (uint256 amountTreat, uint256 amountB, uint256 initialTreatBalance) {
        uint256 amountIn = IERC20(pathTreat[0]).balanceOf(address(this));
        amountTreat = amountIn / 2;
        amountB = amountIn / 2;

        // Swapping to tokenB first will decrease probability of excessive TreatTokens
        // We want to avoid returning TreatTokens, since transaction will more likely cost more gas than for tokenB
        if (pathB.length > 0) {
            _approveIfRequired(pathB[0], address(router), amountB);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                amountB,
                0,
                pathB,
                address(this),
                block.timestamp + 1200
            );

            amountB = IERC20(pathB[pathB.length - 1]).balanceOf(address(this));
        }

        // swapping to TreatToken
        initialTreatBalance = treatToken.balanceOf(address(this));
        _approveIfRequired(pathTreat[0], address(router), amountTreat);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            amountTreat,
            0,
            pathTreat,
            address(this),
            block.timestamp + 1200
        );

        // subtracting initial balance to avoid vesting attack
        amountTreat = treatToken.balanceOf(address(this)) - initialTreatBalance;
    }


    /*
     * @notice Transfers remaining tokens back to user. Converts them back to input token
     * @param router Router address
     * @param tokens Addresses of input token, tokenB, lpToken and WBNB
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @return toReturn Returned amount of input tokens
     * @dev Transfers tokens only above THRESHOLD value to save gas
     */
    function _returnTokens(
        IRouter router,
        TokensAddresses memory tokens,
        address[] calldata pathTreat,
        address[] calldata pathB,
        uint256 initialTreatBalance
    ) private returns(uint256 toReturn) {
        // vesting manipulations protection
        uint256 remainingAmountTreat = treatToken.balanceOf(address(this)) - initialTreatBalance;
        uint256 remainingAmountB = IERC20(tokens.tokenB).balanceOf(address(this));

        if (remainingAmountTreat > THRESHOLD) {
            address[] memory path = _reversePath(pathTreat);
            _approveIfRequired(address(treatToken), address(router), remainingAmountTreat);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                remainingAmountTreat,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
        }

        if (remainingAmountB > THRESHOLD && pathB.length > 0) {
            address[] memory path = _reversePath(pathB);
            _approveIfRequired(path[0], address(router), remainingAmountB);
            router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
                remainingAmountB,
                0,
                path,
                address(this),
                block.timestamp + 1200
            );
        }

        toReturn = IERC20(tokens.tokenIn).balanceOf(address(this));
        if (toReturn > THRESHOLD) {
            if (msg.value > 0) {
                WBNB.withdraw(toReturn);
                (bool success, ) = payable(msg.sender).call{value: toReturn}("");
                require(success, "Can't return BNB");
            } else {
                IERC20(tokens.tokenIn).transfer(msg.sender, toReturn);
            }
        } else {
            toReturn = 0;
        }
    }


    /*
     * @notice Reverses address array
     * @param path Input path
     * @return Reversed path
     */
    function _reversePath(
        address[] calldata path
    ) private pure returns(address[] memory) {
        uint256 arrayLength = path.length;
        address[] memory reversedPath = new address[](arrayLength);

        for (uint i = 0; i < arrayLength; i++) {
            reversedPath[i] = path[arrayLength - 1 - i];
        }

        return reversedPath;
    }


    /*
     * @notice Approves token to spender if required
     * @param token ERC20 token
     * @param spender Spender contract address
     * @param minAmount Minimum amount of tokens to spend
     */
    function _approveIfRequired(
        address token,
        address spender,
        uint256 minAmount
    ) private {
        if (IERC20(token).allowance(address(this), spender) < minAmount) {
            IERC20(token).approve(spender, type(uint256).max);
        }
    }


    /*
     * @notice Transfers LP tokens from msg.sender to this contract
     * @param lpToken LP token address
     * @param amount Amount of tokens to fe transferred
     * @param permitData Permit signature and deadline to spend lp tokens. Required only once, with uint256.max value
     * May be set as zero values if allowance of LP token (msg.sender -> address(this)) is greater than expected LP tokens amount
     * @dev Since TreatLiquidity sends LP tokens to new owner, we must get them back in order to deposit
     */
    function _getLpTokensWithPermit(
        address lpToken,
        uint256 amount,
        PermitData calldata permit
    ) private {
        if (IERC20(lpToken).allowance(msg.sender, address(this)) < amount) {
            IPair(lpToken).permit(
                msg.sender,
                address(this),
                type(uint256).max,
                permit.deadline,
                permit.v,
                permit.r,
                permit.s
            );
        }

        IERC20(lpToken).transferFrom(msg.sender, address(this), amount);
    }


    /*
     * @notice Calculates amountIn in such way, so that remaining tokens would be split into
     * such amounts, that most of them would be added to liquidity
     * @param remaining Remaining amount of tokenA to be split between tokenA and tokenB and added to liquidity
     * @param reserveIn Current reserve of tokenA
     * @return Amount of tokenA to be swapped to tokenB in order to achieve perfect liquidity ratio
     * @dev Used for adding to liquidity remaining tokens instead of returning them to the user
     */
    function _getPerfectAmountIn(
        uint256 remaining,
        uint256 reserveIn
    ) private pure returns(uint256) {
        return Math.sqrt((3988009 * reserveIn + 3988000 * remaining)
            / 3976036 * reserveIn)
            - 1997 * reserveIn / 1994;
    }

    /*
     * @notice Emits LpBoughtAndDepositedToStrategy event
     * @dev Workaround for stack too deep error
     */
    function _emitLpBoughtAndDepositedToStrategy(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        IStrategyFarm farm,
        address strategy,
        uint256 amountIn,
        address tokenIn,
        address lpToken,
        uint256 lpAmount,
        uint256 returnedAmount
    ) private {
        emit LpBoughtAndDepositedToStrategy (
            address(treatLiquidity),
            address(router),
            address(farm),
            strategy,
            msg.sender,
            tokenIn,
            lpToken,
            amountIn,
            lpAmount,
            returnedAmount
        );
    }

    /*
     * @notice Emits LpBoughtAndDeposited event
     * @dev Workaround for stack too deep error
     */
    function _emitLpBoughtAndDeposited(
        ITreatLiquidity treatLiquidity,
        IRouter router,
        IFarm farm,
        uint256 amountIn,
        address tokenIn,
        address lpToken,
        uint256 lpAmount,
        uint256 returnedAmount
    ) private {
        emit LpBoughtAndDeposited (
            address(treatLiquidity),
            address(router),
            address(farm),
            msg.sender,
            tokenIn,
            lpToken,
            amountIn,
            lpAmount,
            returnedAmount
        );
    }


    /****************************** Estimation functions helpers ******************************/
    /*
     * @notice Gets reserves and total supply of LP token
     * @param factory Factory address
     * @param pathTreat Address path to swap to TreatToken
     * @param pathB Address path to swap to tokenB
     * @return lpData Reserves and total supply of LP token
     * @dev Internal function for estimateAmountOfLpTokens
     */
    function _getLpData(
        IFactory factory,
        address[] calldata pathTreat,
        address[] calldata pathB
    ) private view returns(LpData memory lpData) {
        address tokenB = pathB.length > 0 ? pathB[pathB.length - 1] : pathTreat[0];
        address pairAddress = factory.getPair(address(treatToken), tokenB);
        if (pairAddress == address(0)) {
            return lpData;
        }

        lpData.tokenB = tokenB;
        lpData.reserveTreat = treatToken.balanceOf(pairAddress);
        lpData.reserveB = IERC20(tokenB).balanceOf(pairAddress);
        lpData.totalSupply = IPair(pairAddress).totalSupply();

        return lpData;
    }


    /*
     * @notice Calculate expected amount out of swap
     * @param router Router address
     * @param amountIn Amount ot tokens to pe spent
     * @param path Address path to swap to token
     * @return amountOut Expected amount of tokenOut
     * @dev Internal function for estimateAmountOfLpTokens
     */
    function _getAmountOut(
        IRouter router,
        uint256 amountIn,
        address[] calldata path
    ) private view returns(uint256 amountOut) {
        if (path.length > 0) {
            (uint256[] memory amounts) = router.getAmountsOut(amountIn, path);
            amountOut = amounts[amounts.length - 1];
        } else {
            amountOut = amountIn;
        }
    }


    /*
     * @notice Estimates amount of minted LP tokens based on input amounts
     * @param amountADesired Amount of tokens A to add to liquidity
     * @param amountBDesired Amount of tokens B to add to liquidity
     * @param lpData Reserves and total supply of LP token
     * @return liquidity Amount of LP tokens expected to receive in return
     * @dev Internal function for estimateAmountOfLpTokens
     */
    function _estimateLpAmount(
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        LpData memory lpData
    ) private pure returns(uint256 liquidity, uint256 amountTreat, uint256 amountB) {
        uint256 amountBOptimal = amountTreatDesired * lpData.reserveB / lpData.reserveTreat;

        if (amountBOptimal <= amountBDesired) {
            (amountTreat, amountB) = (amountTreatDesired, amountBOptimal);
        } else {
            uint256 amountAOptimal = amountBDesired * lpData.reserveTreat / lpData.reserveB;
            (amountTreat, amountB) = (amountAOptimal, amountBDesired);
        }

        liquidity = Math.min(
            amountTreat * lpData.totalSupply / lpData.reserveTreat,
            amountB * lpData.totalSupply / lpData.reserveB
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership} and {updateOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract SafeOwnable is Context {
    address private _owner;
    address private _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipUpdated(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _owner = _msgSender();
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
        _owner = address(0);
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     */
    function updateOwnership() external {
        _updateOwnership();
    }

    /**
     * @dev Allows newOwner to claim ownership
     * @param newOwner Address that should become a new owner
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _newOwner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to msg.sender
     * Internal function without access restriction.
     */
    function _updateOwnership() private {
        address oldOwner = _owner;
        address newOwner = _newOwner;
        require(msg.sender == newOwner, "Not a new owner");
        require(oldOwner != newOwner, "Already updated");
        _owner = newOwner;
        emit OwnershipUpdated(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IFactory {
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

//SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity ^0.8.0;

interface IPair {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IFarm {
    function depositOnBehalf(uint256 amount, address account) external;
    function stakeToken() external returns(address);
}
interface IStrategyFarm {
    function depositOnBehalf(
        address strategy,
        address account,
        uint256 amount
    ) external;
}

interface IStrategy {
    function stakeToken() external returns(address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITreatToken is IERC20, IERC20Metadata {
    function getPastVotes(address account, uint256 blockNumber)
        external
        view
        returns (uint256);

    function executeStaking(
        address account,
        uint256 transferAmount
    ) external returns (
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    );

    function executeWithdrawal(
        address account,
        uint256 transferAmount,
        uint256 lockedAmount,
        uint256 remainingVestingProgress
    ) external;

    function viewNotVestedTokens(address recipient) external view
        returns(uint256 locked, uint256 remainingVestingTime);

    function isExchangeAddress(address pair) external view returns(bool);
}

//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IRouter {
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
pragma solidity ^0.8.0;

import "./IFactory.sol";

interface ITreatLiquidity {
    function addLiquidity(
        address tokenB,
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETH(
        uint256 amountTreatDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function addLiquidityOnBehalf(
        address account,
        address tokenB,
        uint256 amountTreatDesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

    function addLiquidityETHOnBehalf(
        address account,
        uint256 amountTreatDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function factory() external view returns(IFactory);
    function router() external view returns(address);
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}