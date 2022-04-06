/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^ 0.8.0;

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

contract AdvancedTimeLock {
    //struct for timelock
    struct mytimelock {
        uint  end;
        address  token;
        uint  balance;
        uint  duration;
    }

    mapping(address => mytimelock[]) public timelocks;
    
    function createTimeLock(address payable owner, address _token, uint _amount, uint _duration) external {
        require(_duration > 0, 'duration must be greater than 0');
        require(_amount > 0, 'amount must be greater than 0');
        timelocks[owner].push(
            mytimelock(block.timestamp + _duration, _token, _amount, _duration)
            );
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

    }

    function getTimeLock(address owner, uint index) external view returns ( uint, address, uint) {
        require(index < timelocks[owner].length, 'index out of bounds');
        return (timelocks[owner][index].end, timelocks[owner][index].token, timelocks[owner][index].balance);
    }


    receive() external payable { }

    function withdrawByToken(address payable owner, address token, uint amount) public {
        require(timelocks[owner].length > 0, 'no timelocks');
        mytimelock[] memory timelock = timelocks[owner];
        bool found = false;
        for(uint i = 0; i < timelocks[owner].length; i++) {
            if (timelock[i].token == token && 
                timelock[i].balance == amount ) {
                    found = true;
                    this.withdraw(owner, i);
            }
        }
        require(found, 'no timelock found');

    }

    function withdraw(address payable owner, uint index) public {
        require(block.timestamp >= timelocks[owner][index].end, 'too early');
        if (timelocks[owner][index].token == address(0)) {
            owner.transfer(timelocks[owner][index].balance);
        } else {
            IERC20(timelocks[owner][index].token).transfer(owner, timelocks[owner][index].balance);
        }
        if(timelocks[owner].length == 1) {
            timelocks[owner].pop();
        } else {
            timelocks[owner][index] = timelocks[owner][timelocks[owner].length - 1];
            timelocks[owner].pop();
        }
    }

}