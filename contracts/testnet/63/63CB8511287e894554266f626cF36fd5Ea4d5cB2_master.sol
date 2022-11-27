// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

    import "./safeMath.sol";
    import "./brakeSystem.sol";
    import "./accessControl.sol";
    import "./interfaceIERC20.sol";

contract master is IERC20, access, brakeSystem {
    using safeMath for uint256;

    string internal _name = "BIT Lottery";
    string internal _symbol = "BTL";
    
    address payable[] internal _gamblers;

    mapping(address => bool) internal _branch;
    mapping(uint256 => history) internal _loterryHistory;
    
    struct history {
        address winningWallet;
        uint256 awardReceived;
    }

    uint256 internal payoutAward = 85;
    uint256 internal payoutRate = 15;

    uint256 internal constant maxValue = 100;

    uint internal _lotteryID = 1;
    uint internal _ticketLimit = 100**18;

    uint256 internal _tikcketsAvaliable = _ticketLimit;
    uint256 internal _totalTikcketsSold = 0;
    uint256 internal _tikcketsSold = 0;

    uint256 internal _ticketValue = 1 ether;

    event received(
        address indexed from, 
        uint256 indexed amount
        );
    event ticketPrice(
        address indexed from, 
        uint256 indexed value
        );
    event limitGamblers(
        address indexed from, 
        uint256 indexed gamblers
        );
    event newBranch(
        address indexed sender, 
        address indexed account, 
        bool indexed value
        );
    event newWinner(
        address indexed winningWallet, 
        uint256 indexed lotteryID
        );
    event newGambler(
        address indexed account, 
        uint256 indexed lotteryID
        );

    string public developer = "https://github.com/cryptorug";

receive() external payable onlyBranch {
    require(msg.value != 0,
    "Owner: Insufficient value");
    emit received(msg.sender, msg.value);
}

    function totalSupply() external view override returns(uint256){
        return address(this).balance;
    }

    function decimals() external view override returns(uint){
        return _lotteryID;
    }

    function symbol() external view override returns(string memory){
        return _symbol;
    }

    function name() external view override returns(string memory){
        return _name;
    }

    function getOwner() external view override returns(address){
        return _owner;
    }

    function getNumber() internal virtual view returns(uint256){
        return uint256(keccak256(
            abi.encodePacked(
                address(this),block.timestamp)
                )
            );
    }

    function getTicketInfo() public view returns(uint256 indexTicketsAvaliable, uint256 indexSold, uint256 indexTotalTicketSold){
        uint256 A = _tikcketsAvaliable;
        uint256 B = _tikcketsSold;
        uint256 C = _totalTikcketsSold;
        return(A, B, C); 
    }

    function getLotteryInfo() public view returns (
        uint256 indexLotteryID, uint256 indexTicketPrice, uint256 indexPlayers, uint256 indexlimitGamblers, uint256 indexAccumulated){
        uint256 B = _lotteryID;
        uint256 C = _ticketValue;
        uint256 D = _gamblers.length;
        uint256 E = _ticketLimit;
        uint256 F = address(this).balance;
        return (B, C, D, E, F);
    }

    function setPayoutAwardDivision(uint256 _award, uint256 _rate) external whenPaused onlyDeveloper returns(bool){
    require(_award + _rate == 100,
    "Owner: The distribution must be proportional to one hundred");
        payoutAward = _award;
        payoutRate = _rate;
        return true;
    }

    function getPayoutAwardDivision() public view returns(uint256 indexWinner, uint256 indexFork){
        uint256 A = payoutAward;
        uint256 B = payoutRate;
        return (A, B);
    }

    function setBranch(address _account, bool _value) external onlyDeveloper returns(bool){
        _branch[_account] = _value;
        emit newBranch(msg.sender, _account, _value);
        return true;
    }

    function setTicketPrice(uint256 _value) external whenPaused onlyDeveloper returns(bool){
    require(_value != 0,
    "Owner: The limit cannot be equal to zero");
        _ticketValue = _value;
        emit ticketPrice(msg.sender, _ticketValue);
        return true;
    }

    function setTicketLimit(uint256 _amount) external whenPaused onlyDeveloper returns(bool){
    require(_amount != 0,
    "Owner: The limit cannot be equal to zero");
        _ticketLimit = _amount;
        emit limitGamblers(msg.sender, _ticketLimit);
        return true;
    }

    function buyTicket(address _account) public payable whenNotPaused returns(bool){
    if (_gamblers.length >= _ticketLimit){
            roulette();
            }else{
                require(msg.value >= _ticketValue,
                "Owner: The amount must be equal to or greater than the suggested ticket price");
                ticketBox(_account);
                emit newGambler(_account, _lotteryID);}
                return true;
    }

    function ticketBox(address _account) internal virtual {
        _gamblers.push(payable(_account));

        _tikcketsSold ++;
        _totalTikcketsSold ++;
        _tikcketsAvaliable --;
    }

    function spinRoulette() external whenPaused onlyDeveloper returns(bool){
        if (_gamblers.length != 0){
            roulette();
            }else{
                revert(
                    "Owner: Insufficient amount of gamblers");}
                return true;
    }

    function roulette() internal virtual {
        getNumber();
        uint256 index = getNumber() % _gamblers.length;
        uint256 premium = address(this).balance;

        history memory newhistory = history(_gamblers[index], premium*payoutAward/maxValue);
        _loterryHistory[_lotteryID] = newhistory;

            _gamblers[index].transfer(premium*payoutAward/maxValue);
            payable(msgSender()).transfer(premium*payoutRate/maxValue);

        emit newWinner(_gamblers[index], _lotteryID);

        _lotteryID ++;
        _tikcketsAvaliable = _ticketLimit;
        _gamblers = new address payable[](0);
    }
    
}