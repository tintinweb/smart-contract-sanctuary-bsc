/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-11-26
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-29
*/

//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;



interface IERC20 {

    function totalSupply() external view returns (uint256);
    
    function symbol() external view returns(string memory);
    
    function name() external view returns(string memory);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
    
    /**
     * @dev Returns the number of decimal places
     */
    function decimals() external view returns (uint8);

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


contract Airdrop {

    mapping(address => bool) public admins;

    modifier isAdmin() {
        require(admins[msg.sender], "Caller is not admin");
        _;
    }

    constructor() {
        admins[msg.sender] = true;
    }

    function addAdmin(address _admin) public isAdmin {
        admins[_admin] = true;
    }

    function removeAdmin(address _admin) public isAdmin {
        admins[_admin] = false;
    }

    function drop(address token, address[] calldata users, uint256[] calldata amounts) external isAdmin {
        uint256 len = users.length;
        require(
            len == amounts.length,
            'Invalid Lengths'
        );
        for (uint i = 0; i < len;) {
            require(
                IERC20(token).transfer(users[i], amounts[i]),
                'Failure On Transfer'
            );
            unchecked { ++i; }
        }
    }

    function withdraw(address token) external isAdmin {
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }

    function withdrawBNB() external isAdmin {
        (bool s,) = payable(msg.sender).call{value: address(this).balance}("");
        require(s);
    }
}