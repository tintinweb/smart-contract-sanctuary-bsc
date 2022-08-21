// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./SafeMath.sol";
import "./SafeMathUint.sol";
import "./SafeMathInt.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Factory.sol";
import "./IUniswapV2Router.sol";
interface exchequerLike {
    function addlp() external;
}
contract CcoinToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CcoinToken/not-authorized");
        _;
    }

    IUniswapV2Router public uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address public vault = 0x623F0a30a9ff1dDb02aEf7E57B5006a5F3A1a6c1;

    address public  uniswapV2Pair;
    bool private swapping;

    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public deadWallet = 0x000000000000000000000000000000000000dEaD;
    address public operationAddress = 0x7Eb943eBb6ac0d65439B1630774Facd7e6ff567A;
    address public fistLP = 0x7Eb943eBb6ac0d65439B1630774Facd7e6ff567A;

    uint256 public swapTokensAtAmount = 10000 * (10**18);
    uint256 public startTime;

    mapping(address => bool) private _isExcludedFromFees;

    mapping (address => bool) public automatedMarketMakerPairs;

    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    constructor() public ERC20("Ccoin", "Ccoin") {
        wards[msg.sender] = 1;
        address _uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdt);
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        _mint(owner(), 1600000 * 1e18);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }
	function setVariable(uint256 what, address ust, uint256 data) external auth{
        if (what == 1) vault = ust;
        if (what == 2) fistLP = ust;
        if (what == 3) operationAddress = ust;
        if (what == 4) swapTokensAtAmount = data;
	}
    function excludeFromFees(address account, bool excluded) public auth {
        require(_isExcludedFromFees[account] != excluded, "CCIOIN: Account is already the value of 'excluded'");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) public auth {
        require(automatedMarketMakerPairs[pair] != value, "CCIOIN: Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }


    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

	function setTime(uint256 data) external onlyOwner{
        startTime = data;
	}

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        if (automatedMarketMakerPairs[to] && balanceOf(to) == 0) require(from == fistLP,"CCIOIN/001");
        if (automatedMarketMakerPairs[from] && isBuy(from,amount) || automatedMarketMakerPairs[to] && !isAddLiquidity(to,amount)) require(block.timestamp > startTime,"CCIOIN/002");
 
        if(amount <= 1E16) {
            super._transfer(from, to, amount);
            return;
        }
 
		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
            uint256 dead = contractTokenBalance.mul(5).div(60);
            super._transfer(address(this),deadWallet,dead);

            uint256 award = contractTokenBalance.mul(50).div(60);
            super._transfer(address(this),vault,award);

            uint256 sellTokens = balanceOf(address(this));
            swapTokensForUsdt(sellTokens);

            swapping = false;
        }

        bool takeFee = !swapping;
        // if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if(takeFee) {
        	uint256 fees = amount.mul(6).div(100);
            super._transfer(from, address(this), fees);
            amount = amount.sub(fees);
        }
        super._transfer(from, to, amount);       
    }

    function initApprove() public {
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
    }

    function swapTokensForUsdt(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        uniswapV2Router.swapExactTokensForTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            vault,
            block.timestamp
        );
        exchequerLike(vault).addlp();
    }

    function getAsset(address _pair) public view returns (address){
        address _token0 = IUniswapV2Pair(_pair).token0();
        address _token1 = IUniswapV2Pair(_pair).token1();
        address asset = _token0 == address(this) ? _token1 : _token0;
        return asset;
    }
    //Decide whether to add liquidity or sell,
    function isAddLiquidity(address _pair,uint256 wad) internal view returns (bool) {
        address _asset = getAsset(_pair);
        uint256 balance1 = IERC20(_asset).balanceOf(_pair);
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(_pair).getReserves();
        if (reserve0 ==0 || reserve1 ==0 ) return true;
        address _token0 = IUniswapV2Pair(_pair).token0();
        (uint256 spdreserve, uint256 assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        uint256 assetamount = uniswapV2Router.quote(wad, spdreserve, assetreserve);
        return (balance1 > assetreserve + assetamount/2 );
    }
    function isBuy(address _pair,uint256 wad) internal view returns (bool) {
        if (!automatedMarketMakerPairs[_pair]) return false;
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();
        address _token0 = IUniswapV2Pair(_pair).token0();
        (,uint assetreserve)= _token0 == address(this) ? (reserve0,reserve1) : (reserve1,reserve0);
        address _asset = getAsset(_pair);
        address[] memory path = new address[](2);
        path[0] = _asset;
        path[1] = address(this);
        uint[] memory amounts = uniswapV2Router.getAmountsIn(wad,path);
        uint balance1 = IERC20(_asset).balanceOf(_pair);
        return (balance1 > assetreserve + amounts[0]/2);
    }
}