/**
 *Submitted for verification at BscScan.com on 2023-01-25
*/

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


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

// File: lottery.sol


pragma solidity 0.8.17;


contract Lottery {
    IERC20 public BUSD = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    address public owner;
    address[] public players;

    uint256 public lotteryId;
    uint256 public lastLotteryTime;
    uint256 immutable entryPrice = 10e18; // 10 BUSD

    mapping(uint256 => address) public lotteryHistory;
    mapping(uint256 => uint256) public lotteryHistoryPrize;

    constructor() {
        owner = msg.sender;
        lastLotteryTime = block.timestamp + 1 days;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function getRandomNumber() private view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        block.gaslimit,
                        block.number,
                        block.coinbase,
                        blockhash(block.number - 1)
                    )
                )
            );
    }

    function getBalance() public view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    function getPrizePool() public view returns (uint256) {
        return (BUSD.balanceOf(address(this)) * 70) / 100;
    }

    function getEntries(address user) public view returns (uint256) {
        uint256 entries = 0;
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == user) {
                entries++;
            }
        }
        return entries;
    }

    function getTotalEntries() public view returns (uint256) {
        return players.length;
    }

    function enter(uint256 tickets) external {
        require(tickets > 0);
        BUSD.transferFrom(msg.sender, address(this), entryPrice * tickets);
        for (uint256 i = 0; i < tickets; i++) {
            players.push(msg.sender);
        }
    }

    function pickWinner() external {
        require(players.length > 0);
        require(lastLotteryTime + 1 days < block.timestamp);

        uint256 index = getRandomNumber() % players.length;
        lotteryHistoryPrize[lotteryId] = getPrizePool();

        uint256 prizePool = getPrizePool();
        uint256 contractPrize = getBalance() - prizePool;

        BUSD.transfer(players[index], getPrizePool());
        BUSD.transfer(
            0x1Bf868C031AAF6AC9AFdBbB1E31D1fA9e6490F8a,
            contractPrize
        );

        lastLotteryTime = block.timestamp;
        lotteryHistory[lotteryId] = players[index];
        lotteryId++;

        players = new address[](0);
    }
}