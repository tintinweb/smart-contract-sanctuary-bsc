/**
 *Submitted for verification at BscScan.com on 2022-07-25
*/

/** 
 *  SourceUnit: d:\Projects\ibl\sc-yield-betting\contracts\SportBet.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

// solhint-disable-next-line compiler-version
pragma solidity ^0.8.0;

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}




/** 
 *  SourceUnit: d:\Projects\ibl\sc-yield-betting\contracts\SportBet.sol
*/
            
////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT

pragma solidity ^0.8.0;
////import "../proxy/utils/Initializable.sol";

/*
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
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}


/** 
 *  SourceUnit: d:\Projects\ibl\sc-yield-betting\contracts\SportBet.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.0;

////import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
////import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface IAffiliate {

    function distributeReferralFee(address account) external payable;

}

interface IBanker {

    function release(address account, uint256 amount) external;

}

interface IRug {

    function isOperator(address account) external view returns(bool);
    function getJackpotAddress() external view returns(address);
    function getBankerAddress() external view returns(address);
    function getOperationAddress() external view returns(address);
    function getReferralAddress() external view returns(address);

}

contract SportBet is Initializable, ContextUpgradeable {

    event logSportBetReceiveFund(address account, uint256 amount);
    event logSportBetChangeDepositFees(uint256 operationFee, uint256 jackpotFee, uint256 bankerFee, uint256 referralFee);
    event logSportBetCreateGame(uint256 gameId, uint256 categoryId, uint256[] numPools, uint256[] depositPerPools, uint256 startTime, uint256 endTime, uint256 bettingTime, uint256 displayTime);
    event logSportBetCancelGame(uint256 gameId, uint256 bankerFund);
    event logSportBetCancelSubGame(uint256 gameId, uint256 subGameId, uint256 bankerFund);
    event logSportBetDeposit(uint256 gameId, uint256 subGameId, uint256 poolId, address user, uint256 amount, uint256 bankerFee, uint256 operationFee, uint256 referralFee);
    event logSportBetDepositSubGame(uint256 gameId, uint256 subGameId, uint256 numPools, uint256 depositPerPool);
    event logSportBetClaimReward(uint256 gameId, uint256 subGameId, uint256 poolId, address user, uint256 deposit, uint256 reward);
    event logSportBetSelectPool(uint256 gameId, uint256[] subGameIds, uint256[] poolIds);
    event logSportBetClaimDeposit(uint256 gameId, uint256 subGameId, uint256 poolId, address user, uint256 deposit);

    struct Pool {
        uint256 totalDeposit;
        uint256 totalReward;
    }

    struct SubGame {
        uint256 totalDeposit;
        uint256 totalBankerFund;
        uint256 status;
        uint256 numParticipants;
        uint256 winningPool;
    }

    struct Game {
        uint256 categoryId;
        uint256 totalDeposit;
        uint256 startTime;
        uint256 endTime;
        uint256 bettingTime;
        uint256 status;
        uint256 totalBankerFund;
        uint256 numParticipants;
        uint256 totalCommission;
        uint256 displayTime;
    }

    struct WinningInfo {
        address account;
        uint256 reward;
        uint256 deposit;
    }

    struct WinningInfo2 {
        address account;
        uint256 reward;
    }

    uint256 public constant ONE_HUNDRED_PERCENT = 10000; // 100%

    uint256 public constant GAME_CANCELED = 1;
    uint256 public constant GAME_COMPLETED = 2;

    IRug public rug;

    // game id => subgame id => winners
    mapping(uint256 => mapping(uint256 => WinningInfo[])) public winningList;

    // game id => subgame id => pools
    mapping(uint256 => mapping(uint256 => Pool[])) private _pools;

    // game id => game
    mapping(uint256 => Game) private _games;

    // game id => subgames
    mapping(uint256 => SubGame[]) private _subGames;

    // game id => subgame id => number of pools
    mapping(uint256 => mapping(uint256 => uint256)) private _numPools;

    // game id => number of subgames
    mapping(uint256 => uint256) private _numSubGames;

    // user address => game id => subgame id => pool id => deposit amount
    mapping(address => mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256)))) public userDeposit;

    uint256 public currentGame;

    uint256 public operationFee;
    uint256 public jackpotFee;
    uint256 public bankerFee;
    uint256 public referralFee;

    uint256[] public activeGames;
    uint256[] public endedGames;
    uint256[] public canceledGames;

    // game id => user address
    mapping(uint256 => mapping(address => bool)) public isGameParticipant;

    // game id => subgame id => user address
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public isSubGameParticipant;

    mapping(address => uint256[]) public participatedGames;

    // game id => winners
    mapping(uint256 => WinningInfo2[]) public winningList2;

    // user address => game id => deposit amount
    mapping(address => mapping(uint256 => uint256)) public userDeposit2;

    // Now this variable is unused but we need to keep it to prevent user claimed reward cant re-claim
    // user address => game id => subgame id => pool id => true: claimed
    mapping(address => mapping(uint256 => mapping(uint256 => mapping(uint256 => bool)))) private _isClaimed;

    // user address => game id => type: reward | deposit => true: claimed
    mapping(address => mapping(uint256 => mapping(string => bool))) public isClaimed;

    modifier onlyOperator() {
        require(rug.isOperator(_msgSender()), "not in operator list");
        _;
    }

    function initialize(address _rug)
        external
        initializer
    {
        __Context_init_unchained();

        activeGames.push(0);

        rug = IRug(_rug);

        currentGame = 1;

        operationFee = 500; // 5%
        jackpotFee = 100; // 1%
        bankerFee = 250; // 2.5%
        referralFee = 150; // 1.5%
    }

    function deposit() external payable {
        address msgSender = _msgSender();

        require(msgSender == rug.getBankerAddress(), "caller is invalid");

        emit logSportBetReceiveFund(msgSender, msg.value);
    }

    function createGame(uint256 categoryId, uint256[] memory numPools, uint256[] memory depositPerPools, uint256 startTime, uint256 endTime, uint256 bettingTime, uint256 displayTime) 
        external
        onlyOperator
    {
        uint256 numSubGames = numPools.length;

        require(numSubGames > 0 && numSubGames == depositPerPools.length, "array length is invalid");

        require(bettingTime > 0 && startTime >= bettingTime && startTime <= endTime, "time is invalid");

        uint256 totalAmount = 0;

        uint256 gameId = currentGame;

        SubGame[] storage subGames = _subGames[gameId];

        for (uint256 i = 0; i < numSubGames; i++) {
            require(numPools[i] > 1, "number of pools is invalid");

            uint256 amount = depositPerPools[i] * numPools[i];

            subGames.push(SubGame(amount, amount, 0, 0, 0));

            Pool[] storage pools = _pools[gameId][i];

            for (uint256 j = 0; j < numPools[i]; j++) {
                pools.push(Pool(depositPerPools[i], 0));
            }

            totalAmount += amount;

            _numPools[gameId][i] = numPools[i];
        }

        if (totalAmount > 0) {
            IBanker(rug.getBankerAddress()).release(address(this), totalAmount);
        }

        _numSubGames[gameId] = numSubGames;

        _games[gameId] = Game(categoryId, totalAmount, startTime, endTime, bettingTime, 0, totalAmount, 0, 0, displayTime);

        activeGames.push(gameId);

        emit logSportBetCreateGame(gameId, categoryId, numPools, depositPerPools, startTime, endTime, bettingTime, displayTime);

        currentGame++;
    }

    function cancelGame(uint256 gameId)
        external
        onlyOperator
    {
        Game storage game = _games[gameId];

        require(game.status == 0 && block.timestamp < game.endTime, "game was canceled or completed");

        game.status = GAME_CANCELED;

        canceledGames.push(gameId);

        delete activeGames[gameId];

        uint256 totalBankerFund = game.totalBankerFund;

        if (totalBankerFund > 0) {
            payable(rug.getBankerAddress()).transfer(totalBankerFund);

            game.totalDeposit -= totalBankerFund;
            game.totalBankerFund = 0;

            SubGame[] storage subGames = _subGames[gameId];

            for (uint256 i = 0; i < subGames.length; i++) {
                SubGame storage subGame = subGames[i];

                if (subGame.status != 0) {
                    continue;
                }

                uint256 bankerFundPerPool = subGame.totalBankerFund / _numPools[gameId][i];

                subGame.totalDeposit -= subGame.totalBankerFund;
                subGame.totalBankerFund = 0;

                Pool[] storage pools = _pools[gameId][i];

                for (uint256 j = 0; j < pools.length; j++) {
                    pools[j].totalDeposit -= bankerFundPerPool;
                }
            }
        }

        emit logSportBetCancelGame(gameId, totalBankerFund);
    }

    function cancelSubGame(uint256 gameId, uint256[] memory subGameIds)
        external
        onlyOperator
    {
        uint256 numSubGames = subGameIds.length;

        require(numSubGames > 0, "array length is invalid");

        Game storage game = _games[gameId];

        require(game.status == 0 && block.timestamp < game.endTime, "game was canceled or completed");

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < numSubGames; i++) {
            SubGame storage subGame = _subGames[gameId][subGameIds[i]];

            require(subGame.status == 0, "subgame was canceled");

            subGame.status = GAME_CANCELED;

            uint256 totalBankerFund = subGame.totalBankerFund;

            if (totalBankerFund > 0) {
                uint256 bankerFundPerPool = totalBankerFund / _numPools[gameId][subGameIds[i]];

                subGame.totalDeposit -= totalBankerFund;
                subGame.totalBankerFund = 0;

                Pool[] storage pools = _pools[gameId][subGameIds[i]];

                for (uint256 j = 0; j < pools.length; j++) {
                    pools[j].totalDeposit -= bankerFundPerPool;
                }
            }

            emit logSportBetCancelSubGame(gameId, subGameIds[i], totalBankerFund);

            totalAmount += totalBankerFund;
        }

        if (totalAmount > 0) {
            game.totalDeposit -= totalAmount;
            game.totalBankerFund -= totalAmount;

            payable(rug.getBankerAddress()).transfer(totalAmount);
        }
    }

    function depositSubGame(uint256 gameId, uint256[] memory subGameIds, uint256[] memory depositPerPools)
        external
        onlyOperator
    {
        uint256 numSubGames = subGameIds.length;

        require(numSubGames > 0 && numSubGames == depositPerPools.length, "array length is invalid");

        Game storage game = _games[gameId];

        require(game.status == 0, "game was canceled or completed");

        require(block.timestamp < game.startTime, "can not deposit subgame");

        uint256 totalAmount = 0;

        for (uint256 i = 0; i < numSubGames; i++) {
            require(depositPerPools[i] > 0, "deposit amount is invalid");

            SubGame storage subGame = _subGames[gameId][subGameIds[i]];

            require(subGame.status == 0, "subgame was canceled");

            Pool[] storage pools = _pools[gameId][subGameIds[i]];

            uint256 numPools = pools.length;

            for (uint256 j = 0; j < numPools; j++) {
                pools[j].totalDeposit += depositPerPools[i];
            }

            uint256 amount = depositPerPools[i] * numPools;

            subGame.totalDeposit += amount;
            subGame.totalBankerFund += amount;

            totalAmount += amount;

            emit logSportBetDepositSubGame(gameId, subGameIds[i], numPools, depositPerPools[i]);
        }

        game.totalDeposit += totalAmount;
        game.totalBankerFund += totalAmount;

        IBanker(rug.getBankerAddress()).release(address(this), totalAmount);
    }

    function joinGame(uint256 gameId, uint256 subGameId, uint256 poolId)
        external
        payable
    {
        uint256 amount = msg.value;

        require(amount > 0, "deposit amount is invalid");

        Game storage game = _games[gameId];

        require(game.status == 0, "game was canceled or completed");

        require(game.bettingTime <= block.timestamp && block.timestamp < game.startTime, "can not deposit pool");

        SubGame storage subGame = _subGames[gameId][subGameId];

        require(subGame.status == 0, "subgame was canceled");

        Pool storage pool = _pools[gameId][subGameId][poolId];

        address msgSender = _msgSender();

        if (!isGameParticipant[gameId][msgSender]) {
            isGameParticipant[gameId][msgSender] = true;

            participatedGames[msgSender].push(gameId);

            game.numParticipants += 1;
        }

        if (!isSubGameParticipant[gameId][subGameId][msgSender]) {
            isSubGameParticipant[gameId][subGameId][msgSender] = true;

            subGame.numParticipants += 1;
        }

        uint256 _operationFee  = amount * operationFee / ONE_HUNDRED_PERCENT;
        uint256 _jackpotFee    = amount * jackpotFee   / ONE_HUNDRED_PERCENT;
        uint256 _bankerFee     = amount * bankerFee    / ONE_HUNDRED_PERCENT;
        uint256 _referralFee   = amount * referralFee  / ONE_HUNDRED_PERCENT;

        uint256 actualDeposit = amount - _operationFee - _bankerFee - _referralFee - _jackpotFee;

        userDeposit[msgSender][gameId][subGameId][poolId] += actualDeposit;
        userDeposit2[msgSender][gameId] += actualDeposit;

        pool.totalDeposit += actualDeposit;

        subGame.totalDeposit += actualDeposit;

        game.totalDeposit += actualDeposit;

        game.totalCommission += _operationFee;

        if (_jackpotFee > 0) {
            payable(rug.getJackpotAddress()).transfer(_jackpotFee);
        }

        if (_bankerFee > 0) {
            payable(rug.getBankerAddress()).transfer(_bankerFee);
        }

        if (_operationFee > 0) {
            payable(rug.getOperationAddress()).transfer(_operationFee);
        }

        if (_referralFee > 0) {
            IAffiliate(rug.getReferralAddress()).distributeReferralFee{value: _referralFee}(msgSender);
        }

        emit logSportBetDeposit(gameId, subGameId, poolId, msgSender, amount, _bankerFee, _operationFee, _referralFee);
    }

    function claimReward(uint256 gameId)
        external
    {
        Game memory game = _games[gameId];

        require(game.status == GAME_COMPLETED, "game was canceled or was not completed");

        address msgSender = _msgSender();

        require(!isClaimed[msgSender][gameId]["reward"], "already claimed");

        isClaimed[msgSender][gameId]["reward"] = true;

        SubGame[] memory subGames = _subGames[gameId];

        uint256 totalClaim = 0;
        uint256 totalReward = 0;

        for (uint256 i = 0; i < subGames.length; i++) {
            SubGame memory subGame = subGames[i];

            if (subGame.status != 0) {
                continue;
            }

            uint256 poolId = subGame.winningPool - 1;

            uint256 amount = userDeposit[msgSender][gameId][i][poolId];

            if (amount == 0 || _isClaimed[msgSender][gameId][i][poolId]) {
                continue;
            }

            Pool memory pool = _pools[gameId][i][poolId];

            uint256 reward = pool.totalReward * amount / pool.totalDeposit;

            totalReward += reward;

            totalClaim += (reward + amount);

            emit logSportBetClaimReward(gameId, i, poolId, msgSender, amount, reward);

            winningList[gameId][i].push(WinningInfo(msgSender, reward, amount));
        }

        require(totalClaim > 0, "can not claim");

        payable(msgSender).transfer(totalClaim);

        winningList2[gameId].push(WinningInfo2(msgSender, totalReward));
    }

    function claimDeposit(uint256 gameId)
        external
    {
        Game storage game = _games[gameId];

        require(game.status != 0, "game still is running");

        bool isGameCompleted = game.status == GAME_COMPLETED;

        address msgSender = _msgSender();

        require(!isClaimed[msgSender][gameId]["deposit"], "already claimed");

        isClaimed[msgSender][gameId]["deposit"] = true;

        SubGame[] storage subGames = _subGames[gameId];

        uint256 totalClaim = 0;

        for (uint256 i = 0; i < subGames.length; i++) {
            SubGame storage subGame = subGames[i];

            if (isGameCompleted && subGame.status != GAME_CANCELED) {
                continue;
            }

            Pool[] storage pools = _pools[gameId][i];

            uint256 totalAmount = 0;

            for (uint256 j = 0; j < pools.length; j++) {
                Pool storage pool = pools[j];

                uint256 amount = userDeposit[msgSender][gameId][i][j];

                if (amount == 0) {
                    continue;
                }

                pool.totalDeposit -= amount;

                totalAmount += amount;

                userDeposit[msgSender][gameId][i][j] = 0;

                emit logSportBetClaimDeposit(gameId, i, j, msgSender, amount);
            }

            subGame.totalDeposit -= totalAmount;

            totalClaim += totalAmount;
        }

        game.totalDeposit -= totalClaim;

        userDeposit2[msgSender][gameId] -= totalClaim;

        require(totalClaim > 0, "can not claim");

        payable(msgSender).transfer(totalClaim);
    }

    function selectPool(uint256 gameId, uint256[] memory subGameIds, uint256[] memory poolIds)
        external
        onlyOperator
    {
        uint256 numSubGames = subGameIds.length;

        require(numSubGames > 0 && numSubGames == poolIds.length, "array length is invalid");

        Game storage game = _games[gameId];

        require(game.status == 0, "game was canceled or completed");

        require(game.endTime > 0, "can not select pool");

        for (uint256 i = 0; i < numSubGames; i++) {
            SubGame storage subGame = _subGames[gameId][subGameIds[i]];

            require(subGame.status == 0, "subgame was canceled");

            require(subGame.winningPool == 0, "subgame was completed");

            Pool[] storage pools = _pools[gameId][subGameIds[i]];

            uint256 numPools = pools.length;

            uint256 totalAmount = 0;

            for (uint256 j = 0; j < numPools; j++) {
                if (poolIds[i] == j) {
                    continue;
                }

                totalAmount += pools[j].totalDeposit;
            }

            Pool storage winningPool = _pools[gameId][subGameIds[i]][poolIds[i]];

            winningPool.totalReward = totalAmount;

            subGame.winningPool = poolIds[i] + 1;

            if (subGame.totalBankerFund > 0) {
                uint256 bankerFund = subGame.totalBankerFund / numPools;

                uint256 reward = winningPool.totalReward * bankerFund / winningPool.totalDeposit;

                payable(rug.getBankerAddress()).transfer(bankerFund + reward);
            }
        }

        game.status = GAME_COMPLETED;

        endedGames.push(gameId);

        emit logSportBetSelectPool(gameId, subGameIds, poolIds);

        SubGame[] storage subGames = _subGames[gameId];

        for (uint256 i = 0; i < subGames.length; i++) {
            SubGame storage subGame = subGames[i];

            if (subGame.status == 0) {
                require(subGame.winningPool != 0, "the winning pool is not selected");
            }
        }
    }

    function changeDepositFees(uint256 _operationFee, uint256 _jackpotFee, uint256 _bankerFee, uint256 _referralFee) external onlyOperator {
        if (operationFee != _operationFee) {
            operationFee = _operationFee;
        }

        if (jackpotFee != _jackpotFee) {
            jackpotFee = _jackpotFee;
        }

        if (bankerFee != _bankerFee) {
            bankerFee = _bankerFee;
        }

        if (referralFee != _referralFee) {
            referralFee = _referralFee;
        }

        require(operationFee + jackpotFee + bankerFee + referralFee <= ONE_HUNDRED_PERCENT, "fee is invalid");

        emit logSportBetChangeDepositFees(_operationFee, _jackpotFee, _bankerFee, _referralFee);
    }

    function getGameInfo(uint256 gameId) external view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
        Game memory game = _games[gameId];

        return (game.totalDeposit, _numSubGames[gameId], game.startTime, game.numParticipants, game.endTime, game.bettingTime, game.totalBankerFund, game.status, game.totalCommission, game.displayTime);
    }

    function getSubGameInfo(uint256 gameId, uint256 subGameId) external view returns(uint256, uint256, uint256, uint256, uint256, uint256) {
        SubGame memory subGame = _subGames[gameId][subGameId];

        return (subGame.totalDeposit, subGame.totalBankerFund, _numPools[gameId][subGameId], subGame.status, subGame.numParticipants, subGame.winningPool);
    }

    function getPoolInfo(uint256 gameId, uint256 subGameId, uint256 poolId) external view returns(uint256, uint256) {
        Pool storage pool = _pools[gameId][subGameId][poolId];

        return (pool.totalDeposit, pool.totalReward);
    }

    function getEstReward(uint256 gameId, address account) external view returns(uint256 reward) {
        Game memory game = _games[gameId];

        if (game.status != GAME_COMPLETED || isClaimed[account][gameId]["reward"]) {
            return 0;
        }

        SubGame[] memory subGames = _subGames[gameId];

        for (uint256 i = 0; i < subGames.length; i++) {
            SubGame memory subGame = subGames[i];

            if (subGame.status != 0) {
                continue;
            }

            uint256 poolId = subGame.winningPool - 1;

            uint256 amount = userDeposit[account][gameId][i][poolId];

            if (amount == 0 || _isClaimed[account][gameId][i][poolId]) {
                continue;
            }

            Pool memory pool = _pools[gameId][i][poolId];

            reward += (pool.totalReward * amount / pool.totalDeposit);
        }

        return reward;
    }

    function getListActiveGame() external view returns(uint256[] memory) {
       return activeGames;
    }

    function getListEndedGame() external view returns(uint256[] memory) {
        return endedGames;
    }

    function getListCanceledGame() external view returns(uint256[] memory) {
        return canceledGames;
    }

    function getWinningList(uint256 gameId,uint256 subGameId) external view returns(WinningInfo[] memory) {
        return winningList[gameId][subGameId];
    }

    function getWinningList(uint256 gameId) external view returns(WinningInfo2[] memory) {
        return winningList2[gameId];
    }

    function getListParticipatedGame(address account) external view returns(uint256[] memory) {
        return participatedGames[account];
    }

}