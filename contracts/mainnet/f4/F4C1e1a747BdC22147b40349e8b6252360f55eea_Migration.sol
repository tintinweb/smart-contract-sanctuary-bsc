//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
import "./IERC20.sol";

contract Migration {

    mapping ( address => uint256 ) public recipients;
    mapping ( address => uint256 ) public migrators;
    address[] allMigrators;
    address[] allRecipients;
    address useless = 0x2cd2664Ce5639e46c6a3125257361e01d0213657;    
    address caller  = 0x091dD81C8B9347b30f1A4d5a88F92d6F2A42b059;
    event Migrate(address sender, address recipient, uint256 amount);

    function migrate(uint amount, address recipient) external {
        require(
            amount > 0 && recipient != address(0),
            'Invalid Arguments'
        );

        bool s = IERC20(useless).transferFrom(msg.sender, address(this), amount);
        require(s, 'Approval Not Given');

        if (migrators[msg.sender] == 0) {
            allMigrators.push(msg.sender);
        }
        if (recipients[recipient] == 0) {
            allRecipients.push(recipient);
        }

        migrators[msg.sender] += amount;
        recipients[recipient] += amount;

        emit Migrate(msg.sender, recipient, amount);
    }
    function getAllMigrators() external view returns (address[] memory) {
        return allMigrators;
    }
    function getAllRecipients() external view returns (address[] memory) {
        return allRecipients;
    } 
    function withdraw(uint amount) external {
        require(msg.sender == caller);
        _withdraw(amount);
    }
    function withdraw() external {
        require(msg.sender == caller);
        _withdraw(IERC20(useless).balanceOf(address(this)));
    }
    function _withdraw(uint amount) internal {
        IERC20(useless).transfer(caller, amount);
    }
}

//SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

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