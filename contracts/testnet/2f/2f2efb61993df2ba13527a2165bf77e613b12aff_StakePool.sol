// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface YiMainPool {
    function allocAirDrop(address _pair, uint256 _stake) external returns (uint256);
    function allocKeyAirDrop(address _pair, uint256 _stake) external returns (uint256);
}

interface IKeyToken {
    function mintForEvent(address dest_) external;
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

interface IYiBoxSetting {
    function getIncomePool() external returns (address);
    function getrepoPool() external returns (address);
    function getIncomePer() external returns (uint32);
    function getRepoPer() external returns (uint32);
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
    function transfer(address to, uint value) external returns (bool);
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function totalSupply() external view returns (uint);
}

//质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
//空投时重新计算每个人的质押收益
contract StakePool is Ownable {
    address public factory;
    using SafeMath for uint256;
    struct Stake {
        address staker;     //质押人
        uint256 Amount;     //本人质押总量
        uint256 startTime;  //首次质押时间
        uint256 lastTime;   //上次质押时间
        uint256 allIncome;  //累计收益
        uint256 balance;    //收益余额
    }
    
    address internal aPancakePair;

    Stake[] public stake; //质押详细记录
    mapping (address => uint) public ownerStake;   //质押人键值对应

    uint256 public lastAirDrop; //上次空投量

    uint256 constant AD_INTERVAL = 23 hours + 50 minutes;
    uint256 public lastestAirDroping;   //上次空投时间戳（秒）
    address public mainPool;           //主矿池
    address public mainToken;          //主币
    address public pairToken;          //对币
    address public YiSetting;

    event eGetPancakeLPAddress(address LP);

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _mainToken, address _pairToken) external {
        require(msg.sender == factory, 'S2001: you are not factory ...'); // sufficient check
        mainToken = _mainToken;
        pairToken = _pairToken;
        // setMainPool(_msgSender());
        // this.getPancakeLPAddress();
    }

    function setAdmin(address _admin) external {
        transferOwnership(_admin);
    }

    function setSetting(address _setting) public onlyOwner {
        YiSetting = _setting;
    } 

    //设置主矿池
    function setMainPool(address _main) external onlyOwner {
        require(_main != address(0));
        mainPool = _main;
    }

    //设置主币
    function setMainToken(address _token) external onlyOwner {
        require(_token != address(0), "S2002: mainToken is invalid ... ");
        mainToken = _token;
    }

    //查询矿池余额
    function balance() external view returns (uint256) {
        require(mainToken != address(0), "S1001: mainToken is invalid ... ");
        return YiToken(mainToken).balanceOf(address(this));
    }

    //结算所有人的余额
    function settlement(address _exclude) internal {
        for (uint i=0; i < stake.length; i++) {
            if (_exclude == address(0)) {
                _addstake(stake[i].staker, 0);
            } else if (stake[i].staker != _exclude) {
                _addstake(stake[i].staker, 0);
            }
        }
    }

    function getPairTotalSupply() public view returns(uint256 _total) {
        require(aPancakePair != address(0),"K2024: aPancakePair error");
        _total = PancakePair(aPancakePair).totalSupply();
    }

    function getPairReserves() private view returns(uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        require(aPancakePair != address(0),"K2024: aPancakePair error");
        (_reserve0,_reserve1,_blockTimestampLast ) = PancakePair(aPancakePair).getReserves();
    }

    //空投，先重新计算所有人的收益,然后空投
    function airDrop() external lock isOpen {
        uint256 _stake = this.getLPOnStake();
        require(mainPool != address(0),"S2003: mainPool error");
        require(lastestAirDroping.add(AD_INTERVAL) < block.timestamp, "S2004: airDroping not allowed yet");
        settlement(address(0));
        lastAirDrop = YiMainPool(mainPool).allocAirDrop(pairToken, _stake);
        lastestAirDroping = block.timestamp;
    }

    //查询质押在本池的所有LP
    function getLPOnStake() external view returns(uint256) {
        require(aPancakePair != address(0), "S1002: do getPancakeLPAddress() first ... ");
        return PancakePair(aPancakePair).balanceOf(address(this));
    }

    //收益计算
    //质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
    function calcIncome(uint256 _stakePrice, uint256 _delay) internal view returns(uint256) {
        uint256 StakeCount = this.getLPOnStake();
        if (lastAirDrop == 0 || _stakePrice == 0 || StakeCount == 0) {
            return 0;
        }
        // return (_delay / 1 days) * (_stakePrice / StakeCount) * lastAirDrop;
        return (_delay * _stakePrice * lastAirDrop) / (86400 * StakeCount);
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
        require(_staker != address(0), "S2004: not a real user ... ");
        require(mainPool != address(0),"S2005: mainPool error");
        require(aPancakePair != address(0), "S2006: do getPancakeLPAddress() first ... ");
        uint256 hasLP = queryLP(_staker);
        require(hasLP >= _stakeNum,"S2007: not enough LP ... ");

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
                updateStaker(true, _idx, _income, _stakeNum, _now);
            } else {
                require(false, "S2008: a error address....");
            }
        }

        if (_stakeNum > 0) {
            //将用户的LP质押到本池
            PancakePair(aPancakePair).transferFrom(_staker, address(this), _stakeNum);
        }
        return _income;
    }

    //添加质押 同时计算出累计至上次质押的收益 重新计算所有人的收益
    function addStake(uint256 _stakeNum) external lock isOpen returns(uint256) {
        address _staker = _msgSender();
        settlement(_staker);
        uint256 _income = _addstake(_staker, _stakeNum);
        
        return _income;
    }

    //查询用户可用于质押的LP余额
    function queryLP(address _staker) public view returns(uint256) {
        require(_staker != address(0), "S1003: a error address ... ");
        require(aPancakePair != address(0), "S1004: do getPancakeLPAddress() first ... ");
        return PancakePair(aPancakePair).balanceOf(_staker);
    }

    //减少质押 同时计算出累计至上次质押的收益
    function subStake(uint256 _stakeNum) external lock isOpen returns(uint256) {
        address _staker = _msgSender();
        require(_staker != address(0),"S2009: need a sender ...");
        require(mainPool != address(0),"S2010: mainPool error ...");
        require(stake.length > 0, "S2011: Empty staker ...");
        uint256 StakeCount = this.getLPOnStake();
        require(StakeCount >= _stakeNum, "S2012: StakePool Insufficient balance ...");
        // uint256 hasLP = queryLP(_staker);
        // require(hasLP >= _stakeNum,"S2013:  not enough LP ... ");
        uint _idx = ownerStake[_staker];
        require(stake[_idx].staker == _staker, "S2014: Can't find staker ...");
        require(stake[_idx].Amount >= _stakeNum, "S2015: Person stake Insufficient balance ...");
        
        uint256 _now = now;
        uint256 _delay = _now - stake[_idx].lastTime;
        uint256 _income = calcIncome(stake[_idx].Amount, _now - stake[_idx].lastTime);
        updateStaker(false, _idx, _income, _stakeNum, _now);
        settlement(_staker);

        uint256 _p = 0;
        uint256 _f = 0;
        (_f,_p) = fee(_stakeNum, _delay);
        //将在本池质押的LP退还给用户
        PancakePair(aPancakePair).transfer(_staker, _p);
        PancakePair(aPancakePair).transfer(mainPool, _f);

        return _income;
    }

    function fee(uint256 _input, uint256 _delay) internal pure returns (uint256 _fee, uint256 _result) {
        if ( _delay < 7 days) {
            _fee = _input * 5 / 1000; 
            
        } else if ( _delay < 14 days) {
            _fee = _input * 4 / 1000; 
        } else if ( _delay < 30 days) {
            _fee = _input * 3 / 1000; 
        } else if ( _delay < 90 days) {
            _fee = _input * 2 / 1000; 
        } else if ( _delay < 180 days) {
            _fee = _input / 1000; 
        } else {
            _fee = 0;
        }
        _result = _input - _fee;
    }

    //查询收益(每秒), 返回 每秒收益，质押量，总收益，当前余额
    function queryIncome() external view isOpen returns(uint256,uint256,uint256,uint256){
        address _staker = _msgSender();
        require(mainPool != address(0),"S1005: mainPool error ...");
        require(stake.length > 0, "S1006: Empty staker ...");
        uint _idx = ownerStake[_staker];
        require(stake[_idx].staker == _staker, "S1007: Can't find staker ...");

        uint256 _incomePer = calcIncome(stake[_idx].Amount, 1); //每秒收益
        uint256 _incomeNow = calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);

        return (_incomePer,stake[_idx].Amount, stake[_idx].allIncome + _incomeNow, stake[_idx].balance + _incomeNow);
    }

    //提现 (提现人 提现金额)
    function withdraw(address _sender, uint256 _amount) external lock isOpen returns(bool) {
        require(mainPool != address(0),"S2016: mainPool error ...");
        uint _idx = ownerStake[_sender];
        require(stake[_idx].staker == _sender, "S2018: Can't find staker ...");
        uint256 _PoolBal = this.balance();
        require(_amount <= _PoolBal, "S2019: StakePool Insufficient balance ...");
        uint256 _balance = stake[_idx].balance;
        uint256 _incomeNow = calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);
        _balance += _incomeNow;
        require(_amount <= _balance, "S2020: Person Insufficient balance ...");
        stake[_idx].balance = _balance - _amount;

        uint256 _incomeFee = _amount * IYiBoxSetting(YiSetting).getIncomePer() / 10000;
        uint256 _repoFee =  _amount * IYiBoxSetting(YiSetting).getRepoPer() / 10000;
        require((_incomeFee + _repoFee) < _amount, "fee error");

        YiToken(mainToken).transfer(IYiBoxSetting(YiSetting).getIncomePool(), _incomeFee);
        YiToken(mainToken).transfer(IYiBoxSetting(YiSetting).getrepoPool(), _repoFee);
        uint256 _result = _amount - _incomeFee - _repoFee;

        return YiToken(mainToken).transfer(_sender, _result);
    }
    // test lp address https://testnet.bscscan.com/address/0x4895ABB0bc0483587dc7a9dbA27199026496Bfc8
    // 获取由流动性池生成的lp池地址
    function getPancakeLPAddress() external onlyOwner returns (address) {
        require(mainToken != address(0), "S2021:  please set a mainToken ... ");

        //BUSD test 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
        //address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7),mainToken);
        address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(pairToken,mainToken);
        require(_PancakePair != address(0), "S2022:  Can't find _PancakePair ... ");
        aPancakePair = _PancakePair;
        emit eGetPancakeLPAddress(_PancakePair);
        return _PancakePair;
    } 

    function nextAirDroping() public view onlyOwner returns(uint256) {
        return lastestAirDroping + AD_INTERVAL;
    }
}