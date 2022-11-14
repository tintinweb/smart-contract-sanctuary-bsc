/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (
                                            uint112 reserve0,
                                            uint112 reserve1,
                                            uint32 blockTimestampLast
                                            );

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
}


interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) view external returns (uint256);
    function decimals() view external returns (uint256);


}


contract LpMigration{

    address constant ROUTER_V2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;//addr pancakeRouter
    address constant OLD_CELL = 0xf3E1449DDB6b218dA2C9463D4594CEccC8934346; // addr old cell token
    address constant LP_OLD = 0x06155034f71811fe0D6568eA8bdF6EC12d04Bed2; // addr old lp token
    address constant CELL =  0xd98438889Ae7364c7E2A3540547Fad042FB24642;// addr new cell token
    address constant LP_NEW = 0x1c15f4E3fd885a34660829aE692918b4b9C1803d;// addr new lp token v2
    address WETH = IUniswapV2Router01(ROUTER_V2).WETH();
    address payable public marketingAddress = payable(0xC3b8A652e59d59A71b00808c1FB2432857080Ab8);
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner,"Caller is not owner");
        _;
    }

    function migrate(uint amountLP) external  {

        (uint token0,uint token1) = migrateLP(amountLP);
        (uint eth,uint cell, ) = IUniswapV2Router01(LP_NEW).getReserves();     

        uint resoult = cell/eth;              
        token1 = resoult * token0;

        IERC20(CELL).approve(ROUTER_V2,token1);
        IERC20(WETH).approve(ROUTER_V2,token0);

        (uint tokenA, , ) = IUniswapV2Router01(ROUTER_V2).addLiquidity(
            WETH,
            CELL,
            token0,
            token1,
            0,
            0,
            msg.sender,
            block.timestamp + 5000
        );

        uint balanceOldToken = IERC20(OLD_CELL).balanceOf(address(this));
        IERC20(OLD_CELL).transfer(marketingAddress,balanceOldToken);

        if (tokenA < token0) {
            uint256 refund0 = token0 - tokenA;
            IERC20(WETH).transfer(msg.sender,refund0);

        }

     }


    function migrateLP(uint amountLP) internal returns(uint256 token0,uint256 token1) {

        IERC20(LP_OLD).transferFrom(msg.sender,address(this),amountLP);
        IERC20(LP_OLD).approve(ROUTER_V2,amountLP);

        return IUniswapV2Router01(ROUTER_V2).removeLiquidity(
            WETH,
            OLD_CELL,
            amountLP,
            0,
            0,
            address(this),
            block.timestamp + 5000
        );

    }

    function withdrawCELL() external onlyOwner {

        uint balance = IERC20(CELL).balanceOf(address(this));
        IERC20(CELL).transfer(msg.sender,balance);
    }

    function withdraw(address tokenAddr, uint _amount) external onlyOwner {
        require(tokenAddr != address(0),"Error zero address");
        
        IERC20(tokenAddr).transfer(msg.sender,_amount);
    }

}