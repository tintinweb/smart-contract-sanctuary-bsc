/**
 *Submitted for verification at BscScan.com on 2022-11-17
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);

}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint value) external returns (bool);
    function withdraw(uint) external;
}

interface IUniswapV2Router02{
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
}

interface IPair {
function getReserves (  ) external view returns ( uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
function swap ( uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data ) external;
}


contract Front_Bot{
    address internal immutable Router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address internal immutable WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    
    
    // transfer(address,uint256)
    bytes4 internal constant ERC20_TRANSFER_ID = 0xa9059cbb;

    // swap(uint256,uint256,address,bytes)
    bytes4 internal constant PAIR_SWAP_ID = 0x022c0d9f;
    
    address payable public owner;
    
    constructor()  payable {
        owner = payable(msg.sender);
    }

    function buyTK(uint8 _flag, uint128 _amount, uint128 _amountOut, address _pair, address BNB) external {
        (uint112 TKRes, uint112 BNBRes) = getReserves(_pair, _flag);
        uint _FnnAmt = getAmountOut(_amount, BNBRes, TKRes);
        assembly{
            if eq(lt(_FnnAmt, _amountOut), 1){
                revert(3,3)
            }

            mstore(0x7c, ERC20_TRANSFER_ID)
            // destination
            mstore(0x80, _pair)
            // amount
            mstore(0xa0, _amount)

            let s1 := call(sub(gas(), 5000), BNB, 0, 0x7c, 0x44, 0, 0)
            if iszero(s1) {
                // WGMI
                revert(3, 3)
            
        }

        // swap function signature
        mstore(0x7c, PAIR_SWAP_ID)
        // tokenOutNo == 0 ? ....
        switch _flag
        case 0 {
            mstore(0x80, _FnnAmt)
            mstore(0xa0, 0)
        }
        case 1 {
            mstore(0x80, 0)
            mstore(0xa0, _FnnAmt)
        }
        // address(this)
        mstore(0xc0, address())
        // empty bytes
        mstore(0xe0, 0x80)

        let s2 := call(sub(gas(), 5000), _pair, 0, 0x7c, 0xa4, 0, 0)
        if iszero(s2) {
            revert(3, 3)
        }

    }
    
    }

    function callGetReserves(address _pair, uint _flag) external view returns(uint112 TKRes, uint112 BNBRes ){
        (TKRes, BNBRes) = getReserves(_pair, _flag);    
    }
    
    function getReserves(address _pair, uint _flag) internal view returns(uint112 TKRes, uint112 BNBRes ){
        if (_flag == 0){
            (TKRes, BNBRes, ) = IPair(_pair).getReserves();
        }else{
            (BNBRes, TKRes, ) = IPair(_pair).getReserves();
        }
    }

    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal  pure returns (uint amountOut) {
        uint amountInWithFee = amountIn * 9975; 
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = (reserveIn * 10000) + amountInWithFee;
        amountOut = numerator / denominator;
    }


    function sellTk(uint8 _flag, address _pair, address _token) external {
        (uint tkres, uint BNBRes) = getReserves(_pair, _flag);
        uint amtTk = IERC20(_token).balanceOf(address(this));
        uint BNBOut = getAmountOut(amtTk, tkres, BNBRes);
        IERC20(_token).transfer(_pair, amtTk);
        (uint amount0Out, uint amount1Out) = _flag == 1 ? (BNBOut, uint(0)):(uint(0), BNBOut);
        IPair(_pair).swap(amount0Out, amount1Out, address(this), new bytes(0));
    }

    receive() external payable {
        if(msg.sender != WBNB){
            IWETH(WBNB).deposit{value:msg.value}();
        }  
    }
    
   

    function withdraw(address _token) external {
        require(msg.sender == owner, "Only Owner");
        uint amt = IERC20(_token).balanceOf(address(this));
        require(amt > 0, "No Token");
        IERC20(_token).transfer(owner, amt);
    }

    function withdrawEth(uint _amount, address _to) external {
        require(msg.sender == owner);
        address BNB = WBNB;
        require(msg.sender == owner, "Only Owner can withdraw BNB");
        IWETH(BNB).withdraw(_amount);
        payable(_to).transfer(_amount);
    }
    
}