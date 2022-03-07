// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;
import "./Interfaces/ITokenConversion.sol";
import "./Interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
//import "./helpers/RevertReasonParser.sol";

/*interface ITokenConversionLibrary {
    function convertTokenToETH(
        address _factory,
        address _toWhomToIssue,
        address _tokenToExchange,
        uint256 _amount,
        uint256 _minOutputAmount
    ) external returns (uint256);

    function convertETHToToken(
        address _factory,
        address _toWhomToIssue,
        address _tokenToExchange,
        uint256 _amount,
        uint256 _minOutputAmount
    ) external returns (uint256);

    function convertTokenToToken(
        address _factory, 
        address _toWhomToIssue, 
        address _tokenToExchange, 
        address _tokenToConvertTo, 
        uint256 _amount, 
        uint256 _minOutputAmount
    ) external returns (uint256);
}*/

interface IYZapIn {
    function YZapIn(
        address _toWhomToIssue,
        address _fromTokenAddress,
        address _toPairAddress,
        uint256 _amount,
        uint256 _minPoolTokens,
        string calldata _exchangeName
    ) external payable returns (uint256);
}

interface YZap {
    function routerAddress() external returns (address);
}

/*interface ITokenExchangeRouter {
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external payable returns (uint[] memory amounts);
}*/

interface IYZapOut {
    function YZapOut(
        address _toWhomToIssue,
        address _toTokenAddress,
        address _fromPoolAddress,
        uint256 _amount,
        uint256 _minToTokens,
        string calldata _exchangeName
    ) external payable returns (uint256);

    //for curve only
    function getTokenAddressFromSwapAddress(
        address _fromPairAddress
    ) external view returns (address);
}

interface IStakeWithBytes {
    function stake(uint256 amount, bytes calldata b) external;
    function unstake(uint256 amount, bytes calldata b) external;
}

interface IDepositWithRidPool {
    function depositToken(uint256 _rid, uint256 _amount) external;
    function withdrawToken(uint256 _rid, uint256 _amount) external;
}

interface IDepositWithCashout {
    function deposit(uint256 amount) external;
    function cashout(uint256 amount) external;
}

interface IMarketPool {
    function mint(uint256 amount) external;
    function claimVenus(address user) external;
}

interface IYIELDPool {
    function stakeAndAssignTo(address assignTo, uint256 amount) external;
    function withdraw(uint256 amount) external;
    function getReward() external;
    function exit() external;
}

interface IVaultProxy {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function userInfo(address user) external returns(uint256, uint256);
    function pendingRewards() external returns(uint256);
    function mint(uint256 amount) external;
}


interface IFactory {
    //function checkIfTokensCanBeExchangedWith1Exchange(address _fromToken, address _toToken) external returns(bool, address, address[] memory);
    function getInContract(uint256 _exchange) external returns (address);
    function getOutContract(uint256 _exchange) external returns (address);
    function getExchange(uint256 _exchange) external returns (string memory, address, address);
    function isAddressApprovedForStaticFunctions(address _address, uint256 riskLevel) external view returns (bool);
    function isAddressApprovedForDirectCallFunction(address _address, uint256 riskLevel) external view returns (bool);
    function yieldStakeContract() external view returns (address);
    function yieldStakePair() external view returns (address);
    function yieldStakeRewardToken() external view returns (address);
    function yieldStakeExchange() external view returns (uint256);
    function tokenConversionLibrary() external view returns (address);
    function tokenConversionStorage() external view returns (address);
    function getYieldStakeSettings() external view returns (address, address, uint256, uint256, uint256, uint256, address);
    function developmentFund() external view returns (address payable);
    function generatePersonalContractEvent(string calldata _type, bytes calldata _data) external;
    function getStrategy(uint256 _index) external view returns(address);
    function claimInYieldSettings() external view returns(uint256 toDevelopment, uint256 toBurn, address toToken, address to);
    function claimInNativeSettings() external view returns(uint256 toDevelopment, uint256 toBurn, address toToken, address to);
}

interface IWBNBWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
}

/**
@notice Personal contract, used by Factory contract. 
@notice Contains all functions needed for investments
@notice variable investor is owner of deposit funds
@notice variable strategist is address used to run investment commands
@notice variable factory address of factory contract
*/
//TODO: improve upgradeable, use https://www.trufflesuite.com/blog/a-sweet-upgradeable-contract-experience-with-openzeppelin-and-truffle
//if any library code update required !keep! variables order: https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable
contract PersonalLibrary {
    using SafeERC20 for IERC20;
    bool private _notEntered;
    bool private _inFunction;
    
    address payable private investor;
    address private strategist;
    IFactory private factory;
    //address public personalLib;
    address private yieldToken;
    address private networkNativeToken;//WETH or WBNB
    uint256 private constant percentageDecimals = 10000;//two => 100.00%
    uint256 private riskLevel;

    //fee setup
    Investment public investment;

    struct StakedReward {
        uint256 amount;
        uint256 createdAt;//also works as id
        uint256 unlockAt;
    }
    mapping (address => mapping (uint256 => StakedReward[])) public stakedRewards;

    struct ProvideLiquiditySet {
        uint256 exchange;
        address tokenAddress;
        address pairAddress;
        address liquidityPoolOutputTokenAddress;
        uint256 amount;
        uint256 minPoolTokens;
    }

    struct LiquidityToVaultSet {
        uint256 poolTemplate;
        address vaultAddresses;
        uint256 pid;
        //TODO: add the pid in new contract; search key: #iOcby3 and liquidityToVault
    }

    struct StakeSet {
        uint256 poolTemplate; 
        address stakeContractAddress; 
        address tokenToStake;
        uint256 pid;
        bytes extraBytes;
    }
    
    struct UnstakeSet {
        uint256 poolTemplate;
        address stakeContractAddress; 
        uint256 amount;
        uint256 pid;
        bytes extraBytes;
    }

    struct VaultToLiquiditySet {
        address vaultAddress;
    }

    struct WithdrawLiquiditySet {
        uint256 exchange;
        address toWhomToIssue;
        address toTokenAddress;
        address fromTokenAddress;
        address fromliquidityPoolAddress;
        uint256 minTokensRec;
    }
    
    struct Investment {
        address token;
        uint256 initialAmount;
        bool isExternal;
    }

    /**
     * @dev Throws if called by any account other than the strategist.
     */
    modifier onlyStrategist() {
        require(msg.sender == strategist, "!s");
        _;
    }

    modifier strategistOrInvestor() {
        require(msg.sender == strategist || msg.sender == investor, "!si");
        _;
    }

    /**
     * @dev Throws if called by any account other than the investor.
     */
    modifier onlyInvestor() {
        require(msg.sender == investor, '!investor');
        _;
    }

    /**
     * @dev simple custom ReentrancyGuard solution cause
     * failed to run ReentrancyGuard from openzeppelin with initialize/ProxyFactory 
     * (due to private _notEntered and constructor)
     */
    modifier nonReentrant() {
        require(_notEntered, 'already entered');
        _notEntered = false;
        _;
        _notEntered = true;
    }


    /**
     * @dev simple way to disable valueReceived event on restake, stake, unstake and other transactions
     * but, keep it on actual eth.transfer
     */
    modifier inFunction() {
        _inFunction = true;
        _;
        _inFunction = false;
    }

    modifier toggleInvestment(Investment storage _investment) {
        _investment.isExternal = !_investment.isExternal;
        _;
        _investment.isExternal = !_investment.isExternal;
    }
    
    /**
    @notice This function is called only once for every new personal contract
    @param _investor can deposit and withdraw funds
    @param _strategist can invest available funds
    @param _riskLevel max risk level for this contract (0-100%)
    @param _networkNativeToken address of WETH or WBNB
    @param _yieldToken address of Yield Protocol token
    @param _investmentToken address of token in which investment made
    */
    function initialize (
        address payable _investor, 
        address _strategist, 
        uint256 _riskLevel,
        address _networkNativeToken,
        address _yieldToken,
        address _investmentToken
    ) external {
        require(address(factory) == address(0));
        factory = IFactory(msg.sender);
        investor = _investor;
        strategist = _strategist;
        riskLevel = _riskLevel;
        networkNativeToken = _networkNativeToken;
        yieldToken = _yieldToken;
        _notEntered = true;//cause no pre defined variables on ProxyFactory
        investment = Investment(_investmentToken, 0, true);
    }

    /**
    @notice This function is used to provide liquidity and stake with one transaction [harvest]
    @param _pl is a struct of variables that will be used in provideLiquidity function
    @param _lv ... liquidityToVault function
    @param _st ... stake function
    */
    function provideLiquidityAndStake(
        ProvideLiquiditySet memory _pl,
        LiquidityToVaultSet memory _lv,
        StakeSet memory _st
    ) public onlyStrategist inFunction {
        uint256 balance = _pl.amount;

        if (investment.isExternal) {
            require(_pl.tokenAddress == investment.token, "Wrong token");
            investment.initialAmount += balance;
        }

        /*
        Finally done step by step plan:
        1. rebuild 5* functions from public to internal.
        this is to create single entrance to keep track the investmetn
        * provide liquidity, stake, unstake, withdraw liquidity, vault to liquidity
        2. replace liquidity to vault function with stake
        3. create additional variable to see if we doing new stake / unstake, or restake for example
        4. create 2 new variable to keep track total investment, and total withdraw
        (comparing this number will charge user for the fee)
        5. create new variable to set desired token to track investments
        6. create function to estimate investment in the desired token (item #5)
        7. rebuild network native function per new requirements (we will send only BUSD)
        but, for common user we'll have to keep the native option. So, I'll add boolean variable to track this
        8. unstake and withdraw liquidity to personal contract. charge fee and only than send tokens to strategist
        9. rebuild claim reward function: to keep track if we need charge fee
        10. rebuild unstake (with no claim reward) function: to include rewards on fee

        note: a bit delayted due to node. again out of memory. I didn't expact this will be so fast.
        Luckily internet speed was great and I was able to restart node from scratch for ~5 hours :)
        p.s. again tried to clear some space from the full node, but again failed. 
        When I try to clear memory - I simply brode the node
        */

        if(_pl.exchange > 0){
            balance = provideLiquidity(_pl.exchange, _pl.tokenAddress, _pl.pairAddress, _pl.amount, _pl.minPoolTokens);
        }else if(_pl.tokenAddress != _pl.pairAddress){
            balance = _convertTokenToToken(address(this), _pl.tokenAddress, _pl.pairAddress, _pl.amount, _pl.minPoolTokens);
        }

        if(_lv.vaultAddresses != address(0)){
            factory.generatePersonalContractEvent("LiquidityToVault", abi.encode(_st.stakeContractAddress, _pl.pairAddress, balance));
            //TODO: add the pid in new contract; search key: #iOcby3 and liquidityToVault
            //liquidityToVault(_lv.poolTemplate, _lv.vaultAddresses, _pl.liquidityPoolOutputTokenAddress, balance, _lv.pid);
            _stake(_lv.poolTemplate, _lv.vaultAddresses, _pl.liquidityPoolOutputTokenAddress, balance, _lv.pid, bytes(""));
            balance = IERC20(_st.tokenToStake).balanceOf(address(this));
        }

        if(_st.stakeContractAddress != address(0) /*&& _st.poolTemplate != Strategy.MINT_AND_CLAIM*/){
            _stake(_st.poolTemplate, _st.stakeContractAddress, _st.tokenToStake, balance, _st.pid, _st.extraBytes);
        }
    }

    /**
    @notice simple wrapper to claim & exit in one transaction
    @notice stopLossExit doesn't work with this due to differences in fee logic
    @param _un is a struct of variables that will be used in unstake function
    @param _vl ... vaultToLiquidity function
    @param _wl ... withdrawLiquidity function
    @param _rewardType reward function selector
    @param _rewards array of reward token addresses to claim
    */
    function unstakeAndWithdrawLiquidityAndClaimReward(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        uint256 _rewardType,
        address[] memory _rewards
    ) external strategistOrInvestor {
        uint256 amount = _un.amount;
        address toWhomToIssue = _wl.toWhomToIssue;
        address toTokenAddress = _wl.toTokenAddress;

        if (_rewardType == 1) {
            amount -= claimProfitNativeTokens(_un, _vl, _wl, _rewards);
        } else if (_rewardType == 2) {
            amount -= claimProfitYIELDTokens(_un, _vl, _wl, _rewards);
        } else if (_rewardType == 3) {
            amount -= claimProfitAndStake(_un, _vl, _wl, _rewards);
        }

        _un.amount = amount;
        _wl.toWhomToIssue = toWhomToIssue;
        _wl.toTokenAddress = toTokenAddress;
        unstakeAndWithdrawLiquidity(_un, _vl, _wl);
    }

    /**
    @notice Claim profit in native invested token
    @param _un used in unstakeAndWithdrawLiquidity
    @param _vl used in unstakeAndWithdrawLiquidity
    @param _wl used in unstakeAndWithdrawLiquidity
    @param _rewards addresses of possible rewards
    */
    function claimProfitNativeTokens(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        address[] memory _rewards
    ) strategistOrInvestor inFunction public returns(uint256) {
        IFactory _factory = factory;
        address token = investment.token;
     
        (uint256 profit, uint256 withdrawn) = claimProfitInToken(_un, _vl, _wl, _rewards, token);
        if (profit == 0) return withdrawn;

        (uint256 toDevelopment, uint256 toBurn, address toToken, address to) = _factory.claimInYieldSettings();
        toDevelopment = profit - ((profit * (percentageDecimals - toDevelopment)) / percentageDecimals);
        toBurn = profit - ((profit * (percentageDecimals - toBurn)) / percentageDecimals);

        profit = profit - toDevelopment - toBurn;
        toDevelopment = _convertTokenToToken(address(this), token, toToken, toDevelopment, 1);
        toBurn = _convertTokenToToken(address(this), token, yieldToken, toBurn, 1);

        IERC20(toToken).transfer(to, toDevelopment);
        ERC20Burnable(yieldToken).burn(toBurn);
        IERC20(token).transfer(investor, profit);
        _factory.generatePersonalContractEvent("RewardNativeClaimed", abi.encode(toBurn, toDevelopment, profit));
        return withdrawn;
    }

    /**
    @notice Claim profit in yield token
    @param _un used in unstakeAndWithdrawLiquidity
    @param _vl used in unstakeAndWithdrawLiquidity
    @param _wl used in unstakeAndWithdrawLiquidity
    @param _rewards addresses of possible rewards
    */
    function claimProfitYIELDTokens(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        address[] memory _rewards
    ) strategistOrInvestor inFunction public returns(uint256) {
        IFactory _factory = factory;
        address token = investment.token;
        address _yieldToken = yieldToken;

        (uint256 profit, uint256 withdrawn) = claimProfitInToken(_un, _vl, _wl, _rewards, token);
        if (profit == 0) return withdrawn;

        (uint256 toDevelopment, uint256 toBurn, address toToken, address to) = _factory.claimInYieldSettings();
        toDevelopment = profit - ((profit * (percentageDecimals - toDevelopment)) / percentageDecimals);
        toBurn = profit - ((profit * (percentageDecimals - toBurn)) / percentageDecimals);

        profit = profit - toDevelopment - toBurn;
        toDevelopment = _convertTokenToToken(address(this), token, toToken, toDevelopment, 1);

        uint256 yieldAmount = _convertTokenToToken(address(this), token, _yieldToken, profit + toBurn, 1);

        toBurn = yieldAmount * toBurn / (profit + toBurn);
        yieldAmount -= toBurn;

        IERC20(toToken).transfer(to, toDevelopment);
        ERC20Burnable(_yieldToken).burn(toBurn);
        IERC20(_yieldToken).transfer(investor, yieldAmount);
        _factory.generatePersonalContractEvent("RewardYieldClaimed", abi.encode(toBurn, toDevelopment, profit));
        return withdrawn;
    }

    /**
    @notice Claim profit and invest it to yield lp pool
    @param _un used in unstakeAndWithdrawLiquidity
    @param _vl used in unstakeAndWithdrawLiquidity
    @param _wl used in unstakeAndWithdrawLiquidity
    @param _rewards addresses of possible rewards
    */
    function claimProfitAndStake(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        address[] memory _rewards
    ) strategistOrInvestor inFunction public returns(uint256) {
        IFactory _factory = factory;
        address token = investment.token;
        (uint256 profit, uint256 withdrawn) = claimProfitInToken(_un, _vl, _wl, _rewards, token);
        if (profit == 0) return withdrawn;

        (
            address yieldStakeContract, 
            address yieldStakePair, 
            uint256 yieldStakeExchange, 
            uint256 yieldStakePid, 
            uint256 yieldStakeStrategy,
            uint256 yieldStakeLockSeconds,
        ) = _factory.getYieldStakeSettings();

        profit = provideLiquidity(
            yieldStakeExchange,
            token,
            yieldStakePair,
            profit,
            1
        );
        
        _stake(yieldStakeStrategy, yieldStakeContract, yieldStakePair, profit, yieldStakePid, bytes(""));

        stakedRewards[yieldStakeContract][yieldStakePid].push(
            StakedReward(profit, block.timestamp, block.timestamp + yieldStakeLockSeconds)
        );

        _factory.generatePersonalContractEvent("RewardStaked", abi.encode(profit));
        return withdrawn;
    }

    /**
    @notice Claim profit in token 
    @param _un used in unstakeAndWithdrawLiquidity
    @param _vl used in unstakeAndWithdrawLiquidity
    @param _wl used in unstakeAndWithdrawLiquidity
    @param _rewards addresses of possible rewards
    @param token address of token in which profit will be withdrawn
    */
    function claimProfitInToken(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        address[] memory _rewards,
        address token
    ) toggleInvestment(investment) internal returns(uint256 out, uint256 withdrawn) {
        _claimRewards(_un.poolTemplate, _un.stakeContractAddress, _un.pid);
        (uint256 estimatedLiquidity, uint256 estimatedRewards) = estimateInvestment(IUniswapV2Pair(_wl.fromliquidityPoolAddress), _rewards, _un.amount, token);
        uint256 profit = 
            estimatedLiquidity + estimatedRewards > investment.initialAmount ? 
            estimatedLiquidity + estimatedRewards - investment.initialAmount : 
            0;

        if (profit == 0) return (0, 0);

        uint256 rewardsProfit = profit > estimatedRewards ? estimatedRewards : profit;

        uint256 rewardsCollected = 0;
        for (uint256 i = 0; i < _rewards.length; i++) {
            uint256 balance = IERC20(_rewards[i]).balanceOf(address(this));
            if (balance == 0) continue;
            if (_rewards[i] == token) {
                out = balance;
                continue;
            }

            uint256 estimate = estimateTokenToToken(_rewards[i], token, balance);
            uint256 withdrawAmount = 
                    rewardsProfit - rewardsCollected > estimate ? estimate : rewardsProfit - rewardsCollected;
            rewardsCollected += withdrawAmount;
            withdrawAmount = withdrawAmount * balance / estimate;

            out += _convertTokenToToken(address(this), _rewards[i], token, withdrawAmount, 1);
        }

        if (profit - rewardsProfit > 0) {
            _un.amount = _un.amount * (profit - rewardsProfit) / estimatedLiquidity;
            _wl.toWhomToIssue = address(this);
            _wl.toTokenAddress = token;
            withdrawn = _un.amount;
            out += unstakeAndWithdrawLiquidity(_un, _vl, _wl);
        }
    }

    /**
    @notice Estimates current value of investment in invetment.token tokens
    @param _lpPool pool in which investment currently
    @param _rewards addresses of possible rewards
    @param _lpAmount expected amount of liquidity pool tokens
    @param _toToken pool in which investment currently
    @return estimatedLiquidity estimated output of liquidity pool tokens in invetment.token
    @return estimatedRewards estimated output of rewards in invetment.token
     */
    function estimateInvestment(IUniswapV2Pair _lpPool, address[] memory _rewards, uint256 _lpAmount, address _toToken) public view returns(uint256 estimatedLiquidity, uint256 estimatedRewards) {
        for (uint256 i = 0; i < _rewards.length; i++) {
            uint256 balance = IERC20(_rewards[i]).balanceOf(address(this));
            estimatedRewards += estimateTokenToToken(_rewards[i], _toToken, balance);
        }

        estimatedLiquidity = estimatePoolOutput(_lpPool, _toToken, _lpAmount);
    }

    /**
    @notice Estimates output after tokens swap
    @param _from address of token
    @param _to address of token
    @param _amount amount of expected _from tokens
    @return amount of _to tokens
     */
    function estimateTokenToToken(address _from, address _to, uint256 _amount) public view returns (uint256) {
        IFactory _factory = factory;
        ITokenConversion tokenConversion =  ITokenConversion(_factory.tokenConversionLibrary());
        return tokenConversion.estimateTokenToToken(_factory.tokenConversionStorage(), _from, _to, _amount);
    }

    /**
    @notice Estimates current liquidity in pool in _toToken tokens
    @param _lpPool pool in which investment currently
    @param _toToken address of token
    @param _lpAmount expected amount of liquidity pool tokens
    @return estimated output of liquidity pool tokens in _toToken
     */
    function estimatePoolOutput(IUniswapV2Pair _lpPool, address _toToken, uint256 _lpAmount) public view returns(uint256) {
        IFactory _factory = factory;
        ITokenConversion tokenConversion =  ITokenConversion(_factory.tokenConversionLibrary());
        return tokenConversion.estimatePoolOutput(_factory.tokenConversionStorage(), _lpPool, _toToken, _lpAmount);
    }

    /**
    @notice This function is used to unstake and withdraw liquidity with one transaction [harvest]
    @param _un is a struct of variables that will be used in unstake function
    @param _vl ... vaultToLiquidity function
    @param _wl ... withdrawLiquidity function
    */
    function unstakeAndWithdrawLiquidity(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl
    ) public payable strategistOrInvestor nonReentrant inFunction returns(uint256) {
        uint256 _balance; 

        require(_wl.toWhomToIssue == address(this) || _wl.toWhomToIssue == investor, '!allowed');

        if(_un.stakeContractAddress != address(0)){
            _unstake(_un.poolTemplate, _un.stakeContractAddress, _un.amount, _un.pid, _un.extraBytes);
        }

        if(_vl.vaultAddress != address(0) /*&& _un.poolTemplate != Strategy.MINT_AND_CLAIM*/){
            _vaultToLiquidity(_vl.vaultAddress);
        }

        if(_wl.exchange > 0){
            _balance = _withdrawLiquidity(
                _wl.exchange, 
                address(this),
                _wl.toTokenAddress, 
                _wl.fromTokenAddress, 
                IERC20(_wl.fromliquidityPoolAddress).balanceOf(address(this)), 
                _wl.minTokensRec
            );
        }else if(_wl.toTokenAddress != _wl.fromTokenAddress){
            _balance = IERC20(_wl.fromTokenAddress).balanceOf(address(this));
            if(_balance > 0) {
                _convertTokenToToken(address(this), _wl.fromTokenAddress, _wl.toTokenAddress, _balance, _wl.minTokensRec);
            }
        } 
        
        if (_wl.toWhomToIssue == investor){
            if (_wl.toTokenAddress == address(0)){
                _balance = address(this).balance;
            } else {
                _balance = IERC20(_wl.toTokenAddress).balanceOf(address(this));
            }

            if (_wl.toTokenAddress == address(0)){
                payable(investor).transfer(address(this).balance);
            } else {
                IERC20(_wl.toTokenAddress).transfer(investor, IERC20(_wl.toTokenAddress).balanceOf(address(this)));
            }
            factory.generatePersonalContractEvent("LiquidityUnstakedAndWithdrawn", abi.encode(_un.stakeContractAddress, _un.pid));
        }

        if (investment.isExternal) {
            require(_wl.toTokenAddress == investment.token, "Wrong token");
            investment.initialAmount = 0;
        }

        return _balance;
    }

    /**
    @notice This function is used to stake rewards into another pool for autocompound. All with one transaction
    @param _poolTemplate array of strategies of _stakeContractAddress pools
    @param _stakeContractAddress array of pools where HARVEST rewards
    @param _pid array of pool ids (for masterchef contracts, if any at _stakeContractAddress array)
    @param _rewards array of rewards to convert
    @param _pl ... provideLiquidity function (pool where to STAKE the rewards)
    @param _lv ... liquidityToVault function (pool where to STAKE the rewards)
    @param _st ... stake function (pool where to STAKE the rewards)
    @param _minTokensRec Reverts if less tokens received than this (if conversion happen)
    */
    function autoCompound(
        uint256[] memory _poolTemplate,
        address[] memory _stakeContractAddress,
        uint256[] memory _pid,
        address[] memory _rewards,
        ProvideLiquiditySet memory _pl,
        LiquidityToVaultSet memory _lv,
        StakeSet memory _st,
        uint256 _minTokensRec
    ) toggleInvestment(investment) external {//no owner check, will check in provideLiquidityAndStake function

        for (uint256 i; i < _poolTemplate.length; i++){
            _claimRewards(_poolTemplate[i], _stakeContractAddress[i], _pid[i]);
        }

        convertArrayOfTokensToToken(address(this), _rewards, networkNativeToken, _minTokensRec);

        _pl.amount = IERC20(networkNativeToken).balanceOf(address(this));
        _pl.tokenAddress = networkNativeToken;

        provideLiquidityAndStake(
            _pl,
            _lv, 
            _st
        );
    }

    /**
    @notice This function is used to combine several transactions into one action: restake
    @param _un is a struct of variables that will be used in unstake function
    @param _vl ... vaultToLiquidity function
    @param _wl ... withdrawLiquidity function
    @param _pl ... provideLiquidity function
    @param _lv ... liquidityToVault function
    @param _st ... stake function
    @param _rewardsToCompound array of reward to compound from un-vl-wl pool. send only if autocompound option is enabled
    @param _minTokensRecForAutoCompound will revert if tokens conversion failed
    */
    function restake(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        ProvideLiquiditySet memory _pl,
        LiquidityToVaultSet memory _lv,
        StakeSet memory _st,
        address[] memory _rewardsToCompound,
        uint256 _minTokensRecForAutoCompound
    ) toggleInvestment(investment) external {//no owner check, will check in provideLiquidityAndStake function

        //additional info:
        //_wl.toWhomToIssue - no need, always this contract
        //_wl_minTokensRec - doesn't metter, we have _pl.minPoolTokens
        //_wl.toTokenAddress - should be networkNativeToken or liquidityPoolOutputTokenAddress
        //_pl.tokenAddress == _wl.toTokenAddress
        //_pl.amount - we need to calculate this

        _wl.toWhomToIssue = address(this);
        if(_pl.exchange == 0){
             //no lp pair try to withdraw directly in required token
            _wl.toTokenAddress = _pl.liquidityPoolOutputTokenAddress;
        }else{
            //have to work with lp pairs
            //TODO: try to add direct swap
            _wl.toTokenAddress = networkNativeToken;
        }
        
        unstakeAndWithdrawLiquidity(
            _un, 
            _vl, 
            _wl
        );

        if(_rewardsToCompound.length > 0){
            //no need to claim them here, we already claimed on unstake
            convertArrayOfTokensToToken(address(this), _rewardsToCompound, _wl.toTokenAddress, _minTokensRecForAutoCompound);
        }

        _pl.amount = IERC20(_wl.toTokenAddress).balanceOf(address(this));
        _pl.tokenAddress = _wl.toTokenAddress;

        provideLiquidityAndStake(
            _pl,
            _lv, 
            _st
        );

        factory.generatePersonalContractEvent("Restake", abi.encode(_un.stakeContractAddress, _un.pid, _st.stakeContractAddress, _st.pid));
    }

    /*function claimProfitYIELDTokens2(
        uint256 _minTokensRec,
        address[][] memory routers, 
        address[][][] memory paths
    ) strategistOrInvestor inFunction public {
     
        //TODO: add min tokens variable check here. We can keep 1 in _convertTokenToToken(), cause we we'll have one common check
        //this is medium priority, search key mintokn1024

        convertArrayOfTokensToTokenWithPredefinedPath(address(this), 1, routers, paths);
        address[] memory tokensNew = new address[](1);
        tokensNew[0] = yieldToken;
        claimProfitYIELDTokens(tokensNew, _minTokensRec);
        
    }*/




    /**
    @notice difference with unstakeAndWithdrawLiquidity: no fee for rewards
    @notice stopLossExit doesn't have fee and reward tokens are converted to network native token
    @param _un is a struct of variables that will be used in unstake function
    @param _vl ... vaultToLiquidity function
    @param _wl ... withdrawLiquidity function
    @param _tokens array of reward token addresses to claim
    @param _minRewardConverted reverts if less tokens received than this (from rewards only)
    */
    function stopLossExit(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl,
        address[] memory _tokens,
        uint256 _minRewardConverted
    ) external onlyStrategist inFunction {
        //FRONTEND or BACKEND - new variable: _minRewardConverted
        uint256 initialBalance = _getAddressBalance(_wl.toTokenAddress, investor);
        uint256 rewardConverted;
        uint256 unstaked;

        unstakeAndWithdrawLiquidity(_un, _vl, _wl);

        unstaked = _getAddressBalance(_wl.toTokenAddress, investor) - initialBalance;
        if(_tokens.length > 0){
            for (uint256 i; i < _tokens.length; i++){
                uint256 _balance =  IERC20(_tokens[i]).balanceOf(address(this));
                if(_balance == 0)continue;
                _convertTokenToToken(investor, _tokens[i], _wl.toTokenAddress,  _balance, 1);//1 is ok here
            }      
            rewardConverted = _getAddressBalance(_wl.toTokenAddress, investor) - (initialBalance + unstaked);
            //note: rewardConverted == 0 cause we may not have rewards at all, but we can't rewert
            require((rewardConverted == 0 || _minRewardConverted <= rewardConverted), 'slippage');
        }

        factory.generatePersonalContractEvent("stopLossCalled", abi.encode(unstaked, rewardConverted));
    }

    /**
    @notice set new stop loss level for this personal contract, 
    @param _riskLevel is new risk level value (0 - 100 value, no decimals)
    */
    function setRiskLevel(uint256 _riskLevel) onlyInvestor external {
        riskLevel = _riskLevel;
    }

    /**
    @notice simple wrapper to claim & exit in one transaction from Yield stake reward pool
    @notice difference with other methods that there is no fee on rewards
    @param _un is a struct of variables that will be used in unstake function
    @param _vl ... vaultToLiquidity function
    @param _wl ... withdrawLiquidity functionsta
    */
    function unstakeAndClaimRewardsFromYieldStakePool(
        UnstakeSet memory _un,
        VaultToLiquiditySet memory _vl,
        WithdrawLiquiditySet memory _wl
    ) toggleInvestment(investment) external strategistOrInvestor {

        //skip this check save gas, will use stakedRewards instead
        //require(_un.stakeContractAddress == yieldStakeContract && _un.pid == yieldStakePid, 'this function works with reward pool only');
        require(stakedRewards[_un.stakeContractAddress][_un.pid].length > 0, 'no active stake rewards found');

        //note: instead of getting current reward from factory, we should rely on the reward that as on moment of stake..
        //but there is no requirements that reward pool will be changed. So, skipped this for now 
        address yieldStakeRewardToken = factory.yieldStakeRewardToken();
        uint256 rewardBalanceBefore = IERC20(yieldStakeRewardToken).balanceOf(address(this));

        unstakeAndWithdrawLiquidity(_un, _vl, _wl);
        calculateAndSendRewardsForYieldStakeRewardPool(yieldStakeRewardToken, rewardBalanceBefore);
    }
    
    /**
    @notice claim rewards from strategist and pool, for YIELD stake rewards pool only
    @notice Please note: strategist should approve personal contract to spend reward tokens
    */
    function claimRewardsFromYieldStakePool() external strategistOrInvestor inFunction {

        (
            address yieldStakeContract, 
            , 
            , 
            uint256 yieldStakePid, 
            uint256 yieldStakeStrategy,
            ,
            address yieldStakeRewardToken
        ) = factory.getYieldStakeSettings();

        uint256 rewardBalanceBefore = IERC20(yieldStakeRewardToken).balanceOf(address(this));

        _claimRewards(yieldStakeStrategy, yieldStakeContract, yieldStakePid);

        calculateAndSendRewardsForYieldStakeRewardPool(yieldStakeRewardToken, rewardBalanceBefore);
    }

    /**
    @notice function calculates available tocket to be unstaked from reward pools
    @notice we expect only several items in the cycle, gas shouldn't cost much
    @param _stakeContract the stake contract address. In case default stake contract was changed, client can still claim rewards from previous pool..
    @param _pid for masterchef contracts, default is 0
    @return Amount of available tokens to unstake, amount of locked tokens, count of stakes
    */
    function getStakedRewardAmounts(address _stakeContract, uint256 _pid) external view returns (uint256, uint256, uint256){
        uint256 unlocked;
        uint256 locked;
        
        uint256 stakeArraySize = stakedRewards[_stakeContract][_pid].length;
        for(uint256 c = 0; c < stakeArraySize; c++){
            if(stakedRewards[_stakeContract][_pid][c].unlockAt <= block.timestamp){
                unlocked += stakedRewards[_stakeContract][_pid][c].amount;
            }else{
                locked += stakedRewards[_stakeContract][_pid][c].amount;
            }
        }
        
        return (unlocked, locked, stakeArraySize);
    }

    /**
    @notice function calculates available tocket to be unstaked from reward pools
    @notice we expect only several items in the cycle, gas shouldn't cost much;
    @notice in case we will need to withdraw all elements: (uint256 unlocked,, ) = getStakedRewardAmounts(_stakeContract);
    @param _stakeContract the stake contract address. In case default stake contract was changed, client can still claim rewards from previous pool..
    @param _pid for masterchef contracts, default is 0
    @param _amountToRemove amout of tokens to be unstaked
    */
    function refreshStakedRewards(address _stakeContract, uint256 _pid, uint256 _amountToRemove) internal {
        require(_amountToRemove > 0, 'empty');

        uint256 stakeArraySize = stakedRewards[_stakeContract][_pid].length;
         
        for(uint256 c = 0; c < stakeArraySize; c++){
            StakedReward storage element = stakedRewards[_stakeContract][_pid][c];
            if(element.unlockAt <= block.timestamp){
                if(_amountToRemove <= element.amount){
                    element.amount = element.amount - _amountToRemove;
                    _amountToRemove = 0;
                    break;
                }else{
                    _amountToRemove = _amountToRemove - element.amount;
                    element.amount = 0;
                }
            }
        }

        require(_amountToRemove == 0, 'failed to unstake desired amount');
        
        delete stakedRewards[address(0)][_pid];//clear tmp slot

        for(uint256 c = 0; c < stakeArraySize; c++){
            if(stakedRewards[_stakeContract][_pid][c].amount > 0){
                stakedRewards[address(0)][_pid].push(stakedRewards[_stakeContract][_pid][c]);
            }
            
        }
        stakedRewards[_stakeContract][_pid] = stakedRewards[address(0)][_pid];
        
    }

    /**
    @notice helper, allows to call any method with any data on the provided address.
    @notice safety is guaranteed by approved pools: we can not call this method on any address; 
    @notice so, fund of the investor still safe
    @notice positive moment of this func is that we can adopt almost instantly to investment flow change.
    @param _address1 address on which we should run provided bytecode
    @param _inuptBytes1 bytecode to call on address 1
    @param _address2 another address, just to do two transactions in one
    @param _inuptBytes2 another bytecode, just to do two transactions in one
    @return result of 1 call, result of 2 call 
    */
    function directCall(address _address1, bytes memory _inuptBytes1, address _address2, bytes memory _inuptBytes2) inFunction onlyStrategist nonReentrant external returns (bytes memory, bytes memory){
        IFactory _factory = factory;
        bool status;
        bytes memory result1;
        bytes memory result2;

        require(_factory.isAddressApprovedForDirectCallFunction(_address1, riskLevel), 'a1');

        (status, result1) = _address1.call(_inuptBytes1); 
        require(status, 'call 1 failed');

        if(_address2 != address(0)){
            require(_factory.isAddressApprovedForDirectCallFunction(_address2, riskLevel), 'a2');
            (status, result2) = _address2.call(_inuptBytes2); 
            require(status, 'call 2 failed');
        }

        return (result1, result2);
    }

    /**
    @notice emergency eth withdraw. Will take 10% fee.
    @param sendTo address where needed to send eth
    */
    function rescueEth(address payable sendTo) external onlyInvestor nonReentrant {

        uint256 balance = address(this).balance;
        require(balance > 0, 'nothing to rescue');
        sendTo.transfer(balance - (balance / 10));
        factory.developmentFund().transfer(balance / 10);

    }

   /**
    @notice will be usefull in custom cases, for example when we can't exchange reward token on yield
    @notice this may happen if, for example, reward token and yield token are not supporeted on same exchange
    @return true or false
    */
    function rescueTokens(address tokenAddress, uint256 amount) onlyStrategist external returns (bool){
        return IERC20(tokenAddress).transfer(investor, amount);
    }

    /** internal functions **/

        
    /**
    @notice This function is used to invest in given LP pair through ETH/ERC20 Tokens
    @param _exchange is liquidity pool index taken from Factory contract
    @param _fromTokenAddress The ERC20 token used for investment (address(0x00..) if ether)
    @param _toPairAddress The liquidity pool pair address
    @param _amount The amount of fromToken to invest
    @param _minPoolTokens Reverts if less tokens received than this
    @return Amount of LP bought
    */
    function provideLiquidity(
        uint256 _exchange, 
        address _fromTokenAddress, 
        address _toPairAddress, 
        uint256 _amount, 
        uint256 _minPoolTokens
    ) internal returns (uint256) {

        (string memory name, address inContract, ) = factory.getExchange(_exchange);
        uint256 ethValue;

        if(_fromTokenAddress == address(0)){
            ethValue = _amount;
        }else{
            _approve(_fromTokenAddress, inContract, _amount);
        }

        return IYZapIn(inContract).YZapIn{value: ethValue}(
            address(this),
            _fromTokenAddress,
            _toPairAddress,
            _amount,
            _minPoolTokens,
            name
        );
    }

    /**
    @notice This function is used to withdraw liquidity from pool
    @param _exchange is liquidity pool index taken from Factory contract
    @param _ToWhomToIssue is address of personal contract for this user
    @param _ToTokenContractAddress The ERC20 token to withdraw in (address(0x00) if ether)
    @param _fromPairAddress The pair address to withdraw from
    @param _amount The amount of liquidity pool tokens (LP)
    @param _minTokensRec Reverts if less tokens received than this
    @return the amount of eth/tokens received after withdraw
    */
    function _withdrawLiquidity(
        uint256 _exchange,
        address _ToWhomToIssue,
        address _ToTokenContractAddress,
        address _fromPairAddress,
        uint256 _amount,
        uint256 _minTokensRec
    ) internal returns (uint256){

        (string memory name, , address outContractAddress) = factory.getExchange(_exchange);

        //note: this is in case pair != token, for example in curve...
        address tokenAddress = IYZapOut(outContractAddress).getTokenAddressFromSwapAddress(_fromPairAddress); 
        _approve(tokenAddress, outContractAddress, _amount);

        return IYZapOut(outContractAddress).YZapOut(
            _ToWhomToIssue,
            _ToTokenContractAddress,
            _fromPairAddress,
            _amount,
            _minTokensRec,
            name
        );
    }
    
    /**
    @notice the function stakes token into provided pool.
    @notice pool's "stake" function must match one of hardcoded template
    @param _poolTemplate template of the pool. 0 = STAKE, 1 = DEPOSIT and so on..
    @param _stakeContractAddress The stake contract address
    @param _tokenToStake is address of a token or lp/flp pair to be staked
    @param _amount The amount of _fromTokenAddress to invest
    @param _pid id of the pool in masterchef contract..
    @param extraBytes set of bytes for any extra data !! skipped till gas limit improved !!
    */
    function _stake(
            uint256 _poolTemplate, 
            address _stakeContractAddress, 
            address _tokenToStake, 
            uint256 _amount, 
            uint256 _pid, 
            bytes memory extraBytes
        ) internal {
        IFactory _factory = factory;
        
        require(_factory.isAddressApprovedForStaticFunctions(_stakeContractAddress, riskLevel), '!approved');
        _approve(_tokenToStake, _stakeContractAddress, _amount);


        bool status;
        (status, ) = _factory.getStrategy(uint256(_poolTemplate)).delegatecall(abi.encodeWithSignature(
            "stake(address,address,uint256,uint256,bytes)",  
            _stakeContractAddress, _tokenToStake, _amount, _pid, extraBytes
        ));
        require(status, 'stake call failed');

    }

    /**
    @notice This function is used to unstake tokens
    @param _poolTemplate template of the pool. 0 = STAKE, 1 = DEPOSIT and so on..
    @param _stakeContractAddress The stake contract address
    @param _amount The amount of tokens to withdraw
    @param _pid id of the pool in masterchef contract..
    @param extraBytes set of bytes for any extra data !! skipped till gas limit improved !!
    */
    function _unstake(
        uint256 _poolTemplate,
        address _stakeContractAddress,
        uint256 _amount,
        uint256 _pid,
        bytes memory extraBytes
    ) internal {

        //note: auto investment doesn't work with rewards pools to avoid mixing.
        //so we don't need to check if it is a reward stake or not, we assume they are all rewards.
        //if somehow there will be non-reward stake, strategist can withdraw it via direct call
        if(stakedRewards[_stakeContractAddress][_pid].length > 0){
            //this will revert if reward still locked
            refreshStakedRewards(_stakeContractAddress, _pid, _amount);
        }

        bool status;
        (status, ) = factory.getStrategy(uint256(_poolTemplate)).delegatecall(abi.encodeWithSignature(
            "unstake(address,uint256,uint256,bytes)",  
            _stakeContractAddress, _amount, _pid, extraBytes
        ));
        require(status, 'unstake call failed');
    }

    /**
    @notice This function is used to unfarm flp tokens, example: f3Crv -> 3Crv
    @notice Didn't add _poolTemplate, cause all known use same withdraw function
    @param vaultAddress source of farmed tokens
    */
    function _vaultToLiquidity(address vaultAddress) internal {
        IVaultProxy(vaultAddress).withdraw(IERC20(vaultAddress).balanceOf(address(this)));
    }

    /**
    @notice convert any tokens to any tokens.
    @param _toWhomToIssue is address of personal contract for this user
    @param _tokenToExchange address of token witch will be converted
    @param _tokenToConvertTo address of token witch will be returned
    @param _amount how much will be converted
    */
    function _convertTokenToToken(address _toWhomToIssue, address _tokenToExchange, address _tokenToConvertTo, uint256 _amount, uint256 _minOutputAmount) internal returns (uint256) {       
        IFactory _factory = factory;
        bool status;
        bytes memory result;
        (status, result) = _factory.tokenConversionLibrary().delegatecall(abi.encodeWithSignature(
            "convertTokenToToken(address,address,address,address,uint256,uint256)",  
            _factory.tokenConversionStorage(), _toWhomToIssue, _tokenToExchange, _tokenToConvertTo, _amount, _minOutputAmount
        ));
        require(status, 'c call failed');

        return abi.decode(result, (uint256));
    }

    /**
    @notice convert array of any tokens to yield tokens.
    @param _toWhomToIssue is address of personal contract for this user
    @param _tokens array of token witch needed to convert to yield
    @param _minTokensRec Reverts if less tokens received than this (if conversion happen)
    @return balance of yield tokens in this address 
    */
    function convertArrayOfTokensToToken(address _toWhomToIssue, address[] memory _tokens, address _convertToToken, uint256 _minTokensRec) internal returns (uint256) {
        IFactory _factory = factory;
        bool status;
        bytes memory result;
        (status, result) = _factory.tokenConversionLibrary().delegatecall(abi.encodeWithSignature(
            "convertArrayOfTokensToToken(address,address[],address,address,uint256)",  
            _factory.tokenConversionStorage(),
            _tokens, 
            _convertToToken,
            _toWhomToIssue, 
            _minTokensRec
        ));
        require(status, 'ca call failed');

        return abi.decode(result, (uint256));


        /*uint256 amount;
        for (uint256 i; i < _tokens.length; i++){
            //convertTokenToYIELD(_toWhomToIssue, _tokens[i], IERC20(_tokens[i]).balanceOf(address(this)));
            if(_tokens[i] != _convertToToken){
                uint256 b = IERC20(_tokens[i]).balanceOf(address(this));
                if(b > 0){
                    amount += _convertTokenToToken(_toWhomToIssue, _tokens[i], _convertToToken, b, 1);
                }
            }
        }

        //note: amount can be 0, cause we may not have some tokens on balance, but we can't revert 
        require(amount == 0 || amount >= _minTokensRec, 'convert rewards to yield: slippage error');

        //return all balance, not just freshly converted
        //this is cause there is no split logic
        return IERC20(_convertToToken).balanceOf(address(this));*/
    }


    
    /**
    @notice convert array of any tokens to yield tokens.
    @param _toWhomToIssue is address of personal contract for this user
    @param _minTokensRec Reverts if less tokens received than this (if conversion happen)
    @return balance of yield tokens in this address 
    */
    /*function convertArrayOfTokensToTokenWithPredefinedPath(
        address _toWhomToIssue, 
        uint256 _minTokensRec,
        address[][] memory routers, 
        address[][][] memory paths
    ) internal returns (uint256) {
        
        bool status;
        bytes memory result;
        (status, result) = IFactory(factory).tokenConversionLibrary().delegatecall(abi.encodeWithSignature(
            "convertArrayOfTokensToTokenWithPredefinedPath(address,uint256,address[][],address[][][])",  
            _toWhomToIssue, 
            _minTokensRec,
            routers,
            paths
        ));

        require(status, RevertReasonParser.parse(result, "convertArrayOfTokensToTokenWithPredefinedPath failed: "));

        return abi.decode(result, (uint256));
    }*/

    /**
    @notice will be used by back end / front end to build correct flow
    @return flow that this contracts works
    */
    function version() pure external returns (uint256){
        return 7;
    }

    function calculateAndSendRewardsForYieldStakeRewardPool(address yieldStakeRewardToken, uint256 rewardBalanceBefore) internal {
       uint256 gotRewards = IERC20(yieldStakeRewardToken).balanceOf(address(this)) - rewardBalanceBefore;
        if(gotRewards > 0){
            IERC20(yieldStakeRewardToken).transfer(investor, gotRewards);
        }

        gotRewards = IERC20(yieldStakeRewardToken).balanceOf(strategist);
        if(gotRewards > 0){
            //out of gas
            //require(IERC20(yieldStakeRewardToken).allowance(strategist, address(this)) >= gotRewards, 'strategist allowance');
            IERC20(yieldStakeRewardToken).transferFrom(strategist, investor, gotRewards);
        }

    }
    
    function _claimRewards(uint256 _poolTemplate, address _stakeContractAddress, uint256 _pid) internal {
        bool status;
        (status, ) = factory.getStrategy(_poolTemplate).delegatecall(abi.encodeWithSignature(
            "claimRewards(address,uint256)",  
            _stakeContractAddress, _pid
        ));
        require(status, 'claimRewards call failed');
    }

    function _approve(address _token, address _spender, uint256 _amount) internal {
        //first set to 0 due to:
        //1. USDT: https://github.com/Uniswap/uniswap-interface/issues/1172
        //2. in case SafeERC20: approve from non-zero to non-zero allowance
        IERC20(_token).safeApprove(_spender, 0);
        IERC20(_token).safeApprove(_spender, _amount);
    }

    function _getAddressBalance(address _token, address _user) internal view returns (uint256) {
        return (_token == address(0))?_user.balance:IERC20(_token).balanceOf(_user);
    }

    receive() external payable {
         if(!_inFunction){
            factory.generatePersonalContractEvent("ValueReceived", abi.encode(msg.value));
         }
    }
}

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
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
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
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

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
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

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../../../utils/Context.sol";

/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: GPLv2
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IUniswapV2Pair.sol";

interface ITokenConversion {
    function convertTokenToToken(address _storageAddress, address payable _toWhomToIssue, address _fromToken, address _toToken, uint256 _amount, uint256 _minOutputAmount) external returns (uint256);
    function convertArrayOfTokensToToken(address _storageAddress, address[] memory _tokens, address _convertToToken, address payable _toWhomToIssue, uint256 _minTokensRec) external returns (uint256);
    function estimateTokenToToken(address _storageAddress, address _fromToken, address _toToken, uint256 _amount) external view returns (uint256);
    function estimatePoolOutput(address _storageAddress, IUniswapV2Pair _lpPool, address _toToken, uint256 _lpAmount) external view returns (uint256 amountOut);
}