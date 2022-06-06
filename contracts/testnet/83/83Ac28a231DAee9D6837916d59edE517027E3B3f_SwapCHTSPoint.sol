/**
 *Submitted for verification at BscScan.com on 2022-06-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-04
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-25
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-08
 */

/**
 *Submitted for verification at BscScan.com on 2022-03-02
 */

/**
 *Submitted for verification at BscScan.com on 2022-02-21
 */

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.1;

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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract SwapCHTSPoint {
    string public name = "Swap CHTS Point";
    address public owner;
    address public mainToken;
    address public treasuryAddress;
    uint256 public nonce;
    bool public paused;

    event Withdraw(address user, address token, uint256 amount);
    event Deposit(address user, address token, uint256 amount);
    
    constructor(address _treasuryAddress, address _mainToken) {
        owner = msg.sender;
        treasuryAddress = _treasuryAddress;
        mainToken = _mainToken;
        paused = false;
    }

    // Update status package
    function setPause(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        require(_treasuryAddress != address(0), "Address cant be zero");
        treasuryAddress = _treasuryAddress;
    }

    function verifyMessage(
        uint256 _value, 
        address _sender, 
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    ) public returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        bytes32 hashedMessage = keccak256(abi.encode(_value, _sender, nonce++));
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, hashedMessage));

        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);

        return signer == owner;
    }

    function withdrawPermit(
        uint256 _amount, 
        address _address, 
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    )
        public
        whenNotPaused
    {
        require(_amount >= 1 ether, "Minimun 1 ether");
        require(verifyMessage(_amount, _address, _v, _r, _s), "Not Accepted");
        require(!paused, "Event end");

        // Transfer token
        IERC20(mainToken).transferFrom(treasuryAddress, _address, _amount);

        emit Withdraw(msg.sender, mainToken, _amount);
    }

    function buyPoint(uint256 amount) payable external {
        require(IERC20(mainToken).balanceOf(msg.sender) >= amount, "Not enough balance");
        require(amount >= 1 ether, "Minimun 1 ether");

        IERC20(mainToken).transferFrom(msg.sender, treasuryAddress, amount);

        emit Deposit(msg.sender, mainToken, amount);
    }

    modifier whenNotPaused() {
        require(!paused, "Paused!");
        _;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the owner of contract can call this function"
        );
        _;
    }

}