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

contract CcoinToken is ERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint) public wards;
    function rely(address usr) external  auth { wards[usr] = 1; }
    function deny(address usr) external  auth { wards[usr] = 0; }
    modifier auth {
        require(wards[msg.sender] == 1, "CSAToken/not-authorized");
        _;
    }

    IUniswapV2Router public uniswapV2Router;
    address public vault = 0xD41a11F824b337620400400aF5b43A637F5E143a;

    address public  uniswapV2Pair;
    bool private swapping;

    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public operationAddress = 0x28A47379F29267Fbc2Bbd853FD59152dB9c6EFaA;
    address public fistLP = 0x28A47379F29267Fbc2Bbd853FD59152dB9c6EFaA;

    uint256 public swapTokensAtAmount = 10000 * (10**18);
    uint256 public startTime;

    // exlcude from fees and max transaction amount
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => uint256) public EdaoReferrer;
    // store addresses that a automatic market maker pairs. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateDividendTracker(address indexed newAddress, address indexed oldAddress);
    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);
    event ExcludeFromFees(address indexed account, bool isExcluded);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event LiquidityWalletUpdated(address indexed newLiquidityWallet, address indexed oldLiquidityWallet);
    event GasForProcessingUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );
    event SendDividends(
        address indexed ust,
    	uint256 tokensSwapped,
    	uint256 amount
    );
    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );

    constructor() public ERC20("Ccoin", "Ccoin") {

        wards[msg.sender] = 1;
    	IUniswapV2Router _uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Router = _uniswapV2Router;
        // Create a uniswap pair for this new token
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), usdt);
        uniswapV2Pair = _uniswapV2Pair;
        _setAutomatedMarketMakerPair(_uniswapV2Pair, true);
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        _mint(owner(), 1600000 * 1e18);
        _approve(address(this), address(uniswapV2Router), ~uint256(0));
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

        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (automatedMarketMakerPairs[to] && balanceOf(to) == 0) require(from == fistLP,"CCIOIN/001");
        if (automatedMarketMakerPairs[from] && isBuy(from,amount) || automatedMarketMakerPairs[to] && !isAddLiquidity(to,amount)) require(block.timestamp > startTime,"CCIOIN/001");
 
        if(amount <= 1E18) {
            super._transfer(from, to, amount);
            return;
        }
 
		uint256 contractTokenBalance = balanceOf(address(this));
        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(canSwap && !swapping && !automatedMarketMakerPairs[from] && from != owner() && to != owner()) {
            swapping = true;
            uint256 backpair = contractTokenBalance.mul(1).div(6);
            super._transfer(address(this),uniswapV2Pair,backpair);
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