/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// File: YiBoxToken/Context.sol
// PancakeRouter address
// testnet 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
// mainnet 0x10ED43C718714eb63d5aA57B78B54704E256024E

// PancakeFactory address
// testnet: 0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc
// mainnet: 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73

// BNBToken address
// testnet: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
// mainnet: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c

// BUSDToken address
// testnet: 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.6;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "not owner");
        }
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {
    function add(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

pragma solidity ^0.6.6;

library SafeMathExt {
    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "uint128: addition overflow");

        return c;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "uint128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function add64(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "uint64: addition overflow");

        return c;
    }

    function sub64(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "uint64: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function safe128(uint256 a) internal pure returns(uint128) {
        require(a < 0x0100000000000000000000000000000000, "uint128: number overflow");
        return uint128(a);
    }

    function safe64(uint256 a) internal pure returns(uint64) {
        require(a < 0x010000000000000000, "uint64: number overflow");
        return uint64(a);
    }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "uint32: number overflow");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "uint32: number overflow");
        return uint16(a);
    }
}

interface YiMainPool {
    function allocStake(uint256 _stake) external returns (uint256);
}

interface YiToken {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface PancakePair {
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

//质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
//空投时重新计算每个人的质押收益
contract StakePool is Ownable {
    using SafeMath for uint256;
    using SafeMath64 for uint64;
    struct Stake {
        address staker;     //质押人
        uint256 Amount;     //本人质押总量
        uint256 startTime;  //首次质押时间
        uint256 lastTime;   //上次质押时间
        uint256 allIncome;  //累计收益
        uint256 balance;    //收益余额
    }
    //uint256 public StakeCount = 0;  //质押池质押总量
    
    address internal aPancakePair;

    Stake[] public stake; //质押详细记录
    // mapping (uint => address) public stakeToOwner;  //质押人记录
    mapping (address => uint) public ownerStake;   //质押人键值对应

    uint256 public lastAirDrop; //上次空投量

    uint256 constant  AD_INTERVAL = 23 hours + 50 minutes;
    uint256 public lastestAirDroping;   //上次空投时间戳（秒）
    address mainPool;           //主矿池
    address mainToken;          //主币

    //设置管理员
    function setAdmin(address _admin) external onlyOwner {
        this.transferOwnership(_admin);
    }

    //设置主矿池
    function setMainPool(address _main) external onlyOwner  {
        require(_main != address(0));
        mainPool = _main;
    }

    //设置主币
    function setMainToken(address _token) external onlyOwner {
        require(_token != address(0), " token is invalid ... ");
        mainToken = _token;
    }

    //查询矿池余额
    function balance() external view returns (uint256) {
        require(mainToken != address(0), " token is invalid ... ");
        return YiToken(mainToken).balanceOf(address(this));
    }

    function settlement(address _exclude) internal {
        for (uint i=0; i < stake.length; i++) {
            if (stake[i].staker != _exclude && _exclude != address(0))
            _addstake(stake[i].staker, 0);
        }
    }

    //空投，先重新计算所有人的收益,然后空投
    function airDrop(uint256 _stake) external onlyOwner {
        require(mainPool != address(0),"mainPool error");
        require(lastestAirDroping.add(AD_INTERVAL) < block.timestamp, "airDroping not allowed yet");
    
        settlement(address(0));

        lastAirDrop = YiMainPool(mainPool).allocStake(_stake);
        lastestAirDroping = block.timestamp;
    }

    //查询质押在本池的所有LP
    function getLPOnStake() external view returns(uint256) {
        require(aPancakePair != address(0), " do getPancakeLPAddress() first ... ");
        return PancakePair(aPancakePair).balanceOf(address(this));
    }

    //收益计算
    //质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
    function calcIncome(uint256 _stakePrice, uint256 _delay) internal view returns(uint256) {
        uint256 StakeCount = this.getLPOnStake();
        if (lastAirDrop == 0 || _stakePrice == 0 || StakeCount == 0) {
            return 0;
        }
        return (_delay / 1 days) * (_stakePrice / StakeCount) * lastAirDrop;
    }

    //质押更新
    function updateStaker(bool isadd, uint _idx, uint256 _income, uint256 _stakeNum, uint256 _time) internal {
        if (isadd) {
            stake[_idx].Amount += _stakeNum;
        } else {
            stake[_idx].Amount -= _stakeNum;
        }
        stake[_idx].allIncome += _income;
        stake[_idx].balance += _income;
        stake[_idx].lastTime = _time;
    }

    //添加质押 同时计算出累计至上次质押的收益
    function _addstake(address _staker, uint256 _stakeNum) internal returns(uint256) {
        require(_staker != address(0), " not a real user ... ");
        require(mainPool != address(0),"mainPool error");
        require(aPancakePair != address(0), " do getPancakeLPAddress() first ... ");
        uint256 hasLP = this.queryLP();
        require(hasLP >= _stakeNum," not enough LP ... ");

        uint256 _income = 0;
        if (ownerStake[_staker] == 0) {
            if (stake.length == 0) {
                stake.push(Stake(_staker, _stakeNum, now, now, 0, 0));
                ownerStake[_staker] = stake.length - 1;
            } else {
                if (_staker == stake[0].staker) {
                    uint256 _now = now;
                    _income = calcIncome(stake[0].Amount, _now - stake[0].lastTime);
                    updateStaker(true, 0, _income, _stakeNum, _now);
                } else {
                    stake.push(Stake(_staker, _stakeNum, now, now, 0, 0));
                    ownerStake[_staker] = stake.length - 1;
                }
            }
        } else {
            uint _idx = ownerStake[_staker];
            if (_staker == stake[_idx].staker) {
                uint256 _now = now;
                _income = calcIncome(stake[_idx].Amount, _now - stake[_idx].lastTime);
                updateStaker(true, 0, _income, _stakeNum, _now);
            } else {
                require(false, " a error address....");
            }
        }

        if (_stakeNum > 0) {
            //将用户的LP质押到本池
            PancakePair(aPancakePair).transferFrom(_staker, address(this), _stakeNum);
        }
        return _income;
    }

    //添加质押 同时计算出累计至上次质押的收益 重新计算所有人的收益
    function addStake(uint256 _stakeNum) external returns(uint256) {
        address _staker = _msgSender();
        uint256 _income = _addstake(_staker, _stakeNum);
        settlement(_staker);
        return _income;
    }

    //查询用户可用于质押的LP余额
    function queryLP() external view returns(uint256) {
        address _staker = _msgSender();
        require(_staker != address(0), " a error address ... ");
        require(aPancakePair != address(0), " do getPancakeLPAddress() first ... ");
        return PancakePair(aPancakePair).balanceOf(_staker);
    }

    //减少质押 同时计算出累计至上次质押的收益
    function subStake(uint256 _stakeNum) external returns(uint256) {
        address _staker = _msgSender();
        require(_staker != address(0),"need a sender ...");
        require(mainPool != address(0),"mainPool error ...");
        require(stake.length > 0, "Empty staker ...");
        uint256 StakeCount = this.getLPOnStake();
        require(StakeCount >= _stakeNum, "StakePool Insufficient balance ...");
        uint256 hasLP = this.queryLP();
        require(hasLP >= _stakeNum," not enough LP ... ");
        uint _idx = ownerStake[_staker];
        require(stake[_idx].staker == _staker, "Can't find staker ...");
        require(stake[_idx].Amount >= _stakeNum, "Person stake Insufficient balance ...");
        uint256 _now = now;
        uint256 _income = calcIncome(stake[_idx].Amount, _now - stake[_idx].lastTime);
        updateStaker(false, _idx, _income, _stakeNum, _now);
        
        //将在本池质押的LP退还给用户
        PancakePair(aPancakePair).transferFrom(address(this), _staker, _stakeNum);
        settlement(_staker);
        return _income;
    }

    //查询收益(每秒), 返回 每秒收益，质押量，总收益，当前余额
    function queryIncome(address _staker) external view onlyOwner returns(uint256,uint256,uint256,uint256){
        require(mainPool != address(0),"mainPool error ...");
        require(stake.length > 0, "Empty staker ...");
        uint _idx = ownerStake[_staker];
        require(stake[_idx].staker == _staker, "Can't find staker ...");

        uint256 _incomePer = calcIncome(stake[_idx].Amount, 1); //每秒收益
        uint256 _incomeNow = calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);

        return (_incomePer,stake[_idx].Amount, stake[_idx].allIncome + _incomeNow, stake[_idx].balance + _incomeNow);
    }

    //提现 (提现人 提现金额)
    function withdraw(address _sender, uint256 _amount) external returns(bool) {
        require(mainPool != address(0),"mainPool error ...");
        require(stake.length > 0, "Empty staker ...");
        uint _idx = ownerStake[_sender];
        require(stake[_idx].staker == _sender, "Can't find staker ...");
        uint256 _PoolBal = this.balance();
        require(_amount > _PoolBal, " StakePool Insufficient balance ...");
        uint256 _balance = stake[_idx].balance;
        uint256 _incomeNow = calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);
        _balance += _incomeNow;
        require(_amount > _balance, " Person Insufficient balance ...");
        stake[_idx].balance = _balance - _amount;
        return YiToken(mainToken).transfer(_sender, _amount);
    }
    // test lp address https://testnet.bscscan.com/address/0x4895ABB0bc0483587dc7a9dbA27199026496Bfc8
    // 获取由流动性池生成的lp池地址
    function getPancakeLPAddress() external onlyOwner returns (address) {
        require(mainToken != address(0), " please set a mainToken ... ");

        //BUSD test 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
        address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7),mainToken);
        require(_PancakePair != address(0), " Can't find _PancakePair ... ");
        aPancakePair = _PancakePair;
        return _PancakePair;
    } 

    function nextAirDroping() public view onlyOwner returns(uint256) {
        return lastestAirDroping + AD_INTERVAL;
    }
}