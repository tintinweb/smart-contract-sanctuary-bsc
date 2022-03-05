/**
 *Submitted for verification at BscScan.com on 2022-03-04
*/

// SPDX-License-Identifier: GNU GPL-3.0-or-later
pragma solidity 0.8.10;

// Simple Owner defines a contract with single owner that cannot be changed
// this contract can receive funds and has the ability to transfer funds to the owners address only
abstract contract SimpleOwner {
    address payable immutable internal owner;

    // Only owner should be able to run functions
    modifier onlyOwner() {
        require(msg.sender == owner, "!owner");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    // withdraw all bnb in this contract to the owner address 
    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    // withdraw all of the token provided in this contract to the owner address 
    function withdrawToken(address tokenAddr) external onlyOwner{
        IERC20 token = IERC20(tokenAddr); 
        uint amount = token.balanceOf(address(this));
        token.transfer(owner, amount);
    }

    receive() external payable {}

    fallback() external payable {}
}

pragma solidity 0.8.10;

library SimplePair {
    IWBNB constant WBNB = IWBNB(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address private constant PANCAKE_FACTORY = 0x6725F303b657a9451d8BA641348b6761A6CC7a17;

    // executes a simple swap of tokens in this pair.
    // @amountIn is the amount you want to spend on the swap
    // @token is the address of one of the tokens in the pair, this token is the associated with the @amountIn
    // note: no previous checks are required, you only need to input a @amountIn that is avaliable and the token address that is in the pair
    // output amount and other calculations are handled by the function internally
    function simpleSwap(IPancakePair pair, address token, uint amountIn) internal returns (uint) {
        require(token == pair.token0() || token == pair.token1(), "!pair token");
        require(amountIn > 0, "!amountIn");

        if(token == address(WBNB)){
            depositWBNB(amountIn);
        }

        require(IERC20(token).balanceOf(address(this)) >= amountIn, "!balance");
        
        (uint reserve0, uint reserve1,) = pair.getReserves();

        (uint256 reserveA, uint256 reserveB) = 
            token == pair.token0()
            ? (reserve0, reserve1)
            : (reserve1, reserve0);

        uint amountOut = getAmountOut(amountIn, reserveA, reserveB);

        (uint256 amount0Out, uint256 amount1Out) = 
            token == pair.token0()
            ? (uint256(0), amountOut) 
            : (amountOut, uint256(0));

        IERC20(token).transfer(address(pair), amountIn); //send the input tokens to the pair contract to execute the swap
        pair.swap(amount0Out, amount1Out, address(this), new bytes(0));
        
        return amountOut;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'INSUFFICIENT_LIQUIDITY');

        (uint m, uint n) = (1000,2); //m and n are the constants in the PancakePair contract for pancakeswap pairs
        uint amountInWithFee = amountIn * (m - n);
        uint numerator = amountInWithFee * reserveOut;
        uint denominator = reserveIn * m + amountInWithFee;
        amountOut = numerator / denominator;
    }
    
    //convert enough bnb into wbnb to reach @amountIn in wbnb ( only if the current amount of wbnb is less than @amountIn )
    function depositWBNB(uint amountIn) internal {
        uint wbnbBalance = WBNB.balanceOf(address(this));
        if(wbnbBalance >= amountIn) return; //the wbnb in the contract is sufficient for the swap

        uint bnbBalance = address(this).balance;
        require(wbnbBalance + bnbBalance >= amountIn, "not enough bnb");
            
        uint differenceNeeded = amountIn - wbnbBalance; // missing amount of wbnb required for the swap
        WBNB.deposit{value:differenceNeeded}();//convert bnb to wbnb 
    }

    //checks if the @token is present in the @pair
    function isOnPair(IPancakePair pair, address token) internal view returns (bool) {
        return pair.token0() == token || pair.token1() == token;
    }

    //returns the reserves for the @token in the @pair
    function reserve(IPancakePair pair, address token) internal view returns (uint) {
        (uint reserve0, uint reserve1,) = pair.getReserves();
        return token == pair.token0() ?reserve0 : reserve1;
    }
}

pragma solidity >=0.5.0;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

pragma solidity >=0.5.0;

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

pragma solidity 0.8.10;

interface IWBNB {
    function deposit() external payable;
    function withdraw(uint value) external;
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
}

contract AutoCrypto is SimpleOwner{
    using SimplePair for IPancakePair;

    IPancakeFactory private constant PANCAKE_FACTORY = IPancakeFactory(0x6725F303b657a9451d8BA641348b6761A6CC7a17);

    //returns the address of the pair (if it exists) on pancakeswap for the provided tokens 
    function getPair(address token0, address token1) external view returns (address pair) {
        require(token0 != token1,"token0 != token1");
        pair = PANCAKE_FACTORY.getPair(token0, token1);
        require (pair != address(0), "pair not found");
    }
    
    // swaps two tokens in the provided pair
    function swap(address _pair, address inToken, uint amount) external onlyOwner returns (uint amountOut) {
        require(_pair != address(0), "!pair");
        IPancakePair pair = IPancakePair(_pair);
        require(pair.isOnPair(inToken), "!isOnPair");
        amountOut = pair.simpleSwap(inToken, amount);
    }

    function number() external pure returns(uint){
        return 1;
    }
}