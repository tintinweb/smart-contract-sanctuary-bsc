/**
 *Submitted for verification at BscScan.com on 2023-03-31
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;


// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.
library SafeMath {
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
}


library SafeCast {
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }

    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }

    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }

    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }

    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }

    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }

    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }

    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }

    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }

    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }

    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }

    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }

    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }

    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }

    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }

    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }

    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }

    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }

    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }

    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }
}


interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}


interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// safe transfer
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        // (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}



abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}


// owner
abstract contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'owner error');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


// Linkedin interface
interface ILinkedin {
    function mySuper(address user) external view returns (address);
    function myJuniors(address user) external view returns (address[] memory);
    function getSuperList(address user, uint256 list) external view returns (address[] memory);
}

// CardNFT interface
interface ICardNFT {
    function card(address account) external view returns(uint256);
    function mintCard(address account, uint256 grade) external;
    function burnCard(address account) external;
    function cardEteState(address account) external view returns(uint256,uint256);
    function changeCardEteState(address account, uint256 limit, uint256 taked) external;
}

// crystal interface
interface ICrystal {
    function crystalPriceUSDT() external view returns (uint256);
    function mintCrystal(address account, uint256 amount) external returns (bool);
    function burnCrystal(address account, uint256 amount) external returns (bool);
}

// PriceUSDTCalcuator interface
interface IPriceUSDTCalcuator {
    function tokenPriceUSDT(address token) external view returns(uint256);
    function lpPriceUSDT(address lp) external view returns(uint256);
}

// MyEvent interface
interface IMyEvent {
    function userDepositEvent(uint256 turn, uint256 issue, address user, uint256 cardNFT, uint256 tokenAmount) external;
    function teamEarnTakeEvent(uint256 turn, uint256 issue, address teamEarn, uint256 earnAmount, uint256 priceEte, uint256 totalUsdt, uint256 canTakeTime) external;
}

// mining v2
// tpis: eteUserToken=CETE, eteCardToken=BETE.
contract MiningV2 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // now turn(in turn). if is 10, as 1-10.
    uint256 public turn;
    // turn -> issue.
    mapping(uint256 => uint256) public issue;
    // turn -> issue-> issue details
    mapping(uint256 => mapping(uint256 => IssueMsg)) private _IssueMsg;
    struct IssueMsg {
        uint256 totalUsdt;                    // value usdt total.
        uint256 userCount;                    // user deposit lp total.(only depoist eteUserToken).
        uint256 starCardCount;                // star card deposit lp total.
        uint64 startTime;                     // start deposit time.
        uint64 endTime;                       // end deposit time.
        uint64 canTakeTime;                   // can take time.
        // issue status.
        // 1 = not take principal. not take earn. not deposit full. 
        // 2 = not take principal. not take earn, depoist full.
        // 3 = can take principal and can take earn.
        // 4 = only can take principal.
        uint64 status;
        uint256 takedCount;   // taked count.
        uint256 usdtPriceETE; // usdt price ete. is 1e18 usdt = ? ete.
    }
    
    uint256 private immutable _dayTime;    // one day time. mainnet=86400, testnet=60.
    uint256 public oneIssueTime;           // one issue time. default is 7 day.
    address public ete;                    // ete contract address.
    address public eteUserToken;           // user deposit token.
    address public eteCardToken;           // card deposit token.
    address public cardNFT;                // card nft contract address.
    address public teamEarn;               // team earn contract address.
    address public leader;                 // leader address. harvest token address.
    address public leader2;                // leader address. earn token address.
    address public linkedin;               // linkedin address.
    address public priceUSDTCalcuator;     // price usdt calculator contract address.
    address public crystal;                // crystal contract address.
    uint256 public canRatio = 200;         // account can deposit one issue is ratio. default 200%%.
    uint256 public burnCrystalsRatio = 200;// burn crystal ratio. default is 200%%.
    bool public isOpen = true;             // depoist open or close. default is open.

    mapping(address => bytes32[]) public userOrders;  // account all order. (account address + trun + issue = order id).
    mapping(bytes32 => address) public orderOwnerOf;  // order id of account address.
    mapping(bytes32 => OrderMsg) public userOrderMsg; // order id -> order details.
    struct OrderMsg {
        uint128 count;       // depoist count. 
        uint128 takedAmount; // taked earn amount.
        uint64 cardNFT;      // deposit time is card. 
        uint64 turnOf;       // of turn
        uint64 issueOf;      // of issue
        uint64 isTaked;      // is taked. (0=not take, 3=taked principal + taked earn. 4=taked principal).
    }
    mapping(address => uint256) public cardDepositCount;   // card user deposit count.
    uint256 public cardDepositLimit = 10000*(1e18);        // card deposit eteCardToken limit.
    address public myEvent;                                // my event


    constructor(
        uint256 dayTime_,
        address ete_,
        address eteUserToken_,
        address eteCardToken_,
        address cardNFT_,
        address teamEarn_,
        address leader_,
        address leader2_,
        address linkedin_,
        address priceUSDTCalcuator_,
        address crystal_,
        address myEvent_
    ) {
        _dayTime = dayTime_;          // mainnet=86400, testnet=100。
        oneIssueTime = _dayTime * 5;  // default is 5 day.

        ete = ete_;
        eteUserToken = eteUserToken_;
        eteCardToken = eteCardToken_;
        cardNFT = cardNFT_;
        teamEarn = teamEarn_;
        leader = leader_;
        leader2 = leader2_;
        linkedin = linkedin_;
        priceUSDTCalcuator = priceUSDTCalcuator_;
        crystal = crystal_;
        myEvent = myEvent_;

        // default first turn first issue.
        turn = 1;
        issue[turn] = 1;
        // start first turn first issue.
        _startIssue(turn, issue[turn], 20000*(10**18));
    }


    event StartIssue(uint256 turn, uint256 issue, uint256 totalUsdt, uint256 startTime, uint256 endTime, uint256 canTakeTime);  // start new issue.
    event UserDeposit(uint256 turn, uint256 issue, address user, uint256 cardNFT, uint256 tokenAmount);      // account deposit.
    event UserTake(uint256 turn, uint256 issue, address user, uint256 tokenAmount, uint256 earnAmount);      // account take earn.
    event TeamEarnTake(uint256 turn, uint256 issue, address teamEarn, uint256 earnAmount, uint256 priceEte, uint256 totalUsdt, uint256 canTakeTime); // team earn.
    event SetNowIssueEndTime(uint256 turn, uint256 issue, uint256 oldEndTime, uint256 nowEndTime);           // change now issue end time.
    event TakeEarnBurnCard(address user, uint256 cardNFT, uint256 limit, uint256 taked);                     // taked earn then burn card.

    // set every issue time. next issue in force, if is 7 = 7 day.
    function setOneIssueTime(uint256 _dayNumber) public onlyOwner {
        require(_dayNumber > 0 && _dayNumber < 30, "time error");
        oneIssueTime = _dayTime * _dayNumber;
    }

    function setEte(address _ete) public onlyOwner {
        require(_ete != address(0), "0 address error");
        ete = _ete;
    }
    function setEteUserToken(address _eteUserToken) public onlyOwner {
        require(_eteUserToken != address(0), "0 address error");
        eteUserToken = _eteUserToken;
    }
    function setEteCardToken(address _eteCardToken) public onlyOwner {
        require(_eteCardToken != address(0), "0 address error");
        eteCardToken = _eteCardToken;
    }
    function setCardNFT(address _cardNFT) public onlyOwner {
        require(_cardNFT != address(0), "0 address error");
        cardNFT = _cardNFT;
    }
    function setTeamEarn(address _teamEarn) public onlyOwner {
        require(_teamEarn != address(0), "0 address error");
        teamEarn = _teamEarn;
    }
    function setLeader(address _leader) public onlyOwner {
        require(_leader != address(0), "0 address error");
        leader = _leader;
    }
    function setLeader2(address _leader2) public onlyOwner {
        require(_leader2 != address(0), "0 address error");
        leader2 = _leader2;
    }
    function setLinkedin(address _linkedin) public onlyOwner {
        require(_linkedin != address(0), "0 address error");
        linkedin = _linkedin;
    }
    function setPriceUSDTCalcuator(address _priceUSDTCalcuator) public onlyOwner {
        require(_priceUSDTCalcuator != address(0), "0 address error");
        priceUSDTCalcuator = _priceUSDTCalcuator;
    }
    function setCrystal(address _crystal) public onlyOwner {
        require(_crystal != address(0), "0 address error");
        crystal = _crystal;
    }
    function setMyEvent(address _myEvent) public onlyOwner {
        require(_myEvent != address(0), "0 address error");
        myEvent = _myEvent;
    }
    function setCanRatio(uint256 _canRatio) public onlyOwner {
        require(_canRatio > 0 && _canRatio < 10000, "canRatio error");
        canRatio = _canRatio;
    }
    function setBurnCrystalsRatio(uint256 _burnCrystalsRatio) public onlyOwner {
        require(_burnCrystalsRatio > 0 && _burnCrystalsRatio < 10000, "burnCrystalsRatio error");
        burnCrystalsRatio = _burnCrystalsRatio;
    }
    function setIsOpen(bool _isOpen) public onlyOwner {
        isOpen = _isOpen;
    }
    function setCardDepositLimit(uint256 _cardDepositLimit) public onlyOwner {
        cardDepositLimit = _cardDepositLimit;
    }


    // get ? turn ? issue details.
    function getIssueMsg(uint256 _turn, uint256 _issue) public view returns(IssueMsg memory) {
        return _IssueMsg[_turn][_issue];
    }

    // get all issue.
    function getAllIssue() public view returns(uint256[] memory) {
        uint256[] memory _allIssues = new uint256[](turn);
        for(uint256 i = 1; i <= turn; i++) {
            _allIssues[i-1] = issue[i];
        }
        return _allIssues;
    }

    // get all issue as details.
    function getAllIssueMsg() public view returns(IssueMsg[] memory) {
        uint256 totalIssue;
        for(uint256 i0 = 1; i0 <= turn; i0++) {
            totalIssue = totalIssue.add(issue[i0]);
        }
        IssueMsg[] memory _allIssuesMsg = new IssueMsg[](totalIssue);
        uint256 nowi = 0;
        for(uint256 i1 = 1; i1 <= turn; i1++) {
            uint256 _issue = issue[i1];
            for(uint256 i2 = 1; i2 <= _issue; i2++) {
                _allIssuesMsg[nowi++] = _IssueMsg[i1][i2];
            }
        }
        return _allIssuesMsg;
    }

    // get all issue and all issue details.
    function getAllIssueAndMsg() public view returns(uint256[] memory, IssueMsg[] memory) {
        uint256 totalIssue;
        uint256[] memory _allIssues = new uint256[](turn);
        for(uint256 i0 = 1; i0 <= turn; i0++) {
            _allIssues[i0-1] = issue[i0];
            totalIssue = totalIssue.add(issue[i0]);
        }
        IssueMsg[] memory _allIssuesMsg = new IssueMsg[](totalIssue);
        uint256 nowi = 0;
        for(uint256 i1 = 1; i1 <= turn; i1++) {
            uint256 _issue = issue[i1];
            for(uint256 i2 = 1; i2 <= _issue; i2++) {
                _allIssuesMsg[nowi++] = _IssueMsg[i1][i2];
            }
        }
        return (_allIssues, _allIssuesMsg);
    }

    // changge now issue end time.
    function setNowIssueEndTime(uint256 _newEndTime) public onlyOwner {
        uint256 _nowIssue = issue[turn];
        IssueMsg storage _nowIssueMsg = _IssueMsg[turn][_nowIssue];
        require(_newEndTime > block.timestamp, "time error 0");
        require(_newEndTime < _nowIssueMsg.canTakeTime, "time error 1");
        emit SetNowIssueEndTime(turn, _nowIssue, _nowIssueMsg.endTime, _newEndTime);
        _nowIssueMsg.endTime = SafeCast.toUint64(_newEndTime);
    }

    // start new turn. must last issue deposit not full and time end. (amount mul 1e18 zero)
    function startTurns(uint256 _totalUsdt) public onlyOwner {
        require(_totalUsdt > 1, "totao usdt error");

        uint256 _nowIssue = issue[turn];
        IssueMsg storage _nowIssueMsg = _IssueMsg[turn][_nowIssue];
        require(block.timestamp > _nowIssueMsg.endTime && _nowIssueMsg.status == 1, "not end");

        _nowIssueMsg.status = 4;
        if(_nowIssue > 1) _IssueMsg[turn][_nowIssue-1].status = 4;

        // start new issue.
        turn = turn + 1;
        issue[turn] = 1;
        _startIssue(turn, issue[turn], _totalUsdt);
    }

    // start new issue.
    function _startIssue(uint256 _turn, uint256 _issue, uint256 _totalUsdt) private {
        uint256 _third = _totalUsdt.div(2);
  
        uint256 _nowCanTakeTime;
        if(_issue == 1) {
            if(_turn > 1) {
                _nowCanTakeTime = oneIssueTime.add(_IssueMsg[_turn-1][issue[_turn-1]].canTakeTime);
            }else {
                _nowCanTakeTime = block.timestamp.add(oneIssueTime);
            }
        }else {
            _nowCanTakeTime = oneIssueTime.add(_IssueMsg[_turn][_issue-1].canTakeTime);
        }
        _nowCanTakeTime = _nowCanTakeTime >= block.timestamp.add(oneIssueTime) ? _nowCanTakeTime : block.timestamp.add(oneIssueTime);

        uint256 _etePirce = IPriceUSDTCalcuator(priceUSDTCalcuator).tokenPriceUSDT(ete);
        uint256 _usdtPriceETE = uint256(1e18).mul(1e18).div(_etePirce);
        _IssueMsg[_turn][_issue] = IssueMsg({
            totalUsdt: _totalUsdt,
            userCount: _third,
            starCardCount: _totalUsdt.sub(_third),
            startTime: SafeCast.toUint64(block.timestamp),
            endTime: SafeCast.toUint64(block.timestamp.add(oneIssueTime)),
            canTakeTime: SafeCast.toUint64(_nowCanTakeTime),
            status: 1,
            takedCount: 0,
            usdtPriceETE: _usdtPriceETE
        });


        emit StartIssue(_turn, _issue, _totalUsdt, block.timestamp, block.timestamp.add(oneIssueTime), _nowCanTakeTime);
    }

    // get order id details.
    function getOrdersMsg(bytes32 _order) public view returns(OrderMsg memory) {
        return userOrderMsg[_order];
    }

    // get account all order id
    function getUserOrdersAll(address _user) public view returns(bytes32[] memory) {
        return userOrders[_user];
    }

    // get account all order id details.
    function getUserOrdersMsgAll(address _user) public view returns(OrderMsg[] memory) {
        bytes32[] memory _userOrderAll = getUserOrdersAll(_user);
        OrderMsg[] memory _userOrderAllMsg = new OrderMsg[](_userOrderAll.length);

        for(uint256 i = 0; i < _userOrderAll.length; i++) {
            _userOrderAllMsg[i] = userOrderMsg[_userOrderAll[i]];
        }
        return _userOrderAllMsg;
    }

    // get account all order id and all order details.
    function getUserOrdersAndMsgAll(address _user) public view returns(bytes32[] memory, OrderMsg[] memory) {
        bytes32[] memory _userOrderAll = getUserOrdersAll(_user);
        OrderMsg[] memory _userOrderAllMsg = new OrderMsg[](_userOrderAll.length);

        for(uint256 i = 0; i < _userOrderAll.length; i++) {
            _userOrderAllMsg[i] = userOrderMsg[_userOrderAll[i]];
        }
        return (_userOrderAll, _userOrderAllMsg);
    }

    // user deposit
    function userDeposit(uint256 tokenAmount) public nonReentrant {
        require(isOpen, "not open");
        require(!isContract(msg.sender), "not user1");
        require(tx.origin == msg.sender, 'not user2');

        address _user = msg.sender;
        uint256 _cardNFT = ICardNFT(cardNFT).card(_user);
        require(_cardNFT != 1, "card is 1");
        uint256 _nowIssue = issue[turn];
        IssueMsg storage _nowIssueMsg = _IssueMsg[turn][_nowIssue];
        require(block.timestamp > _nowIssueMsg.startTime && block.timestamp < _nowIssueMsg.endTime, "time error");
        require(_nowIssueMsg.status == 1, "not deposit");  // must is not deposit full.

        // calculate can deposit amount.
        address depositTokenAddress = _cardNFT == 2 ? eteCardToken : eteUserToken;
        if(_cardNFT == 2) {
            require(_nowIssueMsg.starCardCount > 0, "not count2");
            tokenAmount = _nowIssueMsg.starCardCount >= tokenAmount ? tokenAmount : _nowIssueMsg.starCardCount;
            _nowIssueMsg.starCardCount = _nowIssueMsg.starCardCount.sub(tokenAmount);
            // card deposit count
            cardDepositCount[_user] = cardDepositCount[_user].add(tokenAmount);
            require(cardDepositCount[_user] <= cardDepositLimit, "card deposit limit error");
        }else {
            require(_nowIssueMsg.userCount > 0, "not count0");
            tokenAmount = _nowIssueMsg.userCount >= tokenAmount ? tokenAmount : _nowIssueMsg.userCount;
            _nowIssueMsg.userCount = _nowIssueMsg.userCount.sub(tokenAmount);
        }

        // created order id.
        bytes32 _order = keccak256(abi.encode(_user,turn,_nowIssue));
        if(orderOwnerOf[_order] == address(0)) {
            // user first deposit
            userOrders[_user].push(_order);
            orderOwnerOf[_order] = _user;
            userOrderMsg[_order] = OrderMsg({count: SafeCast.toUint128(tokenAmount), takedAmount: 0, cardNFT: SafeCast.toUint64(_cardNFT), turnOf: SafeCast.toUint64(turn), issueOf: SafeCast.toUint64(_nowIssue), isTaked: 0});
        }else {
            // user not first deposit.
            userOrderMsg[_order].count = SafeCast.toUint128(SafeMath.add(userOrderMsg[_order].count, tokenAmount));
            require(_cardNFT == userOrderMsg[_order].cardNFT, "card NFT error");
        }
        // user deposit not > total can deposit ratio. 
        require(userOrderMsg[_order].count <= _nowIssueMsg.totalUsdt.mul(canRatio).div(10000), "deposit can ratio error");
        TransferHelper.safeTransferFrom(depositTokenAddress, _user, address(this), tokenAmount);
        
        emit UserDeposit(turn, _nowIssue, _user, _cardNFT, tokenAmount);
        IMyEvent(myEvent).userDepositEvent(turn, _nowIssue, _user, _cardNFT, tokenAmount);
        
        // if now issue deposit full.
        if(_nowIssueMsg.userCount == 0 && _nowIssueMsg.starCardCount == 0) {
            // now issue is 2.
            _IssueMsg[turn][_nowIssue].status = 2;
            if(_nowIssue > 1) {
                // if have last issue. last issue is 3.
                uint256 _lastIssue = _nowIssue-1;
                _IssueMsg[turn][_lastIssue].status = 3;

                // last issue start earn. teamEarn contract = 8%, leader address = 1%. leader2 address = 1%.
                uint256 _price = _IssueMsg[turn][_lastIssue].usdtPriceETE;
                uint256 _v0 = _IssueMsg[turn][_lastIssue].totalUsdt.mul(_price).div((1e18)).mul(800).div(10000);
                uint256 _v1 = _IssueMsg[turn][_lastIssue].totalUsdt.mul(_price).div((1e18)).mul(100).div(10000);
                uint256 _v2 = _IssueMsg[turn][_lastIssue].totalUsdt.mul(_price).div((1e18)).mul(100).div(10000);
                TransferHelper.safeTransfer(ete, teamEarn, _v0);
                TransferHelper.safeTransfer(ete, leader, _v1);
                TransferHelper.safeTransfer(ete, leader2, _v2);
                emit TeamEarnTake(turn, _lastIssue, teamEarn, _v0, _price, _IssueMsg[turn][_lastIssue].totalUsdt, _IssueMsg[turn][_lastIssue].canTakeTime);
                IMyEvent(myEvent).teamEarnTakeEvent(turn, _lastIssue, teamEarn, _v0, _price, _IssueMsg[turn][_lastIssue].totalUsdt, _IssueMsg[turn][_lastIssue].canTakeTime);
                _IssueMsg[turn][_lastIssue].takedCount = _v0.add(_v1).add(_v2); 
            }
           
            // start next issue.
            uint256 _nextIssue = _nowIssue + 1;
            issue[turn] = _nextIssue;
            uint256 _totalUsdt = _nowIssueMsg.totalUsdt.mul(30).div(100).add(_nowIssueMsg.totalUsdt);
            _startIssue(turn, _nextIssue, _totalUsdt);
        }
    }

    // user take. 
    // take principal or take principal and earn.
    function userTake(bytes32 order) public nonReentrant {
        OrderMsg storage _orderMsg = userOrderMsg[order];
        IssueMsg storage _orderIssueMsg = _IssueMsg[_orderMsg.turnOf][_orderMsg.issueOf];
        address _user = msg.sender;
        require(_orderIssueMsg.status == 3 || _orderIssueMsg.status == 4, "not take");    // must is can take.
        require(block.timestamp > _orderIssueMsg.canTakeTime, "time error");              // time must is can take time.
        require(_orderMsg.isTaked == 0, "already taked");                                 // must is not taked.
        require(orderOwnerOf[order] == _user, "not owner of");                            // order is user.
        // deposit time is card nft.
        address depositTokenAddress = _orderMsg.cardNFT == 0 ? eteUserToken : eteCardToken;

        // if 3. take principal and earn.
        uint256 _ratioMy;
        // total： 20%。 super： 3% = 1+(0.5*4)。 my：17% = (6,11)（12+22)。
        if(_orderMsg.cardNFT == 2) {
            _ratioMy = 1100;
            // card deposit count
            cardDepositCount[_user] = cardDepositCount[_user].sub(_orderMsg.count);
        }else {
            _ratioMy = 600;
        }

        // is 4. only is take principal.
        if(_orderIssueMsg.status == 4) {
            // result user lp.
            TransferHelper.safeTransfer(depositTokenAddress, _user, _orderMsg.count);

            _orderMsg.isTaked = 4;
            emit UserTake(_orderMsg.turnOf, _orderMsg.issueOf, _user, _orderMsg.count, 0);
            return; // over
        }

        uint256 _usdtPriceETE = _orderIssueMsg.usdtPriceETE;
        uint256 _valueEte = _usdtPriceETE.mul(_orderMsg.count).div(1e18);   // value ete.
        uint256 _earnMy = _valueEte.mul(2).mul(_ratioMy).div(10000);        // my earin.
        uint256 _earnMySuper = _valueEte.mul(100).div(10000);               // super1 earn = 1%.
        uint256 _earnMyOtherSuper = _valueEte.mul(50).div(10000);           // super2 - super5 earn = 0.5%.

        uint256 _total = _earnMyOtherSuper.mul(4).add(_earnMySuper).add(_earnMy);  // earn total.
        address[] memory _super5  = ILinkedin(linkedin).getSuperList(_user, 5);
        require(_super5.length == 5, "super list error");
        for(uint256 i = 0; i < 5; i++) {
            _super5[i] = _super5[i] == address(0) ? leader : _super5[i];
        }
        TransferHelper.safeTransfer(ete, _user, _earnMy);                    // user earn.
        TransferHelper.safeTransfer(ete, _super5[0], _earnMySuper);          // super1 earn.
        for(uint256 i = 1; i < 5; i++) {
            TransferHelper.safeTransfer(ete, _super5[i], _earnMyOtherSuper); // super2 - super5 earn.
        }

        _orderIssueMsg.takedCount = _orderIssueMsg.takedCount.add(_total); 
        // result user lp.
        TransferHelper.safeTransfer(depositTokenAddress, _user, _orderMsg.count);
        _orderMsg.isTaked = 3;                                   // status is 3. is taked.
        _orderMsg.takedAmount = SafeCast.toUint128(_earnMy);     // earn amount.
        emit UserTake(_orderMsg.turnOf, _orderMsg.issueOf, _user, _orderMsg.count, _earnMy);

        // burn crystal.
        _burnCrystal(_orderMsg, _user);
        // burn card
        if(_orderMsg.cardNFT > 0) _burnCard(_user, _earnMy);
    }

    function _burnCrystal(OrderMsg storage _orderMsg, address _user) private {
        uint256 crystalPrice = ICrystal(crystal).crystalPriceUSDT();
        uint256 crystalAmount = uint256(_orderMsg.count).mul(1e18).div(crystalPrice);
        uint256 _burnNumber = crystalAmount.mul(burnCrystalsRatio).div(10000);
        ICrystal(crystal).burnCrystal(_user, _burnNumber);
    }

    function _burnCard(address _user, uint256 _earnMy) private {
        ICardNFT(cardNFT).changeCardEteState(_user, 0, _earnMy);
        uint256 _nowCardNFT = ICardNFT(cardNFT).card(_user);                // now card.
        require(_nowCardNFT > 0, "not card but take card mining error");
        (uint256 limit, uint256 taked) = ICardNFT(cardNFT).cardEteState(_user);
        if(taked > limit) {
            ICardNFT(cardNFT).burnCard(_user);
            emit TakeEarnBurnCard(_user, _nowCardNFT, limit, taked);
        }
    }


    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    // take token
    function takeToken(address _token, address _to , uint256 _value) external onlyOwner {
        require(_to != address(0), "zero address error");
        require(_value > 0, "value zero error");
        TransferHelper.safeTransfer(_token, _to, _value);
    }


}