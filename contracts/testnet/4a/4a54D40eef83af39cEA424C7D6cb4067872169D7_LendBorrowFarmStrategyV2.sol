// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;
pragma abicoder v2;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./../utils/LogicUpgradeable.sol";
import "./../Interfaces/ILogicContract.sol";
import "./../Interfaces/IXToken.sol";
import "./../Interfaces/ICompoundVenus.sol";
import "./../Interfaces/ISwap.sol";
import "./../Interfaces/IMultiLogicProxy.sol";
import "./../Interfaces/ILendBorrowFarmingPair.sol";

contract LendBorrowFarmStrategyV2 is LogicUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address private blid;
    address private comptroller;
    address private logic;
    address private farmingPair;
    address private multiLogicProxy;
    address private rewardsSwapRouter;
    address private rewardsToken;
    address[] private pathToSwapRewardsToBNB;
    address[] private pathToSwapBNBToBLID;

    mapping(address => address) private vTokens;
    mapping(uint256 => address) lendingTokens;
    uint256 lendingTokensCount;

    event SetBLID(address _blid);
    event SetMultiLogicProxy(address multiLogicProxy);
    event AddLendingToken(address token);
    event ReleaseToken(address token, uint256 amount);
    event Borrow(address, uint256);
    event Deposit(address, uint256);
    event Build(uint256);
    event Destroy(uint256);
    event DestroyAll();
    event ClaimRewards(uint256 amount);

    function __LendBorrowFarmStrategy_init(
        address _comptroller,
        address _rewardsSwapRouter,
        address _rewardsToken,
        address _logic,
        address _farmingPair
    ) public initializer {
        LogicUpgradeable.initialize();
        comptroller = _comptroller;
        rewardsSwapRouter = _rewardsSwapRouter;
        rewardsToken = _rewardsToken;
        logic = _logic;
        farmingPair = _farmingPair;
    }

    receive() external payable {}

    fallback() external payable {}

    modifier onlyMultiLogicProxy() {
        require(msg.sender == multiLogicProxy, "F1");
        _;
    }

    /**
     * @notice Set blid in contract
     * @param blid_ Address of BLID
     */
    function setBLID(address blid_) external onlyOwner {
        blid = blid_;
        emit SetBLID(blid_);
    }

    /**
     * @notice Set MultiLogicProxy, you can call the function once
     * @param _multiLogicProxy Address of Storage Contract
     */
    function setMultiLogicProxy(address _multiLogicProxy) external onlyOwner {
        require(multiLogicProxy == address(0), "F5");
        multiLogicProxy = _multiLogicProxy;

        emit SetMultiLogicProxy(_multiLogicProxy);
    }

    /**
     * @notice Set pathToSwapRewardsToBNB
     * @param path path to rewards to BNB
     */
    function setPathToSwapRewardsToBNB(address[] calldata path)
        external
        onlyOwner
    {
        uint256 length = path.length;
        require(length >= 2, "F16");
        require(path[0] == rewardsToken, "F17");

        pathToSwapRewardsToBNB = new address[](length);
        for (uint256 i = 0; i < length; ) {
            pathToSwapRewardsToBNB[i] = path[i];

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Set pathToSwapBNBToBLID
     * @param path path to BNB to BLID
     */
    function setPathToSwapBNBToBLID(address[] calldata path)
        external
        onlyOwner
    {
        uint256 length = path.length;
        require(length >= 2, "F16");
        require(path[length - 1] == blid, "F18");

        pathToSwapBNBToBLID = new address[](length);
        for (uint256 i = 0; i < length; ) {
            pathToSwapBNBToBLID[i] = path[i];

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Add vToken in Contract and approve token
     * this token will be used for Lending
     * Approve token for storage, venus, pancakeswap/apeswap/biswap router,
     * and pancakeswap/apeswap/biswap master(Main Staking contract)
     * Approve rewardsToken for swap
     * @param token Address of underlying token
     * @param vToken Address of vToken
     */
    function addLendingToken(address token, address vToken) public onlyOwner {
        require(vTokens[token] == address(0), "F6");

        address _logic = logic;
        vTokens[token] = vToken;

        // Add token/oToken to Logic
        ILogicContract(_logic).addXTokens(token, vToken, 0);

        // Entermarkets with token/vtoken
        address[] memory tokens = new address[](1);
        tokens[0] = vToken;
        ILogicContract(_logic).enterMarkets(tokens, 0);

        // Add LendingTokens
        lendingTokens[lendingTokensCount++] = vToken;

        emit AddLendingToken(token);
    }

    /**
     * @notice Take all available token from storage and mint
     */
    function lendToken() external onlyOwnerAndAdmin {
        address _logic = logic;

        // Get all tokens in storage
        address[] memory tokens = IMultiLogicProxy(multiLogicProxy)
            .getUsedTokensStorage();
        uint256 length = tokens.length;

        // For each token
        for (uint256 i = 0; i < length; ) {
            address token = tokens[i];

            // Get available amount
            uint256 amount = IMultiLogicProxy(multiLogicProxy)
                .getTokenAvailable(token, _logic);

            if (amount > 0) {
                // Check token has been inited
                require(vTokens[token] != address(0), "F2");

                // Take token from storage
                ILogicContract(_logic).takeTokenFromStorage(amount, token);

                // Mint
                ILogicContract(_logic).mint(vTokens[token], amount);
            }

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Build Strategy
     * @param usdAmount Amount of USD to borrow : decimal = 18
     */
    function build(uint256 usdAmount) external onlyOwnerAndAdmin {
        // Get Farming Pairs, Percentages
        FarmingPair[] memory reserves = ILendBorrowFarmingPair(farmingPair)
            .getFarmingPairs();

        // Check percentage and farmingPair are matched
        ILendBorrowFarmingPair(farmingPair).checkPercentages();

        address _logic = logic;
        uint256 index;

        // Array of token borrow
        address[] memory arrBorrowToken = new address[](reserves.length * 2);
        uint256[] memory arrBorrowAmount = new uint256[](reserves.length * 2);

        // Array of token amount for addLiquidity
        uint256[] memory arrToken0Amount = new uint256[](reserves.length);
        uint256[] memory arrToken1Amount = new uint256[](reserves.length);
        uint256 pos;

        // For each pair, calculate build, borrow amount
        for (index = 0; index < reserves.length; ) {
            FarmingPair memory reserve = reserves[index];

            // Calculate the build, borrow amount
            uint256 token0BorrowAmount;
            uint256 token1BorrowAmount;
            (
                arrToken0Amount[index],
                arrToken1Amount[index],
                token0BorrowAmount,
                token1BorrowAmount
            ) = _calcBorrowAmount(
                reserve,
                (usdAmount * reserve.percentage) / 10000
            );

            // Store borrow token and borrow amount in array
            uint256 i;
            for (i = 0; i < pos + 1; i++) {
                if (arrBorrowToken[i] == reserve.xTokenA) {
                    arrBorrowAmount[i] += token0BorrowAmount;
                    break;
                }
            }
            if (i == pos + 1) {
                arrBorrowToken[pos] = reserve.xTokenA;
                arrBorrowAmount[pos] = token0BorrowAmount;
                pos++;
            }

            for (i = 0; i < pos + 1; i++) {
                if (arrBorrowToken[i] == reserve.xTokenB) {
                    arrBorrowAmount[i] += token1BorrowAmount;
                    break;
                }
            }
            if (i == pos + 1) {
                arrBorrowToken[pos] = reserve.xTokenB;
                arrBorrowAmount[pos] = token1BorrowAmount;
                pos++;
            }

            unchecked {
                ++index;
            }
        }

        // Borrow Tokens
        for (index = 0; index < pos; index++) {
            if (arrBorrowAmount[index] > 0) {
                uint256 borrowAmount = ILogicContract(_logic).borrow(
                    arrBorrowToken[index],
                    arrBorrowAmount[index],
                    0
                );

                require(borrowAmount == 0, "F13"); // Borrow should be successed
            }

            emit Borrow(arrBorrowToken[index], arrBorrowAmount[index]);
        }

        // Add Liquidity, Deposit
        for (index = 0; index < reserves.length; ) {
            FarmingPair memory reserve = reserves[index];

            // Add Liquidity
            uint256 deadline = block.timestamp + 1 hours;
            uint256 liquidity;
            if (reserve.tokenB == address(0)) {
                // If tokenB is BNB
                (, , liquidity) = ILogicContract(_logic).addLiquidityETH(
                    reserve.swap,
                    reserve.tokenA,
                    arrToken0Amount[index],
                    arrToken1Amount[index],
                    0,
                    0,
                    deadline
                );
            } else {
                // If tokenA, tokenB are not BNB
                (, , liquidity) = ILogicContract(_logic).addLiquidity(
                    reserve.swap,
                    reserve.tokenA,
                    reserve.tokenB,
                    arrToken0Amount[index],
                    arrToken1Amount[index],
                    0,
                    0,
                    deadline
                );
            }

            // Deposit to masterchief
            ILogicContract(_logic).deposit(
                reserve.swapMaster,
                reserve.poolID,
                liquidity
            );
            emit Deposit(reserve.lpToken, liquidity);

            unchecked {
                ++index;
            }
        }

        emit Build(usdAmount);
    }

    /**
     * @notice Destory Strategy
     * @param _percentage % that sould be destoried for all pairs < 10000
     */
    function destroy(uint256 _percentage) public onlyOwnerAndAdmin {
        require(_percentage <= 10000, "F11");

        // Get Farming Pairs, Percentages
        FarmingPair[] memory reserves = ILendBorrowFarmingPair(farmingPair)
            .getFarmingPairs();

        // Calculate the total amount of each pair
        address _logic = logic;
        uint256 count = reserves.length;
        uint256 index;

        // For each pair, process the build
        for (index = 0; index < count; ) {
            FarmingPair memory reserve = reserves[index];

            (uint256 depositedLp, ) = IMasterChef(reserve.swapMaster).userInfo(
                reserve.poolID,
                _logic
            );

            // Withdraw LP token from masterchef and repayborrow
            if (depositedLp > 0)
                _withdrawAndRepay(reserve, (depositedLp * _percentage) / 10000);

            unchecked {
                ++index;
            }
        }

        emit Destroy(_percentage);
    }

    /**
     * @notice Destory Strategy All
     */
    function destroyAll() public onlyOwnerAndAdmin {
        // Get Farming Pairs, Percentages
        FarmingPair[] memory reserves = ILendBorrowFarmingPair(farmingPair)
            .getFarmingPairs();

        // Calculate the total amount of each pair
        address _logic = logic;
        uint256 count = reserves.length;
        uint256 index;

        // Claim and swap rewards to BNB
        _claimInternal(0);

        // Destory all pairs
        destroy(10000);

        // Keep BNB balance
        uint256 balanceBNBOld = address(_logic).balance;

        // For each pair Swap remained tokens to BNB
        uint256 deadline = block.timestamp + 100;
        uint256 balance;
        for (index = 0; index < count; ) {
            FarmingPair memory reserve = reserves[index];

            // Check TokenA
            balance = IERC20Upgradeable(reserve.tokenA).balanceOf(_logic);
            if (balance > 0) {
                ILogicContract(_logic).swapExactTokensForETH(
                    reserve.swap,
                    balance,
                    0,
                    reserve.pathTokenA2BNB,
                    deadline
                );
            }

            // Check TokenB
            if (reserve.tokenB != address(0)) {
                balance = IERC20Upgradeable(reserve.tokenB).balanceOf(_logic);
                if (balance > 0) {
                    ILogicContract(_logic).swapExactTokensForETH(
                        reserve.swap,
                        balance,
                        0,
                        reserve.pathTokenB2BNB,
                        deadline
                    );
                }
            }

            unchecked {
                ++index;
            }
        }

        // For each pair if there is unpaid borrow, repay it using BNB
        uint256 borrowAmount;
        uint256 length;
        address[] memory pathToBNBToToken;
        uint256 i;
        for (index = 0; index < count; ) {
            FarmingPair memory reserve = reserves[index];

            // For TokenA
            borrowAmount = IXToken(reserve.xTokenA).borrowBalanceCurrent(
                _logic
            );
            if (borrowAmount > 0) {
                // Get path BNB to token
                length = reserve.pathTokenA2BNB.length;
                pathToBNBToToken = new address[](length);
                for (i = 0; i < length; i++)
                    pathToBNBToToken[i] = reserve.pathTokenA2BNB[
                        length - i - 1
                    ];

                // Swap BNB for token
                balance = address(_logic).balance;
                ILogicContract(_logic).swapETHForExactTokens(
                    reserve.swap,
                    balance,
                    borrowAmount,
                    pathToBNBToToken,
                    deadline
                );

                // Repayborrow
                ILogicContract(_logic).repayBorrow(
                    reserve.xTokenA,
                    borrowAmount
                );
            }

            // For TokenB
            borrowAmount = IXToken(reserve.xTokenB).borrowBalanceCurrent(
                _logic
            );
            if (borrowAmount > 0) {
                // Get path BNB to token
                if (reserve.tokenB != address(0)) {
                    length = reserve.pathTokenB2BNB.length;
                    pathToBNBToToken = new address[](length);
                    for (i = 0; i < length; i++)
                        pathToBNBToToken[i] = reserve.pathTokenB2BNB[
                            length - i - 1
                        ];

                    // Swap BNB for token
                    balance = address(_logic).balance;
                    ILogicContract(_logic).swapETHForExactTokens(
                        reserve.swap,
                        balance,
                        borrowAmount,
                        pathToBNBToToken,
                        deadline
                    );
                }

                // Repayborrow
                ILogicContract(_logic).repayBorrow(
                    reserve.xTokenB,
                    borrowAmount
                );
            }

            unchecked {
                ++index;
            }
        }

        // Check BNB is increated
        // Swap available BNB to BLID and send BLID to storage
        uint256 balanceBNBNew = address(_logic).balance;
        if (balanceBNBNew > balanceBNBOld) {
            _sendRewardsToStorage(balanceBNBNew - balanceBNBOld);
        }

        emit DestroyAll();
    }

    /**
     * @notice Destory All, RedeemUnderlying, return all Tokens to storage
     */
    function returnAllTokensToStorage() external onlyOwnerAndAdmin {
        address _logic = logic;

        // Destroy All
        // destroyAll();

        // Get all tokens in storage
        address[] memory tokens = IMultiLogicProxy(multiLogicProxy)
            .getUsedTokensStorage();
        uint256 length = tokens.length;

        // For each token
        for (uint256 i = 0; i < length; ) {
            address token = tokens[i];

            // Get token balance registered to MultiLogic
            uint256 balance = IMultiLogicProxy(multiLogicProxy).getTokenBalance(
                token,
                _logic
            );

            if (balance == 0) continue;

            // Check token has been inited
            require(vTokens[token] != address(0), "F2");

            // Calculate redeem amount
            uint256 redeemAmount = balance;
            if (token != address(0))
                redeemAmount -= IERC20Upgradeable(token).balanceOf(_logic); // Logic doesn't have BNB after destroyAll();

            // RedeemUnderlying
            if (redeemAmount > 0)
                ILogicContract(_logic).redeemUnderlying(
                    vTokens[token],
                    redeemAmount
                );

            // Return existing Token To Storage
            if (balance > 0)
                ILogicContract(_logic).returnTokenToStorage(balance, token);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Claim Rewards and send BLID to Storage
     * @param mode 0 : all, 1 : Venus only, 2 : Farm only
     */
    function claimRewards(uint8 mode) external onlyOwnerAndAdmin {
        require(pathToSwapBNBToBLID.length >= 2, "F15");

        address _logic = logic;

        // Keep BNB balance
        uint256 balanceBNBOld = address(_logic).balance;

        // Claim Rewards token
        _claimInternal(mode);

        // Check rewards BNB
        uint256 balanceBNBNew = address(_logic).balance;

        if (balanceBNBNew > balanceBNBOld) {
            // Convert BNB to BLID and send to storage
            uint256 amountBLID = _sendRewardsToStorage(
                balanceBNBNew - balanceBNBOld
            );

            emit ClaimRewards(amountBLID);
        }
    }

    /**
     * @notice multicall to Logic
     */
    function multicall(bytes[] memory callDatas)
        public
        onlyOwnerAndAdmin
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        uint256 length = callDatas.length;
        returnData = new bytes[](length);
        for (uint256 i = 0; i < length; ) {
            (bool success, bytes memory ret) = address(logic).call(
                callDatas[i]
            );
            require(success, "F99");
            returnData[i] = ret;

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Frees up tokens for the user, but Storage doesn't transfer token for the user,
     * only Storage can this function, after calling this function Storage transfer
     * from Logic to user token.
     * @param _amount Amount of token
     * @param token Address of token
     */
    function releaseToken(uint256 _amount, address token)
        external
        payable
        onlyMultiLogicProxy
    {
        require(vTokens[token] != address(0), "F2");

        // Get Farming Pairs
        FarmingPair[] memory reserves = ILendBorrowFarmingPair(farmingPair)
            .getFarmingPairs();

        uint256 takeFromVenus = 0;
        uint256 length = reserves.length;
        address _logic = logic;
        address vToken = vTokens[token];

        // check logic balance
        uint256 amount;

        if (token == address(0)) {
            amount = address(_logic).balance;
        } else {
            amount = IERC20Upgradeable(token).balanceOf(_logic);
        }
        if (amount >= _amount) {
            if (token == address(0)) {
                ILogicContract(_logic).returnETHToMultiLogicProxy(_amount);
            }

            emit ReleaseToken(token, _amount);
            return;
        }

        // decrease redeemAmount
        amount = _amount - amount;

        //loop by reserves lp token
        for (uint256 i = 0; i < length; ) {
            address[] memory path = ILendBorrowFarmingPair(farmingPair)
                .findPath(i, token); // get path for router
            FarmingPair memory reserve = reserves[i];
            uint256 lpAmount = ILendBorrowFarmingPair(farmingPair)
                .getPriceFromTokenToLp(
                    reserve.lpToken,
                    amount - takeFromVenus,
                    token,
                    reserve.swap,
                    path
                ); //get amount of lp token that need for reedem liqudity

            //get how many deposited to farming
            (uint256 depositedLp, ) = IMasterChef(reserve.swapMaster).userInfo(
                reserve.poolID,
                _logic
            );
            if (depositedLp == 0) continue;
            // if deposited LP tokens don't enough  for repay borrow and for reedem token then only repay
            // borow and continue loop, else repay borow, reedem token and break loop
            if (lpAmount >= depositedLp) {
                takeFromVenus += ILendBorrowFarmingPair(farmingPair)
                    .getPriceFromLpToToken(
                        reserve.lpToken,
                        depositedLp,
                        token,
                        reserve.swap,
                        path
                    );
                _withdrawAndRepay(reserve, depositedLp);
            } else {
                _withdrawAndRepay(reserve, lpAmount);

                // get supplied token and break loop
                ILogicContract(_logic).redeemUnderlying(vToken, amount);

                if (token == address(0)) {
                    ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
                }
                emit ReleaseToken(token, _amount);
                return;
            }

            unchecked {
                ++i;
            }
        }

        //try get supplied token
        ILogicContract(_logic).redeemUnderlying(vToken, amount);
        //if get money
        if (
            token != address(0) &&
            IERC20Upgradeable(token).balanceOf(_logic) >= _amount
        ) {
            emit ReleaseToken(token, _amount);
            return;
        }

        if (token == address(0) && address(_logic).balance >= _amount) {
            ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
            emit ReleaseToken(token, _amount);
            return;
        }

        // redeem remaind vToken
        uint256 vTokenBalance; // balance of cToken
        uint256 exchangeRateMantissa; //conversion rate from cToken to token

        // Get vToken information and redeem
        (, vTokenBalance, , exchangeRateMantissa) = IXToken(vToken)
            .getAccountSnapshot(_logic);

        if (vTokenBalance > 0) {
            uint256 supplyBalance = (vTokenBalance * exchangeRateMantissa) /
                10**18;

            ILogicContract(_logic).redeemUnderlying(vToken, supplyBalance);
        }

        if (
            token != address(0) &&
            IERC20Upgradeable(token).balanceOf(_logic) >= _amount
        ) {
            emit ReleaseToken(token, _amount);
            return;
        }

        if (token == address(0) && address(_logic).balance >= _amount) {
            ILogicContract(_logic).returnETHToMultiLogicProxy(amount);
            emit ReleaseToken(token, _amount);
            return;
        }

        revert("no money");
    }

    /*** Prive Function ***/

    /**
     * Calculate borrow amount, build amount for each pair
     * @param reserve FarmingPair
     * @param borrowUSDAmount required borrow amount in USD for this pair
     * @return token0Amount token0 build amount
     * @return token1Amount token1 build amount
     * @return token0BorrowAmount token0 borrow amount
     * @return token1BorrowAmount token1 borrow amount
     */
    function _calcBorrowAmount(
        FarmingPair memory reserve,
        uint256 borrowUSDAmount
    )
        private
        view
        returns (
            uint256 token0Amount,
            uint256 token1Amount,
            uint256 token0BorrowAmount,
            uint256 token1BorrowAmount
        )
    {
        address _logic = logic;
        address _comptroller = comptroller;
        uint256 balance0;
        uint256 balance1;

        // Token convertion rate to USD : decimal = 18 + (18 - token.decimals)
        uint256 token0Price = IOracleVenus(
            IComptrollerVenus(_comptroller).oracle()
        ).getUnderlyingPrice(reserve.xTokenA);
        uint256 token1Price = IOracleVenus(
            IComptrollerVenus(_comptroller).oracle()
        ).getUnderlyingPrice(reserve.xTokenB);

        // get Reserves
        (balance0, balance1, ) = IPancakePair(reserve.lpToken).getReserves();

        // Calculate Reserves in USD Amount
        balance0 =
            ((
                IPancakePair(reserve.lpToken).token0() == reserve.tokenA
                    ? balance0
                    : balance1
            ) * token0Price) /
            (10**18);
        balance1 =
            ((
                IPancakePair(reserve.lpToken).token0() == reserve.tokenA
                    ? balance1
                    : balance0
            ) * token1Price) /
            (10**18);

        // Calculate build amount for addToLiquidity
        token0Amount =
            (borrowUSDAmount * (10**18) * balance0) /
            (token0Price * (balance0 + balance1));
        token1Amount =
            (borrowUSDAmount * (10**18) * balance1) /
            (token1Price * (balance0 + balance1));

        // Calculate borrow amount (TokenA should not be address(0) BNB)
        balance0 = IERC20Upgradeable(reserve.tokenA).balanceOf(_logic);
        balance1 = reserve.tokenB == address(0)
            ? address(_logic).balance
            : IERC20Upgradeable(reserve.tokenB).balanceOf(_logic);

        token0BorrowAmount = token0Amount > balance0
            ? token0Amount - balance0
            : 0;
        token1BorrowAmount = token1Amount > balance1
            ? token1Amount - balance1
            : 0;
    }

    /**
     * @notice Claim rewards and swap to BNB
     * @param mode 0 : all, 1 : Venus only, 2 : Farm only
     */
    function _claimInternal(uint8 mode) private {
        require(pathToSwapRewardsToBNB.length >= 2, "F14");

        address _logic = logic;
        uint256 _lendingTokensCount = lendingTokensCount;
        uint256 index;
        uint256 deadline = block.timestamp + 100;
        uint256 balance;

        // claim XVS
        if (mode == 0 || mode == 1) {
            address[] memory vTokensToClaim = new address[](
                _lendingTokensCount
            );
            for (index = 0; index < _lendingTokensCount; ) {
                vTokensToClaim[index] = lendingTokens[index];

                unchecked {
                    ++index;
                }
            }
            ILogicContract(_logic).claim(vTokensToClaim, 0);

            // Swap XVS to BNB
            balance = IERC20Upgradeable(rewardsToken).balanceOf(_logic);
            if (balance > 0) {
                ILogicContract(_logic).swapExactTokensForETH(
                    rewardsSwapRouter,
                    balance,
                    0,
                    pathToSwapRewardsToBNB,
                    deadline
                );
            }
        }

        // For each pair, claim CAKE/BSW
        if (mode == 0 || mode == 2) {
            // Get Farming Pairs
            FarmingPair[] memory reserves = ILendBorrowFarmingPair(farmingPair)
                .getFarmingPairs();
            uint256 count = reserves.length;

            for (index = 0; index < count; ) {
                FarmingPair memory reserve = reserves[index];

                // call MasterChef.deposit(0);
                ILogicContract(_logic).deposit(
                    reserve.swapMaster,
                    reserve.poolID,
                    0
                );

                // Swap rewards token to BNB
                balance = IERC20Upgradeable(reserve.rewardsToken).balanceOf(
                    _logic
                );
                if (balance > 0) {
                    ILogicContract(_logic).swapExactTokensForETH(
                        reserve.swap,
                        balance,
                        0,
                        reserve.pathRewards2BNB,
                        deadline
                    );
                }

                unchecked {
                    ++index;
                }
            }
        }
    }

    /**
     * @notice Swap BNB to BLID and send to storage
     * @param amountBNB reward BNB amount
     * @return amountBLID reward BLID amount
     */
    function _sendRewardsToStorage(uint256 amountBNB)
        internal
        returns (uint256 amountBLID)
    {
        address _logic = logic;

        // Convert BNB to BLID
        if (amountBNB > 0) {
            uint256 amountOutMin = 0;
            uint256 deadline = block.timestamp + 100;

            ILogicContract(_logic).swapExactETHForTokens(
                rewardsSwapRouter,
                amountBNB,
                amountOutMin,
                pathToSwapBNBToBLID,
                deadline
            );

            // Add BLID earn to storage
            amountBLID = IERC20Upgradeable(blid).balanceOf(_logic);
            if (amountBLID > 0)
                ILogicContract(_logic).addEarnToStorage(amountBLID);
        }
    }

    /**
     * @notice Withdraw lp token from farms and repay borrow
     */
    function _withdrawAndRepay(FarmingPair memory reserve, uint256 lpAmount)
        private
    {
        ILogicContract(logic).withdraw(
            reserve.swapMaster,
            reserve.poolID,
            lpAmount
        );
        if (reserve.tokenB == address(0)) {
            //if tokenB is BNB
            _repayBorrowBNBandToken(
                reserve.swap,
                reserve.tokenA,
                reserve.xTokenB,
                reserve.xTokenA,
                lpAmount
            );
        } else {
            //if token A and B is not BNB
            _repayBorrowOnlyTokens(
                reserve.swap,
                reserve.tokenA,
                reserve.tokenB,
                reserve.xTokenA,
                reserve.xTokenB,
                lpAmount
            );
        }
    }

    /**
     * @notice Repay borrow when in farms  erc20 and BNB
     */
    function _repayBorrowBNBandToken(
        address swap,
        address tokenB,
        address xTokenA,
        address xTokenB,
        uint256 lpAmount
    ) private {
        address _logic = logic;

        (uint256 amountToken, uint256 amountETH) = ILogicContract(_logic)
            .removeLiquidityETH(
                swap,
                tokenB,
                lpAmount,
                0,
                0,
                block.timestamp + 1 days
            );
        {
            uint256 totalBorrow = IXTokenETH(xTokenA).borrowBalanceCurrent(
                _logic
            );
            if (totalBorrow >= amountETH) {
                ILogicContract(_logic).repayBorrow(xTokenA, amountETH);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenA, totalBorrow);
            }

            totalBorrow = IXToken(xTokenB).borrowBalanceCurrent(_logic);
            if (totalBorrow >= amountToken) {
                ILogicContract(_logic).repayBorrow(xTokenB, amountToken);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenB, totalBorrow);
            }
        }
    }

    /**
     * @notice Repay borrow when in farms only erc20
     */
    function _repayBorrowOnlyTokens(
        address swap,
        address tokenA,
        address tokenB,
        address xTokenA,
        address xTokenB,
        uint256 lpAmount
    ) private {
        address _logic = logic;

        (uint256 amountA, uint256 amountB) = ILogicContract(_logic)
            .removeLiquidity(
                swap,
                tokenA,
                tokenB,
                lpAmount,
                0,
                0,
                block.timestamp + 1 days
            );
        {
            uint256 totalBorrow = IXToken(xTokenA).borrowBalanceCurrent(_logic);
            if (totalBorrow >= amountA) {
                ILogicContract(_logic).repayBorrow(xTokenA, amountA);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenA, totalBorrow);
            }

            totalBorrow = IXToken(xTokenB).borrowBalanceCurrent(_logic);
            if (totalBorrow >= amountB) {
                ILogicContract(_logic).repayBorrow(xTokenB, amountB);
            } else {
                ILogicContract(_logic).repayBorrow(xTokenB, totalBorrow);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./OwnableUpgradeableVersionable.sol";
import "./OwnableUpgradeableAdminable.sol";

abstract contract LogicUpgradeable is
    Initializable,
    OwnableUpgradeableVersionable,
    OwnableUpgradeableAdminable,
    UUPSUpgradeable
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    function initialize() public initializer {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface ILogicContract {
    function addXTokens(
        address token,
        address xToken,
        uint8 leadingTokenType
    ) external;

    function approveTokenForSwap(address token) external;

    function claim(address[] calldata xTokens, uint8 leadingTokenType) external;

    function mint(address xToken, uint256 mintAmount)
        external
        returns (uint256);

    function borrow(
        address xToken,
        uint256 borrowAmount,
        uint8 leadingTokenType
    ) external returns (uint256);

    function repayBorrow(address xToken, uint256 repayAmount) external;

    function redeemUnderlying(address xToken, uint256 redeemAmount)
        external
        returns (uint256);

    function swapExactTokensForTokens(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        address swap,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        address swap,
        uint256 amountETH,
        uint256 amountOut,
        address[] calldata path,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function addLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 amountADesired,
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

    function removeLiquidity(
        address swap,
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function addLiquidityETH(
        address swap,
        address token,
        uint256 amountTokenDesired,
        uint256 amountETHDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    )
        external
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidityETH(
        address swap,
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH);

    function addEarnToStorage(uint256 amount) external;

    function enterMarkets(address[] calldata xTokens, uint8 leadingTokenType)
        external
        returns (uint256[] memory);

    function returnTokenToStorage(uint256 amount, address token) external;

    function takeTokenFromStorage(uint256 amount, address token) external;

    function returnETHToMultiLogicProxy(uint256 amount) external;

    function deposit(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external;

    function withdraw(
        address swapMaster,
        uint256 _pid,
        uint256 _amount
    ) external;

    function returnToken(uint256 amount, address token) external; // for StorageV2 only
}

interface IStrategy {
    function releaseToken(uint256 amount, address token) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IXToken {
    function mint(uint256 mintAmount) external returns (uint256);

    function borrow(uint256 borrowAmount) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow(uint256 repayAmount) external returns (uint256);

    function borrowBalanceCurrent(address account) external returns (uint256);

    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );

    function underlying() external view returns (address);

    function name() external view returns (string memory);
}

interface IXTokenETH {
    function mint() external payable;

    function borrow(uint256 borrowAmount) external returns (uint256);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);

    function repayBorrow() external payable;

    function borrowBalanceCurrent(address account) external returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IComptrollerVenus {
    function enterMarkets(address[] calldata xTokens)
        external
        returns (uint256[] memory);

    function markets(address cTokenAddress)
        external
        view
        returns (
            bool,
            uint256,
            bool
        );

    function getAllMarkets() external view returns (address[] memory);

    function getAccountLiquidity(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );

    function oracle() external view returns (address);
}

interface IDistributionVenus {
    function claimVenus(address holder, address[] memory vTokens) external;
}

interface IOracleVenus {
    function getUnderlyingPrice(address vToken) external view returns (uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IMultiLogicProxy {
    function releaseToken(uint256 amount, address token) external;

    function takeToken(uint256 amount, address token) external;

    function addEarn(uint256 amount, address blidToken) external;

    function returnToken(uint256 amount, address token) external;

    function setLogicTokenAvailable(
        uint256 amount,
        address token,
        uint256 deposit_withdraw
    ) external;

    function getTokenAvailable(address _token, address _logicAddress)
        external
        view
        returns (uint256);

    function getTokenBalance(address _token, address _logicAddress)
        external
        view
        returns (uint256);

    function getUsedTokensStorage() external view returns (address[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IPancakePair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112,
            uint112,
            uint32
        );
}

interface IPancakeRouter01 {
    function WETH() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

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
}

interface IMasterChef {
    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function userInfo(uint256 _pid, address account)
        external
        view
        returns (uint256, uint256);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

struct FarmingPair {
    address tokenA;
    address tokenB;
    address xTokenA;
    address xTokenB;
    address swap;
    address swapMaster;
    address lpToken;
    uint256 poolID;
    address rewardsToken;
    address[][] path;
    address[] pathTokenA2BNB;
    address[] pathTokenB2BNB;
    address[] pathRewards2BNB;
    uint256 percentage;
}

interface ILendBorrowFarmingPair {
    function getFarmingPairs() external view returns (FarmingPair[] memory);

    function getPriceFromLpToToken(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) external view returns (uint256);

    function getPriceFromTokenToLp(
        address lpToken,
        uint256 value,
        address token,
        address swap,
        address[] memory path
    ) external view returns (uint256);

    function checkPercentages() external view;

    function findPath(uint256 id, address token)
        external
        view
        returns (address[] memory path);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
import "../extensions/draft-IERC20PermitUpgradeable.sol";
import "../../../utils/AddressUpgradeable.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract OwnableUpgradeableVersionable is OwnableUpgradeable {
    string private _version;
    string private _purpose;

    event UpgradeVersion(string version, string purpose);

    function getVersion() external view returns (string memory) {
        return _version;
    }

    function getPurpose() external view returns (string memory) {
        return _purpose;
    }

    /**
    * @notice Set version and purpose
    * @param version Version string, ex : 1.2.0
    * @param purpose Purpose string
    */
    function upgradeVersion(string memory version, string memory purpose)
        external
        onlyOwner
    {
        require(bytes(version).length != 0, "OV1");

        _version = version;
        _purpose = purpose;

        emit UpgradeVersion(version, purpose);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract OwnableUpgradeableAdminable is OwnableUpgradeable {
    address private _admin;

    event SetAdmin(address admin);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "OA1");
        _;
    }

    modifier onlyOwnerAndAdmin() {
        require(msg.sender == owner() || msg.sender == _admin, "OA2");
        _;
    }

    /**
     * @notice Set admin
     * @param newAdmin Addres of new admin
     */
    function setAdmin(address newAdmin) external onlyOwner {
        _admin = newAdmin;
        emit SetAdmin(newAdmin);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (proxy/utils/Initializable.sol)

pragma solidity ^0.8.2;

import "../../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since proxied contracts do not make use of a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be
 * reused. This mechanism prevents re-execution of each "step" but allows the creation of new initialization steps in
 * case an upgrade adds a module that needs to be initialized.
 *
 * For example:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * contract MyToken is ERC20Upgradeable {
 *     function initialize() initializer public {
 *         __ERC20_init("MyToken", "MTK");
 *     }
 * }
 * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {
 *     function initializeV2() reinitializer(2) public {
 *         __ERC20Permit_init("MyToken");
 *     }
 * }
 * ```
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 *
 * [CAUTION]
 * ====
 * Avoid leaving a contract uninitialized.
 *
 * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation
 * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke
 * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:
 *
 * [.hljs-theme-light.nopadding]
 * ```
 * /// @custom:oz-upgrades-unsafe-allow constructor
 * constructor() {
 *     _disableInitializers();
 * }
 * ```
 * ====
 */
abstract contract Initializable {
    /**
     * @dev Indicates that the contract has been initialized.
     * @custom:oz-retyped-from bool
     */
    uint8 private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Triggered when the contract has been initialized or reinitialized.
     */
    event Initialized(uint8 version);

    /**
     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,
     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.
     */
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    /**
     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the
     * contract hasn't been initialized to a greater version before. In its scope, `onlyInitializing` functions can be
     * used to initialize parent contracts.
     *
     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original
     * initialization step. This is essential to configure modules that are added through upgrades and that require
     * initialization.
     *
     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in
     * a contract, executing them in the right order is up to the developer or operator.
     */
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }

    /**
     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the
     * {initializer} and {reinitializer} modifiers, directly or indirectly.
     */
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    /**
     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.
     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized
     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called
     * through proxies.
     */
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/utils/UUPSUpgradeable.sol)

pragma solidity ^0.8.0;

import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../ERC1967/ERC1967UpgradeUpgradeable.sol";
import "./Initializable.sol";

/**
 * @dev An upgradeability mechanism designed for UUPS proxies. The functions included here can perform an upgrade of an
 * {ERC1967Proxy}, when this contract is set as the implementation behind such a proxy.
 *
 * A security mechanism ensures that an upgrade does not turn off upgradeability accidentally, although this risk is
 * reinstated if the upgrade retains upgradeability but removes the security mechanism, e.g. by replacing
 * `UUPSUpgradeable` with a custom implementation of upgrades.
 *
 * The {_authorizeUpgrade} function must be overridden to include access restriction to the upgrade mechanism.
 *
 * _Available since v4.1._
 */
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }

    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    /// @custom:oz-upgrades-unsafe-allow state-variable-immutable state-variable-assignment
    address private immutable __self = address(this);

    /**
     * @dev Check that the execution is being performed through a delegatecall call and that the execution context is
     * a proxy contract with an implementation (as defined in ERC1967) pointing to self. This should only be the case
     * for UUPS and transparent proxies that are using the current contract as their implementation. Execution of a
     * function through ERC1167 minimal proxies (clones) would not normally pass this test, but is not guaranteed to
     * fail.
     */
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    /**
     * @dev Check that the execution is not being performed through a delegate call. This allows a function to be
     * callable on the implementing contract but not through proxies.
     */
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }

    /**
     * @dev Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the
     * implementation. It is used to validate that the this implementation remains valid after an upgrade.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.
     */
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }

    /**
     * @dev Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call
     * encoded in `data`.
     *
     * Calls {_authorizeUpgrade}.
     *
     * Emits an {Upgraded} event.
     */
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }

    /**
     * @dev Function that should revert when `msg.sender` is not authorized to upgrade the contract. Called by
     * {upgradeTo} and {upgradeToAndCall}.
     *
     * Normally, this function will use an xref:access.adoc[access control] modifier such as {Ownable-onlyOwner}.
     *
     * ```solidity
     * function _authorizeUpgrade(address) internal override onlyOwner {}
     * ```
     */
    function _authorizeUpgrade(address newImplementation) internal virtual;

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/utils/Initializable.sol";

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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (interfaces/draft-IERC1822.sol)

pragma solidity ^0.8.0;

/**
 * @dev ERC1822: Universal Upgradeable Proxy Standard (UUPS) documents a method for upgradeability through a simplified
 * proxy whose upgrades are fully controlled by the current implementation.
 */
interface IERC1822ProxiableUpgradeable {
    /**
     * @dev Returns the storage slot that the proxiable contract assumes is being used to store the implementation
     * address.
     *
     * IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks
     * bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this
     * function revert if invoked through a proxy.
     */
    function proxiableUUID() external view returns (bytes32);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (proxy/ERC1967/ERC1967Upgrade.sol)

pragma solidity ^0.8.2;

import "../beacon/IBeaconUpgradeable.sol";
import "../../interfaces/draft-IERC1822Upgradeable.sol";
import "../../utils/AddressUpgradeable.sol";
import "../../utils/StorageSlotUpgradeable.sol";
import "../utils/Initializable.sol";

/**
 * @dev This abstract contract provides getters and event emitting update functions for
 * https://eips.ethereum.org/EIPS/eip-1967[EIP1967] slots.
 *
 * _Available since v4.1._
 *
 * @custom:oz-upgrades-unsafe-allow delegatecall
 */
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }

    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    // This is the keccak-256 hash of "eip1967.proxy.rollback" subtracted by 1
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    /**
     * @dev Storage slot with the address of the current implementation.
     * This is the keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @dev Emitted when the implementation is upgraded.
     */
    event Upgraded(address indexed implementation);

    /**
     * @dev Returns the current implementation address.
     */
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 implementation slot.
     */
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    /**
     * @dev Perform implementation upgrade
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    /**
     * @dev Perform implementation upgrade with security checks for UUPS proxies, and additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        // Upgrades from old implementations will perform a rollback test. This test requires the new
        // implementation to upgrade back to the old, non-ERC1822 compliant, implementation. Removing
        // this special case will break upgrade paths from old UUPS implementation to new ones.
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }

    /**
     * @dev Storage slot with the admin of the contract.
     * This is the keccak-256 hash of "eip1967.proxy.admin" subtracted by 1, and is
     * validated in the constructor.
     */
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @dev Emitted when the admin account has changed.
     */
    event AdminChanged(address previousAdmin, address newAdmin);

    /**
     * @dev Returns the current admin.
     */
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    /**
     * @dev Stores a new address in the EIP1967 admin slot.
     */
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    /**
     * @dev Changes the admin of the proxy.
     *
     * Emits an {AdminChanged} event.
     */
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    /**
     * @dev The storage slot of the UpgradeableBeacon contract which defines the implementation for this proxy.
     * This is bytes32(uint256(keccak256('eip1967.proxy.beacon')) - 1)) and is validated in the constructor.
     */
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    /**
     * @dev Emitted when the beacon is upgraded.
     */
    event BeaconUpgraded(address indexed beacon);

    /**
     * @dev Returns the current beacon.
     */
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    /**
     * @dev Stores a new beacon in the EIP1967 beacon slot.
     */
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    /**
     * @dev Perform beacon upgrade with additional setup call. Note: This upgrades the address of the beacon, it does
     * not upgrade the implementation contained in the beacon (see {UpgradeableBeacon-_setImplementation} for that).
     *
     * Emits a {BeaconUpgraded} event.
     */
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/beacon/IBeacon.sol)

pragma solidity ^0.8.0;

/**
 * @dev This is the interface that {BeaconProxy} expects of its beacon.
 */
interface IBeaconUpgradeable {
    /**
     * @dev Must return an address that can be used as a delegate call target.
     *
     * {BeaconProxy} will check that this address is a contract.
     */
    function implementation() external view returns (address);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/StorageSlot.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for reading and writing primitive types to specific storage slots.
 *
 * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.
 * This library helps with reading and writing to such slots without the need for inline assembly.
 *
 * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.
 *
 * Example usage to set ERC1967 implementation slot:
 * ```
 * contract ERC1967 {
 *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
 *
 *     function _getImplementation() internal view returns (address) {
 *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
 *     }
 *
 *     function _setImplementation(address newImplementation) internal {
 *         require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
 *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
 *     }
 * }
 * ```
 *
 * _Available since v4.1 for `address`, `bool`, `bytes32`, and `uint256`._
 */
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    /**
     * @dev Returns an `AddressSlot` with member `value` located at `slot`.
     */
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.
     */
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.
     */
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }

    /**
     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.
     */
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        /// @solidity memory-safe-assembly
        assembly {
            r.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/draft-IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20PermitUpgradeable {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}