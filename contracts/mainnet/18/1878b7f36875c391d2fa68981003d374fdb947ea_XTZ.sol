/**
 *Submitted for verification at BscScan.com on 2023-02-08
*/

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IPancakePair {
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

}
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}




interface IERC20 {

    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}



contract XTZ {
    using SafeMath for uint;
    address private constant WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address admin;

    function addBalance() external payable {}
    constructor(){
        admin = address(msg.sender);
    }

    function getBalance(address token) external view returns(uint){
        return IERC20(token).balanceOf(address(this));
    }

    
    function withdrow() external {
        payable(msg.sender).transfer(address(this).balance);
    }


    function withdrow_wbnb(uint value) external {
        IERC20(WETH).transferFrom(msg.sender, address(this), value);
    }

    function return_tokens(address token) external {
        IERC20(token).transferFrom(address(this),msg.sender,IERC20(token).balanceOf(address(this)));
    }


    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        uint amountInWithFee = amountIn.mul(9975);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;    
    }




    function a1_swap_x0(address to, uint amountIn, bool wbnb_first, uint expectedAmount) external {
        (uint112 r0, uint112 r1,) =  IPancakePair(to).getReserves();
        //TOKEN - WBNB
        if (wbnb_first == false){
            uint amountOut = getAmountOut(amountIn,r1,r0);
            require(amountOut >= expectedAmount, "swap first expected > real");
    
            IERC20(WETH).transfer(to,amountIn);
            IPancakePair(to).swap(amountOut,0,address(this),new bytes(0));
        }
        //WBNB - TOKEN
        else {
            uint amountOut = getAmountOut(amountIn,r0,r1);
            require(amountOut >= expectedAmount, "swap first expected > real");

            IERC20(WETH).transfer(to,amountIn);
            IPancakePair(to).swap(0,amountOut,address(this),new bytes(0));
        }
    }
    function b1_swap_x0(address token, address pair, bool wbnb_first, uint expectedAmount) external {
        uint amountIn = IERC20(token).balanceOf(address(this));


        if (wbnb_first == false){
            require(amountIn > 0, "zero amount of token");
            (uint112 r0, uint112 r1,) =  IPancakePair(pair).getReserves();
            uint amountOut = getAmountOut(amountIn,r0,r1);
            require(amountOut >= expectedAmount, "swap second expected > real");

            IERC20(token).transfer(pair,amountIn);
            IPancakePair(pair).swap(0,amountOut,address(this),new bytes(0));

        }
        else{
            require(amountIn > 0, "zero amount of token");
            (uint112 r0, uint112 r1,) =  IPancakePair(pair).getReserves();
            uint amountOut = getAmountOut(amountIn,r1,r0);
            require(amountOut >= expectedAmount, "swap second expected > real");
            
            IERC20(token).transfer(pair,amountIn);
            IPancakePair(pair).swap(amountOut,0,address(this),new bytes(0));
        }
    }


}