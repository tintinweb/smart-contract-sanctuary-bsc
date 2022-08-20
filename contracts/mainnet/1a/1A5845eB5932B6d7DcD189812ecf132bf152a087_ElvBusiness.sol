// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router.sol";

interface InviterLike {
    function inviter(address) external view returns (address);
    function setLevel(address,address) external;
}
interface ElvLike {
    function eventTransfer(address src, address dst, uint wad) external;
    function addTransfer(address src, address dst, uint wad) external;
    function subTransfer(address src,uint wad) external;
}

contract ElvBusiness is Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "ElvBusiness/not-authorized");
        _;
    }

    InviterLike public elvInviter = InviterLike(0x69BBaa77604711C3Cb169Bf998ad1407885007E0);
    IUniswapV2Router public uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public eth = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address public operationAddress = 0x7Eb943eBb6ac0d65439B1630774Facd7e6ff567A;
    address public nftPool = 0xcc0F5a4035DB6ADfb7d5F15D5d85CfC8411D1091;
    address public elv;
    address public vault = 0x263df962a83b5bbECBfA549Fe444F284a86f3bC5;
    uint256 public swapTokensAtAmount = 1000 * 1E22;
    bool    public tier;
    uint256 public ethFree;
    uint256 public minEVL;
    uint256 public startTime;

    bool    private swapping;

    mapping(address => bool) private _isExcludedFromFees;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping (address => uint256) public buyamount;

   
    constructor() public {
        wards[msg.sender] = 1;
    }

	function setVariable(uint256 what, address ust, uint256 data) external auth{
        if (what == 1) operationAddress = ust;
        if (what == 2) elvInviter = InviterLike(ust);
        if (what == 3) nftPool = ust;
        if (what == 4) elv = ust;
        if (what == 5) eth = ust;
        if (what == 6) vault = ust;
        if (what == 7) swapTokensAtAmount = data;
        if (what == 8) minEVL = data;
	}

    function setTier() external auth{
        tier = !tier;
	}

    function setTime(uint256 data) external onlyOwner{
        startTime = data;
	}

    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "ElvBusiness: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "ElvBusiness: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transferFrom(address from,address to,uint256 amount) public {
        require(msg.sender == elv,"ElvBusiness/01");
        ElvLike(elv).subTransfer(from, amount);

        if (automatedMarketMakerPairs[to] && IERC20(elv).balanceOf(to) == 0) require(from == operationAddress,"ElvBusiness/02");
        if (automatedMarketMakerPairs[from] && isBuy(from,amount) || automatedMarketMakerPairs[to] && !isAddLiquidity(to,amount)) require(block.timestamp > startTime,"ElvBusiness/03");

        uint256 contractTokenBalance = IERC20(elv).balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from]) {
            swapping = true;
            uint256 wad = contractTokenBalance.sub(ethFree);
            uint256 burnTokens = wad.mul(15).div(60);
            ElvLike(elv).addTransfer(address(this), deadWallet, burnTokens);

            uint256 nftTokens = wad.mul(25).div(60);
            ElvLike(elv).addTransfer(address(this), nftPool, nftTokens);

            uint256 halfs = wad.mul(10).div(60);
            uint256 forUsdtTokens = ethFree.add(halfs);
            swapTokensForETH(forUsdtTokens,halfs);
            
            ElvLike(elv).subTransfer(address(this), IERC20(elv).balanceOf(address(this)));
            ethFree = 0;
            swapping = false;
        }
   
        bool takeFee = !swapping;

        if (!automatedMarketMakerPairs[from] && !automatedMarketMakerPairs[to]) {
           takeFee = false;
        }
  
        else if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
                 takeFee = false;
        }

        else if(automatedMarketMakerPairs[to] && isAddLiquidity(to,amount)) {
                 takeFee = false;
        }

        else if(automatedMarketMakerPairs[from] && !isBuy(from,amount)) {
                 takeFee = false;
        }

        if(takeFee) {
            uint256 feesRatio;
            uint256 ethRatio;
            uint256 fees;
            if (automatedMarketMakerPairs[from]) {
                buyamount[to] += amount;
                feesRatio = 8;
                fees = amount.mul(feesRatio).div(100);
                ElvLike(elv).addTransfer(from,address(this), fees);
                if (tier) rewardsForFree(to,amount);
                else {
                    rewardsForTreasury(to,amount);
                    ethRatio = 2;
                }
            }
            else {
                feesRatio = 15;
                fees = amount.mul(feesRatio).div(100);
                ElvLike(elv).addTransfer(from, address(this), fees);
                ethRatio = 9;
            }
            ethFree += amount.mul(ethRatio).div(100);
            amount = amount.sub(fees);
        }
        ElvLike(elv).addTransfer(from, to, amount);  
    }
    function rewardsForFree(address to,uint256 tokens) private {
        address _dst = to;
        uint256 amounts1 = tokens.mul(12).div(1000);
        uint256 amounts2 = tokens.mul(8).div(1000);
        ElvLike(elv).subTransfer(address(this), tokens.mul(20).div(1000));
        for (uint256 i=0;i<2;++i) {
            address referrer = elvInviter.inviter(_dst);
            address _referrer = referrer;
            uint256 amount;
            if (_referrer == address(0) || IERC20(elv).balanceOf(_referrer) < minEVL*1E18 || automatedMarketMakerPairs[_referrer]) _referrer = operationAddress;
            if (i==0) amount = amounts1;
            if (i==1) amount = amounts2;
            ElvLike(elv).addTransfer(address(this),_referrer, amount);
            _dst = referrer; 
        }
    }
    function rewardsForTreasury(address to,uint256 tokens) private {
        address _dst = to;
        uint256 amounts1 = tokens.mul(10).div(100);
        uint256 amounts2 = tokens.mul(4).div(100);
        uint256 amounts3 = tokens.mul(3).div(100);
        ElvLike(elv).subTransfer(vault, tokens.mul(17).div(100));
        for (uint256 i=0;i<3;++i) {
            address referrer = elvInviter.inviter(_dst);
            address _referrer = referrer;
            uint256 amount;
            if (_referrer == address(0) || IERC20(elv).balanceOf(_referrer) < minEVL*1E18 || automatedMarketMakerPairs[_referrer]) _referrer = operationAddress;
            if (i==0) amount = amounts1;
            if (i==1) amount = amounts2;
            if (i==2) amount = amounts3;
            ElvLike(elv).addTransfer(vault,_referrer, amount);
            _dst = referrer; 
        }
    }
    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = elv;
        path[1] = usdt;
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 tokenAmount,uint256 _addlpTokens) private {
        swapTokensForUsdt(tokenAmount);
        swapAndLiquify(_addlpTokens);
        uint256 usdtAmount = IERC20(usdt).balanceOf(address(this));
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = eth;

        // make the swap
        uniswapV2Router.swapExactTokensForTokens(
            usdtAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function init() public {
        IERC20(elv).approve(address(uniswapV2Router), ~uint256(0));
        IERC20(usdt).approve(address(uniswapV2Router), ~uint256(0));
    }

    function swapAndLiquify(uint256 elvAmount) private {
        uint256 usdtAmount = IERC20(usdt).balanceOf(address(this));
        uniswapV2Router.addLiquidity(
            elv,
            usdt,
            elvAmount,
            usdtAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    function getAsset(address _pair) internal view returns (address){
        address _token0 = IUniswapV2Pair(_pair).token0();
        address _token1 = IUniswapV2Pair(_pair).token1();
        address asset = _token0 == elv ? _token1 : _token0;
        return asset;
    }
    //Decide whether to add liquidity or sell,
    function isAddLiquidity(address _pair,uint256 wad) internal view returns (bool) {
        address _asset = getAsset(_pair);
        uint256 balance1 = IERC20(_asset).balanceOf(_pair);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return true;
        address _token0 = IUniswapV2Pair(_pair).token0();
        (uint256 spdreserve, uint256 assetreserve)= _token0 == elv ? (reserve0,reserve1) : (reserve1,reserve0);
        uint256 assetamount = uniswapV2Router.quote(wad, spdreserve, assetreserve);
        return (balance1 > assetreserve + assetamount/2 );
    }
    function isBuy(address _pair,uint256 wad) internal view returns (bool) {
        if (!automatedMarketMakerPairs[_pair]) return false;
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        address _token0 = IUniswapV2Pair(_pair).token0();
        (,uint assetreserve)= _token0 == elv ? (reserve0,reserve1) : (reserve1,reserve0);
        address _asset = getAsset(_pair);
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = elv;
        uint[] memory amounts = uniswapV2Router.getAmountsIn(wad,path);
        uint balance1 = IERC20(_asset).balanceOf(_pair);
        return (balance1 > assetreserve + amounts[0]/2);
    }
    
    function withdraw(address asses) public {
        require(msg.sender == operationAddress,"ElvBusiness/04");
        IERC20(asses).transfer(operationAddress, IERC20(asses).balanceOf(address(this)));
    }
    function getAmount(address usr) external view returns (uint256){
        return buyamount[usr];
    }

}