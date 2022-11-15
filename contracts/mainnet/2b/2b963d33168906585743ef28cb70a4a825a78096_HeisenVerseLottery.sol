/**
 *Submitted for verification at BscScan.com on 2022-11-14
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @title HeisenVerse Lottery Contract
 * @author HeisenDev
 */
contract HeisenVerseLottery is Context {
    using SafeMath for uint256;

    address private heisenVerse;
    address[] public players;
    address[] public winners;
    uint public lotteryCount = 1;
    uint public lotteryPrice = 0.03 ether;
    event Deposit(address indexed sender, uint amount);
    event BuyLottery(address indexed sender, uint amount);
    event Winner(uint lottery, address indexed winner, uint number, uint amount);

    constructor() {
        heisenVerse = payable(_msgSender());
    }
    modifier restricted(){
        require(_msgSender() == heisenVerse);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(_msgSender(), msg.value);
        }
    }

    function buyLottery(address ref) public payable {
        require(msg.value >= lotteryPrice, "Lottery: underpriced");
        uint256 amount = msg.value;
        uint256 refAmount =  amount.mul(5).div(100);
        (bool refSent, ) = ref.call{value: refAmount}("");
        require(refSent, "Deposit ETH: Failed to send ETH");
        uint256 contractBalance = address(this).balance;
        if (contractBalance >= 1 ether) {
            pickWinner();
        }
        players.push(_msgSender());
        emit BuyLottery(_msgSender(), msg.value);
    }

    function pickWinner() internal {
        uint winner1 = random(1) % players.length;
        uint winner2 = random(2) % players.length;
        uint winner3 = random(3) % players.length;

        uint256 contractBalance = address(this).balance;
        uint256 winner1Amount = contractBalance.mul(50).div(100);
        uint256 winner2Amount = contractBalance.mul(20).div(100);
        uint256 winner3Amount = contractBalance.mul(10).div(100);
        uint256 heisenVerseAmount =  contractBalance.sub(winner1Amount).sub(winner2Amount).sub(winner3Amount);
        (bool sentPlayer1, ) = payable(players[winner1]).call{value: winner1Amount}("");
        require(sentPlayer1, "Deposit ETH: Failed to send ETH");
        (bool sentPlayer2, ) = payable(players[winner2]).call{value: winner2Amount}("");
        require(sentPlayer2, "Deposit ETH: Failed to send ETH");
        (bool sentPlayer3, ) = payable(players[winner3]).call{value: winner3Amount}("");
        require(sentPlayer3, "Deposit ETH: Failed to send ETH");
        (bool sentHeisenVerse, ) = heisenVerse.call{value: heisenVerseAmount}("");
        require(sentHeisenVerse, "Deposit ETH: Failed to send ETH");
        winners.push(players[winner1]);
        winners.push(players[winner2]);
        winners.push(players[winner3]);
        emit Winner(lotteryCount, players[winner1], winner1, winner1Amount);
        emit Winner(lotteryCount, players[winner2], winner2, winner2Amount);
        emit Winner(lotteryCount, players[winner3], winner3, winner3Amount);
        lotteryCount++;
        players = new address[](0);
    }

    function random(uint256 winner) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players, lotteryCount, winner)));
    }

    function setPrice(uint256 _lotteryPrice) public restricted {
        require(players.length == 0, "Need empty Lottery");
        lotteryPrice = _lotteryPrice;
    }

    function totalPlayers() public view returns(uint){
        return players.length;
    }
}