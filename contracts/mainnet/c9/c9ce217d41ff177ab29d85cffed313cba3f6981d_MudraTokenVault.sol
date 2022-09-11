/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

/**
 *Submitted for verification at BscScan.com on 2021-05-04
*/

// File @openzeppelin/contracts/token/ERC20/[email protected]


pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
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


// File contracts/MudraTokenVault.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

contract MudraTokenVault {

    //pack data in one word to save gas
    struct Data {
        address factory;
        address token;
        address owner;
        uint8 status;
    }

    Data public data;

    function init(address _token, address _owner) external returns (bool) {
        require(data.status == 0, "ALREADY INIT");
        data.factory = msg.sender;
        data.owner = _owner;
        data.status = 1;
        data.token = _token;
        IERC20(_token).approve(data.factory, uint256(-1));
        return true;
    }

    function destruct(address payable _receiver) external {
        require(msg.sender == data.factory, "ONLY FACTORY");
        selfdestruct(_receiver);
    }

    function claimBEP20Token(address bep20Token, address lockOwner, uint256 tokenAmount) public {
        require(msg.sender == data.factory || msg.sender == data.owner, "ONLY FACTORY or OWNER");
        // do not allow recovering lock token
        require(bep20Token != data.token, "Locked token withdraw");

        IERC20(bep20Token).transfer(lockOwner, tokenAmount);
    }

    function claimBEP20TokenAll(address bep20Token, address lockOwner) public {
        claimBEP20Token(bep20Token, lockOwner, IERC20(bep20Token).balanceOf(address(this)));
    }

    function claimBNB(address payable lockOwner, uint256 amount) public {
        require(msg.sender == data.factory || msg.sender == data.owner, "ONLY FACTORY or OWNER");
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = lockOwner.call{ value: amount }("");
        require(success, "Unable to send BNB");
    }

    function claimBNBAll(address payable lockOwner) public {
        claimBNB(lockOwner, address(this).balance);
    }

    function setOwner(address _owner) public {
        require(_owner != address(0), "ZERO NEW OWNER");
        require(msg.sender == data.factory || msg.sender == data.owner, "ONLY FACTORY or OWNER");
        data.owner = _owner;
    }

    receive() external payable {}
}