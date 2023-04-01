/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// File: contracts/DigitalSelfSwapFactory.sol


pragma solidity ^0.8.0;

// Interface for the ERC20 token standard
interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

// Main factory contract for the DigitalSelfSwap DEX
contract DigitalSelfSwap {
    mapping(address => mapping(address => uint256)) public tokens;
    mapping(address => mapping(address => bool)) public pairs;

    // Create a new token pair on the DEX
    function createPair(address tokenA, address tokenB) external {
        require(tokenA != tokenB, "DigitalSelfSwap: Cannot create pair with identical tokens");
        require(tokens[tokenA][tokenB] == 0, "DigitalSelfSwap: Pair already exists");

        pairs[tokenA][tokenB] = true;
        pairs[tokenB][tokenA] = true;
    }

    // Add liquidity to an existing token pair
    function addLiquidity(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external {
        require(pairs[tokenA][tokenB], "DigitalSelfSwap: Pair does not exist");
        require(amountA > 0 && amountB > 0, "DigitalSelfSwap: Liquidity cannot be zero");

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        tokens[tokenA][tokenB] += amountA;
        tokens[tokenB][tokenA] += amountB;
    }

    // Swap tokens on an existing token pair
    function swapTokens(address tokenA, address tokenB, uint256 amountA) external {
        require(pairs[tokenA][tokenB], "DigitalSelfSwap: Pair does not exist");
        require(tokens[tokenA][tokenB] > 0, "DigitalSelfSwap: Liquidity is zero");

        uint256 amountB = (tokens[tokenB][tokenA] * amountA) / tokens[tokenA][tokenB];
        require(amountB > 0, "DigitalSelfSwap: Insufficient liquidity");

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);

        // Call the getAddressOfToken function from the contract itself
        address tokenBAddress = getAddressOfToken(tokenB);
        (bool success, ) = tokenBAddress.call(abi.encodeWithSelector(bytes4(keccak256(bytes("transfer(address,uint256)"))), msg.sender, amountB));
        require(success, "Transfer failed");

        tokens[tokenA][tokenB] -= amountA;
        tokens[tokenB][tokenA] += amountB;
    }

    // Get the address of the ERC20 token contract
    function getAddressOfToken(address token) public pure returns (address) {
        return address(uint160(token));
    }

}