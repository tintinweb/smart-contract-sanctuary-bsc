/**
 *Submitted for verification at BscScan.com on 2022-03-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
/** 
 * @title Ballot
 * @dev Implements voting process along with vote delegation
 */
contract NineDice {
   
    // Big Type Limit Numbers
    uint8[] public bigLimit = [4, 98];
    // Small Type Limit Numbers
    uint8[] public smallLimit = [1, 95];
    // Max odds number
    uint32 public maxOdds = 985000;
    // Min reserve money
    uint256 public minReserveCoin = 1000;
    // Player could withraw coins
    mapping (address => uint256) playerCoins;
    address private owner;
    uint256 public lastResult;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event PlayerWithdraw(address player, uint256 withdrawCoin);
    event PlayerBet(address player, uint256 betCoin, uint8 betNumber, uint8 betType, uint256 winCoin, uint256 withdrawCoin);
    
    // modifier to check if caller is owner
    modifier isOwner() {
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
        lastResult = block.timestamp;
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) external isOwner {
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

    /**
     * @dev Player withdraw coins
     */
    function playerWithdraw() external payable {
        require(playerCoins[msg.sender] > 0, "No enough coin could be withdraw");

        uint256 withdrawCoin = playerCoins[msg.sender];
        playerCoins[msg.sender] -= withdrawCoin;
        payable(msg.sender).transfer(withdrawCoin);
        emit PlayerWithdraw(msg.sender, withdrawCoin);
    }

    function getCoins() external view returns(uint256){
        return playerCoins[msg.sender];
    }

    /**
     * @dev Compute player bet info and return result 
     * @param betNumber player bet number
     * @param betType player bet type
     */
    function playerBet(uint8 betNumber, uint8 betType) public payable {
        require(betType == 1 || betType == 2, "BetType is not valid");
        if (betType == 1) {
            // Big Type
            require(betNumber >= bigLimit[0] && betNumber <= bigLimit[1], "BetNumber is not valid");
        } else if (betType == 2 ) {
            // Small Type
            require(betNumber >= smallLimit[0] && betNumber <= smallLimit[1], "BetNumber is not valid");
        }

        uint256 betCoin = msg.value;
        uint8 result = requestRandomWordsAuto(msg.sender, betCoin, betNumber, betType);
        bool isWin = false;
        if (betType == 1 && betNumber > result) {
            isWin = true;
        } else if (betType == 2 && betNumber <= result) {
            isWin = true;
        }
        uint256 winCoin = 0;
        uint256 withdrawCoin = 0;
        if (isWin) {
            uint256 balance = address(this).balance;
            winCoin = getWinNum(betCoin, betNumber, betType);
            // require(winNum <= balance, "Contact balance is not enough");
            if (winCoin > balance) {
                playerCoins[msg.sender] += winCoin;
            } else {
                withdrawCoin = winCoin;
                payable(msg.sender).transfer(winCoin);
            }            
        }
        emit PlayerBet(msg.sender, betCoin, betNumber, betType, winCoin, withdrawCoin);
    }

    /**
     * @dev Request random words 
     * @return random words
     */
    function requestRandomWordsAuto(address player, uint256 betCoin, uint8 betNumber, uint8 betType) internal returns(uint8) {
        uint256 random_one = uint256(keccak256(abi.encodePacked(block.timestamp, betType, betNumber, betCoin, player, lastResult)));
        uint8 random_two = uint8(random_one % 100);
        lastResult = random_one;
        return random_two;
    }

    function getOdds(uint8 betNumber, uint8 betType) internal view returns(uint32){
        uint32 odds = 0;
        if (betType == 1) {
            odds = maxOdds / (99 - betNumber);
        } else if (betType == 2 ) {
            odds = maxOdds / betNumber;
        }
        return odds;
    }
    function getWinNum(uint256 betCoin, uint8 betNumber, uint8 betType) internal view returns(uint256){
        uint32 odds = 0;
        if (betType == 1) {
            odds = maxOdds / (99 - betNumber);
        } else if (betType == 2 ) {
            odds = maxOdds / betNumber;
        }
        uint256 winNum = betCoin * odds / 10000;
        return winNum;
    }
    function getBalance() external view returns(uint256) {
        return address(this).balance;
    }
    function setMinReserveCoin(uint256 minCoin) external {
        minReserveCoin = minCoin;
    }
}