// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IAskoRiskToken.sol";

contract AllStarsFarm is Ownable {
    using SafeERC20 for IERC20;

    /**
     * @notice Info of each token's risk tokens
     * @param lr: the address of low risk token
     * @param hr: the address of high risk token
     */
    struct RiskToken {
        address lr;
        address hr;
    }

    /**
     * @notice Info of each stake
     * @param amount: amount of user's stake
     * @param checkpoint: blocknumber of user's last action
     * @param endBlock: the last block for which user will get rewards
     */
    struct Stake {
        uint256 amount;
        uint256 checkpoint;
        uint256 endBlock;
    }

    /**
     * @notice Info of each reward token
     * @param id: the id of token in rewardTokens array
     * @param apr: the APR for the token (basis point required)
     */
    struct RewardToken {
        uint256 id;
        uint256 apr;
    }

    uint256 public withdrawFee = 1000; // 10% of the withdrawing amount (basis point used),  TODO: change by exact number
    uint256 public minStakeAmount; // TODO: change by function to calculate minStakeAmount
    address public constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; 

    address public immutable treasury; // Address of the treasury account
    uint256 public blocksPerDay = 28000; // Approximate number of blocks per day
    uint256 public lockPeriod; // lock period for stake in AllStars Farm
    uint256 public userCounter; // users total Count
    uint256 public minAmountForSecondGroup; 
    uint256 public minAmountForThirdGroup; 
    uint256 public minAmountForFourthGroup; 

    address[] public rewardTokens; // The array of tokens given as reward

    // TODO: Get hr/lr tokens info from rAsko contracts (ask Mark for docs)
    mapping(address => RiskToken) public riskTokens; // address of token => addresses of risk tokens
    mapping(address => RewardToken) public rewardTokenInfo; // address of reward token => info of reward token
    mapping(address => mapping(address => Stake)) public stakes; // address of user => address of risk token => stake
    mapping(bytes32 => address) public seedToUser; // mapping to keep info for NFT reward distribution

    IUniswapV2Router02 public router; // PancakeSwap router

    event Staked(address user, address token, address stakedToken, uint256 amount, uint256 amountInBUSD, uint8 groupNumber);
    event Withdrawn(address user, address token, address stakedToken, uint256 amount);
    event Reinvested(address user, address stakedToken, uint256 amount);

    /**
     * @notice Modifier to check if token is in the list of approved tokens
     * @param token_: address of the token
     */

    modifier isInList(address token_) {
        require(riskTokens[token_].lr != address(0), "AllStarsFarm: Inappropriate token!");
        _;
    }

    constructor(address treasury_, address router_, uint256 minAmountForSecondGroup_, uint256 minAmountForThirdGroup_, uint256 minAmountForFourthGroup_) {
        require(treasury_ != address(0), "AllStarsFarm: Treasury can not be zero");

        treasury = treasury_;
        lockPeriod = 60 * blocksPerDay;
        router = IUniswapV2Router02(router_);
        minAmountForSecondGroup = minAmountForSecondGroup_;
        minAmountForThirdGroup = minAmountForThirdGroup_;
        minAmountForFourthGroup = minAmountForFourthGroup_;
    }

    /**
     * @notice Function to add token to the list of approved tokens
     * @param token_: address of the token to add to the list of approved tokens
     * @param lrToken_: address of the low risk token
     * @param hrToken_: address of the high risk token
     */

    function addToken(
        address token_,
        address lrToken_,
        address hrToken_
    ) external onlyOwner {
        require(token_ != address(0), "AllStarsFarm: Token can't be zero address!");
        require(lrToken_ != address(0), "AllStarsFarm: LRToken can't be zero address!");
        require(hrToken_ != address(0), "AllStarsFarm: HRToken can't be zero address!");
        RiskToken storage tokens = riskTokens[token_];
        require(tokens.lr == address(0), "AllStarsFarm: Token is already in the list!");

        tokens.lr = lrToken_;
        tokens.hr = hrToken_;
    }

    /**
     * @notice Function to remove token from the list of approved tokens
     * @param token_: address of the token to remove from the list
     */

    function removeToken(address token_) external onlyOwner isInList(token_) {
        delete riskTokens[token_];
        // Maybe allow users to withdraw without lock period if the token has been deleted?
    }

    /**
     * @notice Function to add reward token
     * @param token_: address of the reward token to add
     * @param amount_: amount to add
     * @param apr_: the APR for the token (basis point required)
     */

    function addRewardToken(
        address token_,
        uint256 amount_,
        uint256 apr_ // Check how this is calculated
    ) external onlyOwner {
        require(token_ != address(0), "AllStarsFarm: RewardToken can't be zero address!");
        require(amount_ > 0, "AllStarsFarm: RewardToken amount can't be zero!");
        require(apr_ > 0, "AllStarsFarm: APR can't be zero!");

        RewardToken storage rewardToken = rewardTokenInfo[token_];

        if (rewardToken.apr == 0) {
            rewardTokens.push(token_);
            rewardToken.id = rewardTokens.length - 1;
        }
        rewardToken.apr = apr_;

        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
    }

    /**
     * @notice Function to remove reward token
     * @param token_: address of the reward token to remove
     */

    function removeRewardToken(address token_) external onlyOwner {
        RewardToken storage rewardToken = rewardTokenInfo[token_];
        require(rewardToken.apr > 0, "AllStarsFarm: RewardToken is not in list!");
        require(rewardTokens.length > 1, "AllStarsFarm: Can't remove last reward token!");
        uint256 amount = IERC20(token_).balanceOf(address(this));

        address lastToken = rewardTokens[rewardTokens.length - 1];
        rewardTokens[rewardToken.id] = lastToken;
        rewardTokenInfo[lastToken].id = rewardToken.id;
        rewardTokens.pop();

        delete rewardTokenInfo[token_];

        if (amount > 0) {
            IERC20(token_).safeTransfer(treasury, amount);
        }
    }

    function computeUniqueSeedForNFTRewards(uint256 userCounter_, uint8 groupNumber_) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(userCounter_, groupNumber_));
    }

    /**
     * @notice Function to get token "price" in BUSD /// can be reason for attacs
     */
    function getBUSDForToken(address token_, uint256 amount_) public view returns (uint256) {
        address[] memory path = new address[](2);
        (path[0], path[1]) = (token_, BUSD_ADDRESS);
        uint256[] memory amounts = router.getAmountsOut(amount_, path);
        return amounts[1];
    }

    /**
     * @notice Function to stake tokens
     * @param token_: token from list of approved tokens
     * @param amount_: amount to stake
     * @param isLowRisk_: bool to know the token is LR or HR
     */
    function stake(
        address token_,
        uint256 amount_,
        bool isLowRisk_
    ) external isInList(token_) {
        address stakedToken;
        if (isLowRisk_) {
            stakedToken = riskTokens[token_].lr;
        } else {
            stakedToken = riskTokens[token_].hr;
        }
        uint256 tokenAmount = IAskoRiskToken(stakedToken).exchangeRatePrior() * amount_;
        uint256 amountInBUSD = getBUSDForToken(token_, tokenAmount);
        require(amountInBUSD >= minStakeAmount, "AllStarsFarm: Insufficient amount!");
        uint8 groupNumber;
        if (amountInBUSD < minAmountForSecondGroup) {
            groupNumber = 1;
        } else if (amountInBUSD < minAmountForThirdGroup) {
            groupNumber = 2;
        } else if (amountInBUSD < minAmountForFourthGroup) {
            groupNumber = 3;
        } else {
            groupNumber = 4;
        }

        _stake(stakedToken, amount_, groupNumber);
        emit Staked(msg.sender, token_, stakedToken, amount_, amountInBUSD, groupNumber);
    }

    /**
     * @notice Function to reinvest staked tokens
     * @param stakedToken_: token to reinvest
     */

    function reinvest(address stakedToken_) external {
        Stake storage userStake = stakes[msg.sender][stakedToken_];

        require(userStake.amount > 0, "AllStarsFarm: You have no stakes to reinvest!");
        userStake.endBlock = block.number + lockPeriod;

        emit Reinvested(msg.sender, stakedToken_, userStake.amount);
    }

    /**
     * @notice Function to withdraw staked tokens
     * @param token_: token from list of approved tokens
     * @param amount_: amount to stake
     * @param isLowRisk_: bool to know the token is LR or HR
     */

    function withdraw(
        address token_,
        uint256 amount_,
        bool isLowRisk_
    ) external isInList(token_) {
        require(amount_ > 0, "AllStarsFarm: Insufficient amount!");
        address stakedToken;
        if (isLowRisk_) {
            stakedToken = riskTokens[token_].lr;
            _withdrawLR(stakedToken, amount_);
        } else {
            stakedToken = riskTokens[token_].hr;
            _withdrawHR(stakedToken, amount_);
        }
        emit Withdrawn(msg.sender, token_, stakedToken, amount_);
    }

    /**
     * @notice Claim tokens stored as reward
     * @param stakedToken_: token to claim rewards for
     */
    function claimRewards(address stakedToken_) external {
        Stake memory userStake = stakes[msg.sender][stakedToken_];
        require(userStake.amount > 0, "AllStarsFarm: You have no rewards to claim");
        _claimRewards(stakedToken_);
    }

    /**
     * @notice Function to calculate tokens stored as reward, return amount of each reward token
     * @param stakeholder_: the address of stakeHolder
     * @param token_: the address of reward token
     * @param stakedToken_: the address of token to claim rewards for
     */
    function pendingReward(
        address stakeholder_,
        address token_,
        address stakedToken_
    ) public view returns (uint256) {
        Stake memory userStake = stakes[stakeholder_][stakedToken_];
        uint256 blocksPassed;
        if (block.number > userStake.endBlock) {
            blocksPassed = userStake.endBlock - userStake.checkpoint;
        } else {
            blocksPassed = block.number - userStake.checkpoint;
        }
        return ((userStake.amount * blocksPassed * getRewardPerBlock(rewardTokenInfo[token_].apr, blocksPerDay)) / 1e18);
    }

    /**
     * @notice Function to set new avarage blocks per day
     * @param blocksPerDay_: the avarage amount of blocks mined per day
     */

    function setBlocksPerDay(uint256 blocksPerDay_) external onlyOwner {
        lockPeriod = 60 * blocksPerDay_;
        blocksPerDay = blocksPerDay_;
    }

    /**
     * @notice Function to set new withdraw fee
     * @param newWithdrawFee_: the new withdraw fee to set
     */

    function setWithdrawFee(uint256 newWithdrawFee_) external onlyOwner {
        withdrawFee = newWithdrawFee_;
    }

    /**
     * @notice Function to set new min stake amount for second group
     * @param newMinAmountForSecondGroup_: the new min stake amount to set
     */
     
    function setMinAmountForSecondGroup(uint256 newMinAmountForSecondGroup_) external onlyOwner {
        minAmountForSecondGroup = newMinAmountForSecondGroup_;
    }

    /**
     * @notice Function to set new min stake amount for third group
     * @param newMinAmountForThirdGroup_: the new min stake amount to set
     */
     
    function setMinAmountForThirdGroup(uint256 newMinAmountForThirdGroup_) external onlyOwner {
        minAmountForThirdGroup = newMinAmountForThirdGroup_;
    }

    /**
     * @notice Function to set new min stake amount for fourth group
     * @param newMinAmountForFourthGroup_: the new min stake amount to set
     */
     
    function setMinAmountForFourthGroup(uint256 newMinAmountForFourthGroup_) external onlyOwner {
        minAmountForFourthGroup = newMinAmountForFourthGroup_;
    }

    /**
     * @notice Function to set new min stake amount
     * @param newMinStakeAmount_: the new min stake amount to set
     */
     
    function setMinStakeAmount(uint256 newMinStakeAmount_) external onlyOwner {
        minStakeAmount = newMinStakeAmount_;
    }


    /**
     * @notice Function to get the amount of reward tokens per block, depending on given APR and average number blocks per day
     * @param apr_: the APR for the token (basis point required)
     */

    function getRewardPerBlock(uint256 apr_, uint256 blocksPerDay_) public pure returns (uint256 rewardPerBlock) {
        rewardPerBlock = (apr_ * 1e16) / (365 * 100 * blocksPerDay_);
    }

    /**
     * @notice Private function to withdraw LR tokens
     * @param stakedToken_: LR token to withdraw
     * @param amount_: amount to withdraw
     */
    function _withdrawLR(address stakedToken_, uint256 amount_) private {
        Stake storage userStake = stakes[msg.sender][stakedToken_];
        require(amount_ <= userStake.amount, "AllStarsFarm: You have no enough stakes to withdraw");

        _claimRewards(stakedToken_);

        userStake.amount -= amount_;
        userStake.checkpoint = block.number;
        uint256 fee = 0;

        if (block.number < userStake.endBlock) {
            fee = (amount_ * withdrawFee) / 10000;
            IERC20(stakedToken_).safeTransferFrom(address(this), treasury, fee);
        }

        IERC20(stakedToken_).safeTransferFrom(address(this), msg.sender, amount_ - fee);
    }

    /**
     * @notice Private function to withdraw HR tokens
     * @param stakedToken_: HR token to withdraw
     * @param amount_: amount to withdraw
     */
    function _withdrawHR(address stakedToken_, uint256 amount_) private {
        Stake storage userStake = stakes[msg.sender][stakedToken_];
        require(amount_ <= userStake.amount, "AllStarsFarm: You have no enough stakes to withdraw!");
        require(block.number >= userStake.endBlock, "AllStarsFarm: Lock period hasn't passed!");

        _claimRewards(stakedToken_);

        userStake.amount -= amount_;
        userStake.checkpoint = block.number;

        IERC20(stakedToken_).safeTransferFrom(address(this), msg.sender, amount_);
    }

    /**
     * @notice Private function to claim tokens stored as reward
     * @param stakedToken_: token to claim rewards for
     */
    function _claimRewards(address stakedToken_) private {
        uint256 length = rewardTokens.length;
        uint256[] memory rewards = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            uint256 contractBal = IERC20(rewardTokens[i]).balanceOf(address(this));
            rewards[i] = pendingReward(msg.sender, rewardTokens[i], stakedToken_);
            if (rewards[i] <= contractBal) {
                IERC20(rewardTokens[i]).safeTransfer(msg.sender, rewards[i]);
            } else {
                IERC20(rewardTokens[i]).safeTransfer(msg.sender, contractBal);
            }
        }
        stakes[msg.sender][stakedToken_].checkpoint = block.number;
    }

    /**
     * @notice Function to stake tokens
     * @param stakedToken_: address of the token to stake
     * @param amount_: amount to stake
     */

    function _stake(
        address stakedToken_,
        uint256 amount_,
        uint8 groupNumber_
    ) private {
        Stake storage userStake = stakes[msg.sender][stakedToken_];
        if (userStake.amount > 0) {
            _claimRewards(stakedToken_);
        }
        userStake.amount += amount_;
        userStake.checkpoint = block.number;
        userStake.endBlock = block.number + lockPeriod;
        bytes32 seed = computeUniqueSeedForNFTRewards(userCounter, groupNumber_);
        seedToUser[seed] = msg.sender;
        userCounter++;

        IERC20(stakedToken_).safeTransferFrom(msg.sender, address(this), amount_);
    }
}

pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

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
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;

import "../token/ERC20/IERC20.sol";

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

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
    constructor() {
        _transferOwnership(_msgSender());
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IAskoRiskToken {
    function exchangeRatePrior() external view returns (uint256);
}

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

import "@openzeppelin/contracts/access/Ownable.sol";


import "./AllStarsFarm.sol";
import "./PremiumFarm.sol";

contract NFTRewards is VRFConsumerBaseV2, ERC1155Holder, Ownable {
    struct NFT {
        uint256 id;
        uint256 amount;
        bool isERC721;
    }

    // Chainlink configs
    VRFCoordinatorV2Interface public immutable coordinator;
    uint32 public constant MAX_NUM_WORDS = 500; // Maximum number of random numbers retrived from chainlink
    uint32 public constant GAS_LIMIT = 25e5; // Maximum gas limit
    uint64 public immutable subscribtionID;
    bytes32 private immutable keyHash;

    mapping(address => NFT) public nftRewards;

    constructor(
        address vrfCoordinator_,
        uint64 subscribtionID_,
        bytes32 keyHash_
    ) VRFConsumerBaseV2(vrfCoordinator_) {
        // Set VRF configs
        coordinator = VRFCoordinatorV2Interface(vrfCoordinator_);
        subscribtionID = subscribtionID_;
        keyHash = keyHash_;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {}

    function addNFT(
        address nft_,
        uint256 id_,
        uint256 amount_,
        bool isERC721_
    ) external {
        NFT storage newNFT = nftRewards[nft_];

        newNFT.id = id_;

        if (isERC721_) {
            newNFT.isERC721 = true;

            IERC721(nft_).safeTransferFrom(msg.sender, address(this), id_);
        } else {
            newNFT.amount = amount_;

            IERC1155(nft_).safeTransferFrom(msg.sender, address(this), id_, 1, "0x00");
        }
    }

    // function distributeRewards() external onlyOwner returns(uint256 requestId){
    //     requestId = coordinator.requestRandomWords(keyHash, subscribtionID, 3, GAS_LIMIT, 1);

    // }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/utils/ERC1155Holder.sol)

pragma solidity ^0.8.0;

import "./ERC1155Receiver.sol";

/**
 * Simple implementation of `ERC1155Receiver` that will allow a contract to hold ERC1155 tokens.
 *
 * IMPORTANT: When inheriting this contract, you must include a way to use the received tokens, otherwise they will be
 * stuck.
 *
 * @dev _Available since v3.1._
 */
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PremiumFarm is Ownable {
    using SafeERC20 for IERC20;

    /**
     * @notice Info of each token's risk tokens
     * @param lr: the address of low risk token
     * @param hr: the address of high risk token
     */
    struct RiskToken {
        address lr;
        address hr;
    }

    /**
     * @notice Info of each stake
     * @param amount: amount of user's stake
     * @param checkpoint: blocknumber of user's last action
     * @param endBlock: the last block for which user will get rewards
     */
    struct Stake {
        uint256 amount;
        uint256 checkpoint;
        uint256 endBlock;
    }

    /**
     * @notice Info of each reward token
     * @param id: the id of token in rewardTokens array
     * @param rewardPerBlock: the amount of reward token given for stake per block
     */
    struct RewardToken {
        uint256 id;
        uint256 rewardPerBlock;
    }

    uint256 public constant WITHDRAW_FEE = 1000; // 10% of the withdrawing amount(basis point used),  TODO: change by exact number
    uint256 public constant MIN_STAKE_AMOUNT = 1 ether; // TODO: change by function to calculate minStakeAmount
    uint256 public constant BLOCKS_PER_DAY = 28000; // Approximate number of blocks per day

    address public immutable treasury; // Address of the treasury account
    uint256 public immutable lockPeriod; // lock period for stake in Premium Farm

    address[] public rewardTokens; // The array of tokens given as reward

    // TODO: Get hr/lr tokens info from rAsko contracts (ask Mark for docs)
    mapping(address => RiskToken) public riskTokens; // address of token => addresses of risk tokens
    mapping(address => RewardToken) public rewardTokenInfo; // address of reward token => info of reward token
    mapping(address => mapping(address => Stake)) public stakes; // address of user => address of risk token => stake

    event Staked(address indexed user, uint8 id, uint256 amount);
    event Claimed(address indexed user, uint8 id, uint256 amount);
    event Withdrawn(address stakedToken, uint256 amount);
    event Reivested(address stakedToken);

    /**
     * @notice Modifier to check if token is in the list of approved tokens
     * @param token_: address of the token
     */

    modifier isInList(address token_) {
        require(riskTokens[token_].lr != address(0), "PremiumFarm: Inappropriate token!");
        _;
    }

    constructor(address treasury_) {
        require(treasury_ != address(0), "PremiumFarm: Treasury can not be zero");

        treasury = treasury_;
        lockPeriod = 30 * BLOCKS_PER_DAY;
    }

    /**
     * @notice Function to add token to the list of approved tokens
     * @param token_: address of the token to add to the list of approved tokens
     * @param lrToken_: address of the low risk token
     * @param hrToken_: address of the high risk token
     */

    function addToken(
        address token_,
        address lrToken_,
        address hrToken_
    ) external onlyOwner {
        require(token_ != address(0), "PremiumFarm: Token can't be zero address!");
        require(lrToken_ != address(0), "PremiumFarm: LRToken can't be zero address!");
        require(hrToken_ != address(0), "PremiumFarm: HRToken can't be zero address!");
        RiskToken storage tokens = riskTokens[token_];
        require(tokens.lr == address(0), "PremiumFarm: Token is already in the list!");

        tokens.lr = lrToken_;
        tokens.hr = hrToken_;
    }

    /**
     * @notice Function to remove token from the list of approved tokens
     * @param token_: address of the token to remove from the list
     */

    function removeToken(address token_) external onlyOwner isInList(token_) {
        delete riskTokens[token_];
        // Maybe allow users to withdraw without lock period if the token has been deleted?
    }

    /**
     * @notice Function to add reward token
     * @param token_: address of the reward token to add
     * @param amount_: amount to add
     * @param apr_: the APR for the token (basis point required)
     */

    function addRewardToken(
        address token_,
        uint256 amount_,
        uint256 apr_ // Check how this is calculated
    ) external onlyOwner {
        require(token_ != address(0), "PremiumFarm: RewardToken can't be zero address!");
        require(amount_ > 0, "PremiumFarm: RewardToken amount can't be zero!");
        require(apr_ > 0, "PremiumFarm: APR can't be zero!");

        RewardToken storage token = rewardTokenInfo[token_];

        if (token.rewardPerBlock == 0) {
            rewardTokens.push(token_);
            token.id = rewardTokens.length - 1;
        }
        token.rewardPerBlock = getRewardPerBlock(apr_);

        IERC20(token_).safeTransferFrom(msg.sender, address(this), amount_);
    }

    /**
     * @notice Function to remove reward token
     * @param token_: address of the reward token to remove
     */

    function removeRewardToken(address token_) external onlyOwner {
        RewardToken storage token = rewardTokenInfo[token_];
        require(token.rewardPerBlock > 0, "PremiumFarm: RewardToken is not in list!");
        require(rewardTokens.length > 1, "PremiumFarm: Can't remove last reward token!");
        
        uint256 amount = IERC20(token_).balanceOf(address(this));
        address lastToken = rewardTokens[rewardTokens.length - 1];
        rewardTokens[token.id] = lastToken;
        rewardTokenInfo[lastToken].id = token.id;
        rewardTokens.pop();

        delete rewardTokenInfo[token_];

        if (amount > 0) {
            IERC20(token_).safeTransfer(treasury, amount);
        }
    }

    /**
     * @notice Function to stake tokens
     * @param token_: token from list of approved tokens
     * @param amount_: amount to stake
     * @param isLowRisk_: bool to know the token is LR or HR
     */

    function stake(
        address token_,
        uint256 amount_,
        bool isLowRisk_
    ) external isInList(token_) {
        require(amount_ >= MIN_STAKE_AMOUNT, "PremiumFarm: Insufficient amount!");
        if (isLowRisk_) {
            _stake(riskTokens[token_].lr, amount_);
        } else {
            _stake(riskTokens[token_].hr, amount_);
        }
    }

    /**
     * @notice Function to reinvest staked tokens
     * @param stakedToken_: token to reinvest
     */

    function reinvest(address stakedToken_) external {
        Stake storage userStake = stakes[msg.sender][stakedToken_];

        require(userStake.amount > 0, "PremiumFarm: You have no stakes to reinvest!");
        userStake.endBlock = block.number + lockPeriod;
    }

    /**
     * @notice Function to withdraw staked tokens
     * @param token_: token from list of approved tokens
     * @param amount_: amount to stake
     * @param isLowRisk_: bool to know the token is LR or HR
     */

    function withdraw(
        address token_,
        uint256 amount_,
        bool isLowRisk_
    ) external isInList(token_) {
        require(amount_ > 0, "PremiumFarm: Insufficient amount!");
        if (isLowRisk_) {
            _withdrawLR(riskTokens[token_].lr, amount_);
        } else {
            _withdrawHR(riskTokens[token_].hr, amount_);
        }
    }

    /**
     * @notice Claim tokens stored as reward
     * @param stakedToken_: token to claim rewards for
     */
    function claimRewards(address stakedToken_) external {
        Stake memory userStake = stakes[msg.sender][stakedToken_];
        require(userStake.amount > 0, "PremiumFarm: You have no rewards to claim");
        _claimRewards(stakedToken_);
    }

    /**
     * @notice Function to calculate tokens stored as reward, return amount of each reward token
     * @param stakeholder_: the address of stakeHolder
     * @param token_: the address of reward token
     * @param stakedToken_: the address of token to claim rewards for
     */
    function pendingReward(
        address stakeholder_,
        address token_,
        address stakedToken_
    ) public view returns (uint256) {
        Stake memory userStake = stakes[stakeholder_][stakedToken_];
        uint256 blocksPassed;
        if (block.number > userStake.endBlock) {
            blocksPassed = userStake.endBlock - userStake.checkpoint;
        } else {
            blocksPassed = block.number - userStake.checkpoint;
        }
        return ((userStake.amount * blocksPassed * rewardTokenInfo[token_].rewardPerBlock) / 1e18);
    }

    /**
     * @notice Function to get the amount of reward tokens per block, depending on given APR and average number blocks per day
     * @param apr_: the APR for the token (basis point required)
     */

    function getRewardPerBlock(uint256 apr_) public pure returns (uint256 rewardPerBlock) {
        rewardPerBlock = (apr_ * 1e16) / (365 * 100 * BLOCKS_PER_DAY);
    }

    /**
     * @notice Private function to withdraw LR tokens
     * @param stakedToken_: LR token to withdraw
     * @param amount_: amount to withdraw
     */
    function _withdrawLR(address stakedToken_, uint256 amount_) private {
        Stake storage userStake = stakes[msg.sender][stakedToken_];
        require(amount_ <= userStake.amount, "PremiumFarm: You have no enough stakes to withdraw");

        _claimRewards(stakedToken_);

        userStake.amount -= amount_;
        userStake.checkpoint = block.number;
        uint256 fee = 0;

        if (block.number < userStake.endBlock) {
            fee = (amount_ * WITHDRAW_FEE) / 10000;
            IERC20(stakedToken_).safeTransferFrom(address(this), treasury, fee);
        }

        IERC20(stakedToken_).safeTransferFrom(address(this), msg.sender, amount_ - fee);
    }

    /**
     * @notice Private function to withdraw HR tokens
     * @param stakedToken_: HR token to withdraw
     * @param amount_: amount to withdraw
     */
    function _withdrawHR(address stakedToken_, uint256 amount_) private {
        Stake storage userStake = stakes[msg.sender][stakedToken_];
        require(amount_ <= userStake.amount, "PremiumFarm: You have no enough stakes to withdraw!");
        require(block.number >= userStake.endBlock, "PremiumFarm: Lock period hasn't passed!");

        _claimRewards(stakedToken_);

        userStake.amount -= amount_;
        userStake.checkpoint = block.number;

        IERC20(stakedToken_).safeTransferFrom(address(this), msg.sender, amount_);
    }

    /**
     * @notice Private function to claim tokens stored as reward
     * @param stakedToken_: token to claim rewards for
     */
    function _claimRewards(address stakedToken_) private {
        uint256 length = rewardTokens.length;
        uint256[] memory rewards = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            uint256 contractBal = IERC20(rewardTokens[i]).balanceOf(address(this));
            rewards[i] = pendingReward(msg.sender, rewardTokens[i], stakedToken_);
            if (rewards[i] <= contractBal) {
                IERC20(rewardTokens[i]).safeTransfer(msg.sender, rewards[i]);
            } else {
                IERC20(rewardTokens[i]).safeTransfer(msg.sender, contractBal);
            }
        }
    }

    /**
     * @notice Function to stake tokens
     * @param stakedToken_: address of the token to stake
     * @param amount_: amount to stake
     */

    function _stake(address stakedToken_, uint256 amount_) private {
        Stake storage userStake = stakes[msg.sender][stakedToken_];
        if (userStake.amount > 0) {
            _claimRewards(stakedToken_);
        }

        userStake.amount += amount_;
        userStake.checkpoint = block.number;
        userStake.endBlock = block.number + lockPeriod;

        IERC20(stakedToken_).safeTransferFrom(msg.sender, address(this), amount_);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/utils/ERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../IERC1155Receiver.sol";
import "../../../utils/introspection/ERC165.sol";

/**
 * @dev _Available since v3.1._
 */
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

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
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
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
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
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
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
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
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
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
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken4 is ERC20 {
    constructor() ERC20("High Risk Token", "HR") {
        _mint(msg.sender, 1e26);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken3 is ERC20 {
    constructor() ERC20("High Risk Token", "HR") {
        _mint(msg.sender, 1e26);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken2 is ERC20 {
    constructor() ERC20("High Risk Token", "HR") {
        _mint(msg.sender, 1e26);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken1 is ERC20 {
    constructor() ERC20("High Risk Token", "HR") {
        _mint(msg.sender, 1e26);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LRMock is ERC20 {
    constructor() ERC20("Low Risk Token", "LR") {
        _mint(msg.sender, 1e26);
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.0.0;
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract HRMock is ERC20 {
    constructor() ERC20("High Risk Token", "HR") {
        _mint(msg.sender, 1e26);
    }
}