/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: NA

pragma solidity ^0.8.0;

/**
* @title IBookMaker
* @dev simple interface for BookMaker's getodds function
 */
interface IBookMaker{
    function getOdds(address _bookie, uint _amount) external view returns(uint);
}

/**
* @title Bet
* @author Carson Case ([email protected])
* @notice Contract created by the BookMaker representing 1 bet of several.
* payments in ETH sent to the contract are recorded as wagers according to the odds specified in BookMaker
* BookMaker can settle a bet, defining a winner Bet contract. The non-winners self destruct after sending their
* funds to the winner. And the winner contract allows collections by the betting addresses
 */
contract Bet{

    address immutable bookMaker;
    address immutable bookie;
    bool winner = false;
    uint public totalOwed = 0;

    mapping(address => uint) owedIfWon;

    constructor(address _bookMaker, address _bookie){
        bookMaker = _bookMaker;
        bookie = _bookie;
    }

    /**
    * @notice adds liquidity for the bet. Making larger bets possible with good payouts
        bookie can expect these funds back so long as bet stays resonably balanced
     */
    function addLiquidity() external payable{
        require(msg.sender == bookMaker, "Only bookmaker can call");
        owedIfWon[bookie] += msg.value * 2;
        totalOwed += msg.value * 2;
    }

    /**
    * @notice function called upon bet
    * sending ETH to this contract calls this funciton. And logs your wager
     */
    receive() external payable{
        require(!winner, "Betting has ended");
        require(msg.sender != bookie, "bookie cannot bet");
        uint owed = IBookMaker(bookMaker).getOdds(bookie, msg.value);
        owedIfWon[msg.sender] += owed;
        totalOwed += owed;
    }

    /**
    * @notice if betting is over. You collect your wager here
     */
    function collect() external{
        uint amount = owedIfWon[msg.sender];
        if(amount > 0 && winner){
            owedIfWon[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    /**
    * @notice for BookMaker to call the winner. Sends funds to real winner if lost
    *   and keeps funds, sending only the bookie fee and liquidity back to bookie
     */
    function callWinner(address payable _winner, uint _bookieFee) external{
        require(msg.sender == bookMaker, "Only bookmaker can call");
        // if this is the winner mark as so. If not self destruct and send winner funds
        if(_winner == address(this)){
            winner = true;
            uint toRefundLq = (totalOwed > address(this).balance)
            ? owedIfWon[bookie] - (totalOwed - address(this).balance)
            : owedIfWon[bookie];
            payable(bookie).transfer(toRefundLq);
        }else{
            payable(bookie).transfer(_bookieFee);
            selfdestruct(_winner);
        }
    }


}