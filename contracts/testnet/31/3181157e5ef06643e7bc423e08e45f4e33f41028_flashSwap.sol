/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IERC20Joe {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IJoePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IJoeRouter02 {
    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IJoeFactory {
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

contract flashSwap{
    address private constant WAVAX = 0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7;
    address private constant pair =0x2d16af2D7f1edB4bC5DBAdF3ffF04670B4BcD0BB;
    address private constant router =0x60aE616a2155Ee3d9A68541Ba4544862310933d4;
    int256 a1;
    int256 b1;
    int256 a2;
    int256 b2;



    function sqrt(int256 n) internal pure returns (int256 res) {
        assert(n > 1);

        // The scale factor is a crude way to turn everything into integer calcs.
        // Actually do (n * 10 ^ 4) ^ (1/2)
        int256 _n = n * 10**6;
        int256 c = _n;
        res = _n;

        int256 xi;
        while (true) {
            xi = (res + c / res) / 2;
            // don't need be too precise to save gas
            if (res - xi < 1000) {
                break;
            }
            res = xi;
        }
        res = res / 10**3;
    }

    function Getprofit(address pairpool0,address pairpool1) external view returns(int256 profit,int256 amount){
        address token0 = IJoePair(pairpool0).token0();
        if (token0==WAVAX){
            (int256 a1,int256 b1,)=IJoePair(pairpool0).getReserves();
        }else{
            (int256 b1,int256 a1,)=IJoePair(pairpool0).getReserves();
        }

        address token1=IJoePair(pairpool1).token0();
        if (token1==WAVAX){
            (int256 a1,int256 b1,)=IJoePair(pairpool0).getReserves();
        }else{
            (int256 b1,int256 a1,)=IJoePair(pairpool0).getReserves();
        }
        int256 m =a2*b2/(a1*b1);
        int256 sqrtM = int256(sqrt(m));
        int256 amount = (sqrtM*b1-b2)/(1+sqrtM);
        if(amount<1000000000000000){
            profit=0;
        }else{profit=1;

        }



    }
















    function FlashSwap(address _tokenBorrow, uint256 _amount) external {
        address token0 = IJoePair(pair).token0();
        address token1 = IJoePair(pair).token1();
        uint256 amount0Out = _tokenBorrow == token0 ? _amount : 0;
        uint256 amount1Out = _tokenBorrow == token1 ? _amount : 0;
        bytes memory data = abi.encode(_tokenBorrow, _amount);

        IJoePair(pair).swap(amount0Out, amount1Out, address(this), data);
    }


    function joeCall(
        address _sender,
        uint256 _amount0,
        uint256 _amount1,
        bytes calldata _data
    ) external {
        require(_sender == address(this), "!sender");
        (address tokenBorrow, uint amount) = abi.decode(_data, (address, uint));


        address[] memory path = new address[](2);
        path[0] = WAVAX;
        path[1] = tokenBorrow;
        uint[] memory amounts = IJoeRouter02(router).getAmountsIn(amount,path);
      


        IERC20Joe(WAVAX).transfer(pair, amounts[0]);
    }
    }