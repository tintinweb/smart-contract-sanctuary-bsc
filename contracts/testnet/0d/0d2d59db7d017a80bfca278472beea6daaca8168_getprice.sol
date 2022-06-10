/**
 *Submitted for verification at BscScan.com on 2022-06-09
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;



interface IBEP20 
{
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


  interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}


contract getprice
{

    IPancakePair bnbbusdlp;
    IPancakePair whetobnblp;

    constructor (IPancakePair _bnbtobusd ,IPancakePair _whetobnblp)
    {
        bnbbusdlp = _bnbtobusd;
        whetobnblp = _whetobnblp;


    }

    function BnbtoBusd() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  bnbbusdlp.getReserves();

       uint256 z = (a*1e18)/b;
       return z;
    }

        function BUSDtobnb() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  bnbbusdlp.getReserves();
       uint256 z = (b*1e18)/a;
       return z;
    }
    


        function whetobnb() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  whetobnblp.getReserves();
       uint256 z = (a*1e18)/b;
       return z;
    }

        function bnbtowhe() public view returns(uint256 )
    {
       (uint256 a,uint256 b,uint256 c) =  whetobnblp.getReserves();

       uint256 z = (b*1e18)/a;
       return z;
    }

}

// WBNBLP 0xe0e92035077c39594793e61802a350347c320cf2
// WHLP 0x059ed4400111C562fB9Dcc20103e0C50D5a0d249