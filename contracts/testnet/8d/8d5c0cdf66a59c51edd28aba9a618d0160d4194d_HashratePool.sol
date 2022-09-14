// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "./IYiBoxBase.sol";

interface YiMainPool {
    function allocHashrateAirDrop(uint256 _need) external;
}

interface IYiBoxNFT {
    function getAllOwners() external view returns (address[] memory _owners);
    function mint(address to, uint256 tokenId, uint256 _quality, uint256 _hashrate,uint256 ttype) external returns(uint256);

}

interface IYiToken {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
}

// interface INFTHelpAdv2 {
//     function getRealHashrate(address target) external view returns (uint256);
// }

interface IYiBoxNFT1155 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}


contract HashratePool is  AYiBoxBase {
    using SafeMath for uint256;

    uint256 public lastAirDrop; //上次空投量

    uint256 constant AD_INTERVAL = 23 hours + 50 minutes;
    uint256 public lastestAirDroping;   //上次空投时间戳（秒）
    address public mainPool;           //主矿池
    address public HeroAddress;        //1155Hero
    address public BoxAddress;         //1155Box
    // address public NFTHelp2Address;

    // INFTHelpAdv2 NFTHelpADV2;
    IYiToken mainToken;          //主币
    IYiBoxNFT NFTToken;

    // event eOpenBox(uint256[] indexed _tks, uint256[] indexed _lvs, uint256[] indexed _hrs, uint256[] _tys);
    event eOpenBox(uint256[] _tks, uint256[] _lvs, uint256[] _hrs, uint256[] _tys);

    function setNFTToken(address _NFTToken) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        NFTToken = IYiBoxNFT(_NFTToken);
    }
/*
    function setNFTHelp2Address(address _NFTHelp) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        NFTHelp2Address = _NFTHelp;
        // NFTHelpADV2 = INFTHelpAdv2(NFTHelp2Address);
    }
*/
    function setHeroAddress(address _HeroAddress) public onlyOwner {
        // require(_NFTToken != address(0), "NFTToken invalid");
        HeroAddress = _HeroAddress;
    }

    function setBoxAddress(address _BoxAddress) public onlyOwner {
        BoxAddress = _BoxAddress;
    }

    //设置主矿池
    function setMainPool(address _main) external onlyOwner {
        require(_main != address(0));
        mainPool = _main;
    }

    //设置主币
    function setMainToken(address _token) external onlyOwner {
        // require(_token != address(0), "mainToken invalid");
        mainToken = IYiToken(_token);
    }

    function getAllStakers() public view returns (address[] memory _staker) {

    }

    //查询矿池余额
    function balance() external view returns (uint256) {
        return mainToken.balanceOf(address(this));
    }

    function transferAll(address _to) public onlyOwner {
        uint256 all = this.balance();
        mainToken.transfer(_to, all);
    }

    function HashrateTotal() external view returns (uint256 _total) {
        _total = YiBoxBase.GetParam(YiBoxType.HashrateMaxHashrate);
    }

        //记录质押时间节点并返回最新量
    function recordStake() internal returns (uint256 base) {
        uint256 stakeTimeStamp = YiBoxBase.GetParam(YiBoxType.HashrateStakeTimeStamp);
        if (stakeTimeStamp == 0) {
            YiBoxBase.SetParam(YiBoxType.HashrateStakeTimeStamp, block.timestamp);
            
        } else {
            uint256 _delay = block.timestamp-stakeTimeStamp;
            if (_delay > 0) {
                base = YiBoxBase.GetLastStakeNode(YiBoxType.HashrateStakeNode) + calcIncome(1,_delay,YiBoxBase.GetParam(YiBoxType.HashrateMaxHashrate),lastAirDrop);
                uint256[] memory v1 = new uint256[](2);
                v1[0] = block.timestamp;
                v1[1] = base;
                YiBoxBase.SetParam(YiBoxType.HashrateStakeTimeStampStakeNode,makeAParam(0),v1,new address[](0));
            }
        }
    }

    //和nft合约同步并结算算力池
    function settlementAll() external {
        uint256 stakeTimeStamp = YiBoxBase.GetParam(YiBoxType.HashrateStakeTimeStamp);
        if (stakeTimeStamp == 0) {
            YiBoxBase.SetParam(YiBoxType.HashrateStakeTimeStamp, block.timestamp);
            // stakeNode[stakeTimeStamp] = 0;
        } else {
            uint256 _delay = block.timestamp-stakeTimeStamp;
            if (_delay > 0) {
                uint256 base = YiBoxBase.GetLastStakeNode(YiBoxType.HashrateStakeNode) + calcIncome(1,_delay,YiBoxBase.GetParam(YiBoxType.HashrateMaxHashrate),lastAirDrop);
                uint256[] memory v1 = new uint256[](2);
                v1[0] = block.timestamp;
                v1[1] = base;
                YiBoxBase.SetParam(YiBoxType.HashrateStakeTimeStampStakeNode,makeAParam(0),v1,new address[](0));
            }
            
        }
    }


    //空投，先重新计算所有人的收益,然后空投
    function airDrop() external {
        uint256 hashrateToal = this.HashrateTotal();//IYiBoxNFT(NFTToken).getHashrateTotal();
        require(mainPool != address(0),"mainPool error");
        require(lastestAirDroping.add(AD_INTERVAL) < block.timestamp, "airDroping error");
        // settlement(address(0));
        uint256 decimal = 10 ** 18;
        if (hashrateToal >= 500001) {
            lastAirDrop = 200000 * decimal;
        } else if (hashrateToal >= 400001) {
            lastAirDrop = 120000 * decimal;
        } else if (hashrateToal >= 300001) {
            lastAirDrop = 70000 * decimal;
        } else if (hashrateToal >= 200001) {
            lastAirDrop = 30000 * decimal;
        } else if (hashrateToal >= 100001) {
            lastAirDrop = 20000 * decimal;
        } else {
            lastAirDrop = 10000 * decimal;
        }
        YiMainPool(mainPool).allocHashrateAirDrop(lastAirDrop);
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
    function getIncome(Hashrate memory _hashrate) internal returns (uint256 _income) {
        uint256 _new = recordStake();
        uint256 lTime = _hashrate.info >> 192;
        uint256 hashrate = (_hashrate.info >> 64) % 0x10000000000000000;
        _income = (_new - YiBoxBase.GetParam(YiBoxType.HashrateStakeNode,lTime)) * hashrate;
    }

    //收益更新
    function updateIncome(Hashrate memory _hashrate) internal returns (uint256 _income) {
        _income = getIncome(_hashrate);
        _hashrate.allIncome += _income;
        _hashrate.balance += _income;
        _hashrate.info = (_hashrate.info << 64 >> 64) + (block.timestamp << 192);
        YiBoxBase.SetHashrate(YiBoxType.HashrateSet, tx.origin, _hashrate);
    }

    //更新算力池
    function update(address _staker) internal returns(uint256) {
        Hashrate memory _hashrate = YiBoxBase.GetHashrate(_staker);
        require(_hashrate.info != 0, "user error");
        // require(NFTHelp2Address == msg.sender || msg.sender == owner() || msg.sender == address(this), "user error");
        uint256 _income = updateIncome(_hashrate);
        return _income;
    }

    function checkOpenbox(uint256 _num) internal view returns (uint256 _s) {
        require(mainPool != address(0),"mainPool error");
        require(HeroAddress != address(0) || BoxAddress != address(0),"heroAddress BoxAddress error");
        Hashrate memory _hs = YiBoxBase.GetHashrate(_msgSender());
        require(_hs.info != 0,"get box num error");
        _s = _hs.info % 0x100000000;
        uint256 _e = (_hs.info >> 32) % 0x100000000;
        require(_num <= (_e - _s + 1), "openbox out range");
    }
    
    function openBox(uint256 _num) external returns(uint256[] memory _tks, uint256[] memory _qus, uint256[] memory _hrs, uint256[] memory _tys) {
        // require(_num <= 10,"openBox error");
        uint256 _s = checkOpenbox(_num);
        _tks = new uint256[](_num);
        uint256[] memory _useIdx;
        IYiBoxNFT1155(BoxAddress).safeTransferFrom(_msgSender(), owner(), 2, _num, "");
        (_qus,_tys, _useIdx, _hrs)  = YiSetting.calcOpenBox(_s, (_s + _num - 1));

        uint256[] memory id_ = new uint256[](_num);
        uint256[] memory am_ = new uint256[](_num);
        uint cou = 0;

        uint256 hasadd;
        for (uint i = 0; i < _num; i++) {
            if (_qus[i] <= 3) {
                _tks[i] = 1 + (_qus[i] << 16) + (_tys[i] << 32);
                bool find = false;
                for (uint j = 0; j < cou; j++) {
                    if (id_[j] == _tks[i]) {
                        find = true;
                        am_[j]++;
                        break;
                    }
                }

                if (!find) {
                    id_[cou] = _tks[i];
                    am_[cou] = 1;
                    cou++;
                }
            } else {
                _tks[i] = IYiBoxNFT(NFTToken).mint(_msgSender(), _useIdx[i], _qus[i], _hrs[i], _tys[i]);
            }
            hasadd += _hrs[i];
        }

        updatehashate(true, true, hasadd, _msgSender(), _tys, _qus);
        IYiBoxNFT1155(HeroAddress).safeBatchTransferFrom(mainPool, _msgSender(), id_, am_, "");
        update(_msgSender());
        emit eOpenBox(_tks, _qus, _hrs, _tys);
    }

    function queryIncomeNow(Hashrate memory hashrates) internal view returns(uint256 IncomeNow){
        uint256 stakeTimeStamp = YiBoxBase.GetParam(YiBoxType.HashrateStakeTimeStamp);
        uint256 lTime = hashrates.info >> 192;
        uint256 hashrate = (hashrates.info >> 64) % 0x10000000000000000;
        uint256 base = YiBoxBase.GetLastStakeNode(YiBoxType.HashrateStakeNode) - YiBoxBase.GetParam(YiBoxType.HashrateStakeNode,lTime) + calcIncome(1, block.timestamp - stakeTimeStamp,YiBoxBase.GetParam(YiBoxType.HashrateMaxHashrate),lastAirDrop);
        IncomeNow = base * hashrate; 
    }

    //查询收益(每秒), 返回 每秒收益，质押量，总收益，当前余额
    function queryIncome(address _staker) external view returns(uint256,uint256,uint256,uint256){
        Hashrate memory hashrate = YiBoxBase.GetHashrate(_staker);
        uint256 _hashrate = (hashrate.info >> 64) % 0x10000000000000000;
        require(_hashrate != 0, "no staker");
        uint256 _incomePer = calcIncome(_hashrate, 1,YiBoxBase.GetParam(YiBoxType.HashrateMaxHashrate),lastAirDrop); //每秒收益
        uint256 _incomeNow = queryIncomeNow(hashrate);
        return (_incomePer,_hashrate, hashrate.allIncome + _incomeNow, hashrate.balance + _incomeNow);
    }

    //提现 (提现人 提现金额)
    function withdraw(address _sender, uint256 _amount) external returns(bool) {
        Hashrate memory hashrates = YiBoxBase.GetHashrate(_sender);
        uint256 hashrate = (hashrates.info >> 64) % 0x10000000000000000;
        require(hashrate != 0, "no staker");
        uint256 _PoolBal = this.balance();
        require(_amount <= _PoolBal, "Pool Insufficient balance");
        uint256 _balance = hashrates.balance;
        uint256 _time = block.timestamp;
        uint256 _incomeNow = getIncome(hashrates);
        _balance += _incomeNow;
        require(_amount <= _balance, "Person Insufficient balance");

        hashrates.info = (hashrates.info << 64 >> 64) + (_time << 192);
        hashrates.allIncome += _incomeNow;
        hashrates.balance = _balance - _amount;
        YiBoxBase.SetHashrate(YiBoxType.HashrateSet, _msgSender(), hashrates);
        return mainToken.transfer(_sender, _amount);
    }
}