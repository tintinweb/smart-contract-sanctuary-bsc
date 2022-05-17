/**
 *Submitted for verification at BscScan.com on 2022-05-16
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract XoomVirtualStake {
    uint public constant DAPP_ID = 5;
    uint public constant FUNCTION_ID_START = 1;
    uint public constant FUNCTION_ID_CHECKPOINT = 2;
    uint public constant FUNCTION_ID_CLAIM = 3;
    uint256 private constant ONE_HUNDRED = 100**10; // 100000000000000000000;
    uint private constant ONE_YEAR = 365*24*60*60;

    uint256 private constant OWNER_NOT_ENTERED = 1;
    uint256 private constant OWNER_ENTERED = 2;
    uint256 private reentrancyForOwnerStatus;

    address public metersAddress;
    address public platformToken;
    uint public liquidityPriceUsingMultihop = 1;
    address public swapRouter;
    address public chainWrapToken;

    uint public stakeSeed = 0;
    mapping(uint => uint256) private stakeAPR;
    mapping(uint => address) private stakeToken;
    mapping(uint => address) private stakeRewardToken;
    mapping(uint => uint256) private stakeMinRequiredBalanceToKeep;
    mapping(uint => uint) private stakeCheckpointFrequency;
    mapping(uint => uint) private stakeCheckpointWaitTime;
    mapping(uint => uint) private stakeLockTime;
    mapping(uint => uint) private stakeActive;

    // Player structure StakeID => Player => Info
    mapping(uint => mapping(address => uint)) private playerLastCheckpoint;
    mapping(uint => mapping(address => uint)) private playerNextCheckpoint;
    mapping(uint => mapping(address => uint)) private playerNextCheckpointLimit;
    mapping(uint => mapping(address => uint)) private playerEndStakeTime;
    mapping(uint => mapping(address => uint256)) private playerLastBalance;
    mapping(uint => mapping(address => uint256)) private playerAccumulated;
    mapping(uint => mapping(address => uint)) private playerReleaseAccumulated;


    struct PlayerStakeDateRecord {
        uint lastCheckpoint;
        uint nextCheckpoint;
        uint nextCheckpointLimit;
        uint endStakeTime;
        uint256 lastBalance;
        uint256 accumulated;
        uint releaseAccumulated;
    }

    event MetersAddressChange(address value);
    event PlatformTokenChange(address value);
    event LiquidityPriceUseMultihopChange(uint value);
    event SwapRouterChange(address value);
    event StakeSet(uint stakeID, uint256 apr, address token, address rewardToken);
    event PlayerStart(uint stakeID, address player);
    event PlayerCheckpoint(uint stakeID, address player);
    event PlayerClaim(uint stakeID, address player);
    event SudoChangePlayerStake(uint stakeID, address player);
    event SudoTransferFund(address token, address to, uint256 amountInWei);
    event SudoTransferNetworkCoinFund(address to, uint256 amountInWei);

    constructor(address _metersAddress, address _platformToken)
    {
        require(_metersAddress != address(0), "INVMETERS"); // INVMETERS = Invalid Meters Address
        require(_platformToken != address(0), "INVPLATTOK"); // INVPLATTOK = Invalid Platform Token

        metersAddress = _metersAddress;
        platformToken = _platformToken;
        reentrancyForOwnerStatus = OWNER_NOT_ENTERED;

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
    }

    modifier validateAllowed
    {
        require(IMeters(metersAddress).addressIsAllowed(address(this)) == 1, 'CNA'); // CNA = Contract Not Allowed
        _;
    }

    modifier onlyOwner
    {
        require(msg.sender == IMeters(metersAddress).getOwner(), 'FN'); // FN = Forbidden
        _;
    }

    modifier noReentrancyForOwner
    {
        require(reentrancyForOwnerStatus != OWNER_ENTERED, "REE"); // REE = Reentrancy Locked
        reentrancyForOwnerStatus = OWNER_ENTERED;
        _;
        reentrancyForOwnerStatus = OWNER_NOT_ENTERED;
    }

    modifier validAddress(address _address) 
    {
       require(_address != address(0), "INVAD"); // INVAD = Invalid Address
       _;
    }

    modifier validWallet
    {
        require( !Hlp.isContract(msg.sender), "CTR"); // CTR = Wallet is a contract
        require(tx.origin == msg.sender, "INVW"); // INVW = Invalid wallet origin
        _;
    }

    modifier activeStake(uint stakeID)
    {
        require(stakeActive[stakeID] == 1, "INAC"); // Inactive Stake
        _;
    }

    modifier validRequirements(uint functionId)
    {
        require(functionId == FUNCTION_ID_START || functionId == FUNCTION_ID_CHECKPOINT || functionId == FUNCTION_ID_CLAIM, "INVF"); // Invalid Function
        require(IMeters(metersAddress).validateRequirement(DAPP_ID, functionId, msg.sender) == 1, "REQC"); // REQC = Requirements to complete
        _;
    }

    modifier hasMinBalanceToKeep(uint stakeID)
    {
        uint256 playerTokenBalance = IERC20(stakeToken[stakeID]).balanceOf(msg.sender);
        require(playerTokenBalance >= stakeMinRequiredBalanceToKeep[stakeID], "LOWBAL"); // LOWBAL = Low Balance
        _;
    }

    modifier checkpointValidate(uint stakeID)
    {
        require(playerLastCheckpoint[stakeID][msg.sender] > 0, "NSS"); // NSS = Not Started Stake
        // uint timeDiff = block.timestamp - playerLastCheckpoint[stakeID][msg.sender];
        require(block.timestamp >= playerNextCheckpoint[stakeID][msg.sender], "TOOEARLY"); // TOOEARLY = Too Early to Checkpoint
        require(block.timestamp <= playerNextCheckpointLimit[stakeID][msg.sender], "CHKEXPIRED"); // CHKEXPIRED = Checkpoint Expired
        require(playerReleaseAccumulated[stakeID][msg.sender] == 0, "UNLOCKED"); // UNLOCKED = You have balance to claim
        _;
    }

    modifier claimValidate(uint stakeID)
    {
        require(block.timestamp >= playerEndStakeTime[stakeID][msg.sender], "TOOEARLYC"); // TOOEARLYC = Too Early to Claim
        require(playerReleaseAccumulated[stakeID][msg.sender] == 1, "LOCKED"); // LOCKED = No balance to claim
        require(IERC20(platformToken).balanceOf(address(this)) >= playerAccumulated[stakeID][msg.sender], "LOWSUPP"); // LOWSUPP = Low Supply
        _;
    }

    function setMetersAddress(address value) external onlyOwner noReentrancyForOwner validAddress(value) validWallet
    {
        metersAddress = value;
        emit MetersAddressChange(value);
    }

    function setPlatformToken(address value) external onlyOwner noReentrancyForOwner validAddress(value) validWallet
    {
        platformToken = value;
        emit PlatformTokenChange(value);
    }

    function setLiquidityPriceUseMultihop(uint value) external onlyOwner noReentrancyForOwner validWallet
    {
        liquidityPriceUsingMultihop = value;
        emit LiquidityPriceUseMultihopChange(value);
    }

    function setSwapRouter(address value) external onlyOwner noReentrancyForOwner validWallet validAddress(value)
    {
        swapRouter = value;
        emit SwapRouterChange(value);
    }

    function registerStake(uint256 apr, address token, address rewardToken, uint256 minRequiredBalanceToKeep, uint checkpointFrequency, uint checkpointWaitTime, uint lockTime) external onlyOwner noReentrancyForOwner validateAllowed validAddress(token) validAddress(rewardToken) validWallet
    {
        stakeSeed++;
        uint stakeID = stakeSeed;
        setStakeData(stakeID, apr, token, rewardToken, minRequiredBalanceToKeep, checkpointFrequency, checkpointWaitTime, lockTime);
        stakeActive[stakeID] = 1;
    }

    function setInactiveActive(uint stakeID, uint value) external onlyOwner noReentrancyForOwner validateAllowed validWallet 
    {
        stakeActive[stakeID] = value;
    }

    function setStake(uint stakeID, uint256 apr, address token, address rewardToken, uint256 minRequiredBalanceToKeep, uint checkpointFrequency, uint checkpointWaitTime, uint lockTime) external onlyOwner noReentrancyForOwner validateAllowed validAddress(token) validAddress(rewardToken) validWallet
    {
        setStakeData(stakeID, apr, token, rewardToken, minRequiredBalanceToKeep, checkpointFrequency, checkpointWaitTime, lockTime);
        emit StakeSet(stakeID, apr, token, rewardToken);
    }

    function setStakeData(uint stakeID, uint256 apr, address token, address rewardToken, uint256 minRequiredBalanceToKeep, uint checkpointFrequency, uint checkpointWaitTime, uint lockTime) internal
    {
        stakeAPR[stakeID] = apr;
        stakeToken[stakeID] = token;
        stakeRewardToken[stakeID] = rewardToken;
        stakeMinRequiredBalanceToKeep[stakeID] = minRequiredBalanceToKeep;
        stakeCheckpointFrequency[stakeID] = checkpointFrequency;
        stakeCheckpointWaitTime[stakeID] = checkpointWaitTime;
        stakeLockTime[stakeID] = lockTime;
    }

    function getStake(uint stakeID) external view returns (uint256 apr, address token, address rewardToken, uint256 minRequiredBalanceToKeep, uint checkpointFrequency, uint checkpointWaitTime, uint lockTime)
    {
        return (
            stakeAPR[stakeID], 
            stakeToken[stakeID], 
            stakeRewardToken[stakeID], 
            stakeMinRequiredBalanceToKeep[stakeID], 
            stakeCheckpointFrequency[stakeID], 
            stakeCheckpointWaitTime[stakeID], 
            stakeLockTime[stakeID]
        );
    }

    function getPlayerStakeData(uint stakeID, address player) external view returns (PlayerStakeDateRecord memory result)
    {
        PlayerStakeDateRecord memory record = PlayerStakeDateRecord(
            playerLastCheckpoint[stakeID][player],
            playerNextCheckpoint[stakeID][player],
            playerNextCheckpointLimit[stakeID][player],
            playerEndStakeTime[stakeID][player],
            playerLastBalance[stakeID][player],
            playerAccumulated[stakeID][player],
            playerReleaseAccumulated[stakeID][player]
        );
        
        return record;
    }

    function start(uint stakeID) external validateAllowed validWallet activeStake(stakeID) validRequirements(FUNCTION_ID_START) hasMinBalanceToKeep(stakeID)
    {
        setCheckpointState(stakeID);

        playerEndStakeTime[stakeID][msg.sender] = block.timestamp + stakeLockTime[stakeID];
        playerAccumulated[stakeID][msg.sender] = 0;
        playerReleaseAccumulated[stakeID][msg.sender] = 0;

        emit PlayerStart(stakeID, msg.sender);

        // Set Score
        IMeters(metersAddress).addScoreAndCounter(msg.sender, DAPP_ID, FUNCTION_ID_START);
    }

    function checkpoint(uint stakeID) external validateAllowed validWallet activeStake(stakeID) validRequirements(FUNCTION_ID_CHECKPOINT) hasMinBalanceToKeep(stakeID) checkpointValidate(stakeID)
    {
        setCheckpointState(stakeID);

        uint256 earnAtCheckpoint = getNextCheckpointReward(stakeID, msg.sender);
        playerAccumulated[stakeID][msg.sender] += earnAtCheckpoint;

        if(block.timestamp >= playerEndStakeTime[stakeID][msg.sender])
        {
            playerReleaseAccumulated[stakeID][msg.sender] = 1;
        }

        emit PlayerCheckpoint(stakeID, msg.sender);

        // Set Score
        IMeters(metersAddress).addScoreAndCounter(msg.sender, DAPP_ID, FUNCTION_ID_CHECKPOINT);
    }

    function claim(uint stakeID) external validateAllowed validWallet activeStake(stakeID) validRequirements(FUNCTION_ID_CLAIM) claimValidate(stakeID)
    {
        uint256 accumulated = playerAccumulated[stakeID][msg.sender];
        uint256 reward = 0;
        address rewardToken = stakeRewardToken[stakeID];

        uint transferUsingSwap = 0;

        if(rewardToken == platformToken)
        {
            reward = accumulated;
        }
        else
        {
            reward = getAmountOutMin(platformToken, rewardToken, accumulated, liquidityPriceUsingMultihop);
            transferUsingSwap = 1;
        }

        // Clear player record
        playerAccumulated[stakeID][msg.sender] = 0;
        playerReleaseAccumulated[stakeID][msg.sender] = 0;
        playerEndStakeTime[stakeID][msg.sender] = 0;
        playerLastCheckpoint[stakeID][msg.sender] = 0;
        playerNextCheckpoint[stakeID][msg.sender] = 0;
        playerNextCheckpointLimit[stakeID][msg.sender] = 0;
        playerLastBalance[stakeID][msg.sender] = 0;

        emit PlayerClaim(stakeID, msg.sender);

        // Set Score
        IMeters(metersAddress).addScoreAndCounter(msg.sender, DAPP_ID, FUNCTION_ID_CLAIM);

        // Transfer at end
        if(transferUsingSwap == 0)
        {
            bool txOk = IERC20(rewardToken).transfer(msg.sender, reward);
            require(txOk, "TXERR"); // TXERR = Transaction Error
        }
        else
        {
            internalSwap(platformToken, rewardToken, accumulated, reward, msg.sender, liquidityPriceUsingMultihop);
        }
    }

    function setCheckpointState(uint stakeID) internal
    {
        playerLastCheckpoint[stakeID][msg.sender] = block.timestamp;
        playerNextCheckpoint[stakeID][msg.sender] = block.timestamp + stakeCheckpointFrequency[stakeID];
        playerNextCheckpointLimit[stakeID][msg.sender] = block.timestamp + stakeCheckpointFrequency[stakeID] + stakeCheckpointWaitTime[stakeID];
        playerLastBalance[stakeID][msg.sender] = IERC20(stakeToken[stakeID]).balanceOf(msg.sender);
    }

    function getNextCheckpointReward(uint stakeID, address player) public view returns (uint256)
    {
        address tokenToValidateCheckpoint = stakeToken[stakeID];
        uint256 playerTokenBalance = IERC20(tokenToValidateCheckpoint).balanceOf(player);
        uint256 annualForecast = (playerTokenBalance * stakeAPR[stakeID]) / ONE_HUNDRED;
        uint amountOfCheckpointsInOneYear = ONE_YEAR / stakeCheckpointFrequency[stakeID];
        uint256 earnAtCheckpointInStakeToken = annualForecast / amountOfCheckpointsInOneYear;
        uint earnAtCheckpointInPlatformToken = 0;

        if(tokenToValidateCheckpoint == platformToken)
        {
            earnAtCheckpointInPlatformToken = earnAtCheckpointInStakeToken;
        }
        else
        {
            earnAtCheckpointInPlatformToken = getAmountOutMin(tokenToValidateCheckpoint, platformToken, earnAtCheckpointInStakeToken, liquidityPriceUsingMultihop);
        }

        return earnAtCheckpointInPlatformToken;
    }

    function isOpenToStart(uint stakeID, address player) external view returns (uint result, uint response)
    {
        uint256 playerTokenBalance = IERC20(stakeToken[stakeID]).balanceOf(player);
        if(playerTokenBalance < stakeMinRequiredBalanceToKeep[stakeID])
        {
            // Low Balance
            return (0, 1);
        }

        if(IMeters(metersAddress).validateRequirement(DAPP_ID, FUNCTION_ID_START, player) == 0)
        {
            // Unmet requirements
            return (0, 2);
        }

        return (1, 0);
    }

    function isOpenToCheckpoint(uint stakeID, address player) external view returns (uint result, uint response)
    {
        if(playerLastCheckpoint[stakeID][player] == 0)
        {
            // Not Started Stake
            return (0, 1);
        }
        
        if(block.timestamp < playerNextCheckpoint[stakeID][player])
        {
            // Too Early to Checkpoint
            return (0, 2);
        }

        if(block.timestamp > playerNextCheckpointLimit[stakeID][player])
        {
            // Checkpoint Expired
            return (0, 3);
        }

        if(playerReleaseAccumulated[stakeID][player] > 0)
        {
            // You have balance to claim
            return (0, 5);
        }

        if(stakeActive[stakeID] == 0)
        {
            // Inactive Stake
            return (0, 6);
        }

        if(IMeters(metersAddress).validateRequirement(DAPP_ID, FUNCTION_ID_CHECKPOINT, player) == 0)
        {
            // Unmet requirements
            return (0, 7);
        }
        
        return (1, 0);
    }

    function isOpenToClaim(uint stakeID, address player) external view returns (uint result, uint response)
    {
        if(block.timestamp < playerEndStakeTime[stakeID][player])
        {
            // Too Early to Claim
            return (0, 1);
        }
        
        if(playerReleaseAccumulated[stakeID][player] == 0)
        {
            // No balance to claim
            return (0, 2);
        }

        if(IERC20(platformToken).balanceOf(address(this)) < playerAccumulated[stakeID][player])
        {
            // Low Supply
            return (0, 3);
        }

        uint256 playerTokenBalance = IERC20(stakeToken[stakeID]).balanceOf(player);
        if(playerTokenBalance < stakeMinRequiredBalanceToKeep[stakeID])
        {
            // Low Balance
            return (0, 5);
        }


        if(stakeActive[stakeID] == 0)
        {
            // Inactive Stake
            return (0, 6);
        }

        if(IMeters(metersAddress).validateRequirement(DAPP_ID, FUNCTION_ID_CLAIM, player) == 0)
        {
            // Unmet requirements
            return (0, 7);
        }
        
        return (1, 0);
    }

    function getAmountOutMin(address tokenIn, address tokenOut, uint256 amountIn, uint multihopWithWrapToken) public view returns (uint256) 
    {

       //path is an array of addresses.
       //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
       //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;
        if (tokenIn == chainWrapToken || tokenOut == chainWrapToken || multihopWithWrapToken == 0) 
        {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        } 
        else 
        {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = chainWrapToken;
            path[2] = tokenOut;
        }
        
        uint256[] memory amountOutMins = IUniswapV2Router(swapRouter).getAmountsOut(amountIn, path);
        return amountOutMins[path.length -1];  
    }

    function internalSwap(address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOutMin, address to, uint multihopWithWrapToken) private 
    {
        if(tokenIn != chainWrapToken)
        {
            require( IERC20(tokenIn).balanceOf( address(this) ) >= amountIn, "LOWSWAPBALANCE" ); //Low balance before swap

            // We need to allow the uniswapv2 router to spend the token we just sent to this contract
            // by calling IERC20 approve you allow the uniswap contract to spend the tokens in this contract 
            IERC20(tokenIn).approve(swapRouter, amountIn);
        }

        //path is an array of addresses.
        //this path array will have 3 addresses [tokenIn, WETH, tokenOut]
        //the if statement below takes into account if token in or token out is WETH.  then the path is only 2 addresses
        address[] memory path;

        if (tokenIn == chainWrapToken || tokenOut == chainWrapToken || multihopWithWrapToken == 0) 
        {
            path = new address[](2);
            path[0] = tokenIn;
            path[1] = tokenOut;
        } 
        else 
        {
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = chainWrapToken;
            path[2] = tokenOut;
        }

        //then we will call swapExactTokensForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        if (tokenOut == chainWrapToken)
        {
            IUniswapV2Router(swapRouter).swapExactTokensForETH(amountIn, amountOutMin, path, to, block.timestamp);
        }
        else
        {
            IUniswapV2Router(swapRouter).swapExactTokensForTokens(amountIn, amountOutMin, path, to, block.timestamp);
        }

    }

    /* *****************************
        SUDO
    *  *****************************/

    function changePlayerStake(uint stakeID, address player, uint lastCheckpoint, uint nextCheckpoint, uint nextCheckpointLimit, uint endStakeTime, uint256 lastBalance, uint256 accumulated, uint releaseAccumulated) external onlyOwner noReentrancyForOwner validAddress(player) validWallet
    {
        playerLastCheckpoint[stakeID][player] = lastCheckpoint;
        playerNextCheckpoint[stakeID][player] = nextCheckpoint;
        playerNextCheckpointLimit[stakeID][player] = nextCheckpointLimit;
        playerEndStakeTime[stakeID][player] = endStakeTime;
        playerLastBalance[stakeID][player] = lastBalance;
        playerAccumulated[stakeID][player] = accumulated;
        playerReleaseAccumulated[stakeID][player] = releaseAccumulated;

        emit SudoChangePlayerStake(stakeID, player);
    }

    function transferFund(address token, address to, uint256 amountInWei) external onlyOwner noReentrancyForOwner validAddress(token) validAddress(to) validWallet
    {
        emit SudoTransferFund(token, to, amountInWei);

        //Withdraw token
        bool txOk = IERC20(token).transfer(to, amountInWei);

        require(txOk, "TXERR"); // TXERR = Transaction Error
    }

    function transferNetworkCoinFund(address to, uint256 amountInWei) external onlyOwner noReentrancyForOwner validAddress(to) validWallet
    {
        emit SudoTransferNetworkCoinFund(to, amountInWei);

        //Withdraw Network Coin
        payable(to).transfer(amountInWei);
    }


}

// ****************************************************
// ***************** METERS INTERFACE *****************
// ****************************************************
interface IMeters {
    function getOwner() external view returns (address);
    function addressIsAllowed(address value) external view returns (uint);
    function getMappedAddressesForAllowanceSize() external view returns (uint);
    function addScoreAndCounter(address player, uint feature, uint functionId) external;
    function getTablePoints(uint feature, uint functionId) external view returns(uint256);
    function getPlayerScore(address player, uint feature) external view returns (uint256);
    function getPlayerCounter(address player, uint feature, uint functionId) external view returns (uint256);
    function getRequirementCountForFunction(uint feature, uint functionId, uint featureOfMeters, uint functionIdOfMeters) external view returns(uint256);
    function getRequirementScore(uint feature, uint functionId, uint featureOfMeters) external view returns(uint256);
    function getRequirementBalance(uint feature, uint functionId, address tokenAddress) external view returns(uint256);
    function validateRequirement(uint feature, uint functionId, address player) external view returns (uint);
    function validateRequirementMeters(uint feature, uint functionId, uint featureOfMeters, uint functionIdOfMeters, address player) external view returns (uint);
    function validateRequirementBalances(uint feature, uint functionId, address tokenAddress, address player) external view returns (uint);
}

// ****************************************************
// ***************** ERC-20 INTERFACE *****************
// ****************************************************
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


// ****************************************************
// ***************** UNIV2 INTERFACES *****************
// ****************************************************
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