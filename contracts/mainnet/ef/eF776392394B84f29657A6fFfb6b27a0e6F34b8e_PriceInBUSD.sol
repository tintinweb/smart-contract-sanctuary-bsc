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
    address[] public token_Address = [
        0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c,
        0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d,
        0xFeea0bDd3D07eb6FE305938878C0caDBFa169042,
        0x3EE2200Efb3400fAbB9AacF31297cBdD1d435D47,
        0xbA2aE424d960c26247Dd6c32edC70B295c744C43,
        0xC762043E211571eB34f1ef377e5e8e76914962f9
    ];

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
    function addCoinAddress(address _tokenAddress) public {
        token_Address.push(_tokenAddress);
    }
    function getWalletBalanceInBUSD_Details(address wallet) public view returns(uint[] memory, uint[] memory, uint, uint){
        uint[] memory walletBalance;
        uint[] memory walletBalanceInBUSD;
        uint cummulativeBusdBalance = 0;
        for (uint i = 0; i < token_Address.length; i++) {
            IERC20 token = IERC20(token_Address[i]);
            walletBalance[i] = token.balanceOf(wallet);
            walletBalanceInBUSD[i] = getTokenPrice(token_Address[i], walletBalance[i]);
            cummulativeBusdBalance+=walletBalanceInBUSD[i];
        }
        uint busd_balance = IERC20(BUSD_ADDRESS).balanceOf(wallet);
        cummulativeBusdBalance += busd_balance;
        return (walletBalance, walletBalanceInBUSD, busd_balance, cummulativeBusdBalance);
    }

     function getWalletBalanceInBUSD(address wallet) public view returns(uint, uint){
        uint cummulativeBusdBalance = 0;
        for (uint i = 0; i < token_Address.length; i++) {
            IERC20 token = IERC20(token_Address[i]);
            cummulativeBusdBalance += getTokenPrice(token_Address[i], token.balanceOf(wallet));
        }
        uint busd_balance = IERC20(BUSD_ADDRESS).balanceOf(wallet);
        cummulativeBusdBalance += busd_balance;
        return (busd_balance, cummulativeBusdBalance);
    }

    function getExampleBalanceInBUSD_Details(uint256[] memory _walletamount, uint256 _busd_amount) public view returns(uint[] memory,uint){
        uint[] memory exampleBalanceInBUSD;
        uint cummulativeBusdBalance = 0;
        for (uint i = 0; i < token_Address.length; i++) {
            exampleBalanceInBUSD[i]=getTokenPrice(token_Address[i], _walletamount[i]);
            cummulativeBusdBalance+=exampleBalanceInBUSD[i];
        }
        cummulativeBusdBalance += _busd_amount;
        return (exampleBalanceInBUSD,cummulativeBusdBalance);
    }


    function getExampleBalanceInBUSD(uint256[] memory _walletamount, uint256 _busd_amount) public view returns(uint){
        uint cummulativeBusdBalance = 0;
        for (uint i = 0; i < token_Address.length; i++) {
            cummulativeBusdBalance += getTokenPrice(token_Address[i], _walletamount[i]);
        }
        cummulativeBusdBalance += _busd_amount;
        return (cummulativeBusdBalance);
    }

    function getTokenPrice(address tokenAddress, uint amountIn) public view returns (uint) {
        address[] memory path = new address[](2);
        path[0] = tokenAddress;
        path[1] = BUSD_ADDRESS;
        uint[] memory amountsOut = IPancakeRouter(ROUTER_ADDRESS).getAmountsOut(amountIn, path);
        return amountsOut[1];
    }
}