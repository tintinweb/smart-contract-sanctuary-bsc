/**
 *Submitted for verification at BscScan.com on 2022-01-31
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.11; 

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event LotteryWin(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

contract LuckDuck is Context, IERC20, IERC20Metadata, Ownable {
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _isWhitelisted;

    uint256 private _totalSupply = 0;
    uint256 private constant _initialSupply = 1_000_000_000_000;

    string  private constant _name     = "Luck Duck";
    string  private constant _symbol   = "LDCK";
    uint8   private constant _decimals = 18;
    uint private randNonce = 0;
    uint256 public _txFee = 10; // 10 % of transaction amount
    uint256 private constant _rafflePercentage = 15; // 15 % of _txFee
    uint256 private constant _lotteryPercentage = 85; // 85 % of _txFee
    address private _raffleWallet = 0x7777777777777777777777777777777777777777; //Random wallet, used to store raffle lottery tokens

    enum Prize { LUCK_DUCK, SECOND, THIRD, FOURTH, BLANK }
    uint256 private constant TICKETS_MAX = 2000000;
    uint256 private constant LUCKY_NUMBER = 7;
    uint256 private constant MIN_TX_AMOUNT_FOR_TICKET = 1000;

    /* Raffle */
    address[] private _recentWinners;
    address[] private _tickets;
    uint private _randNonce = 0;
    uint256 private _lastRaffle;
    
    uint256 private constant TICKET_COST = 500_000 * 10 ** uint256(_decimals);
    uint256 private constant MIN_TICKETS = 1;
    uint256 private constant MAX_TICKETS = 10;
    uint256 private constant WINNER_COUNT = 5;
    uint256 private constant JACKPOT_BURN_PERCENTAGE = 5;

    constructor() {
        _lastRaffle = block.timestamp;
        _mint(_msgSender(), _initialSupply * 10 ** uint256(_decimals));
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        uint256 txFee = calculateTxFee(amount);
        uint256 transferAmount = amount;
        if (sender != owner() && recipient != owner() && !isWhitelisted(sender) && !isWhitelisted(recipient)) {
            transferAmount = transferAmount - txFee;
            uint256 lotteryFee = txFee * _lotteryPercentage / 100;
            uint256 raffleFee = txFee * _rafflePercentage / 100;

            _balances[address(this)] = _balances[address(this)] + lotteryFee;
            _balances[_raffleWallet] = _balances[_raffleWallet] + raffleFee;
        }
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += transferAmount;

        if (!isWhitelisted(sender) && !recipient.isContract()) {
            if (sender.isContract()) {
                transactionLottery(recipient, amount);
            } else {
                transactionLottery(sender, amount);
            }
        }

        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Calculates transaction fee
     *
     * @return Token fee
     */
    function calculateTxFee(uint256 _amount) private view returns (uint256) {
        return _amount * _txFee / 100;
    }

    /**
     * @dev Transfers prize tokens to winner's wallet
     *
     * Requirements:
     *
     * - Transfer sender must be this contract or `_raffleWallet`
     * - Recipient must not be the zero address
     * - Sender balance must be at least `amount`
     */
    function _transferLotteryWin(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender == address(this) || sender == _raffleWallet, "ERC20: transfer sender not lottery or raffle");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit LotteryWin(sender, recipient, amount);
    }

    /**
     * @dev Draws a lottery ticket each transaction and distributes prize tokens
     *
     */
    function transactionLottery(address account, uint256 amount) internal virtual {
        if (amount < MIN_TX_AMOUNT_FOR_TICKET) {
            return;
        }

        uint256 ticket = drawLotteryTicket();
        Prize win = evaluateTicket(ticket);

        if (win == Prize.LUCK_DUCK) {
            _transferLotteryWin(address(this), account, getWinningAmount(win, amount));
        } else if (win == Prize.SECOND) {
            _transferLotteryWin(address(this), account, getWinningAmount(win, amount));
        } else if (win == Prize.THIRD) {
            _transferLotteryWin(address(this), account, getWinningAmount(win, amount));
        } else if (win == Prize.FOURTH) {
            _transferLotteryWin(address(this), account, getWinningAmount(win, amount));
        }
    }

    /**
     * @dev Calculates the amount of tokens won for a specific prize
     *
     * NOTE: Maximum tokens is the current token balance
     * 
     * @return Tokens won
     */
    function getWinningAmount(Prize prize, uint256 amount) internal view returns (uint256) {
        uint256 contractBalance = balanceOf(address(this));
        uint256 win = 0;

        if (prize == Prize.LUCK_DUCK) {
            win = amount * 10000;
        } else if (prize == Prize.SECOND) {
            win = amount * 500;
        } else if (prize == Prize.THIRD) {
            win = amount * 5;
        } else if (prize == Prize.FOURTH) {
            win = amount;
        }

        if (win > contractBalance) {
            return contractBalance;
        }
        return win;
    }

    /**
     * @dev Evaluates whether the lottery ticket has a prize
     *
     * @return Prize
     */
    function evaluateTicket(uint256 ticket) internal pure returns (Prize) {
        if (ticket == LUCKY_NUMBER) {
            return Prize.LUCK_DUCK;
        } else if (ticket >= 10 && ticket <= 30) {
            return Prize.SECOND;
        } else if (ticket >= 1000 && ticket <= 11000) {
            return Prize.THIRD;
        } else if (ticket >= 100000 && ticket <= 200000) {
            return Prize.FOURTH;
        }
        return Prize.BLANK;
    }

    /**
     * @dev Draws a random ticket of lottery ticket pool
     *
     * @return Random ticket
     */
    function drawLotteryTicket() internal returns (uint256) {
        return randTicket(TICKETS_MAX);
    }

    /**
     * @dev Picks a random ticket
     *
     * @return Random ticket 
     */
    function randTicket(uint _modulus) internal virtual returns (uint) {
        randNonce++; 
        return uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _modulus;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Revokes whitelist status
     *
     */
    function excludeFromWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = false;
    }
    
    /**
     * @dev Whitelists `account`
     *
     */
    function includeInWhitelist(address account) public onlyOwner {
        _isWhitelisted[account] = true;
    }

    /**
     * @dev Whitelist status of `account`
     *
     * @return Whether account is whitelisted
     */
    function isWhitelisted(address account) public view returns (bool) {
        return _isWhitelisted[account];
    }
    
    /**
     * @dev Winners of last raffle
     *
     * @return the winners
     */
    function recentWinners() public view returns (address[] memory) {
        return _recentWinners;
    }

    /**
     * @dev Jackpot for the current raffle
     *
     * @return tokens in jackpot
     */
    function raffleJackpot() public view returns (uint256) {
        return balanceOf(_raffleWallet);
    }

    /**
     * @dev Jackpot for the current lottery
     *
     * @return tokens in jackpot
     */
    function lotteryJackpot() public view returns (uint256) {
        return balanceOf(address(this));
    }

    /**
     * @dev Number of sold tickets for current raffle
     *
     * @return the number of tickets
     */
    function raffleTicketsSold() public view returns (uint256) {
        return _tickets.length;
    }

    /**
     * @dev Buys `amount` tickets to entry raffle
     *
     * Requirements:
     *
     * - `amount` is limited to a ticket maximum per transaction
     */
    function buyTickets(uint amount) public {
        require(amount >= MIN_TICKETS && amount <= MAX_TICKETS);
        transferRaffleTicket(_msgSender(), amount * TICKET_COST);

        for (uint count = 0; count < amount; count++) {
            _tickets.push(_msgSender());
        }
    }

    /**
     * @dev Raffles 5 winners for the current raffle jackpot
     *
     * NOTE: Raffle winners are saved until next raffle and tickets are reset
     *
     * Requirements:
     *
     * - `_lastRaffle` must be at least a week ago
     * - At least one raffle ticket needs to be bought
     */
    function raffle() public {
        require(block.timestamp - _lastRaffle >= 1 weeks, "LuckDuckRaffle: can raffle only once a week");
        require(_tickets.length > 0, "LuckDuckRaffle: no raffle entries");
        _lastRaffle = block.timestamp;
        delete _recentWinners;

        uint256 tokenJackpot = raffleJackpot();
        uint256 tokenBurn = tokenJackpot * JACKPOT_BURN_PERCENTAGE / 100;
        uint256 tokenWin = (tokenJackpot - tokenBurn) / WINNER_COUNT;
        
        for (uint count = 0; count < WINNER_COUNT; count++) {
            uint ticketIndex = randTicket(_tickets.length);
            address winner = _tickets[ticketIndex];
            _transferLotteryWin(_raffleWallet, winner, tokenWin);
            _recentWinners.push(winner);
        }

        burn(tokenBurn);
        delete _tickets;
    }

    /**
     * @dev Transfers raffle ticket costs to `_raffleWallet`
     *
     */
    function transferRaffleTicket(
        address sender,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = _balances[sender];
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[_raffleWallet] += amount;
    }

    /**
     * @dev Burns `tokenAmount` tokens for `_raffleWallet`.
     *
     * Requirements:
     *
     * - `_raffle_Wallet` must have a balance of at least `tokenAmount`
     */
    function burn(uint256 tokenAmount) private {
        require(_balances[_raffleWallet] >= tokenAmount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[_raffleWallet] = _balances[_raffleWallet] - tokenAmount;
        }
        _totalSupply = _totalSupply - tokenAmount;
    }
}