// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPancakeRouter {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}
contract PriceInBUSD{
    address public ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address[] public token_Address;
    uint[] public walletBalanceInBUSD;
    mapping(address=>uint) public addressToBalance;

    function setRouterAddress(address _router)public{
        ROUTER_ADDRESS=_router;
    }
    function getRouterAddress()public view returns(address){
        return ROUTER_ADDRESS;
    }
    function getBUSDAddress()public view returns(address){
        return BUSD_ADDRESS;
    }
    function setBUSDAddress(address _BUSD)public{
        BUSD_ADDRESS=_BUSD;
    }
    function getBalance(address wallet,address _token)public view returns(uint){
        IERC20 token= IERC20(_token);
        uint bal=token.balanceOf(wallet);
        return bal;
    }
    function tokenAddressArray(address[] memory _tokenAddress) public{
        token_Address=_tokenAddress;
    }
    function addCoinAddress(address _tokenAddress) public{
        token_Address.push(_tokenAddress);
    }
    function getWalletBalanceInBUSD(address wallet)public returns(uint[] memory,uint){
        uint[] memory walletBalance;
        uint cummulativeBusdBalance;
        for (uint i = 0; i < token_Address.length; i++) {
            IERC20 token = IERC20(token_Address[i]);
            walletBalance[i] = token.balanceOf(wallet);
            walletBalanceInBUSD[i]=getTokenPrice(token_Address[i],walletBalance[i]);
            cummulativeBusdBalance+=walletBalanceInBUSD[i];
            addressToBalance[token_Address[i]]=walletBalanceInBUSD[i];
        }
        return (walletBalanceInBUSD,cummulativeBusdBalance);
    }
    function getExampleBalanceInBUSD(uint256[] memory _walletamount) public view returns(uint[] memory,uint){
        uint[] memory exampleBalanceInBUSD;
        uint cummulativeBusdBalance;
        for (uint i = 0; i < token_Address.length; i++) {
            exampleBalanceInBUSD[i]=getTokenPrice(token_Address[i],_walletamount[i]);
            cummulativeBusdBalance+=exampleBalanceInBUSD[i];
        }
        return (exampleBalanceInBUSD,cummulativeBusdBalance);
    }
    function getTokenPrice(address tokenAddress, uint amountIn) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = BUSD_ADDRESS;
        uint[] memory amountsOut = IPancakeRouter(ROUTER_ADDRESS).getAmountsOut(amountIn, path);
        return amountsOut[1] / amountIn;
    }
}