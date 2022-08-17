// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.16;

import "./SafeMath.sol";
import "./Datasets.sol";

contract Addao is Datasets {
    
    string public name;// 名称
    
    string public symbol;// 符号

    uint8 public decimals;// 精度

    uint256 public totalSupply;// 发行总量
    
    uint256 public burnSupply;// 销毁量

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;
    
    using SafeMath for uint256;
    
    TetherToken tether;

    constructor(
        string memory _name,
        string memory _symbol,
        address _tetherAddr
    ){
        name = _name;
        symbol = _symbol;
        decimals = 8;
        totalSupply = 0;
        burnSupply = 0;
        totalShare = 0;
        usdtDecimals = 18;

        tokenPrice = 1 * 10 ** usdtDecimals;// USDT价格

        modifyAdFee = 1 * 10 ** 8;// token价格
        reviewsAdFee = 1 * 10 ** 8;// token价格
        
        tecRatio = 40;// 40/10000 技术 手续费
        bonusRatio = 1000;// 1000/10000 分红池比例
        shareRatio = 1000;// 1000/10000 股份池比例

        // 广告扩展参数
        AdMarkUintList.push("activationLink");// 激活网址 (1:激活 0:未激活)
        AdMarkUintList.push("fontSize");// 字体大小
        AdMarkUintList.push("like");// 喜欢
        AdMarkUintList.push("makeComplaints");// 吐槽
        AdMarkStringList.push("fontColor");// 字体颜色

        // 开始分红池
        bonusMaximumTime = 48 * 60 * 60;
        bonusSession = 1;
        bonusGame[bonusSession] = Bonus(
            {
                whetherToEnd : false,
                endTime : block.timestamp + bonusMaximumTime,
                bonusPrizePool : 0,
                participant : new address[](0),
                participationAmount : new uint256[](0),
                lastPrizePool : 0,
                received : 0,
                amountMaxAddr : address(0x0),
                amountMaxValue : 0,
                bonusEndNumOne : 0,
                bonusEndNumTwo : 0,
                bonusEndNumThree : 0
            }
        );
        
        // 开始股份池
        shareMaximumTime = 24 * 60 * 60;
        shareSession = 1;
        shareGame[shareSession] = Share(
            {
                whetherToEnd : false,
                endTime : block.timestamp + shareMaximumTime,
                totalFunds : 0,
                totalVotes : 0,
                receivedFunds : 0,
                receivedVotes : 0
            }
        );
        
        owner = msg.sender;
        tether = TetherToken(_tetherAddr);
        technologyAddr = msg.sender;
    }
    
    receive() external payable {}

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "implementation must already exists");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result 
                case 0 { revert(ptr, size) }
                default { return(ptr, size) }            
        }
    }

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event BuyToken(address indexed _addr, uint256 _value);

    event BurnToken(address _addr, uint256 _value);

    event ClaimEarnings(address _addr, uint256 _tokenVal);

    event StakeToken(address _addr, uint256 _usdtVal, uint256 _tokenVal);

    event WalletWithdrawal(address _addr, uint256 _tokenVal);

    modifier validDestination(address _to) {
        require(_to != address(0x0), "address cannot be 0x0");
        _;
    }
    
    modifier onlyowner()  {
        require(owner == msg.sender, "Insufficient permissions");
        _;
    }
    
    modifier onlyimplementation()  {
        require(address(this) == msg.sender, "Insufficient permissions");
        _;
    }

    // 两个字符串是否相等
    function isEqual(string memory a,string memory b) internal pure returns (bool){
        bytes32 hashA = keccak256(abi.encode(a));
        bytes32 hashB = keccak256(abi.encode(b));
        return hashA == hashB;
    }

    // 随机数
    function rand(uint256 _length, uint256 num) internal view returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, num)));
        return random % _length;
    }
    
    /**
    * 设置
    */

    // 设置逻辑地址
    function setImpl(address impl) external onlyowner validDestination(impl) returns (bool) {
        require(impl != implementation, "No change");
        implementation = impl;
        return true;
    }
    
    // 修改参数
    function upPara(address _technologyAddr, uint256 _modifyAdFee, uint256 _reviewsAdFee) external onlyowner returns (bool) {
        technologyAddr = _technologyAddr;
        if(_modifyAdFee > 0) {
            modifyAdFee = _modifyAdFee;
        }
        if(_reviewsAdFee > 0) {
            reviewsAdFee = _reviewsAdFee;
        }
        return true;
    }
    
    // 设置广告扩展参数
    function setAdMarkList(string memory _type, string memory _name) external onlyowner returns (bool) {
        if(isEqual(_type, "uint") == true) {
            AdMarkUintList.push(_name);
        } else if (isEqual(_type, "string") == true) {
            AdMarkStringList.push(_name);
        }
        return true;
    }

    // 授权
    function approve(address _spender, uint256 _value) public validDestination(_spender) returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 转账
    function transfer(address _to, uint256 _value) public validDestination(_to) returns (bool) {
        require(_value >= 0, "Incorrect transfer amount");
        require(_balances[msg.sender] >= _value, "Insufficient balance");
        require(_balances[_to] + _value >= _balances[_to], "Transfer failed");

        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
    // 授权转账
    function transferFrom(address _from, address _to, uint256 _value) public validDestination(_to) returns (bool) {
        require(_value >= 0, "Incorrect transfer amount");
        require(_balances[_from] >= _value, "Insufficient balance");
        require(_balances[_to] + _value >= _balances[_to], "Transfer failed");
        require(_allowances[_from][msg.sender] >= _value, "Insufficient authorized amount");

        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);

        emit Transfer(_from, _to, _value);

        return true;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }
    
    // 计算代币
    function calculationToken(uint256 _usdtVal) public view returns(uint256) {
        return _usdtVal.mul(10 ** 8).div(tokenPrice);
    }

    // 计算USDT
    function calculationUsdt(uint256 _tokenVal) public view returns(uint256) {
        return _tokenVal.mul(tokenPrice).div(10 ** 8);
    }

    // 查询USDT
    function balanceOfUSDT(address addr) public view validDestination(addr) returns (uint256) {
        return tether.balanceOf(addr);
    }

    // 更新代币价格
    function riseUsdt() internal returns(uint256) {
        uint256 tokenNum = totalSupply - burnSupply;
        if(tokenNum > 0) {
            tokenPrice = tether.balanceOf(address(this)).mul(10 ** 8).div(tokenNum);
        }

        return tokenPrice;
    }
    
    // 销毁代币
    function burnToken(address addr, uint256 _tokenval) internal validDestination(addr) returns (bool) {
        require(_tokenval > 0, "Incorrect quantity");
        require(_balances[addr] >= _tokenval, "Insufficient balance");

        _balances[addr] = _balances[addr].sub(_tokenval);

        // 手续费
        uint256 tecVal = _tokenval.mul(tecRatio).div(10000);
        PlayerMap[technologyAddr].wallet = PlayerMap[technologyAddr].wallet.add(tecVal);

        // 分红池
        uint256 bonusVal = _tokenval.mul(bonusRatio).div(10000);

        // 股份池
        uint256 shareVal = _tokenval.mul(shareRatio).div(10000);

        // 托管到智能合约
        _balances[address(this)] = _balances[address(this)].add(tecVal).add(bonusVal).add(shareVal);

        // 销毁量
        uint256 burnVal = _tokenval.sub(tecVal).sub(bonusVal).sub(shareVal);
        _balances[address(0x0)] = _balances[address(0x0)].add(burnVal);

        // 用户总销毁量
        PlayerMap[addr].totalBurnAmount = PlayerMap[addr].totalBurnAmount.add(burnVal);

        // 更新销毁量
        burnSupply = burnSupply.add(burnVal);
        tokenPrice = riseUsdt();
        
        // 销毁记录
        burnLogList.push(BurnLog(addr, burnVal, block.timestamp));

        emit BurnToken(addr, burnVal);

        return true;
    }

    /**
    * 外部调用 主要逻辑
    */

    // 修改推荐人
    function setReferrer(address _superiorAddr) external validDestination(_superiorAddr) returns (bool) {
        Player storage player = PlayerMap[msg.sender];
        address superiorAddr = player.superiorAddr;
        require(address(0x0) == superiorAddr, "Referrer address cannot be changed");
        require(address(0x0) != _superiorAddr, "address cannot be 0x0");
        require(msg.sender != _superiorAddr, "Can't be myself");

        player.superiorAddr = _superiorAddr;

        player = PlayerMap[_superiorAddr];
        player.subordinates.push(msg.sender);
        player.subordinatesCount = player.subordinates.length;

        return true;
    }
    
    // 购买代币 TetherToken approve
    function buyToken(uint256 _tokenVal) external returns (bool) {
        require(_tokenVal > 0, "Incorrect token quantity");

        uint256 _usdtVal = calculationUsdt(_tokenVal);

        require(_usdtVal > 0, "Amount is too small");
        require(tether.balanceOf(msg.sender) >= _usdtVal, "Incorrect amount");
        require(tether.allowance(msg.sender, address(this)) >= _usdtVal, "Insufficient authorized amount");

        tether.transferFrom(msg.sender, address(this), _usdtVal);
        _balances[msg.sender] = _balances[msg.sender].add(_tokenVal);

        totalSupply = totalSupply.add(_tokenVal);

        emit BuyToken(msg.sender, _tokenVal);

        return true;
    }

    // 钱包提现
    function walletWithdrawal(uint256 _tokenVal) external returns (bool) {
        require(_tokenVal > 0, "Incorrect token quantity");
        
        require(PlayerMap[msg.sender].wallet >= _tokenVal, "Insufficient balance");

        PlayerMap[msg.sender].wallet = PlayerMap[msg.sender].wallet.sub(_tokenVal);

        uint256 _usdtVal = calculationUsdt(_tokenVal);

        require(_usdtVal > 0, "Amount is too small");
        require(tether.balanceOf(address(this)) >= _usdtVal, "Insufficient contract balance");
        
        tether.transfer(msg.sender, _usdtVal);
        _balances[address(this)] = _balances[address(this)].sub(_tokenVal);
        _balances[address(0x0)] = _balances[address(0x0)].add(_tokenVal);
        
        // 用户总销毁量
        PlayerMap[address(this)].totalBurnAmount = PlayerMap[address(this)].totalBurnAmount.add(_tokenVal);

        // 更新销毁量
        burnSupply = burnSupply.add(_tokenVal);

        // 销毁记录
        burnLogList.push(BurnLog(address(this), _tokenVal, block.timestamp));

        emit WalletWithdrawal(msg.sender, _tokenVal);

        return true;
    }

    /**
    * 逻辑合约操作
    * msg.sender == address(this)
    */

    /**
    * TetherToken approve
    * 发布广告，质押代币
    */
    function stakeToken(address addr, uint256 _usdtVal) external onlyimplementation returns (uint256) {
        require(_usdtVal >= 1, "value must >= 1");
        require(tether.balanceOf(addr) >= _usdtVal, "Incorrect amount");
        require(tether.allowance(addr, address(this)) >= _usdtVal, "Insufficient authorized amount");

        uint256 _tokenVal = calculationToken(_usdtVal);
        require(_tokenVal > 0, "Incorrect token quantity");

        tether.transferFrom(addr, address(this), _usdtVal);
        _balances[address(this)] = _balances[address(this)].add(_tokenVal);

        totalSupply = totalSupply.add(_tokenVal);

        emit StakeToken(addr, _usdtVal, _tokenVal);

        return _tokenVal;        
    }

    /**
    * 删除广告，销毁代币，兑换回USDT
    */
    function claimEarnings(address addr, uint256 _tokenVal) external onlyimplementation returns (uint256) {
        require(_tokenVal > 0, "Incorrect quantity");
        require(_balances[address(this)] >= _tokenVal, "Insufficient balance");

        // 手续费
        uint256 tecVal = _tokenVal.mul(tecRatio).div(10000);
        // 扣除手续费
        uint256 _usdtVal = calculationUsdt(_tokenVal.sub(tecVal));

        require(_usdtVal > 0, "Amount is too small");
        require(tether.balanceOf(address(this)) >= _usdtVal, "Incorrect amount");

        // 兑换回USDT
        tether.transfer(addr, _usdtVal);

        // 销毁量
        uint256 burnVal = _tokenVal.sub(tecVal);
        _balances[address(this)] = _balances[address(this)].sub(burnVal);
        _balances[address(0x0)] = _balances[address(0x0)].add(burnVal);

        // 手续费
        PlayerMap[technologyAddr].wallet = PlayerMap[technologyAddr].wallet.add(tecVal);

        // 用户总销毁量
        PlayerMap[address(this)].totalBurnAmount = PlayerMap[address(this)].totalBurnAmount.add(burnVal);

        // 更新销毁量
        burnSupply = burnSupply.add(burnVal);
        
        // 销毁记录
        burnLogList.push(BurnLog(address(this), burnVal, block.timestamp));

        emit ClaimEarnings(addr, _tokenVal);

        return _usdtVal;
    }

    /**
    * 广告消费，销毁代币
    */
    function adFee(address addr, uint256 _tokenVal) external onlyimplementation returns (bool) {
        require(_tokenVal > 0, "Incorrect token quantity");
        require(_balances[addr] >= _tokenVal, "Insufficient balance");

        burnToken(addr, _tokenVal);

        return true;
    }

    /**
    * 查询
    */
    
    // 查询广告信息 [基本参数],['竞价金额'],['扩展参数数字型'],['扩展参数字符型']
    function getAd(bytes4 adHash) external view returns (AdData memory, uint256, uint256[] memory, string[] memory) {
        AdData memory addata = AdMap[adHash];
        uint256 bidAmount = bidAmountMap[adHash];// 广告竞价金额
        uint256[] memory AdMarkUint = new uint256[](AdMarkUintList.length);
        string[] memory AdMarkString = new string[](AdMarkStringList.length);
        
        for(uint256 i = 0; i < AdMarkUintList.length; i ++) {
            AdMarkUint[i] = AdMarkMapUint[adHash][AdMarkUintList[i]];
        }

        for(uint256 i = 0; i < AdMarkStringList.length; i ++) {
            AdMarkString[i] = AdMarkMapString[adHash][AdMarkStringList[i]];
        }

        return (addata, bidAmount, AdMarkUint, AdMarkString);
    }

    // 销毁记录 (开始位置，结束位置)
    function getBurnLogList(uint256 start, uint256 end) external view returns (BurnLog[] memory) {
        require(start <= end, "start <= end");
        
        uint256 count = end - start + 1;
        if(start >= burnLogList.length){
            count = 0;
        } else if(end >= burnLogList.length){
            end = burnLogList.length - 1;
            count = end - start + 1;
        }
        BurnLog[] memory output = new BurnLog[](count);
        uint256 num = 0;
        for(uint256 i = start; i < burnLogList.length; i ++) {
            output[num] = burnLogList[i];
            if(i == end) {
                break;
            }
            num++;
        }
        return output;
    }
    
    // 关键词列表 (开始位置，结束位置)
    function getKeywordsList(uint256 start, uint256 end) external view returns (string[] memory) {
        require(start <= end, "start <= end");
        
        uint256 count = end - start + 1;
        if(start >= keywordsList.length){
            count = 0;
        } else if(end >= keywordsList.length){
            end = keywordsList.length - 1;
            count = end - start + 1;
        }
        string[] memory output = new string[](count);
        uint256 num = 0;
        for(uint256 i = start; i < keywordsList.length; i ++) {
            output[num] = keywordsList[i];
            if(i == end) {
                break;
            }
            num++;
        }
        return output;
    }

    // 关键词广告列表 (关键词, 开始位置，结束位置)
    function getKeywordsAdHashList(string memory _keywords, uint256 start, uint256 end) external view returns (bytes4[] memory) {
        require(start <= end, "start <= end");
        
        Keywords storage keywords = keywordsMap[_keywords];

        uint256 count = end - start + 1;
        if(start >= keywords.keywordsAdHashList.length){
            count = 0;
        } else if(end >= keywords.keywordsAdHashList.length){
            end = keywords.keywordsAdHashList.length - 1;
            count = end - start + 1;
        }
        bytes4[] memory output = new bytes4[](count);
        uint256 num = 0;
        for(uint256 i = start; i < keywords.keywordsAdHashList.length; i ++) {
            output[num] = keywords.keywordsAdHashList[i];
            if(i == end) {
                break;
            }
            num++;
        }
        return output;
    }

    // 竞价广告列表 (开始位置，结束位置)
    function getBidAmountList(uint256 start, uint256 end) internal view returns (bytes4[] memory) {
        require(start <= end, "start <= end");
        
        uint256 count = end - start + 1;
        if(start >= bidAmountList.length){
            count = 0;
        } else if(end >= bidAmountList.length){
            end = bidAmountList.length - 1;
            count = end - start + 1;
        }
        bytes4[] memory output = new bytes4[](count);
        uint256 num = 0;
        for(uint256 i = start; i < bidAmountList.length; i ++) {
            output[num] = bidAmountList[i];
            if(i == end) {
                break;
            }
            num++;
        }
        return output;
    }
    
    // 随机广告列表
    function getAdHashList(uint256 count) internal view returns (bytes4[] memory) {
        if(count > adHashList.length){
            count = adHashList.length;
        }
        bytes4[] memory output = new bytes4[](count);
        for(uint256 i = 0; i < count; i ++) {
            uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, i))) % count;
            output[i] = adHashList[random];
        }
        return output;
    }

    // 加载广告 竞价广告优先 (开始位置，结束位置)
    // 返回 isBid=true 广告是竞价广告 isBid=false 广告是普通广告
    function loadAd(uint256 start, uint256 end) external view returns (bytes4[] memory, bool) {
        require(start <= end, "start <= end");
        bool isBid = true;
        bytes4[] memory output = getBidAmountList(start, end);
        if(output.length == 0) {
            uint256 count = end - start + 1;
            output = getAdHashList(count);
            isBid = false;
        }
        return (output, isBid);
    }

    // 我的广告列表 status=0:正在投放 status=1：已结束投放
    function myAdList(uint256 _type) external view returns (bytes4[] memory) {
        if(_type == 0) {
            return PlayerMap[msg.sender].adList;
        } else {
            return PlayerMap[msg.sender].adFinishList;
        }
    }

    // 数据面板
    function Dashboard() external view returns (uint256[] memory) {
        uint256[] memory output = new uint256[](12);
        uint256 _balanceOfUSDT = balanceOfUSDT(address(this));
        Bonus memory bonus = bonusGame[bonusSession];
        Share memory share = shareGame[shareSession];
        uint256 balanceOfContract = _balances[address(this)];
        uint256 balanceOfLiquidity = totalSupply.sub(burnSupply).sub(balanceOfContract);
        
        output[0] = _balanceOfUSDT; // 金库市值
        output[1] = bonus.bonusPrizePool; // 分红池
        output[2] = share.totalFunds;// 股份池
        output[3] = tokenPrice; // 代币价格
        output[4] = totalSupply; // 发行总量
        output[5] = burnSupply; // 销毁量
        output[6] = balanceOfContract; // 质押量
        output[7] = balanceOfLiquidity; // 流通量
        output[8] = adHashList.length; // 在线广告数量
        output[9] = totalCompletedAd; // 完成广告数量
        output[10] = totalRevenue;// 完成广告收益
        output[11] = totalShare;// 发行股份总量

        return output;
    }

    // 查询分红池信息
    function getBonusInfo() external view returns(uint256, uint256, uint256, uint256, bool) {
        Bonus storage bonus = bonusGame[bonusSession];
        return (
            bonusSession, 
            block.timestamp, 
            bonus.endTime, 
            bonus.bonusPrizePool, 
            bonus.whetherToEnd
        );
    }

    // 查询股份池信息
    function getShareInfo() external view returns(uint256, uint256, uint256, uint256, uint256, bool) {
        Share storage share = shareGame[shareSession];
        return (
            shareSession, 
            block.timestamp, 
            share.endTime, 
            share.totalFunds, 
            share.totalVotes,
            share.whetherToEnd
        );
    }
}

abstract contract TetherToken {
    function transfer(address to, uint value) external virtual;
    function transferFrom(address from, address to, uint value) external virtual;
    function balanceOf(address who) external view virtual returns (uint256);
    function allowance(address owner, address spender) external view virtual returns (uint256);
}