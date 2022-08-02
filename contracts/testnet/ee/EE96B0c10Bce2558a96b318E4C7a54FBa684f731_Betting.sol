/**
 *Submitted for verification at BscScan.com on 2022-08-02
*/

// File: artifacts/IToken.sol


pragma solidity ^0.8.0;

interface IToken {
    function approve(address spender, uint256 amount) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function burnFrom(address account, uint256 amount) external;
}

// File: artifacts/Betting.sol


pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Betting is Context, Ownable {
    struct Bet {
        uint256 Ticket;
        string[] Title;
        bool Parlay;
        uint256 amount;
        uint8 Result;
        string Reason;
        bool accept;
        uint256 To_winAmount;
        address Referrer;
        address Token_address;
    }

    struct MaxBetMaxWin {
        uint256 minBet;
        uint256 maximumBetAmounTotal;
        uint256 maximumBetAmount;
        uint256 maxWin;
    }

    mapping(address => mapping(uint256 => Bet)) public bets;
    mapping(address => MaxBetMaxWin) public maxBetMaxWins;
    mapping(address => mapping(address => uint256)) public amountUsers;
    mapping(address => address) Referrers;
    mapping(address => uint256) public bankrollAmounts;
    mapping(address => bool) paymentTokens;
    uint256 public referralPercent;
    mapping(address => uint256) vipReferrer;

    address public agentWallet;

    constructor() {
        paymentTokens[address(0x0)] = true;
        MaxBetMaxWin storage _maxbetmaxwin = maxBetMaxWins[address(0x0)];
        _maxbetmaxwin.minBet = 10**16;
        _maxbetmaxwin.maximumBetAmounTotal = 10000 * 10**18;
        _maxbetmaxwin.maximumBetAmount = 10000 * 10**18;
        _maxbetmaxwin.maxWin = 1000 * 10**16;
    }

    event NewBet(address _user_address, uint256 _ticket);
    event PlaceBet(
        uint256 indexed _ticket,
        string[] indexed _Title,
        bool indexed _Parlay
    );
    event AcceptBet(
        address indexed _user_address,
        uint256 indexed _Ticket,
        uint256 indexed _To_win
    );
    event GradeBet(
        address indexed _user_address,
        uint256 indexed _Ticket,
        uint8 indexed _Result
    );
    event RejectBet(
        address indexed _user_address,
        uint256 indexed _Ticket,
        string indexed _Reason
    );
    event SettleBet(uint8 indexed _Result, string indexed _Reason);

    modifier isPlacedBet(address _user, uint256 _ticket) {
        require(bets[_user][_ticket].amount > 0, "No placed bet");
        _;
    }

    modifier onlyAgent(address _wallet) {
        require(_wallet == agentWallet, "Not Agent Wallet");
        _;
    }

    function setAgentWallet(address _agentWallet) external onlyOwner {
        agentWallet = _agentWallet;
    }

    function placeBet(
        uint256 _ticket,
        string memory _Title,
        address _Referrer,
        address _Token_address,
        uint256 _Token_amount
    ) external payable {
        Bet storage _bet = bets[msg.sender][_ticket];
        _bet.Ticket = _ticket;
        _bet.Title.push(_Title);
        _bet.Parlay = false;
        _bet.Token_address = _Token_address;
        if (_Referrer != address(0x0)) {
            if (Referrers[msg.sender] != address(0x0))
                require(
                    Referrers[msg.sender] == _Referrer,
                    "Not same referrer"
                );
            else _bet.Referrer = _Referrer;
        }
        uint256 _addAmount = _Token_address == address(0x0)
            ? msg.value
            : _Token_amount;
        require(
            maxBetMaxWins[_Token_address].minBet <= _addAmount,
            "Less than minimumBetAmount."
        );
        require(
            maxBetMaxWins[_Token_address].maximumBetAmount >= _addAmount,
            "Exceeds maximumBetAmount."
        );
        if (_Token_address != address(0x0)) {
            require(
                paymentTokens[_Token_address] == true,
                "Not payment Token."
            );
            require(
                IToken(_Token_address).balanceOf(msg.sender) >= _Token_amount,
                "Not enough tokens for bet."
            );
            IToken(_Token_address).transferFrom(
                msg.sender,
                address(this),
                _Token_amount
            );
        }
        _bet.amount = _addAmount;
        emit NewBet(msg.sender, _ticket);
    }

    function placeBets(
        uint256[] memory _tickets,
        string[] memory _Titles,
        bool Parlay,
        address[] memory _Referrers,
        address[] memory _token_Addresses,
        uint256[] memory _amounts
    ) external payable {
        uint256 _totalBetAmount = 0;
        for (uint256 i = 0; i < _tickets.length; i++) {
            uint256 _ticketNo = Parlay ? _tickets[0] : _tickets[i];
            Bet storage _bet = bets[msg.sender][_ticketNo];
            _bet.Title.push(_Titles[i]);
            if (i >= 1 && Parlay == true) continue;
            _bet.Parlay = Parlay;
            _bet.Ticket = _tickets[i];
            _bet.Token_address = _token_Addresses[i];
            if (_Referrers[i] != address(0x0)) {
                if (Referrers[msg.sender] != address(0x0))
                    require(
                        Referrers[msg.sender] == _Referrers[i],
                        "Not same referrer"
                    );
                else _bet.Referrer = _Referrers[i];
            }
            uint256 _betAmount = _amounts[i];
            if(Parlay && _token_Addresses[0] == address(0x0))
                _betAmount = msg.value;
            require(
                maxBetMaxWins[_token_Addresses[i]].minBet <= _betAmount,
                "Less than minimumBetAmount."
            );
            require(
                maxBetMaxWins[_token_Addresses[i]].maximumBetAmount >=
                    _betAmount,
                "Exceeds maximumBetAmount."
            );
            require(
                _totalBetAmount + _betAmount <=
                    maxBetMaxWins[_token_Addresses[i]].maximumBetAmounTotal,
                "Exceeds maximumBetAmountTotal."
            );
            _totalBetAmount += _betAmount;
            if (_token_Addresses[i] != address(0x0)) {
                require(
                    paymentTokens[_token_Addresses[i]] == true,
                    "Not payment Token."
                );

                require(
                    IToken(_token_Addresses[i]).balanceOf(msg.sender) >=
                        _betAmount,
                    "Not enough tokens"
                );

                IToken(_token_Addresses[i]).transferFrom(
                    msg.sender,
                    address(this),
                    _betAmount
                );
            }
            _bet.amount = _betAmount;
        }
    }

    function depositBankroll(address _Token_address, uint256 _Token_amount)
        external
        payable
        onlyOwner
    {
        require(paymentTokens[_Token_address] == true, "Not payment token");
        if (_Token_address != address(0x0)) {
            uint256 _prevAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            IToken(_Token_address).transferFrom(
                owner(),
                address(this),
                _Token_amount
            );
            uint256 _afterAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            bankrollAmounts[_Token_address] += _afterAmount - _prevAmount;
        } else bankrollAmounts[address(0x0)] += msg.value;
    }

    function withdrawBankroll(uint256 _withdrawAmount, address _Token_address)
        external
        onlyOwner
    {
        require(
            bankrollAmounts[_Token_address] >= _withdrawAmount,
            "Not enough withdrawal tokens"
        );
        if (_Token_address != address(0x0)) {
            IToken(_Token_address).transfer(owner(), _withdrawAmount);
            bankrollAmounts[_Token_address] -= _withdrawAmount;
        } else {
            payable(owner()).transfer(_withdrawAmount);
            bankrollAmounts[address(0x0)] -= _withdrawAmount;
        }
    }

    function updateReferralSettings(uint256 _referralPercent)
        external
        onlyOwner
    {
        referralPercent = _referralPercent;
    }

    function setVIPreferrer(address _user_address, uint256 _Referral_percent)
        external
        onlyOwner
    {
        vipReferrer[_user_address] = _Referral_percent;
    }

    function removeVIPreferrer(address _user_address) external onlyOwner {
        vipReferrer[_user_address] = 0;
    }

    function setPaymentToken(address _token_address, bool _Active)
        external
        onlyOwner
    {
        paymentTokens[_token_address] = _Active;
    }

    function refundBet(address _user_address, uint256 _Ticket)
        external
        onlyAgent(msg.sender)
        isPlacedBet(_user_address, _Ticket)
    {
        Bet storage _bet = bets[_user_address][_Ticket];
        payable(_user_address).transfer(_bet.amount);
        _bet.amount = 0;
    }

    function acceptBet(
        address _user_address,
        uint256 _Ticket,
        uint256 _To_win
    ) external onlyAgent(msg.sender) {
        Bet storage _bet = bets[_user_address][_Ticket];
        require(
            _To_win <= maxBetMaxWins[_bet.Token_address].maxWin,
            "To_win exceeds maxWin"
        );
        _bet.accept = true;
        _bet.To_winAmount = _To_win;

        emit AcceptBet(_user_address, _Ticket, _To_win);
    }

    function rejectBet(
        address _user_address,
        uint256 _Ticket,
        string memory _Reason
    ) external onlyAgent(msg.sender) isPlacedBet(_user_address, _Ticket) {
        delete bets[_user_address][_Ticket];
        emit RejectBet(_user_address, _Ticket, _Reason);
    }

    function settleBet(
        address _user_address,
        uint256 _Ticket,
        uint8 _Result,
        uint256 _To_win,
        string memory _Reason
    ) external onlyAgent(msg.sender) isPlacedBet(_user_address, _Ticket) {
        Bet storage _bet = bets[_user_address][_Ticket];
        _bet.Result = _Result;
        _bet.Reason = _Reason;
        require(_bet.To_winAmount >= _To_win, "New toWin amount exceeds old");
        _bet.To_winAmount = _To_win;
        address _refferAddress = Referrers[_user_address];
        //WIN
        //sends user bnb in the amount of the to_win value from acceptBet event for this ticket #. Deduct the to_win amount from bankrollAmount storage variable.
        if (_Result == 3) {
            uint256 _userAmount = _bet.amount;
            uint256 _refferAmount = 0;
            if (_refferAddress != address(0x0)) {
                if (vipReferrer[_refferAddress] != 0) {
                    _refferAmount =
                        (_userAmount * vipReferrer[_refferAddress]) /
                        10000;
                } else 
                    _refferAmount = (_userAmount * referralPercent) / 10000;
            }
            if (_bet.Token_address != address(0x0)) {
                if (_refferAmount != 0)
                    IToken(_bet.Token_address).transfer(
                        _refferAddress,
                        _refferAmount
                    );
                IToken(_bet.Token_address).transfer(_user_address, _bet.To_winAmount);
            } else {
                if (_refferAmount != 0)
                    payable(_refferAddress).transfer(_refferAmount);
                payable(_user_address).transfer(_bet.To_winAmount);
            }
            bankrollAmounts[_bet.Token_address] -= _bet.To_winAmount;
        }
        //PUSH
        //send the user just their bet amount back since it was a push.
        else if (_Result == 2) {
            uint256 _userAmount = _bet.amount;
            uint256 _refferAmount = 0;
            if (_refferAddress != address(0x0)) {
                if (vipReferrer[_refferAddress] != 0) {
                    _refferAmount =
                        (_userAmount * vipReferrer[_refferAddress]) /
                        10000;
                    _userAmount -= _refferAmount;
                } else {
                    _refferAmount = (_userAmount * referralPercent) / 10000;
                    _userAmount -= _refferAmount;
                }
            }
            if (_bet.Token_address != address(0x0)) {
                if (_refferAmount != 0)
                    IToken(_refferAddress).transfer(
                        _bet.Referrer,
                        _refferAmount
                    );
                IToken(_bet.Token_address).transfer(_user_address, _userAmount);
            } else {
                if (_refferAmount != 0)
                    payable(_refferAddress).transfer(_refferAmount);
                payable(_user_address).transfer(_userAmount);
            }
        }
        //LOSS
        //send user nothing, they lost. Add the bet amount the user lost to the bankrollAmount storage variable.
        else if (_Result == 1) {
            bankrollAmounts[_bet.Token_address] += _bet.amount;
            _bet.amount = 0;
        }
        //CANCELLED
        //send the user their bet amount back, the game or bet was cancelled.
        else if (_Result == 4) {
            if (_bet.Token_address != address(0x0))
                IToken(_bet.Token_address).transfer(_user_address, _bet.amount);
            else payable(_user_address).transfer(_bet.amount);
            _bet.amount = 0;
        }
        emit SettleBet(_Result, _Reason);
    }

    function updateMaxBetMaxWin(
        uint256 _minBet,
        uint256 _maximumBetAmountTotal,
        uint256 _maximumBetAmount,
        uint256 _maxWin,
        address _token_address
    ) external onlyOwner {
        MaxBetMaxWin storage _maxBetMaxWin = maxBetMaxWins[_token_address];
        _maxBetMaxWin.minBet = _minBet;
        _maxBetMaxWin.maximumBetAmounTotal = _maximumBetAmountTotal;
        _maxBetMaxWin.maximumBetAmount = _maximumBetAmount;
        _maxBetMaxWin.maxWin = _maxWin;
    }
}