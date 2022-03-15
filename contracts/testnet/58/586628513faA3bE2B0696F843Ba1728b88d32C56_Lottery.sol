/**
 *Submitted for verification at BscScan.com on 2022-03-15
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

contract Lottery {

    struct Player {
        address payable wallet;
        string username;
        string hashPassword;
        string referer;
        bool freePass;
        uint winAmount;
    }

    struct Ticket {
        string username;
        uint[] tokens;
    }

    // Lottery data
    Player[] public players; //private
    Ticket[] public tickets; //pivate
    uint public lotteryID;
    // Admin info
    address payable public owner;
    address public middleware;
    // Hyper-parameters
    uint[] private lotteryTokens;
    uint[] public winnerAmounts;
    uint[] public winnerRefAmounts;
    bool[] public amountFixed;
    //Helper lists
    uint[] private winnersCnt;
    uint[] private winnersRefCnt;

    constructor(address midlwr) {
        // creator of the smart contract
        owner = msg.sender;
        // middleware registers users indirectly
        middleware = midlwr;
        // current number of lottery 
        lotteryID = 1;
        // the winner tokens
        lotteryTokens = [2, 12, 23, 33, 48, 8];
        // number of (direct) winners with different scores
        winnersCnt = [0, 0, 0, 0, 0, 0, 0];
        // number of (indirect/reference) winners with different scores
        winnersRefCnt = [0, 0, 0, 0, 0, 0, 0];
        // amount of money to be paid to winners with different scores
        winnerAmounts = [0, 0, 1, 2, 3, 4, 5];
        // amount of money to be paid to (reference) winners with different scores
        winnerRefAmounts = [0, 0, 1, 1, 1, 1, 1];
        // shows if the money should be paid for each score absolute or divided between winners
        amountFixed = [true, true, true, true, true, false, false];
    }

    // check if username exists in players list
    function userExists(string memory usrnm) public view returns (bool) {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                return true;
            }
        }
        return false;
    }

    // check if username matches password in players list
    function checkPassword(string memory usrnm, string memory hashPwd) public view returns (bool) {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm) && compareStrings(players[i].hashPassword, hashPwd)) {
                return true;
            }
        }
        return false;
    }

    // get lottery balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // get lottery tokens
    function getLotteryTokens() public onlyOwner view returns (uint[] memory) {
        return lotteryTokens;
    }

    // set lottery tokens
    function setLotteryTokens(uint[] memory tokens) public onlyOwner {
        lotteryTokens = tokens;
    }

    // set win amounts
    function setWinnerAmounts(uint[] memory amounts) public onlyOwner {
        winnerAmounts = amounts;
    }

    // set reference win amounts
    function setRefWinnerAmounts(uint[] memory amounts) public onlyOwner {
        winnerRefAmounts = amounts;
    }

    // check if wallet matches user
    function checkWallet(string memory usrnm, address wllt) private view onlyMiddleware returns(bool){
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                return players[i].wallet == wllt; 
            }
        }
        return false;
    }

    // change wallet for user
    function changeWallet(string memory usrnm, address payable wllt) public onlyMiddleware {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                players[i].wallet = wllt;
            }
        }
    }

    // check if token is in correct format (6 non-duplicate numbers from 1to 50)
    function checkTokens(uint[] memory tkns) private pure returns (bool) {
        if (tkns.length != 6) {
            return false;
        }
        for (uint i=0; i<6; i++) {
            if (tkns[i] < 1 || tkns[i] > 50) {
                return false;
            }
            for (uint j=0; j<6; j++) {
                if (i != j && tkns[i] == tkns[j]) {
                    return false;
                }
            }
        }
        return true;
    }

    // enter lottery directly
    function enterLottery(string memory usr, string memory hashPwd, string memory rfrr, uint[] memory tkns) public payable {
        require(msg.value == 0.05 ether,"Amount should be equal to 0.05 BNB");
        if (userExists(usr)) {
            if (checkPassword(usr, hashPwd)) {
                if (checkTokens(tkns)) {
                    if (checkWallet(usr, msg.sender)) {
                        // create ticket if user exists, password and wallet match username and tokens are in correct format
                        tickets.push(Ticket(usr, tkns));
                    } else {
                        revert("wallet does not match user");
                    }
                } else {
                    revert("incorrect tokens format");
                }
            } else {
                revert("wrong password");
            }
        } else {
            if (checkTokens(tkns)) {
                if (!emptyString(rfrr) && userExists(rfrr)) {
                    // if user is new, and has a referer that exists in player lists, create the user and make a ticket for them
                    players.push(Player(payable(msg.sender), usr, hashPwd, rfrr, false, 0));
                    tickets.push(Ticket(usr, tkns));
                } else if (emptyString(rfrr)) {
                    // if user is new, and does not have a referer, create the user and make a ticket for them
                    players.push(Player(payable(msg.sender), usr, hashPwd, rfrr, false, 0));
                    tickets.push(Ticket(usr, tkns));
                } else {
                    revert("referer username does not exist in lottery");
                }
            } else {
                revert("incorrect tokens format");
            }
        }
    }

    // enter lottery through middleware
    function enterLotteryMiddleware(address payable wllt, string memory usr, string memory hashPwd, string memory rfrr, uint[] memory tkns) public payable onlyMiddleware {
        require(msg.value == 0.05 ether,"Amount should be equal to 0.05 BNB");
        if (userExists(usr)) {
            if (checkPassword(usr, hashPwd)) {
                if (checkTokens(tkns)) {
                    if (checkWallet(usr, wllt)) {
                        // create ticket if user exists, password and wallet match username and tokens are in correct format
                        tickets.push(Ticket(usr, tkns));
                    } else {
                        revert("wallet does not match user");
                    }
                } else {
                    revert("incorrect tokens format");
                }
            } else {
                revert("wrong password");
            }
        } else {
            if (checkTokens(tkns)) {
                if (!emptyString(rfrr) && userExists(rfrr)) {
                    // if user is new, and has a referer that exists in player lists, create the user and make a ticket for them
                    players.push(Player(wllt, usr, hashPwd, rfrr, false, 0));
                    tickets.push(Ticket(usr, tkns));
                } else if (emptyString(rfrr)) {
                    // if user is new, and does not have a referer, create the user and make a ticket for them
                    players.push(Player(wllt, usr, hashPwd, rfrr, false, 0));
                    tickets.push(Ticket(usr, tkns));
                } else {
                    revert("referer username does not exist in lottery");
                }
            } else {
                revert("incorrect tokens format");
            }
        }
    }

    // check if string is empty
    function emptyString(string memory s) private pure returns(bool) {
        bytes memory sByte = bytes(s);
        return sByte.length == 0;
    }

    // check if user has freepass
    function hasFreePass(string memory usrnm) private view returns(bool) {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                return players[i].freePass;
            }
        }
    }

    // register freepass user in lottery
    function registerFreepassUser(string memory usrnm, string memory hashPwd, uint[] memory tkns) public onlyMiddleware {
        if (userExists(usrnm)) {
            if (checkPassword(usrnm, hashPwd)) {
                if (hasFreePass(usrnm)) {
                    // create a ticket for the user, if username exists in players list, password matches the username and tokens are in correct format
                    tickets.push(Ticket(usrnm, tkns));
                    takeFreePass(usrnm);
                } else {
                    revert("This user does not have freepass");
                }
            } else {
                revert("incorrect password");
            }
        }
        else {
            revert("this username does not exist in lottery");
        }
    }

    // helper-func score tokens
    function scoreToken(uint[] memory tok1, uint[] memory tok2) private pure returns (uint) {
        uint score = 0;
        for (uint i=0; i<tok1.length; i++) {
            for (uint j=0; j<tok2.length; j++) {
                if (tok1[i] == tok2[j]) {
                    score++;
                }
            }
        }
        return score;
    }

    // check for equality of strings    
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    // check if user has a valid referer
    function hasReferer(string memory usrnm) view public returns(bool) {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                return userExists(players[i].referer);
            }
        }
        return false;
    }

    // give freepass to a user
    function giveFreePass(string memory usrnm) public onlyMiddleware {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                players[i].freePass = true;
            }
        }
    }

    // take away freepass from a user
    function takeFreePass(string memory usrnm) public onlyMiddleware {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                players[i].freePass = false;
            }
        }
    }

    // add money to player (to be paid later)
    function addWinAmount(string memory usrnm, uint amnt) private onlyMiddleware {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                players[i].winAmount += amnt;
            }
        }
    }

    // add reference money to player (to be paid later)
    function addWinAmountToReferer(string memory usrnm, uint amnt) private onlyMiddleware {
        for (uint i=0; i<players.length; i++) {
            if (compareStrings(players[i].username, usrnm)) {
                addWinAmount(players[i].referer, amnt);
            }
        }
    }

    // calculate win amount for every user
    function findWinners() public onlyOwner {
        for (uint i=0; i<players.length; i++) {
            players[i].winAmount = 0;
        }
        // Calculate number of winners for each score
        for (uint i=0; i<tickets.length; i++) {
            uint score = scoreToken(tickets[i].tokens, lotteryTokens);
            winnersCnt[score]++;
            if (hasReferer(tickets[i].username)) {
                winnersRefCnt[score]++;
            }
            if (score == 1) {
                giveFreePass(tickets[i].username);
            }
        }
        for (uint i=0; i<6; i++) {
            if (amountFixed[i]) {
                winnersCnt[i] = 1;
                winnersRefCnt[i] = 1;
            }
        }
        // Calculate money for each ticket and add the amount to the player
        for (uint i=0; i<tickets.length; i++) {
            uint score = scoreToken(tickets[i].tokens, lotteryTokens);
            addWinAmount(tickets[i].username, uint(winnerAmounts[score] / winnersCnt[score]));
            if (hasReferer(tickets[i].username)) {
                addWinAmountToReferer(tickets[i].username, uint(winnerRefAmounts[score] / winnersRefCnt[score]));
            }
        }
    }

    // get the total amount of money to be paid to all players
    function getAllWinnings() public onlyOwner view returns (uint) {
        uint winnings = 0;
        for (uint i=0; i<players.length; i++) {
            winnings += players[i].winAmount;
        }
        return winnings;
    } 

    // send money to every user at once
    function transferToWinners() public onlyOwner {
        // converting ether to wei
        uint ratio = 1000000000000000000;
        for (uint i=0; i<players.length; i++) {
            // send money to winners
            if (players[i].winAmount > 0) {
                players[i].wallet.transfer(players[i].winAmount*ratio);
                // clear win amount for every user
                players[i].winAmount = 0;
            }
        }
        // transfer the remaining money to owner
        owner.transfer(getBalance());
        // Start new lottery
        uint l = tickets.length;
        // clear tickets
        for (uint i=0; i<l; i++) {
            tickets.pop();
        }
        lotteryID++;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyMiddleware() {
        require(msg.sender == middleware || msg.sender == owner);
        _;
    }
}