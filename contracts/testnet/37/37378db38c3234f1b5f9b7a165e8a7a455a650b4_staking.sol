/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

// File: contracts/IERC20.sol


pragma solidity >=0.4.22 <0.8.19;

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
// File: contracts/Staking.sol


pragma solidity 0.8.17;

/*
    This contract acts a staking
    contract for 
*/

contract staking {
    IERC20 TOKEN;
    mapping(address => uint256) public _amount;
    mapping(address => bool) private _isStaked;
    uint256 public stakers;
    uint256 public totalStaked;

    constructor (address _token) {
        TOKEN = IERC20(_token);
        //verify the token address is real
        require(TOKEN.balanceOf(address(this)) >= 0, "Invalid token address");
    }

    //This functions help stake tokens
    function stakeToken(uint256 amount) external returns (bool) {
        require(TOKEN.balanceOf(msg.sender) >= amount, "Insufficient amount");
        //lock tokens to contract
        _amount[msg.sender] = _amount[msg.sender] + amount;
        totalStaked = totalStaked + amount;
        //add as number of stakers
        if(!_isStaked[msg.sender]){
            stakers = stakers + 1;
            _isStaked[msg.sender] = true;
        }
        TOKEN.transferFrom(msg.sender, address(this), amount);
        return true;
    }

    //This functions help stake tokens
    function unstake(uint256 amount) external returns (bool) {
        require(_amount[msg.sender] >= amount, "Insufficient staked amount");
        require(TOKEN.balanceOf(address(this)) >= amount, "Insufficient staked amount");
        //lock tokens to contract
        _amount[msg.sender] = _amount[msg.sender] - amount;
        totalStaked = totalStaked - amount;
        //remove as stakers
        if(_amount[msg.sender] <= 0){
            stakers = stakers - 1;
            _isStaked[msg.sender] = false;
        }
        TOKEN.transfer(msg.sender, amount);
        return true;
    }

    

}