pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;


import "./Ownable.sol";


interface IToken {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




contract BetsSportChainSpace is Ownable {

    //Addresses
    address dev1;
    address dev2;
    address dev3;
    address mkt;

    // Token
    IToken public token_SCS;

    address scstoken = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; /** busd Testnet **/
    // address scstoken = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56; /** SCS Mainnet **/


    //Taxes
    uint256 ownerTax = 30;  // 3%
    uint256 devTax = 20; // 2%
    uint256 mktTax = 10; // 1%

    //constants
    uint internal minimumBet = 1 * 1e18;

    uint256 maxBetTimeBefore = 900;

    //mappings
    mapping(address => uint256[]) internal userToBets;
    mapping(uint256 => Bet[]) internal matchToBets;
    mapping(bytes32 => bool) internal matchPaidOut;
    mapping(address => User) public users;
    mapping(uint256 => bool) public matchIds;


    //Data
    Match[] public matches;
    Bet[] public bets;

    //Events
    event WithdrawBalance(address _address, uint256 _amount, uint256 _percentage);
    event DepositData(address _address, uint256 _amount);



    struct Bet {
        address user;
        uint256 matchId;  // Match Struct
        uint256 amount;
        uint8 chosenWinner;
        uint8 status;  // 0 - pending , 1  - Ended winner , 2 - Ended Lose, 3 - back tokens
    }

    struct User {
        address _address;
        uint256 balance;
        uint8 status;
    }

    struct Match {
        uint256 id;
        uint256 team1;
        uint256 team2;
        uint256 odds0; // ODDS Draw
        uint256 odds1; // ODDS Team 1
        uint256 odds2; // ODDS Team 2
        uint8 winner;  // 0 - DRAW , 1 - Team 1 , 2 - Team 2
        uint8 status;   // 0 - pending , 1  - Ended , 2 - back bets, 3 - Admin Block Match, 4 - prepare to remove
        uint256 date;
        bool exist;
    }

    constructor(address _dev1, address _dev2, address _dev3, address _mkt) public {

        dev1 = _dev1;
        dev2 = _dev2;
        dev3 = _dev3;
        mkt = _mkt;
        token_SCS = IToken(scstoken);
    }

    function setMatch(uint256 _id, uint256 _team1 , uint256 _team2, uint256 _odds0, uint256 _odds1, uint256 _odds2, uint256 _date) public onlyOwner {
        require(matches[_id].exist);
        matches[_id] = Match(_id, _team1, _team2, _odds0, _odds1, _odds2,  0, 0, _date, true);
        matchIds[_id] = true;
    }

    function updateMatch(uint256 _id, uint256 _team1 , uint256 _team2, uint256 _odds0, uint256 _odds1, uint256 _odds2, uint256 _date) public onlyOwner {
        require(matches[_id].exist);
        matches[_id] = Match(_id, _team1, _team2, _odds0, _odds1, _odds2,  0, 0, _date, true);
    }


    /// @notice Validate Match To enable set bets
    /// @return bool
    function _validateMatch(uint256 _matchId) private view returns (bool) {

        // require(thisMatch, "No match in Contract");
        Match storage thisMatch = matches[_matchId];


        if(thisMatch.status != 0) {
            return false;
        }

        if(thisMatch.date < (block.timestamp + maxBetTimeBefore)) {
            return false;
        }

        return true;
    }


    /// @notice gets the current matches on which the user has bet
    /// @return array of match ids
    function getUserBets() public view returns (uint256[] memory) {
        return userToBets[msg.sender];
    }


    function getUserInContractBalance() public view returns (uint256) {
        return users[msg.sender].balance;
    }

    function getUserBalance() public view returns (uint256) {
        return token_SCS.balanceOf(address(msg.sender));
    }


    function getBalanceSCS() public view returns (uint256) {
        return token_SCS.balanceOf(address(this));
    }


    /// @notice gets a user's bet on a given match
    /// @param _matchId the id of the desired match
    /// @return tuple containing the bet amount, and the index of the chosen winner (or (0,0) if no bet found)
    function getUserBet(uint256 _matchId) public view returns (uint amount, uint8 winner) {
        Bet[] storage matchBets = matchToBets[_matchId];
        for (uint n = 0; n < matchBets.length; n++) {
            if (matchBets[n].user == msg.sender) {
                return (matchBets[n].amount, matchBets[n].chosenWinner);
            }
        }
        return (0, 0);
    }

    /// @notice get Latest Matches
    /// @param _matchId the id of the match on which to bet
    function getMatchLatestBets(uint256 _matchId) public view returns (Bet[] memory) {

        uint counter = 0;
        Bet[] memory result;

        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].matchId == _matchId) {
                result[counter] = bets[i];
                counter++;
            }
            if(counter > 10) {
                break;
            }
        }
        return result;
    }

    /// @notice place a bet for User
    /// @param _matchId the id of the match on which to bet
    /// @param _chosenWinner the index of the participant chosen as winner
    /// @param _amount the index of the participant chosen as winner
    function placeBet(uint256 _matchId, uint8 _chosenWinner, uint256 _amount) public {

        //bet must be above a certain minimum
        require(_amount >= minimumBet);

        //require that chosen winner falls within the defined number of participants for match
        require(_validateMatch(_matchId));
        if(users[msg.sender].balance < _amount) {
            token_SCS.transferFrom(address(msg.sender), address(this), _amount);
        } else {
            users[msg.sender].balance = users[msg.sender].balance - _amount;
        }

        bets.push(Bet(msg.sender, _matchId, _amount, _chosenWinner, 0));

        uint256[] storage userBets = userToBets[msg.sender];
        userBets.push(_matchId);

    }


    /// @notice Set Match Status by ID Match
    /// @param _matchId the id of the match on which to bet
    /// @param _winner winner match
    /// @param _status Status of the match
    function setMatchStatus(uint256 _matchId, uint8 _winner, uint8 _status) public onlyOwner {

        Match storage thisMatch = matches[_matchId];
        uint8 currentStatus = matches[_matchId].status;
        matches[_matchId].winner = _winner;


        //Disable remove Match if Status is not Ended or not back tokens
        if(_status != 4 || (currentStatus == 1 || currentStatus == 2)) {
            matches[_matchId].status = _status;
        }


        if(_status == 1) {
            _sendMatchUsersWinBalances(thisMatch, _winner);
        }
        if(_status == 2) {
            _backAllBets(thisMatch);
        }

    }

    /// @notice Send Win values to all Users.
    /// @param _match match object
    /// @param _winner the Team who win
    function _sendMatchUsersWinBalances(Match memory _match, uint8 _winner) private {

        Bet[] storage matchBets = matchToBets[_match.id];


        for (uint n = 0; n < matchBets.length; n++) {
            if (matchBets[n].chosenWinner == _winner) {

                uint256 oddsValue = 0;
                if(_winner == 0){
                    oddsValue = _match.odds0;
                }
                if(_winner == 1){
                    oddsValue = _match.odds1;
                }
                if(_winner == 2){
                    oddsValue = _match.odds2;
                }

                uint256 winningValue = (matchBets[n].amount * oddsValue) / 100;

                winningValue = _payTax(winningValue);

                users[matchBets[n].user].balance = users[matchBets[n].user].balance + winningValue;
                matchBets[n].status = 1;
            } else {
                matchBets[n].status = 2;
            }
        }

    }


    /// @notice Back all token to user Balances in contract
    /// @param _match match Object
    function _backAllBets(Match memory _match) private {

        Bet[] storage matchBets = matchToBets[_match.id];
        for (uint n = 0; n < matchBets.length; n++) {
            users[matchBets[n].user].balance = users[matchBets[n].user].balance + matchBets[n].amount;
            matchBets[n].status = 3;
        }

    }


    /// @notice send Taxes for Marketing and developers
    function _payTax(uint256 winningValue) private returns(uint256) {

        uint256 ownerTaxValue = (winningValue * ownerTax / 100);
        uint256 devTaxValue = (winningValue * devTax / 100);
        uint256 mktTaxValue = (winningValue * mktTax / 100);

        users[owner()].balance = users[owner()].balance + ownerTaxValue;
        users[dev1].balance = users[dev1].balance + devTaxValue;
        users[dev2].balance = users[dev2].balance + devTaxValue;
        users[dev3].balance = users[dev3].balance + devTaxValue;
        users[mkt].balance = users[mkt].balance + mktTaxValue;


        winningValue = winningValue - ownerTaxValue - devTaxValue - mktTaxValue;
        return winningValue;
    }



    /// @notice Withdraw user contract balance to main account in percents
    function WithdrawContractBalance(uint256 _percentage) public onlyOwner {

        uint256 percentageValue = (getBalanceSCS() * _percentage) / 100;

        uint256 ownerTaxValue = (percentageValue * ownerTax / 100);
        uint256 devTaxValue = (percentageValue * devTax / 100);
        uint256 mktTaxValue = (percentageValue * mktTax / 100);
        users[owner()].balance = users[owner()].balance + ownerTaxValue;
        users[dev1].balance = users[dev1].balance + devTaxValue;
        users[dev2].balance = users[dev2].balance + devTaxValue;
        users[dev3].balance = users[dev3].balance + devTaxValue;
        users[mkt].balance = users[mkt].balance + mktTaxValue;



        token_SCS.transfer(msg.sender, (percentageValue - ownerTaxValue - devTaxValue - mktTaxValue));
        users[msg.sender].balance = users[msg.sender].balance - percentageValue;

        emit WithdrawBalance(msg.sender, percentageValue, _percentage);
    }

    function Deposit(uint256 _amount) public {

        //Deposit must be above a certain minimum
        require(_amount >= minimumBet);

        token_SCS.transferFrom(address(msg.sender), address(this), _amount);

        emit DepositData(msg.sender, _amount);
    }



    /// @notice Tax Settings
    function setOwnerTax(uint256 _tax ) public onlyOwner {
        ownerTax = _tax;
    }

    /// @notice Tax Settings
    function setDevTax(uint256 _tax ) public onlyOwner {
        devTax = _tax;
    }

    /// @notice Tax Settings
    function setMktTax(uint256 _tax ) public onlyOwner {
        mktTax = _tax;
    }

    /// @notice Dev address Settings
    function setDev1Address(address _dev ) public onlyOwner {
        dev1 = _dev;
    }

    /// @notice Dev address Settings
    function setDev2Address(address _dev ) public onlyOwner {
        dev2 = _dev;
    }

    /// @notice Dev address Settings
    function setDev3Address(address _dev ) public onlyOwner {
        dev3 = _dev;
    }

    /// @notice Marketing address Settings
    function setMktAddress(address _mkt ) public onlyOwner {
        mkt = _mkt;
    }

    /// @notice SCS token address change
    function setSCSTokenContract(address _address) public onlyOwner {
        scstoken = _address;
        token_SCS = IToken(scstoken);
    }
}