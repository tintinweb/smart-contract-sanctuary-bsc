// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/math/Math.sol";

import "../VaultController.sol";
import "../../library/SafeToken.sol";
import "../../library/System.sol";

import "../../interfaces/IPancakeRouter02.sol";
import "../../interfaces/IStrategy.sol";
import "../../interfaces/IGoenSchedule.sol";
import "../../interfaces/IGoenAdminConfig.sol";
import {ISmartChef, IERC20Metadata} from "../../interfaces/ISmartChef.sol";

import "../../helper/VotingEscrowHelper.sol";


contract VaultCake is 
VaultController,
IStrategy,
ReentrancyGuardUpgradeable
{
    using SafeMath for uint256;
    using SafeToken for address;

    // Pancake router
    IPancakeRouter02 private PANCAKE_ROUTER; //Hardcoded

    // CAKE Pool
    ISmartChef private PancakePool;

    // GOEN Distributor
    IGoenSchedule private schedule;

    IGoenAdminConfig private _config;

    VotingEscrowHelper private _helper;

    // WBNB address to use for swap from pancake
    address private WBNB; //Hardcoded

    // To amplify reward
    uint256 private constant AMPLIFIED_COEF = 1e18;  

    // Value for balance of user deposit in real
    mapping(address => uint256) private principal;

    // Total BNB earned in pool
    uint256 public totalBNB;

    // Total GOEN earned in pool
    uint256 public totalGOEN;

    // Total share distributed (only calculate for share rewards BNB)
    uint256 public totalShares;

    // Last-time BNB earned
    uint256 public lastTimeBNB;

    // Last-time GOEN earned
    uint256 public lastTimeGOEN;

    // Store balances of user (update from withdrawal, deposit, claim = getReward)
    mapping(address => uint256) public balances;

    // Reward per share stored of the last time update reward
    uint256 public rewardPerShareStored;

    // Reward per share stored of the last time update reward
    uint256 public goenRewardPerShareStored;

    uint256 public profitInterval;

    // Store the reward per share paid of user (update from updateReward modifier)
    mapping(address => uint256) public userRewardPerSharePaid;

    // Store the reward per share paid of user (update from updateReward modifier)
    mapping(address => uint256) public goenUserRewardPerSharePaid;

    // Current reward that can claim of user
    mapping(address => uint256) public rewards;

     // Current GOEN reward that can claim of user
    mapping(address => uint256) public goenRewards;

    // Total amount deposit in pool
    uint256 public totalDeposit;

    // Array of deposited addresses
    address[] public depositedUsers;

    // Current deposit 24h
    mapping(address => uint256) public userTotalDeposit24h;

    struct User {
        uint256 userId;
        address userAddress;
    }

    // Mapping user
    mapping(address => User) public mappingUser;
    
    // Total deposit balance of the day
    uint256 public totalDeposit24h;

    User newUser;

    // Like feebox for system pay gas fee for harvest and swap to
    address private TREASURY;

    // The interest earned for GOEN Governance vault
    address private GOV;

    address public OPERATOR;

    function userExist(address _newUser) public view returns (bool) {
        if (depositedUsers.length == 0)
            return false;

        return (depositedUsers[mappingUser[_newUser].userId] == _newUser);
    }

    function addUser(address userAddress) public returns (uint256) {
        require(userAddress!= address(0));

        if (!userExist(userAddress)) {
            newUser = User(depositedUsers.length, userAddress);

            mappingUser[userAddress] = newUser;
            depositedUsers.push(userAddress);

            return newUser.userId;
        }
    }

    // Update the rewards and rewardPerSharePaid of an address
    modifier updateReward(address _account) {
        rewardPerShareStored = rewardPerShare();
        lastTimeBNB = totalBNB;
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerSharePaid[_account] = rewardPerShareStored;
        }
        _;
    }

    // Update the rewards and rewardPerSharePaid of an address
    modifier updateGOENReward(address _account) {
        goenRewardPerShareStored = goenRewardPerShare();
        lastTimeGOEN = totalGOEN;
        if (_account != address(0)) {
            goenRewards[_account] = goenEarned(_account);
            goenUserRewardPerSharePaid[_account] = goenRewardPerShareStored;
        }
        _;
    }

    /**
     * @notice TODO: Make contract can transfer ETH(BNB)???
     */
    receive() external payable {}

    /**
     * @notice TODO: Explaining???
     */
    function initialize(address _token, address _pool) 
    external 
    initializer {
        require(
            _token != address(0), 
            "VaultCake: invalid token");

        __VaultController_init(IBEP20(_token));
        __ReentrancyGuard_init();
        WBNB = System.WBNB;
        PancakePool = ISmartChef(_pool);
        PANCAKE_ROUTER = IPancakeRouter02(System.SWAP_ROUTER);
        vaultStakingToken.approve(address(PancakePool), uint256(-1));
        PancakePool.rewardToken().approve(address(PANCAKE_ROUTER), uint256(-1));
    }


    function setupVault(address govVault, address treasuryVault)
    public
    onlyOwner {
        GOV = govVault;
        TREASURY = treasuryVault;
    }

    
    /**
     * @notice Return amount balance being deposit in pool
     */
    function principalOf(address _account)
    public
    view
    override
    returns (uint256) {
        return principal[_account];
    }

    /**
     * @notice TODO: Get last time reward applicable benefit
     * @return The benefit from Venus that apply in the last time get rewardPerShare
     */
    function lastTimeRewardApplicable() 
    public
    view
    returns (uint256) {
        return Math.min(totalBNB, lastTimeBNB);
    }

    /**
     * @notice Calculate the reward per share of the system
     */
    function rewardPerShare()
    public
    view
    returns (uint256) {
        if (totalShares == 0) {
            return rewardPerShareStored;
        }
        return rewardPerShareStored.add(totalBNB.sub(lastTimeBNB).mul(AMPLIFIED_COEF).div(totalShares));
    }

    /**
     * @notice Calculate the reward per share of the system
     */
    function goenRewardPerShare()
    public
    view
    returns (uint256) {
        if (totalShares == 0) {
            return goenRewardPerShareStored;
        }
        return goenRewardPerShareStored.add(totalGOEN.sub(lastTimeGOEN).mul(AMPLIFIED_COEF).div(totalShares));
    }
    
    /**
     * @notice Calculate the current earned of an account
     */
    function earned(address _account) 
    public
    view
    override
    returns (uint256) {
        return balances[_account].
        mul(rewardPerShare().sub(userRewardPerSharePaid[_account]))
        .div(AMPLIFIED_COEF)
        .add(rewards[_account]);
    }

    /**
     * @notice Calculate the current earned of an account
     */
    function goenEarned(address _account) 
    public
    view
    returns (uint256) {
        return balances[_account].
        mul(goenRewardPerShare().sub(goenUserRewardPerSharePaid[_account]))
        .div(AMPLIFIED_COEF)
        .add(goenRewards[_account]);
    }

    /**
     * @notice return avaiable token asset of market on venus.
     */
    function balance() 
    public
    view
    override 
    returns (uint256) {
        return totalDeposit;
    }

    /**
     * @notice balance of user was deposited for pool
     * @param _account : address of user account
     */
    function balanceOf(address _account) 
    public
    view
    override 
    returns (uint256) {
        return principal[_account];
    }

    /**
     * @notice Return amount user can withdraw
     * @param _account : address of user account
     */
    function withdrawableBalanceOf(address _account)
    public
    view
    override
    returns (uint256) {
        return userTotalDeposit24h[_account] + balanceOf(_account);
    }

    function setupOperator(address goenSchedule_, address helper_, address config_, address operator_)
    public
    onlyOwner {
        schedule = IGoenSchedule(goenSchedule_);
        _helper = VotingEscrowHelper(helper_);
        _config = IGoenAdminConfig(config_);
        OPERATOR = operator_;
    }

    /**
     * @notice Deposit partial balances tokens asset of user
     * @param _amount : amount users deposit
     */
    function deposit(uint256 _amount)
    public
    override
    notPaused
    nonReentrant
    updateReward(msg.sender)
    updateGOENReward(msg.sender) {
        vaultStakingToken.transferFrom(msg.sender, address(this), _amount);
        totalDeposit = totalDeposit.add(_amount);

        addUser(msg.sender);
        userTotalDeposit24h[msg.sender] = userTotalDeposit24h[msg.sender].add(_amount);
        principal[msg.sender] = principal[msg.sender].add(_amount);
        totalDeposit24h = totalDeposit24h.add(_amount);

        emit Deposited(msg.sender, _amount);
    }

    /**
     * @notice deposit all balances tokens asset of user
     */
    function depositAll()
    external
    override {
        deposit(vaultStakingToken.balanceOf(msg.sender));
    }

    /**
     * @notice Withdraw all ballance from amount of deposit, rewards BNB &   * GOEN
     */
    function withdrawAll()
    external
    override
    updateReward(msg.sender)
    updateGOENReward(msg.sender) {
        IERC20Metadata rewardToken = PancakePool.rewardToken();
        uint256 amount = principal[msg.sender];
        //Update userTotalDeposit24h
        uint256 amount24h = userTotalDeposit24h[msg.sender];
        if (amount24h >= amount) {
            userTotalDeposit24h[msg.sender] = amount24h.sub(amount);
        } else {
            uint256 before = rewardToken.balanceOf(address(this));
            PancakePool.withdraw(amount.sub(amount24h));
            uint256 withdrawProfit = rewardToken.balanceOf(address(this)).sub(before);

            totalShares = totalShares.sub(amount.sub(amount24h));
            userTotalDeposit24h[msg.sender] = 0;
            profitInterval = profitInterval.add(withdrawProfit);
        }
        totalDeposit = totalDeposit.sub(amount);
        totalDeposit24h = totalDeposit24h.sub(amount24h);

        vaultStakingToken.transfer(msg.sender, amount);

        delete principal[msg.sender];
        uint256 profit = rewards[msg.sender];
        SafeToken.safeTransferETH(msg.sender, profit);
        SafeToken.safeTransfer(address(GOEN), msg.sender, goenRewards[msg.sender]);
        delete rewards[msg.sender];
        delete userRewardPerSharePaid[msg.sender];
        delete goenRewards[msg.sender];
        delete goenUserRewardPerSharePaid[msg.sender];
        delete balances[msg.sender];
        emit Withdrawn(msg.sender, amount, 0);
    }

    /**
     * @notice The amount of underlying currently owned by the account
     */
    function getUnderlyingBalance()
    public
    view
    returns (uint256) {
        return totalDeposit;
    }

    function withdraw(uint256) 
    external 
    override {
        revert("N/A");
    }

    /**
     * @notice Withdraw underlying ballance of user
     * @param _amount : amount tokens asset user want withdraw
     */
    function withdrawUnderlying(uint256 _amount)
    external
    updateReward(msg.sender)
    updateGOENReward(msg.sender) {
        IERC20Metadata rewardToken = PancakePool.rewardToken();
        uint256 amount = Math.min(_amount, principal[msg.sender]);
        //Update userTotalDeposit24h
        uint256 amount24h = userTotalDeposit24h[msg.sender];
        if (amount24h >= amount) {
            userTotalDeposit24h[msg.sender] = amount24h.sub(amount);
            totalDeposit24h = totalDeposit24h.sub(amount);
        } else {
            uint256 leftover = amount.sub(amount24h);
            uint256 before = rewardToken.balanceOf(address(this));
            PancakePool.withdraw(leftover);
            uint256 withdrawProfit = rewardToken.balanceOf(address(this)).sub(before);
            profitInterval = profitInterval.add(withdrawProfit);

            totalShares = totalShares.sub(leftover);
            balances[msg.sender] = balances[msg.sender].sub(leftover);
            userTotalDeposit24h[msg.sender] = 0;
            totalDeposit24h = totalDeposit24h.sub(amount24h);
        }

        vaultStakingToken.transfer(msg.sender, amount);
        
        principal[msg.sender] = principal[msg.sender].sub(amount);
        totalDeposit = totalDeposit.sub(amount);
    }

    /**
     * @notice rewards token earned (BNB from swap and GOEN tokens)
     */
    function getReward()
    public
    override
    nonReentrant
    updateReward(msg.sender)
    updateGOENReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        uint256 goenReward = goenRewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
        }

        if (goenReward > 0) {
            goenRewards[msg.sender] = 0;
        }

        SafeToken.safeTransferETH(msg.sender, reward);
        GOEN.transfer(msg.sender, goenReward);

        emit ProfitPaid(msg.sender, reward, 0);
    }

    function _swapRewardToBNB(address rewardToken, uint256 amount) 
    internal
    returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = rewardToken;
        path[1] = WBNB;
        uint256 swapAmount = PANCAKE_ROUTER.swapExactTokensForETH(amount, 0, path, address(this), block.timestamp)[1];
        return swapAmount;
    }

    event VaultHarvested(
        uint256 poolReceivedAmount,
        uint256 rebateReceived,
        uint256 goenReceivedAmount
    );

    /**
     * @notice Harvest interest token and BNB
     */
    function harvest()
    public
    override
    notPaused
    updateReward(address(0))
    updateGOENReward(address(0)) 
    returns (uint256 poolReceivedAmount, uint256 goenReceivedAmount) {
        // GET REWARDS
        IERC20Metadata rewardToken = PancakePool.rewardToken();
        uint256 before = rewardToken.balanceOf(address(this));
        PancakePool.deposit(totalDeposit24h);
        uint256 withdrawProfit = rewardToken.balanceOf(address(this)).sub(before);

        goenReceivedAmount = schedule.harvest();
        if (totalShares == 0) {
            IBEP20(GOEN).transfer(address(schedule), goenReceivedAmount);
        }
        uint256 reward = 0;
        uint256 rebateReceive = 0;
        if (profitInterval.add(withdrawProfit) > 0) {
            poolReceivedAmount = _swapRewardToBNB(
                address(PancakePool.rewardToken()),
                profitInterval.add(withdrawProfit)
            );
            (reward, rebateReceive) = _distributeReward(poolReceivedAmount);
        }
        totalGOEN += goenReceivedAmount;

        // // BATCH DEPOSIT
        rewardPerShareStored = rewardPerShare();
        goenRewardPerShareStored = goenRewardPerShare();
        lastTimeBNB = totalBNB;
        lastTimeGOEN = totalGOEN;
        for (uint i = 0; i < depositedUsers.length; i++) {
            address userAddress = depositedUsers[i];
            rewards[userAddress] = earned(userAddress);
            userRewardPerSharePaid[userAddress] = rewardPerShareStored;
            goenRewards[userAddress] = goenEarned(userAddress);
            goenUserRewardPerSharePaid[userAddress] = goenRewardPerShareStored;
            
            uint256 userDeposited = userTotalDeposit24h[userAddress];
            balances[userAddress] = balances[userAddress].add(userDeposited);
            delete userTotalDeposit24h[userAddress];
            delete mappingUser[userAddress];
        }
        totalShares = totalShares.add(totalDeposit24h);
        
        // // CLEAR DEPOSIT
        delete depositedUsers;
        totalDeposit24h = 0;
        profitInterval = 0;

        emit VaultHarvested(reward, rebateReceive, goenReceivedAmount);
    }

    function reinvest(address _newPool) external {
        require(msg.sender == OPERATOR, "Caller is not operator");
        IERC20Metadata rewardToken = PancakePool.rewardToken();
        uint256 before = rewardToken.balanceOf(address(this));
        PancakePool.withdraw(totalShares);
        uint256 withdrawReward = rewardToken.balanceOf(address(this)).sub(before);
        uint256 poolReceivedAmount = _swapRewardToBNB(
                address(PancakePool.rewardToken()),
                withdrawReward
            );
        (uint256 reward, uint256 rebateReceive) = _distributeReward(poolReceivedAmount);

        PancakePool = ISmartChef(_newPool);
        vaultStakingToken.approve(_newPool, uint256(-1));
        PancakePool.rewardToken().approve(address(PANCAKE_ROUTER), uint256(-1));

        PancakePool.deposit(totalShares.add(totalDeposit24h));

        uint256 goenReceivedAmount = schedule.harvest();
        if (totalShares == 0) {
            IBEP20(GOEN).transfer(address(schedule), goenReceivedAmount);
        }

        for (uint i = 0; i < depositedUsers.length; i++) {
            address userAddress = depositedUsers[i];
            rewards[userAddress] = earned(userAddress);
            userRewardPerSharePaid[userAddress] = rewardPerShareStored;
            goenRewards[userAddress] = goenEarned(userAddress);
            goenUserRewardPerSharePaid[userAddress] = goenRewardPerShareStored;
            
            uint256 userDeposited = userTotalDeposit24h[userAddress];
            balances[userAddress] = balances[userAddress].add(userDeposited);
            delete userTotalDeposit24h[userAddress];
            delete mappingUser[userAddress];
        }
        totalShares = totalShares.add(totalDeposit24h);
        
        // // CLEAR DEPOSIT
        delete depositedUsers;
        totalDeposit24h = 0;
        profitInterval = 0;

        emit VaultHarvested(reward, rebateReceive, goenReceivedAmount);
    }

    function _distributeReward(uint256 poolReceivedAmount) internal returns (uint256, uint256) {
        uint256 harvestBounty = poolReceivedAmount.mul(_config.bounty()).div(10000);
        poolReceivedAmount = poolReceivedAmount.sub(harvestBounty);
        uint256 reward = poolReceivedAmount.mul(_config.reward()).div(100);
        uint256 sysReceive = poolReceivedAmount.sub(reward);
        uint256 govReceive = sysReceive.mul(_config.gov()).mul(100 - _config.rebate()).div(10000);
        uint256 rebateReceive = sysReceive.mul(_config.gov()).mul(_config.rebate()).div(10000);
        uint256 treasuryReceive = sysReceive.sub(govReceive).sub(rebateReceive);
        
        if (totalShares > 0) {
            totalBNB += reward;
            SafeToken.safeTransferETH(address(TREASURY), treasuryReceive);
        } else {
            SafeToken.safeTransferETH(address(TREASURY), treasuryReceive.add(reward));
            reward = 0;
        }
        SafeToken.safeTransferETH(_helper.tokenAtPool(WBNB), rebateReceive);
        SafeToken.safeTransferETH(msg.sender, harvestBounty);
        SafeToken.safeTransferETH(address(GOV), govReceive);
        return (reward, rebateReceive);
    }

    // function emergencyWithdraw()
    // nonReentrant
    // external
    // onlyOwner {
    //     updateVenusFactors();
    //     uint256 underlyingBalance = getUnderlyingBalance();
    //     venusBridge.redeemAll();
    //     venusBridge.withdraw(msg.sender, underlyingBalance);
    //     SafeToken.safeTransfer(address(GOEN), msg.sender, GOEN.balanceOf(address(this)));
    //     SafeToken.safeTransferETH(msg.sender, address(this).balance);
    // }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuardUpgradeable is Initializable {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
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
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "@pancakeswap/pancake-swap-lib/contracts/token/BEP20/BEP20.sol";

import "../interfaces/IPancakeRouter02.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IMasterChef.sol";

import "../library/System.sol";

import "../library/PausableUpgradeable.sol";
import "../library/WhitelistUpgradeable.sol";

abstract contract VaultController is
IVaultController,
PausableUpgradeable,
WhitelistUpgradeable 
{
    using SafeBEP20 for IBEP20;

    // Address of GOEN token
    BEP20 public GOEN;

    // Address of Staking token
    IBEP20 internal vaultStakingToken;

    // TODO: Grap: not used this one yet???
    uint256[49] private __gap;

    // Events    
    event Recovered(address token, uint256 amount);

    /**
     * @notice Initialize vault controller from BEP20 token
     * @param _token the staking token
     */
    function __VaultController_init(IBEP20 _token) 
    internal 
    initializer {
        __PausableUpgradeable_init();
        __WhitelistUpgradeable_init();
        vaultStakingToken = _token;
        GOEN = BEP20(System.GOEN);
    }

    /**
     * @notice Return address of staking token
     */
    function stakingToken()
    external
    view
    override
    returns (address) {
        return address(vaultStakingToken);
    }

    /**
     * @notice Transfer amount tokens to owner
     * @param _token the token which be needed transfering
     * @param _amount the amount of tokens
     */
    function recoverToken(address _token, uint256 _amount)
    external
    virtual
    onlyOwner {
        require(
            _token != address(vaultStakingToken),
            "VaultController: cannot recover underlying token");

        IBEP20(_token).safeTransfer(owner(), _amount);
        emit Recovered(_token, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface ERC20Interface {
    function balanceOf(address user) external view returns (uint256);
}

library SafeToken {
    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function balanceOf(address token, address user) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("approve(address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeApprove");
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("transfer(address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransfer");
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes("transferFrom(address,address,uint256)")));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "!safeTransferFrom");
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

library System {
    address constant SYRUP_POOL = 0xe3CEbC98E205A7f6365AFeD77b74300A19D92F42;
    address constant SWAP_ROUTER = 0x89e310DB3feB95cf8eFD1EB47d9e0f2261E0f6bb;
    address constant VENUS_UNICONTROLLER = 0x94d1820b2D1c7c7452A163983Dc888CEC546b77D;
    address constant GOEN = 0x7C19Ae03218509Cb08897F875048f8BD946D01D0;
    address constant WBNB = 0x97c012Ef10eDc79510A17272CEE3ecBE1443177F;
    address constant XVS = 0xB9e0E753630434d7863528cc73CB7AC638a7c8ff;
    address constant BUSD = 0x8301F2213c0eeD49a7E28Ae4c3e91722919B8B47;
    uint256 constant SYSTEM_INTERVAL = 1 days;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./IPancakeRouter01.sol";

interface IPancakeRouter02 is IPancakeRouter01 {
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
pragma solidity ^0.6.12;

pragma experimental ABIEncoderV2;

import "./IStrategyCompact.sol";

interface IStrategy is IStrategyCompact {
    // rewardsToken
    // function sharesOf(address account) external view returns (uint256);

    function deposit(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    /* ========== Interface ========== */

    function depositAll() external;

    function withdrawAll() external;

    function getReward() external;

    function harvest() external returns (uint256, uint256);

    // function pid() external view returns (uint256);

    // function totalSupply() external view returns (uint256);

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount, uint256 withdrawalFee);
    event ProfitPaid(address indexed user, uint256 profit, uint256 performanceFee);
    event BunnyPaid(address indexed user, uint256 profit, uint256 performanceFee);
    event Harvested(uint256 profit);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

interface IGoenSchedule {
    function harvest() external returns(uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;


interface IGoenAdminConfig {
    function addWhiteList(address token) external;
    function isInWhiteList(address token) external view returns (bool);
    function reward() external view returns (uint256);
    function gov() external view returns (uint256);
    function rebate() external view returns (uint256);
    function bounty() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;


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

interface ISmartChef {
    function rewardToken() external view returns (IERC20Metadata);
    function deposit(uint256 _amount) external;
    function withdraw(uint256 _amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import {IRebatePool} from "../governances/RebatePool.sol";
import {IVotingEscrowCallback} from "../governances/VotingEscrow.sol";
import "@pancakeswap/pancake-swap-lib/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VotingEscrowHelper is IVotingEscrowCallback, Ownable {
    mapping(address => address) public tokenAtPool;
    IVotingEscrowCallback[] public rebatePools;
    IVotingEscrowCallback public votingEmission;

    modifier isContract(address _address) {
        uint32 size;
        assembly {
            size := extcodesize(_address)
        }
        require(size > 0, "Not a contract!");
        _;
    }

    constructor(address[] memory rebatePool_, address votingEmission_) public {
        votingEmission = IVotingEscrowCallback(votingEmission_);
        for (uint256 i = 0; i < rebatePool_.length; i++) {
            rebatePools.push(IVotingEscrowCallback(rebatePool_[i]));
            tokenAtPool[IRebatePool(rebatePool_[i]).getToken()] = rebatePool_[i];
        }
    }

    function syncWithVotingEscrow(address account_) external override {
        votingEmission.syncWithVotingEscrow(account_);
        for (uint256 i = 0; i < rebatePools.length; i++) {
            rebatePools[i].syncWithVotingEscrow(account_);
        }
    }

    function setVotingEmission(address votingEmission_) public onlyOwner isContract(votingEmission_) {
        votingEmission = IVotingEscrowCallback(votingEmission_);
    }

    function getAllRebatePools() public view returns (IVotingEscrowCallback[] memory) {
        return rebatePools;
    }

    function addRebatePool(address rebatePool_) public onlyOwner isContract(rebatePool_) {
        require(!_isPoolExisted(rebatePool_), "Pool is already added");
        rebatePools.push(IVotingEscrowCallback(rebatePool_));
        tokenAtPool[IRebatePool(rebatePool_).getToken()] = rebatePool_;
    }

    function replacePoolAtWith(uint256 index_, address rebatePool_) public onlyOwner isContract(rebatePool_) {
        require(index_ >= 0 || index_ < rebatePools.length, "Wrong argument");
        require(!_isPoolExisted(rebatePool_), "Pool is already added");
        address oldRebatePool_ = address(IVotingEscrowCallback(rebatePools[index_]));
        tokenAtPool[IRebatePool(oldRebatePool_).getToken()] = address(0);
        rebatePools[index_] = IVotingEscrowCallback(rebatePool_);
        tokenAtPool[IRebatePool(rebatePool_).getToken()] = rebatePool_;
    }

    function _isPoolExisted(address rebatePool_) private view returns (bool) {
        for (uint256 i = 0; i < rebatePools.length; i++) {
            if (rebatePools[i] == IVotingEscrowCallback(rebatePool_)) {
                return true;
            }
        }
        return false;
    }
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
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
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.6.0;

import './IBEP20.sol';
import '../../math/SafeMath.sol';
import '../../utils/Address.sol';

/**
 * @title SafeBEP20
 * @dev Wrappers around BEP20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeBEP20 for IBEP20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IBEP20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

import '../../access/Ownable.sol';
import '../../GSN/Context.sol';
import './IBEP20.sol';
import '../../math/SafeMath.sol';
import '../../utils/Address.sol';

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is Context, IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
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
    ) internal {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

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

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

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
pragma solidity ^0.6.12;

interface IMasterChef {
    function cakePerBlock() external view returns (uint256);

    function totalAllocPoint() external view returns (uint256);

    function poolInfo(uint256 _pid)
        external
        view
        returns (
            address lpToken,
            uint256 allocPoint,
            uint256 lastRewardBlock,
            uint256 accCakePerShare
        );

    function userInfo(uint256 _pid, address _account) external view returns (uint256 amount, uint256 rewardDebt);

    function poolLength() external view returns (uint256);

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function enterStaking(uint256 _amount) external;

    function leaveStaking(uint256 _amount) external;
}

/*
   ____            __   __        __   _
  / __/__ __ ___  / /_ / /  ___  / /_ (_)__ __
 _\ \ / // // _ \/ __// _ \/ -_)/ __// / \ \ /
/___/ \_, //_//_/\__//_//_/\__/ \__//_/ /_\_\
     /___/

* Docs: https://docs.synthetix.io/
*
*
* MIT License
* ===========
*
* Copyright (c) 2020 Synthetix
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract PausableUpgradeable is OwnableUpgradeable {
    uint256 public lastPauseTime;
    bool public paused;

    event PauseChanged(bool isPaused);

    modifier notPaused() {
        require(!paused, "PausableUpgradeable: cannot be performed while the contract is paused");
        _;
    }

    function __PausableUpgradeable_init() internal initializer {
        __Ownable_init();
        require(owner() != address(0), "PausableUpgradeable: owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;
        if (paused) {
            lastPauseTime = now;
        }

        emit PauseChanged(paused);
    }

    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract WhitelistUpgradeable is OwnableUpgradeable {
    mapping(address => bool) private _whitelist;
    bool private _disable; // default - false means whitelist feature is working on. if true no more use of whitelist

    event Whitelisted(address indexed _address, bool whitelist);
    event EnableWhitelist();
    event DisableWhitelist();

    modifier onlyWhitelisted() {
        require(_disable || _whitelist[msg.sender], "Whitelist: caller is not on the whitelist");
        _;
    }

    function __WhitelistUpgradeable_init() internal initializer {
        __Ownable_init();
    }

    function isWhitelist(address _address) public view returns (bool) {
        return _whitelist[_address];
    }

    function setWhitelist(address _address, bool _on) external onlyOwner {
        _whitelist[_address] = _on;

        emit Whitelisted(_address, _on);
    }

    function disableWhitelist(bool disable) external onlyOwner {
        _disable = disable;
        if (disable) {
            emit DisableWhitelist();
        } else {
            emit EnableWhitelist();
        }
    }

    uint256[49] private __gap;
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

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
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
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
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, 'Address: low-level call failed');
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
        return _functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
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
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

import '../GSN/Context.sol';

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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IPancakeRouter01 {
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

    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

pragma experimental ABIEncoderV2;

import "./IVaultController.sol";

interface IStrategyCompact is IVaultController {
    /* ========== Dashboard ========== */

    function balance() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function principalOf(address account) external view returns (uint256);

    function withdrawableBalanceOf(address account) external view returns (uint256);

    function earned(address account) external view returns (uint256);

    // function priceShare() external view returns (uint256);

    // function depositedAtOf(address account) external view returns (uint256);

    // function rewardsToken() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

interface IVaultController {
    function stakingToken() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/ContextUpgradeable.sol";
import "../proxy/Initializable.sol";
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
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;
import "../proxy/Initializable.sol";

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
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
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../library/SafeDecimalMath.sol";
import "../library/CoreUtility.sol";
import "../library/System.sol";
import "../interfaces/IVotingEscrow.sol";
import "../interfaces/IWrappedERC20.sol";
import "../library/SafeToken.sol";

interface IRebatePool {
    function getToken() external view returns (address);
}

contract RebatePool is CoreUtility, Ownable, IRebatePool {
    using SafeMath for uint256;
    using SafeDecimalMath for uint256;
    using SafeERC20 for IERC20;
    using SafeToken for address;

    uint256 public immutable maxTime;
    address public immutable rewardToken;
    IVotingEscrow public immutable votingEscrow;

    /// @notice Timestamp of the last checkpoint
    uint256 public checkpointTimestamp;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice Amount of Goen locked at the end of the last checkpoint"s week
    uint256 public nextWeekLocked;

    /// @notice Total veGoen at the end of the last checkpoint"s week
    uint256 public nextWeekSupply;

    /// @notice Cumulative rewards received until the last checkpoint minus cumulative rewards
    ///         claimed until now
    uint256 public lastRewardBalance;

    /// @notice Mapping of week => total rewards accumulated
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         the rewards collected from the corresponding fund in rewardToken"s unit
    mapping(uint256 => uint256) public rewardsPerWeek;

    /// @notice Mapping of week => vote-locked Goen total supplies
    ///
    //          Key is the start timestamp of a week on each Thursday. Value is
    ///         vote-locked Goen total supplies captured at the start of each week
    mapping(uint256 => uint256) public veSupplyPerWeek;

    /// @notice Locked balance of an account, which is synchronized with `VotingEscrow` when
    ///         `syncWithVotingEscrow()` is called
    mapping(address => IVotingEscrow.LockedBalance) public userLockedBalances;

    /// @notice Start timestamp of the week of a user"s last checkpoint
    mapping(address => uint256) public userWeekCursors;

    /// @notice An account"s veGoen amount at the beginning of the week of this user"s
    ///         last checkpoint
    mapping(address => uint256) public userLastBalances;

    /// @notice Mapping of account => amount of claimable Goen
    mapping(address => uint256) public claimableRewards;

    event Synchronized(
        address indexed account,
        uint256 oldAmount,
        uint256 oldUnlockTime,
        uint256 newAmount,
        uint256 newUnlockTime
    );

    constructor(
        address rewardToken_,
        address votingEscrow_
    ) public {
        rewardToken = rewardToken_;
        votingEscrow = IVotingEscrow(votingEscrow_);
        maxTime = IVotingEscrow(votingEscrow_).getMaxtime();
        checkpointTimestamp = block.timestamp;
    }

    function getToken() public view override returns (address) {
        return address(rewardToken);
    }

    function balanceOf(address account_) external view returns (uint256) {
        return _balanceAtTimestamp(userLockedBalances[account_], block.timestamp);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupplyAtTimestamp(block.timestamp);
    }

    function balanceOfAtTimestamp(address account_, uint256 timestamp_) external view returns (uint256) {
        require(timestamp_ >= checkpointTimestamp, "Must be current or future time");
        return _balanceAtTimestamp(userLockedBalances[account_], timestamp_);
    }

    function totalSupplyAtTimestamp(uint256 timestamp_) external view returns (uint256) {
        require(timestamp_ >= checkpointTimestamp, "Must be current or future time");
        return _totalSupplyAtTimestamp(timestamp_);
    }

    /// @dev Calculate the amount of veGoen of a `LockedBalance` at a given timestamp
    function _balanceAtTimestamp(IVotingEscrow.LockedBalance memory lockedBalance_, uint256 timestamp_)
        public
        view
        returns (uint256)
    {
        if (timestamp_ >= lockedBalance_.unlockTime) {
            return 0;
        }
        return lockedBalance_.amount.mul(lockedBalance_.unlockTime - timestamp_) / maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp_) public view returns (uint256) {
        uint256 total = 0;
        for (
            uint256 weekCursor = _endOfWeek(timestamp_);
            weekCursor <= timestamp_ + maxTime;
            weekCursor += System.SYSTEM_INTERVAL
        ) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp_)) / maxTime);
        }
        return total;
    }


    /// @notice Synchronize an account's locked Goen with `VotingEscrow`.
    /// @param account_ Address of the synchronized account
    function syncWithVotingEscrow(address account_) external {
        userCheckpoint(account_);

        uint256 nextWeek = _endOfWeek(block.timestamp);
        IVotingEscrow.LockedBalance memory newLockedBalance = votingEscrow.getLockedBalance(account_);
        if (newLockedBalance.amount == 0 || newLockedBalance.unlockTime <= nextWeek) {
            return;
        }
        IVotingEscrow.LockedBalance memory oldLockedBalance = userLockedBalances[account_];
        uint256 newNextWeekLocked = nextWeekLocked;
        uint256 newNextWeekSupply = nextWeekSupply;

        // Remove the old schedule if there is one
        if (oldLockedBalance.amount > 0 && oldLockedBalance.unlockTime > nextWeek) {
            scheduledUnlock[oldLockedBalance.unlockTime] = scheduledUnlock[oldLockedBalance.unlockTime].sub(
                oldLockedBalance.amount
            );
            newNextWeekLocked = newNextWeekLocked.sub(oldLockedBalance.amount);
            newNextWeekSupply = newNextWeekSupply.sub(
                oldLockedBalance.amount.mul(oldLockedBalance.unlockTime - nextWeek) / maxTime
            );
        }

        scheduledUnlock[newLockedBalance.unlockTime] = scheduledUnlock[newLockedBalance.unlockTime].add(
            newLockedBalance.amount
        );
        nextWeekLocked = newNextWeekLocked.add(newLockedBalance.amount);
        // Round up on division when added to the total supply, so that the total supply is never
        // smaller than the sum of all accounts"veGoen balance.
        nextWeekSupply = newNextWeekSupply.add(
            newLockedBalance.amount.mul(newLockedBalance.unlockTime - nextWeek).add(maxTime - 1) / maxTime
        );
        userLockedBalances[account_] = newLockedBalance;

        emit Synchronized(
            account_,
            oldLockedBalance.amount,
            oldLockedBalance.unlockTime,
            newLockedBalance.amount,
            newLockedBalance.unlockTime
        );
    }

    function userCheckpoint(address account_) public returns (uint256 rewards_) {
        checkpoint();
        rewards_ = claimableRewards[account_].add(_rewardCheckpoint(account_));
        claimableRewards[account_] = rewards_;
    }

    function claimRewards(address payable account_) external returns (uint256 rewards_) {
        rewards_ = _claimRewards(account_);
        if (rewardToken == System.WBNB) {
            SafeToken.safeTransferETH(account_, rewards_);
        } else {
            IERC20(rewardToken).safeTransfer(account_, rewards_);
        }
    }

    /// @notice Receive unwrapped transfer from the wrapped token.
    receive() external payable {}

    function _claimRewards(address account_) public returns (uint256 rewards_) {
        checkpoint();
        rewards_ = claimableRewards[account_].add(_rewardCheckpoint(account_));
        claimableRewards[account_] = 0;
        lastRewardBalance = lastRewardBalance.sub(rewards_);
        emit UserClaimed(account_, rewards_);
    }

    /// @notice Make a global checkpoint. If the period since the last checkpoint spans over
    ///         multiple weeks, rewards received in this period are split into these weeks
    ///         proportional to the time in each week.
    /// @dev Post-conditions:
    ///
    ///      - `checkpointTimestamp == block.timestamp`
    ///      - `lastRewardBalance == rewardToken.balanceOf(address(this))`
    ///      - All `rewardsPerWeek[t]` are updated, where `t <= checkpointTimestamp`
    ///      - All `veSupplyPerWeek[t]` are set, where `t <= checkpointTimestamp`
    ///      - `nextWeekSupply` is the total veGoen at the end of this week
    ///      - `nextWeekLocked` is the total locked Goen at the end of this week
    function checkpoint() public {
        uint256 tokenBalance;
        if(rewardToken == System.WBNB){
            tokenBalance = address(this).balance;
        } else{
            tokenBalance = IERC20(rewardToken).balanceOf(address(this));
        }
        uint256 tokensToDistribute = tokenBalance.sub(lastRewardBalance);
        lastRewardBalance = tokenBalance;
        uint256 rewardTime = checkpointTimestamp;
        uint256 weekCursor = _endOfWeek(rewardTime) - System.SYSTEM_INTERVAL;
        uint256 currentWeek = _endOfWeek(block.timestamp) - System.SYSTEM_INTERVAL;

        // Update veGoen supply at the beginning of each week since the last checkpoint.
        if (weekCursor < currentWeek) {
            uint256 newLocked = nextWeekLocked;
            uint256 newSupply = nextWeekSupply;
            for (uint256 w = weekCursor + System.SYSTEM_INTERVAL; w <= currentWeek; w += System.SYSTEM_INTERVAL) {
                veSupplyPerWeek[w] = newSupply;
                // Calculate supply at the end of the next week.
                newSupply = newSupply.sub(newLocked.mul(System.SYSTEM_INTERVAL) / maxTime);
                // Remove Goen unlocked at the end of the next week from total locked amount.
                newLocked = newLocked.sub(scheduledUnlock[w + System.SYSTEM_INTERVAL]);
            }
            nextWeekLocked = newLocked;
            nextWeekSupply = newSupply;
        }

        // Distribute rewards received since the last checkpoint.
        if (tokensToDistribute > 0) {
            if (weekCursor >= currentWeek) {
                rewardsPerWeek[weekCursor] = rewardsPerWeek[weekCursor].add(tokensToDistribute);
            } else {
                uint256 sinceLast = block.timestamp - rewardTime;
                // Calculate the fraction of rewards proportional to the time from
                // the last checkpoint to the end of that week.
                rewardsPerWeek[weekCursor] = rewardsPerWeek[weekCursor].add(
                    tokensToDistribute.mul(weekCursor + System.SYSTEM_INTERVAL - rewardTime) / sinceLast
                );
                weekCursor += System.SYSTEM_INTERVAL;
                // Calculate the fraction of rewards for intermediate whole weeks.
                while (weekCursor < currentWeek) {
                    rewardsPerWeek[weekCursor] = tokensToDistribute.mul(System.SYSTEM_INTERVAL) / sinceLast;
                    weekCursor += System.SYSTEM_INTERVAL;
                }
                // Calculate the fraction of rewards proportional to the time from
                // the beginning of the current week to the current block timestamp.
                rewardsPerWeek[weekCursor] = tokensToDistribute.mul(block.timestamp - weekCursor) / sinceLast;
            }
        }

        checkpointTimestamp = block.timestamp;
    }

    /// @dev Calculate rewards since a user"s last checkpoint and make a new checkpoint.
    ///
    ///      Post-conditions:
    ///
    ///      - `userWeekCursor[account]` is the start timestamp of the current week
    ///      - `userLastBalances[account]` is amount of veGoen at the beginning of the current week
    /// @param account Address of the account
    /// @return Rewards since the last checkpoint
    function _rewardCheckpoint(address account) public returns (uint256) {
        uint256 currentWeek = _endOfWeek(block.timestamp) - System.SYSTEM_INTERVAL;
        uint256 weekCursor = userWeekCursors[account];
        if (weekCursor >= currentWeek) {
            return 0;
        }
        if (weekCursor == 0) {
            userWeekCursors[account] = currentWeek;
            return 0;
        }

        // The week of the last user checkpoint has ended.
        uint256 lastBalance = userLastBalances[account];
        uint256 rewards = lastBalance > 0
            ? lastBalance.mul(rewardsPerWeek[weekCursor]) / veSupplyPerWeek[weekCursor]
            : 0;
        weekCursor += System.SYSTEM_INTERVAL;

        // Iterate over succeeding weeks and calculate rewards.
        IVotingEscrow.LockedBalance memory lockedBalance = userLockedBalances[account];
        while (weekCursor < currentWeek) {
            uint256 veGoenBalance = _balanceAtTimestamp(lockedBalance, weekCursor);
            if (veGoenBalance == 0) {
                break;
            }
            // A positive veGoenBalance guarentees that veSupply of that week is also positive
            rewards = rewards.add(veGoenBalance.mul(rewardsPerWeek[weekCursor]) / veSupplyPerWeek[weekCursor]);
            weekCursor += System.SYSTEM_INTERVAL;
        }

        userWeekCursors[account] = currentWeek;
        userLastBalances[account] = _balanceAtTimestamp(lockedBalance, currentWeek);
        return rewards;
    }

    /// @notice Recalculate `nextWeekSupply` from scratch. This function eliminates accumulated
    ///         rounding errors in `nextWeekSupply`, which is incrementally updated in
    ///         `syncWithVotingEscrow()` and `checkpoint()`. It is almost never required.
    /// @dev See related test cases for details about the rounding errors.
    function calibrateSupply() external {
        uint256 nextWeek = _endOfWeek(checkpointTimestamp);
        nextWeekSupply = _totalSupplyAtTimestamp(nextWeek);
    }

    event UserClaimed(address user, uint256 amount);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "../library/CoreUtility.sol";
import "../library/ManagedPausable.sol";
import "../interfaces/IVotingEscrow.sol";
import "../library/ProxyUtility.sol";

interface IAddressWhitelist {
    function check(address account) external view returns (bool);
}

interface IVotingEscrowCallback {
    function syncWithVotingEscrow(address account) external;
}

contract VotingEscrow is
    IVotingEscrow,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    CoreUtility,
    ManagedPausable,
    ProxyUtility
{
    /// @dev Reserved storage slots for future base contract upgrades
    uint256[29] public _reservedSlots;

    using SafeMath for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    event LockCreated(address indexed account, uint256 amount, uint256 unlockTime, uint256 duration);

    event AmountIncreased(address indexed account, uint256 increasedAmount);

    event UnlockTimeIncreased(address indexed account, uint256 newUnlockTime, uint256 duration);

    event Withdrawn(address indexed account, uint256 amount);

    uint8 public constant decimals = 18;

    uint256 public maxTime;

    address public token;

    string public name;
    string public symbol;

    address public addressWhitelist;

    mapping(address => LockedBalance) public locked;

    /// @notice Mapping of unlockTime => total amount that will be unlocked at unlockTime
    mapping(uint256 => uint256) public scheduledUnlock;

    /// @notice max lock time allowed at the moment
    uint256 public maxTimeAllowed;

    /// @notice Contract to be call when an account"s locked Goen is updated
    address public callback;

    /// @notice Amount of Goen locked now. Expired locks are not included.
    uint256 public totalLocked;

    /// @notice Total veGoen at the end of the last checkpoint"s week
    uint256 public nextWeekSupply;

    /// @notice Mapping of week => vote-locked Goen total supplies
    ///
    ///         Key is the start timestamp of a week on each Thursday. Value is
    ///         vote-locked Goen total supplies captured at the start of each week
    mapping(uint256 => uint256) public veSupplyPerWeek;

    /// @notice Start timestamp of the trading week in which the last checkpoint is made
    uint256 public checkpointWeek;

    /// @dev Initialize the contract. The contract is designed to be used with OpenZeppelin"s
    ///      `TransparentUpgradeableProxy`. This function should be called by the proxy"s
    ///      constructor (via the `_data` argument).
    function initialize(
        address token_,
        uint256 maxTime_,
        string memory name_,
        string memory symbol_,
        uint256 maxTimeAllowed_
    ) external initializer {
        __Ownable_init();
        require(maxTimeAllowed_ <= maxTime_, "Cannot exceed max time");
        token = token_;
        maxTime = maxTime_;
        maxTimeAllowed = maxTimeAllowed_;
        _initializeV2(msg.sender, name_, symbol_);
    }

    /// @dev Initialize the part added in V2. If this contract is upgraded from the previous
    ///      version, call `upgradeToAndCall` of the proxy and put a call to this function
    ///      in the `data` argument.
    ///
    ///      In the previous version, name and symbol were not correctly initialized via proxy.

    function initializeV2(
        address pauser_,
        string memory name_,
        string memory symbol_
    ) external onlyProxyAdmin {
        _initializeV2(pauser_, name_, symbol_);
    }

    function _initializeV2(
        address pauser_,
        string memory name_,
        string memory symbol_
    ) public {
        _initializeManagedPausable(pauser_);
        require(bytes(name).length == 0 && bytes(symbol).length == 0);
        name = name_;
        symbol = symbol_;

        // Initialize totalLocked, nextWeekSupply and checkpointWeek
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 totalLocked_ = 0;
        uint256 nextWeekSupply_ = 0;
        for (uint256 weekCursor = nextWeek; weekCursor <= nextWeek + maxTime; weekCursor += System.SYSTEM_INTERVAL) {
            totalLocked_ = totalLocked_.add(scheduledUnlock[weekCursor]);
            nextWeekSupply_ = nextWeekSupply_.add((scheduledUnlock[weekCursor].mul(weekCursor - nextWeek)) / maxTime);
        }
        totalLocked = totalLocked_;
        nextWeekSupply = nextWeekSupply_;
        checkpointWeek = nextWeek - System.SYSTEM_INTERVAL;
    }

    function getMaxtime() external view override returns (uint256) {
        return maxTime;
    }

    function getTimestampDropBelow(address account, uint256 threshold) external view override returns (uint256) {
        LockedBalance memory lockedBalance = locked[account];
        if (lockedBalance.amount == 0 || lockedBalance.amount < threshold) {
            return 0;
        }
        return lockedBalance.unlockTime.sub(threshold.mul(maxTime).div(lockedBalance.amount));
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOfAtTimestamp(account, block.timestamp);
    }

    // calculate total veGoen every week , su
    function totalSupply() external view override returns (uint256) {
        uint256 weekCursor = checkpointWeek;
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 currentWeek = nextWeek - System.SYSTEM_INTERVAL;
        uint256 newNextWeekSupply = nextWeekSupply;
        uint256 newTotalLocked = totalLocked;
        if (weekCursor < currentWeek) {
            weekCursor += System.SYSTEM_INTERVAL;
            for (; weekCursor < currentWeek; weekCursor += System.SYSTEM_INTERVAL) {
                // Remove Goen unlocked at the beginning of the next week from total locked amount.
                newTotalLocked = newTotalLocked.sub(scheduledUnlock[weekCursor]);
                // Calculate supply at the end of the next week.
                newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(System.SYSTEM_INTERVAL) / maxTime);
            }
            newTotalLocked = newTotalLocked.sub(scheduledUnlock[weekCursor]);
            newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(block.timestamp - currentWeek) / maxTime);
        } else {
            newNextWeekSupply = newNextWeekSupply.add(newTotalLocked.mul(nextWeek - block.timestamp) / maxTime);
        }

        return newNextWeekSupply;
    }

    function getLockedBalance(address account) external view override returns (LockedBalance memory) {
        return locked[account];
    }

    function balanceOfAtTimestamp(address account, uint256 timestamp) external view override returns (uint256) {
        return _balanceOfAtTimestamp(account, timestamp);
    }

    function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256) {
        return _totalSupplyAtTimestamp(timestamp);
    }

    function createLock(uint256 amount, uint256 unlockTime) external nonReentrant whenNotPaused {
        _assertNotContract();
        require(unlockTime + System.SYSTEM_INTERVAL == _endOfWeek(unlockTime), "Unlock time must be end of a week");

        LockedBalance memory lockedBalance = locked[msg.sender];

        require(amount > 0, "Zero value");
        require(lockedBalance.amount == 0, "Withdraw old tokens first");
        require(unlockTime > block.timestamp, "Can only lock until time in the future");
        require(unlockTime <= block.timestamp + maxTimeAllowed, "Voting lock cannot exceed max lock time");
        // checkpoint of total
        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, amount, unlockTime);
        scheduledUnlock[unlockTime] = scheduledUnlock[unlockTime].add(amount);
        locked[msg.sender].unlockTime = unlockTime;
        locked[msg.sender].amount = amount;

        IERC20Upgradeable(token).safeTransferFrom(msg.sender, address(this), amount);

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }
        uint256 duration = _duration(unlockTime, block.timestamp);
        emit LockCreated(msg.sender, amount, unlockTime, duration);
    }

    function increaseAmount(address account, uint256 amount) external nonReentrant whenNotPaused {
        LockedBalance memory lockedBalance = locked[account];

        require(amount > 0, "Zero value");
        require(lockedBalance.unlockTime > block.timestamp, "Cannot add to expired lock");

        uint256 newAmount = lockedBalance.amount.add(amount);
        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, newAmount, lockedBalance.unlockTime);
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].add(amount);
        locked[account].amount = newAmount;

        IERC20Upgradeable(token).safeTransferFrom(msg.sender, address(this), amount);

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit AmountIncreased(account, amount);
    }

    function increaseUnlockTime(uint256 unlockTime_) external nonReentrant whenNotPaused {
        require(unlockTime_ + System.SYSTEM_INTERVAL == _endOfWeek(unlockTime_), "Unlock time must be end of a week");
        LockedBalance memory lockedBalance = locked[msg.sender];

        require(lockedBalance.unlockTime > block.timestamp, "Lock expired");
        require(unlockTime_ > lockedBalance.unlockTime, "Can only increase lock duration");
        require(unlockTime_ <= block.timestamp + maxTimeAllowed, "Voting lock cannot exceed max lock time");
        uint256 duration = _duration(unlockTime_, lockedBalance.unlockTime);
        _checkpoint(lockedBalance.amount, lockedBalance.unlockTime, lockedBalance.amount, unlockTime_);
        scheduledUnlock[lockedBalance.unlockTime] = scheduledUnlock[lockedBalance.unlockTime].sub(lockedBalance.amount);
        scheduledUnlock[unlockTime_] = scheduledUnlock[unlockTime_].add(lockedBalance.amount);
        locked[msg.sender].unlockTime = unlockTime_;

        if (callback != address(0)) {
            IVotingEscrowCallback(callback).syncWithVotingEscrow(msg.sender);
        }

        emit UnlockTimeIncreased(msg.sender, unlockTime_, duration);
    }

    function withdraw() external nonReentrant {
        LockedBalance memory lockedBalance = locked[msg.sender];
        require(block.timestamp >= lockedBalance.unlockTime, "The lock is not expired");
        uint256 amount = uint256(lockedBalance.amount);

        lockedBalance.unlockTime = 0;
        lockedBalance.amount = 0;
        locked[msg.sender] = lockedBalance;

        IERC20Upgradeable(token).safeTransfer(msg.sender, amount);

        emit Withdrawn(msg.sender, amount);
    }

    function updateAddressWhitelist(address newWhitelist_) external onlyOwner {
        require(
            newWhitelist_ == address(0) || AddressUpgradeable.isContract(newWhitelist_),
            "Must be null or a contract"
        );
        addressWhitelist = newWhitelist_;
    }

    function updateCallback(address newCallback_) external onlyOwner {
        require(
            newCallback_ == address(0) || AddressUpgradeable.isContract(newCallback_),
            "Must be null or a contract"
        );
        callback = newCallback_;
    }

    function _assertNotContract() private view {
        if (msg.sender != tx.origin) {
            if (addressWhitelist != address(0) && IAddressWhitelist(addressWhitelist).check(msg.sender)) {
                return;
            }
            revert("Smart contract depositors not allowed");
        }
    }

    function _balanceOfAtTimestamp(address account_, uint256 timestamp_) private view returns (uint256) {
        require(timestamp_ >= block.timestamp, "Must be current or future time");
        LockedBalance memory lockedBalance = locked[account_];
        if (timestamp_ > lockedBalance.unlockTime) {
            return 0;
        }
        return (lockedBalance.amount.mul(lockedBalance.unlockTime - timestamp_)) / maxTime;
    }

    function _totalSupplyAtTimestamp(uint256 timestamp_) private view returns (uint256) {
        uint256 weekCursor = _endOfWeek(timestamp_);
        uint256 total = 0;
        for (; weekCursor <= timestamp_ + maxTime; weekCursor += System.SYSTEM_INTERVAL) {
            total = total.add((scheduledUnlock[weekCursor].mul(weekCursor - timestamp_)) / maxTime);
        }
        return total;
    }

    /// @dev Pre-conditions:
    ///
    ///      - `newAmount > 0`
    ///      - `newUnlockTime > block.timestamp`
    ///      - `newUnlockTime +System.SYSTEM_INTERVAL == _endOfWeek(newUnlockTime)`, i.e. aligned to a trading week
    ///
    ///      The latter two conditions gaurantee that `newUnlockTime` is no smaller than the local
    ///      variable `nextWeek` in the function.
    function _checkpoint(
        uint256 oldAmount_,
        uint256 oldUnlockTime_,
        uint256 newAmount_,
        uint256 newUnlockTime_
    ) private {
        // Update veGoen supply at the beginning of each week since the last checkpoint.
        uint256 weekCursor = checkpointWeek;
        uint256 nextWeek = _endOfWeek(block.timestamp);
        uint256 currentWeek = nextWeek - System.SYSTEM_INTERVAL;
        uint256 newTotalLocked = totalLocked;
        uint256 newNextWeekSupply = nextWeekSupply;
        if (weekCursor < currentWeek) {
            for (uint256 w = weekCursor + System.SYSTEM_INTERVAL; w <= currentWeek; w += System.SYSTEM_INTERVAL) {
                veSupplyPerWeek[w] = newNextWeekSupply;
                // Remove Goen unlocked at the beginning of this week from total locked amount.
                newTotalLocked = newTotalLocked.sub(scheduledUnlock[w]);
                // Calculate supply at the end of the next week.
                newNextWeekSupply = newNextWeekSupply.sub(newTotalLocked.mul(System.SYSTEM_INTERVAL) / maxTime);
            }
            checkpointWeek = currentWeek;
        }

        // Remove the old schedule if there is one
        if (oldAmount_ > 0 && oldUnlockTime_ >= nextWeek) {
            newTotalLocked = newTotalLocked.sub(oldAmount_);
            newNextWeekSupply = newNextWeekSupply.sub(oldAmount_.mul(oldUnlockTime_ - nextWeek) / maxTime);
        }

        totalLocked = newTotalLocked.add(newAmount_);
        // Round up on division when added to the total supply, so that the total supply is never
        // smaller than the sum of all accounts"veGoen balance.
        nextWeekSupply = newNextWeekSupply.add(newAmount_.mul(newUnlockTime_ - nextWeek).add(maxTime - 1) / maxTime);
    }

    function _duration(uint256 unlockTime_, uint256 timestamp_) private pure returns (uint256 duration_) {
        uint256 remainder = (unlockTime_ - timestamp_).mod(System.SYSTEM_INTERVAL);
        duration_ = (unlockTime_ - timestamp_).div(System.SYSTEM_INTERVAL);
        return duration_ = remainder > 0 ? duration_ + 1 : duration_;
    }

    function updateMaxTimeAllowed(uint256 newMaxTimeAllowed_) external onlyOwner {
        require(newMaxTimeAllowed_ <= maxTime, "Cannot exceed max time");
        require(newMaxTimeAllowed_ > maxTimeAllowed, "Cannot shorten max time allowed");
        maxTimeAllowed = newMaxTimeAllowed_;
    }

    /// @notice Recalculate `nextWeekSupply` from scratch. This function eliminates accumulated
    ///         rounding errors in `nextWeekSupply`, which is incrementally updated in
    ///         `createLock`, `increaseAmount` and `increaseUnlockTime`. It is almost
    ///         never required.
    /// @dev Search "rounding error" in test cases for details about the rounding errors.
    function calibrateSupply() external {
        uint256 nextWeek = checkpointWeek + System.SYSTEM_INTERVAL;
        nextWeekSupply = _totalSupplyAtTimestamp(nextWeek);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

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
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";

library SafeDecimalMath {
    using SafeMath for uint256;

    /* Number of decimal places in the representations. */
    uint256 private constant decimals = 18;
    uint256 private constant highPrecisionDecimals = 27;

    /* The number representing 1.0. */
    uint256 private constant UNIT = 10**uint256(decimals);

    /* The number representing 1.0 for higher fidelity numbers. */
    uint256 private constant PRECISE_UNIT = 10**uint256(highPrecisionDecimals);
    uint256 private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR =
        10**uint256(highPrecisionDecimals - decimals);

    /**
     * @return The result of multiplying x and y, interpreting the operands as fixed-point
     * decimals.
     *
     * @dev A unit factor is divided out after the product of x and y is evaluated,
     * so that product must be less than 2**256. As this is an integer division,
     * the internal division always rounds down. This helps save on gas. Rounding
     * is more expensive on gas.
     */
    function multiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y).div(UNIT);
    }

    function multiplyDecimalPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return x.mul(y).div(PRECISE_UNIT);
    }

    /**
     * @return The result of safely dividing x and y. The return value is a high
     * precision decimal.
     *
     * @dev y is divided after the product of x and the standard precision unit
     * is evaluated, so the product of x and UNIT must be less than 2**256. As
     * this is an integer division, the result is always rounded down.
     * This helps save on gas. Rounding is more expensive on gas.
     */
    function divideDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(UNIT).div(y);
    }

    function divideDecimalPrecise(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Reintroduce the UNIT factor that will be divided out by y. */
        return x.mul(PRECISE_UNIT).div(y);
    }

    /**
     * @dev Convert a standard decimal representation to a high precision one.
     */
    function decimalToPreciseDecimal(uint256 i) internal pure returns (uint256) {
        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    /**
     * @dev Convert a high precision decimal to a standard decimal representation.
     */
    function preciseDecimalToDecimal(uint256 i) internal pure returns (uint256) {
        uint256 quotientTimesTen = i.mul(10).div(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen = quotientTimesTen.add(10);
        }

        return quotientTimesTen.div(10);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, and the max value of
     * uint256 on overflow.
     */
    function saturatingMul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c / a != b ? type(uint256).max : c;
    }

    function saturatingMultiplyDecimal(uint256 x, uint256 y) internal pure returns (uint256) {
        /* Divide by UNIT to remove the extra factor introduced by the product. */
        return saturatingMul(x, y).div(UNIT);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./System.sol";

abstract contract CoreUtility {
    using SafeMath for uint256;
    uint256 internal constant DURATION = 1 days;
    uint256 internal constant START_TIME = 1648789200;
    /// @dev UTC time of a day when the fund settles.
    

    /// @dev Return end timestamp of the trading week containing a given timestamp.
    ///
    ///      A trading week starts at UTC time `SETTLEMENT_TIME` on a Thursday (inclusive)
    ///      and ends at the same time of the next Thursday (exclusive).
    /// @param timestamp The given timestamp
    /// @return End timestamp of the trading week.
    function _endOfWeek(uint256 timestamp) internal pure returns(uint256) {
        return ((timestamp.sub(START_TIME) / DURATION) + 1) * DURATION + START_TIME;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;
pragma experimental ABIEncoderV2;

interface IVotingEscrow {
    struct LockedBalance {
        uint256 amount;
        uint256 unlockTime;
    }

    function getMaxtime() external view returns(uint256);

    function balanceOf(address account) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function balanceOfAtTimestamp(address account, uint256 timestamp) external view returns (uint256);

    function getTimestampDropBelow(address account, uint256 threshold) external view returns (uint256);

    function getLockedBalance(address account) external view returns (LockedBalance memory);
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWrappedERC20 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20Upgradeable {
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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

pragma solidity >=0.6.0 <0.8.0;

import "./IERC20Upgradeable.sol";
import "../../math/SafeMathUpgradeable.sol";
import "../../utils/AddressUpgradeable.sol";

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
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;

    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Contract of an emergency stop mechanism that can be triggered by an authorized account.
 *
 * This module is modified based on Pausable in OpenZeppelin v3.3.0, adding public functions to
 * pause, unpause and manage the pauser role. It is also designed to be used by upgradable
 * contracts, like PausableUpgradable but with compact storage slots and no dependencies.
 */
abstract contract ManagedPausable {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**AC
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    event PauserRoleTransferred(address indexed previousPauser, address indexed newPauser);

    uint256 private constant FALSE = 0;
    uint256 private constant TRUE = 1;

    uint256 private _initialized;

    uint256 private _paused;

    address private _pauser;

    function _initializeManagedPausable(address pauser_) internal {
        require(_initialized == FALSE);
        _initialized = TRUE;
        _paused = FALSE;
        _pauser = pauser_;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused != FALSE;
    }

    function pauser() public view returns (address) {
        return _pauser;
    }

    function renouncePauserRole() external onlyPauser {
        emit PauserRoleTransferred(_pauser, address(0));
        _pauser = address(0);
    }

    function transferPauserRole(address newPauser) external onlyPauser {
        require(newPauser != address(0));
        emit PauserRoleTransferred(_pauser, newPauser);
        _pauser = newPauser;
    }

    modifier onlyPauser() {
        require(_pauser == msg.sender, "Pausable: only pauser");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(_paused == FALSE, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused != FALSE, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external onlyPauser whenNotPaused {
        _paused = TRUE;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external onlyPauser whenPaused {
        _paused = FALSE;
        emit Unpaused(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.10 <0.8.0;

abstract contract ProxyUtility {
    /// @dev Storage slot with the admin of the contract.
    bytes32 private constant _ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    /// @dev Revert if the proxy admin is not the caller
    modifier onlyProxyAdmin() {
        bytes32 slot = _ADMIN_SLOT;
        address proxyAdmin;
        assembly {
            proxyAdmin := sload(slot)
        }
        require(msg.sender == proxyAdmin, "Only proxy admin");
        _;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}