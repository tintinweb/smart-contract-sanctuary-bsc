/**
 *Submitted for verification at BscScan.com on 2022-11-15
*/

//SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

contract Distributor {

    address public owner;
    address public constant usdt = 0x55d398326f99059fF775485246999027B3197955;
    address[] public nodes;
    mapping(address => bool) public isBlclist;
    mapping(address => bool) public isExist;
    
    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner call");
        _;
    }

    function changeOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function exactTokensOfThis(uint amount) external onlyOwner {
        require(IERC20(usdt).balanceOf(address(this)) >= amount, "unsufficient tokens");
        IERC20(usdt).transfer(msg.sender, amount);
    }

    function viewAountOfThis() external view onlyOwner returns (uint) {
        return IERC20(usdt).balanceOf(address(this));
    }

    function distribute(uint amount) external onlyOwner {
        require(IERC20(usdt).balanceOf(address(this)) >= amount, "unsufficient tokens");
        address cur;
        uint reward = amount / nodes.length;
        for (uint8 i = 0; i < nodes.length; i++) { 
            cur = nodes[i];
            if (isBlclist[cur]) continue;
            IERC20(usdt).transfer(cur, reward);
        } 
    }

    function addAccounts(address[] memory accounts) external onlyOwner {
        require(accounts.length <= 200, "exceed max amount");
        address cur;
        for (uint8 i = 0; i < accounts.length; i++) {
            cur = accounts[i]; 
            if (!isExist[cur]) {
                isExist[cur] = true;
                nodes.push(cur);
            }
        }
    }

    function setBlclist(address amount, bool flag) external onlyOwner {
        isBlclist[amount] = flag;
    }
}