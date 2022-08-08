// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./Owner.sol";

interface YiMainPool {
    function allocKeyAirDrop(address _pair, uint256 _stake) external returns (uint256);
}

interface IKeyToken {
    function mintForEvent(address dest_) external;
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function burn(uint256 amount_) external;
}

interface YiToken {
    function balanceOf(address _owner) external view returns (uint256);
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
    function token0() external view returns (address);
    function token1() external view returns (address);
}

//质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
//空投时重新计算每个人的质押收益
contract KeyPool is Ownable {
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
    address public keyToken;           //钥匙

    address PancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    event eGetPancakeLPAddress(address LP);

    constructor() public {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    function initialize(address _mainToken, address _pairToken, address _keyToken) external {
        require(msg.sender == factory, 'S2001: you are not factory ...'); // sufficient check
        mainToken = _mainToken;
        pairToken = _pairToken;
        keyToken = _keyToken;
    }

    function setAdmin(address _admin) external {
        transferOwnership(_admin);
    }

    //设置主矿池
    function setMainPool(address _main) external onlyOwner {
        require(_main != address(0));
        mainPool = _main;
    }

    //设置主币
    function setMainToken(address _token) external onlyOwner {
        require(_token != address(0), "K2002: mainToken is invalid ... ");
        mainToken = _token;
    }

    //设置钥匙
    function setKeyToken(address _token) external onlyOwner {
        require(_token != address(0), "K2002: keyToken is invalid ... ");
        keyToken = _token;
    }

    //查询矿池余额
    function balance() external view returns (uint256) {
        require(keyToken != address(0), "K1001: keyToken is invalid ... ");
        return IKeyToken(keyToken).balanceOf(address(this));
    }

    //查询个人余额
    function balanceOf(address _staker) external view returns (uint256) {
        require(keyToken != address(0), "K1001: keyToken is invalid ... ");
        // return IKeyToken(keyToken).balanceOf(_staker);
        return stake[ownerStake[_staker]].balance;
    }

    //购买并销毁
    function purchase(address _staker, uint256 _keyNum) external lock onlyOwner isOpen returns (bool) {
        require(_keyNum >= 1 * (10** 18),"K2030: key incomplete ");
        require(_staker != address(0),"K2029: need a staker");
        uint idx = ownerStake[_staker];
        uint256 _now = now;
        uint256 _delay = _now - stake[idx].lastTime;
        uint256 _income = calcIncome(stake[idx].Amount ,_delay);
        updateStaker(true, idx, _income, 0, _now);
        uint256 bal = this.balanceOf(_staker);
        require(bal >= _keyNum,"K2028: not enough key");
        stake[idx].balance -= _keyNum;
        IKeyToken(keyToken).burn(_keyNum);
        return true;
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

    function showToken0() private view returns(address) {
        return PancakePair(aPancakePair).token0();
    }

    function showToken1() private view returns(address) {
        return PancakePair(aPancakePair).token1();
    }

    function getLPBusd(uint256 _LP) private view returns (uint256 _busd){
        uint aLp = getPairTotalSupply();
        uint256 _reserve0;
        uint256 _reserve1;
        uint32 _blockTimestampLast;
        (_reserve0,_reserve1,_blockTimestampLast) = getPairReserves();
        if (PancakePair(aPancakePair).token0() == mainToken) {
            _busd = (_reserve1 * _LP * 2 / aLp);
        } else {
            _busd = (_reserve0 * _LP * 2 / aLp);
        }
    }

    //空投，先重新计算所有人的收益,然后空投
    function airDrop() external lock isOpen {
        require(mainPool != address(0),"K2003: mainPool error");
        require(pairToken != address(0),"K2023: pairToken error");
        require(lastestAirDroping.add(AD_INTERVAL) < block.timestamp, "K2022: airDroping not allowed yet");
        settlement(address(0));
        uint256 _stake = PancakePair(aPancakePair).balanceOf(address(this));
        uint256 _busd = getLPBusd(_stake);
        lastAirDrop = YiMainPool(mainPool).allocKeyAirDrop(pairToken, _busd);
        lastestAirDroping = block.timestamp;
    }

    //查询质押在本池的所有LP
    function getLPOnStake() external view returns(uint256 _LP,uint256 _busd) {
        require(aPancakePair != address(0), "K1002: do getPancakeLPAddress() first ... ");
        _LP = PancakePair(aPancakePair).balanceOf(address(this));
        _busd = getLPBusd(_LP);

    }

    //收益计算
    //质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
    function calcIncome(uint256 _stakePrice, uint256 _delay) private view returns(uint256) {
        uint256 StakeCount = 0;
        uint256 BusdCount = 0;
        (StakeCount, BusdCount) = this.getLPOnStake();
        if (lastAirDrop == 0 || _stakePrice == 0 || StakeCount == 0|| BusdCount == 0) {
            return 0;
        }

        uint256 _busd = getLPBusd(_stakePrice);
        // return (_delay / 1 days) * (_busd / BusdCount) * lastAirDrop;
        return (_delay * _busd * lastAirDrop) / (86400 * BusdCount);
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
        require(_staker != address(0), "K2004: not a real user ... ");
        require(mainPool != address(0),"K2005: mainPool error");
        require(aPancakePair != address(0), "K2006: do getPancakeLPAddress() first ... ");
        uint256 hasLP = queryLP(_staker);
        require(hasLP >= _stakeNum,"K2007: not enough LP ... ");

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
                require(false, "K2008: a error address....");
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
        require(_staker != address(0), "K1003: a error address ... ");
        require(aPancakePair != address(0), "K1004: do getPancakeLPAddress() first ... ");
        return PancakePair(aPancakePair).balanceOf(_staker);
    }

    //减少质押 同时计算出累计至上次质押的收益
    function subStake(uint256 _stakeNum) external lock isOpen returns(uint256) {
        address _staker = _msgSender();
        require(_staker != address(0),"K2009: need a sender ...");
        
        require(mainPool != address(0),"K2010: mainPool error ...");
        require(stake.length > 0, "K2011: Empty staker ...");
        uint256 hasLP = 0;
        (hasLP,) = this.getLPOnStake();//queryLP(_staker);
        require(hasLP >= _stakeNum,"K2013:  not enough LP ... ");
        uint _idx = ownerStake[_staker];
        require(stake[_idx].staker == _staker, "K2014: Can't find staker ...");
        require(stake[_idx].Amount >= _stakeNum, "K2015: Person stake Insufficient balance ...");
        uint256 _now = now;
        uint256 _delay = _now - stake[_idx].lastTime;
        uint256 _income = calcIncome(stake[_idx].Amount, _delay);
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
    function queryIncome(address _staker) external isOpen view returns(uint256,uint256,uint256,uint256){
        if (mainPool == address(0)) {
            return (0,0,0,0);
        }
        // require(mainPool != address(0),"K1005: mainPool error ...");
        if (stake.length <= 0) {
            return (1,1,1,1);
        }
        // require(stake.length > 0, "K1006: Empty staker ...");
        uint _idx = ownerStake[_staker];
        if (stake[_idx].staker != _staker) {
            return (2,2,2,2);
        }
        // require(stake[_idx].staker == _staker, "K1007: Can't find staker ...");

        uint256 _incomePer = calcIncome(stake[_idx].Amount, 1); //每秒收益
        uint256 _incomeNow = calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);

        return (_incomePer,stake[_idx].Amount, stake[_idx].allIncome + _incomeNow, stake[_idx].balance + _incomeNow);
    }



    // test lp address https://testnet.bscscan.com/address/0x4895ABB0bc0483587dc7a9dbA27199026496Bfc8
    // 获取由流动性池生成的lp池地址
    function getPancakeLPAddress() external returns (address) {
        require(mainToken != address(0), "K2021:  please set a mainToken ... ");

        //BUSD test 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
        //address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7),mainToken);
        address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(pairToken,mainToken);
        require(_PancakePair != address(0), "K022:  Can't find _PancakePair ... ");
        aPancakePair = _PancakePair;
        emit eGetPancakeLPAddress(_PancakePair);
        return _PancakePair;
    } 

    function nextAirDroping() public view onlyOwner returns(uint256) {
        return lastestAirDroping + AD_INTERVAL;
    }
}