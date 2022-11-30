// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./interfaces/ICrowdsale.sol";
import "./interfaces/IWalletFactory.sol";
import "./interfaces/IRAX.sol";
import "./interfaces/IPancakeRouter.sol";


/**
 * @title Crowdsale
 */
contract CrowdsaleRAXToken is ICrowdsale, Ownable, Pausable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    /**
     * @dev Predefined max referral levels.
     */
    uint256 public constant REFERRAL_PROGRAM_LEVELS = 3;

    uint256 internal constant PERCENTAGE_DENOM = 10000;

    /**
     * @dev Getter for the price.
     */
    uint256 public immutable price;

    /**
     * @dev Getter for the raise.
     */
    uint256 public immutable raise;

    /**
     * @dev Getter for the min possible amountIn at time.
     */
    uint256 public minAmount;

    /**
     * @dev Getter for max possible amount total.
     */
    uint256 public maxAmount;

    /**
     * @dev Getter for sale start.
     */
    uint256 public start;

    /**
     * @dev Getter for duration.
     */
    uint256 public duration;

    /**
     * @dev Getter for the total RAX sold.
     */
    uint256 public totalSold;

    /**
     * @dev Getter for the total reward earned by all referrers.
     */
    uint256 public totalEarned;

    address public immutable BUSD; // 0xe9e7cea3dedca5984780bafc599bd69add087d56
    address public immutable USDT; // 0x55d398326f99059ff775485246999027b3197955
    address public immutable USDC; // 0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d
    address public immutable RAX;
    address public immutable pancakeRouter; // 0x10ed43c718714eb63d5aa57b78b54704e256024e
    
    /**
     * @dev Getter referres.
     */
    mapping(address => address) public referrers;

    /**
     * @dev Getter for spent amounts by user.
     */
    mapping(address => uint256) public spent;

    /**
     * @dev Getter for bought RAX amounts by user.
     */
    mapping(address => uint256) public bought;

    /**
     * @dev Getter for all level rewards by user.
     */
    mapping(address => uint256) public rewards;

    /**
     * @dev Factory address to create vesting wallets.
     */
    address internal _walletFactory;

    /**
     * @dev Internal vesting managers storage.
     */
    Vesting[] internal _vestingManagers;

    /**
     * @dev Internal vesting wallets storage.
     *
     * vestingManager => (beneficiary => wallet)
     */
    mapping(address => mapping(address => address)) internal _vestingWallets;

    modifier onlySalePeriod {
        require(block.timestamp >= start && block.timestamp < (start + duration), "Sale: sale not started or already finished");
        _;
    }

    modifier whenNotStarted {
        require(start == 0 || (start > 0 && block.timestamp < start), "Sale: sale already started");
        _;
    }

    /**
     * @param price_ The price for RAX token;
     * @param raise_ The target raise for this sale;
     * @param BUSD_ The BUSD address, preferable to buy for;
     * @param USDT_ The USDT address;
     * @param USDC_ The USDC_ address;
     * @param RAX_ The selling RAX address;
     * @param pancakeRouter_ The PancakeRouter address. Used to change BNB\USDT\USDC to BUSD;
     * @param walletFactory_ The IWalletFactory implementation.
     *
     * USDT, USDC and PancakeRouter are optional. In that case sale be possible only for BUSD.
     */
    constructor(uint256 price_, uint256 raise_, address BUSD_, address USDT_, address USDC_, address RAX_, address pancakeRouter_, address walletFactory_) {
        price = price_;
        raise = raise_;
        BUSD = BUSD_;
        USDT = USDT_;
        USDC = USDC_;
        RAX = RAX_;
        pancakeRouter = pancakeRouter_;
        _walletFactory = walletFactory_;
    }

    /**
     * @dev Getter for vesting managers count.
     */
    function getVestingManagersCount() external view virtual override returns (uint256) {
        return _vestingManagers.length;
    }

    /**
     * @dev Getter for vesting manager.
     *
     * @return The address of vesting manager and its distribution percentage.
     */
    function getVestingManager(uint256 index) external view virtual override returns (address, uint256) {
        return (_vestingManagers[index].vestingManager, _vestingManagers[index].distributionPercentage);
    }

    /**
     * @dev Getter for user's vesting wallet.
     */
    function getVestingWallets(address beneficiary) external view virtual override returns (address[] memory) {
        return _getVestingWallets(beneficiary);
    }

    /**
     * @dev Setter for the sale start.
     *
     * @param start_ in seconds, timestamp format.
     */
    function setStart(uint64 start_) external virtual override onlyOwner whenNotStarted {
        require(start_ > block.timestamp, "Sale: past timestamp");
        start = start_;
    }

    /**
     * @dev Setter for the sale duration.
     *
     * @param duration_ in seconds.
     */
    function setDuration(uint64 duration_) external virtual override onlyOwner whenNotStarted {
        duration = duration_;
    }

    /**
     * @dev Setter min possible amount for one beneficiary at time.
     */
    function setMinAmount(uint256 minAmount_) external virtual override onlyOwner whenNotStarted {
        minAmount = minAmount_;
    }

    /**
     * @dev Setter for total max possible amount for one beneficiary.
     */
    function setMaxAmount(uint256 maxAmount_) external virtual override onlyOwner whenNotStarted {
        maxAmount = maxAmount_;
    }

    /**
     * @dev Adds vesting manager.
     *
     * @param vestingManager_ The new vesting manager.
     * @param distributionPercentage_ The distribution percentage, with 3 decimals (100% is 10000).
     *
     * To start sale total sum of distributionPercentage of all managers have to be 10000 (100%).
     */
    function addVestingManager(address vestingManager_, uint256 distributionPercentage_) external virtual override onlyOwner whenNotStarted {
        uint256 distributionPercentageTotal = _getDistributionPercentageTotal();
        distributionPercentageTotal += distributionPercentage_;
        require(distributionPercentageTotal <= 10000, "Sale: wrong total distribution percentage");
        _vestingManagers.push(Vesting(vestingManager_, distributionPercentage_));
    }

    /**
     * @dev Removes vesting manager.
     */
    function removeVestingManager(uint256 index) external virtual override onlyOwner whenNotStarted {
        require(index < _vestingManagers.length, "Sale: wrong index");
        uint256 lastIndex = _vestingManagers.length - 1;
        _vestingManagers[index].vestingManager = _vestingManagers[lastIndex].vestingManager;
        _vestingManagers[index].distributionPercentage = _vestingManagers[lastIndex].distributionPercentage;
        _vestingManagers.pop();
    }

    /**
     * @dev Withdraws given `token` tokens from the contracts's account to owner.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     */
    function withdraw(address token) external virtual override onlyOwner {
        require(token != address(0), "Sale: zero address given");
        IERC20 tokenImpl = IERC20(token);
        tokenImpl.safeTransfer(msg.sender, tokenImpl.balanceOf(address(this)));
    }

    /**
     * @dev Triggers stopped state.
     */
    function pause() external virtual override onlyOwner onlySalePeriod {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     */
    function unpause() external virtual override onlyOwner onlySalePeriod {
        _unpause();
    }

    /**
     * @dev Buy tokens for `token`'s `amountIn`. 
     *
     * @param token For what token user want buy RAX. Can be BUSD\USDT\USDC\0x0. Use 0x0 and send value to buy RAX for BNB.
     *  USDT\USDC\BNB will be changed to BUSD 'on the fly';
     * @param amountIn Amount for which user want to buy RAX;
     * @param minAmountOut Min amount out in terms of PancakeRouter. Have to be given if token is USDT\USDC\BNB, 
     *  otherwise have to be 0;
     * @param referrer The referrer, if present. If possible will be set in the RAX token too, to get rewards from future
     *  transfers.
     *
     * Can be used only in sale period.
     *
     * Can be paused by owner in emergency case.
     *
     * minAmountOut can be get from PancakeRouter:
     *  - to deduct PancakeRouter's fee from amountIn (will not work with if amountIn is equal with minAmountIn set in sale):
     *      const minAmountOut = pancakeRouter.getAmountsOut(amountIn, [USDT, BUSD])
     *  - or add it amountIn before call:
     *      const amountsIn = pancakeRouter.getAmountsIn(amountOut, [USDT, BUSD])
     *      const minAmountOut = amountsIn[0]
     *      
     * Emits {TokenTransferred} event;
     * Emits {TokenSold} event;
     * Emits {RewardEarned} event if referrer provided;
     * Emits few {Transfer} event.
     */
    function buy(address token, uint256 amountIn, uint256 minAmountOut, address referrer) external payable virtual override onlySalePeriod whenNotPaused nonReentrant {
        _buy(token, amountIn, minAmountOut, referrer);
    }

    function _buy(address token, uint256 amountIn, uint256 minAmountOut, address referrer) internal {
        require(_getDistributionPercentageTotal() == 10000, "Sale: vestings are not correct");
        require(token == BUSD || token == USDT || token == USDC || (token == address(0) && msg.value > 0), "Sale: wrong asset or value");
        if (referrer != address(0)) {
            address existingReferrer = referrers[msg.sender];
            if (existingReferrer != address(0)) {
                require(existingReferrer == referrer, "Sale: referrer already set");
            }
            // check is referrer have vesting wallet
            address[] memory wallets = _getVestingWallets(referrer);
            // can check only first element, cause there is no case when first element is not set but second one is
            require(wallets.length > 0 && wallets[0] != address(0), "Sale: invalid referrer");
            
            IRAX RAXImpl = IRAX(RAX);
            if (RAXImpl.referrers(msg.sender) == address(0)) {
                RAXImpl.setReferrer(msg.sender, referrer);
            }
        }

        uint256 amountBusdIn = amountIn;
        if (token == address(0)) { // native asset (BNB)
            amountBusdIn = _swapToBusd(address(0), 0, minAmountOut);
        } else {
            IERC20 tokenImpl = IERC20(token);

            tokenImpl.safeTransferFrom(msg.sender, address(this), amountIn);

            if (token != BUSD) { // USDT or USDC
                amountBusdIn = _swapToBusd(token, amountIn, minAmountOut);
            }
        }

        require(amountBusdIn >= minAmount, "Sale: minAmount");
        spent[msg.sender] += amountBusdIn;
        require(spent[msg.sender] <= maxAmount, "Sale: maxAmount");

        referrers[msg.sender] = referrer;

        uint256[] memory amountRaxOuts = new uint256[](4);
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            uint256 amountBusdInByVestinManager = (amountBusdIn * _vestingManagers[i].distributionPercentage) / PERCENTAGE_DENOM;

            amountRaxOuts[0] = (amountBusdInByVestinManager * 10**18) / price;
            amountRaxOuts[1] = (amountBusdInByVestinManager * 5000) / PERCENTAGE_DENOM;
            amountRaxOuts[2] = (amountBusdInByVestinManager * 3000) / PERCENTAGE_DENOM;
            amountRaxOuts[3] = (amountBusdInByVestinManager * 2000) / PERCENTAGE_DENOM;

            _execute(_vestingManagers[i].vestingManager, msg.sender, amountRaxOuts);
        }
    }

    function _swapToBusd(address erc20, uint256 amountIn, uint256 minAmountOut) private returns (uint256) {
        IPancakeRouter02 pancakeRouterImpl = IPancakeRouter02(pancakeRouter);

        address[] memory path = new address[](2);
        path[1] = BUSD;

        IERC20 BUSDImpl = IERC20(BUSD);
        uint256 balanceBefore = BUSDImpl.balanceOf(address(this));

        if (erc20 == address(0)) {
            path[0] = pancakeRouterImpl.WETH();
            pancakeRouterImpl.swapExactETHForTokensSupportingFeeOnTransferTokens{ value: msg.value }(minAmountOut, path, address(this), block.timestamp);
        } else {
            path[0] = erc20;
            IERC20 erc20Impl = IERC20(erc20);
            erc20Impl.safeIncreaseAllowance(pancakeRouter, amountIn);
            pancakeRouterImpl.swapExactTokensForTokensSupportingFeeOnTransferTokens(amountIn, minAmountOut, path, address(this), block.timestamp);
        }

        uint256 balanceAfter = BUSDImpl.balanceOf(address(this));

        return balanceAfter - balanceBefore;
    }

    function _execute(address vestingManager, address beneficiary, uint256[] memory amountRaxOuts) private {
        (address[] memory allLevelsVestingWallets, address[] memory allLevelsReferrers) = _getAllLevelsVestingWallets(vestingManager, beneficiary);

        totalSold += amountRaxOuts[0];
        emit TokenTransferred(allLevelsVestingWallets[0], amountRaxOuts[0]);
        emit TokenSold(beneficiary, amountRaxOuts[0]);

        IERC20 erc20Impl = IERC20(RAX);

        bought[beneficiary] += amountRaxOuts[0];
        
        erc20Impl.safeTransfer(allLevelsVestingWallets[0], amountRaxOuts[0]);
        for (uint256 i = 1; i < allLevelsVestingWallets.length; ++i) {
            if (allLevelsVestingWallets[i] == address(0)) {
                break;
            }
            totalEarned += amountRaxOuts[i];
            emit RewardEarned(allLevelsVestingWallets[i], amountRaxOuts[i], i);
            rewards[allLevelsReferrers[i]] += amountRaxOuts[i];
            erc20Impl.safeTransfer(allLevelsVestingWallets[i], amountRaxOuts[i]);
        }
    }

    function _getVestingWallets(address beneficiary) internal view returns (address[] memory) {
        address[] memory wallets = new address[](_vestingManagers.length);
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            address vestingManager = _vestingManagers[i].vestingManager;
            wallets[i] = _vestingWallets[vestingManager][beneficiary];
        }
        return wallets;
    }

    function _getDistributionPercentageTotal() internal view returns (uint256) {
        uint256 distributionPercentageTotal = 0;
        for (uint256 i = 0; i < _vestingManagers.length; ++i) {
            distributionPercentageTotal += _vestingManagers[i].distributionPercentage;
        }
        return distributionPercentageTotal;
    }

    function _getAllLevelsVestingWallets(address vestingManager, address beneficiary) internal returns (address[] memory, address[] memory) {
        address[] memory allLevelsVestingWallets = new address[](REFERRAL_PROGRAM_LEVELS + 1);
        address[] memory allLevelsReferrers = new address[](REFERRAL_PROGRAM_LEVELS + 1);

        address vestingWallet = _vestingWallets[vestingManager][beneficiary];

        if (vestingWallet == address(0)) {
            IWalletFactory factoryImpl = IWalletFactory(_walletFactory);
            vestingWallet = factoryImpl.createManagedVestingWallet(beneficiary, vestingManager);
            _vestingWallets[vestingManager][beneficiary] = vestingWallet;
        }

        allLevelsVestingWallets[0] = vestingWallet;

        address referrer = referrers[beneficiary];
        for (uint256 i = 1; i <= REFERRAL_PROGRAM_LEVELS; ++i) {
            address referrerVestingWallet = _vestingWallets[vestingManager][referrer];
            if (referrerVestingWallet == address(0)) {
                break;
            }
            allLevelsVestingWallets[i] = referrerVestingWallet;
            allLevelsReferrers[i] = referrer;
            referrer = referrers[referrer];
        }

        return (allLevelsVestingWallets, allLevelsReferrers);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface ICrowdsale {

    struct Vesting {
        address vestingManager;
        uint256 distributionPercentage;
    }

    /**
     * @dev Emitted when `beneficiary` bought `amount` of token.
     */
    event TokenSold(address indexed beneficiary, uint256 indexed amount);

    /**
     * @dev Emitted when vesting wallet `receiver` received `amount` of token.
     */
    event TokenTransferred(address indexed receiver, uint256 indexed amount);

    /**
     * @dev Emitted when `referrer` get his `level`'s reward from his referee (eg referee bought tokens).
     */
    event RewardEarned(address indexed referrer, uint256 indexed amount, uint256 indexed level);

    function price() external view returns (uint256);
    function raise() external view returns (uint256);
    function start() external view returns (uint256);
    function duration() external view returns (uint256);
    function minAmount() external view returns (uint256);
    function maxAmount() external view returns (uint256);
    function getVestingManagersCount() external view returns (uint256);
    function getVestingManager(uint256 index) external view returns (address, uint256);
    function getVestingWallets(address beneficiary) external view returns (address[] memory);

    function totalSold() external view returns (uint256);
    function totalEarned() external view returns (uint256);

    function BUSD() external view returns (address);
    function USDT() external view returns (address);
    function RAX() external view returns (address);
    function pancakeRouter() external view returns (address);

    function setStart(uint64) external;
    function setDuration(uint64) external;
    function setMinAmount(uint256 minAmount_) external;
    function setMaxAmount(uint256 maxAmount_) external;
    function addVestingManager(address vestingManager_, uint256 distributionPercentage_) external;
    function removeVestingManager(uint256 index) external;

    function pause() external;
    function unpause() external;

    function withdraw(address) external;

    function buy(address erc20, uint256 amountIn, uint256 minAmountOut, address referrer) external payable;
}

interface IWhitelistedCrowdsale is ICrowdsale {
    function isInWhitelist(address user, bytes32[] memory proof) external view returns (bool);
    function setWhitelist(bytes32 whitelist_) external;
    function buyWithProof(bytes32[] memory proof, address erc20, uint256 amountIn, uint256 minAmountOut, address referrer) external payable;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IWalletFactory {
    function createManagedVestingWallet(address beneficiary, address vestingManager) external returns (address);
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

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

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

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
pragma solidity ^0.8.9;

interface IRAX {
    function referrers(address referrer) external view returns (address);
    function setReferrer(address referrer) external;
    function setReferrer(address referee, address referrer) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

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
abstract contract ReentrancyGuard {
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

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
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
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
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
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
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
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../extensions/draft-IERC20Permit.sol";
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

    function safePermit(
        IERC20Permit token,
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
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

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
interface IERC20Permit {
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