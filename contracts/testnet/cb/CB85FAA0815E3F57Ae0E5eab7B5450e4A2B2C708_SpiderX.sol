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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SpiderX {

    IERC20 token;

    address private owner;

    address private admin;

    mapping (string => uint) public prices;

    mapping (address => uint) public balances;

    mapping (string => uint) private rooms;


    modifier OnlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin, "not an admin!");
        _;
    }

    event Deposit(address indexed player, uint indexed amount);

    event Withdraw(address indexed player, uint indexed amount);

    event CreateRoom(string indexed roomId, address[] indexed players, uint indexed amount);

    event CancelGame(string indexed roomId);

    event Payment(string indexed roomId, address indexed winner, uint indexed amount);

    event NicknameChange(address indexed player);

    event AvatarChange(address indexed player);

    event PayMessage(address indexed player);

    event Delegate(address indexed admin, address indexed newAdmin);

    event NewPrice(string indexed service, uint newPrice);

    constructor() {
        token = IERC20(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7);
        owner = msg.sender;
        admin = 0xA9485322f292196B5c270318eE3a093Cb86dA2DF;
        prices["nickname"] = 1000000000000000000;
        prices["avatar"] = 1000000000000000000;
        prices["message"] = 1000000000000000000;
        prices["commission"] = 1;
    }

    function deposit(uint amount, address user) public OnlyAdmin {
        balances[user] += amount;
        emit Deposit(user, amount);
    }

    function withdraw(uint amount) public {
        require(amount <= balances[msg.sender], "insufficient funds!");
        balances[msg.sender] -= amount;
        uint commission = amount*prices["commission"]/100;
        balances[admin] += commission;
        token.transfer(msg.sender, amount - commission);
        emit Withdraw(msg.sender, amount - commission);
    }

    function createRoom(string memory roomId, address[] memory players, uint amount) external OnlyAdmin {
        for (uint i = 0; i < players.length; i++){
            require(amount <= balances[players[i]], "insufficient funds!");
            balances[players[i]] -= amount;
            rooms[roomId] += amount;
        }
        emit CreateRoom (roomId, players, rooms[roomId]);
    }

    function gameResult(string memory roomId, address winner) external OnlyAdmin {
        uint amount = rooms[roomId];
        balances[winner] += amount;
        rooms[roomId] -= amount;
        emit Payment (roomId, winner, amount);
    }

    function gameCancellation(string memory roomId) external OnlyAdmin {
        emit CancelGame(roomId);
    }

    function setNickname(address user) external {
        require(balances[user] >= prices["nickname"], "insufficient funds!");
        balances[user] -= prices["nickname"];
        balances[admin] += prices["nickname"];
        emit NicknameChange(user);
    }

    function setAvatar(address user) external {
        require(balances[user] >= prices["avatar"], "insufficient funds!");
        balances[user] -= prices["avatar"];
        balances[admin] += prices["avatar"];
        emit AvatarChange(user);
    }

    function payMessage(address user) external {
        require(balances[user] >= prices["message"], "insufficient funds!");
        balances[user] -= prices["message"];
        emit PayMessage(user);
    }

    function setPrices(string memory service, uint newPrice) external {
        prices[service] = newPrice;
        emit NewPrice(service, newPrice);
    }

    function delegateAdmin(address newAdmin) external OnlyOwner {
        emit Delegate(admin, newAdmin);
        admin = newAdmin;
    }

    function GetPoolBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function GetRoomBalance(string memory roomId) public view returns (uint256) {
        return rooms[roomId];
    }
}