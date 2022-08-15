//SPDX-License-Identifier: Unlicense
pragma solidity >=0.6.6;

// import "hardhat/console.sol";

// Uniswap interface and library imports
import "UniswapV2Library.sol";
import "SafeERC20.sol";
import "IUniswapV2Router01.sol";
import "IUniswapV2Router02.sol";
import "IUniswapV2Pair.sol";
import "IUniswapV2Factory.sol";
import "IERC20.sol";
// import "./libraries/UniswapV2Library.sol";
// import "./libraries/SafeERC20.sol";
// import "./interfaces/IUniswapV2Router01.sol";
// import "./interfaces/IUniswapV2Router02.sol";
// import "./interfaces/IUniswapV2Pair.sol";
// import "./interfaces/IUniswapV2Factory.sol";
// import "./interfaces/IERC20.sol";

contract PancakeFlashSwap {
    using SafeERC20 for IERC20;

    address private trade1Token;
    address private trade2Token;
    address private trade3Token;

    // Factory and Routing Addresses
    address private constant PANCAKE_FACTORY =
        0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address private constant PANCAKE_ROUTER =
        0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Token Addresses
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant ETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;

    // Trade Variables
    uint256 private deadline = block.timestamp + 1 days;
    uint256 private constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    // FUND SMART CONTRACT
    // Provides a function to allow contract to be funded
    function fundFlashSwapContract(
        address _owner,
        address _token,
        uint256 _amount
    ) public {
        IERC20(_token).transferFrom(_owner, address(this), _amount);
    }

    // GET CONTRACT BALANCE
    // Allows public view of balance for contract
    function getBalanceOfToken(address _address) public view returns (uint256) {
        return IERC20(_address).balanceOf(address(this));
    }

    // PLACE A TRADE
    // Executed placing a trade
    function placeTrade(
        address _fromToken,
        address _toToken,
        uint256 _amountIn
    ) private returns (uint256) {
        // Approve Token to allow to trade it
        IERC20(_fromToken).safeApprove(address(PANCAKE_ROUTER), _amountIn);
        IERC20(_fromToken).safeDecreaseAllowance(address(PANCAKE_ROUTER), 0);
        // uint256 allow = IERC20(_fromToken).allowance(
        //     _fromToken,
        //     address(PANCAKE_ROUTER)
        // );
        // console.log("Allowance:", allow);
        // IERC20(_toToken).approve(PANCAKE_ROUTER, MAX_INT);
        // Get Pair to double check if pool exists
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(
            _fromToken,
            _toToken
        );
        // Return error if combination does not exist
        require(pair != address(0), "Pool does not exist");

        // console.log("pair", pair);
        // console.log("from", _fromToken);
        // console.log("to", _toToken);

        // Calculate Amount Out
        address[] memory path = new address[](2);
        path[0] = _fromToken;
        path[1] = _toToken;

        uint256 amountRequired = IUniswapV2Router01(PANCAKE_ROUTER)
            .getAmountsOut(_amountIn, path)[1];

        // Perform Arbitrage - Swap for another token
        uint256 amountReceived = IUniswapV2Router01(PANCAKE_ROUTER)
            .swapExactTokensForTokens(
                _amountIn, // amountIn
                amountRequired, // amountOutMin
                path, // path
                address(this), // address to
                deadline // deadline
            )[1];

        require(amountReceived > 0, "Aborted Tx: Trade returned zero");

        return amountReceived;
    }

    // CHECK PROFITABILITY
    // Checks whether > output > input
    function checkProfitability(uint256 _input, uint256 _output)
        private
        returns (bool)
    {
        return _output > _input;
    }

    function calculateTrade(
        address _base,
        address _quote,
        uint256 _amount
    ) internal view returns (uint256) {
        // Calculate Amount Out
        address[] memory path = new address[](2);
        path[0] = _base;
        path[1] = _quote;

        uint256[] memory amountOut = IUniswapV2Router01(PANCAKE_ROUTER)
            .getAmountsOut(_amount, path); //[1];

        return amountOut[amountOut.length - 1];
    }

    function calculateArbitrage(
        address _token1,
        address _token2,
        address _token3,
        uint256 amount
    ) external view returns (uint256) {
        // Calculate Trade 1
        uint256 amountTrade1 = calculateTrade(_token1, _token2, amount);
        // console.log(amountTrade1);
        assert(amountTrade1 > 0);
        // Calculate Trade 2
        uint256 amountTrade2 = calculateTrade(_token2, _token3, amountTrade1);
        // console.log(amountTrade2);
        assert(amountTrade2 > 0);
        // Calculate Trade 3
        uint256 amountTrade3 = calculateTrade(_token3, _token1, amountTrade2);
        // console.log(amountTrade3);
        assert(amountTrade3 > 0);

        return amountTrade3;
    }

    // INITIATE ARBITRAGE
    // Begins receiving loan to engage performing arbitrage trades
    function startArbitrage(
        address _trade1Token,
        address _trade2Token,
        address _trade3Token,
        uint256 _amount
    ) external {
        // IERC20(_trade1Token).safeApprove(address(PANCAKE_ROUTER), MAX_INT);
        // IERC20(_trade2Token).safeApprove(address(PANCAKE_ROUTER), MAX_INT);
        // IERC20(_trade3Token).safeApprove(address(PANCAKE_ROUTER), MAX_INT);
        // IERC20(USDT).safeApprove(address(PANCAKE_ROUTER), MAX_INT);

        // Get the Factory Pair address for combined tokens
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(
            _trade1Token,
            ETH
        );

        // Return error if combination does not exist
        require(pair != address(0), "Pool does not exist");

        // Figure out which token (0 or 1) has the amount and assign
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();
        uint256 amount0Out = _trade1Token == token0 ? _amount : 0;
        uint256 amount1Out = _trade1Token == token1 ? _amount : 0;

        // Passing data as bytes so that the 'swap' function knows it is a flashloan
        bytes memory data = abi.encode(_trade1Token, _amount, msg.sender);

        trade1Token = _trade1Token;
        trade2Token = _trade2Token;
        trade3Token = _trade3Token;
        // Execute the initial swap to get the loan
        IUniswapV2Pair(pair).swap(amount0Out, amount1Out, address(this), data);
    }

    function pancakeCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        // Ensure this request came from the contract
        address token0 = IUniswapV2Pair(msg.sender).token0();
        address token1 = IUniswapV2Pair(msg.sender).token1();
        address pair = IUniswapV2Factory(PANCAKE_FACTORY).getPair(
            token0,
            token1
        );
        require(msg.sender == pair, "The sender needs to match the pair");
        require(_sender == address(this), "Sender should match this contract");

        // Decode data for calculating the repayment
        (address tokenBorrow, uint256 amount, address myAddress) = abi.decode(
            _data,
            (address, uint256, address)
        );

        // Calculate the amount to repay at the end
        uint256 fee = ((amount * 3) / 997) + 1;
        uint256 amountToRepay = amount + fee;
        // console.log('FlashLoanAmount to repay: ', amountToRepay);

        // DO ARBITRAGE
        // Assign loan amount
        uint256 loanAmount = _amount0 > 0 ? _amount0 : _amount1;

        // Place Trades
        uint256 trade1AcquiredCoin = placeTrade(
            trade1Token,
            trade2Token,
            loanAmount
        );
        // console.log("Trade1Outcome:", trade1AcquiredCoin);
        uint256 trade2AcquiredCoin = placeTrade(
            trade2Token,
            trade3Token,
            trade1AcquiredCoin
        );
        // console.log("Trade2Outcome:", trade2AcquiredCoin);
        uint256 trade3AcquiredCoin = placeTrade(
            trade3Token,
            trade1Token,
            trade2AcquiredCoin
        );
        // console.log("Trade3Outcome:", trade3AcquiredCoin);

        // Check Profitability
        bool profCheck = checkProfitability(amountToRepay, trade3AcquiredCoin);
        require(profCheck, "Arbitrage not profitable");
        // console.log('profitcheck done');

        // Pay Myself
        // IERC20 otherToken = IERC20(trade1Token);
        // otherToken.transfer(myAddress, trade3AcquiredCoin - amountToRepay);
        // console.log('pay myself done');


        // Pay Loan Back
        IERC20(tokenBorrow).transfer(pair, amountToRepay);
        // console.log('pay loan back done');

    }
}