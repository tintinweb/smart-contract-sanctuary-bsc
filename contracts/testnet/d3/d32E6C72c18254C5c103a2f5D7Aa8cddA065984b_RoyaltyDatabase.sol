//SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "./Ownable.sol";
import "./IERC20.sol";

contract RoyaltyDatabase is Ownable {

    address payable public immutable royaltyRecipient;
    address payable public platformRecipient;
    
    constructor(address payable royalty, address payable platform) {
        royaltyRecipient = royalty;
        platformRecipient = platform;
    }

    function setPlatformRecipient(address payable platformRecipient_) external onlyOwner {
        platformRecipient = platformRecipient_;
    }

    function withdraw() external {
        _distribute(address(0));
    }

    function withdrawToken(address token) external {
        _distribute(token);
    }

    function withdrawTokens(address[] calldata tokens) external {
        uint len = tokens.length;
        for (uint i = 0; i < len;) {
            _distribute(tokens[i]);
            unchecked {
                ++i;
            }
        }
    }

    function _distribute(address token) internal {
        if (token == address(0)) {
            _send(royaltyRecipient, address(this).balance / 10);
            _send(platformRecipient, address(this).balance);
        } else {
            uint bal = IERC20(token).balanceOf(address(this));
            uint bal0 = bal / 10;
            uint bal1 = bal - bal0;
            _sendToken(token, royaltyRecipient, bal0);
            _sendToken(token, platformRecipient, bal1);
        }
    }

    function _sendToken(address token, address to, uint amount) internal {
        uint tokenBal = IERC20(token).balanceOf(address(this));
        if (amount > tokenBal) {
            amount = tokenBal;
        }
        if (amount == 0 || to == address(0)) {
            return;
        }
        IERC20(token).transfer(to, amount);
    }

    function _send(address payable to, uint amount) internal {
        if (amount > address(this).balance) {
            amount = address(this).balance;
        }
        if (amount == 0 || to == address(0)) {
            return;
        }
        (bool s,) = to.call{value: amount}("");
        require(s, 'ETH TRNSFR FAIL');
    }

    receive() external payable {
        _distribute(address(0));
    }
}

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.14;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Ownable {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier onlyOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

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