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

/**
* @title IBet
* @dev interface for Bet contract
 */
interface IBet{
    function callWinner(address payable _winner, uint _bookieFee) external;
    function totalOwed() external returns(uint);
    function addLiquidity() external payable;

}

/**
* @title Bet
* @author Carson Case ([email protected])
* @notice Contract to create, manage, and settle Bets. 
*   A pair of Bets is a Book. And a Book is made by the bookie through BookMaker
* The bookie funds the bets with liquidity and earns a spread on bets called R or
* the reduction rate in return, split with me, the contract creator.
* Bookies also must be trusted parties, as they settle the bet and the winner.
* Feel free to make your bookie a smart contract for this to be trustless
*/
contract BookMaker{

    uint constant oneHundredPercent = 1 ether;
    uint constant R = 2 ether / 100;    //2%
    address internal constant DEV = 0x27d2c7F2729029440bE539EaA61657d35b5A4AEA;

    struct Book{
        bool active;
        address bet1;
        address bet2;
    }

    mapping (address => Book) public bookiesBooks;

    event NewBook(address Bookie);
    event ClosedBook(address Bookie);

    /**
    * @notice creates a newBook. Caller is bookie
     */
    function newBook() external payable{
        require(msg.value %2 == 0, "Please don't be like this. Just make the liquidity amount even");
        require(!bookiesBooks[msg.sender].active, "Close your book first");
        address b1 = address(new Bet(address(this), msg.sender));
        address b2 = address(new Bet(address(this), msg.sender));
        bookiesBooks[msg.sender] = Book(true,b1,b2);
        if(msg.value > 1){
            IBet(b1).addLiquidity{value:msg.value/2}();
            IBet(b2).addLiquidity{value:msg.value/2}();
        }
        emit NewBook(msg.sender);
    }

    /**
    * @notice closes a book with the address of Book as the winner. Must be called by bookie
     */
    function closeBook(address _winner) external{
        Book storage b = bookiesBooks[msg.sender];
        require(b.bet1 == _winner || b.bet2 == _winner, "Must be the bookie of the winner");
        b.active = false;

        uint b1 = (b.bet1).balance;
        uint b2 = (b.bet2).balance;
        uint totalOwed = IBet(_winner).totalOwed();
        
        uint bookieFee = (b1+b2 > totalOwed)
        ? (b1+b2) - totalOwed
        : 0;

        address loser = _winner == b.bet1
        ? b.bet2 
        : b.bet1;
        // call loser first as it needs to send funds to winner
        IBet(loser).callWinner(payable(_winner), bookieFee);
        IBet(_winner).callWinner(payable(_winner), bookieFee);

        emit ClosedBook(msg.sender);
    }

    /**
    * @notice returns the odds for a particular bookie's active book,
    *   this one is only practically callable by a Bet contract
     */
    function getOdds(address _bookie, uint _amount) external view returns(uint){
        return (msg.sender == bookiesBooks[_bookie].bet1)
        ? _getOdds(_bookie, _amount, true)
        : _getOdds(_bookie, _amount, false);   
    }

    /**
    * @notice returns  the odds for a particualr bookie's active book
    * @param _betIsB1 defines which odds are being retreived. Odds for a bet on B1 or not
     */
    function getOdds(address _bookie, uint _amount, bool _betIsB1) external view returns(uint){
        return(_getOdds(_bookie, _amount, _betIsB1));
    }

    /**
    * @notice private function for getting the odds calculated
     */
    function _getOdds(address _bookie, uint _amount, bool _betIsB1) private view returns(uint){ 
        Book storage b = bookiesBooks[_bookie];
        require(b.active, "This book is no longer active");
        uint b1 = (b.bet1).balance;
        uint b2 = (b.bet2).balance;

        /*
        Equation for the odds. looks like this:
        P = oneHundred percent
        R = reduction rate
        t = total in book
        A = amount being bet
        a = total already bet on option
        A(P - R) ((t + A) / (a + A))
        _________________________
                    P
        */

        return (_betIsB1)
        ? (_amount * (oneHundredPercent - R) * ((b1+b2) + _amount) / (b1+_amount))/oneHundredPercent // funds are being added to b1
        : (_amount * (oneHundredPercent - R) * ((b1+b2) + _amount) / (b2+_amount))/oneHundredPercent; // funds are being added to b2 

    }
}