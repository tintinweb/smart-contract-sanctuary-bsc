/**
 *Submitted for verification at BscScan.com on 2022-08-23
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

interface YiMainPool {
    function allocHashrateAirDrop(uint256 _hashrateTotal) external returns (uint256);
}

interface IYiBoxSetting {
    function calcOpenBox(uint256 times) external returns (uint256[] memory,uint256[] memory, uint256[] memory, uint256[] memory,uint256[30] memory);
    // function calcHashrate4() external returns (uint32);
    // function calcHashrate5() external returns (uint32);
    // function getMaxHeroType() external view returns (uint16);
    function getIncomePool() external returns (address);
    function getrepoPool() external returns (address);
    function getIncomePer() external returns (uint32);
    function getRepoPer() external returns (uint32);
    // function getMaxLevel(uint8 _vLevel) external returns(uint256);
    // function getHashrate(uint q, uint com, uint r) external returns (uint[] memory, uint[] memory);
    // function getLevelUpV4(uint256 currentLevel_) external returns(uint256, uint256, uint256, uint256, uint256);
    // function getLevelUpV5(uint256 currentLevel_) external returns(uint256, uint256, uint256, uint256, uint256, uint256);
    // function getLevelUpV6(uint256 currentLevel_) external view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256);
}

interface IYiBoxNFT {
    // function getHashrateTotal() external view returns (uint256 hTotal);
    function getAllOwners() external view returns (address[] memory _owners);
    // function openBox(uint256 tokenId, uint8 _quality, uint32 _hashrate, uint16 _type) external;
    function mint(address to, uint256 tokenId, uint256 _quality, uint256 _hashrate,uint256 ttype) external returns(uint256);
    // function getTokensByStatus(address _owner, uint256 _status) external view returns (uint256[] memory);
    // function setStatus(address _s, uint256 tokenId, uint256 _status) external;
    // function tokenBase(uint256 tokenId) external view returns (uint256, uint256,uint256, uint256, uint256);
    // function ownerOf(uint256 tokenId) external returns (address);
    // function transferFromInternal(address from, address to, uint32 tokenId) external;
    // function getLevelsByToken(uint256 _token) external view returns (uint256[] memory, uint256[] memory, uint256[] memory);
    // function upLevel(uint256 tokenId, uint256 _hashrate) external;
    // function burnIn(uint256 tokenId) external;
}

interface YiToken {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

interface INFTHelpAdv2 {
    function getRealHashrate(address target) external view returns (uint256);
}

interface IYiBoxNFT1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath add");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath sub");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath mul");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath div");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath mod");
        return a % b;
    }
}

library SafeMathExt {
    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "safe32");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "safe16");
        return uint16(a);
    }

    function safe8(uint256 a) internal pure returns(uint8) {
        require(a < 0x0100, "safe8");
        return uint8(a);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    uint8 private unlocked = 1;

    modifier lock() {
        require(unlocked == 1, "is LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "owner error");
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

contract HashratePool is Ownable {
    using SafeMath for uint256;
    struct Hashrate {
        address staker;     //质押人
        // uint256 sTime;  //首次加入时间
        uint256 lTime;   //上次更新时间
        uint256 allIncome;  //累计收益
        uint256 balance;    //收益余额
    }
    
    Hashrate[] public hashrates; //质押详细记录
    mapping (address => uint) public ownerStake;   //质押人键值对应

    struct StakeRecord {
        uint256 stakeNum;
        uint256 lastAirDrop;
    }
    //总质押记录列表
    mapping (uint => StakeRecord) stakeTimeStamp;
    uint[] stakeTimeStampList;

    uint256 public lastAirDrop; //上次空投量

    uint256 constant AD_INTERVAL = 23 hours + 50 minutes;
    uint256 public lastestAirDroping;   //上次空投时间戳（秒）
    address public mainPool;           //主矿池
    address public mainToken;          //主币
    address public NFTToken;
    address public HeroAddress;        //1155Hero
    address public BoxAddress;         //1155Box
    address public YiSetting;
    address public NFTHelp2Address;

    event eOpenBox(uint256[] indexed _tks, uint256[] indexed _lvs, uint256[] indexed _hrs, uint256[] _tys);

    function setNFTToken(address _NFTToken) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        NFTToken = _NFTToken;
    }

    function setNFTHelp2Address(address _NFTHelp) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        NFTHelp2Address = _NFTHelp;
    }

    function setHeroAddress(address _HeroAddress) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        HeroAddress = _HeroAddress;
    }

    function setBoxAddress(address _BoxAddress) public onlyOwner {
        BoxAddress = _BoxAddress;
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
        // require(_token != address(0), "mainToken invalid");
        mainToken = _token;
    }

    //查询矿池余额
    function balance() external view returns (uint256) {
        require(mainToken != address(0), "mainToken invalid");
        return YiToken(mainToken).balanceOf(address(this));
    }

    // //结算所有人的余额
    // function settlement(address _exclude) internal {
    //     for (uint i=0; i < hashrates.length; i++) {
    //         if (_exclude == address(0)) {
    //             _update(hashrates[i].staker);
    //         } else if (hashrates[i].staker != _exclude) {
    //             _update(hashrates[i].staker);
    //         }
    //     }
    // }

    function HashrateTotal() external view returns (uint256 _total) {
        require(NFTHelp2Address != address(0), "NFTHelp2Address error");
        require(NFTToken != address(0), "NFTToken error");
        address[] memory allAddress = IYiBoxNFT(NFTToken).getAllOwners();
        for (uint i = 0; i < allAddress.length; i++) {
            _total += INFTHelpAdv2(NFTHelp2Address).getRealHashrate(allAddress[i]);
            
        } 
    }

        //记录质押时间节点
    function recordStake() internal {
        require(NFTToken != address(0), "NFTToken error");
        uint256 _hr = this.HashrateTotal();//IYiBoxNFT(NFTToken).getHashrateTotal();
        uint _now = now;
        if (stakeTimeStampList.length > 0) {
            if (stakeTimeStampList[stakeTimeStampList.length-1] != _now) {
                stakeTimeStampList.push(_now);
            }
        } else {
            stakeTimeStampList.push(_now);
        }
        stakeTimeStamp[_now].stakeNum = _hr;
        stakeTimeStamp[_now].lastAirDrop = lastAirDrop;
    }

    //和nft合约同步并结算算力池
    function settlementAll() external {
        // settlement(address(0));
        recordStake();
    }


    //空投，先重新计算所有人的收益,然后空投
    function airDrop() external lock {
        uint256 hashrateToal = this.HashrateTotal();//IYiBoxNFT(NFTToken).getHashrateTotal();
        require(mainPool != address(0),"mainPool error");
        require(lastestAirDroping.add(AD_INTERVAL) < block.timestamp, "airDroping error");
        // settlement(address(0));
        lastAirDrop = YiMainPool(mainPool).allocHashrateAirDrop(hashrateToal);
        lastestAirDroping = block.timestamp;
        recordStake();
    }

    function calcIncome(uint256 _hashrate, uint256 _delay, uint256 _hashrateToal, uint256 _lastAirDrop) internal pure returns(uint256) {
        if (_lastAirDrop == 0 || _hashrate == 0 || _hashrateToal == 0) {
            return 0;
        }
        return (_delay * _hashrate * _lastAirDrop) / (86400 * _hashrateToal);
    }

    //计算累计收益
    function getIncome(uint _idx, uint256 _time) internal  view returns (uint256 _income) {
        require(NFTHelp2Address != address(0), "NFTHelp2Address error");
        uint index = stakeTimeStampList.length;
        for(uint i = stakeTimeStampList.length - 1; i >= 0; i--) {
            if (hashrates[_idx].lTime >= stakeTimeStampList[i]) break;
            index = i;
        }

        for(uint i = index; i < stakeTimeStampList.length; i++) {
            if (i > 0) {
                uint _stake = stakeTimeStamp[stakeTimeStampList[i - 1]].stakeNum;
                uint dt = stakeTimeStampList[i] - stakeTimeStampList[i - 1];
                _income += calcIncome(INFTHelpAdv2(NFTHelp2Address).getRealHashrate(hashrates[_idx].staker), dt,_stake, stakeTimeStamp[stakeTimeStampList[i - 1]].lastAirDrop);
            }
        }

        if (_time - hashrates[_idx].lTime > 0 && _time - stakeTimeStampList[stakeTimeStampList.length - 1] > 0 && index > 0) {
            uint _stake = stakeTimeStamp[stakeTimeStampList[stakeTimeStampList.length - 1]].stakeNum;
            uint dt = _time - stakeTimeStampList[stakeTimeStampList.length - 1];
            _income += calcIncome(INFTHelpAdv2(NFTHelp2Address).getRealHashrate(hashrates[_idx].staker), dt, _stake, stakeTimeStamp[stakeTimeStampList[stakeTimeStampList.length - 1]].lastAirDrop);
        }
    }

    //收益更新
    function updateIncome(uint _idx, uint256 _time) internal returns (uint256 _income) {
        _income = getIncome(_idx, _time);
        hashrates[_idx].allIncome += _income;
        hashrates[_idx].balance += _income;
        hashrates[_idx].lTime = _time;
    }

    //更新算力池
    function update(address _staker) external returns(uint256) {
        require(_staker != address(0), "user error");
        require(mainPool != address(0) && NFTToken != address(0),"main or NFT error");
        require(NFTHelp2Address == msg.sender || msg.sender == owner() || msg.sender == address(this), "user error");

        uint256 _income = 0;
        if (ownerStake[_staker] == 0) {
            if (hashrates.length == 0) {
                // hashrates.push(Hashrate(_staker, now, now, 0, 0));
                hashrates.push(Hashrate(_staker, now, 0, 0));
                ownerStake[_staker] = hashrates.length - 1;
            } else {
                if (_staker == hashrates[0].staker) {
                    _income = updateIncome(0, now);
                } else {
                    // hashrates.push(Hashrate(_staker, now, now, 0, 0));
                    hashrates.push(Hashrate(_staker, now, 0, 0));
                    ownerStake[_staker] = hashrates.length - 1;
                }
            }
        } else {
            uint _idx = ownerStake[_staker];
            if (_staker == hashrates[_idx].staker) {
                _income = updateIncome(_idx , now);
            } else {
                require(false, "error address");
            }
        }

        return _income;
    }

    
    function openBox(uint32 _num) external lock returns(uint256[] memory _tks, uint256[] memory _qus, uint256[] memory _hrs, uint256[] memory _tys) {
        require(_num <= 10,"openBox error");
        require(NFTToken != address(0) && YiSetting != address(0),"NFT Setting error");
        require(mainPool != address(0),"mainPool error");
        require(HeroAddress != address(0) || BoxAddress != address(0),"heroAddress BoxAddress error");

        this.update(_msgSender());
        _tks = new uint256[](_num);
        uint256[] memory _useIdx;

        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), mainPool, 2, _num, "");
         (_qus,_tys, _useIdx, _hrs,)  = IYiBoxSetting(YiSetting).calcOpenBox(_num);
        for (uint i = 0; i < _num; i++) {
            uint256 _tarToken;
            if (_qus[i] <= 3) {
                _tarToken = 1 + (_qus[i] << 16) + (_tys[i] << 32);
                IYiBoxNFT1155(HeroAddress).safeTransferFrom(mainPool, _msgSender(), _tarToken, 1, "");
            } else {
                _tarToken = IYiBoxNFT(NFTToken).mint(_msgSender(), _useIdx[i], _qus[i], _hrs[i], _tys[i]);
            }
            _tks[i] = _tarToken;
        }

        recordStake();
        emit eOpenBox(_tks, _qus, _hrs, _tys);
    }

    //查询收益(每秒), 返回 每秒收益，质押量，总收益，当前余额
    function queryIncome(address _staker) external view returns(uint256,uint256,uint256,uint256){
        require(mainPool != address(0) && NFTToken != address(0), "mainPool error");
        require(NFTHelp2Address != address(0), "NFTHelp2Address error");
        require(hashrates.length > 0, "Empty staker");
        uint _idx = ownerStake[_staker];
        require(hashrates[_idx].staker == _staker, "no staker");

        uint256 _total = INFTHelpAdv2(NFTHelp2Address).getRealHashrate(hashrates[_idx].staker);
        uint256 hashrateToal = this.HashrateTotal();//IYiBoxNFT(NFTToken).getHashrateTotal();
        uint256 _incomePer = calcIncome(_total, 1,hashrateToal,lastAirDrop); //每秒收益
        uint256 _incomeNow = getIncome(_idx, now);

        return (_incomePer,_total, hashrates[_idx].allIncome + _incomeNow, hashrates[_idx].balance + _incomeNow);
    }

    //提现 (提现人 提现金额)
    function withdraw(address _sender, uint256 _amount) external lock returns(bool) {
        require(mainPool != address(0),"mainPool error");
        uint _idx = ownerStake[_sender];
        require(hashrates[_idx].staker == _sender, "Can't find staker");
        uint256 _PoolBal = this.balance();
        require(_amount <= _PoolBal, "Pool Insufficient balance");
        uint256 _balance = hashrates[_idx].balance;
        uint256 _time = now;
        uint256 _incomeNow = getIncome(_idx, _time);
        _balance += _incomeNow;
        require(_amount <= _balance, "Person Insufficient balance");
        hashrates[_idx].balance = _balance - _amount;
        hashrates[_idx].allIncome += _incomeNow;
        hashrates[_idx].lTime = _time;
        recordStake();
        return YiToken(mainToken).transfer(_sender, _amount);
        /*
        uint256 _incomeFee = _amount * IYiBoxSetting(YiSetting).getIncomePer() / 10000;
        uint256 _repoFee =  _amount * IYiBoxSetting(YiSetting).getRepoPer() / 10000;
        require((_incomeFee + _repoFee) < _amount, "fee error");

        YiToken(mainToken).transfer(IYiBoxSetting(YiSetting).getIncomePool(), _incomeFee);
        YiToken(mainToken).transfer(IYiBoxSetting(YiSetting).getrepoPool(), _repoFee);
        uint256 _result = _amount - _incomeFee - _repoFee;

        return YiToken(mainToken).transfer(_sender, _result);
        */
    }
}