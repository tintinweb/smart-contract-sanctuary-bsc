/**
 *Submitted for verification at BscScan.com on 2022-09-17
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

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

contract MPIDO {
    IERC20  public usdtContract;
    address Coll;

    event Partner(address indexed addr);
    event PreSale(address indexed addr, uint num);
    event RefAddress(address indexed myaddr, address upperaddr);

    struct User {
        uint inviteNum;
        bool isPartner;
        bool isBuy;
    }

    mapping(address => address) public referrerAddress;
    mapping(address => User) public users;

    constructor (address usdt) {
        usdtContract = IERC20(usdt);
        Coll = 0x08314080cA738907A4f1c8f9cc6097a96047d249;
        referrerAddress[msg.sender] = 0x22A43813F74cF6Fd13DeE9c735Ff631a6B96C2aD;
    }

    function buy(uint _num) public {
        require(_num == 20e18/1000 || _num == 30e18/1000 || _num == 50e18/1000 || _num == 100e18/1000, "num error");
        require(users[msg.sender].isBuy == false, "isPlay error");

        uint one = 0;
        uint two = 0;

        if (referrerAddress[msg.sender] != address(0)) {
            one = _num * 8 / 100;
            usdtContract.transferFrom(msg.sender, referrerAddress[msg.sender], one);
            if (referrerAddress[referrerAddress[msg.sender]] != address(0)) {
                two = _num * 5 / 100;
                usdtContract.transferFrom(msg.sender, referrerAddress[referrerAddress[msg.sender]], two);
            }
        }
        usdtContract.transferFrom(msg.sender, Coll, _num - one - two);
        users[msg.sender].isBuy = true;

        emit PreSale(msg.sender, _num);
    }

    function partner() public {
        require(users[msg.sender].inviteNum >= 10, "inviteNum error");
        require(users[msg.sender].isPartner == false, "isPartner error");

        usdtContract.transferFrom(msg.sender, Coll, 1000e18/1000);
        users[msg.sender].isPartner = true;

        emit Partner(msg.sender);
    }

    function setreferrerAddress(address readdr) external {
        require(msg.sender != readdr, "error");
        require(referrerAddress[msg.sender] == address(0), "readdr is not null");
        require(referrerAddress[readdr] != address(0), "readdr is error");

        referrerAddress[msg.sender] = readdr;
        users[readdr].inviteNum += 1;

        emit RefAddress(msg.sender, readdr);
    }
}