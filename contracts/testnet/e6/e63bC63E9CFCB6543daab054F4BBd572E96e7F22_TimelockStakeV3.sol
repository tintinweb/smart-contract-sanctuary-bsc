/**
 *Submitted for verification at BscScan.com on 2022-06-26
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

contract TimelockStakeV3
{
    uint256 private constant ONE_HUNDRED = 100**10; // 100000000000000000000;
    uint256 private constant ONE = 10**18;
    uint256 private constant ONE_YEAR = 31536000;
    bool private lockedOwner;

    address public owner;
    address public chainWrapToken;
    address public swapRouter;
    address public usdToken;
    address public platformToken;
    // uint public swapUsesMultihop;

    struct PowerUpRecord {
        uint256 multiply;
        uint durationInSeconds;
    }

    struct PowerUpDepositRecord {
        address powerToken;
        uint time;
    }

    struct PoweredUpRewardRecord {
        PowerUpDepositRecord deposit;
        uint256 rewardAmount;
    }

    struct PlayerStakeRecord {
        uint256 amountInRecord;
        uint startTime;
        uint endTime;
        uint lockedToWithdraw;
        uint256 earnedForNow;
        uint256 earnedForEnd;
        uint256 powerUpRewardPartForNow;
        PoweredUpRewardRecord[] powerUpListForNow;
    }

    struct InterestRewardRecord {
        uint256 annualReward;
        uint256 amountInYears;
        uint256 rewardBasedOnStakeToken;
        uint256 reward;
        uint256 powerUpReward;
        PoweredUpRewardRecord[] powerUpList;
    }

    struct PlayerCounter {
        uint stake;
        uint farm;
        uint applyStakePowerUp;
        uint applyFarmPowerUp;
        uint stakeWithdraw;
        uint farmWithdraw;
    }

    uint private poolSeed;
    uint[] private pools;
    mapping(uint => uint) private poolOffchainId;
    mapping(uint => address) private poolStakingToken;
    mapping(uint => address) private poolPrizeToken;
    mapping(uint => uint) private poolPeriod;
    mapping(uint => uint256) private poolAPR;
    mapping(uint => uint) private poolLocked;
    mapping(uint => uint) private poolDepositDisabled;
    mapping(uint => uint256) private poolStakedAmount;
    mapping(uint => address[]) private poolPlayers;
    mapping(uint => uint) private poolIsFarm;
    
    mapping(address => PowerUpRecord) private powerupTokenList; // Power-up token record by Token Address

    mapping(uint => mapping(address => uint)) private isPoolPlayer;

    mapping(uint => mapping(address => uint256)) private playerStakedAmount; // Total of staked
    mapping(uint => mapping(address => uint256[])) private playerStakeRecordAmount; // Amount of Stake record
    mapping(uint => mapping(address => uint[])) private playerStakeRecordStartTime; // End Date of Stake record
    mapping(uint => mapping(address => uint[])) private playerStakeRecordEndTime; // End Date of Stake record
    mapping(uint => mapping(address => mapping(uint => PowerUpDepositRecord[]))) private playerStakeDepositedPowerup; //Deposited Power-up (poolID => player => poolRecordIx => powerUPInfo)
    mapping(address => PlayerCounter) private playerCounter;

    event PlayerErase(uint stakeIndex, uint256 stakedAmount, uint256 rewardAtMoment, uint startTime, uint endTime);
    event OnwerChange(address indexed newValue);
    // event SwapUsesMultihopChange();
    event OnPowerUp(address player, address powerToken, uint poolID, uint poolRecordIx);

    constructor(address platformTokenAddress) 
    {
        require(platformTokenAddress != address(0), "INVD"); // INVD = Invalid Address

        owner = msg.sender;
        platformToken = platformTokenAddress;
        // swapUsesMultihop = 1;

        poolSeed = 1;

        /*
        56: WBNB
        137: WMATIC
        1: WETH9
        43114: WAVAX
        97: WBNB testnet
        */
        chainWrapToken = block.chainid == 56 ?  address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) : 
                    (block.chainid == 137 ?     address(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270) :
                    (block.chainid == 1 ?       address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2) : 
                    (block.chainid == 43114 ?   address(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7) : 
                    (block.chainid == 97 ?      address(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd) : 
                                                address(0) ) ) ) );

        /*
        56: PancakeFactory
        137: SushiSwap UniswapV2Router02
        1: UniswapV2Router02
        43114: Pangolin Router
        97: PancakeRouter testnet
        */
        swapRouter = block.chainid == 56 ?      address(0x10ED43C718714eb63d5aA57B78B54704E256024E) : 
                    (block.chainid == 137 ?     address(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506) : 
                    (block.chainid == 1 ?       address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D) : 
                    (block.chainid == 43114 ?   address(0x44771c71250D303d32E638c1c7ca7d00135cd65f) : 
                    (block.chainid == 97 ?      address(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3) : 
                                                address(0) ) ) ) );

        /*
        56: BUSD
        137: PUSD
        1: BUSD Ethereum
        43114: USDT
        97: BUSD testnet
        */
        usdToken = block.chainid == 56 ?        address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56) : 
                    (block.chainid == 137 ?     address(0x9aF3b7DC29D3C4B1A5731408B6A9656fA7aC3b72) : 
                    (block.chainid == 1 ?       address(0x4Fabb145d64652a948d72533023f6E7A623C7C53) : 
                    (block.chainid == 43114 ?   address(0xde3A24028580884448a5397872046a019649b084) : 
                    (block.chainid == 97 ?      address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee) : 
                                                address(0) ) ) ) );
    }

    modifier onlyOwner 
    {
        require(msg.sender == owner, 'FN'); //Forbidden
        _;
    }

    modifier noReentrancy() 
    {
        require(!lockedOwner, "NREE"); // No Reentrance

        lockedOwner = true;
        _;
        lockedOwner = false;
    }

    modifier validPool(uint poolID)
    {
        require(poolStakingToken[poolID] != address(0), "InvPId"); // Invalid Pool ID
        _;
    }

    modifier validAddress(address _address) 
    {
       require(_address != address(0), "INVD"); // INVD = Invalid Address
       _;
    }

    modifier validWallet
    {
        require( !Hlp.isContract(msg.sender), "CTR"); // CTR = Wallet is a contract
        require(tx.origin == msg.sender, "INVW"); // INVW = Invalid wallet origin
        _;
    }

    modifier poolValidLiquidity(address stakingToken, address prizeToken, uint isFarm)
    {
        uint platformVsWrapOK;
        uint platformVsStakingOK;
        uint platformVsPrizeOK;

        (platformVsWrapOK, platformVsStakingOK, platformVsPrizeOK) = hasLiquidityToCreatePool(stakingToken, prizeToken, isFarm);
        require(platformVsWrapOK == 1 && platformVsStakingOK == 1 && platformVsPrizeOK == 1, "ILIQ"); // ILIQ: Invalid Liquidity
        _;
    }


    /* *****************************
        POOL MANAGEMENT
    *  *****************************/
    function createPool(uint offchainId, address stakingToken, address prizeToken, uint period, uint256 apr, uint locked, uint isFarm) external onlyOwner noReentrancy validAddress(stakingToken) validAddress(prizeToken) poolValidLiquidity(stakingToken, prizeToken, isFarm)
    {
        uint poolID = poolSeed;
        poolSeed++;

        pools.push(poolID);

        poolOffchainId[poolID] = offchainId;
        poolStakingToken[poolID] = stakingToken;
        poolPrizeToken[poolID] = prizeToken;
        poolPeriod[poolID] = period;
        poolAPR[poolID] = apr;
        poolLocked[poolID] = locked;
        poolDepositDisabled[poolID] = 0;
        poolStakedAmount[poolID] = 0;
        poolIsFarm[poolID] = isFarm;
        delete poolPlayers[poolID]; //Clear array
    }

    function setPoolDisabledDeposit(uint poolID, uint disabledValue) external onlyOwner noReentrancy validPool(poolID)
    {        
        poolDepositDisabled[poolID] = disabledValue;
    }

    function setPoolOffchainId(uint poolID, uint offchainId) external onlyOwner noReentrancy validPool(poolID)
    {        
        poolOffchainId[poolID] = offchainId;
    }

    function destroyPool(uint poolID) external onlyOwner noReentrancy validPool(poolID)
    {        
        // Force Redeem/Withdraw
        for(uint ix = 0; ix < poolPlayers[poolID].length; ix++)
        {
            address player = poolPlayers[poolID][ix];
            uint256 amountToTransfer = playerStakedAmount[poolID][player];

            if(amountToTransfer > 0)
            {
                // Reset pool player status
                isPoolPlayer[poolID][player] = 0;
                playerStakedAmount[poolID][player] = 0;

                // Withdraw playerStakedAmount[poolID][player] to player
                bool txOk = IERC20(poolStakingToken[poolID]).transfer(player, amountToTransfer);
                require(txOk, "TXERR"); // TXERR = Transaction Error

                // Redeem tokens
                for(uint ixRecord = 0; ixRecord < playerStakeRecordAmount[poolID][player].length; ixRecord++)
                {
                    uint startTime = playerStakeRecordStartTime[poolID][player][ixRecord];
                    uint forcedEndTime = block.timestamp;
                    uint256 stakePeriod = forcedEndTime - startTime;
                    InterestRewardRecord memory irr = getInterestReward(poolID, playerStakeRecordAmount[poolID][player][ixRecord], poolAPR[poolID], stakePeriod, ixRecord, player);

                    // Clear player deposited powerup in this pool record
                    delete playerStakeDepositedPowerup[poolID][player][ixRecord];

                    if(poolPrizeToken[poolID] == platformToken)
                    {
                        bool txPrizeOk = IERC20(platformToken).transfer(player, irr.reward);
                        require(txPrizeOk, "PTXERR"); // PTXERR = Prize Transaction Error
                    }
                    else
                    {
                        uint256 redeemableInResultToken = getAmountOutMin(platformToken, poolPrizeToken[poolID], irr.reward);
                        internalSwap(platformToken, poolPrizeToken[poolID], irr.reward, redeemableInResultToken, player);
                    }
                }

                // Clear player stake records
                delete playerStakeRecordAmount[poolID][player];
                delete playerStakeRecordStartTime[poolID][player];
                delete playerStakeRecordEndTime[poolID][player];
            }
        }

        // Reset mapping values
        poolOffchainId[poolID] = 0;
        poolStakingToken[poolID] = address(0);
        poolPrizeToken[poolID] = address(0);
        poolPeriod[poolID] = 0;
        poolAPR[poolID] = 0;
        poolLocked[poolID] = 0;
        poolDepositDisabled[poolID] = 0;
        poolStakedAmount[poolID] = 0;
        poolIsFarm[poolID] = 0;
        delete poolPlayers[poolID]; //Clear array

        // Remove from pools array
        for(uint ixToRemove = 0; ixToRemove < pools.length; ixToRemove++)
        {
            if(pools[ixToRemove] == poolID)
            {
                //Swap index to last
                uint poolsCount = pools.length;
                if(poolsCount > 1)
                {
                    pools[ixToRemove] = pools[poolsCount - 1];
                }

                //Delete dirty last
                if(poolsCount > 0)
                {
                    pools.pop();
                }

                break;
            }
        }
    }

    function hasLiquidityToCreatePool(address stakingToken, address prizeToken, uint isFarm) public view returns (uint platformVsWrapOK, uint platformVsStakingOK, uint platformVsPrizeOK)
    {
        // LIQUIDITY REQUIREMENTS TO CREATE POOL
        // 1 - platform / chainWrapToken
        // 2 - platform / prize
        // 3 - platform / stake

        uint vPlatformVsWrapOK = 1; // OK
        uint vPlatformVsStakingOK = 1; // OK
        uint vPlatformVsPrizeOK = 1; // OK

        if(getLPPair(platformToken, chainWrapToken) == address(0))
        {
            vPlatformVsWrapOK = 0; // NOK
        }

        if(isFarm == 0)
        {
            if(platformToken != stakingToken)
            {
                if(getLPPair(platformToken, stakingToken) == address(0))
                {
                    vPlatformVsStakingOK = 0; // NOK
                }
            }
        }

        if(platformToken != prizeToken)
        {
            if(getLPPair(platformToken, prizeToken) == address(0))
            {
                vPlatformVsPrizeOK = 0; // NOK
            }
        }

        return (vPlatformVsWrapOK, vPlatformVsStakingOK, vPlatformVsPrizeOK);
    }

    /* *****************************
        POOL READING
    *  *****************************/
    function getVaultBalance(address token) external view returns (uint256)
    {
        return IERC20(token).balanceOf(address(this));
    }

    function getPoolsSize() external view returns (uint)
    {
        return pools.length;
    }

    function getPoolByIndex(uint poolIndex) external view returns (uint256[] memory numbers, address stakingToken, address prizeToken)
    {
        return getPool( pools[poolIndex] );
    }

    function getPool(uint poolID) public view validPool(poolID) returns (uint256[] memory numbers, address stakingToken, address prizeToken)
    {
        uint256[] memory resultNumbers = new uint256[](9);
        resultNumbers[0] = poolID; // Pool ID
        resultNumbers[1] = poolOffchainId[poolID]; // Offchain ID
        resultNumbers[2] = poolPeriod[poolID]; // Stake Period
        resultNumbers[3] = poolAPR[poolID]; // APR
        resultNumbers[4] = poolLocked[poolID]; // Locked Mode
        resultNumbers[5] = poolDepositDisabled[poolID]; // Deposit Disabled
        resultNumbers[6] = poolStakedAmount[poolID]; // Amount in stake
        resultNumbers[7] = poolPlayers[poolID].length; // Total of players
        resultNumbers[8] = poolIsFarm[poolID]; // Is Farm

        return (resultNumbers, poolStakingToken[poolID], poolPrizeToken[poolID]);
    }

    function getPlayerStake(uint poolID, address player) external view validPool(poolID) returns (uint256[] memory)
    {
        uint256[] memory resultNumbers = new uint256[](2);

        if(isPoolPlayer[poolID][player] == 0)
        {
            return resultNumbers;
        }

        resultNumbers[0] = playerStakedAmount[poolID][player]; // Total of staked
        resultNumbers[1] = playerStakeRecordAmount[poolID][player].length; // Total of stake records

        return resultNumbers;
    }

    function getPlayerStakeRecord(uint poolID, address player, uint index) external view validPool(poolID) returns (PlayerStakeRecord memory result)
    {
        PlayerStakeRecord memory vResult = PlayerStakeRecord({
            amountInRecord: 0,
            startTime: 0,
            endTime: 0,
            lockedToWithdraw: 0,
            earnedForNow: 0,
            earnedForEnd: 0,
            powerUpRewardPartForNow: 0,
            powerUpListForNow: new PoweredUpRewardRecord[](0)
        });

        if(isPoolPlayer[poolID][player] == 0)
        {
            return vResult;
        }

        if(playerStakeRecordAmount[poolID][player].length == 0)
        {
            return vResult;
        }

        vResult.amountInRecord = index < playerStakeRecordAmount[poolID][player].length ? playerStakeRecordAmount[poolID][player][index] : 0; // Amount in record
        vResult.startTime = index < playerStakeRecordStartTime[poolID][player].length ? playerStakeRecordStartTime[poolID][player][index] : 0; // Start time
        vResult.endTime = index < playerStakeRecordEndTime[poolID][player].length ? playerStakeRecordEndTime[poolID][player][index] : 0; // End time
        vResult.lockedToWithdraw = index < playerStakeRecordEndTime[poolID][player].length ? getPlayerStakeRecordLockedToWithdraw(poolID, player, index) : 1; // Locked to withdraw

        uint forcedEndTime = block.timestamp;
        
        InterestRewardRecord memory irrForNow = getInterestReward(poolID, playerStakeRecordAmount[poolID][player][index], poolAPR[poolID], (forcedEndTime - vResult.startTime), index, player);
        vResult.earnedForNow = irrForNow.reward;
        vResult.powerUpRewardPartForNow = irrForNow.powerUpReward;
        vResult.powerUpListForNow = irrForNow.powerUpList;

        InterestRewardRecord memory irrForEnd = getInterestReward(poolID, playerStakeRecordAmount[poolID][player][index], poolAPR[poolID], (vResult.endTime - vResult.startTime), index, player);
        vResult.earnedForEnd = irrForEnd.reward;

        return vResult;
    }

    function getPlayerStakeRecordLockedToWithdraw(uint poolID, address player, uint index) public view returns (uint)
    {
        if(poolLocked[poolID] == 0)
        {
            return 0;
        }

        uint expectedEndTime = playerStakeRecordEndTime[poolID][player][index];

        if(block.timestamp >= expectedEndTime)
        {
            return 0;
        }

        return 1;

    }

    function getPlayerIsInPool(uint poolID, address player) external view returns (uint)
    {
        return isPoolPlayer[poolID][player];
    }

    function getPoolPlayerByIndex(uint poolID, uint index) external view returns (address)
    {
        return poolPlayers[poolID][index];
    }

    function getInterestReward(uint poolID, uint256 stakedAmount, uint256 apr, uint stakePeriod, uint index, address player) internal view returns (InterestRewardRecord memory)
    {
        uint256 annualReward = (stakedAmount * apr) / ONE_HUNDRED;
        uint256 amountInYears = SafeMath.safeDivFloat(stakePeriod, ONE_YEAR, 18);
        uint256 rewardBasedOnStakeToken = SafeMath.safeMulFloat(annualReward, amountInYears, 18);

        uint256 reward;

        if(poolStakingToken[poolID] == platformToken)
        {
            reward = rewardBasedOnStakeToken;
        }
        else
        {
            if(poolIsFarm[poolID] == 0)
            {
                reward = getAmountOutMin(poolStakingToken[poolID], platformToken, rewardBasedOnStakeToken);
            }
            else
            {
                reward = getLPPrice(poolStakingToken[poolID], rewardBasedOnStakeToken, platformToken);
            }
        }

        (uint256 powerUpReward, PoweredUpRewardRecord[] memory powerUpList) = getPoweredUpReward(poolID, player, index, reward, stakePeriod);
        reward += powerUpReward;
        
        return InterestRewardRecord({
            annualReward: annualReward,
            amountInYears: amountInYears,
            rewardBasedOnStakeToken: rewardBasedOnStakeToken,
            reward: reward,
            powerUpReward: powerUpReward,
            powerUpList: powerUpList
        });
    }

    function getPoweredUpReward(uint poolID, address player, uint ixRecord, uint256 redeemableValue, uint256 stakePeriod) public view returns (uint256 amount, PoweredUpRewardRecord[] memory list)
    {
        PowerUpDepositRecord[] memory arrPowerUp = playerStakeDepositedPowerup[poolID][player][ixRecord];

        uint256 result = 0;
        PoweredUpRewardRecord[] memory resultList = new PoweredUpRewardRecord[](arrPowerUp.length);

        for(uint ix = 0; ix < arrPowerUp.length; ix++)
        {
            address powerUpToken = arrPowerUp[ix].powerToken;

            PowerUpRecord memory powerRecord = powerupTokenList[powerUpToken];
            
            uint256 weiToDeduct = (powerRecord.durationInSeconds * redeemableValue) / stakePeriod;
            uint256 weiToReplace = SafeMath.safeMulFloat(powerRecord.multiply, weiToDeduct, 18); // powerRecord.multiply is in WEI

            uint256 amountResultInRecord = weiToReplace - weiToDeduct;

            resultList[ix] = PoweredUpRewardRecord({
                deposit: arrPowerUp[ix], 
                rewardAmount: amountResultInRecord
            });

            result += amountResultInRecord;
        }

        return (result, resultList);
    }

    function getPlayerDepositedPowerUpCount(uint poolID, address player, uint ixRecord) external view returns (uint)
    {
        return playerStakeDepositedPowerup[poolID][player][ixRecord].length;
    }

    function getPlayerDepositedPowerUpInfo(uint poolID, address player, uint ixRecord, uint ixPowerUp) external view returns (PowerUpDepositRecord memory)
    {
        return playerStakeDepositedPowerup[poolID][player][ixRecord][ixPowerUp];
    }

    function getPlayerCounter(address player) external view returns (PlayerCounter memory)
    {
        return playerCounter[player];
    }

    /* *****************************
        POOL PLAYER SET
    *  *****************************/

    function poolStakeDepositUsingNetworkCoin(uint poolID) external validPool(poolID) validWallet payable
    {
        require(poolStakingToken[poolID] == chainWrapToken, "InvPoolToken"); // Invalid Pool Token

        poolStakeDepositInternal(poolID, msg.value, 1);
    }

    function poolStakeDeposit(uint poolID, uint amount) external validPool(poolID) validWallet
    {
        poolStakeDepositInternal(poolID, amount, 0);
    }

    function poolStakeDepositInternal(uint poolID, uint amount, uint UsingNetworkCoin) internal validPool(poolID) validWallet
    {
        require(poolPeriod[poolID] > 0, "InvPPeriod"); // Invalid Pool Period
        require(poolDepositDisabled[poolID] == 0, "Disabled"); // Pool Deposit Disabled 

        if(UsingNetworkCoin == 0)
        {
            require(IERC20(poolStakingToken[poolID]).balanceOf(msg.sender) >= amount, "INVALID_BALANCE");

            //Approve (outside): allowed[msg.sender][spender] (sender = my account, spender = stake token address)
            uint256 allowance = IERC20(poolStakingToken[poolID]).allowance(msg.sender, address(this));
            require(allowance >= amount, "AL"); //STAKE: Check the token allowance. Use approve function.
        }

        // Update Pool Information
        poolStakedAmount[poolID] = poolStakedAmount[poolID] + amount;

        // Update Player Information
        playerStakedAmount[poolID][msg.sender] = playerStakedAmount[poolID][msg.sender] + amount;

        // Record generation
        playerStakeRecordAmount[poolID][msg.sender].push(amount);
        playerStakeRecordStartTime[poolID][msg.sender].push(block.timestamp);
        playerStakeRecordEndTime[poolID][msg.sender].push( block.timestamp + poolPeriod[poolID] );

        // Set player as pool player
        if(isPoolPlayer[poolID][msg.sender] == 0)
        {
            poolPlayers[poolID].push(msg.sender);
            isPoolPlayer[poolID][msg.sender] = 1;
        }

        // Update Counter
        if(poolIsFarm[poolID] == 0)
        {
            playerCounter[msg.sender].stake++;
        }
        else
        {
            playerCounter[msg.sender].farm++;
        }

        if(UsingNetworkCoin == 0)
        {
            // Receive deposit token value
            bool txOk = IERC20(poolStakingToken[poolID]).transferFrom(msg.sender, address(this), amount);
            require(txOk, "TXERR"); // TXERR = Transaction Error
        }
    }

    function poolStakeWithdraw(uint poolID, uint poolRecordIndex) external validWallet
    {
        _poolStakeWithdraw(poolID, poolRecordIndex, msg.sender);
    }

    function _poolStakeWithdraw(uint poolID, uint poolRecordIndex, address player) internal validPool(poolID)
    {
        require(poolPeriod[poolID] > 0, "InvPPeriod"); // Invalid Pool Period
        require(isPoolPlayer[poolID][player] == 1, "NotInStake"); // Not in Stake
        require(playerStakeRecordAmount[poolID][player].length > 0, "NoRecords"); // No Stake Records
        require(poolRecordIndex < playerStakeRecordAmount[poolID][player].length, "InvIndex"); // Invalid Record Index

        uint256 amountToUnstake = playerStakeRecordAmount[poolID][player][poolRecordIndex];
        require(amountToUnstake > 0, "EmptyRecord"); // Empty Record

        uint expectedEndTime = playerStakeRecordEndTime[poolID][player][poolRecordIndex];
        if(poolLocked[poolID] == 1)
        {
            require(block.timestamp >= expectedEndTime, "Locked"); // Locked Stake Record
        }

        // Update Pool Information
        poolStakedAmount[poolID] = poolStakedAmount[poolID] - amountToUnstake;

        // Update Player Information
        playerStakedAmount[poolID][player] = playerStakedAmount[poolID][player] - amountToUnstake;

        // Get stake start time before record clean
        uint startTime = playerStakeRecordStartTime[poolID][player][poolRecordIndex];

        // Record removal
        removeStakeRecord(poolID, player, poolRecordIndex);

        // Remove user as player if user is no longer in pool stake
        if(playerStakeRecordAmount[poolID][player].length == 0)
        {
            isPoolPlayer[poolID][player] = 0;
            removePlayerFromPool(poolID, player);
        }

        // Withdraw amountToUnstake to player
        if(poolStakingToken[poolID] != chainWrapToken)
        {
            bool txOk = IERC20(poolStakingToken[poolID]).transfer(player, amountToUnstake);
            require(txOk, "TXERR"); // TXERR = Transaction Error
        }
        else
        {
            //Withdraw Network Coin
            payable(player).transfer(amountToUnstake);
        }

        // Redeem tokens
        uint occuredEndTime = block.timestamp;
        uint256 stakePeriod = occuredEndTime - startTime;

        InterestRewardRecord memory irr = getInterestReward(poolID, amountToUnstake, poolAPR[poolID], stakePeriod, poolRecordIndex, player);

        // Remove player powerup tokens applied in this record index
        delete playerStakeDepositedPowerup[poolID][player][poolRecordIndex];

        // Update Counter
        if(poolIsFarm[poolID] == 0)
        {
            playerCounter[player].stakeWithdraw++;
        }
        else
        {
            playerCounter[player].farmWithdraw++;
        }

        if(poolPrizeToken[poolID] == platformToken)
        {
            bool txPrizeOk = IERC20(platformToken).transfer(player, irr.reward);
            require(txPrizeOk, "PTXERR"); // PTXERR = Prize Transaction Error
        }
        else
        {
            uint256 redeemableInResultToken = getAmountOutMin(platformToken, poolPrizeToken[poolID], irr.reward);
            internalSwap(platformToken, poolPrizeToken[poolID], irr.reward, redeemableInResultToken, player);
        }

    }

    function powerUpDepositToStakePool(uint poolID, uint poolRecordIndex, address powerToken) external validPool(poolID) validAddress(powerToken) validWallet
    {
        require(poolPeriod[poolID] > 0, "InvPPeriod"); // Invalid Pool Period
        require(isPoolPlayer[poolID][msg.sender] == 1, "NotInStake"); // Not in Stake
        require(playerStakeRecordAmount[poolID][msg.sender].length > 0, "NoRecords"); // No Stake Records
        require(poolRecordIndex < playerStakeRecordAmount[poolID][msg.sender].length, "InvIndex"); // Invalid Record Index
        require(powerupTokenList[powerToken].multiply > 0 && powerupTokenList[powerToken].durationInSeconds > 0, "InvPT"); // Invalid powerup token

        require(IERC20(powerToken).allowance(msg.sender, address(this)) >= ONE, "PA"); // Check the Powerup Token allowance. Use approve function.
        require(IERC20(powerToken).balanceOf(msg.sender) >= ONE, "INVALID_BALANCE");

        playerStakeDepositedPowerup[poolID][msg.sender][poolRecordIndex].push(PowerUpDepositRecord({
            powerToken: address(powerToken),
            time: block.timestamp
        }));

        // Update Counter
        if(poolIsFarm[poolID] == 0)
        {
            playerCounter[msg.sender].applyStakePowerUp++;
        }
        else
        {
            playerCounter[msg.sender].applyFarmPowerUp++;
        }

        bool txOk = IERC20(powerToken).transferFrom(msg.sender, address(this), ONE);
        require(txOk, "TXERR"); // TXERR = Transaction Error

        emit OnPowerUp(msg.sender, powerToken, poolID, poolRecordIndex);
    }

    function removeStakeRecord(uint poolID, address player, uint index) internal
    {
        uint count = playerStakeRecordAmount[poolID][player].length;

        // ***** REMOVE playerStakeRecordAmount record
        // Swap index to last
        if(count > 1)
        {
            playerStakeRecordAmount[poolID][player][index] = playerStakeRecordAmount[poolID][player][count - 1];
            playerStakeRecordStartTime[poolID][player][index] = playerStakeRecordStartTime[poolID][player][count - 1];
            playerStakeRecordEndTime[poolID][player][index] = playerStakeRecordEndTime[poolID][player][count - 1];
        }

        // Delete dirty last
        if(count > 0)
        {
            playerStakeRecordAmount[poolID][player].pop();
            playerStakeRecordStartTime[poolID][player].pop();
            playerStakeRecordEndTime[poolID][player].pop();
        }
    }

    function removePlayerFromPool(uint poolID, address player) internal
    {
        uint count = poolPlayers[poolID].length;

        for(uint ix = 0; ix < count; ix++)
        {
            if(poolPlayers[poolID][ix] == player)
            {
                // Swap index to last
                if(count > 1)
                {
                    poolPlayers[poolID][ix] = poolPlayers[poolID][count - 1];
                }

                // Delete dirty last
                if(count > 0)
                {
                    poolPlayers[poolID].pop();
                }

                break;
            }
        }
    }

    /* *****************************
        SUDO
    *  *****************************/

    function forcePlayerToWithdraw(uint poolID, uint poolRecordIndex, address player) external onlyOwner noReentrancy validAddress(player)
    {
        _poolStakeWithdraw(poolID, poolRecordIndex, player);
    }

    function forcePlayerToWithdrawWholePool(uint poolID, address player) external onlyOwner noReentrancy validAddress(player)
    {
        uint poolSize = playerStakeRecordAmount[poolID][player].length;

        if(poolSize == 0)
        {
            return;
        }

        for(uint ixRecord = 0; ixRecord < poolSize; ixRecord++)
        {
            _poolStakeWithdraw(poolID, 0, player); //Always remove from first (zero index)
        }
    }

    function transferFund(address token, address to, uint256 amountInWei) external onlyOwner noReentrancy validAddress(token) validAddress(to)
    {
        //Withdraw token
        bool txOk = IERC20(token).transfer(to, amountInWei);
        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function transferNetworkCoinFund(address to, uint256 amountInWei) external onlyOwner noReentrancy validAddress(to)
    {
        //Withdraw Network Coin
        payable(to).transfer(amountInWei);
    }

    function erasePlayerDataInPool(uint poolID, address player) external onlyOwner noReentrancy validAddress(player)
    {
        // Write player status log
        uint poolSize = playerStakeRecordAmount[poolID][player].length;
        if(poolSize > 0)
        {
            for(uint ixRecord = 0; ixRecord < poolSize; ixRecord++)
            {
                uint startTime = playerStakeRecordStartTime[poolID][player][ixRecord];
                uint occuredEndTime = block.timestamp;
                uint256 stakePeriod = occuredEndTime - startTime;

                InterestRewardRecord memory irr = getInterestReward(poolID, playerStakeRecordAmount[poolID][player][ixRecord], poolAPR[poolID], stakePeriod, ixRecord, player);
                emit PlayerErase(ixRecord, playerStakeRecordAmount[poolID][player][ixRecord], irr.reward, startTime, occuredEndTime);
            }
        }
        
        poolStakedAmount[poolID] = poolStakedAmount[poolID] - playerStakedAmount[poolID][player];

        // Reset pool player status
        isPoolPlayer[poolID][player] = 0;
        playerStakedAmount[poolID][player] = 0;

        // Clear player stake records
        delete playerStakeRecordAmount[poolID][player];
        delete playerStakeRecordStartTime[poolID][player];
        delete playerStakeRecordEndTime[poolID][player];

        // Remove user from pool player list
        removePlayerFromPool(poolID, player);
    }


    /* *****************************
            COMMON FUNCTIONS
    *  *****************************/
    function setOwner(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        owner = newValue;
        emit OnwerChange(newValue);
    }

    function setPlatformToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        platformToken = newValue;
    }

    // function setSwapUsesMultihop(uint newValue) external onlyOwner noReentrancy
    // {
    //     swapUsesMultihop = newValue;
    //     emit SwapUsesMultihopChange();
    // }

    function setChainWrapToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        chainWrapToken = newValue;
    }

    function setSwapRouter(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        swapRouter = newValue;
    }

    function setUSDToken(address newValue) external onlyOwner noReentrancy validAddress(newValue)
    {
        usdToken = newValue;
    }

    function setPowerUpToken(address powerToken, uint256 multiply, uint durationInSeconds) external onlyOwner noReentrancy validAddress(powerToken)
    {
        powerupTokenList[powerToken].multiply = multiply; // multiply is in WEI
        powerupTokenList[powerToken].durationInSeconds = durationInSeconds;
    }

    function getPowerUpTokenInfo(address powerToken) external view returns (PowerUpRecord memory)
    {
        return powerupTokenList[powerToken];
    }

    /* **********************************************************
            SWAP FUNCTIONS
    *  **********************************************************/

    // function getUSDPrice(address token, uint256 amount, uint multihopWithWrapToken) external view returns (uint256)
    function getUSDPrice(address token, uint256 amount) external view returns (uint256)
    {
        // uint256 result = getAmountOutMin(token, usdToken, amount, multihopWithWrapToken);
        uint256 result = getAmountOutMin(token, usdToken, amount);
        return result;
    }

    // function getAmountOutMin(address tokenIn, address tokenOut, uint256 amountIn, uint multihopWithWrapToken) public view returns (uint256) 
    function getAmountOutMin(address tokenIn, address tokenOut, uint256 amountIn) public view returns (uint256) 
    {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;

        // if (tokenIn == chainWrapToken || tokenOut == chainWrapToken || multihopWithWrapToken == 0) 
        // {
        //     path = new address[](2);
        //     path[0] = tokenIn;
        //     path[1] = tokenOut;
        // } 
        // else 
        // {
        //     path = new address[](3);
        //     path[0] = tokenIn;
        //     path[1] = chainWrapToken;
        //     path[2] = tokenOut;
        // }
        
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;


        uint256[] memory amountOutMins = IUniswapV2Router(swapRouter).getAmountsOut(amountIn, path);
        return amountOutMins[path.length -1];  
    }

    // function internalSwap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, address to, uint multihopWithWrapToken) private returns (uint[] memory amounts)
    function internalSwap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, address to) private returns (uint[] memory amounts)
    {
        if(tokenIn != chainWrapToken)
        {
            require( IERC20(tokenIn).balanceOf( address(this) ) >= amountIn, "LOWSWAPBALANCE" ); //Low balance before swap

            // We need to allow the uniswapv2 router to spend the token we just sent to this contract
            // by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
            bool approveOK = IERC20(tokenIn).approve(swapRouter, amountIn);
            require(approveOK, "APPR"); // APPR: Approval Error
        }

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;

        // if (tokenIn == chainWrapToken || tokenOut == chainWrapToken || multihopWithWrapToken == 0) 
        // {
        //     path = new address[](2);
        //     path[0] = tokenIn;
        //     path[1] = tokenOut;
        // } 
        // else 
        // {
        //     path = new address[](3);
        //     path[0] = tokenIn;
        //     path[1] = chainWrapToken;
        //     path[2] = tokenOut;
        // }

        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        if (tokenOut == chainWrapToken)
        {
            return IUniswapV2Router(swapRouter).swapExactTokensForETH(amountIn, amountOutMin, path, to, block.timestamp);
        }
        else
        {
            return IUniswapV2Router(swapRouter).swapExactTokensForTokens(amountIn, amountOutMin, path, to, block.timestamp);
        }
    }

    function getLPPair(address tokenA, address tokenB) internal view returns (address lpPair)
    {
        address factory = IUniswapV2Router(swapRouter).factory();
        address lpPairAddress = IUniswapV2Factory(factory).getPair(tokenA, tokenB);
        return lpPairAddress;
    }

    function getLPPrice(address lpToken, uint256 amountOfLPToken, address priceInToken) internal view returns (uint256 result)
    {
        uint lpDecimals = IERC20(lpToken).decimals();
        address token0 = IUniswapV2Pair(lpToken).token0();
        address token1 = IUniswapV2Pair(lpToken).token1();
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(lpToken).getReserves();

        uint256 reserve0Price;
        uint256 reserve1Price;

        if(token0 != priceInToken)
        {
            reserve0Price = getAmountOutMin(token0, priceInToken, reserve0);
        }
        else
        {
            reserve0Price = reserve0;
        }

        if(token1 != priceInToken)
        {
            reserve1Price = getAmountOutMin(token1, priceInToken, reserve1);
        }
        else
        {
            reserve1Price = reserve1;
        }

        uint256 LPUnitPrice = reserve0Price + reserve1Price;
        uint256 amountPrice = SafeMath.safeMulFloat(LPUnitPrice, amountOfLPToken, lpDecimals);
        return amountPrice;
    }

}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(address indexed sender, uint256 amount0, uint256 amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
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
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function getAmountsOut(uint256 amountIn, address[] memory path) external view returns (uint256[] memory amounts);
  
    function swapExactTokensForTokens(
        //amount of tokens we are sending in
        uint256 amountIn,
        
        //the minimum amount of tokens we want out of the trade
        uint256 amountOutMin,
    
        //list of token addresses we are going to trade in.  this is necessary to calculate amounts
        address[] calldata path,
    
        //this is the address we are going to send the output tokens to
        address to,
    
        //the last time that the trade is valid for
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, uint deadline
    ) external returns (uint[] memory amounts);
}

library SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        if (a == 0) 
        {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "OMUL"); //STAKE: multiplication overflow

        return c;
    }

    function safeMulFloat(uint256 a, uint256 b, uint decimals) internal pure returns(uint256)
    {
        if (a == 0 || decimals == 0)  
        {
            return 0;
        }

        uint result = safeDiv(safeMul(a, b), safePow(10, uint256(decimals)));

        return result;
    }

    function safePow(uint256 n, uint256 e) internal pure returns(uint256)
    {

        if (e == 0) 
        {
            return 1;
        } 
        else if (e == 1) 
        {
            return n;
        } 
        else 
        {
            uint256 p = safePow(n,  safeDiv(e, 2));
            p = safeMul(p, p);

            if (safeMod(e, 2) == 1) 
            {
                p = safeMul(p, n);
            }

            return p;
        }
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return safeDiv(a, b, "ZDIV"); //STAKE: division by zero
    }

    function safeDiv(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function safeDivFloat(uint256 a, uint256 b, uint256 decimals) internal pure returns (uint256)
    {
        return safeDiv(safeMul(a, safePow(10,decimals)), b);
    }

    function safeMod(uint256 a, uint256 b) internal pure returns (uint256) 
    {
        return safeMod(a, b, "ZMOD"); //STAKE: modulo by zero
    }

    function safeMod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) 
    {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// ****************************************************
// ***************** HELPER FUNCTIONS *****************
// ****************************************************
library Hlp 
{
    function isContract(address account) internal view returns (bool) 
    {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}