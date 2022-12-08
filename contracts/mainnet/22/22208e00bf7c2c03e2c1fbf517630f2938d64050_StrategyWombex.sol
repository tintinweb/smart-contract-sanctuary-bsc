// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/Context.sol

pragma solidity ^0.8.0;

import "../ERC20.sol";
import "../SafeERC20.sol";
import "../SafeMath.sol";

import "../IUniswapRouterETH.sol";
import "../IUniswapV2Pair.sol";
import "../IMasterChef.sol";
import "../IWombex.sol";
import "../StratManager.sol";
import "../FeeManager.sol";
import "../StringUtils.sol";

contract StrategyWombex is StratManager, FeeManager {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct Routes {
        address[] output1ToNativeRoute;
        address[] output2ToNativeRoute;
        address[] output1ToWantRoute;
        address[] output2ToWantRoute;
    }

    // Tokens used
    address public native;
    address public output1;
    address public output2;
    address public want;
    address public underlyingAsset;
    address public sUnderlyingAsset;

    // Third party contracts
    address public chef;
    address public womChef;
    address public booster;

    bool public harvestOnDeposit;
    uint256 public lastHarvest;
    string public pendingRewardsFunctionName;
    uint256 public blocksPerYear;

    // Routes
    address[] public output1ToNativeRoute;
    address[] public output2ToNativeRoute;
    address[] public output1ToWantRoute;
    address[] public output2ToWantRoute;

    event StratHarvest(address indexed harvester, uint256 wantHarvested, uint256 tvl);
    event Deposit(uint256 tvl);
    event Withdraw(uint256 tvl);
    event ChargedFees(uint256 callFees, uint256 protocolFees, uint256 holdersFees);

    constructor(
        address _want,
        address _underlying,
        address _sUnderlying,
        address _chef,
        address _womChef,
        address _vault,
        address _unirouter,
        address _keeper,
        Routes memory _routes,
        uint256 _blocksPerYear
    ) StratManager(_keeper, _keeper, _unirouter, _vault, _keeper) {
        want = _want;
        underlyingAsset = _underlying;
        sUnderlyingAsset = _sUnderlying;
        chef = _chef;
        booster = IWombexMasterChef(chef).booster();        
        womChef = _womChef;
        blocksPerYear = _blocksPerYear;

        output1 = _routes.output1ToNativeRoute[0];
        output2 = _routes.output2ToNativeRoute[0];
        native = _routes.output1ToNativeRoute[_routes.output1ToNativeRoute.length - 1];
        output1ToNativeRoute = _routes.output1ToNativeRoute;
        output2ToNativeRoute = _routes.output2ToNativeRoute;

        // setup lp routing
        require(_routes.output1ToWantRoute[0] == output1, "output1ToWantRoute[0] != output1");
        require(_routes.output1ToWantRoute[_routes.output1ToWantRoute.length - 1] == want, "output1ToWantRoute[last] != want");
        output1ToWantRoute = _routes.output1ToWantRoute;

        require(_routes.output2ToWantRoute[0] == output2, "output2ToWantRoute[0] != output2");
        require(_routes.output2ToWantRoute[_routes.output2ToWantRoute.length - 1] == want, "output2ToWantRoute[last] != want");
        output2ToWantRoute = _routes.output2ToWantRoute;
        
        _giveAllowances();
    }

    // Calculate Performance for this strategy in NativeToken
    function strategyPerformance(uint256 toDeposit) public view returns (uint256) {
        IWombexClaim rewardsInfos = IWombexClaim(sUnderlyingAsset);
        uint256 rTotalSupply = rewardsInfos.totalSupply();
        (,, uint256 rRewardRate,,,,,,) = rewardsInfos.tokenRewards(output2);

        uint256 womRewards = rRewardRate.mul(31536000); // rewardRate * secondsPerYear
        uint256 wmxRewards = getMintedWmxAmount(womRewards);

        uint256 yearlyWom = womRewards.mul(balanceOfPool().add(toDeposit)).div(rTotalSupply);
        uint256[] memory amountOutWom = IUniswapRouterETH(unirouter).getAmountsOut(yearlyWom, output2ToNativeRoute);
        uint256 yearlyWmx = wmxRewards.mul(balanceOfPool().add(toDeposit)).div(rTotalSupply);
        uint256[] memory amountOutWmx = IUniswapRouterETH(unirouter).getAmountsOut(yearlyWmx, output1ToNativeRoute);
        return (amountOutWom[amountOutWom.length -1] + amountOutWmx[amountOutWmx.length -1]);
    }

    // puts the funds to work
    function deposit() public whenNotPaused {
        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal > 0) {
            // Deposit to WomChef for LPs
            IWombatMasterChef(womChef).deposit(want, wantBal, 0, address(this), block.timestamp, false);
            uint256 underlyingBal = IERC20(underlyingAsset).balanceOf(address(this));
            if(underlyingBal > wantBal){ // Processing Coverage Ratio
                IERC20(underlyingAsset).safeTransfer(ProtocolFeeRecipient, (underlyingBal - wantBal) / 2);
            }
            IWombexBooster(booster).deposit(IWombexMasterChef(chef).lpTokenToPid(underlyingAsset), IERC20(underlyingAsset).balanceOf(address(this)), true);
            emit Deposit(balanceOf());
        }
    }

    function withdraw(uint256 _amount) external {
        require(msg.sender == vault, "!vault");

        uint256 wantBal = IERC20(want).balanceOf(address(this));

        if (wantBal < _amount) {
            IWombexMasterChef(chef).withdraw(underlyingAsset, _amount.sub(wantBal), 0, address(this));
            wantBal = IERC20(want).balanceOf(address(this));
        }

        if (wantBal > _amount) {
            wantBal = _amount;
        }

        IERC20(want).safeTransfer(vault, wantBal);

        emit Withdraw(balanceOf());
    }

    function harvest(address callFeeRecipient) external virtual {
        require(msg.sender == vault, "!vault");
        _harvest(callFeeRecipient);
    }

    // compounds earnings and charges performance fee
    function _harvest(address callFeeRecipient) internal whenNotPaused {
        IWombexClaim(sUnderlyingAsset).getReward(address(this), false);
        uint256 output1Bal = IERC20(output1).balanceOf(address(this));
        uint256 output2Bal = IERC20(output2).balanceOf(address(this));
        if (output1Bal > 0 || output2Bal > 0) {
            chargeFees(callFeeRecipient);
            addLiquidity();
            uint256 wantHarvested = balanceOfWant();
            deposit();

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, wantHarvested, balanceOf());
        }
    }

    // performance fees
    function chargeFees(address callFeeRecipient) internal {
        uint256 toNative1 = IERC20(output1).balanceOf(address(this)).mul(VAULT_FEE).div(DENOMINATOR_FEE);
        uint256 toNative2 = IERC20(output2).balanceOf(address(this)).mul(VAULT_FEE).div(DENOMINATOR_FEE);
        if(toNative1 > 0) {
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(toNative1, 0, output1ToNativeRoute, address(this), block.timestamp);
        }
        if(toNative2 > 0) {
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(toNative2, 0, output2ToNativeRoute, address(this), block.timestamp);
        }

        uint256 nativeBal = IERC20(native).balanceOf(address(this));

        uint256 callFeeAmount = nativeBal.mul(CALL_FEE).div(DENOMINATOR_FEE);
        IERC20(native).safeTransfer(callFeeRecipient, callFeeAmount);

        uint256 protocolFeeAmount = nativeBal.mul(PROTOCOL_FEE).div(DENOMINATOR_FEE);
        IERC20(native).safeTransfer(ProtocolFeeRecipient, protocolFeeAmount);
        uint256 holdersFeeAmount = IERC20(native).balanceOf(address(this));
        IERC20(native).safeTransfer(HoldersFeeRecipient, holdersFeeAmount);

        emit ChargedFees(callFeeAmount, protocolFeeAmount, holdersFeeAmount);
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        uint256 output1Harvest = IERC20(output1).balanceOf(address(this));
        uint256 output2Harvest = IERC20(output2).balanceOf(address(this));

        if (output1Harvest > 0) {
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(output1Harvest, 0, output1ToWantRoute, address(this), block.timestamp);
        }

        if (output2Harvest > 0) {
            IUniswapRouterETH(unirouter).swapExactTokensForTokens(output2Harvest, 0, output2ToWantRoute, address(this), block.timestamp);
        }
    }

    // calculate the total underlaying 'want' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfWant().add(balanceOfPool());
    }

    // it calculates how much 'want' this contract holds.
    function balanceOfWant() public view returns (uint256) {
        return IERC20(want).balanceOf(address(this));
    }

    // it calculates how much 'want' the strategy has working in the farm.
    function balanceOfPool() public view returns (uint256) {
        return IERC20(sUnderlyingAsset).balanceOf(address(this));
    }

    // returns rewards unharvested
    function rewardsAvailable() public view returns (uint256, uint256) {
        uint256 unharvestedBal2 = 0;
        // Check unharvested WOM Rewards
        (address[] memory tokens, uint256[] memory amounts) = IWombexClaim(sUnderlyingAsset).claimableRewards(address(this));
        for (uint256 i = 0; i < tokens.length; i++) {
            if(address(tokens[i]) == address(output2)) { 
                unharvestedBal2 = amounts[i];
            }
        }

        return (getMintedWmxAmount(unharvestedBal2), unharvestedBal2);
    }

    function getMintedWmxAmount(uint256 womRewards) public view returns (uint256) {
        uint256 cliff = IERC20(output1).totalSupply().sub(50000000000000000000000000).div(100000000000000000000000);
        uint256 totalCliffs = 500;
        uint256 reduction = totalCliffs.sub(cliff).mul(5).div(2).add(2);
        uint256 rAmount = womRewards.mul(reduction).div(totalCliffs);
        return rAmount.mul(IWombexWMXClaim(booster).mintRatio()).div(10000);
    }

    // native reward amount for calling harvest
    function callReward() public view returns (uint256) {
        (uint256 outputBal1, uint256 outputBal2) = rewardsAvailable();
        uint256 nativeOut = 0;
        
        if (outputBal1 > 0) {
            uint256[] memory amountOut = IUniswapRouterETH(unirouter).getAmountsOut(outputBal1, output1ToNativeRoute);
            nativeOut += amountOut[amountOut.length -1];
        }

        if (outputBal2 > 0) {
            uint256[] memory amountOut = IUniswapRouterETH(unirouter).getAmountsOut(outputBal2, output2ToNativeRoute);
            nativeOut += amountOut[amountOut.length -1];
        }

        return nativeOut.mul(VAULT_FEE).div(DENOMINATOR_FEE).mul(CALL_FEE).div(DENOMINATOR_FEE);
    }

    function setHarvestOnDeposit(bool _harvestOnDeposit) external onlyManager {
        harvestOnDeposit = _harvestOnDeposit;
    }

    function setMasterChef(address _masterChef) external onlyManager {
        chef = _masterChef;
        booster = IWombexMasterChef(chef).booster();
        _giveAllowances();
    }

    function setWombatMasterChef(address _masterChef) external onlyManager {
        womChef = _masterChef;
        _giveAllowances();
    }

    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        require(msg.sender == vault, "!vault");

        IWombexMasterChef(chef).withdraw(underlyingAsset, balanceOfPool(), 0, address(this));

        uint256 wantBal = IERC20(want).balanceOf(address(this));
        IERC20(want).transfer(vault, wantBal);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public onlyManager {
        pause();
        IWombexMasterChef(chef).withdraw(underlyingAsset, balanceOfPool(), 0, address(this));
    }

    function pause() public onlyManager {
        _pause();

        _removeAllowances();
    }

    function unpause() external onlyManager {
        _unpause();

        _giveAllowances();

        deposit();
    }

    function _giveAllowances() internal {
        IERC20(want).safeApprove(chef, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        IERC20(want).safeApprove(womChef, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        IERC20(underlyingAsset).safeApprove(booster, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        IERC20(sUnderlyingAsset).safeApprove(chef, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        IERC20(output1).safeApprove(unirouter, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
        IERC20(output2).safeApprove(unirouter, uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935));
    }

    function _removeAllowances() internal {
        IERC20(want).safeApprove(chef, 0);
        IERC20(want).safeApprove(womChef, 0);
        IERC20(output1).safeApprove(unirouter, 0);
        IERC20(output2).safeApprove(unirouter, 0);
    }

    /**
     * @dev Rescues random funds stuck that the strat can't handle.
     * @param _token address of the token to rescue.
     */
    function inCaseTokensGetStuck(address _token) external onlyManager {
        require(_token != want, "!token");

        uint256 amount = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeTransfer(msg.sender, amount);
    }
}