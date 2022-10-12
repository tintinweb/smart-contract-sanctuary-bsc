/**
 *Submitted for verification at BscScan.com on 2022-10-12
*/

// SPDX-License-Identifier: MIT
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

// File: contracts/shibbv2Swap.sol



pragma solidity ^0.8.13;


contract DSwap {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;

    uint fee = 0.0037 ether;
    address payable feeCollector = payable(0x4Af08Dcf38614C475ADc2f97a3998af7C5421a5e);

    uint public totalSupply;
    mapping (address => uint) public balanceOf;

    constructor ( address _token0, address _token1){
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

   function _burn(address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _update(uint _res0, uint _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    function swap(address _tokenIn, uint _amountIn) external payable returns (uint amountOut) {
        require(_tokenIn == address(token0) , "Invalid Token");
         
        //gas reduction 
        //transfer token in
        
        uint amountIn;

        if (_tokenIn == address(token0)) {
            token0.transferFrom(msg.sender, address(this),_amountIn);
            amountIn = token0.balanceOf(address(this)) - reserve0;
            require(msg.value >= fee);
            feeCollector.transfer(fee);
        }

        //calculate amount out including fees
        //dx= dy
        //10 shibb -> 1 shibbv2 
        amountOut = (amountIn * 100)/1000;
        //uopdate reserve0 and reserve1
        if (_tokenIn == address(token0)) {
            _update(reserve0 + _amountIn, reserve1 - amountOut);
        } 


        //transfer token out
        if (_tokenIn == address(token0)) {
            token1.transfer(msg.sender, amountOut);
        } 
    }


 function addLiquidity( uint _amount0, uint _amount1) external returns(uint shares) {
        //transfering tokens to contract
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        //checking balances
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));
        
        //total supply that came in
        uint d0 = bal0 - reserve0;
        uint d1 = bal1 - reserve1;

        /*
        a = amount in
        L = total liquidity
        s = shares to mint
        T = total supply

        ( L + a )/ L = (T + s) / T

        s = a * T / L
        */
        
        if (totalSupply == 0) {
            shares = d0 + d1;
        } else  {
            shares = ((d0 + d1) * totalSupply) / (reserve0 + reserve1);
        }

       // require(shares > 0, "shares are 0");
       // _mint(msg.sender, shares);

        _update(bal0, bal1);
    }

    function removeLiquidity(uint _shares) external returns ( uint d0, uint d1){
          /*
        a = amount in
        L = total liquidity
        s = shares to mint
        T = total supply

        a/ L = s / T

        a = L * s / T
        */
        d0 = (reserve0 * _shares ) / totalSupply;
        d1 = (reserve1 * _shares ) / totalSupply;

        _burn(msg.sender, _shares);
        _update(reserve0 - d0, reserve1 - d1);

        //transfering tokens
        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }

        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
    }
}