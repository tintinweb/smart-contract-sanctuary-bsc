pragma solidity ^0.8.0;

interface IPancakePair {
    function totalSupply() external view returns (uint);
}

interface IPancakeRouter01 {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

contract RetriveTokenPrice {
    address private pancakePair = 0x0DB94CAEE2FbB7eC69959240e93d6F86b4223525;
    address private pancakeRouterV2 = 0xCc7aDc94F3D80127849D2b41b6439b7CF1eB4Ae0;
    address public usdt = 0xf35B19Cf48E8CFC92488609DF23Ce1B7d894A07c;
    address public wbnb = 0x0dE8FCAE8421fc79B29adE9ffF97854a424Cad09;
    address public dfhToken = 0xf35B19Cf48E8CFC92488609DF23Ce1B7d894A07c;

    function get()
        external
        view 
    returns(uint256) {
        uint256 _totalSupplyofLP = IPancakePair(pancakePair).totalSupply();

        address[] memory path;
        path[0] = wbnb;
        path[1] = usdt;

        uint256[] memory _wbnbPrice = IPancakeRouter01(pancakeRouterV2).getAmountsOut(10**18, path);
        return _wbnbPrice[1];

        // path[0] = dfh;
        // path[1] = wbnb;
        // uint256[] memory _oneBNBWithBusd = IPancakeRouter01(pancakeRouterV2).getAmountsOut(10**18, path);

        // uint256 _curPrice = _oneTokenWithBNB*_oneBNBWithBusd;



        // return _totalSupplyofLP;
    }
}