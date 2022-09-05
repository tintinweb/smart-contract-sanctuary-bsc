/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: Unlicensed

/**
 * Feature name: YY-Lottery V2
 * Type: Utility
 * Network: BSC
 * Related token: YinYang
 * Related token address: 0xa7Da7D9E572417Fca8a6CFE9a8F60a8a661E16ce (mainnet)
 */

pragma abicoder v2;
pragma solidity ^0.7.4;

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IYYToken {
    function owner() external pure returns (address);
    function balanceOf(address who) external view returns (uint256);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract LotteryYinYang is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address ZERO = 0x0000000000000000000000000000000000000000;

    struct Lottery {
        uint id;
        uint256 startedAt;
        uint256 expiresAt;
        uint totalTicketsAmount;
        uint playersAmount;
        bool locked;
        uint winnersAmount;
        uint256 bnbPrizes;
        uint256 yyPrizes;
    }

    struct Participant {
        address wallet;
        uint ticketsAmount;
        uint256 createdAt;
        uint256 updatedAt;
    }

    struct Winner {
        address wallet;
        uint256 prizeValue;
        string pos;
    }

    struct Locked {
        address wallet;
        uint256 tokensAmount;
        uint expiresAt;
        uint256 bonusTokensAmount;
        uint tickets;
    }

    modifier isAuth() {
        require(owner() == msg.sender, "Auth: caller is not the owner");
        _;
    }

    modifier V1Migration() {
        require(_V1Migration == msg.sender, "Only V1 Migration");
        _;
    }

    uint256 public bnbPricePerTicket;
    uint256 public yyPricePerTicket;
    uint public lotteryInMinutes;
    uint public nextLotteryInMinutes;
    uint private nextBurn;

    mapping (uint => Lottery) public lotteries;
    mapping (uint => Participant[]) public participants;
    mapping (uint => Winner[]) public leaderboard;
    mapping (uint => Locked) public lockedTokens;
    mapping (address => uint) public lockedTokensIndex;

    uint public lotteryIndex;
    uint public lockedWalletIndex;

    address public burnWallet;
    address public yyTokenAddress;
    IYYToken public yyToken;

    uint256 public totalLockedTokens;

    bool private _inLock;
    bool public _emergencyLock;

    address public _V1Migration;

    modifier inLock() {
        require(_inLock == false, "_"); _;
    }

    constructor() {
        lotteryIndex = 0;
        lockedWalletIndex = 0;
        _V1Migration = ZERO;

        _transferOwnership(msg.sender);

        burnWallet = address(DEAD);
        yyTokenAddress = 0xa7Da7D9E572417Fca8a6CFE9a8F60a8a661E16ce;
        yyToken = IYYToken(yyTokenAddress);

        bnbPricePerTicket = 10000000000000000;
        yyPricePerTicket = 100000;
        lotteryInMinutes = 4 hours;
        nextLotteryInMinutes = 15 minutes;
        nextBurn = block.timestamp.add(24 hours);

        _inLock = false;
        _emergencyLock = false;

        yyToken.approve(address(this), 99999999999999999999999999999999999999999999999999999999999999999999);
    }

    function setV1MigrationAddress(address _addr) public isAuth {
        _V1Migration = _addr; 
    }

    function yyVaultAvailable() internal view returns(uint256) {
        uint256 _value = yyToken.balanceOf(address(this)).sub(totalLockedTokens);
        if(_value > 0) {
            return _value;
        }

        return 0;
    }

    function emergencyUnlockTokens() public inLock {
        require(_emergencyLock == false, "use_unlockTokens");

        _inLock = true;
        uint walletId = lockedTokensIndex[msg.sender];

        if(lockedTokens[walletId].wallet != address(ZERO)) {
            uint256 _tokensAmount = lockedTokens[walletId].tokensAmount;
            uint256 _finalTokensAmount = _tokensAmount.sub(_tokensAmount.div(5));

            yyToken.transferFrom(address(this), msg.sender, _finalTokensAmount);
            yyToken.transferFrom(address(this), address(DEAD), _tokensAmount.sub(_finalTokensAmount));
            totalLockedTokens = totalLockedTokens.sub(_tokensAmount);
            removeLockedWallet(walletId, msg.sender);
        }
        _inLock = false;
    }

    function unlockTokens() public inLock { 
        _inLock = true;
        uint walletId = lockedTokensIndex[msg.sender];

        if(lockedTokens[walletId].wallet != address(ZERO)) {
            if(_emergencyLock == false) {
                require(block.timestamp >= lockedTokens[walletId].expiresAt, "not_expired_yet");
            }

            yyToken.transferFrom(address(this), msg.sender, lockedTokens[walletId].tokensAmount);
            totalLockedTokens = totalLockedTokens.sub(lockedTokens[walletId].tokensAmount);
            removeLockedWallet(walletId, msg.sender);
        }
        _inLock = false;
    }

    function removeLockedWallet(uint _walletId, address _sender) internal {
        uint _newId = 0;

        for(uint i = _walletId; i < lockedWalletIndex; i++) {
            if(i == _walletId) {
                delete lockedTokens[_walletId];
                continue;
            }
            _newId = i - 1;
            lockedTokens[_newId] = lockedTokens[i]; 
            lockedTokensIndex[lockedTokens[i].wallet] = _newId;
        }

        delete lockedTokensIndex[_sender];
        lockedWalletIndex--;
    }

    function lockTokens(uint _days, uint256 _ticketsAmount) public { 
        _inLock = true;
        require(_days >= 1 && _days <= 7, "wrong_days_range");
        require(_ticketsAmount >= 1, "wrong_tickets_amount");

        uint256 takeTokensAmount = yyPricePerTicket.mul(_ticketsAmount);

        require(yyToken.balanceOf(address(msg.sender))>=takeTokensAmount, "wrong_yy_amount");
        yyToken.transferFrom(msg.sender, address(this), takeTokensAmount);

        uint256 _bonusTokensAmount = takeTokensAmount;

        uint walletId = lockedTokensIndex[msg.sender];

        if(_days == 2) {
            _bonusTokensAmount = _bonusTokensAmount.add(_bonusTokensAmount.div(2));
        }else if(_days == 3) {
            _bonusTokensAmount = _bonusTokensAmount.mul(2);
        }else if(_days == 4) {
            _bonusTokensAmount = (_bonusTokensAmount.mul(2)).add(_bonusTokensAmount.div(2));
        }else if(_days == 5) {
            _bonusTokensAmount = _bonusTokensAmount.mul(3);
        }else if(_days == 6) {
            _bonusTokensAmount = (_bonusTokensAmount.mul(3)).add(_bonusTokensAmount.div(2));
        }else if(_days == 7) {
            _bonusTokensAmount = _bonusTokensAmount.mul(4);
        }

        if(walletId==0) {
            lockedTokensIndex[msg.sender] = lockedWalletIndex;
            lockedTokens[lockedWalletIndex] = Locked(
                msg.sender,
                takeTokensAmount,
                block.timestamp.add(_days.mul(24 hours)),
                _bonusTokensAmount,
                _bonusTokensAmount.div(yyPricePerTicket)
            );

            lockedWalletIndex++;
        }else{
            lockedTokens[walletId].tokensAmount = lockedTokens[walletId].tokensAmount.add(takeTokensAmount);
            lockedTokens[walletId].expiresAt = lockedTokens[walletId].expiresAt.add(_days.mul(24 hours));
            lockedTokens[walletId].bonusTokensAmount = lockedTokens[walletId].bonusTokensAmount.add(_bonusTokensAmount);
            lockedTokens[walletId].tickets = lockedTokens[walletId].tickets.add(_bonusTokensAmount.div(yyPricePerTicket));
        }

        totalLockedTokens = totalLockedTokens.add(takeTokensAmount);
        _inLock = false;
    }

    function buyTickets(uint _ticketsAmount) public payable { 
        require(lotteries[lotteryIndex].locked == false && lotteries[lotteryIndex].expiresAt > block.timestamp, "_");

        uint256 _value = _ticketsAmount.mul(bnbPricePerTicket);

        require(_value == msg.value, "wrong_value");

        payable(this).transfer(msg.value);

        uint _playersAmount = lotteries[lotteryIndex].playersAmount;
        address _wallet = msg.sender;
        bool _found = false;

        for(uint i = 0; i < _playersAmount; i++) {
            if(participants[lotteryIndex][i].wallet == _wallet) {
                participants[lotteryIndex][i].ticketsAmount = 
                    participants[lotteryIndex][i].ticketsAmount.add(_ticketsAmount);
                participants[lotteryIndex][i].updatedAt = block.timestamp;
                _found = true;

                lotteries[lotteryIndex].totalTicketsAmount 
                    = lotteries[lotteryIndex].totalTicketsAmount.add(_ticketsAmount);
                break;
            }
        }

        if(!_found) {
            participants[lotteryIndex].push(
                Participant(
                    _wallet,
                    _ticketsAmount,
                    block.timestamp,
                    block.timestamp
                )
            );
            lotteries[lotteryIndex].totalTicketsAmount 
                = lotteries[lotteryIndex].totalTicketsAmount.add(_ticketsAmount);
            lotteries[lotteryIndex].playersAmount++;
        }
    }

    function startLottery() public {
        require(lotteries[lotteryIndex].locked == true && block.timestamp >= lotteries[lotteryIndex].startedAt, "_");
        participants[lotteryIndex];
        leaderboard[lotteryIndex];

        uint _totalTickets = 0;
        uint _totalPlayers = 0;

        for(uint i = 0; i < lockedWalletIndex+1; i++) {
            if(lockedTokens[i].expiresAt > block.timestamp) {
                participants[lotteryIndex].push(
                    Participant(
                        lockedTokens[i].wallet,
                        lockedTokens[i].tickets,
                        block.timestamp,
                        block.timestamp
                    )
                );

                _totalPlayers++;
                _totalTickets = _totalTickets.add(lockedTokens[i].tickets);
            }
        }

        lotteries[lotteryIndex].playersAmount = _totalPlayers;
        lotteries[lotteryIndex].totalTicketsAmount = _totalTickets;

        lotteries[lotteryIndex].locked = false;

        if(block.timestamp >= nextBurn) {
            uint256 totalYY = yyVaultAvailable();
            if(totalYY > 0) {
                uint256 _toBurn = totalYY.sub(totalYY.div(5));
                yyToken.transferFrom(address(this), address(DEAD), _toBurn);

                nextBurn = block.timestamp.add(24 hours);      
            }
        }
    }

    function endLottery() public {
        require(lotteries[lotteryIndex].locked == false && block.timestamp >= lotteries[lotteryIndex].expiresAt, "_");
        uint playersAmount = lotteries[lotteryIndex].playersAmount;
        uint totalTicketsAmount = lotteries[lotteryIndex].totalTicketsAmount;
        uint ticketNumber = 0;
        address[] memory ticketsList = new address[](playersAmount+1);

        for (uint i = 0; i < playersAmount; i++) {
            ticketsList[ticketNumber] = participants[lotteryIndex][i].wallet;
            ticketNumber++;
        }

        for (uint i = 0; i < ticketsList.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp.add(totalTicketsAmount)))) % (ticketsList.length - i);
            address temp = ticketsList[n];
            ticketsList[n] = ticketsList[i];
            ticketsList[i] = temp;
        }

        uint[] memory topWinners = pickTopWinners(ticketsList.length);
        uint[] memory winners = pickWinners(ticketsList.length, topWinners[0]);

        address payable winnerWallet;
        uint256 totalBnbPrizes = address(this).balance;
        uint256 prizeToWinner;

        totalBnbPrizes = totalBnbPrizes.sub((totalBnbPrizes.div(5)).div(2)); //10% to next round
        totalBnbPrizes = totalBnbPrizes.sub(10000000000000000); //0.01 

        uint _winnersAmount = 0;

        if(totalBnbPrizes >= 10000000000000000) { //min. 0.01 
            lotteries[lotteryIndex].bnbPrizes = totalBnbPrizes;
            for (uint i = 0; i < topWinners.length; i++) {
                if(address(ticketsList[topWinners[i]]) == address(ZERO)) {
                    continue;
                }
                winnerWallet = payable(ticketsList[topWinners[i]]);

                if(i==0) {
                    prizeToWinner = (totalBnbPrizes.div(5)).mul(3); //60%
                    leaderboard[lotteryIndex].push(Winner(
                        winnerWallet, prizeToWinner, "1st"
                    ));
                }else if(i==1) {
                    prizeToWinner = (totalBnbPrizes.div(5)); //20%
                    leaderboard[lotteryIndex].push(Winner(
                        winnerWallet, prizeToWinner, "2nd"
                    ));
                }else if(i==2) {
                    prizeToWinner = (totalBnbPrizes.div(5)).div(2); //10%
                    leaderboard[lotteryIndex].push(Winner(
                        winnerWallet, prizeToWinner, "3rd"
                    ));
                }
                payable(winnerWallet).transfer(prizeToWinner.sub(1000000000));
                _winnersAmount++;
            }
        }

        uint256 totalYYPrizes = yyVaultAvailable();

        if(totalYYPrizes > 0) {
            prizeToWinner = (totalYYPrizes.div(5)).div(10); //20%/10

            if(prizeToWinner >= 500000) { //min. 0.5 YY token per wallet to pay
                uint _yyWinners = 0;
                for (uint i = 0; i < winners.length; i++) {
                    if(address(ticketsList[winners[i]]) == address(ZERO)) {
                        continue;
                    }
                    leaderboard[lotteryIndex].push(Winner(
                        address(ticketsList[winners[i]]), prizeToWinner, "yy"
                    ));
                    yyToken.transferFrom(address(this), address(ticketsList[winners[i]]), prizeToWinner);
                    _winnersAmount++;
                    _yyWinners++;
                }

                lotteries[lotteryIndex].yyPrizes = prizeToWinner.mul(_yyWinners);
            }
        }

        lotteries[lotteryIndex].winnersAmount = _winnersAmount;

        lotteryIndex = lotteryIndex + 1;

        lotteries[lotteryIndex] = Lottery(
            lotteryIndex, 
            block.timestamp.add(nextLotteryInMinutes), 
            block.timestamp.add(lotteryInMinutes), 
            0, 
            0,
            true,
            0,
            0,
            0
        );
    }

    function initLottery() public isAuth {
        require(lotteryIndex==2&&lotteries[2].locked==true, "started");

        leaderboard[lotteryIndex];
        lotteries[lotteryIndex].locked = false;
    }

    function _migrateFromV1Lottery(
        uint id,
        uint256 startedAt,
        uint256 expiresAt,
        uint totalTicketsAmount,
        uint playersAmount,
        bool locked,
        uint winnersAmount,
        uint256 bnbPrizes,
        uint256 yyPrizes
    ) public V1Migration {
        lotteryIndex = id;

        lotteries[id] = Lottery(
            id, 
            startedAt, 
            expiresAt, 
            totalTicketsAmount, 
            playersAmount,
            locked,
            winnersAmount,
            bnbPrizes,
            yyPrizes
        );
    }

    function _migrateFromV1Participant(
        uint lotteryId,
        address wallet,
        uint ticketsAmount,
        uint256 createdAt,
        uint256 updatedAt
    ) public V1Migration {
       participants[lotteryId].push(
            Participant(
                wallet,
                ticketsAmount,
                createdAt,
                updatedAt
            )
        );
    }

    function _migrateFromV1Winner(
        uint lotteryId,
        address wallet,
        uint256 prizeValue,
        string memory pos
    ) public V1Migration {
         leaderboard[lotteryId].push(
             Winner(
                wallet, 
                prizeValue, 
                pos
            )
        );
    }

    function lotteryLeaderboard(uint _lotteryId) public view returns(Winner[] memory) {
        return leaderboard[_lotteryId];
    }

    function currentLottery() public view returns(uint256, Lottery memory) {
        return (
            yyVaultAvailable().div(5),
            lotteries[lotteryIndex]
        );
    }

    function toBurn() public view returns(uint256) {
        return (yyVaultAvailable().div(5)).mul(4);
    }

    function myTickets(address _wallet) public view returns(uint) {
        uint _playersAmount = lotteries[lotteryIndex].playersAmount;
        for(uint i = 0; i < _playersAmount; i++) {
            if(participants[lotteryIndex][i].wallet == _wallet) {
                return participants[lotteryIndex][i].ticketsAmount;
            }
        }
        return 0;
    }

    function myLockedTokens() public view returns(Locked memory) {
        uint walletId = lockedTokensIndex[msg.sender];

        return lockedTokens[walletId];
    }

    function pickTopWinners(uint players) internal view returns(uint[] memory) {
        uint topWinner = uint(
            uint(
                keccak256(abi.encodePacked(block.difficulty, block.timestamp, msg.sender))
            ) % players
        );

        uint diff = players - topWinner;

        if(diff < 3) {
            topWinner = topWinner - diff;
        }

        uint[] memory winners = new uint[](3);

        winners[0] = topWinner;
        winners[1] = topWinner+1;
        winners[2] = topWinner+2;

        return winners;
    }

    function pickWinners(uint players, uint controlWinner) internal view returns(uint[] memory) {
         uint winner = uint(
            uint(
                keccak256(abi.encodePacked(block.difficulty, controlWinner, msg.sender))
            ) % players
        );

        uint lastDiff = players - winner;

        if(lastDiff < 10) {
            winner = winner - lastDiff;
        }

        uint[] memory winners = new uint[](10);

        for(uint i = 0; i < 10; i++) {
            winners[i] = winner + i;
        }

        return winners;
    }

    function setNextLotterySettings(
        uint256 _bnbPricePerTicket, 
        uint256 _yyPricePerTicket,
        uint _lotteryInMinutes,
        uint _nextLotteryInMinutes
    ) public isAuth {
        bnbPricePerTicket = _bnbPricePerTicket;
        yyPricePerTicket = _yyPricePerTicket;
        lotteryInMinutes = _lotteryInMinutes;
        nextLotteryInMinutes = _nextLotteryInMinutes;     
    }

    function setEmergencyLock(bool _flag) public isAuth {
        _emergencyLock = _flag;
    }

    function resetInLock() public isAuth {
        _inLock = false;
    }

    function flushPrizesTo(address _wallet) public isAuth {
        payable(_wallet).transfer(address(this).balance);
    }

    function burnNow() public isAuth {
        uint256 totalYY = yyVaultAvailable();
        uint256 _toBurn = totalYY.sub(totalYY.div(5));
        yyToken.transferFrom(address(this), address(DEAD), _toBurn);
    }

    receive() external payable {}
}