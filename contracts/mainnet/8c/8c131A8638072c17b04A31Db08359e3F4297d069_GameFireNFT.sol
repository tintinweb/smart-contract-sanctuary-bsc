// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "./ERC20.sol";
import "./IUniswapV2Pair.sol";
import "./IUniswapV2Router.sol";
import "./IUniswapV2Factory.sol";

interface InviterLike {
    function inviter(address) external view returns (address);
    function setLevel(address,address) external;
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
contract GameFireNFT is ERC20{
    using Address for address;

    InviterLike public gncInviter = InviterLike(0x2b9f11E9275bB06A787a84C1d9E6c0A018e364eB);
    IUniswapV2Router public uniswapV2Router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E); 
    address public operationAddress = 0x0473396Ba10568409088AF9192a197E4CBC1973E;
    address public uniswapV2Pair;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;

    mapping (address => bool) public automatedMarketMakerPairs;

    constructor() public ERC20("GameFireNFT", "GNC") {
        uniswapV2Pair  = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), usdt);
        automatedMarketMakerPairs[uniswapV2Pair] = true;
        _mint(0xaa36AFDC1F5Ac7211D0f1d4D4033df6C17fB2A7b, 75000000 * 1e18);
    }

    function _transfer(address from,address to,uint256 amount) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }
        if (gncInviter.inviter(to) == address(0) && balanceOf(to) == 0) try gncInviter.setLevel(to,from) {} catch {}

        bool takeFee;
        if(automatedMarketMakerPairs[to] && !isAddLiquidity(to,amount)) takeFee = true;
        if(automatedMarketMakerPairs[from] && isBuy(from,amount)) takeFee = true;
        if(true) {
        	uint256 fees = amount.mul(1).div(100);
            super._transfer(from, address(this), fees);
            address dst;
            if(automatedMarketMakerPairs[from]) dst = to;
            else dst = from;
            address _referrer = gncInviter.inviter(dst);
            if(_referrer == address(0) || _referrer.isContract()) _referrer = operationAddress;
            super._transfer(from, _referrer, fees);
            amount = amount.sub(2*fees);
        }
        if (!automatedMarketMakerPairs[from] && balanceOf(address(this))>0) {
            super._transfer(address(this), uniswapV2Pair, balanceOf(address(this)));
            IUniswapV2Pair(uniswapV2Pair).sync();
        }
        super._transfer(from, to, amount);       
    }
    function getAsset(address _pair) internal view returns (address){
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
    //Withdraw assets that were mistakenly entered into the contract
    function withdraw(address asses) public {
        require(msg.sender == operationAddress,"GNC/01");
        IERC20(asses).transfer(operationAddress, IERC20(asses).balanceOf(address(this)));
    }
    function setOperation(address newOperation) public {
        require(msg.sender == operationAddress,"GNC/02");
        operationAddress = newOperation;
    }
}