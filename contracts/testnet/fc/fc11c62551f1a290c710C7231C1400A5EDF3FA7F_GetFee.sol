//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.11;
import "./IPancakeRouter01.sol";
contract GetFee {
    // 根据不同的地址获取不同的汇率
    constructor(address _router) {
        router = IPancakeSwapRouter(_router);
    }
    address public IPanAddress;
    address public usdtAddress = 0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684;
    address public tokenAddress = 0x0a2231B33152d059454FF43F616E4434Afb6Cc64;
    IPancakeSwapRouter public router;

    function getRateByAddress(uint amountIn, address[] memory path) view public returns(uint[] memory amounts){
        amounts = router.getAmountsOut(amountIn, path);
        return amounts;
    }
    address[] _path = [usdtAddress,tokenAddress];
    function getUsdtPrice(uint amountIn) public view  returns(uint[] memory amounts){
        amounts = getRateByAddress(amountIn,_path);
        return amounts;
    }
    function getUsdtPrice1(uint amountIn) public view  returns(uint){
        uint[] memory amounts = getRateByAddress(amountIn,_path);
        return amounts[1];
    }
    function setIpaddress(address _addr) public{
        router = IPancakeSwapRouter(_addr);
    }
    function setTokenddress(address _addr) public{
        tokenAddress = _addr;
    }
    function setUsdtddress(address _addr) public{
        usdtAddress = _addr;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPancakeSwapRouter {   
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}