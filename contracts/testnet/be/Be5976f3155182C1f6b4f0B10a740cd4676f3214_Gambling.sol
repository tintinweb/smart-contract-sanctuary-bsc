/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-12
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

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

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
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
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Gambling is Ownable {
    using SafeMath for uint256;
     
    struct gameInfo {
        uint256 period;
        uint256 count;
        uint256 price;
        uint256 award;
        bool isStart;
        uint256 saleCount;
        uint256 startTime;
        uint256 lotteryCode;
        address winner;
        uint256 openTime;
        uint256 typeNum;
    }
    
    struct betInfo {
        uint256 buyTime;
        address user;
        uint256 betCount;
    }

    struct userBet {
        uint256 betCount;
        gameInfo game;
    }

    mapping(uint256 => gameInfo) private _gameInfoMap;  //每期信息
    //mapping(string => betInfo) private _betUserMap;
    mapping(uint256 => uint256[]) private _typeList;    //类型对期号列表
    gameInfo[] private _totalList;
    mapping(uint256 => uint256) public _startPeriod;    //正在出售中的列表
    mapping(uint256 => mapping(address=>uint256)) public _userBetCount;
    mapping(address => uint256) public _awardCount;     //用户中奖次数
    mapping(uint256 => betInfo[]) private _betUserList;
    mapping(address => uint256[]) private _userBetList;  //用户购买的期号列表
    address public _opAddress = 0x472a89b8539362658FB00dF7fD258DcC3c2e4Eb5;
    address private _ownerAddress;
    //IERC20 private _token = IERC20(0x55d398326f99059fF775485246999027B3197955);
    IERC20 private _token = IERC20(0x2d609440e9156CB0C579f02dC248e849387fDb4f);
   // event BuyIDO(address user, uint256 numberOfToken, uint256 period);
   // event OpenLottery(address winner, uint256 period);

    constructor() {
        _ownerAddress = msg.sender;
    }
    
    function setOpAddress(address opAddress) public onlyOwner {
        _opAddress = opAddress;
    }

    function getTypePeriodList(uint256 typeNum) public view returns(gameInfo[] memory) {
        uint256[] memory periodList = _typeList[typeNum];
        gameInfo[] memory gameList = new gameInfo[](periodList.length);
        for (uint256 i = 0; i < periodList.length; i++) {
            gameList[i] = _gameInfoMap[periodList[i]];
        }
        return gameList;
    }

    function getBetUserList(uint256 period) public view returns(betInfo[] memory) {
        return _betUserList[period];
    }

    function getTotalList() public view returns(gameInfo[] memory) {
        return _totalList;
    }

    function getUserBetRecode(address user) public view returns(userBet[] memory) {
        uint256[] memory periodList = _userBetList[user];
       // mapping(uint256 => bool) memory existMap;
        userBet[] memory resList = new userBet[](periodList.length);
        for (uint256 i = 0; i < periodList.length; i++) {
            uint256 period = periodList[i];
            // if (existMap[period]) {continue;}
            // existMap[period] = true;
            userBet memory item = userBet({
                betCount: _userBetCount[period][user],
                game: _gameInfoMap[period]
            });
            resList[i] = item;
        }
        return resList;
    }
    
    function setNewGamble(uint256 typeNum, uint256 period, uint256 count, uint256 price, uint256 award) public returns(bool) {
        require(_opAddress==msg.sender||_ownerAddress==msg.sender, "donnot have permission.");
        require(price>0, "price need bigger than 0.");
        require(count>0, "count cannot be zero.");
        require(award>0, "award cannot be zero.");
        require(_gameInfoMap[period].count<=0, "period existed.");
        require(_startPeriod[typeNum]<=0, "period of type not end.");

        _typeList[typeNum].push(period);
        _startPeriod[typeNum] = period;
        _gameInfoMap[period] = gameInfo({
            period: period,
            count: count,
            price: price,
            isStart: true,
            saleCount: 0,
            award: award,
            startTime: block.timestamp,
            lotteryCode: 0,
            winner: address(0),
            openTime: 0,
            typeNum: typeNum
        });
        _totalList.push(_gameInfoMap[period]);

        return true;
    }

    function changeGameOver(uint256 typeNum, uint256 period) public returns(bool) {
        _gameInfoMap[period].isStart = false;
        _startPeriod[typeNum] = 0;
        return true;
    }

    function getGambleInfo(uint256 period) public view returns(gameInfo memory) {
        return _gameInfoMap[period];
    }

    function withdraw(address to, uint256 amount) public onlyOwner returns(bool) {
        _token.transfer(to, amount);
        return true;
    }

    function openLottery(uint256 typeNum) public returns(bool) {
        uint256 _currentPeriod = _startPeriod[typeNum];
        require(_currentPeriod > 0, "current game is over.");
        require(_gameInfoMap[_currentPeriod].isStart, "currnet game is over.");
        require(_opAddress==msg.sender||_ownerAddress==msg.sender, "donnot have permission.");

        gameInfo memory info = _gameInfoMap[_currentPeriod];
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        info.lotteryCode = random.mod(info.count);
        betInfo memory winBetInfo = _betUserList[_currentPeriod][info.lotteryCode];
        info.winner = winBetInfo.user;
        info.openTime = block.timestamp;
        info.isStart = false;
        _gameInfoMap[_currentPeriod] = info;
        _startPeriod[typeNum] = 0;
        _awardCount[winBetInfo.user] = _awardCount[winBetInfo.user].add(1);
        _token.transferFrom(address(this), winBetInfo.user, info.award.mul(10**18));
        
        return true;
    }

    function getBalance() public view returns(uint256) {
        return _token.balanceOf(address(this));
    }

    function buyIdo(uint256 typeNum, uint256 numberOfToken) public returns(bool) {
        uint256 _currentPeriod = _startPeriod[typeNum];
        require(_currentPeriod>0, "game not open");

        gameInfo memory info = _gameInfoMap[_currentPeriod];
        require(info.isStart, "game is over.");

        uint256 price = info.price;
        require(info.count.sub(info.saleCount)>0, "already sold out.");
        require(info.saleCount.add(numberOfToken) <= info.count, "count left not empty.");
       // require(numberOfToken.mul(price)>=msg.value, "price not enough.");

        uint256 amount = price.mul(numberOfToken).mul(10**18);
        _token.transferFrom(msg.sender, address(this), amount);

        uint256 buyed = _userBetCount[_currentPeriod][msg.sender];
        _userBetCount[_currentPeriod][msg.sender] = numberOfToken.add(buyed);
        _userBetList[msg.sender].push(_currentPeriod);
        // for (uint256 i = 0; i < numberOfToken; ++i) {
           
        // }
        _betUserList[_currentPeriod].push(betInfo({
            buyTime: block.timestamp,
            user: msg.sender,
            betCount: numberOfToken
        }));

        info.saleCount = info.saleCount.add(numberOfToken);
        if (info.count == info.saleCount) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
            info.lotteryCode = random.mod(info.count);
            betInfo memory winBetInfo = _betUserList[_currentPeriod][info.lotteryCode];
            info.winner = winBetInfo.user;
            info.openTime = block.timestamp;
            info.isStart = false;
            _startPeriod[typeNum] = 0;
            _awardCount[winBetInfo.user] = _awardCount[winBetInfo.user].add(1);
            _token.transfer(winBetInfo.user, info.award.mul(10**18));
        }
        _gameInfoMap[_currentPeriod] = info;

        return true;
    }
}