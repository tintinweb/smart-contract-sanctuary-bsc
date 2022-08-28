/**
 *Submitted for verification at BscScan.com on 2022-08-28
*/

// SPDX-License-Identifier: Sep
pragma solidity ^0.6.6;

contract HeroFactory1 {
    struct StakeRecord {
        uint256 stakeNum;//这里质押的是busd
        uint256 lastAirDrop;
    }
    //总质押记录列表
    mapping (uint => StakeRecord) public stakeTimeStamp;
    uint[] public stakeTimeStampList;

    uint m_index;

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
    // mapping (address => uint) public ownerStake;   //质押人键值对应

    uint32 public m_u32FixBounes;

    constructor() public {
        stakeTimeStampList.push(1660186607);
        stakeTimeStampList.push(1660187021);
        stakeTimeStampList.push(1660188734);

        stakeTimeStamp[1660186607].stakeNum = 281508117570314511875754;
        stakeTimeStamp[1660186607].lastAirDrop = 600000000000000000000;

        stakeTimeStamp[1660187021].stakeNum = 291068680007689921579359;
        stakeTimeStamp[1660187021].lastAirDrop = 600000000000000000000;

        stakeTimeStamp[1660188734].stakeNum = 293443635788395457695689;
        stakeTimeStamp[1660188734].lastAirDrop = 600000000000000000000;

        stake.push(Stake(address(0xf48F0936b8AE33f65c62ef3a8c0e3b35A9eE94eC), 118531940618568463127642, 1660186607, 1660186607, 0, 0));
        stake.push(Stake(address(0x34849e2f0C3c9C951B6F306bE5b3e86E0A6cdb82), 4025574924403527717660, 1660187021, 1660187021, 0, 0));
        stake.push(Stake(address(0xc953a7d0cB8d2DE729B10b81a9c63330E1256ba2), 1000000000000000000000, 1660188734, 1660188734, 0, 0));

        m_u32FixBounes = 300;
    }

    //收益计算
    //质押收益计算方式：（两次质押操作时间间隔 / 1天） * （本次操作前的质押量 / 质押池总量） *  （上一次空投量）
    function calcIncome(uint256 _stakePrice, uint256 _delay , uint256 BusdCount, uint _lastAirDrop) private pure returns(uint256) {
        require(BusdCount > 0, "BusdCount is 0");
        if (_lastAirDrop == 0 || _stakePrice == 0 || BusdCount == 0) {
            return 0;
        }

        uint256 _busd = _stakePrice;
        // return (_delay / 1 days) * (_busd / BusdCount) * lastAirDrop;
        return (_delay * _busd * _lastAirDrop) / (86400 * BusdCount);
    }

        //计算累计收益
    function getIncome(uint _idx, uint256 _time) public returns (uint256 _income) {
        uint index = stakeTimeStampList.length;
        uint dt  = 0;
        for(uint i = stakeTimeStampList.length - 1; i >= 0; i--) {
            if (stake[_idx].lastTime >= stakeTimeStampList[i]) break;
            index = i;
        }

        for(uint i = index; i < stakeTimeStampList.length; i++) {
            if (i > 0) {
                uint _stake = stakeTimeStamp[stakeTimeStampList[i - 1]].stakeNum;
                dt = stakeTimeStampList[i] - stakeTimeStampList[i - 1];
                _income += calcIncome(stake[_idx].Amount, dt,_stake, stakeTimeStamp[stakeTimeStampList[i - 1]].lastAirDrop);
            }
        }

        if (_time - stake[_idx].lastTime > 0 && index > 0 && _time - stakeTimeStampList[stakeTimeStampList.length - 1] > 0) {
            uint _stake = stakeTimeStamp[stakeTimeStampList[stakeTimeStampList.length - 1]].stakeNum;
            if (_time > stakeTimeStampList[stakeTimeStampList.length - 1]) {
                dt = _time - stakeTimeStampList[stakeTimeStampList.length - 1];
                _income += calcIncome(stake[_idx].Amount, dt, _stake, stakeTimeStamp[stakeTimeStampList[stakeTimeStampList.length - 1]].lastAirDrop);
            }
        }

        m_index++;
    }


    struct Addbase {
        uint32 num;
        uint16 additionPer;
    }

    Addbase[] public lv4pers;
    Addbase[] public lv5pers;

    function setFixBounes(uint32 num) public  {
        m_u32FixBounes = num;
    }

    function setLevel4Pers(uint32[] memory lv4Num, uint16[] memory lv4Per) public  {
        require(lv4Num.length == lv4Per.length, "invalid param length");
        delete lv4pers;
        for (uint i = 0; i < lv4Num.length; i++){
            Addbase memory ab = Addbase(lv4Num[i], lv4Per[i]);
            lv4pers.push(ab);
        }
    }

    function setLevel5Pers(uint32[] memory lv5Num, uint16[] memory lv5Per) public  {
        require(lv5Num.length == lv5Per.length, "invalid param length");
        delete lv5pers;
        for (uint i = 0; i < lv5Num.length; i++){
            Addbase memory ab = Addbase(lv5Num[i], lv5Per[i]);
            lv5pers.push(ab);
        }
    }

        //获得算力加成 1 史诗百分比， 2 传说百分比 , 3 固定加成 , 4 最终算力
    function getHashAddition(uint256 suit, uint256 lv4num, uint256 lv5num, uint256 hashrate) public returns (uint16 lv4per, uint16 lv5per, uint256 bounes, uint256 laseHashrate) {
        bounes = suit * m_u32FixBounes;
        lv4per = 0;
        lv5per = 0;
        for (uint i = lv4pers.length; i > 0; i--) {
            if (lv4num >= lv4pers[i-1].num) {
                lv4per = lv4pers[i-1].additionPer;
                break;
            }
        }
        for (uint i = lv5pers.length; i > 0; i--) {
            if (lv5num >= lv5pers[i-1].num) {
                lv5per = lv5pers[i-1].additionPer;
                break;
            }
        }

        uint256 l4 = 0;
        if (lv4per > 0) {
            l4 = hashrate * lv4per / 10000;
        }

        uint256 l5 = 0;
        if (lv5per > 0) {
            l5 = hashrate * lv5per / 10000;
        }

        laseHashrate = hashrate + l4 + l5 + bounes;
        m_index++;
    }

    function callSeed(address _seed1) public view returns (uint256[40] memory _seed) {
        bytes memory load = abi.encodeWithSignature("Hash(uint256,uint256)", 10000, 40);
        (, bytes memory returnData) = address(_seed1).staticcall(load);
        _seed = abi.decode(returnData,(uint256[40]));
    }

    uint256 public aaaa;
    function testWrite(uint256 _a) public {
        aaaa = _a;

    }
    function testWriteLoop(uint256 _a, uint256 times) public {
        uint256 __a = _a;

        for(uint i = 0; i < times; i++) {
            __a++;
        }
        aaaa = __a;

    }
}