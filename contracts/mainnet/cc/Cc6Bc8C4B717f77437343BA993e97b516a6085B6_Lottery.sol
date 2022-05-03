/**
 *Submitted for verification at BscScan.com on 2022-05-03
*/

//SPDX-License-Identifier: MIT

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

contract Lottery {
    IERC20 busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    address public manager;
    bool private needFeeWithdraw;

    address[] players;
    uint256 startTime;

    event AddPlayer(address player, uint amount, uint playersCount);
    event AddCompletedLottery(address[] playersList, address winner, uint256 startTime, uint256 endTime, uint winnerPrize);

    struct LotteryStruct {
        address[] playersList;
        address winner;
        uint256 startTime;
        uint256 endTime;
    }

    LotteryStruct[] lotteries;
    uint price = 10 ether;
    uint8 playersCount = 10;
    
    constructor() {
        manager = msg.sender;
        needFeeWithdraw = false;
    }

    function getCurrentPlayers() public view returns(address[] memory){
        return players;
    }

    function getLotteries() public view returns(LotteryStruct[] memory){
        return lotteries;
    }

    function addPlayer(uint amount) external {
        require(amount == price, 'Incorrect price');
        require(busd.balanceOf(msg.sender) >= price, 'Incorrect balance');
        address player = address(msg.sender);
    
        if (players.length == 0) {
            startTime = block.timestamp;
        }

        busd.transferFrom(msg.sender, address(this), amount);
        players.push(player);

        emit AddPlayer(player, price, players.length);

        if (players.length == playersCount) {
            pickWinner();
        }
    }

    function random() internal view returns(uint){
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() internal {
        uint r = random();
        address _winner;
        
        uint idx = r % players.length;
        _winner = players[idx];
        uint256 endTime = block.timestamp;

        LotteryStruct memory completedLottery = LotteryStruct(
            players,
            _winner,
            startTime,
            endTime
        );

        lotteries.push(completedLottery);

        uint prize = (playersCount * price * 90) / 100;
        uint fee = busd.balanceOf(address(this)) - prize;

        busd.transfer(_winner, prize);
        emit AddCompletedLottery(players, _winner, startTime, endTime, prize);

        if (needFeeWithdraw) {
            busd.transfer(manager, fee);
            needFeeWithdraw = false;
        }

        players = new address[](0);
    }

    function enableNeedFeeWithdraw() public {
        require(msg.sender == manager);
        needFeeWithdraw = true;
    }

    function getFeeBalance() public view returns(uint){
        require(msg.sender == manager);
        uint fullBalance = busd.balanceOf(address(this));
        uint playersPoolBalance = players.length * price;
        return fullBalance - playersPoolBalance;
    }

    receive () payable external{}
}