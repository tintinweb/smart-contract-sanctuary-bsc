/**
 *Submitted for verification at BscScan.com on 2022-09-15
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;


//By : 0xdaebak
//https://github.com/0xdaebak

contract HoneyPotChecker{


struct HoneyPot{
        bool isHoneyPot;
        address base;
        address token;
        uint256 estimatedBuy;
        uint256 buyAmount;
        uint256 estimatedSell;
        uint256 sellAmount;
        uint256 buyGas;
        uint256 sellGas;
    }

function isHoneyPot(address router, address base, address token) external payable returns(HoneyPot memory){
HoneyPot memory response;
bool success;
uint256 amount;
uint256 estimatedBuyAmount;
uint256 buyAmount;
uint256 sellAmount;
uint256 estimatedSellAmount;
address[] memory path = new address[](2);
uint256[] memory gas = new uint256[](2);
address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;



if(base == WBNB){
success = deposit(base, msg.value);
if(success == false){
    response = failedResponse(token,base);
    return response;
}
}else{
success = deposit(WBNB, msg.value);
if(success == false){
     response = failedResponse(token,base);
    return response;
}
success = swapBase(base);
if(success == false){
     response = failedResponse(token,base);
    return response;
}

}


success = approve(base, router);
if(success == false){
     response = failedResponse(token,base);
    return response;
}


amount = balanceOf(base);
path[0] = base;
path[1] = token;
(success,estimatedBuyAmount) = getAmountsOut(router, amount, path);
if(success == false){
    response = failedResponse(token,base);
    return response;
}
gas[0] = gasleft();
success = swap(router, amount, path);
if(success == false){
    response = failedResponse(token,base);
    return response;
}
gas[0] = gas[0] - gasleft();
buyAmount = balanceOf(token);



path[0] = token;
path[1] = base;
success = approve(token,router);
if(success == false){
     response = failedResponse(token,base);
    return response;
}
(success,estimatedSellAmount) = getAmountsOut(router, buyAmount, path);
if(success == false){
     response = failedResponse(token,base);
    return response;
}
gas[1] = gasleft();
success = swap(router,buyAmount,path);
if(success == false){
    response = failedResponse(token,base);
    return response;
}
gas[1] = gas[1] - gasleft();
sellAmount = balanceOf(base);


response = HoneyPot(
    false,
    base,
    token,
    estimatedBuyAmount,
    buyAmount,
    estimatedSellAmount,
    sellAmount,
    gas[0],
    gas[1]
);

return response;

}

function failedResponse(address token,address base)public pure returns(HoneyPot memory){
    HoneyPot memory response;
    response = HoneyPot(
        true,
        base,
        token,
        0,
        0,
        0,
        0,
        0,
        0
    
    );
    return response;
}

function deposit(address to,uint256 amount) public payable  returns(bool success) {

    assembly{
    mstore(0,hex"d0e30db0")
    let _s := call(gas(),to,amount,0,4,0,0)
    switch _s
    case 0{
    success := false
    }
    case 1{
    success := true
    }
    }
}

function balanceOf(address to) public view returns(uint256 amount){
(,bytes memory data) = to.staticcall(abi.encodeWithSignature("balanceOf(address)",address(this)));

amount = abi.decode(data,(uint256));

return amount;


}

function approve(address to,address token) public payable returns(bool success){
    uint256 approveInfinity =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;
 (success,) = to.call(abi.encodeWithSignature("approve(address,uint256)",token,approveInfinity));
if(success == false){
    return false;
}
return true;
}
function getAmountsOut(address router,uint256 amountIn,address[] memory path) public view returns(bool success, uint256 amount){

 (bool _s,bytes memory data) = router.staticcall(abi.encodeWithSignature("getAmountsOut(uint256,address[])",amountIn,path));
 if(_s == false){
     return(false,0);
 }
 (uint256[] memory amounts) = abi.decode(data,(uint256[]));

 return (true,amounts[1]);
}

function swap(address router,uint256 amountIn,address[] memory path) public payable returns(bool){
(bool success,) = router.call(abi.encodeWithSignature("swapExactTokensForTokensSupportingFeeOnTransferTokens(uint256,uint256,address[],address,uint256)",amountIn,1,path,address(this),block.timestamp + 60));
if(success == false){
    return false;
}
return true;
}

function swapBase(address token) public payable returns(bool success){
    address WBNB = 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd;
    address router = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    address[] memory path = new address[](2);
    
    path[0] = WBNB;
    path[1] = token;
    
    uint256 amountIn = balanceOf(WBNB);
   
    bool _s = approve(WBNB,router);
    if(_s == false){
        return false;
    }
    
    _s = swap(router,amountIn,path);
    if(_s == false){
    return false;
    }
    return true;

}

}