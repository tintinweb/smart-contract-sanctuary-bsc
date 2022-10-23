//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./IERC20.sol";
import "./Ownable.sol";

interface IHarvester {
    function harvest() external;
}

interface IBank {
    function harvestDividends() external;
}

interface IStaking {
    function depositRewards(address reward, uint256 amount) external;
}

interface IPriceOracle {
    function priceOf(address token) external view returns (uint256);
}

interface IWETH {
    function deposit() external payable;
}

contract Harvester is IHarvester, Ownable {

    /**
        Daily Rate Scale
     */
    uint256 public constant DAILY_RATE_SCALE = 10**18;

    /**
        Blocks Per Day
     */
    uint256 public constant blocks_per_day = 28800;

    /**
        Wrapped Native Asset
     */
    address private immutable WETH;

    /**
        Token For Pool 0
     */
    address public immutable poolToken0;

    /**
        Token For Pool 1
     */
    address public immutable poolToken1;

    /**
        Betswirl Bank Contract
     */
    IBank public bank;

    /**
        Price Oracle Contract
     */
    IPriceOracle public priceOracle;

    /**
        Reward Token Structure For Tracking APY
     */
    struct RewardToken {
        uint256 dailyRatePool0;
        uint256 dailyRatePool1;
        uint256 lastRewardBlockPool0;
        uint256 lastRewardBlockPool1;   
    }

    /**
        Reward Token => RewardToken APY Structure
     */
    mapping ( address => RewardToken ) public rewardTokens;

    /**
        List Of Reward Tokens
     */
    address[] public allRewardTokens;

    /**
        Both Staking Pools
     */
    address public pool0;
    address public pool1;

    /**
        Initialize Important Variables
     */
    constructor(
        address WETH_,
        address poolToken0_,
        address poolToken1_,
        address pool0_,
        address pool1_,
        address bank_,
        address priceOracle_
    ) {

        // initialize immutables
        WETH = WETH_;
        poolToken0 = poolToken0_;
        poolToken1 = poolToken1_;

        // initialize other variables
        pool0 = pool0_;
        pool1 = pool1_;
        bank = IBank(bank_);
        priceOracle = IPriceOracle(priceOracle_);
    }

    /**
        Sets Pool 0
     */
    function setPool0(address pool0_) external onlyOwner {
        pool0 = pool0_;
    }

    /**
        Sets Pool 1
     */
    function setPool1(address pool1_) external onlyOwner {
        pool1 = pool1_;
    }

    /**
        Sets The Bank Smart Contract
     */
    function setBank(address bank_) external onlyOwner {
        bank = IBank(bank_);
    }

    /**
        Adds A Reward Token To The List Of Reward Tokens
     */
    function addRewardToken(address rewardToken, uint256 newDailyRatePool0, uint256 newDailyRatePool1) external onlyOwner {
        allRewardTokens.push(rewardToken);
        rewardTokens[rewardToken].lastRewardBlockPool0 = block.number;
        rewardTokens[rewardToken].lastRewardBlockPool1 = block.number;

        rewardTokens[rewardToken].dailyRatePool0 = newDailyRatePool0;
        rewardTokens[rewardToken].dailyRatePool1 = newDailyRatePool1;
    }

    /**
        Resets Reward Timers
     */
    function resetRewardTimers(address rewardToken, bool forPool0) external onlyOwner {
        if (forPool0) {
            rewardTokens[rewardToken].lastRewardBlockPool0 = block.number;
        } else {
            rewardTokens[rewardToken].lastRewardBlockPool1 = block.number;
        }
    }

    /**
        Removes A Reward Token From The List Of Reward Tokens
     */
    function removeRewardToken(address rewardToken) external onlyOwner {
        uint index = allRewardTokens.length;

        for (uint i = 0; i < allRewardTokens.length; i++) {
            if (allRewardTokens[i] == rewardToken) {
                index = i;
                break;
            }
        }
        require(index < allRewardTokens.length, 'Token Not Found');

        allRewardTokens[index] = allRewardTokens[allRewardTokens.length - 1];
        allRewardTokens.pop();
        delete rewardTokens[rewardToken];
    }

    /**
        Sets The Address Of The Price Oracle Smart Contract
     */
    function setPriceOracle(address newOracle) external onlyOwner {
        priceOracle = IPriceOracle(newOracle);
    }

    /**
        Sets The Daily Rate Of `rewardToken` scaled by 10^18
        A Daily Rate Of 10**18 means a max of 1% per day (3,778% APY)
     */
    function setRewardTokenAPY(address rewardToken, uint256 newDailyRate, uint256 newDailyRatePool1) external onlyOwner {
        rewardTokens[rewardToken].dailyRatePool0 = newDailyRate;
        rewardTokens[rewardToken].dailyRatePool1 = newDailyRatePool1;
    }

    /**
        Withdraws Reward Tokens Sent To Contract
     */
    function withdrawToken(address token_) external onlyOwner {
        IERC20(token_).transfer(
            msg.sender,
            IERC20(token_).balanceOf(address(this))
        );
    }

    /**
        Withdraws Native Chain Asset Sent To Contract
     */
    function withdrawNative() external onlyOwner {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s, 'Failure To Withdraw Native');
    }

    /**
        Harvests Dividends From Bank, Splitting Them Up For Each Pool
     */
    function harvest() external {

        // harvest dividends from bank
        try bank.harvestDividends() {} catch {}

        // split up rewards between both pools
        uint sAmount;
        uint vAmount;
        uint length = allRewardTokens.length;

        for (uint i = 0; i < length;) {

            // current reward token
            address rToken = allRewardTokens[i];
            
            // split balance between both pools
            (sAmount, vAmount) = splitAmountForPools(rToken);

            // If Pool 0 Amount Exists, Send To Pool 0
            if (sAmount > 0) {
                rewardTokens[rToken].lastRewardBlockPool0 = block.number;
                IERC20(rToken).approve(pool0, sAmount);
                IStaking(pool0).depositRewards(rToken, sAmount);
            }

            // If Pool 1 Amount Exists, Send To Pool 1
            if (vAmount > 0) {
                rewardTokens[rToken].lastRewardBlockPool1 = block.number;
                IERC20(rToken).approve(pool1, vAmount);
                IStaking(pool1).depositRewards(rToken, vAmount);
            }

            unchecked{ ++i; }
        }
    }

    /**
        Converts Any Native Assets Received Into Its Wrapped Version
     */
    receive() external payable {
        IWETH(WETH).deposit{value: address(this).balance}();
    }

    /**
        Splits balance of `rewardToken` into portions for both Pools
        Ensures The Maximum Daily Rate Is Preserved
     */
    function splitAmountForPools(address rewardToken) public view returns (uint256 pool0Amount, uint256 pool1Amount) {

        // fetch approximate amounts to receive for both pools
        (uint256 sApprox, uint256 vApprox) = determineApproximateAmountsForPools(rewardToken);

        // return precise amount to send
        pool0Amount = determineAmountToGet(rewardToken, sApprox, false);
        pool1Amount = determineAmountToGet(rewardToken, vApprox, true);
    }

    /**
        Returns An Approximate Amount Of `rewardToken` To Distribute To Both Pools
        Based Off The Value In Each Pool, Time Since Last Reward Was Given, And The Set Daily Rates
     */
    function determineApproximateAmountsForPools(
        address rewardToken
    ) public view returns (uint256, uint256) {

        // balance of reward token
        uint256 amount = balanceOf(rewardToken);
        
        // return zeros out if no rewards are to be given
        if (amount == 0) {
            return (0, 0);
        }

        if (pool1 == address(0)) {
            return (amount, 0);
        }

        // scale amounts by value in pools, reward blocks passed, and daily rates
        uint256 pool0Points = valueInPool(false) * timeSincePool0(rewardToken) * rewardTokens[rewardToken].dailyRatePool0;
        uint256 pool1Points       = valueInPool(true) * timeSincePool1(rewardToken) * rewardTokens[rewardToken].dailyRatePool1;

        // denominator is the sum of both points
        uint denom = pool1Points + pool0Points;
        if (denom == 0) {
            return (0, 0);
        }

        // pool 0 amount out is balance * points / denom
        uint sAmount = ( amount * pool0Points ) / denom;
        
        // return sAmount and the difference between amount and sAmount
        return(
            sAmount,
            amount - sAmount
        );
    }

    /**
        Returns The Amount Of `rewardToken` To Be Sent To Either Pool0 Or Pool1
        Based Off The Approximated Value Passed In To This Function And The Set Daily Rate
     */
    function determineAmountToGet(
        address rewardToken,
        uint256 approxAmount,
        bool forPool1
    ) public view returns (uint256) {

        // return 0 if no approx tokens to send
        if (approxAmount == 0) {
            return 0;
        }

        // value of reward in USD
        uint256 rewardValue = valueOfReward(rewardToken, approxAmount);

        // determine the USD Value Owed
        uint256 usdOwed = determineAmountOwed(rewardToken, forPool1);

        // if APY is exceeded, reduce balance, else use full balance
        return usdOwed < rewardValue ? ( approxAmount * usdOwed ) / rewardValue : approxAmount;
    }

    /**
        Returns The USD Value Owed To Maintain The Maximum APY Limit Set By rewardToken For The Designated Pool
     */
    function determineAmountOwed(
        address rewardToken,
        bool forPool1
    ) public view returns (uint256) {

        // time since last reward
        uint256 blocksPassed = forPool1 ? timeSincePool1(rewardToken) : timeSincePool0(rewardToken);

        // value in pool
        uint256 usdInPool = valueInPool(forPool1);

        // calculate rewards per block to reach daily rate, multiply by blocks passed
        // ( value * rate ) * ( blocksPassed / blocks_per_day )
        return ( blocksPassed * usdInPool * getDailyRate(rewardToken, forPool1) ) / ( 10**18 * blocks_per_day );
    }

    function getDailyRate(address rewardToken, bool forPool1) public view returns (uint256) {
        return forPool1 ? rewardTokens[rewardToken].dailyRatePool1 : rewardTokens[rewardToken].dailyRatePool0;
    }

    /**
        Returns The Balance Of `token` in this contract
     */
    function balanceOf(address token) public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    /**
        Returns The USD Value Of Pool Tokens in the specified address
     */
    function valueInPool(bool forPool1) public view returns (uint256) {
        return valueInAddress(
            forPool1 ? poolToken1 : poolToken0,
            forPool1 ? pool1 : pool0
        );
    }

    /**
        Returns The USD Value Of Pool Tokens in the specified address
     */
    function valueInAddress(address token, address wallet) public view returns (uint256) {
        if (token == address(0) || wallet == address(0)) {
            return 0;
        }

        uint bal = IERC20(token).balanceOf(wallet);
        uint val = priceOracle.priceOf(token);
        return ( bal * val ) / 10**IERC20(token).decimals();
    }

    /**
        Returns The USD Value Of `amount` of `reward` token
     */
    function valueOfReward(address reward, uint256 amount) public view returns (uint256) {
        uint val = priceOracle.priceOf(reward);
        return ( amount * val ) / 10**IERC20(reward).decimals();
    }

    /**
        Lists All Registered Reward Tokens
     */
    function viewAllRewardTokens() external view returns (address[] memory) {
        return allRewardTokens;
    }

    /**
        Returns The Number Of Blocks Since The Last Reward Was Distributed To Pool 0
     */
    function timeSincePool0(address rewardToken_) public view returns (uint256) {
        if (rewardTokens[rewardToken_].lastRewardBlockPool0 == 0) {
            return 0;
        }
        return rewardTokens[rewardToken_].lastRewardBlockPool0 >= block.number ? 0 : block.number - rewardTokens[rewardToken_].lastRewardBlockPool0;
    }

    /**
        Returns The Number Of Blocks Since The Last Reward Was Distributed To Pool 1
     */
    function timeSincePool1(address rewardToken_) public view returns (uint256) {
        if (rewardTokens[rewardToken_].lastRewardBlockPool1 == 0) {
            return 0;
        }
        return rewardTokens[rewardToken_].lastRewardBlockPool1 >= block.number ? 0 : block.number - rewardTokens[rewardToken_].lastRewardBlockPool1;
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}