// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibTestnetStorageReset} from  "../libraries/LibTestnetStorageReset.sol";
import {LibAccessControlEnumerable} from  "../libraries/LibAccessControlEnumerable.sol";

// Deploy on testnet network only
contract TestnetStorageResetFacet {

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function initTestnetStorageResetFacet(address receiver) external {
        LibAccessControlEnumerable.checkRole(LibAccessControlEnumerable.DEPLOYER_ROLE);
        require(receiver != address(0), "TestnetStorageResetFacet: Invalid receiver");
        LibTestnetStorageReset.initialize(receiver);
    }

    function reset(address alp, uint256 blockNo) external {
        LibAccessControlEnumerable.checkRole(ADMIN_ROLE);
        LibTestnetStorageReset.reset(alp, blockNo);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IVault} from "../interfaces/IVault.sol";
import {IWBNB} from "../../dependencies/IWBNB.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

library LibVault {

    using Address for address payable;
    using SafeERC20 for IERC20;

    bytes32 constant VAULT_POSITION = keccak256("apollox.vault.storage");
    uint16 constant BASIS_POINTS_DIVISOR = 10000;

    struct AvailableToken {
        address tokenAddress;
        uint32 tokenAddressPosition;
        uint16 weight;
        uint16 feeBasisPoints;
        uint16 taxBasisPoints;
        uint8 decimals;
        bool stable;
        bool dynamicFee;
    }

    struct VaultStorage {
        mapping(address => AvailableToken) tokens;
        address[] tokenAddresses;
        // tokenAddress => amount
        mapping(address => uint256) treasury;
        address wbnb;
        address exchangeTreasury;
    }

    function vaultStorage() internal pure returns (VaultStorage storage vs) {
        bytes32 position = VAULT_POSITION;
        assembly {
            vs.slot := position
        }
    }

    event AddToken(address indexed token, uint16 weight, uint16 feeBasisPoints, uint16 taxBasisPoints, bool stable, bool dynamicFee);
    event RemoveToken(address indexed token);
    event UpdateToken(
        address indexed token,
        uint16 oldFeeBasisPoints, uint16 oldTaxBasisPoints, bool oldDynamicFee,
        uint16 feeBasisPoints, uint16 taxBasisPoints, bool dynamicFee
    );
    event ChangeWeight(address[] tokenAddress, uint16[] oldWeights, uint16[] newWeights);

    function initialize(address wbnb, address exchangeTreasury_) internal {
        VaultStorage storage vs = vaultStorage();
        require(vs.wbnb == address(0) && vs.exchangeTreasury == address(0), "LibAlpManager: Already initialized");
        vs.wbnb = wbnb;
        vs.exchangeTreasury = exchangeTreasury_;
    }

    function WBNB() internal view returns (address) {
        return vaultStorage().wbnb;
    }

    function exchangeTreasury() internal view returns (address) {
        return vaultStorage().exchangeTreasury;
    }

    function addToken(address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool stable, bool dynamicFee, uint16[] memory weights) internal {
        VaultStorage storage vs = vaultStorage();
        AvailableToken storage at = vs.tokens[tokenAddress];
        require(at.weight == 0, "LibVault: Can't add token that already exists");
        if (dynamicFee && taxBasisPoints <= feeBasisPoints) {
            revert("LibVault: TaxBasisPoints must be greater than feeBasisPoints at dynamic rates");
        }
        at.tokenAddress = tokenAddress;
        at.tokenAddressPosition = uint32(vs.tokenAddresses.length);
        at.feeBasisPoints = feeBasisPoints;
        at.taxBasisPoints = taxBasisPoints;
        at.decimals = IERC20Metadata(tokenAddress).decimals();
        at.stable = stable;
        at.dynamicFee = dynamicFee;

        vs.tokenAddresses.push(tokenAddress);
        emit AddToken(at.tokenAddress, weights[weights.length - 1], at.feeBasisPoints, at.taxBasisPoints, at.stable, at.dynamicFee);
        changeWeight(weights);
    }

    function removeToken(address tokenAddress, uint16[] memory weights) internal {
        VaultStorage storage vs = vaultStorage();
        AvailableToken storage at = vs.tokens[tokenAddress];
        require(at.weight > 0, "LibVault: Token does not exist");

        changeWeight(weights);
        uint256 lastPosition = vs.tokenAddresses.length - 1;
        uint256 tokenAddressPosition = at.tokenAddressPosition;
        if (tokenAddressPosition != lastPosition) {
            address lastTokenAddress = vs.tokenAddresses[lastPosition];
            vs.tokenAddresses[tokenAddressPosition] = lastTokenAddress;
            vs.tokens[lastTokenAddress].tokenAddressPosition = uint32(tokenAddressPosition);
        }
        require(at.weight == 0, "LibVault: The weight of the removed Token must be 0.");
        vs.tokenAddresses.pop();
        delete vs.tokens[tokenAddress];
        emit RemoveToken(tokenAddress);
    }

    function updateToken(address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool dynamicFee) internal {
        VaultStorage storage vs = vaultStorage();
        AvailableToken storage at = vs.tokens[tokenAddress];
        require(at.weight > 0, "LibVault: Token does not exist");
        if (dynamicFee && taxBasisPoints <= feeBasisPoints) {
            revert("LibVault: TaxBasisPoints must be greater than feeBasisPoints at dynamic rates");
        }
        (uint16 oldFeePoints, uint16 oldTaxPoints, bool oldDynamicFee) = (at.feeBasisPoints, at.taxBasisPoints, at.dynamicFee);
        at.feeBasisPoints = feeBasisPoints;
        at.taxBasisPoints = taxBasisPoints;
        at.dynamicFee = dynamicFee;
        emit UpdateToken(tokenAddress, oldFeePoints, oldTaxPoints, oldDynamicFee, feeBasisPoints, taxBasisPoints, dynamicFee);
    }

    function changeWeight(uint16[] memory weights) internal {
        VaultStorage storage vs = vaultStorage();
        require(weights.length == vs.tokenAddresses.length, "LibVault: ");
        uint16 totalWeight;
        uint16[] memory oldWeights = new uint16[](weights.length);
        for (uint256 i; i < weights.length; i++) {
            totalWeight += weights[i];
            address tokenAddress = vs.tokenAddresses[i];
            uint16 oldWeight = vs.tokens[tokenAddress].weight;
            oldWeights[i] = oldWeight;
            vs.tokens[tokenAddress].weight = weights[i];
        }
        require(totalWeight == BASIS_POINTS_DIVISOR, "LibVault: Invalid weights");
        emit ChangeWeight(vs.tokenAddresses, oldWeights, weights);
    }

    function deposit(address token, uint256 amount) internal {
        deposit(token, amount, address(0), true);
    }

    // The caller checks whether the token exists and the amount>0
    // in order to return quickly in case of an error
    function deposit(address token, uint256 amount, address from, bool transferred) internal {
        if (!transferred) {
            IERC20(token).safeTransferFrom(from, address(this), amount);
        }
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        vs.treasury[token] += amount;
    }

    function depositBNB(uint256 amount) internal {
        IWBNB(WBNB()).deposit{value : amount}();
        deposit(WBNB(), amount);
    }

    // The caller checks whether the token exists and the amount>0
    // in order to return quickly in case of an error
    function withdraw(address receiver, address token, uint256 amount) internal {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        require(vs.treasury[token] >= amount, "LibVault: Treasury insufficient balance");
        vs.treasury[token] -= amount;
        IERC20(token).safeTransfer(receiver, amount);
    }

    function withdrawBNB(address payable receiver, uint256 amount) internal {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        require(vs.treasury[WBNB()] >= amount, "LibVault: Treasury insufficient balance");
        IWBNB(WBNB()).withdraw(amount);
        vs.treasury[WBNB()] -= amount;
        receiver.sendValue(amount);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IWBNB} from "../../dependencies/IWBNB.sol";
import {LibVault} from  "../libraries/LibVault.sol";
import {LibApxReward} from  "../libraries/LibApxReward.sol";
import {LibAlpManager} from  "../libraries/LibAlpManager.sol";
import {LibStakeReward} from  "../libraries/LibStakeReward.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library LibTestnetStorageReset {

    using Address for address payable;
    using SafeERC20 for IERC20;

    bytes32 constant TESTNET_STORAGE_POSITION = keccak256("apollox.testnet.storage.reset");

    struct TestnetStorage {
        address receiver;
    }

    function testnetStorage() internal pure returns (TestnetStorage storage ts) {
        bytes32 position = TESTNET_STORAGE_POSITION;
        assembly {
            ts.slot := position
        }
    }

    function initialize(address receiver) internal {
        TestnetStorage storage ts = testnetStorage();
        require(ts.receiver == address(0), "LibTestnetStorageReset: Already initialized");
        ts.receiver = receiver;
    }

    function reset(address alp, uint256 blockNo) internal {
        address receiver = testnetStorage().receiver;

        // Clear APX
        IERC20 apx = LibApxReward.apxRewardStorage().rewardToken;
        apx.safeTransfer(receiver, apx.balanceOf(address(this)));

        // Clear old ALP
        IERC20 oldAlp = LibStakeReward.stakeRewardStorage().stakingToken;
        oldAlp.safeTransfer(receiver, oldAlp.balanceOf(address(this)));

        _resetAlpManagerStorage(alp, blockNo);
        _resetVaultStorage(receiver);
        // _resetStakeRewardStorage(alp);
        // _resetApxRewardStorage();
    }

    function _resetAlpManagerStorage(address alp, uint256 blockNo) private {
        LibAlpManager.AlpManagerStorage storage ams = LibAlpManager.alpManagerStorage();
        ams.alp = alp;
        ams.alpIncrement[blockNo] = 0;
        ams.pointAlpIncrement[blockNo] = 0;
    }

    function _resetVaultStorage(address receiver) private {
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        address[] storage tokenAddresses = vs.tokenAddresses;
        IWBNB wbnb = IWBNB(vs.wbnb);

        for (uint8 i; i < tokenAddresses.length; i++) {
            address token = tokenAddresses[i];
            IERC20 erc20 = IERC20(token);
            uint256 amount = erc20.balanceOf(address(this));
            if (token == vs.wbnb) {
                wbnb.withdraw(amount);
                payable(receiver).sendValue(amount);
            } else {
                erc20.safeTransfer(receiver, amount);
            }
            vs.treasury[token] = 0;
        }
    }

    function _resetStakeRewardStorage(address alp) private {
        // Redeploy a new LibStakeReward contract, the new contract modifies the storage location.
        // So there is no need to reset the storage of this contract
    }

    function _resetApxRewardStorage() private {
        // Redeploy a new LibApxReward contract, the new contract modifies the storage location.
        // So there is no need to reset the storage of this contract
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibApxReward} from  "../libraries/LibApxReward.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library LibStakeReward {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    bytes32 constant STAKE_REWARD_POSITION = keccak256("apollox.stake.reward.storage.v2");

    /* ========== STATE VARIABLES ========== */
    struct StakeRewardStorage {
        IERC20 stakingToken;
        uint256 totalStaked;
        mapping(address => uint256) userStaked;
        mapping(address => uint256) lastBlockNumberCalled;
    }

    /* ========== EVENTS ========== */
    event Stake(address indexed account, uint256 amount);
    event UnStake(address indexed account, uint256 amount);

    function stakeRewardStorage() internal pure returns (StakeRewardStorage storage st) {
        bytes32 position = STAKE_REWARD_POSITION;
        assembly {
            st.slot := position
        }
    }

    function initialize(address _stakingToken) internal {
        StakeRewardStorage storage st = stakeRewardStorage();
        require(address(st.stakingToken) == address(0), "Already initialized!");
        st.stakingToken = IERC20(_stakingToken);
    }

    /* ========== VIEWS ========== */
    function totalStaked() internal view returns (uint256) {
        StakeRewardStorage storage st = stakeRewardStorage();
        return st.totalStaked;
    }

    function stakeOf(address _user) internal view returns (uint256) {
        StakeRewardStorage storage st = stakeRewardStorage();
        return st.userStaked[_user];
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function checkOncePerBlock(address user) internal {
        StakeRewardStorage storage st = stakeRewardStorage();
        require(st.lastBlockNumberCalled[user] < block.number, "once per block");
        st.lastBlockNumberCalled[user] = block.number;
    }

    function stake(uint256 _amount) internal {
        require(_amount > 0, 'Invalid amount');

        StakeRewardStorage storage st = stakeRewardStorage();
        st.stakingToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        st.userStaked[msg.sender] = st.userStaked[msg.sender].add(_amount);
        st.totalStaked = st.totalStaked.add(_amount);
        LibApxReward.stake(_amount);
        emit Stake(msg.sender, _amount);
    }

    function unStake(uint256 _amount) internal {
        require(_amount > 0, "Invalid withdraw amount");

        StakeRewardStorage storage st = stakeRewardStorage();
        uint256 old = st.userStaked[msg.sender];
        require(old >= _amount, "Insufficient balance");
        st.userStaked[msg.sender] = old.sub(_amount);
        st.totalStaked = st.totalStaked.sub(_amount);
        LibApxReward.unStake(_amount);
        st.stakingToken.safeTransfer(address(msg.sender), _amount);

        emit UnStake(msg.sender, _amount);
    }

    function claimAllReward() internal {
        LibApxReward.claimApxReward(msg.sender);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibChainlinkPrice} from  "../libraries/LibChainlinkPrice.sol";

library LibPriceFacade {

    uint8 constant public PRICE_DECIMALS = 8;
    uint8 constant public USD_DECIMALS = 18;

    function getPrice(address token) internal view returns (uint256) {
        // Later change to take prices from Chainlink Oracle and Binance Oracle and AMM LP and aggregate them
        (uint256 price, uint8 decimals) = LibChainlinkPrice.getPriceFromChainlink(token);
        return decimals == PRICE_DECIMALS ? price : price * (10 ** PRICE_DECIMALS) / (10 ** decimals);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library LibChainlinkPrice {

    bytes32 constant CHAINLINK_PRICE_POSITION = keccak256("apollox.chainlink.price.storage");

    struct PriceFeed {
        address tokenAddress;
        address feedAddress;
        uint32 tokenAddressPosition;
    }

    struct ChainlinkPriceStorage {
        mapping(address => PriceFeed) priceFeeds;
        address[] tokenAddresses;
    }

    function chainlinkPriceStorage() internal pure returns (ChainlinkPriceStorage storage cps) {
        bytes32 position = CHAINLINK_PRICE_POSITION;
        assembly {
            cps.slot := position
        }
    }

    event SupportChainlinkPriceFeed(address indexed token, address indexed priceFeed, bool supported);

    function addChainlinkPriceFeed(address tokenAddress, address priceFeed) internal {
        ChainlinkPriceStorage storage cps = chainlinkPriceStorage();
        PriceFeed storage pf = cps.priceFeeds[tokenAddress];
        require(pf.feedAddress == address(0), "LibChainlinkPrice: Can't add price feed that already exists");
        pf.tokenAddress = tokenAddress;
        pf.feedAddress = priceFeed;
        pf.tokenAddressPosition = uint32(cps.tokenAddresses.length);

        cps.tokenAddresses.push(tokenAddress);
        emit SupportChainlinkPriceFeed(tokenAddress, priceFeed, true);
    }

    function removeChainlinkPriceFeed(address tokenAddress) internal {
        ChainlinkPriceStorage storage cps = chainlinkPriceStorage();
        PriceFeed storage pf = cps.priceFeeds[tokenAddress];
        address priceFeed = pf.feedAddress;
        require(pf.feedAddress != address(0), "LibChainlinkPrice: Price feed does not exist");

        uint256 lastPosition = cps.tokenAddresses.length - 1;
        uint256 tokenAddressPosition = pf.tokenAddressPosition;
        if (tokenAddressPosition != lastPosition) {
            address lastTokenAddress = cps.tokenAddresses[lastPosition];
            cps.tokenAddresses[tokenAddressPosition] = lastTokenAddress;
            cps.priceFeeds[lastTokenAddress].tokenAddressPosition = uint32(tokenAddressPosition);
        }
        cps.tokenAddresses.pop();
        delete cps.priceFeeds[tokenAddress];
        emit SupportChainlinkPriceFeed(tokenAddress, priceFeed, false);
    }

    function getPriceFromChainlink(address token) internal view returns (uint256 price, uint8 decimals) {
        ChainlinkPriceStorage storage cps = chainlinkPriceStorage();
        address priceFeed = cps.priceFeeds[token].feedAddress;
        require(priceFeed != address(0), "ChainlinkPriceFacet: Price feed does not exist");
        AggregatorV3Interface oracle = AggregatorV3Interface(priceFeed);
        (,int256 price_,,,) = oracle.latestRoundData();
        price = uint256(price_);
        decimals = oracle.decimals();
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibVault} from  "../libraries/LibVault.sol";
import {ICexAsset} from "../../dependencies/ICexAsset.sol";
import {LibPriceFacade} from  "../libraries/LibPriceFacade.sol";

library LibCexVault {

    bytes32 constant CEX_VAULT_STORAGE_POSITION = keccak256("apollox.cex.vault.storage");
    uint16 constant  RATE_BASE = 10000;

    struct CexVaultStorage {
        address cexOracle;
        uint16 securityMarginRate;
    }

    function cexVaultStorage() internal pure returns (CexVaultStorage storage cvs) {
        bytes32 position = CEX_VAULT_STORAGE_POSITION;
        assembly {
            cvs.slot := position
        }
    }

    function initialize(address cexOracle, uint16 securityMarginRate) internal {
        CexVaultStorage storage cvs = cexVaultStorage();
        require(cvs.cexOracle == address(0), "LibCexVault: Already initialized");
        cvs.cexOracle = cexOracle;
        cvs.securityMarginRate = securityMarginRate;
    }

    event SetSecurityMarginRate(uint16 oldRate, uint16 newRate);

    function updateCexOracle(address cexOracle) internal {
        CexVaultStorage storage cvs = cexVaultStorage();
        cvs.cexOracle = cexOracle;
    }

    function setSecurityMarginRate(uint16 securityMarginRate) internal {
        CexVaultStorage storage cvs = cexVaultStorage();
        uint16 oldRate = cvs.securityMarginRate;
        cvs.securityMarginRate = securityMarginRate;
        emit SetSecurityMarginRate(oldRate, securityMarginRate);
    }

    function getCexTotalValueUsd() internal view returns (int256 totalValueUsd, uint256 blockNo) {
        CexVaultStorage storage cvs = cexVaultStorage();
        ICexAsset.BatchAssetRecord memory assetRecord;
        for (uint8 i; i < 5; i++) {
            assetRecord = ICexAsset(cvs.cexOracle).getRecordsAtIndex(i);
            if (assetRecord.blockNumber != block.number) {
                break;
            }
        }
        require(assetRecord.blockNumber != block.number, "LibCexVault: Lack of historical data");
        LibVault.VaultStorage storage vs = LibVault.vaultStorage();
        ICexAsset.AssetDetailRecord[] memory assetRecords = assetRecord.records;
        for (uint256 i; i < assetRecords.length; i++) {
            ICexAsset.AssetDetailRecord memory asset = assetRecords[i];
            LibVault.AvailableToken storage at = vs.tokens[asset.symbol];
            if (at.weight > 0 &&
                (asset.assetType == ICexAsset.AssetType.AssetBalance || asset.assetType == ICexAsset.AssetType.UnRealizedPnl)) {
                uint256 price = LibPriceFacade.getPrice(asset.symbol);
                int256 valueUsd = int256(price) * int256(asset.balance) * int256((10 ** LibPriceFacade.USD_DECIMALS)) / int256((10 ** (LibPriceFacade.PRICE_DECIMALS + at.decimals)));
                totalValueUsd += valueUsd;
            }
        }
        return (totalValueUsd, assetRecord.blockNumber);
    }

    function lastBlockNumberPoint() internal view returns (uint256) {
        return ICexAsset(cexVaultStorage().cexOracle).getRecordsAtIndex(0).blockNumber;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IApxReward} from "../interfaces/IApxReward.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

library LibApxReward {

    using SafeMath for uint;
    using SafeERC20 for IERC20;

    bytes32 constant APX_REWARD_POSITION = keccak256("apollox.apx.reward.storage");

    /* ========== STATE VARIABLES ========== */
    struct ApxRewardStorage {
        IERC20 rewardToken;
        // Mining start block
        uint256 startBlock;
        // Info of each pool.
        IApxReward.ApxPoolInfo poolInfo;
        // Info of each user that stakes LP tokens.
        mapping(address => IApxReward.ApxUserInfo) userInfo;
    }

    event ClaimApxReward(address indexed user, uint256 reward);
    event AddReserve(address indexed appropriator, uint256 amount);

    function apxRewardStorage() internal pure returns (ApxRewardStorage storage ars) {
        bytes32 position = APX_REWARD_POSITION;
        assembly {
            ars.slot := position
        }
    }

    function initialize(address _rewardsToken, uint256 _apxPerBlock, uint256 _startBlock) internal {
        ApxRewardStorage storage st = apxRewardStorage();
        require(address(st.rewardToken) == address(0), "Already initialized!");
        st.rewardToken = IERC20(_rewardsToken);
        st.startBlock = _startBlock;
        // staking pool
        st.poolInfo = IApxReward.ApxPoolInfo({
            totalStaked : 0,
            apxPerBlock : _apxPerBlock,
            lastRewardBlock : _startBlock,
            accAPXPerShare : 0,
            totalReward : 0,
            reserve: 0
        });
    }

    /* ========== VIEWS ========== */

    function apxPoolInfo() internal view returns (IApxReward.ApxPoolInfo memory poolInfo) {
        ApxRewardStorage storage ars = apxRewardStorage();
        IApxReward.ApxPoolInfo storage pool = ars.poolInfo;

        poolInfo.totalStaked = pool.totalStaked;
        poolInfo.apxPerBlock = pool.apxPerBlock;
        poolInfo.lastRewardBlock = pool.lastRewardBlock;
        poolInfo.accAPXPerShare = pool.accAPXPerShare;

        uint256 apxReward;
        if (block.number > pool.lastRewardBlock && pool.totalStaked != 0) {
            uint256 blockGap = block.number.sub(pool.lastRewardBlock);
            apxReward = blockGap.mul(pool.apxPerBlock);
        }
        poolInfo.totalReward = pool.totalReward.add(apxReward);
    }

    // View function to see pending APXs on frontend.
    function pendingApx(address _user) internal view returns (uint256) {
        ApxRewardStorage storage st = apxRewardStorage();
        IApxReward.ApxPoolInfo storage pool = st.poolInfo;
        IApxReward.ApxUserInfo storage user = st.userInfo[_user];
        uint256 accApxPerShare = pool.accAPXPerShare;
        uint256 lpSupply = pool.totalStaked;

        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockGap = block.number.sub(pool.lastRewardBlock);
            uint256 apxReward = blockGap.mul(pool.apxPerBlock);
            accApxPerShare = accApxPerShare.add(apxReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accApxPerShare).div(1e12).sub(user.rewardDebt).add(user.pendingReward);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */
    function stake(uint256 _amount) internal {
        ApxRewardStorage storage st = apxRewardStorage();
        require(_amount > 0, 'Invalid amount');
        require(block.number >= st.startBlock, "Mining not started yet");
        IApxReward.ApxPoolInfo storage pool = st.poolInfo;
        IApxReward.ApxUserInfo storage user = st.userInfo[msg.sender];
        updatePool();
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accAPXPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingReward = user.pendingReward.add(pending);
            }
        }

        pool.totalStaked = pool.totalStaked.add(_amount);
        user.amount = user.amount.add(_amount);
        user.rewardDebt = user.amount.mul(pool.accAPXPerShare).div(1e12);
    }

    function unStake(uint256 _amount) internal {
        ApxRewardStorage storage st = apxRewardStorage();

        IApxReward.ApxPoolInfo storage pool = st.poolInfo;
        IApxReward.ApxUserInfo storage user = st.userInfo[msg.sender];

        require(_amount > 0, "Invalid withdraw amount");
        require(user.amount >= _amount, "Insufficient balance");
        updatePool();
        uint256 pending = user.amount.mul(pool.accAPXPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            user.pendingReward = user.pendingReward.add(pending);
        }

        user.amount = user.amount.sub(_amount);
        pool.totalStaked = pool.totalStaked.sub(_amount);
        user.rewardDebt = user.amount.mul(pool.accAPXPerShare).div(1e12);
    }

    function claimApxReward(address account) internal {
        ApxRewardStorage storage st = apxRewardStorage();
        IApxReward.ApxPoolInfo storage pool = st.poolInfo;
        IApxReward.ApxUserInfo storage user = st.userInfo[account];

        updatePool();
        uint256 pending = user.amount.mul(pool.accAPXPerShare).div(1e12).sub(user.rewardDebt).add(user.pendingReward);
        if (pending > 0) {
            user.pendingReward = 0;
            user.rewardDebt = user.amount.mul(pool.accAPXPerShare).div(1e12);
            require(pool.reserve >= pending, "LibApxReward: APX reserve shortage");
            pool.reserve -= pending;
            st.rewardToken.safeTransfer(account, pending);
            emit ClaimApxReward(account, pending);
        }
    }

    function addReserve(uint256 amount) internal {
        ApxRewardStorage storage ars = apxRewardStorage();
        IApxReward.ApxPoolInfo storage pool = ars.poolInfo;
        ars.rewardToken.transferFrom(msg.sender, address(this), amount);
        pool.reserve += amount;
        emit AddReserve(msg.sender, amount);
    }

    //Todo test apxPerBlock updated
    function updateApxPerBlock(uint256 _apxPerBlock) internal {
        ApxRewardStorage storage st = apxRewardStorage();
        require(_apxPerBlock >= 0, "apxPerBlock greater than 0");
        updatePool();
        st.poolInfo.apxPerBlock = _apxPerBlock;
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() internal {
        ApxRewardStorage storage st = apxRewardStorage();
        IApxReward.ApxPoolInfo storage pool = st.poolInfo;
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.totalStaked;
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockGap = block.number.sub(pool.lastRewardBlock);
        uint256 apxReward = blockGap.mul(pool.apxPerBlock);
        pool.totalReward = pool.totalReward.add(apxReward);
        pool.accAPXPerShare = pool.accAPXPerShare.add(apxReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {LibVault} from  "../libraries/LibVault.sol";
import {ICexVault} from "../interfaces/ICexVault.sol";
import {LibCexVault} from  "../libraries/LibCexVault.sol";
import {LibPriceFacade} from  "../libraries/LibPriceFacade.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library LibAlpManager {

    bytes32 constant ALP_MANAGER_STORAGE_POSITION = keccak256("apollox.alp.manager.storage");
    uint8 constant  ALP_DECIMALS = 18;

    struct AlpManagerStorage {
        mapping(address => uint256) lastMintedAt;
        uint256 coolingDuration;
        address alp;
        // blockNumber => ALP Increase in quantity, possibly negative
        mapping(uint256 => int256) alpIncrement;
        // ICexAsset.BatchAssetRecord.blockNumber => ALP Increase in quantity, possibly negative
        mapping(uint256 => int256) pointAlpIncrement;
    }

    function alpManagerStorage() internal pure returns (AlpManagerStorage storage ams) {
        bytes32 position = ALP_MANAGER_STORAGE_POSITION;
        assembly {
            ams.slot := position
        }
    }

    function initialize(address alpToken) internal {
        AlpManagerStorage storage ams = alpManagerStorage();
        require(ams.alp == address(0), "LibAlpManager: Already initialized");
        ams.alp = alpToken;
        // default 15 minutes
        ams.coolingDuration = 900;
    }

    event AddLiquidity(address indexed account, address indexed token, uint256 amount);
    event RemoveLiquidity(address indexed account, address indexed token, uint256 amount);

    function alpPrice() internal view returns (uint256) {
        (int256 totalValueUsd, uint256 blockNo) = LibCexVault.getCexTotalValueUsd();
        require(totalValueUsd >= 0, "LibAlpManager: Cex vault has a negative number of funds");
        AlpManagerStorage storage ams = alpManagerStorage();
        uint256 totalSupply = IERC20(ams.alp).totalSupply();
        int256 amountOfChange = ams.pointAlpIncrement[blockNo];
        for (uint256 i = 1; i <= block.number - blockNo; i++) {
            amountOfChange += ams.alpIncrement[blockNo + i];
        }
        int256 beforeTotalSupply = int256(totalSupply) - amountOfChange;
        require(beforeTotalSupply >= 0, "LibAlpManager: ALP quantity error");
        if (beforeTotalSupply == 0) {
            return 10 ** LibPriceFacade.PRICE_DECIMALS;
        } else {
            return uint256(totalValueUsd) * (10 ** LibPriceFacade.PRICE_DECIMALS) / uint256(beforeTotalSupply);
        }
    }

    function mintAlp(address account, address tokenIn, uint256 amount) internal returns (uint256 alpAmount){
        alpAmount = _calculateAlpAmount(tokenIn, amount);
        LibVault.deposit(tokenIn, amount, account, false);
        _addMinted(account);
        _alpIncrease(int256(alpAmount));
        emit AddLiquidity(account, tokenIn, amount);
    }

    function mintAlpBNB(address account, uint256 amount) internal returns (uint256 alpAmount){
        address tokenIn = LibVault.WBNB();
        alpAmount = _calculateAlpAmount(tokenIn, amount);
        LibVault.depositBNB(amount);
        _addMinted(account);
        _alpIncrease(int256(alpAmount));
        emit AddLiquidity(account, tokenIn, amount);
    }

    function _calculateAlpAmount(address tokenIn, uint256 amount) private view returns (uint256 alpAmount) {
        LibVault.AvailableToken storage at = LibVault.vaultStorage().tokens[tokenIn];
        require(at.weight > 0, "LibAlpManager: Token does not exist");
        uint256 tokenInPrice = LibPriceFacade.getPrice(tokenIn);
        uint256 amountUsd = tokenInPrice * amount * (10 ** LibPriceFacade.USD_DECIMALS) / (10 ** (at.decimals + LibPriceFacade.PRICE_DECIMALS));
        uint256 afterTaxAmountUsd = amountUsd * (LibVault.BASIS_POINTS_DIVISOR - getMintFeePoint(at)) / LibVault.BASIS_POINTS_DIVISOR;
        alpAmount = afterTaxAmountUsd * 10 ** LibPriceFacade.PRICE_DECIMALS / alpPrice();
    }

    function _addMinted(address account) private {
        alpManagerStorage().lastMintedAt[account] = block.timestamp;
    }

    function _alpIncrease(int256 amount) private {
        AlpManagerStorage storage ams = alpManagerStorage();
        if (LibCexVault.lastBlockNumberPoint() == block.number) {
            ams.pointAlpIncrement[block.number] += amount;
        } else {
            ams.alpIncrement[block.number] += amount;
        }
    }

    function getMintFeePoint(LibVault.AvailableToken storage at) internal view returns (uint16) {
        // Dynamic rates are not supported in Phase I
        // Soon it will be supported
        require(!at.dynamicFee, "LibAlpManager: Dynamic fee rates are not supported at this time");
        return at.feeBasisPoints;
    }

    function burnAlp(address account, address tokenOut, uint256 alpAmount, address receiver) internal returns (uint256 amountOut) {
        amountOut = _calculateTokenAmount(account, tokenOut, alpAmount);
        LibVault.withdraw(receiver, tokenOut, amountOut);
        _alpIncrease(int256(0) - int256(alpAmount));
        emit RemoveLiquidity(account, tokenOut, amountOut);
    }

    function burnAlpBNB(address account, uint256 alpAmount, address payable receiver) internal returns (uint256 amountOut) {
        address tokenOut = LibVault.WBNB();
        amountOut = _calculateTokenAmount(account, tokenOut, alpAmount);
        LibVault.withdrawBNB(receiver, amountOut);
        _alpIncrease(int256(0) - int256(alpAmount));
        emit RemoveLiquidity(account, tokenOut, amountOut);
    }

    function _calculateTokenAmount(address account, address tokenOut, uint256 alpAmount) private view returns (uint256 amountOut) {
        LibVault.AvailableToken storage at = LibVault.vaultStorage().tokens[tokenOut];
        require(at.weight > 0, "LibAlpManager: Token does not exist");
        AlpManagerStorage storage ams = alpManagerStorage();
        require(ams.lastMintedAt[account] + ams.coolingDuration <= block.timestamp, "LibAlpManager: Cooling duration not yet passed");
        uint256 tokenOutPrice = LibPriceFacade.getPrice(tokenOut);
        uint256 amountOutUsd = alpPrice() * alpAmount * (10 ** LibPriceFacade.USD_DECIMALS) / (10 ** (LibPriceFacade.PRICE_DECIMALS + ALP_DECIMALS));
        uint256 afterTaxAmountOutUsd = amountOutUsd * (LibVault.BASIS_POINTS_DIVISOR - getBurnFeePoint(at)) / LibVault.BASIS_POINTS_DIVISOR;
        amountOut = afterTaxAmountOutUsd * 10 ** (LibPriceFacade.PRICE_DECIMALS + at.decimals) / (tokenOutPrice * 10 ** LibPriceFacade.USD_DECIMALS);
    }

    function getBurnFeePoint(LibVault.AvailableToken storage at) internal view returns (uint16) {
        // Dynamic rates are not supported in Phase I
        // Soon it will be supported
        require(!at.dynamicFee, "LibAlpManager: Dynamic fee rates are not supported at this time");
        return at.taxBasisPoints;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library LibAccessControlEnumerable {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 constant ACCESS_CONTROL_STORAGE_POSITION = keccak256("apollox.access.control.storage");
    bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    struct AccessControlStorage {
        mapping(bytes32 => RoleData) roles;
        mapping(bytes32 => EnumerableSet.AddressSet) roleMembers;
        mapping(bytes4 => bool) supportedInterfaces;
    }

    function accessControlStorage() internal pure returns (AccessControlStorage storage acs) {
        bytes32 position = ACCESS_CONTROL_STORAGE_POSITION;
        assembly {
            acs.slot := position
        }
    }

    function checkRole(bytes32 role) internal view {
        checkRole(role, msg.sender);
    }

    function checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
            string(
                abi.encodePacked(
                    "AccessControl: account ",
                    Strings.toHexString(account),
                    " is missing role ",
                    Strings.toHexString(uint256(role), 32)
                )
            )
            );
        }
    }

    function hasRole(bytes32 role, address account) internal view returns (bool) {
        AccessControlStorage storage acs = accessControlStorage();
        return acs.roles[role].members[account];
    }

    function grantRole(bytes32 role, address account) internal {
        AccessControlStorage storage acs = accessControlStorage();
        if (!hasRole(role, account)) {
            acs.roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
        acs.roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) internal {
        AccessControlStorage storage acs = accessControlStorage();
        if (hasRole(role, account)) {
            acs.roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
        acs.roleMembers[role].remove(account);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        AccessControlStorage storage acs = accessControlStorage();
        bytes32 previousAdminRole = acs.roles[role].adminRole;
        acs.roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IVault {

    event TransferToExchangeTreasuryBNB(uint256 amount);
    event TransferToExchangeTreasury(address[] tokens, uint256[] amounts);
    event ReceiveFromExchangeTreasury(address[] tokens, uint256[] amounts);

    struct Token {
        address tokenAddress;
        uint16 weight;
        uint16 feeBasisPoints;
        uint16 taxBasisPoints;
        bool stable;
        bool dynamicFee;
    }

    struct LpItem {
        address tokenAddress;
        int256 value;
        uint8 decimals;
        int256 valueUsd; // decimals = 18
        uint16 targetWeight;
        uint16 feeBasisPoints;
        uint16 taxBasisPoints;
        bool dynamicFee;
    }

    function addToken(address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool stable, bool dynamicFee, uint16[] memory weights) external;

    function removeToken(address tokenAddress, uint16[] memory weights) external;

    function updateToken(address tokenAddress, uint16 feeBasisPoints, uint16 taxBasisPoints, bool dynamicFee) external;

    function changeWeight(uint16[] memory weights) external;

    function tokens() external view returns (Token[] memory tokens_);

    function getTokenByAddress(address tokenAddress) external view returns (Token memory token_);

    function itemValue(address token) external view returns (LpItem memory lpItem);

    function totalValue() external view returns (LpItem[] memory lpItems);

    function transferToExchangeTreasury(address[] calldata tokens, uint256[] calldata amounts) external;

    function transferToExchangeTreasuryBNB(uint256 amount) external;

    function receiveFromExchangeTreasury(bytes[] calldata messages, bytes[] calldata signatures) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IVault} from "../interfaces/IVault.sol";

interface ICexVault {

    function cexOracle() external view returns (address);

    function updateCexOracle(address cexOracle) external;

    function securityMarginRate() external view returns (uint16);

    function setSecurityMarginRate(uint16 securityMarginRate) external;

    function itemCexValue(address tokenAddress) external view returns (IVault.LpItem memory lpItem);

    function totalCexValue() external view returns (IVault.LpItem[] memory lpItems);

    function maxWithdrawAbleUsd() external view returns (int256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IApxReward {

    struct ApxPoolInfo {
        uint256 totalStaked;
        uint256 apxPerBlock;        //award per block
        uint256 lastRewardBlock;   // Last block number that APXs distribution occurs.
        uint256 accAPXPerShare;    // Accumulated APXs per share, times 1e12. See below.
        uint256 totalReward;
        uint256 reserve;
    }

    struct ApxUserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 pendingReward; // User pending reward
        //
        // We do some fancy math here. Basically, any point in time, the amount of APXs
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accAPXPerShare) - user.rewardDebt + user.rewardPending
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accAPXPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User's `pendingReward` gets updated.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    function updateApxPerBlock(uint256 apxPerBlock) external;

    function addReserve(uint256 amount) external;

    function apxPoolInfo() external view returns (ApxPoolInfo memory) ;

    function pendingApx(address _account) external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IWBNB {
    function deposit() external payable;

    function withdraw(uint) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICexAsset {
    enum AssetType {AssetBalance, UnRealizedPnl, TotalNotional}

    struct AssetDetailRecord {
        address symbol;
        int192 balance;
        AssetType assetType;
    }

    struct BatchAssetRecord {
        AssetDetailRecord[] records;
        uint256 blockNumber;
    }

    function getRecordsAtIndex(uint256 _index) external view returns (BatchAssetRecord memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
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
library SafeMath {
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
// OpenZeppelin Contracts (last updated v4.8.0) (utils/math/Math.sol)

pragma solidity ^0.8.0;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    enum Rounding {
        Down, // Toward negative infinity
        Up, // Toward infinity
        Zero // Toward zero
    }

    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
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
        // (a + b) / 2 can overflow.
        return (a & b) + (a ^ b) / 2;
    }

    /**
     * @dev Returns the ceiling of the division of two numbers.
     *
     * This differs from standard division with `/` in that it rounds up instead
     * of rounding down.
     */
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b - 1) / b can overflow on addition, so we distribute.
        return a == 0 ? 0 : (a - 1) / b + 1;
    }

    /**
     * @notice Calculates floor(x * y / denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
     * @dev Original credit to Remco Bloemen under MIT license (https://xn--2-umb.com/21/muldiv)
     * with further edits by Uniswap Labs also under MIT license.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1, then use
            // use the Chinese Remainder Theorem to reconstruct the 512 bit result. The result is stored in two 256
            // variables such that product = prod1 * 2^256 + prod0.
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Handle non-overflow cases, 256 by 256 division.
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            // Make sure the result is less than 2^256. Also prevents denominator == 0.
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 by 256 division.
            ///////////////////////////////////////////////

            // Make division exact by subtracting the remainder from [prod1 prod0].
            uint256 remainder;
            assembly {
                // Compute remainder using mulmod.
                remainder := mulmod(x, y, denominator)

                // Subtract 256 bit number from 512 bit number.
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator and compute largest power of two divisor of denominator. Always >= 1.
            // See https://cs.stackexchange.com/q/138556/92363.

            // Does not overflow because the denominator cannot be zero at this stage in the function.
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                // Divide denominator by twos.
                denominator := div(denominator, twos)

                // Divide [prod1 prod0] by twos.
                prod0 := div(prod0, twos)

                // Flip twos such that it is 2^256 / twos. If twos is zero, then it becomes one.
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift in bits from prod1 into prod0.
            prod0 |= prod1 * twos;

            // Invert denominator mod 2^256. Now that denominator is an odd number, it has an inverse modulo 2^256 such
            // that denominator * inv = 1 mod 2^256. Compute the inverse by starting with a seed that is correct for
            // four bits. That is, denominator * inv = 1 mod 2^4.
            uint256 inverse = (3 * denominator) ^ 2;

            // Use the Newton-Raphson iteration to improve the precision. Thanks to Hensel's lifting lemma, this also works
            // in modular arithmetic, doubling the correct bits in each step.
            inverse *= 2 - denominator * inverse; // inverse mod 2^8
            inverse *= 2 - denominator * inverse; // inverse mod 2^16
            inverse *= 2 - denominator * inverse; // inverse mod 2^32
            inverse *= 2 - denominator * inverse; // inverse mod 2^64
            inverse *= 2 - denominator * inverse; // inverse mod 2^128
            inverse *= 2 - denominator * inverse; // inverse mod 2^256

            // Because the division is now exact we can divide by multiplying with the modular inverse of denominator.
            // This will give us the correct result modulo 2^256. Since the preconditions guarantee that the outcome is
            // less than 2^256, this is the final result. We don't need to compute the high bits of the result and prod1
            // is no longer required.
            result = prod0 * inverse;
            return result;
        }
    }

    /**
     * @notice Calculates x * y / denominator with full precision, following the selected rounding direction.
     */
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }

    /**
     * @dev Returns the square root of a number. If the number is not a perfect square, the value is rounded down.
     *
     * Inspired by Henry S. Warren, Jr.'s "Hacker's Delight" (Chapter 11).
     */
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        // For our first guess, we get the biggest power of 2 which is smaller than the square root of the target.
        //
        // We know that the "msb" (most significant bit) of our target number `a` is a power of 2 such that we have
        // `msb(a) <= a < 2*msb(a)`. This value can be written `msb(a)=2**k` with `k=log2(a)`.
        //
        // This can be rewritten `2**log2(a) <= a < 2**(log2(a) + 1)`
        // → `sqrt(2**k) <= sqrt(a) < sqrt(2**(k+1))`
        // → `2**(k/2) <= sqrt(a) < 2**((k+1)/2) <= 2**(k/2 + 1)`
        //
        // Consequently, `2**(log2(a) / 2)` is a good first approximation of `sqrt(a)` with at least 1 correct bit.
        uint256 result = 1 << (log2(a) >> 1);

        // At this point `result` is an estimation with one bit of precision. We know the true value is a uint128,
        // since it is the square root of a uint256. Newton's method converges quadratically (precision doubles at
        // every iteration). We thus need at most 7 iteration to turn our partial result with one bit of precision
        // into the expected uint128 result.
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }

    /**
     * @notice Calculates sqrt(a), following the selected rounding direction.
     */
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 2, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 2, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 10, rounded down, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }

    /**
     * @dev Return the log in base 256, rounded down, of a positive value.
     * Returns 0 if given 0.
     *
     * Adding one to the result gives the number of pairs of hex symbols needed to represent `value` as a hex string.
     */
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }

    /**
     * @dev Return the log in base 10, following the selected rounding direction, of a positive value.
     * Returns 0 if given 0.
     */
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

import "./math/Math.sol";

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

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
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
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
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/utils/SafeERC20.sol)

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
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
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
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}