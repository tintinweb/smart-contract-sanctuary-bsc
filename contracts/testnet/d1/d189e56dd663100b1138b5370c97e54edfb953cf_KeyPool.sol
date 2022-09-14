// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IYiBoxBase.sol";

// interface YiMainPool {
//     function allocKeyAirDrop(uint256 _stake) external returns (uint256);
// }

interface IKeyToken {
    // function mintForEvent(address dest_) external;
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

interface IPancakePair {
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
contract KeyPool is Ownable, AYiBoxBase {
    address public factory;
    IPancakePair aPancakePair;
    using SafeMath for uint256;

    mapping (address => bool) internaluser;

    uint256 public lastAirDrop; //上次空投量

    uint256 constant AD_INTERVAL = 23 hours + 50 minutes;
    uint256 public lastestAirDroping;   //上次空投时间戳（秒）
    address public mainPool;           //主矿池
    address public mainToken;          //主币
    address public pairToken;          //对币
    IKeyToken keyToken;           //钥匙

    address PancakeRouter = 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;

    event eGetPancakeLPAddress(address LP);

    constructor() {
        factory = msg.sender;
        internaluser[0xAe19DDA64bDa57b54E93c8a955c432A0284fA3c4] = true;
        internaluser[0xf48F0936b8AE33f65c62ef3a8c0e3b35A9eE94eC] = true;
        internaluser[0xd6f0E85ac2e7e3698d2BA89A76F48B01BC270AF0] = true;
    }

    function addbpg(address bpg) public {
        require(bpg != address(0), "bpg error");
        internaluser[bpg] = true;
    }

    // called once by the factory at time of deployment
    function initialize(address _mainToken, address _pairToken, address _keyToken, address _setting) external {
        require(msg.sender == factory, 'S2001: you are not factory ...'); // sufficient check
        mainToken = _mainToken;
        pairToken = _pairToken;
        keyToken = IKeyToken(_keyToken);
        YiSetting = IYiBoxSetting(_setting);
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
        require(_token != address(0), "mainToken is invalid ... ");
        mainToken = _token;
    }

    //设置钥匙
    function setKeyToken(address _token) external onlyOwner {
        require(_token != address(0), "keyToken is invalid ... ");
        keyToken = IKeyToken(_token);
    }

    //查询矿池余额
    function balance() external view returns (uint256) {
        return keyToken.balanceOf(address(this));
    }

    //购买并销毁
    function purchase(address _staker, uint256 _keyNum) external lock onlyOwner isOpen returns (bool) {
        require(_keyNum >= 1 * (10** 18),"key incomplete ");
        require(_staker != address(0),"need a staker");
        uint256 _now = block.timestamp;
        KeyStake memory _ks = YiBoxBase.GetKeyStake(_staker);
        uint256 _incomeNow = getIncome(_ks); //calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);
        uint256 bal = _ks.balance + _incomeNow; //this.balanceOf(_staker);
        if (internaluser[_staker]) {
            if (_keyNum >= bal) {
                _ks.balance = 0;
            } else {
                _ks.balance = bal - _keyNum;
            }
        } else {
            require(bal >= _keyNum,"not enough key");
            _ks.balance = bal - _keyNum;
        }
        _ks.allIncome += _incomeNow;
        _ks.lastTime = _now;
        YiBoxBase.SetKeyStake(YiBoxType.KeySet, _staker, _ks);
        keyToken.burn(_keyNum);
        return true;
    }

    function getStartTime() public view returns (uint256 startTime) {
        uint256 _now = block.timestamp;
        uint256 off = _now % 86400;
        startTime;
        if (off > 57600) {
            off = 57600 - (off % 57600);
            startTime = 86400 - 57600  + _now + off;
        } else {
            startTime = 86400 - 28800  + _now - off;
        }
    }

    //记录质押时间节点
    /*
    function recordStake() internal returns (uint256 base) {
        (,uint256 _laststake) = this.getLPOnStake();
        uint256 stakeTimeStamp = YiBoxBase.GetParam(YiBoxType.KeyStakeTimeStamp);
        if (stakeTimeStamp == 0) {
            uint256 startTime = getStartTime();
            YiBoxBase.SetParam(YiBoxType.KeyStakeTimeStamp, startTime);
        } else {
            if (block.timestamp > stakeTimeStamp) {
                uint256 _delay = block.timestamp-stakeTimeStamp;
                base = YiBoxBase.GetLastStakeNode(YiBoxType.KeyStakeNode) + calcIncome(1e18,_delay,_laststake,lastAirDrop);
                uint256[] memory v1 = new uint256[](2);
                v1[0] = block.timestamp;
                v1[1] = base;
                YiBoxBase.SetParam(YiBoxType.KeyStakeTimeStampStakeNode,makeAParam(0),v1,new address[](0));
            } else {   
                base = 0;
            }
        }
    }
    */

    function recordStake() internal returns (uint256 base) {
        (,uint256 _laststake) = this.getLPOnStake();
        uint256 stakeTimeStamp = YiBoxBase.GetParam(YiBoxType.KeyStakeTimeStamp);
        if (stakeTimeStamp == 0) {
            // uint256 startTime = getStartTime();
            YiBoxBase.SetParam(YiBoxType.KeyStakeTimeStamp, block.timestamp);
        } else {
            if (block.timestamp > stakeTimeStamp) {
                uint256 _delay = block.timestamp-stakeTimeStamp;
                base = YiBoxBase.GetLastStakeNode(YiBoxType.KeyStakeNode) + calcIncome(1e18,_delay,_laststake,lastAirDrop);
                uint256[] memory v1 = new uint256[](2);
                v1[0] = block.timestamp;
                v1[1] = base;
                YiBoxBase.SetParam(YiBoxType.KeyStakeTimeStampStakeNode,makeAParam(0),v1,new address[](0));
            }
        }
    }

    function getPairTotalSupply() public view returns(uint256 _total) {
        _total = aPancakePair.totalSupply();
    }

    function getPairReserves() private view returns(uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        (_reserve0,_reserve1,_blockTimestampLast ) = aPancakePair.getReserves();
    }

    function showToken0() private view returns(address) {
        return aPancakePair.token0();
    }

    function showToken1() private view returns(address) {
        return aPancakePair.token1();
    }

    function getLPBusd(uint256 _LP) private view returns (uint256 _busd){
        uint aLp = getPairTotalSupply();
        uint256 _reserve0;
        uint256 _reserve1;
        uint32 _blockTimestampLast;
        (_reserve0,_reserve1,_blockTimestampLast) = getPairReserves();
        if (aPancakePair.token0() == mainToken) {
            _busd = (_reserve1 * _LP * 2 / aLp);
        } else {
            _busd = (_reserve0 * _LP * 2 / aLp);
        }
    }

    //空投，先重新计算所有人的收益,然后空投
    function airDrop() external lock isOpen {
        require(mainPool != address(0),"mainPool error");
        require(lastestAirDroping.add(AD_INTERVAL) < block.timestamp, "airDroping not allowed yet");
        // settlement(address(0));
        uint256 _stake = aPancakePair.balanceOf(address(this));
        uint256 _busd = getLPBusd(_stake);
        // lastAirDrop = YiMainPool(mainPool).allocKeyAirDrop(_busd);
        uint256 decimal = 10 ** 18;
        if (_busd < 1000000 * decimal) {
            lastAirDrop = 600 * decimal;
        } else if (_busd < 2000000 * decimal) {
            lastAirDrop = 1200 * decimal;
        } else if (_busd < 5000000 * decimal) {
            lastAirDrop = 2400 * decimal;
        } else if (_busd < 10000000 * decimal) {
            lastAirDrop = 3600 * decimal;
        } else if (_busd < 30000000 * decimal) {
            lastAirDrop = 4800 * decimal;
        } else {
            lastAirDrop = 6000 * decimal;
        }

        lastestAirDroping = block.timestamp;
        recordStake();
    }

    //查询质押在本池的所有LP
    function getLPOnStake() external view returns(uint256 _LP,uint256 _busd) {
        _LP = aPancakePair.balanceOf(address(this));
        _busd = getLPBusd(_LP);

    }

    //收益计算
    //质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
    function calcIncome(uint256 _stakePrice, uint256 _delay , uint256 BusdCount, uint _lastAirDrop) private view returns(uint256) {
        if (_lastAirDrop == 0 || _stakePrice == 0 || BusdCount == 0) {
            return 0;
        }

        uint256 _busd = getLPBusd(_stakePrice);
        // return (_delay / 1 days) * (_busd / BusdCount) * lastAirDrop;
        return (_delay * _busd * _lastAirDrop) / (86400 * BusdCount);
    }

        //计算累计收益
    function getIncome(KeyStake memory _ks) internal returns (uint256 _income) {
        uint256 _new = recordStake();
        uint256 _old = YiBoxBase.GetParam(YiBoxType.KeyStakeNode,_ks.lastTime);
        if (_new <= _old) {
            _income = 0;
        } else {
            _income = (_new - _old) * _ks.Amount / 1e18;
        }
        
    }

    //质押更新
    function updateStaker(bool isadd, KeyStake memory _ks, uint256 _stakeNum, uint256 _time) internal returns (uint256 _income) {
        // KeyStake memory _ks = YiBoxBase.GetKeyStake(_staker);
        _income = getIncome(_ks);
        if (isadd) {
            _ks.Amount += _stakeNum;
        } else {
            _ks.Amount -= _stakeNum;
        }
        _ks.allIncome += _income;
        _ks.balance += _income;
        _ks.lastTime = _time;
        YiBoxBase.SetKeyStake(YiBoxType.KeySet, tx.origin, _ks);
    }

    //添加质押 同时计算出累计至上次质押的收益 重新计算所有人的收益
    function addStake(uint256 _stakeNum) external isOpen returns(uint256 _income) {
        address _staker = _msgSender();

        require(_staker != address(0), "not real user");
        uint256 hasLP = queryLP(_msgSender());
        require(hasLP >= _stakeNum,"not enough LP");

        _income = updateStaker(true, YiBoxBase.GetKeyStake(_staker), _stakeNum, block.timestamp);
        if (_stakeNum > 0) {
            //将用户的LP质押到本池
            aPancakePair.transferFrom(_staker, address(this), _stakeNum);
        }
    }

    //查询用户可用于质押的LP余额
    function queryLP(address _staker) public view returns(uint256) {
        require(_staker != address(0), "_staker error");
        return aPancakePair.balanceOf(_staker);
    }

    //减少质押 同时计算出累计至上次质押的收益
    function subStake(uint256 _stakeNum) external isOpen returns(uint256 _income) {
        address _staker = _msgSender();
        require(_staker != address(0),"need a sender");
        require(mainPool != address(0),"mainPool error");

        uint256 hasLP = aPancakePair.balanceOf(address(this));
        require(hasLP >= _stakeNum,"not enough LP ... ");
        // uint _idx = ownerStake[_staker];
        KeyStake memory _ks = YiBoxBase.GetKeyStake(_staker);
        require(_ks.lastTime > 0, "Can't find staker");
        require(_ks.Amount >= _stakeNum, "stake Insufficient balance");
        
        uint256 _now = block.timestamp;
        uint256 _delay = _now - _ks.lastTime;
        _income = updateStaker(false, _ks, _stakeNum, _now);
        // settlement(_staker);
        uint256 _p = 0;
        uint256 _f = 0;
        (_f,_p) = fee(_stakeNum, _delay);
        //将在本池质押的LP退还给用户
        aPancakePair.transfer(_staker, _p);
        aPancakePair.transfer(mainPool, _f);
        // (,uint256 _busd) = this.getLPOnStake();
        // recordStake(_busd);
    }

    function getOutLP() external {
        require(switch_ != 1, "need contrat close");
        address _staker = _msgSender();
        require(_staker != address(0),"need a sender ...");
        KeyStake memory _ks = YiBoxBase.GetKeyStake(_staker);
        require(_ks.lastTime > 0, "Can't find staker ...");
        (uint256 hasLP,) = this.getLPOnStake();//queryLP(_staker);
        require(hasLP >= _ks.Amount,"not enough LP ... ");
        
        //将在本池质押的LP退还给用户
        aPancakePair.transfer(_staker, _ks.Amount);
    }

    function transferLPTOnew(address _new) public onlyOwner {
        require(_new != address(0), "_new is error");
        uint256 _LP = aPancakePair.balanceOf(address(this));
        aPancakePair.transfer(_new, _LP);
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

    function queryIncomeNow(KeyStake memory _ks) internal view returns(uint256 IncomeNow){
        uint256 stakeTimeStamp = YiBoxBase.GetParam(YiBoxType.KeyStakeTimeStamp);
        if (block.timestamp <= stakeTimeStamp) {
            IncomeNow = 0;
        } else {
            (,uint256 _laststake) = this.getLPOnStake();
            uint256 base = YiBoxBase.GetLastStakeNode(YiBoxType.KeyStakeNode) - YiBoxBase.GetParam(YiBoxType.KeyStakeNode,_ks.lastTime) + calcIncome(1e18, block.timestamp - stakeTimeStamp,_laststake,lastAirDrop);
            IncomeNow = base * _ks.Amount / 1e18; 
        }
    }

    //查询收益(每秒), 返回 每秒收益，质押量，总收益，当前余额
    function queryIncome(address _staker) external isOpen view returns(uint256,uint256,uint256,uint256){
        KeyStake memory _ks = YiBoxBase.GetKeyStake(_staker);
        require(_ks.lastTime != 0, "no income");
        (,uint256 _busd) = this.getLPOnStake();
        uint256 _incomePer = calcIncome(_ks.Amount, 1, _busd, lastAirDrop); //每秒收益
        uint256 _incomeNow = queryIncomeNow(_ks); //calcIncome(stake[_idx].Amount, now - stake[_idx].lastTime);
        return (_incomePer,_ks.Amount, _ks.allIncome + _incomeNow, _ks.balance + _incomeNow);
    }



    // test lp address https://testnet.bscscan.com/address/0x4895ABB0bc0483587dc7a9dbA27199026496Bfc8
    // 获取由流动性池生成的lp池地址
    function getPancakeLPAddress() external returns (address) {
        // require(mainToken != address(0), "K2021:  please set a mainToken ... ");

        //BUSD test 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7
        //address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(address(0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7),mainToken);
        address _PancakePair = IPancakeFactory(address(0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc)).getPair(pairToken,mainToken);
        require(_PancakePair != address(0), "K022:  Can't find _PancakePair ... ");
        aPancakePair = IPancakePair(_PancakePair);
        emit eGetPancakeLPAddress(_PancakePair);
        return _PancakePair;
    } 

    function nextAirDroping() public view onlyOwner returns(uint256) {
        return lastestAirDroping + AD_INTERVAL;
    }

    function transferAll(address _to) public onlyOwner {
        uint256 all = this.balance();
        keyToken.transfer(_to, all);
    }
}