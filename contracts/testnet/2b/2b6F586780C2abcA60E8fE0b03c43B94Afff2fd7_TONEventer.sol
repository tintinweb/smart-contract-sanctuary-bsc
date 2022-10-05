// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Ownable.sol";

library Errors {
    string constant INV_AMOUNT = "require: amount > 0";
    string constant INV_ALLOWN = "require: allowance >= amount";

    string constant INV_BALANU = "insufficient balance busd";
}

contract TONEventer is Ownable {
    IERC20 public busd;

    event SwapToTON(int8 workchain, bytes32 destination, uint256 amount);
    event SwapToERC(address destination, uint256 amount);

    constructor(address _owner, address _busd) Ownable(_owner) {
        busd = IERC20(_busd);
    }

    function swapToTON(
        int8 _workchain,
        bytes32 _account,
        uint256 _amount
    ) external {
        require(_amount > 0, Errors.INV_AMOUNT);
        require(busd.balanceOf(msg.sender) >= _amount, Errors.INV_BALANU);

        uint256 allowance = busd.allowance(msg.sender, address(this));
        require(allowance >= _amount, Errors.INV_ALLOWN);

        busd.transferFrom(msg.sender, address(this), _amount);
        emit SwapToTON(_workchain, _account, _amount);
    }

    function swapToERC(address _account, uint256 _amount) external onlyOwner {
        require(_amount > 0, Errors.INV_AMOUNT);
        require(busd.balanceOf(address(this)) >= _amount, Errors.INV_BALANU);

        busd.transfer(_account, _amount);
        emit SwapToERC(_account, _amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not owner");
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// SPDX-License-Identifier: MIT
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