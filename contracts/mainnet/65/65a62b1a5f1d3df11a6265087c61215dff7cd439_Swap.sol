/**
 *Submitted for verification at BscScan.com on 2022-12-24
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

// File: contracts/Swap.sol


pragma solidity ^0.8.4;


interface MarsSwap{
    function swapExactTokensForTokens(uint256 amountIn,uint256 amountOutMin,address[] calldata path,address to,uint256 deadline) external returns (uint256[] memory amounts);
}

contract Swap {
    address payable public immutable  OWNER;
    address public immutable  CALLER;
    MarsSwap private constant MARS_SWAP = MarsSwap(0xb68825C810E67D4e444ad5B9DeB55BA56A66e72D);
    IERC20 private constant usdm = IERC20(0xBb0fA2fBE9b37444f5D1dBD22e0e5bdD2afbbE85);
    IERC20 private constant busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    constructor(address payable _owner){
        OWNER = _owner;
        CALLER = msg.sender;
    }

    function withdrawal() external{
        require(msg.sender == OWNER,"Permission denied");
        usdm.transfer(OWNER,usdm.balanceOf(OWNER));
        busd.transfer(OWNER,busd.balanceOf(OWNER));
    }

    function swap(uint256 amountIn,uint256 amountOutMin,address[] calldata path, uint256 deadline) external{
        require(msg.sender == CALLER,"Permission denied");
        require(path[1] == address(busd),"error");
        MARS_SWAP.swapExactTokensForTokens(amountIn, amountOutMin ,path ,address(this) ,deadline);
    }

    function destructContract() public payable {
        require(msg.sender == OWNER,"Permission denied");
        selfdestruct(OWNER);
    }
}