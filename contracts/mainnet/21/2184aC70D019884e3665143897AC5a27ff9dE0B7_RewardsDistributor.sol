// SPDX-License-Identifier: NONE

pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ProxyImplementation.sol";
import "./GovernableImplementation.sol";

import "./interfaces/IUnkwnPool.sol";
import "./interfaces/IVoterProxy.sol";
import "./interfaces/IUnkwnPoolFactory.sol";
import "./interfaces/IUnkwnLens.sol";
import "./interfaces/IUnCone.sol";
import "./interfaces/IMultiRewards.sol";
import "./interfaces/ICvlUnkwn.sol";
import "./interfaces/IGauge.sol";
import "./interfaces/IUnkwn.sol";
import "./interfaces/IConeRouter.sol";

contract RewardsDistributor is GovernableImplementation, ProxyImplementation {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public voterProxy;

    address public unkwnLockPool;

    address public unConeRewardsPoolAddress;

    address public unknownTeamAddress;

    address public treasuryAddress;

    uint256 public basis = 10000;

    uint256 public unkwnRate = 500;

    uint256 public unConeRate = 1000;

    uint256 public treasuryRate = 1200;

    uint256 public treasuryConeRate = 300;

    // For UNKWN/FTM & unCone/CONE LPs
    uint256 public ecosystemLPRate = 0;

    uint256 public unknownTeamRate = 800;

    uint256 public unknownTeamConeRate = 200;

    address[] public incentivizedPools;

    mapping(address => uint256) public incentivizedPoolWeights;

    uint256 incentivizedPoolWeightTotal;

    bool public partnersReceiveCvlUNKWN;

    address public unkwnLensAddress;

    mapping(address => bool) public operator;

    event OperatorStatus(address candidate, bool status);

    modifier onlyGovernanceOrOperator() {
        require(
            operator[msg.sender] ||
                msg.sender == governanceAddress() ||
                msg.sender == voterProxy,
            "Only the governance or operator may perform this action"
        );
        _;
    }

    struct StakerStreams {
        uint256 unkwnAmount;
        uint256 unConeAmount;
        uint256 treasuryAmount;
        uint256 LPAmount;
        uint256 partnerAmount;
        uint256 ecosystemLPAmount;
        uint256 unknownTeamAmount;
    }

    struct EcosystemLPWeights {
        address stakingAddress;
        uint256 weight;
    }

    address routerAddress;
    address native;

    /**
     * @notice Initialize proxy storage
     */
    function initializeProxyStorage(address _voterProxy)
        public
        checkProxyInitialized
    {
        voterProxy = _voterProxy;
        basis = 10000;

        unkwnRate = 500;

        unConeRate = 1000;

        treasuryRate = 1200;

        unknownTeamRate = 800;

        treasuryConeRate = 300;

        unknownTeamConeRate = 200;
    }

    // Don't need name change since the one in proxy takes different inputs
    function initialize(
        address _unkwnLockPool,
        address _unConeRewardsPoolAddress,
        address _unkwnLensAddress
    ) external onlyGovernance {
        require(unkwnLockPool == address(0), "Already initialized");

        unkwnLockPool = _unkwnLockPool;
        unConeRewardsPoolAddress = _unConeRewardsPoolAddress;

        unkwnLensAddress = _unkwnLensAddress;
    }

    function nativeInit(address _routerAddress, address _native)
        external
        onlyGovernance
    {
        routerAddress = _routerAddress;
        native = _native;
    }

    /* ========== Admin Actions ========== */

    function setOperator(address candidate, bool status)
        external
        onlyGovernance
    {
        operator[candidate] = status;
        emit OperatorStatus(candidate, status);
    }

    function setUnkwnLockPool(address _unkwnLockPool) external onlyGovernance {
        unkwnLockPool = _unkwnLockPool;
    }

    function setUnConeRewardsPool(address _unConeRewardsPoolAddress)
        external
        onlyGovernance
    {
        unConeRewardsPoolAddress = _unConeRewardsPoolAddress;
    }

    function setTreasuryRate(uint256 _treasuryRate) external onlyGovernance {
        treasuryRate = _treasuryRate;
    }

    function setTreasuryConeRate(uint256 _treasuryConeRate)
        external
        onlyGovernance
    {
        treasuryConeRate = _treasuryConeRate;
    }

    function setUnknownTeamRate(uint256 _unknownTeamRate)
        external
        onlyGovernance
    {
        unknownTeamRate = _unknownTeamRate;
    }

    function setUnknownTeamConeRate(uint256 _unknownTeamConeRate)
        external
        onlyGovernance
    {
        unknownTeamConeRate = _unknownTeamConeRate;
    }

    function setTreasuryAddress(address _treasuryAddress)
        external
        onlyGovernance
    {
        treasuryAddress = _treasuryAddress;
    }

    function setUnknownTeamAddress(address _unknownTeamAddress) external {
        if (unknownTeamAddress != address(0)) {
            require(msg.sender == unknownTeamAddress, "Only Unknown Team");
        } else {
            require(msg.sender == governanceAddress(), "Only Governance");
        }
        unknownTeamAddress = _unknownTeamAddress;
    }

    function setPartnersReceiveCvlUNKWN(bool _partnersReceiveCvlUNKWN)
        external
        onlyGovernance
    {
        partnersReceiveCvlUNKWN = _partnersReceiveCvlUNKWN;
    }

    function setEcosystemLPRewards(
        uint256 _ecosystemLPRate,
        address[] calldata _incentivizedPools,
        uint256[] calldata _incentivizedPoolWeights
    ) external onlyGovernance {
        require(
            _incentivizedPools.length == _incentivizedPoolWeights.length,
            "Different amounts of pools and weights"
        );
        ecosystemLPRate = _ecosystemLPRate;
        incentivizedPools = _incentivizedPools;
        uint256 _incentivizedPoolWeightTotal;
        for (uint256 i; i < _incentivizedPools.length; i++) {
            incentivizedPoolWeights[
                _incentivizedPools[i]
            ] = _incentivizedPoolWeights[i];
            _incentivizedPoolWeightTotal += _incentivizedPoolWeights[i];
        }
        incentivizedPoolWeightTotal = _incentivizedPoolWeightTotal;
    }

    /* ========== Staking Pool Actions ========== */

    function setRewardPoolOwner(address stakingAddress, address _owner)
        external
        onlyGovernance
    {
        IMultiRewards(stakingAddress).nominateNewOwner(_owner);
    }

    function addReward(
        address stakingAddress,
        address _rewardsToken,
        uint256 _rewardsDuration
    ) external onlyGovernanceOrOperator {
        IMultiRewards(stakingAddress).addReward(
            _rewardsToken,
            address(this),
            _rewardsDuration
        );
    }

    function notifyRewardAmount(
        address stakingAddress,
        address rewardTokenAddress,
        uint256 amount
    ) external onlyGovernanceOrOperator {
        if (amount == 0) {
            return;
        }
        address coneAddress = IUnkwnLens(unkwnLensAddress).coneAddress(); //gas savings on ssload

        StakerStreams memory rewardStreams; //to avoid stack too deep

        // All bribes and fees go to UnCONE stakers and partners who stake UnCONE if it's whitelisted in tokensAllowlist
        // stored in rewardsDistributor if not whitelist (just so we don't transfer weird tokens down the line)
        // this also handles CONE rebases that's passed here as UnCONE
        if (rewardTokenAddress != coneAddress) {
            if (
                IUnkwnLens(unkwnLensAddress)
                    .tokensAllowlist()
                    .tokenIsAllowedInPools(rewardTokenAddress)
            ) {
                (
                    rewardStreams.unConeAmount,
                    rewardStreams.partnerAmount
                ) = calculatePartnerSlice(amount);
                _notifyRewardAmount(
                    unConeRewardsPoolAddress,
                    rewardTokenAddress,
                    rewardStreams.unConeAmount
                );
                _notifyRewardAmount(
                    partnersRewardsPoolAddress(),
                    rewardTokenAddress,
                    rewardStreams.partnerAmount
                );
            }

            return;
        }

        // If it's CONE, distribute CONE at 10% to UnCONE stakers (and partners), 5% to UNKWN stakers, 3% to treasury and 2% to unknown team
        // x% to UNKWN/FTM & UnCONE/CONE LPs, and rest to LP (84%)
        address unConeAddress = IUnkwnLens(unkwnLensAddress).unConeAddress();
        address unkwnAddress = IUnkwnLens(unkwnLensAddress).unkwnAddress();
        IUnCone unCone = IUnCone(unConeAddress);

        rewardStreams.unkwnAmount = amount.mul(unkwnRate).div(basis); //5%
        rewardStreams.unConeAmount = amount.mul(unConeRate).div(basis); //10%
        rewardStreams.treasuryAmount = amount.mul(treasuryConeRate).div(basis); //3%
        rewardStreams.unknownTeamAmount = amount.mul(unknownTeamConeRate).div(
            basis
        ); //2%
        rewardStreams.ecosystemLPAmount = amount.mul(ecosystemLPRate).div(
            basis
        ); //x%

        rewardStreams.LPAmount = amount
            .sub(rewardStreams.unkwnAmount)
            .sub(rewardStreams.unConeAmount)
            .sub(rewardStreams.treasuryAmount)
            .sub(rewardStreams.unknownTeamAmount)
            .sub(rewardStreams.ecosystemLPAmount);

        // Distribute CONE claimed
        _notifyRewardAmountToNative(
            stakingAddress,
            coneAddress,
            rewardStreams.LPAmount
        );

        // Ecosystem LP and UnCONE stakers and Partners get CONE emission in UnCONE
        uint256 amountToLock = rewardStreams.ecosystemLPAmount.add(
            rewardStreams.unkwnAmount
        );
        IERC20(coneAddress).approve(voterProxy, amountToLock);
        IVoterProxy(voterProxy).lockCone(amountToLock);

        //distribute UnCONE to vlUNKWN
        _notifyRewardAmount(
            unkwnLockPool,
            unConeAddress,
            rewardStreams.unkwnAmount
        );

        // Distribute ecosystem LP amount in UnCONE according to set weights
        if (rewardStreams.ecosystemLPAmount > 0) {
            uint256 incentivizedPoolAmount;
            for (uint256 i; i < incentivizedPools.length; i++) {
                incentivizedPoolAmount = rewardStreams
                    .ecosystemLPAmount
                    .mul(basis)
                    .mul(incentivizedPoolWeights[incentivizedPools[i]])
                    .div(incentivizedPoolWeightTotal)
                    .div(basis);
                _notifyRewardAmount(
                    incentivizedPools[i],
                    unConeAddress,
                    incentivizedPoolAmount
                );
            }
        }

        _convertTokenToNativeAndTransfer(
            treasuryAddress,
            coneAddress,
            rewardStreams.treasuryAmount
        );

        _convertTokenToNativeAndTransfer(
            unknownTeamAddress,
            coneAddress,
            rewardStreams.unknownTeamAmount
        );

        // For UnCONE stakers, distribute CONE emission as CONE
        (
            rewardStreams.unConeAmount,
            rewardStreams.partnerAmount
        ) = calculatePartnerSlice(rewardStreams.unConeAmount);
        _notifyRewardAmount(
            unConeRewardsPoolAddress,
            coneAddress,
            rewardStreams.unConeAmount
        );
        _notifyRewardAmount(
            partnersRewardsPoolAddress(),
            coneAddress,
            rewardStreams.partnerAmount
        );

        // Mint UNKWN and distribute according to tokenomics
        // UnCONE lockers get UNKWN = minted * (UNKWNyst.totalSupply()/CONE.totalSupply())
        // this ensures UnCONE lockers are not diluted against other CONE stakers
        // and prevents the %UNKWN emission UnCONE stakers get isn't diluted below UnCONE/CONE.totalSupply()
        // partners get theirs with at a floor ratio of 2*UnCONE/CONE, until 25%, which reverts back to normal
        // UnCONE lockers altogether are guaranteed a 5% floor in emissions
        // partners get their UNKWN in locked form, this is acheived with vlUNKWN coupons (cvlUNKWN) since vlUNKWN itself isn't transferrable
        IUnkwn(unkwnAddress).mint(address(this), amount);

        rewardStreams.unknownTeamAmount = amount.mul(unknownTeamRate).div(
            basis
        );
        IERC20(unkwnAddress).safeTransfer(
            unknownTeamAddress,
            rewardStreams.unknownTeamAmount
        );

        rewardStreams.treasuryAmount = amount.mul(treasuryRate).div(basis);
        IERC20(unkwnAddress).safeTransfer(
            treasuryAddress,
            rewardStreams.treasuryAmount
        );

        amount = amount.sub(rewardStreams.unknownTeamAmount);
        amount = amount.sub(rewardStreams.treasuryAmount);
        {
            uint256 unConeRatioOfCONE = unCone.totalSupply().mul(1e18).div(
                IERC20(coneAddress).totalSupply()
            ); // basis is not precise enough here, using 1e18

            (
                uint256 nonpartnerRatioOfCONE,
                uint256 partnersRatioOfCONE
            ) = calculatePartnerSlice(unConeRatioOfCONE);
            partnersRatioOfCONE = partnersRatioOfCONE.mul(2); //partners get minted*(partner UnCONE/CONE)*2 as a floor until 25%
            if (partnersRatioOfCONE.mul(basis).div(1e18) > 2500) {
                partnersRatioOfCONE = (
                    partnersRatioOfCONE.div(2).sub(
                        (uint256(1250).mul(1e18)).div(basis)
                    )
                ).mul(7500).div(8750).add(uint256(2500).mul(1e18).div(basis)); // if above 25%, partnersRatioOfCONE = ((partner UnCONE/CONE supply) - 0.125) * 0.75/0.875 + 0.25
            } else if (
                // UnCONE stakers always get at least 5% of UNKWN emissions
                (nonpartnerRatioOfCONE.add(partnersRatioOfCONE)).mul(basis).div(
                    1e18
                ) < 500
            ) {
                nonpartnerRatioOfCONE = uint256(500).mul(1e18).div(basis).div(
                    3
                ); // Partners always have 2x weight against nonpartners if they're only getting 5% (5% < 25%)
                partnersRatioOfCONE = nonpartnerRatioOfCONE.mul(2);
            }

            rewardStreams.unConeAmount = amount.mul(nonpartnerRatioOfCONE).div(
                1e18
            );
            rewardStreams.partnerAmount = amount.mul(partnersRatioOfCONE).div(
                1e18
            );
        }

        _notifyRewardAmount(
            unConeRewardsPoolAddress,
            unkwnAddress,
            rewardStreams.unConeAmount
        );

        if (partnersReceiveCvlUNKWN) {
            // Mint cvlUNKWN and distribute to partnersRewardsPool
            address _cvlUnkwnAddress = cvlUnkwnAddress();
            IERC20(unkwnAddress).approve(
                _cvlUnkwnAddress,
                rewardStreams.partnerAmount
            );
            ICvlUnkwn(_cvlUnkwnAddress).mint(
                address(this),
                rewardStreams.partnerAmount
            );
            _notifyRewardAmount(
                partnersRewardsPoolAddress(),
                _cvlUnkwnAddress,
                rewardStreams.partnerAmount
            );
        } else {
            _notifyRewardAmount(
                partnersRewardsPoolAddress(),
                unkwnAddress,
                rewardStreams.partnerAmount
            );
        }

        rewardStreams.LPAmount = amount.sub(rewardStreams.unConeAmount).sub(
            rewardStreams.partnerAmount
        );
        _notifyRewardAmount(
            stakingAddress,
            unkwnAddress,
            rewardStreams.LPAmount
        );
    }

    /**
     * @notice To distribute stored bribed tokens that's newly whitelisted to UnCONE stakers and Partners
     * @param  rewardTokenAddress reward token address
     * @dev no auth needed since it only transfers whitelisted addresses
     */
    function notifyStoredRewardAmount(address rewardTokenAddress) external {
        require(
            IUnkwnLens(unkwnLensAddress)
                .tokensAllowlist()
                .tokenIsAllowedInPools(rewardTokenAddress),
            "Token is not allowed in reward pools"
        );
        // Get amount of rewards stored in this address
        uint256 amount = IERC20(rewardTokenAddress).balanceOf(address(this));

        StakerStreams memory rewardStreams;

        (
            rewardStreams.unConeAmount,
            rewardStreams.partnerAmount
        ) = calculatePartnerSlice(amount);

        _notifyRewardAmount(
            unConeRewardsPoolAddress,
            rewardTokenAddress,
            rewardStreams.unConeAmount
        );

        _notifyRewardAmount(
            partnersRewardsPoolAddress(),
            rewardTokenAddress,
            rewardStreams.partnerAmount
        );
    }

    function _notifyRewardAmount(
        address stakingAddress,
        address rewardToken,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        address rewardsDistributorAddress = IMultiRewards(stakingAddress)
            .rewardData(rewardToken)
            .rewardsDistributor;
        bool rewardExists = rewardsDistributorAddress != address(0);
        if (!rewardExists) {
            IMultiRewards(stakingAddress).addReward(
                rewardToken,
                address(this),
                604800 // 1 week
            );
        }

        IERC20(rewardToken).approve(stakingAddress, amount);
        IMultiRewards(stakingAddress).notifyRewardAmount(rewardToken, amount);
    }

    function _notifyRewardAmountToNative(
        address stakingAddress,
        address rewardToken,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        address coneAddress = IUnkwnLens(unkwnLensAddress).coneAddress();

        if (rewardToken == coneAddress) {
            IConeRouter01.Route[] memory path;
            path = new IConeRouter01.Route[](1);
            path[0].from = coneAddress;
            path[0].to = native;
            path[0].stable = false;
            IERC20(rewardToken).approve(routerAddress, amount);
            uint256[] memory minAmtArray = IConeRouter01(routerAddress)
                .getAmountsOut(amount, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            minAmt = minAmt.sub(minAmt.div(100));
            uint256[] memory nativeAmount = IConeRouter01(routerAddress)
                .swapExactTokensForTokens(
                    amount,
                    minAmt,
                    path,
                    address(this),
                    block.timestamp + 300
                );
            address rewardsDistributorAddress = IMultiRewards(stakingAddress)
                .rewardData(native)
                .rewardsDistributor;
            bool rewardExists = rewardsDistributorAddress != address(0);
            if (!rewardExists) {
                IMultiRewards(stakingAddress).addReward(
                    native,
                    address(this),
                    604800 // 1 week
                );
            }

            IERC20(native).approve(
                stakingAddress,
                nativeAmount[nativeAmount.length - 1]
            );
            IMultiRewards(stakingAddress).notifyRewardAmount(
                native,
                nativeAmount[nativeAmount.length - 1]
            );
        }
    }

    function _convertTokenToNativeAndTransfer(
        address recipient,
        address rewardToken,
        uint256 amount
    ) internal {
        if (amount == 0) {
            return;
        }
        address coneAddress = IUnkwnLens(unkwnLensAddress).coneAddress();

        if (rewardToken == coneAddress) {
            IConeRouter01.Route[] memory path;
            path = new IConeRouter01.Route[](1);
            path[0].from = coneAddress;
            path[0].to = native;
            path[0].stable = false;
            IERC20(rewardToken).approve(routerAddress, amount);
            uint256[] memory minAmtArray = IConeRouter01(routerAddress)
                .getAmountsOut(amount, path);
            uint256 minAmt = minAmtArray[minAmtArray.length - 1];
            minAmt = minAmt.sub(minAmt.div(100));
            minAmt = (minAmt * 99) / 100;
            uint256[] memory nativeAmount = IConeRouter01(routerAddress)
                .swapExactTokensForTokens(
                    amount,
                    0,
                    path,
                    recipient,
                    block.timestamp + 300
                );
        }
    }

    function setRewardsDuration(
        address stakingAddress,
        address _rewardsToken,
        uint256 _rewardsDuration
    ) external onlyGovernanceOrOperator {
        IMultiRewards(stakingAddress).setRewardsDuration(
            _rewardsToken,
            _rewardsDuration
        );
    }

    function harvestAndDistributeLPRewards(address[] calldata unkwnPools)
        external
        onlyGovernanceOrOperator
    {
        address gauge;
        address staking;

        for (uint256 i; i < unkwnPools.length; i++) {
            gauge = IUnkwnPool(unkwnPools[i]).gaugeAddress();
            staking = IUnkwnPool(unkwnPools[i]).stakingAddress();
            uint256 rewardsLength = IGauge(gauge).rewardTokensLength();
            address[] memory rewards = new address[](rewardsLength);

            for (uint256 j; j < rewardsLength; j++) {
                rewards[j] = IGauge(gauge).rewardTokens(j);
            }

            IVoterProxy(voterProxy).getRewardFromGauge(unkwnPools[i], rewards);
        }
    }

    /* ========== Token Recovery ========== */

    function recoverERC20FromStaking(
        address stakingAddress,
        address tokenAddress
    ) external onlyGovernanceOrOperator {
        uint256 amount = IERC20(tokenAddress).balanceOf(stakingAddress);
        IMultiRewards(stakingAddress).recoverERC20(tokenAddress, amount);
        recoverERC20(tokenAddress);
    }

    function recoverERC20(address tokenAddress)
        public
        onlyGovernanceOrOperator
    {
        uint256 amount = IERC20(tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).safeTransfer(msg.sender, amount);
    }

    /* ========== Helper View Functions ========== */

    function unkwnLens() internal view returns (IUnkwnLens) {
        return IUnkwnLens(unkwnLensAddress);
    }

    function partnersRewardsPoolAddress() internal view returns (address) {
        return unkwnLens().partnersRewardsPoolAddress();
    }

    function cvlUnkwnAddress() internal view returns (address) {
        return unkwnLens().cvlUnkwnAddress();
    }

    function calculatePartnerSlice(uint256 amount)
        internal
        view
        returns (uint256 unConeAmount, uint256 partnerAmount)
    {
        uint256 stakedSunCone = IMultiRewards(unConeRewardsPoolAddress)
            .totalSupply();
        uint256 stakedPunCone = IMultiRewards(partnersRewardsPoolAddress())
            .totalSupply();

        uint256 totalStakedUnCone = stakedSunCone.add(stakedPunCone);
        totalStakedUnCone = (totalStakedUnCone != 0 ? totalStakedUnCone : 1); //no divide by 0

        unConeAmount = amount
            .mul(basis)
            .mul(stakedSunCone)
            .div(totalStakedUnCone)
            .div(basis);

        partnerAmount = amount - unConeAmount;
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
pragma solidity 0.8.11||0.6.12;

/**
 * @title Implementation meant to be used with a proxy
 * @author Unknown
 */
contract ProxyImplementation {
    bool public proxyStorageInitialized;

    /**
     * @notice Nothing in constructor, since it only affects the logic address, not the storage address
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {}

    /**
     * @notice Only allow proxy's storage to be initialized once
     */
    modifier checkProxyInitialized() {
        require(
            !proxyStorageInitialized,
            "Can only initialize proxy storage once"
        );
        proxyStorageInitialized = true;
        _;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;

/**
 * @title Ownable contract which allows governance to be killed, adapted to be used under a proxy
 * @author Unknown
 */
contract GovernableImplementation {
    address internal doNotUseThisSlot; // used to be governanceAddress, but there's a hash collision with the proxy's governanceAddress
    bool public governanceIsKilled;

    /**
     * @notice legacy
     * @dev public visibility so it compiles for 0.6.12
     */
    constructor() public {
        doNotUseThisSlot = msg.sender;
    }

    /**
     * @notice Only allow governance to perform certain actions
     */
    modifier onlyGovernance() {
        require(msg.sender == governanceAddress(), "Only governance");
        _;
    }

    /**
     * @notice Set governance address
     * @param _governanceAddress The address of new governance
     */
    function setGovernanceAddress(address _governanceAddress)
        public
        onlyGovernance
    {
        require(msg.sender == governanceAddress(), "Only governance");
        assembly {
            sstore(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103,
                _governanceAddress
            ) // keccak256('eip1967.proxy.admin')
        }
    }

    /**
     * @notice Allow governance to be killed
     */
    function killGovernance() external onlyGovernance {
        setGovernanceAddress(address(0));
        governanceIsKilled = true;
    }

    /**
     * @notice Fetch current governance address
     * @return _governanceAddress Returns current governance address
     * @dev directing to the slot that the proxy would use
     */
    function governanceAddress()
        public
        view
        returns (address _governanceAddress)
    {
        assembly {
            _governanceAddress := sload(
                0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103
            ) // keccak256('eip1967.proxy.admin')
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./IConeLens.sol";

interface IUnkwnPool {
    function stakingAddress() external view returns (address);

    function conePoolAddress() external view returns (address);

    function conePoolInfo() external view returns (IConeLens.Pool memory);

    function depositLpAndStake(uint256) external;

    function depositLp(uint256) external;

    function withdrawLp(uint256) external;

    function syncBribeTokens() external;

    function notifyBribeOrFees() external;

    function initialize(
        address,
        address,
        address,
        string memory,
        string memory,
        address,
        address
    ) external;

    function gaugeAddress() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function totalSupply() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVoterProxy {
    function depositInGauge(address, uint256) external;

    function withdrawFromGauge(address, uint256) external;

    function getRewardFromGauge(address _conePool, address[] memory _tokens)
        external;

    function depositNft(uint256) external;

    function veAddress() external returns (address);

    function veDistAddress() external returns (address);

    function lockCone(uint256 amount) external;

    function primaryTokenId() external view returns (uint256);

    function vote(address[] memory, int256[] memory) external;

    function votingSnapshotAddress() external view returns (address);

    function coneInflationSinceInception() external view returns (uint256);

    function getRewardFromBribe(
        address conePoolAddress,
        address[] memory _tokensAddresses
    ) external returns (bool allClaimed, bool[] memory claimed);

    function getFeeTokensFromBribe(address conePoolAddress)
        external
        returns (bool allClaimed);

    function claimCone(address conePoolAddress)
        external
        returns (bool _claimCone);

    function setVoterProxyAssetsAddress(address _voterProxyAssetsAddress)
        external;

    function detachNFT(uint256 startingIndex, uint256 range) external;

    function claim() external;

    function whitelist(address tokenAddress) external;

    function whitelistingFee() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IUnkwnPoolFactory {
    function unkwnPoolsLength() external view returns (uint256);

    function isUnkwnPool(address) external view returns (bool);

    function isUnkwnPoolOrLegacyUnkwnPool(address) external view returns (bool);

    function UNKWN() external view returns (address);

    function syncPools(uint256) external;

    function unkwnPools(uint256) external view returns (address);

    function unkwnPoolByConePool(address) external view returns (address);

    function vlUnkwnAddress() external view returns (address);

    function conePoolByUnkwnPool(address) external view returns (address);

    function syncedPoolsLength() external returns (uint256);

    function coneLensAddress() external view returns (address);

    function voterProxyAddress() external view returns (address);

    function rewardsDistributorAddress() external view returns (address);

    function tokensAllowlist() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "./IUnkwn.sol";
import "./IVlUnkwn.sol";
import "./IUnkwnPoolFactory.sol";
import "./IUnCone.sol";
import "./ICone.sol";
import "./IConeLens.sol";
import "./IUserProxy.sol";
import "./IVe.sol";
import "./IVotingSnapshot.sol";
import "./IVoterProxy.sol";
import "./IUnkwnV1Rewards.sol";
import "./ITokensAllowlist.sol";

interface IUnkwnLens {
    struct ProtocolAddresses {
        address unkwnPoolFactoryAddress;
        address ConeLensAddress;
        address UnkwnAddress;
        address vlUnkwnAddress;
        address unConeAddress;
        address voterProxyAddress;
        address coneAddress;
        address voterAddress;
        address poolsFactoryAddress;
        address gaugesFactoryAddress;
        address minterAddress;
        address veAddress;
        address userProxyInterfaceAddress;
        address votingSnapshotAddress;
    }

    struct UserPosition {
        address userProxyAddress;
        uint256 veTotalBalanceOf;
        IConeLens.PositionVe[] vePositions;
        IConeLens.PositionPool[] poolsPositions;
        IUserProxy.PositionStakingPool[] stakingPools;
        uint256 unConeanceOf;
        uint256 unkwnBalanceOf;
        uint256 coneBalanceOf;
        uint256 vlUnkwnBalanceOf;
    }

    struct TokenMetadata {
        address id;
        string name;
        string symbol;
        uint8 decimals;
        uint256 priceUsdc;
    }

    struct UnkwnPoolData {
        address id;
        address stakingAddress;
        uint256 stakedTotalSupply;
        uint256 totalSupply;
        IConeLens.Pool poolData;
    }

    struct Pool {
        address id;
        string symbol;
        bool stable;
        address token0Address;
        address token1Address;
        address gaugeAddress;
        address bribeAddress;
        address[] bribeTokensAddresses;
        address fees;
    }

    struct RewardTokenData {
        address id;
        uint256 rewardRate;
        uint256 periodFinish;
    }

    /* ========== PUBLIC VARS ========== */

    function unkwnPoolFactoryAddress() external view returns (address);

    function rewardsDistributorAddress() external view returns (address);

    function userProxyFactoryAddress() external view returns (address);

    function coneLensAddress() external view returns (address);

    function unkwnAddress() external view returns (address);

    function vlUnkwnAddress() external view returns (address);

    function unConeAddress() external view returns (address);

    function voterProxyAddress() external view returns (address);

    function veAddress() external view returns (address);

    function coneAddress() external view returns (address);

    function unConeRewardsPoolAddress() external view returns (address);

    function partnersRewardsPoolAddress() external view returns (address);

    function treasuryAddress() external view returns (address);

    function cvlUnkwnAddress() external view returns (address);

    function unkwnV1RewardsAddress() external view returns (address);

    function unkwnV1RedeemAddress() external view returns (address);

    function unkwnV1Address() external view returns (address);

    function tokensAllowlistAddress() external view returns (address);

    /* ========== PUBLIC VIEW FUNCTIONS ========== */

    function voterAddress() external view returns (address);

    function poolsFactoryAddress() external view returns (address);

    function gaugesFactoryAddress() external view returns (address);

    function minterAddress() external view returns (address);

    function protocolAddresses()
        external
        view
        returns (ProtocolAddresses memory);

    function positionsOf(address accountAddress)
        external
        view
        returns (UserPosition memory);

    function rewardTokensPositionsOf(address, address)
        external
        view
        returns (IUserProxy.RewardToken[] memory);

    function veTotalBalanceOf(IConeLens.PositionVe[] memory positions)
        external
        pure
        returns (uint256);

    function unkwnPoolsLength() external view returns (uint256);

    function userProxiesLength() external view returns (uint256);

    function userProxyByAccount(address accountAddress)
        external
        view
        returns (address);

    function userProxyByIndex(uint256 index) external view returns (address);

    function gaugeByConePool(address) external view returns (address);

    function conePoolByUnkwnPool(address unkwnPoolAddress)
        external
        view
        returns (address);

    function unkwnPoolByConePool(address conePoolAddress)
        external
        view
        returns (address);

    function stakingRewardsByConePool(address conePoolAddress)
        external
        view
        returns (address);

    function stakingRewardsByUnkwnPool(address conePoolAddress)
        external
        view
        returns (address);

    function isUnkwnPool(address unkwnPoolAddress) external view returns (bool);

    function unkwnPoolsAddresses() external view returns (address[] memory);

    function unkwnPoolData(address unkwnPoolAddress)
        external
        view
        returns (UnkwnPoolData memory);

    function unkwnPoolsData(address[] memory _unkwnPoolsAddresses)
        external
        view
        returns (UnkwnPoolData[] memory);

    function unkwnPoolsData() external view returns (UnkwnPoolData[] memory);

    function unCone() external view returns (IUnCone);

    function unkwn() external view returns (IUnkwn);

    function vlUnkwn() external view returns (IVlUnkwn);

    function unkwnPoolFactory() external view returns (IUnkwnPoolFactory);

    function cone() external view returns (ICone);

    function ve() external view returns (IVe);

    function voterProxy() external view returns (IVoterProxy);

    function votingSnapshot() external view returns (IVotingSnapshot);

    function tokensAllowlist() external view returns (ITokensAllowlist);

    function isPartner(address userProxyAddress) external view returns (bool);

    function stakedUnConeBalanceOf(address accountAddress)
        external
        view
        returns (uint256 stakedBalance);

    function coneInflationSinceInception() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUnCone is IERC20 {
    function mint(address, uint256) external;

    function convertNftToUnCone(uint256) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IMultiRewards {
    struct Reward {
        address rewardsDistributor;
        uint256 rewardsDuration;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerTokenStored;
    }

    function stake(uint256) external;

    function withdraw(uint256) external;

    function getReward() external;

    function stakingToken() external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function earned(address, address) external view returns (uint256);

    function initialize(address, address) external;

    function rewardRate(address) external view returns (uint256);

    function getRewardForDuration(address) external view returns (uint256);

    function rewardPerToken(address) external view returns (uint256);

    function rewardData(address) external view returns (Reward memory);

    function rewardTokensLength() external view returns (uint256);

    function rewardTokens(uint256) external view returns (address);

    function totalSupply() external view returns (uint256);

    function addReward(
        address _rewardsToken,
        address _rewardsDistributor,
        uint256 _rewardsDuration
    ) external;

    function notifyRewardAmount(address, uint256) external;

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

    function setRewardsDuration(address _rewardsToken, uint256 _rewardsDuration)
        external;

    function exit() external;

    function nominateNewOwner(address _owner) external;

    function acceptOwnership() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IUnkwnLens.sol";

interface ICvlUnkwn is IERC20 {
    function minterAddress() external view returns (address);

    function unkwnLens() external view returns (IUnkwnLens);

    function whitelist(address) external view returns (bool);

    function setMinter(address _minterAddress) external;

    function mint(address to, uint256 amount) external;

    function redeem() external;

    function redeem(uint256 amount) external;

    function redeem(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IGauge {
    function rewardTokens(uint256) external returns (address);

    function rewardTokensLength() external view returns (uint256);

    function earned(address, address) external view returns (uint256);

    function getReward(address account, address[] memory tokens) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUnkwn is IERC20 {
    function mint(address to, uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IConeRouter01 {
    struct Route {
        address from;
        address to;
        bool stable;
    }

    function UNSAFE_swapExactTokensForTokens(
        uint256[] memory amounts,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory);

    function addLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
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

    function addLiquidityMATIC(
        address token,
        bool stable,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountMATICMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountMATIC,
            uint256 liquidity
        );

    function factory() external view returns (address);

    function getAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amount, bool stable);

    function getAmountsOut(uint256 amountIn, Route[] memory routes)
        external
        view
        returns (uint256[] memory amounts);

    function getExactAmountOut(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        bool stable
    ) external view returns (uint256);

    function getReserves(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (uint256 reserveA, uint256 reserveB);

    function isPair(address pair) external view returns (bool);

    function pairFor(
        address tokenA,
        address tokenB,
        bool stable
    ) external view returns (address pair);

    function quoteAddLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 amountADesired,
        uint256 amountBDesired
    )
        external
        view
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function quoteLiquidity(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function quoteRemoveLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity
    ) external view returns (uint256 amountA, uint256 amountB);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        bool stable,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityMATIC(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountMATICMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountMATIC);

    function removeLiquidityMATICSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountFTMMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountFTM);

    function removeLiquidityMATICWithPermit(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountMATICMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountMATIC);

    function removeLiquidityMATICWithPermitSupportingFeeOnTransferTokens(
        address token,
        bool stable,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountFTMMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountFTM);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        bool stable,
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

    function sortTokens(address tokenA, address tokenB)
        external
        pure
        returns (address token0, address token1);

    function swapExactMATICForTokens(
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapExactMATICForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForMATIC(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForMATICSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external;

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSimple(
        uint256 amountIn,
        uint256 amountOutMin,
        address tokenFrom,
        address tokenTo,
        bool stable,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] memory routes,
        address to,
        uint256 deadline
    ) external;

    function wmatic() external view returns (address);
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
pragma solidity 0.8.11;

interface IConeLens {
    struct Pool {
        address id;
        string symbol;
        bool stable;
        address token0Address;
        address token1Address;
        address gaugeAddress;
        address bribeAddress;
        address[] bribeTokensAddresses;
        address fees;
        uint256 totalSupply;
    }

    struct PoolReserveData {
        address id;
        address token0Address;
        address token1Address;
        uint256 token0Reserve;
        uint256 token1Reserve;
        uint8 token0Decimals;
        uint8 token1Decimals;
    }

    struct PositionVe {
        uint256 tokenId;
        uint256 balanceOf;
        uint256 locked;
    }

    struct PositionBribesByTokenId {
        uint256 tokenId;
        PositionBribe[] bribes;
    }

    struct PositionBribe {
        address bribeTokenAddress;
        uint256 earned;
    }

    struct PositionPool {
        address id;
        uint256 balanceOf;
    }

    function poolsLength() external view returns (uint256);

    function voterAddress() external view returns (address);

    function veAddress() external view returns (address);

    function poolsFactoryAddress() external view returns (address);

    function gaugesFactoryAddress() external view returns (address);

    function minterAddress() external view returns (address);

    function coneAddress() external view returns (address);

    function vePositionsOf(address) external view returns (PositionVe[] memory);

    function bribeAddresByPoolAddress(address) external view returns (address);

    function gaugeAddressByPoolAddress(address) external view returns (address);

    function poolsPositionsOf(address)
        external
        view
        returns (PositionPool[] memory);

    function poolsPositionsOf(
        address,
        uint256,
        uint256
    ) external view returns (PositionPool[] memory);

    function poolInfo(address) external view returns (Pool memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVlUnkwn {
    struct LocksData {
        uint256 total;
        uint256 unlockable;
        uint256 locked;
        LockedBalance[] locks;
    }

    struct LockedBalance {
        uint112 amount;
        uint112 boosted;
        uint32 unlockTime;
    }

    struct EarnedData {
        address token;
        uint256 amount;
    }

    struct Reward {
        bool useBoost;
        uint40 periodFinish;
        uint208 rewardRate;
        uint40 lastUpdateTime;
        uint208 rewardPerTokenStored;
        address rewardsDistributor;
    }

    function lock(
        address _account,
        uint256 _amount,
        uint256 _spendRatio
    ) external;

    function processExpiredLocks(
        bool _relock,
        uint256 _spendRatio,
        address _withdrawTo
    ) external;

    function lockedBalanceOf(address) external view returns (uint256 amount);

    function lockedBalances(address)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            LockedBalance[] memory
        );

    function claimableRewards(address _account)
        external
        view
        returns (EarnedData[] memory userRewards);

    function rewardTokensLength() external view returns (uint256);

    function rewardTokens(uint256) external view returns (address);

    function rewardData(address) external view returns (Reward memory);

    function rewardPerToken(address) external view returns (uint256);

    function getRewardForDuration(address) external view returns (uint256);

    function getReward() external;

    function checkpointEpoch() external;

    function updateRewards() external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ICone {
    function transferFrom(
        address,
        address,
        uint256
    ) external;

    function allowance(address, address) external view returns (uint256);

    function approve(address, uint256) external;

    function balanceOf(address) external view returns (uint256);

    function router() external view returns (address);

    function minter() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IUserProxy {
    struct PositionStakingPool {
        address stakingPoolAddress;
        address unkwnPoolAddress;
        address conePoolAddress;
        uint256 balanceOf;
        RewardToken[] rewardTokens;
    }

    function initialize(
        address,
        address,
        address,
        address[] memory
    ) external;

    struct RewardToken {
        address rewardTokenAddress;
        uint256 rewardRate;
        uint256 rewardPerToken;
        uint256 getRewardForDuration;
        uint256 earned;
    }

    struct Vote {
        address poolAddress;
        int256 weight;
    }

    function convertNftToUnCone(uint256) external;

    function convertConeToUnCone(uint256) external;

    function depositLpAndStake(address, uint256) external;

    function depositLp(address, uint256) external;

    function stakingAddresses() external view returns (address[] memory);

    function initialize(address, address) external;

    function stakingPoolsLength() external view returns (uint256);

    function unstakeLpAndWithdraw(
        address,
        uint256,
        bool
    ) external;

    function unstakeLpAndWithdraw(address, uint256) external;

    function unstakeLpWithdrawAndClaim(address) external;

    function unstakeLpWithdrawAndClaim(address, uint256) external;

    function withdrawLp(address, uint256) external;

    function stakeUnkwnLp(address, uint256) external;

    function unstakeUnkwnLp(address, uint256) external;

    function ownerAddress() external view returns (address);

    function stakingPoolsPositions()
        external
        view
        returns (PositionStakingPool[] memory);

    function stakeUnCone(uint256) external;

    function unstakeUnCone(uint256) external;

    function unstakeUnCone(address, uint256) external;

    function convertConeToUnConeAndStake(uint256) external;

    function convertNftToUnConeAndStake(uint256) external;

    function claimUnConeStakingRewards() external;

    function claimPartnerStakingRewards() external;

    function claimStakingRewards(address) external;

    function claimStakingRewards(address[] memory) external;

    function claimStakingRewards() external;

    function claimVlUnkwnRewards() external;

    function depositUnkwn(uint256, uint256) external;

    function withdrawUnkwn(bool, uint256) external;

    function voteLockUnkwn(uint256, uint256) external;

    function withdrawVoteLockedUnkwn(uint256, bool) external;

    function relockVoteLockedUnkwn(uint256) external;

    function removeVote(address) external;

    function registerStake(address) external;

    function registerUnstake(address) external;

    function resetVotes() external;

    function setVoteDelegate(address) external;

    function clearVoteDelegate() external;

    function vote(address, int256) external;

    function vote(Vote[] memory) external;

    function votesByAccount(address) external view returns (Vote[] memory);

    function migrateUnConeToPartner() external;

    function stakeUnConeInUnkwnV1(uint256) external;

    function unstakeUnConeInUnkwnV1(uint256) external;

    function redeemUnkwnV1(uint256) external;

    function redeemAndStakeUnkwnV1(uint256) external;

    function whitelist(address) external;

    function implementationsAddresses()
        external
        view
        returns (address[] memory);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface IVe {
    function safeTransferFrom(
        address,
        address,
        uint256
    ) external;

    function ownerOf(uint256) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function balanceOfNFT(uint256) external view returns (uint256);

    function balanceOfNFTAt(uint256, uint256) external view returns (uint256);

    function balanceOfAtNFT(uint256, uint256) external view returns (uint256);

    function locked(uint256) external view returns (uint256);

    function createLock(uint256, uint256) external returns (uint256);

    function approve(address, uint256) external;

    function merge(uint256, uint256) external;

    function token() external view returns (address);

    function controller() external view returns (address);

    function voted(uint256) external view returns (bool);

    function tokenOfOwnerByIndex(address, uint256)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11||0.6.12;
pragma experimental ABIEncoderV2;

interface IVotingSnapshot {
    struct Vote {
        address poolAddress;
        int256 weight;
    }

    function vote(address, int256) external;

    function vote(Vote[] memory) external;

    function removeVote(address) external;

    function resetVotes() external;

    function resetVotes(address) external;

    function setVoteDelegate(address) external;

    function clearVoteDelegate() external;

    function voteDelegateByAccount(address) external view returns (address);

    function votesByAccount(address) external view returns (Vote[] memory);

    function voteWeightTotalByAccount(address) external view returns (uint256);

    function voteWeightUsedByAccount(address) external view returns (uint256);

    function voteWeightAvailableByAccount(address)
        external
        view
        returns (uint256);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./IMultiRewards.sol";

interface IUnkwnV1Rewards is IMultiRewards {
    function stakingCap(address account) external view returns (uint256 cap);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

interface ITokensAllowlist {
    function tokenIsAllowed(address) external view returns (bool);

    function bribeTokensSyncPageSize() external view returns (uint256);

    function bribeTokensNotifyPageSize() external view returns (uint256);

    function bribeSyncLagLimit() external view returns (uint256);

    function notifyFrequency()
        external
        view
        returns (uint256 bribeFrequency, uint256 feeFrequency);

    function feeClaimingDisabled(address) external view returns (bool);

    function periodBetweenClaimCone() external view returns (uint256);

    function periodBetweenClaimFee() external view returns (uint256);

    function periodBetweenClaimBribe() external view returns (uint256);

    function tokenIsAllowedInPools(address) external view returns (bool);

    function setTokenIsAllowedInPools(
        address[] memory tokensAddresses,
        bool allowed
    ) external;

    function oogLoopLimit() external view returns (uint256);

    function notifyConeThreshold() external view returns (uint256);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC20/ERC20.sol)

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
        _approve(owner, spender, allowance(owner, spender) + addedValue);
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
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
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
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
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