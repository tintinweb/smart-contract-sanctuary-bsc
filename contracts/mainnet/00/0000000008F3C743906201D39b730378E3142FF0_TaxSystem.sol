/**
 *Submitted for verification at BscScan.com on 2023-02-02
*/

/**
Attention all ye citizens, the hour of reckoning draws nigh. 
The time has come to take stock of what is owed and to make payments accordingly. 
For those who dare to join us in this great endeavor, the future is yours to shape. 
Endgame.black awaits. Tis' the hour, the end is near.
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IPancakeSwapRouter{
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
    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
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

interface IBattle {
    function notifyFunds(
        uint256 _rTokenFundsForSmallBattle,
        uint256 _fundsForSmallBattle,
        uint256 _bnbFundsForBigBattle,
        uint256 _gamesPerFragment,
        address _rToken
    ) external;
}

interface IENDGAMEDividendTracker {
    function distributeRTokenDividends(uint256 amount, address _rToken) external;
}

contract TaxSystem is Ownable {
    using SafeMath for uint256;
    string public name = "TaxSystem";

    uint256 public constant MAX_UINT256 = ~uint256(0);

    struct TradeTaxSystem {
        uint256 rTokenRewardFee;
        uint256 rTokenDirectRewardFee;
        uint256 smallBattleRTokenFee;
        uint256 smallBattleEndgameFee;
        uint256 liquidityFee;
        uint256 rfvFee;
        uint256 treasuryFee;
        uint256 bigBattleFee;
        uint256 rebaserFee;
        uint256 referralFee;
        uint256 burnFee;
        uint256 totalFee;
	}

    TradeTaxSystem public buyTaxWithReferral;
    TradeTaxSystem public sellTaxWithReferral;
    TradeTaxSystem public transferTaxWithReferral;
    TradeTaxSystem public buyTaxWithoutReferral;
    TradeTaxSystem public sellTaxWithoutReferral;
    TradeTaxSystem public transferTaxWithoutReferral;

    uint256 public maxBracketTax;
    uint256 public feeDenominator;

    struct EpochAcc {
        uint256 accRTokenReward;
        uint256 accSmallBattleRToken;
        uint256 accSmallBattleEndgame;
        uint256 accRFV;
        uint256 accTreasury;
        uint256 accBigBattle;
        uint256 accRebaser;
        uint256 accResearchFund;
        uint256 accDynamicFeeFund;
	}

    EpochAcc public epochAcc;

    address public autoLiquidityReceiver;
    address public treasuryReceiver;
    address public RFVWallet;
    address public rebaserWallet;
    address public researchFund;
    address public dynamicFeeReceiver;
    
    address public endgame;
    IENDGAMEDividendTracker public dividendTracker;
    IBattle public battle;

    modifier onlyEndgame() {
        require(msg.sender == endgame, "Not Endgame Contract");
        _;
    }

    constructor() {
        buyTaxWithReferral = TradeTaxSystem({
            rTokenRewardFee: 50000000,
            rTokenDirectRewardFee: 50000000,
            smallBattleRTokenFee: 100000000,
            smallBattleEndgameFee: 100000000,
            liquidityFee: 50000000,
            rfvFee: 50000000,
            treasuryFee: 100000000,
            bigBattleFee: 100000000,
            rebaserFee: 50000000,
            referralFee: 300000000,
            burnFee: 50000000,
            totalFee: 1000000000
        });

        sellTaxWithReferral = TradeTaxSystem({
            rTokenRewardFee: 100000000,
            rTokenDirectRewardFee: 100000000,
            smallBattleRTokenFee: 100000000,
            smallBattleEndgameFee: 100000000,
            liquidityFee: 200000000,
            rfvFee: 200000000,
            treasuryFee: 100000000,
            bigBattleFee: 100000000,
            rebaserFee: 100000000,
            referralFee: 300000000,
            burnFee: 100000000,
            totalFee: 1500000000
        });

        transferTaxWithReferral = TradeTaxSystem({
            rTokenRewardFee: 0,
            rTokenDirectRewardFee: 0,
            smallBattleRTokenFee: 0,
            smallBattleEndgameFee: 0,
            liquidityFee: 0,
            rfvFee: 0,
            treasuryFee: 0,
            bigBattleFee: 0,
            rebaserFee: 0,
            referralFee: 1000000000,
            burnFee: 0,
            totalFee: 1000000000
        });

        buyTaxWithoutReferral = TradeTaxSystem({
            rTokenRewardFee: 50000000,
            rTokenDirectRewardFee: 50000000,
            smallBattleRTokenFee: 100000000,
            smallBattleEndgameFee: 100000000,
            liquidityFee: 350000000,
            rfvFee: 50000000,
            treasuryFee: 100000000,
            bigBattleFee: 100000000,
            rebaserFee: 50000000,
            referralFee: 0,
            burnFee: 50000000,
            totalFee: 1000000000
        });

        sellTaxWithoutReferral = TradeTaxSystem({
            rTokenRewardFee: 200000000,
            rTokenDirectRewardFee: 100000000,
            smallBattleRTokenFee: 100000000,
            smallBattleEndgameFee: 100000000,
            liquidityFee: 700000000,
            rfvFee: 200000000,
            treasuryFee: 200000000,
            bigBattleFee: 200000000,
            rebaserFee: 100000000,
            referralFee: 0,
            burnFee: 200000000,
            totalFee: 2100000000
        });

        transferTaxWithoutReferral = TradeTaxSystem({
            rTokenRewardFee: 0,
            rTokenDirectRewardFee: 0,
            smallBattleRTokenFee: 0,
            smallBattleEndgameFee: 0,
            liquidityFee: 0,
            rfvFee: 0,
            treasuryFee: 0,
            bigBattleFee: 0,
            rebaserFee: 0,
            referralFee: 1000000000,
            burnFee: 0,
            totalFee: 1000000000
        });

        maxBracketTax = 1000000000;
        feeDenominator = 10000000000;
    }

    function updateEpochAcc(
        uint256 gameAmount,
        TradeTaxSystem memory tradeTax,
        uint256 _dynamicFee,
        uint256 _gamesPerFragment,
        address _trader,
        address _router,
        address _rToken,
        address _rTokenRouter,
        uint256 _tradeFlag
    ) external onlyEndgame {
        epochAcc.accRTokenReward += gameAmount.mul(tradeTax.rTokenRewardFee);
        epochAcc.accSmallBattleRToken += gameAmount.mul(tradeTax.smallBattleRTokenFee);
        epochAcc.accSmallBattleEndgame += gameAmount.mul(tradeTax.smallBattleEndgameFee);
        epochAcc.accRFV += gameAmount.mul(tradeTax.rfvFee);
        epochAcc.accTreasury += gameAmount.mul(tradeTax.treasuryFee);
        epochAcc.accBigBattle += gameAmount.mul(tradeTax.bigBattleFee);
        epochAcc.accRebaser += gameAmount.mul(tradeTax.rebaserFee);
        epochAcc.accDynamicFeeFund += gameAmount.mul(_dynamicFee);

        if (_tradeFlag == 2) {
            epochAcc.accResearchFund += gameAmount.mul(tradeTax.rTokenDirectRewardFee);
        } else {
            uint256 amountToETH = gameAmount.mul(tradeTax.rTokenDirectRewardFee).div(feeDenominator);
            amountToETH = amountToETH.div(_gamesPerFragment);
            if ( amountToETH > 0 ) {
                address[] memory path = new address[](2);
                path[0] = endgame;
                path[1] = IPancakeSwapRouter(_router).WETH();

                uint256 balanceBefore = address(this).balance;
                IPancakeSwapRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
                    amountToETH,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
                uint256 amountToRToken = address(this).balance.sub(balanceBefore);
                if( amountToRToken > 0 ) {
                    path[0] = IPancakeSwapRouter(_rTokenRouter).WETH();
                    path[1] = _rToken;

                    IPancakeSwapRouter(_rTokenRouter).swapExactETHForTokensSupportingFeeOnTransferTokens{value: amountToRToken}(
                        0,
                        path,
                        _trader,
                        block.timestamp
                    );
                }
            }
        }
    }

    function swapBack(
        uint256 _gamesPerFragment,
        address _router,
        address _rToken,
        address _rTokenRouter
    ) external onlyEndgame {
        uint256[] memory mValue = new uint256[](22);

        mValue[0] = epochAcc.accRTokenReward.add(epochAcc.accSmallBattleRToken).add(epochAcc.accRFV).add(
            epochAcc.accTreasury).add(epochAcc.accBigBattle).add(epochAcc.accRebaser).add(
            epochAcc.accResearchFund).add(epochAcc.accDynamicFeeFund); // amount to ETH (game balance)

        if ( mValue[0] == 0) {
            resetEpochAcc();
            return;
        }

        mValue[1] = epochAcc.accRFV.mul(10000000000).div(mValue[0]); // accRFV percent (game balance)
        mValue[2] = epochAcc.accBigBattle.mul(10000000000).div(mValue[0]); // accBigBattle percent (game balance)
        mValue[3] = epochAcc.accRebaser.mul(10000000000).div(mValue[0]); // accRebaser percent (game balance)

        address[] memory path = new address[](2);
        path[0] = endgame;
        path[1] = IPancakeSwapRouter(_router).WETH();

        mValue[4] = address(this).balance; // ETH balance before
        mValue[0] = mValue[0].div(feeDenominator).div(_gamesPerFragment); // amount to ETH 
        IPancakeSwapRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            mValue[0],
            0,
            path,
            address(this),
            block.timestamp
        );

        mValue[5] = address(this).balance.sub(mValue[4]); // received ETH balance
        mValue[6] = mValue[5].mul(mValue[1]).div(10000000000); // ETH amount to RFV
        mValue[7] = mValue[5].mul(mValue[3]).div(10000000000); // ETH amount to Rebaser
        mValue[8] = mValue[5].mul(mValue[2]).div(10000000000); // ETH amount to BigBattle

        bool success;
        if ( mValue[6] > 0) {
            (success, ) = RFVWallet.call{
                value: mValue[6],
                gas: 30000
            }("");
        }
        if ( mValue[7] > 0) {
            (success, ) = rebaserWallet.call{
                value: mValue[7],
                gas: 30000
            }("");
        }

        mValue[9] = mValue[5].sub(mValue[6]).sub(mValue[7]).sub(
            mValue[8]); // ETH amount to Swap

        if( mValue[9] == 0) {
            resetEpochAcc();
            return;
        }

        path[0] = IPancakeSwapRouter(_rTokenRouter).WETH();
        path[1] = _rToken;

        mValue[4] = IERC20(_rToken).balanceOf(address(this)); // RToken balance before
        IPancakeSwapRouter(_rTokenRouter).swapExactETHForTokensSupportingFeeOnTransferTokens{value: mValue[9]}(
            0,
            path,
            address(this),
            block.timestamp
        );

        mValue[10] = IERC20(_rToken).balanceOf(
            address(this)).sub(mValue[4]); // received RToken balance
        
        mValue[11] = epochAcc.accRTokenReward.add(epochAcc.accSmallBattleRToken).add(
            epochAcc.accTreasury).add(epochAcc.accResearchFund).add(epochAcc.accDynamicFeeFund); // total amount for RToken

        if( mValue[11] == 0) {
            resetEpochAcc();
            return;
        }

        mValue[12] = epochAcc.accRTokenReward.mul(10000000000).div(mValue[11]); // RToken reward percent
        mValue[13] = epochAcc.accSmallBattleRToken.mul(10000000000).div(mValue[11]); // RToken percent for small battle
        mValue[17] = epochAcc.accTreasury.mul(10000000000).div(mValue[11]); //RToken percent for treasury
        mValue[19] = epochAcc.accResearchFund.mul(10000000000).div(mValue[11]); //RToken percent for researchFund

        mValue[14] = mValue[10].mul(mValue[12]).div(10000000000); // RToken amount to Reward
        mValue[15] = mValue[10].mul(mValue[13]).div(10000000000); // RToken amount to small battle
        mValue[16] = mValue[10].mul(mValue[17]).div(10000000000); // RToken amount to treasury
        mValue[18] = mValue[10].mul(mValue[19]).div(10000000000); // RToken amount to researchFund
        mValue[20] = mValue[10].sub(mValue[14]).sub(mValue[15]).sub(
                        mValue[16]).sub(mValue[18]); // RToken amount to dynamicFeeWallet

        if ( mValue[14] > 0) {
            success = IERC20(_rToken).transfer(address(dividendTracker), mValue[14]);
            if (success) {
                dividendTracker.distributeRTokenDividends(mValue[14], _rToken);
            }
        }
        if ( mValue[16] > 0) {
            IERC20(_rToken).transfer(treasuryReceiver, mValue[16]);
        }
        if ( mValue[18] > 0) {
            IERC20(_rToken).transfer(researchFund, mValue[18]);
        }
        if ( mValue[20] > 0) {
            IERC20(_rToken).transfer(dynamicFeeReceiver, mValue[20]);
        }
        success = true;
        if ( mValue[8] > 0) {
            (success, ) = address(battle).call{
                value: mValue[8],
                gas: 30000
            }("");
        }
        mValue[21] = epochAcc.accSmallBattleEndgame.div(feeDenominator).div(_gamesPerFragment); // endgame For Small Battle
        if (success && (mValue[21] > 0)) {
            success = IERC20(endgame).transfer(address(battle), mValue[21]);
        }
        if (success && (mValue[15] > 0)) {
            success = IERC20(_rToken).transfer(address(battle), mValue[15]);
        }

        if (success) {
            battle.notifyFunds(
                mValue[15],
                mValue[21].mul(_gamesPerFragment),
                mValue[8],
                _gamesPerFragment,
                _rToken
            );
        }
        
        resetEpochAcc();
    }

    function resetEpochAcc() internal {
        epochAcc.accRTokenReward = 0;
        epochAcc.accSmallBattleRToken = 0;
        epochAcc.accSmallBattleEndgame = 0;
        epochAcc.accRFV = 0;
        epochAcc.accTreasury = 0;
        epochAcc.accBigBattle = 0;
        epochAcc.accRebaser = 0;
        epochAcc.accResearchFund = 0;
        epochAcc.accDynamicFeeFund = 0;
    }

    function addLiquidity(
        uint256 autoLiquidityAmount,
        address _router
    ) external onlyEndgame {
        uint256 amountToLiquify = autoLiquidityAmount.div(2);
        uint256 amountToSwap = autoLiquidityAmount.sub(amountToLiquify);

        if( amountToSwap == 0 ) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = endgame;
        path[1] = IPancakeSwapRouter(_router).WETH();

        uint256 balanceBefore = address(this).balance;

        IPancakeSwapRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETHLiquidity = address(this).balance.sub(balanceBefore);

        if (amountToLiquify > 0 && amountETHLiquidity > 0) {
            IPancakeSwapRouter(_router).addLiquidityETH{value: amountETHLiquidity}(
                endgame,
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
        }
    }

    function updateBuyTaxWithReferral(
        TradeTaxSystem memory _tradeTax
    ) external onlyOwner {
        buyTaxWithReferral = _tradeTax;
    }

    function updateSellTaxWithReferral(
        TradeTaxSystem memory _tradeTax
    ) external onlyOwner {
        sellTaxWithReferral = _tradeTax;
    }

    function updateTransferTaxWithReferral(
        TradeTaxSystem memory _tradeTax
    ) external onlyOwner {
        transferTaxWithReferral = _tradeTax;
    }

    function updateBuyTaxWithoutReferral(
        TradeTaxSystem memory _tradeTax
    ) external onlyOwner {
        buyTaxWithoutReferral = _tradeTax;
    }

    function updateSellTaxWithoutReferral(
        TradeTaxSystem memory _tradeTax
    ) external onlyOwner {
        sellTaxWithoutReferral = _tradeTax;
    }

    function updateTransferTaxWithoutReferral(
        TradeTaxSystem memory _tradeTax
    ) external onlyOwner {
        transferTaxWithoutReferral = _tradeTax;
    }

    function updateMaxBracketTax(
        uint256 _maxBracketTax
    ) external onlyOwner {
        maxBracketTax = _maxBracketTax;
    }

    function updateFeeDenominator(
        uint256 _feeDenominator
    ) external onlyOwner {
        feeDenominator = _feeDenominator;
    }

    function withdrawAllToTreasury(
        uint256 amountToSwap,
        address _router
    ) external onlyEndgame {
        address[] memory path = new address[](2);
        path[0] = endgame;
        path[1] = IPancakeSwapRouter(_router).WETH();
        IPancakeSwapRouter(_router).swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            treasuryReceiver,
            block.timestamp
        );
    }

    function setFeeReceivers(
        address _autoLiquidityReceiver,
        address _treasuryReceiver,
        address _RFVWallet,
        address _rebaserWallet,
        address _researchFund,
        address _dynamicFeeReceiver
    ) external onlyEndgame {
        autoLiquidityReceiver = _autoLiquidityReceiver;
        treasuryReceiver = _treasuryReceiver;
        RFVWallet = _RFVWallet;
        rebaserWallet = _rebaserWallet;
        researchFund = _researchFund;
        dynamicFeeReceiver = _dynamicFeeReceiver;
    }

    function updateEndgame(address _endgame) external onlyOwner {
        require(isContract(_endgame), "only contract address");
        endgame = _endgame;
    }

    function updateDividendTracker(address _dividendTracker) external onlyEndgame {
        dividendTracker = IENDGAMEDividendTracker(_dividendTracker);
    }

    function updateBattle(address _battle) external onlyEndgame {
        battle = IBattle(_battle);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    receive() external payable {}

}