//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./interfaces/IPresale.sol";


contract PreSale is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address payable;

    struct SocialLinks {
        string twitter;
        string facebook;
        string telegram;
        string instagram;
        string github;
        string discord;
        string reddit;
    }

    IUniswapV2Router02 public uniswapV2Router;
    address public devaddr;
    uint256 public constant VERSION = 2;
    uint256 public constant EMERGENCY_WITHDRAWAL_FEE = 10;
    uint256 public constant FINALIZE_EXPIRATION = 7 days;
    address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;
    address payToken;
    IERC20Upgradeable mainToken;

    uint256 public airdropAmount;
    uint256 public minVote;
    address public voteToken;

    uint256 public saleRate;
    uint256 public saleRateDecimals;
    uint256 public listingRate;
    uint256 public listingRateDecimals;
    uint256 public liquidityPercent;
    uint256 public minContribution;
    uint256 public maxContribution;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public weiRaised;
    bool public whitelistEnabled;
    bool public finalized;
    bool public canceled;
    bool public deposited;
    bool public airdropEnabled;
    mapping (address => bool) public whitelist;

    uint256 public claimStartTime;

    uint[] public stageTimes;
    uint[] public stagePercents;

    mapping(address => uint256) public userContributions;
    mapping(address => uint256) public userTokenTally;
    mapping(address => uint256) public userTokenClaimed;
    mapping(address => uint256) public userVotes;
    mapping(address => uint256) public userVotesUnlocked;
    mapping(address => uint256) public userAirdropClaimed;
    mapping(uint256 => address) public contributors;
    uint256 public contributorIndex;
    uint256 public totalVotes;
    string public name;
    string public logo;
    string public website;
    string public projectDescription;
    SocialLinks public links;

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     * @param voteAmount amount of votes
     */
    event TokensPurchased(address purchaser, uint256 value, uint256 amount, uint256 voteAmount);

    /**
     * Event for token claim logging
     * @param beneficiary who got the tokens
     * @param amountToken amount of tokens purchased
     * @param amountAirdrop amount of airdropping tokens
     */
    event TokensClaimed(address beneficiary, uint256 amountToken, uint256 amountAirdrop);
    /**
     * Event for token refund logging
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param voteAmount votes paid for purchase
     */
    event Refunded(address beneficiary, uint256 value, uint256 voteAmount);

    /**
     * Event for emergency withdraw while active
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param voteAmount votes paid for purchase
     */
    event EmergencyWithdrawn(address beneficiary, uint256 value, uint256 fee, uint256 voteAmount);
    /**
     * Event for unlocking vote
     * @param voteAmount votes paid for purchase
     */
    event VotesUnlocked(address beneficiary, uint256 voteAmount);
    event Whitelisted(address account, bool whitelisted);
    event WhitelistEnabled(bool enabled);
    event TokenDeposited(uint256 amount);
    event Finalized();
    event Canceled(bool airdropped);

    receive() external payable {}

    function initialize(
        IPresale.InitParams calldata params,
        IPresale.InitVoteParams calldata voteParams,
        uint[] memory _stageTimes,
        uint[] memory _stagePercents,
        uint256 _claimStartTime
    ) public initializer {
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __Presale_init_unchanged(params, voteParams, _stageTimes, _stagePercents, _claimStartTime);
    }

    function __Presale_init_unchanged(
        IPresale.InitParams calldata params,
        IPresale.InitVoteParams calldata voteParams,
        uint[] memory _stageTimes,
        uint[] memory _stagePercents,
        uint256 _claimStartTime
    ) private {
        require(address(0) != params.mainToken, "set main token to the zero address");
        require(address(0) != params.wallet, "set wallet to the zero address");
        require(params.hardCap > params.softCap, "set Soft Cap greater than Hard Cap");
        require(params.maxContribution > params.minContribution, "set Minimum Contribution greater than Maxmium Contribution");
        require(params.liquidityPercent <= 100, "set Liquidity Percent higher than 100");
        require(params.endTime > params.startTime && params.startTime > block.timestamp, "invalid configuration");
        require(_stageTimes.length == _stagePercents.length, "invalid configuration");
        require(_stageTimes.length > 0, "invalid configuration");
        require(voteParams.minVote > 0, "set minimum vote to zero");
        require(address(0) != voteParams.voteToken, "set vote token to the zero address");

        airdropAmount = voteParams.airdropAmount;
        minVote = voteParams.minVote;
        voteToken = voteParams.voteToken;

        // sale rate
        saleRate = params.saleRate;
        saleRateDecimals = params.saleRateDecimals;
        // listing rate
        listingRate = params.listingRate;
        listingRateDecimals = params.listingRateDecimals;
        // liquidity percent
        liquidityPercent = params.liquidityPercent;
        // soft cap / hard cap in wei
        softCap = params.softCap;
        hardCap = params.hardCap;
        // min/max distribution in wei
        minContribution = params.minContribution;
        maxContribution = params.maxContribution;
        // presale duration
        startTime = params.startTime;
        endTime = params.endTime;
        // token to sell
        mainToken = IERC20Upgradeable(params.mainToken);
        // payment method, it zero address use ETH/BNB
        payToken = params.payToken;
        // owner
        devaddr = params.wallet;
        whitelistEnabled = params.whitelistEnabled;
        // claiming stages. e.g. 10 % every 2 weeks : [10, 10, 10, 10, 10], [604800,604800,604800,604800,604800]
        stageTimes = _stageTimes;
        stagePercents = _stagePercents;
        uniswapV2Router = IUniswapV2Router02(params.router);
        claimStartTime = _claimStartTime;

        finalized = false;
        canceled = false;
        whitelistEnabled = false;
        deposited = false;
        airdropEnabled = false;
        contributorIndex = 0;
        name = params.name;
    }

    function setAirdropEnabled(bool airdropEnabled_) public onlyOwner {
        airdropEnabled = airdropEnabled_;
    }

    function setWhitelistEnabled (bool _whitelistEnabled) external onlyOwner {
        whitelistEnabled = _whitelistEnabled;

        emit WhitelistEnabled(_whitelistEnabled);
    }

    function whitelistAddress (address user, bool enabled) external onlyOwner {
        whitelist[user] = enabled;

        emit Whitelisted(user, enabled);
    }

    function whitelistAddresses (address[] memory accounts, bool[] memory values) external onlyOwner
    {
        require(accounts.length == values.length, "Presale: accounts and values length mismatch");
        for (uint256 i = 0; i < accounts.length; ++i) {
            whitelist[accounts[i]] = values[i];
        }
    }

    function getStages() public view returns (uint256[] memory _stageTimes, uint256[] memory _stagePercents)
    {
        _stageTimes = stageTimes;
        _stagePercents = stagePercents;
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        require(address(0) != _devaddr, "set dev to the zero address");
        devaddr = _devaddr;
    }

    function getTokenAmount(uint256 weiAmount) private view returns(uint256) {
        return weiAmount.mul(saleRate).div(10**saleRateDecimals);
    }

    function getLiquidityTokenAmount(uint256 weiAmount)  private view returns(uint256) {
        return weiAmount.mul(listingRate).div(10**listingRateDecimals);
    }

    function userBalance(address user) public view returns (uint256 staked, uint256 claimed) {
        staked = userTokenTally[user];
        claimed = userTokenClaimed[user];
    }

    function updateMeta(
        string memory logo_,
        string memory website_,
        string memory twitter_,
        string memory facebook_,
        string memory telegram_,
        string memory instagram_,
        string memory github_,
        string memory discord_,
        string memory reddit_,
        string memory projectDescription_
    ) public onlyOwner {
        logo = logo_;
        website = website_;
        links.twitter = twitter_;
        links.facebook = facebook_;
        links.telegram = telegram_;
        links.instagram = instagram_;
        links.github = github_;
        links.discord = discord_;
        links.reddit = reddit_;
        projectDescription = projectDescription_;
    }


    function getConfiguration() external view returns (IPresale.InitParams memory params) {
        params.saleRate = saleRate;
        params.saleRateDecimals = saleRateDecimals;
        params.listingRate = listingRate;
        params.listingRateDecimals = listingRateDecimals;
        params.liquidityPercent = liquidityPercent;
        params.wallet = payable(devaddr);
        params.router = address(0);
        params.mainToken = address(mainToken);
        params.payToken = payToken;
        params.softCap = softCap;
        params.hardCap = hardCap;
        params.minContribution = minContribution;
        params.maxContribution = maxContribution;
        params.startTime = startTime;
        params.endTime = endTime;
        params.whitelistEnabled = whitelistEnabled;
        params.name = name;
    }

    function userAirdropAmount(address user) public view returns (uint256) {
        if (totalVotes == 0) {
            return 0;
        }

        return userVotes[user].mul(airdropAmount).div(totalVotes);
    }

    function claimableAmount(address user) public view returns (uint256, uint256) {

        if (!finalized) {
            return (0, 0);
        }

        uint256 percent = 0;

        for (uint i = 0; i < stageTimes.length; i ++) {
            if (block.timestamp < stageTimes[i].add(claimStartTime)) {
                break;
            }
            percent = percent.add(stagePercents[i]);
        }

        if (percent == 0) {
            return (0, 0);
        }

        uint256 totalTokenClaimable = percent.mul(userTokenTally[user]).div(100);
        totalTokenClaimable = totalTokenClaimable.sub(userTokenClaimed[user]);

        uint256 totalAirdropClaimable = 0;
        if (totalVotes > 0) {
            totalAirdropClaimable = userVotes[user].mul(airdropAmount).div(totalVotes).mul(percent).div(100);
            totalAirdropClaimable = totalAirdropClaimable.sub(userAirdropClaimed[user]);
        }

        return (totalTokenClaimable, totalAirdropClaimable);
    }

    function expired() public view returns (bool) {
        return !canceled && !finalized && block.timestamp > endTime + FINALIZE_EXPIRATION;
    }

    function deposit() external onlyOwner nonReentrant {
        require(!deposited, "Already deposited");

        uint256 amountSale = getTokenAmount(hardCap);
        uint256 amountLiquidity = getLiquidityTokenAmount(hardCap.mul(liquidityPercent).div(100));
        uint256 amountTotal = amountSale.add(amountLiquidity);
        amountTotal = amountTotal.add(airdropAmount);

        mainToken.safeTransferFrom(msg.sender, address(this), amountTotal);
        deposited = true;

        emit TokenDeposited(amountTotal);
    }

    function cancel() external onlyOwner nonReentrant {
        require(!finalized && !canceled, "Presale: has been ended already");

        canceled = true;
        // refund token to owner
        if (deposited) {
            deposited = false;
            uint256 balance = mainToken.balanceOf(address(this));
            mainToken.safeTransfer(devaddr, balance);
        }

        if (airdropEnabled) {
            weiRaised = 0;
            for (uint256 i = 0; i < contributorIndex; i++) {
                address contributor = contributors[i];
                uint256 contribution = userContributions[contributor];
                if (contribution > 0) {
                    userContributions[contributor] = 0;
                    userTokenTally[contributor] = 0;
                    if (payToken == address(0)) {
                        payable(contributors[i]).sendValue(contribution);
                    } else {
                        IERC20Upgradeable(payToken).transfer(payable(contributors[i]), contribution);
                    }
                }
            }
        }

        emit Canceled(airdropEnabled);
    }

    function finalize() external onlyOwner nonReentrant {
        require(!finalized && !canceled && block.timestamp <= endTime + FINALIZE_EXPIRATION, "Presale: has been ended already");
        require(deposited, "Presale: not desposited yet");
        require(weiRaised >= softCap, "Soft cap was not reached");
        require(block.timestamp >= endTime || weiRaised >= hardCap, "Hard cap was not reached or Sale is not ended yet");

        finalized = true;
        if (claimStartTime == 0) {
            claimStartTime = block.timestamp;   
        }


        // add liquidity
        if (liquidityPercent > 0) {
            if (payToken == address(0)) {
                addLiquidityETH();
            } else {
                addLiquidityToken();
            }
        }

        // send remaining token amount to wallet
        uint256 tokenBalance = mainToken.balanceOf(address(this));
        uint256 tokenRequired = getTokenAmount(weiRaised);
        tokenRequired = tokenRequired.add(airdropAmount);
        if (tokenRequired < tokenBalance) {
            mainToken.safeTransfer(devaddr, tokenBalance.sub(tokenRequired));
        }

        // send remaining eth to wallet
        if (payToken == address(0)) {
            uint256 ethBalance = address(this).balance;
            if (ethBalance > 0) {
                payable(devaddr).sendValue(ethBalance);
            }
        } else {
            uint256 ethBalance = IERC20Upgradeable(payToken).balanceOf(address(this));
            if (ethBalance > 0) {
                IERC20Upgradeable(payToken).safeTransfer(devaddr, ethBalance);
            }
        }

        if (airdropEnabled && stagePercents.length == 1 && stagePercents[0] == 100 && stageTimes[0] == 0) {
            // airdrop tokens if vesting is disabled
            for (uint256 i = 0; i < contributorIndex; i++) {
                address contributor = contributors[i];
                uint256 amount = userTokenTally[contributor].sub(userTokenClaimed[contributor]);
                if (amount > 0) {
                    userTokenClaimed[contributor] = userTokenClaimed[contributor].add(amount);
                    mainToken.safeTransfer(contributor, amount);
                }
            }
        }

        emit Finalized();
    }

    function buyWithToken(uint256 weiAmount, uint256 voteAmount) external nonReentrant {
        require(!finalized && !canceled, "Presale: has been ended already");
        require(voteAmount == 0 || voteAmount >= minVote, "Presale: vote amount is too low");
        require(payToken != address(0), "This payment method is disabled");
        require(!whitelistEnabled || whitelist[msg.sender], "Presale: Not whitelisted");
        require(block.timestamp >= startTime, "Presale: Sale hasn't started yet, good things come to those that wait");
        require(block.timestamp < endTime, "Presale: Sale has ended, come back next time!");
        require(weiAmount >= minContribution && weiAmount > 0, "Lower than minimum contribution");

        uint256 newContribution = userContributions[msg.sender].add(weiAmount);
        require(newContribution <= maxContribution, "Presale: exceed maximum contribution limit");

        if (voteAmount > 0) {
            IERC20Upgradeable(voteToken).safeTransferFrom(msg.sender, address(this), voteAmount);
            userVotes[msg.sender] = userVotes[msg.sender].add(voteAmount);
            totalVotes = totalVotes.add(voteAmount);
        }

        IERC20Upgradeable(payToken).safeTransferFrom(msg.sender, address(this), weiAmount);
        uint256 tokenAmount = getTokenAmount(weiAmount);

        weiRaised = weiRaised.add(weiAmount);

        if (userContributions[msg.sender] == 0) {
            contributors[contributorIndex++] = msg.sender;
        }

        userTokenTally[msg.sender] = userTokenTally[msg.sender].add(tokenAmount);
        userContributions[msg.sender] = newContribution;

        emit TokensPurchased(msg.sender, weiAmount, tokenAmount, voteAmount);
    }

    function buyWithETH(uint256 voteAmount) external payable nonReentrant {
        require(!finalized && !canceled, "Presale: has been ended already");
        require(voteAmount == 0 || voteAmount >= minVote, "Presale: vote amount is too low");
        require(payToken == address(0), "This payment method is disabled");
        require(!whitelistEnabled || whitelist[msg.sender], "Presale: Not whitelisted");
        require(block.timestamp >= startTime, "Presale: Sale hasn't started yet, good things come to those that wait");
        require(block.timestamp < endTime, "Presale: Sale has ended, come back next time!");
        require(msg.value >= minContribution && msg.value > 0, "Lower than minimum contribution");

        if (voteAmount > 0) {
            IERC20Upgradeable(voteToken).safeTransferFrom(msg.sender, address(this), voteAmount);
            userVotes[msg.sender] = userVotes[msg.sender].add(voteAmount);
            totalVotes = totalVotes.add(voteAmount);
        }

        uint256 weiAmount = msg.value;

        uint256 newContribution = userContributions[msg.sender].add(weiAmount);
        require(newContribution <= maxContribution, "Presale: exceed maximum contribution limit");

        uint256 tokenAmount = getTokenAmount(weiAmount);

        weiRaised = weiRaised.add(weiAmount);

        if (userContributions[msg.sender] == 0) {
            contributors[contributorIndex++] = msg.sender;
        }

        userTokenTally[msg.sender] = userTokenTally[msg.sender].add(tokenAmount);
        userContributions[msg.sender] = newContribution;

        emit TokensPurchased(msg.sender, weiAmount, tokenAmount, voteAmount);
    }

    function emergencyWithdraw() external nonReentrant {
        require(!finalized && !canceled, "Presale: has been ended already");
        require(weiRaised < hardCap, "Presale: Hard cap reached");
        require(userContributions[msg.sender] > 0, "no contribution");

        uint256 ethAmount = userContributions[msg.sender];
        userContributions[msg.sender] = 0;
        userTokenTally[msg.sender] = 0;
        weiRaised = weiRaised.sub(ethAmount);

        uint256 fee = ethAmount.mul(EMERGENCY_WITHDRAWAL_FEE).div(1000);
        uint256 value = ethAmount.sub(fee);

        if (payToken == address(0)) {
            payable(msg.sender).sendValue(value);
            payable(devaddr).sendValue(fee);
        } else {
            IERC20Upgradeable(payToken).safeTransfer(msg.sender, value);
            IERC20Upgradeable(payToken).safeTransfer(devaddr, fee);
        }

        uint256 voteAmount = userVotes[msg.sender];
        if (voteAmount > 0) {
            userVotes[msg.sender] = 0;
            IERC20Upgradeable(voteToken).safeTransfer(msg.sender, voteAmount);
            totalVotes = totalVotes.sub(voteAmount);
        }
        
        emit EmergencyWithdrawn(msg.sender, value, fee, voteAmount);
    }

    function unlockVotes() external nonReentrant {
        require(finalized, "Presale: not finalized yet");
        uint256 voteAmount = userVotes[msg.sender];
        require(voteAmount > 0, "No votes");
        uint256 unlockedAmount = userVotesUnlocked[msg.sender];
        require(unlockedAmount < voteAmount, "Uo votes to unlock");
        
        uint256 unlockAmount = voteAmount.sub(unlockedAmount);
        userVotesUnlocked[msg.sender] = voteAmount;
        IERC20Upgradeable(voteToken).safeTransfer(msg.sender, unlockAmount);
        emit VotesUnlocked(msg.sender, unlockAmount);
    }

    function claim() external nonReentrant {
        require(finalized, "Presale: not finalized yet");
        (uint256 amountToken, uint256 amountAirdrop) = claimableAmount(msg.sender);
        require(amountToken > 0 || amountAirdrop > 0, "Presale: no claimable tokens");

        uint256 amount = amountToken + amountAirdrop;
        require(mainToken.balanceOf(address(this)) >= amount, "Presale: Not enough tokens in contract for claiming");
        userTokenClaimed[msg.sender] = userTokenClaimed[msg.sender].add(amountToken);
        userAirdropClaimed[msg.sender] = userAirdropClaimed[msg.sender].add(amountAirdrop);
        mainToken.safeTransfer(msg.sender, amount);
        emit TokensClaimed(msg.sender, amountToken, amountAirdrop);
    }

    function claimRefund() external nonReentrant {
        require(canceled || (!finalized && block.timestamp > endTime + FINALIZE_EXPIRATION), "Presale: not canceled");
        require(userContributions[msg.sender] > 0, "no contribution");

        uint256 ethAmount = userContributions[msg.sender];
        userContributions[msg.sender] = 0;
        userTokenTally[msg.sender] = 0;

        if (payToken == address(0)) {
            payable(msg.sender).sendValue(ethAmount);
        } else {
            IERC20Upgradeable(payToken).safeTransfer(msg.sender, ethAmount);
        }

        uint256 voteAmount = userVotes[msg.sender];
        if (voteAmount > 0) {
            userVotes[msg.sender] = 0;
            IERC20Upgradeable(voteToken).safeTransfer(msg.sender, voteAmount);
        }
        
        emit Refunded(msg.sender, ethAmount, voteAmount);
    }

    function addLiquidityETH() private returns (uint256) {
        uint256 ethAmount = weiRaised.mul(liquidityPercent).div(100);
        uint256 tokenAmount = getLiquidityTokenAmount(ethAmount);
        mainToken.approve(address(uniswapV2Router), tokenAmount);

        // add the liquidity
        uint256 liquidity;
        (,,liquidity) = uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(mainToken),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            devaddr,
            block.timestamp
        );
        return liquidity;
    }

    function addLiquidityToken() private returns (uint256) {
        uint256 ethAmount = weiRaised.mul(liquidityPercent).div(100);
        uint256 tokenAmount = getLiquidityTokenAmount(ethAmount);
        // approve token transfer to cover all possible scenarios
        mainToken.approve(address(uniswapV2Router), tokenAmount);
        IERC20Upgradeable(payToken).approve(address(uniswapV2Router), ethAmount);

        // add the liquidity
        uint256 liquidity;
        (,,liquidity) = uniswapV2Router.addLiquidity(
            payToken,
            address(mainToken),
            ethAmount,
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            devaddr,
            block.timestamp
        );
        return liquidity;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)

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
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
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
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        // If the contract is initializing we ignore whether _initialized is set in order to support multiple
        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level
        // of initializers, because in other contexts the contract may have been reentered.
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "../proxy/utils/Initializable.sol";

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

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
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
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20Upgradeable.sol";
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
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

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

pragma solidity >=0.5.0;

interface IUniswapV2Router01 {
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

interface IUniswapV2Router02 is IUniswapV2Router01 {
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

pragma solidity ^0.8.4;

interface IPresale {

    struct InitParams {
        uint256 saleRate;
        uint256 saleRateDecimals;
        uint256 listingRate;
        uint256 listingRateDecimals;
        uint256 liquidityPercent;
        uint256 softCap;
        uint256 hardCap;
        uint256 minContribution;
        uint256 maxContribution;
        uint256 startTime;
        uint256 endTime;
        address payable wallet;
        address router;
        address mainToken;
        address payToken;
        bool whitelistEnabled;
        string name;
    }

    struct InitVoteParams {
        uint256 airdropAmount;
        uint256 minVote;
        address voteToken;
    }

    function initialize(
        IPresale.InitParams calldata params,
        IPresale.InitVoteParams calldata voteParams,
        uint[] memory _stageTimes,
        uint[] memory _stagePercents,
        uint256 _claimStartTime
    ) external;
    function transferOwnership(address account) external;
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