// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Events {
  event BuyTokens (address buyer, uint amount);
  event RevertTokens (address owner, uint amount);
  event ReturnStuckTokens (address owner, address token);
  event TransferBalance (address owner, uint amount);
  event SwitchOnOff (bool online);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.17;

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

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./IERC20.sol";
import "./Events.sol";

contract TrappaICO is Events {
    IERC20 public token;
    uint256 public price;
    address public owner;
    bool public online;

    constructor(address _token, uint256 _price) {
        token = IERC20(_token);
        price = _price; //1500000000000000 // 1BNB = 666
        owner = msg.sender;
        online = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not an owner");
        _;
    }

    receive() external payable {
        require(online, "Error: ICO is offline");

        uint256 amount = msg.value / price;

        require(amount > 0, "Error: Token amount must be greater than 0");

        require(
            token.balanceOf(address(this)) >= amount,
            "Error: Try to buy less tokens"
        );

        uint256 _amount = amount * 10**18;

        emit BuyTokens(msg.sender, _amount);
        bool callback = token.transfer(msg.sender, _amount);

        inspector(callback);
    }

    function inspector(bool result) internal pure returns (bool) {
        if (!result) {
            revert("Error: Transfer Error");
        } else {
            return true;
        }
    }

    function transferBalance() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Error: BNB amount must be greater than 0");
        emit TransferBalance(owner, balance);
        payable(owner).transfer(balance);
    }

    function revertTokens() external onlyOwner {
        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "Error: Token amount must be greater than 0");
        emit RevertTokens(owner, amount);
        token.transfer(owner, amount);
    }

    function switchOnOff() external onlyOwner {
        if (!online) {
            online = true;
        } else {
            online = false;
        }

        emit SwitchOnOff(online);
    }

    function returnStuckTokens(address stuckToken) external onlyOwner {
        require(
            stuckToken != address(token),
            "Error: You can't to withdraw a main token"
        );

        emit ReturnStuckTokens(owner, stuckToken);

        IERC20 _stuckToken = IERC20(stuckToken);

        uint256 amount = _stuckToken.balanceOf(address(this));

        require(amount > 0, "Error: Token amount must be greater than 0");

        bool callback = _stuckToken.transfer(owner, amount);
        inspector(callback);
    }
}