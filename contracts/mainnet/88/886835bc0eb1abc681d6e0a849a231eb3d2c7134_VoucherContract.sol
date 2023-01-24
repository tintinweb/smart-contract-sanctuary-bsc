/**
 *Submitted for verification at BscScan.com on 2023-01-24
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol


pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// File: Voucher_Manager (2).sol


pragma solidity ^0.8.17;



interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

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
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeRouter02 is IPancakeRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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
}

contract VoucherContract {

    // Mapping of voucher codes to voucher values
    mapping (string => uint) public vouchers;

    // The address of the contract owner
    address public owner;

    constructor() public {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(
            0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
        );
    }

    function changeOwner(address _owner) public {
        // Check if the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can create vouchers.");
        
        // Changes owner to the new owner
        owner = _owner;
    }

    // Function to create a new voucher
    function createVoucher(string memory code, uint value) public {
        // Check if the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can create vouchers.");

        // Set the value for the given voucher code
        vouchers[code] = value;
    }

    // Mainnet: 0x10ED43C718714eb63d5aA57B78B54704E256024E
    // Testnet: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1
    IPancakeRouter02 public _router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    AggregatorV3Interface internal priceFeed;

    // Function for the end-user to redeem a voucher
    function redeemVoucher(string memory code) public {
        // 0xd6dA6491A6663B1d413715f4fD8eDD74a4b47694

        // Check if the voucher code exists
        require(vouchers[code] > 0, "Invalid voucher code.");

        // Transfer the voucher value to the caller
        IERC20 erc20 = IERC20(0xd6dA6491A6663B1d413715f4fD8eDD74a4b47694);
        uint amount = usdToTokens(vouchers[code]);

        // Remove the voucher code from the mapping to prevent it from being used again
        vouchers[code] = 0;

        require(erc20.balanceOf(address(this)) >= amount, "Contract has insufficient token balance.");

        // Transfer the voucher value to the caller
        require(erc20.transfer(msg.sender, uint256(amount)), "Transfer failed.");
    }

    function getVoucherValue(string memory code) public view returns(uint256) {
        return uint256(usdToTokens(vouchers[code]));
    }

    function getLatestPrice() public view returns (int) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return price / 10**8;
    }

    function usdToBNB(uint _usd) public view returns(uint) {
        return _usd*10**18 / uint(getLatestPrice());
    }

    function bnbToTokens(uint _bnb) public view returns(uint[] memory) {
        address[] memory path = new address[](2);
        path[0] = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        path[1] = address(0xd6dA6491A6663B1d413715f4fD8eDD74a4b47694);
        return _router.getAmountsOut(_bnb, path);
    }

    function usdToTokens(uint _usd) public view returns(uint) {
        uint _bnb = usdToBNB(_usd);
        uint _tokens = bnbToTokens(_bnb)[1];
        return _tokens;
    }

    function withdrawEther(uint amount) public {
        // Check if the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can withdraw ether.");

        // Check if the contract has enough ether to withdraw
        require(address(this).balance >= amount, "Contract has insufficient ether balance.");

        // Withdraw the ether
        payable(owner).transfer(amount);
    }

    function withdrawToken(address tokenContract, uint256 amount) public {
        // Check if the caller is the contract owner
        require(msg.sender == owner, "Only the contract owner can withdraw tokens.");

        // Check if the contract has enough tokens to withdraw
        IERC20 erc20 = IERC20(tokenContract);
        require(erc20.balanceOf(address(this)) >= amount, "Contract has insufficient token balance.");

        // Withdraw the tokens
        erc20.transfer(owner, amount);
    }
    
    receive() external payable {}
}