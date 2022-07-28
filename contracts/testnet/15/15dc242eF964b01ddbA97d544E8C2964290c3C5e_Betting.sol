// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IToken.sol";

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
        string[][] Title;
        bool Parlay;
        uint256 amount;
        uint8 Result;
        string[] Reason;
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
    mapping(address => uint256) public amountUsers;
    uint256[] public amountTickets;
    uint256 public currentWin;
    mapping(address => uint256) public bankrollAmounts;
    uint256 public maximumBetAmountTotal;
    uint256 public maximumBetAmount;
    uint256 public maxWin;
    mapping(address => bool) paymentTokens;
    uint256 public referralPercent;
    mapping(address => uint256) vipReferrer;

    address private agentWallet;

    constructor() {}

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
        string[] indexed _Reason
    );
    event SettleBet(
        address indexed _user_address,
        uint256 indexed _Ticket,
        uint8 indexed _Result
    );

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
        string[] memory _Title,
        address _Token_address,
        uint256 _Token_amount
    ) external payable {
        if(_Token_address != address(0x0))
            require(paymentTokens[_Token_address] == true, "Not payment Token.");
        Bet storage _bet = bets[msg.sender][_ticket];
        _bet.Title[0] = _Title;
        _bet.Parlay = false;
        _bet.Token_address = _Token_address;
        if (_Token_address != address(0x0)) {
            require(
                IToken(_Token_address).balanceOf(msg.sender) >= _Token_amount,
                "Not enough tokens"
            );
            uint256 _prevAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            IToken(_Token_address).transferFrom(
                msg.sender,
                address(this),
                _Token_amount
            );
            uint256 _afterAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            _bet.amount = _afterAmount - _prevAmount;
        } else _bet.amount = msg.value;

        emit NewBet(msg.sender, _ticket);
    }

    function placeBets(
        uint256[] memory _tickets,
        string[][] memory _Titles,
        bool Parlay,
        address[] memory _token_Addresses,
        uint256[] memory _amounts
    ) external payable {
        if (Parlay == true) {
            if(_token_Addresses[0] != address(0x0))
                require(paymentTokens[_token_Addresses[0]] == true, "Not payment Token.");
            Bet storage _bet = bets[msg.sender][_tickets[0]];
            _bet.amount = _amounts[0];
            _bet.Ticket = _tickets[0];
            for (uint8 i = 0; i < _Titles.length; i++)
                _bet.Title[i] = _Titles[i];
            _bet.Parlay = true;
            _bet.Token_address = _token_Addresses[0];
            if (_token_Addresses[0] != address(0x0)) {
                require(
                    IToken(_token_Addresses[0]).balanceOf(msg.sender) >=
                        _amounts[0],
                    "Not enough tokens"
                );
                uint256 _prevAmount = IToken(_token_Addresses[0]).balanceOf(
                    address(this)
                );
                IToken(_token_Addresses[0]).transferFrom(
                    msg.sender,
                    address(this),
                    _amounts[0]
                );
                uint256 _afterAmount = IToken(_token_Addresses[0]).balanceOf(
                    address(this)
                );
                _bet.amount = _afterAmount - _prevAmount;
            } else _bet.amount = msg.value;
            // _bet.amount = _amounts[0];
        } else {
            for (uint8 i = 0; i < _tickets.length; i++) {
                if(_token_Addresses[i] != address(0x0))
                    require(paymentTokens[_token_Addresses[i]] == true,
                    "Not payment Token."
                );
                Bet storage _bet = bets[msg.sender][_tickets[i]];
                _bet.Parlay = false;
                _bet.Title[0] = _Titles[i];
                _bet.Ticket = _tickets[i];
                _bet.Token_address = _token_Addresses[i];
                if (_token_Addresses[i] != address(0x0)) {
                    require(
                        IToken(_token_Addresses[i]).balanceOf(msg.sender) >=
                            _amounts[i],
                        "Not enough tokens"
                    );
                    uint256 _prevAmount = IToken(_token_Addresses[i]).balanceOf(
                        address(this)
                    );
                    IToken(_token_Addresses[i]).transferFrom(
                        msg.sender,
                        address(this),
                        _amounts[i]
                    );
                    uint256 _afterAmount = IToken(_token_Addresses[i])
                        .balanceOf(address(this));
                    _bet.amount = _afterAmount - _prevAmount;
                } else _bet.amount = _amounts[i];
            }
        }
    }

    function depositBankroll(address _Token_address, uint256 _Token_amount)
        external
        payable
        onlyOwner
    {
        if (_Token_address != address(0x0)) {
            require(paymentTokens[_Token_address] == true, "Not payment token");
            uint256 _prevAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            IToken(_Token_address).transferFrom(
                msg.sender,
                address(this),
                _Token_amount
            );
            uint256 _afterAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            bankrollAmounts[_Token_address] = _afterAmount - _prevAmount;
        } else bankrollAmounts[address(0x0)] += msg.value;
    }

    function withdrawBankroll(
        uint256 _withdrawAmount,
        address _Token_address,
        uint256 _withdrawTokenAmount
    ) external onlyOwner {
        if (_Token_address != address(0x0)) {
            require(
                IToken(_Token_address).balanceOf(address(this)) >=
                    _withdrawTokenAmount,
                "Not enough withdrawal tokens"
            );
            uint256 _prevAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            IToken(_Token_address).transfer(owner(), _withdrawTokenAmount);
            uint256 _afterAmount = IToken(_Token_address).balanceOf(
                address(this)
            );
            bankrollAmounts[_Token_address] = _afterAmount - _prevAmount;
        } else {
            require(
                _withdrawAmount <= bankrollAmounts[address(0x0)],
                "Not enough funds"
            );
            payable(owner()).transfer(_withdrawAmount);
            bankrollAmounts[address(0x0)] -= _withdrawAmount;
        }
    }

    function refundBet(address _user_address, uint256 _Ticket)
        external
        onlyOwner
        isPlacedBet(_user_address, _Ticket)
    {
        Bet storage _bet = bets[_user_address][_Ticket];
        payable(_user_address).transfer(_bet.amount);
        _bet.amount = 0;
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

    function acceptBet(
        address _user_address,
        uint256 _Ticket,
        uint256 _To_win
    ) external onlyAgent(msg.sender) {
        Bet storage _bet = bets[_user_address][_Ticket];
        require(_To_win <= maxBetMaxWins[_bet.Token_address].maxWin, "To_win exceeds maxWin");
        _bet.accept = true;
        _bet.To_winAmount = _To_win;

        emit AcceptBet(_user_address, _Ticket, _To_win);
    }

    function rejectBet(
        address _user_address,
        uint256 _Ticket,
        string[] memory _Reason
    ) external onlyAgent(msg.sender) isPlacedBet(_user_address, _Ticket) {
        delete bets[_user_address][_Ticket];
        emit RejectBet(_user_address, _Ticket, _Reason);
    }

    function settleBet(
        address _user_address,
        uint256 _Ticket,
        uint8 _Result,
        uint256 _To_win,
        string[] memory _Reason
    ) external onlyAgent(msg.sender) isPlacedBet(_user_address, _Ticket) {
        Bet storage _bet = bets[_user_address][_Ticket];
        _bet.Result = _Result;
        _bet.Reason = _Reason;
        require(_bet.To_winAmount >= _To_win, "New toWin amount exceeds old");
        uint8 _result = bets[_user_address][_Ticket].Result;
        if (_result == 3) {
            if (_bet.Token_address != address(0x0)) {
                uint256 _userAmount = _bet.To_winAmount;
                uint256 _refferAmount = 0;
                uint256 _prevAmount = IToken(_bet.Token_address).balanceOf(
                    address(this)
                );
                if (_bet.Referrer != address(0x0)) {
                    if (vipReferrer[_bet.Referrer] != 0) {
                        _refferAmount =
                            (_userAmount * vipReferrer[_bet.Referrer]) /
                            10000;
                        _userAmount -= _refferAmount;
                    } else {
                        _refferAmount = (_userAmount * referralPercent) / 10000;
                        _userAmount -= _refferAmount;
                    }
                    IToken(_bet.Token_address).transfer(
                        _bet.Referrer,
                        _refferAmount
                    );
                }
                IToken(_bet.Token_address).transfer(_user_address, _userAmount);
                uint256 _afterAmount = IToken(_bet.Token_address).balanceOf(
                    address(this)
                );
                bankrollAmounts[_bet.Token_address] -= (_prevAmount -
                    _afterAmount);
            } else {
                uint256 _userAmount = _bet.To_winAmount;
                uint256 _refferAmount = 0;
                if (_bet.Referrer != address(0x0)) {
                    if (vipReferrer[_bet.Referrer] != 0) {
                        _refferAmount =
                            (_userAmount * vipReferrer[_bet.Referrer]) /
                            10000;
                        _userAmount -= _refferAmount;
                    } else {
                        _refferAmount = (_userAmount * referralPercent) / 10000;
                        _userAmount -= _refferAmount;
                    }
                    payable(_bet.Referrer).transfer(_refferAmount);
                }
                payable(_user_address).transfer(_userAmount);
                bankrollAmounts[address(0x0)] -= _bet.To_winAmount;
            }
        } else if (_result == 2) {
            if (_bet.Token_address != address(0x0)) {
                uint256 _userAmount = _bet.amount;
                uint256 _refferAmount = 0;
                uint256 _prevAmount = IToken(_bet.Token_address).balanceOf(
                    address(this)
                );
                if (_bet.Referrer != address(0x0)) {
                    if (vipReferrer[_bet.Referrer] != 0) {
                        _refferAmount =
                            (_userAmount * vipReferrer[_bet.Referrer]) /
                            10000;
                        _userAmount -= _refferAmount;
                    } else {
                        _refferAmount = (_userAmount * referralPercent) / 10000;
                        _userAmount -= _refferAmount;
                    }
                    IToken(_bet.Token_address).transfer(
                        _bet.Referrer,
                        _refferAmount
                    );
                }
                IToken(_bet.Token_address).transfer(_user_address, _userAmount);
                uint256 _afterAmount = IToken(_bet.Token_address).balanceOf(
                    address(this)
                );
                bankrollAmounts[_bet.Token_address] -= (_prevAmount -
                    _afterAmount);
                // _bet.amount = 0;
            } else {
                uint256 _userAmount = _bet.amount;
                uint256 _refferAmount = 0;
                if (_bet.Referrer != address(0x0)) {
                    if (vipReferrer[_bet.Referrer] != 0) {
                        _refferAmount =
                            (_userAmount * vipReferrer[_bet.Referrer]) /
                            10000;
                        _userAmount -= _refferAmount;
                    } else {
                        _refferAmount = (_userAmount * referralPercent) / 10000;
                        _userAmount -= _refferAmount;
                    }
                    payable(_bet.Referrer).transfer(_refferAmount);
                }
                payable(_user_address).transfer(_userAmount);
                bankrollAmounts[address(0x0)] -= _bet.amount;
                // _bet.amount = 0;
            }
        } else if (_result == 1) {
            if (_bet.Token_address != address(0x0)) {
                bankrollAmounts[_bet.Token_address] += _bet.amount;
                _bet.amount = 0;
            } else {
                bankrollAmounts[address(0x0)] += _bet.amount;
                _bet.amount = 0;
            }
        } else if (_result == 4) {
            payable(_user_address).transfer(_bet.amount);
        }
        emit SettleBet(_user_address, _Ticket, _result);
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

// SPDX-License-Identifier: UNLICENSED
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