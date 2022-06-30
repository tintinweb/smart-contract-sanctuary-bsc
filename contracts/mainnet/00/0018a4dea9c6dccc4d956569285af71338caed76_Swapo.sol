/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

//SPDX-License-Identifier: g
pragma solidity ^0.8.15;
library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IPair {
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
}

library Library {
    using SafeMath for uint256;

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1){
        require(tokenA != tokenB, "Library Sort: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "Library Sort: ZERO_ADDRESS");
    }
    // fetches and sorts the reserves for a pair
    function getReserves(address pairAddress, address tokenA, address tokenB) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IPair(pairAddress)
            .getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

     function getAmountsOut(uint256 amountIn,address[] memory path,address[] memory pairPath,uint256[] memory fee) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                pairPath[i],
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(
                amounts[i],
                reserveIn,
                reserveOut,
                fee[i]
            );
        }
    }
    
    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut,
        uint256 fee
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 tenThousand = 10000;
        uint256 amountInWithFee = amountIn.mul(fee);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(tenThousand).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
}

contract Swapo{
    address private owner;
    using SafeMath for uint256;
    receive() external payable {
    }

    fallback() external payable {
    }
    modifier onlyOwner() {
        require( (msg.sender == owner)||(msg.sender == address(this)), "not authorised: ");
        _;
    }
    constructor() {
        owner = msg.sender;
    }
    
    error InsufficientBalance(uint256 balanceBefore, uint256 balanceAfter);
    function swap(uint256 amountIn, address[] calldata tokenPath, address[] calldata poolPath, uint256[] calldata feePath) external onlyOwner{
        uint256 balance = IERC20(tokenPath[0]).balanceOf(address(this));
        uint256[] memory amountsOut = Library.getAmountsOut(amountIn, tokenPath, poolPath, feePath);        
        _swap(amountsOut, tokenPath, poolPath, address(this)); 
        uint256 balanceAfter = IERC20(tokenPath[0]).balanceOf(address(this));
        if(balanceAfter < balance){
            revert InsufficientBalance({
                balanceBefore: balance,
                balanceAfter: balanceAfter
            });
        }
    }
    
    function _swap(uint256[] memory amounts, address[] memory tokenPath, address[] memory poolPath, address _to) internal virtual {
        for (uint256 i =0; i < poolPath.length; i++) {
            (address input, address output) = (tokenPath[i], tokenPath[i + 1]);
            (address token0, ) = Library.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < poolPath.length - 1 ? poolPath[i + 1] : _to;
            IPair(poolPath[i]).swap(
                amount0Out,
                amount1Out,
                to,
                new bytes(0)
            );
        }
    }
    function seeOwner() external view returns(address){
        return owner;
    }
    function approval(address token, address spender) external onlyOwner returns(bool){
        IERC20(token).approve(spender, ~uint256(0));
        return true;
    }

    function checkBalances(address token) external view returns(uint256){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return balance;
    }
    function sendBackAll(address token) external onlyOwner{
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, balance);
    }
    function returnETH(address payable to) payable external onlyOwner{
        uint256 balance = address(this).balance;
        (bool sent, bytes memory data) = to.call{value: balance}("");
        require(sent, "Failed to send Ether");
    }


}