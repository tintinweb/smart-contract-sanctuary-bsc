// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "./SafeMath.sol";
import "./utils.sol";
import "./Datasets.sol";

contract Addao is Datasets {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 public totalBurn;
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
        totalBurn = 0;
        totalShare = 0;
        totalAllShareRevenue = 0;
        usdtDecimals = 18;
        tokenPrice = 1 * 10 ** usdtDecimals;
        tecRatio = 40;
        bonusRatio = 1000;
        shareRatio = 1000;
        AdMarkUintList.push("activationLink");
        AdMarkUintList.push("fontSize");
        AdMarkUintList.push("like");
        AdMarkUintList.push("makeComplaints");
        AdMarkStringList.push("fontColor");
        _nextKeywords[keywordsHead] = keywordsHead;
        _nextBidder[bidderHead] = bidderHead;
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
                maxAddr : address(0x0),
                maxValue : 0,
                endNumOne : 0,
                endNumTwo : 0,
                endNumThree : 0
            }
        );
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

    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Transfer(address indexed from, address indexed to, uint256 value);

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
    
    function approve(address _spender, uint256 _value) public validDestination(_spender) returns (bool) {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) public validDestination(_to) returns (bool) {
        require(_value >= 0, "Incorrect transfer amount");
        require(_balances[msg.sender] >= _value, "Insufficient balance");
        require(_balances[_to] + _value >= _balances[_to], "Transfer failed");
        _balances[msg.sender] = _balances[msg.sender].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
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
    
    function calculationToken(uint256 _usdtVal) public view returns(uint256) {
        return _usdtVal.mul(10 ** 8).div(tokenPrice);
    }

    function calculationUsdt(uint256 _tokenVal) public view returns(uint256) {
        return _tokenVal.mul(tokenPrice).div(10 ** 8);
    }

    function balanceOfUSDT(address addr) public view validDestination(addr) returns (uint256) {
        return tether.balanceOf(addr);
    }

    function riseUsdt() internal returns(uint256) {
        uint256 tokenNum = totalSupply.sub(totalBurn);
        if(tokenNum > 0) {
            tokenPrice = tether.balanceOf(address(this)).mul(10 ** 8).div(tokenNum);
        }
        return tokenPrice;
    }
    
    function burnToken(address addr, uint256 _tokenval) internal validDestination(addr) returns (bool) {
        require(_tokenval > 0, "Incorrect quantity");
        require(_balances[addr] >= _tokenval, "Insufficient balance");
        _balances[addr] = _balances[addr].sub(_tokenval);
        uint256 tecVal = _tokenval.mul(tecRatio).div(10000);
        PlayerMap[technologyAddr].wallet = PlayerMap[technologyAddr].wallet.add(tecVal);
        uint256 bonusVal = _tokenval.mul(bonusRatio).div(10000);
        uint256 shareVal = _tokenval.mul(shareRatio).div(10000);
        _balances[address(this)] = _balances[address(this)].add(tecVal).add(bonusVal).add(shareVal);
        uint256 burnVal = _tokenval.sub(tecVal).sub(bonusVal).sub(shareVal);
        _balances[address(0x0)] = _balances[address(0x0)].add(burnVal);
        PlayerMap[addr].totalBurnAmount = PlayerMap[addr].totalBurnAmount.add(burnVal);
        totalBurn = totalBurn.add(burnVal);
        tokenPrice = riseUsdt();
        burnLogList.push(BurnLog(addr, burnVal, block.timestamp));
        emit Transfer(addr, address(0x0), burnVal);
        emit Transfer(addr, address(this), _tokenval.sub(burnVal));
        return true;
    }

    function buyToken(uint256 _tokenVal) external returns (bool) {
        require(_tokenVal > 0, "Incorrect token quantity");
        uint256 _usdtVal = calculationUsdt(_tokenVal);
        require(_usdtVal > 0, "Amount is too small");
        require(tether.balanceOf(msg.sender) >= _usdtVal, "Incorrect amount");
        require(tether.allowance(msg.sender, address(this)) >= _usdtVal, "Insufficient authorized amount");
        tether.transferFrom(msg.sender, address(this), _usdtVal);
        _balances[msg.sender] = _balances[msg.sender].add(_tokenVal);
        totalSupply = totalSupply.add(_tokenVal);
        emit Transfer(address(this), msg.sender, _tokenVal);
        return true;
    }

    function walletWithdrawal(uint256 _tokenVal) external returns (bool) {
        require(_tokenVal > 0, "Incorrect token quantity");
        require(PlayerMap[msg.sender].wallet >= _tokenVal, "Insufficient balance");
        require(_balances[address(this)] >= _tokenVal, "Insufficient token");
        PlayerMap[msg.sender].wallet = PlayerMap[msg.sender].wallet.sub(_tokenVal);
        uint256 _usdtVal = calculationUsdt(_tokenVal);
        require(_usdtVal > 0, "Amount is too small");
        require(tether.balanceOf(address(this)) >= _usdtVal, "Insufficient contract balance");
        tether.transfer(msg.sender, _usdtVal);
        _balances[address(this)] = _balances[address(this)].sub(_tokenVal);
        _balances[address(0x0)] = _balances[address(0x0)].add(_tokenVal);
        PlayerMap[address(this)].totalBurnAmount = PlayerMap[address(this)].totalBurnAmount.add(_tokenVal);
        totalBurn = totalBurn.add(_tokenVal);
        burnLogList.push(BurnLog(address(this), _tokenVal, block.timestamp));
        emit Transfer(address(this), address(0x0), _tokenVal);
        return true;
    }

    function stakeToken(address addr, uint256 _usdtVal) external onlyimplementation returns (uint256) {
        require(_usdtVal >= 1 * 10 ** usdtDecimals, "value must >= 1usdt");
        require(tether.balanceOf(addr) >= _usdtVal, "Incorrect amount");
        require(tether.allowance(addr, address(this)) >= _usdtVal, "Insufficient authorized amount");
        uint256 _tokenVal = calculationToken(_usdtVal);
        require(_tokenVal > 0, "Amount is too small");
        tether.transferFrom(addr, address(this), _usdtVal);
        _balances[address(this)] = _balances[address(this)].add(_tokenVal);
        totalSupply = totalSupply.add(_tokenVal);
        emit Transfer(address(this), address(this), _tokenVal);
        return _tokenVal;        
    }

    function claimEarnings(bytes4 adHash) external onlyimplementation returns (uint256) {
        require(AdMap[adHash].IsExist == true, "does not exist");
        require(AdMap[adHash].status == 0 || AdMap[adHash].status == 1, "The ad is done");
        AdMap[adHash].status = 2;
        address operator = AdMap[adHash].operator;
        uint256 stakingTokens = AdMap[adHash].stakingTokens;
        require(_balances[address(this)] >= stakingTokens, "Insufficient token");
        uint256 tecVal = stakingTokens.mul(tecRatio).div(10000);
        uint256 _usdtVal = calculationUsdt(stakingTokens.sub(tecVal));
        require(_usdtVal > 0, "Amount is too small");
        require(tether.balanceOf(address(this)) >= _usdtVal, "Incorrect amount");
        tether.transfer(operator, _usdtVal);
        uint256 burnVal = stakingTokens.sub(tecVal);
        _balances[address(this)] = _balances[address(this)].sub(burnVal);
        _balances[address(0x0)] = _balances[address(0x0)].add(burnVal);
        PlayerMap[technologyAddr].wallet = PlayerMap[technologyAddr].wallet.add(tecVal);
        PlayerMap[address(this)].totalBurnAmount = PlayerMap[address(this)].totalBurnAmount.add(burnVal);
        totalBurn = totalBurn.add(burnVal);
        burnLogList.push(BurnLog(address(this), burnVal, block.timestamp));
        emit Transfer(address(this), address(0x0), burnVal);
        return _usdtVal;
    }

    function adFee(address addr, uint256 _tokenVal) external onlyimplementation returns (bool) {
        require(_tokenVal > 0, "Incorrect token quantity");
        require(_balances[addr] >= _tokenVal, "Insufficient balance");
        burnToken(addr, _tokenVal);
        return true;
    }

    function issueShare(address addr) external onlyimplementation returns (bool) {
        bool result = false;
        Player storage player = PlayerMap[addr];
        address superiorAddr = player.superiorAddr;
        if(address(0x0) != superiorAddr) {
            player = PlayerMap[superiorAddr];
            address superiorAddr2 = player.superiorAddr;
            if(address(0x0) != superiorAddr2) {
                bytes4 stockHash = bytes4(keccak256(abi.encode(superiorAddr, addr)));
                if(StockMap[stockHash].IsExist != true) {
                    StockMap[stockHash] = Stock(
                        true,
                        superiorAddr,
                        addr,
                        block.timestamp,
                        shareSession - 1
                    );
                    stockHashList.push(stockHash);
                    player.stockList.push(stockHash);
                    player.stockCount = player.stockList.length;

                    totalShare = totalShare.add(1);
                    result = true;
                }
            }
        }
        return result;
    }

    function recyclingShare(address addr) external onlyimplementation returns (bool) {
        bool result = false;
        Player storage player = PlayerMap[addr];
        address superiorAddr = player.superiorAddr;
        if(address(0x0) != superiorAddr) {
            uint256 length = player.adList.length;
            if(length == 0) {
                bytes4 stockHash = bytes4(keccak256(abi.encode(superiorAddr, addr)));
                if(StockMap[stockHash].IsExist == true) {
                    delete StockMap[stockHash];
                    utils.arrayRemoveBytes4(stockHashList, utils.indexOfBytes4(stockHashList, stockHash));
                    player = PlayerMap[superiorAddr];
                    utils.arrayRemoveBytes4(player.stockList, utils.indexOfBytes4(player.stockList, stockHash));
                    player.stockCount = player.stockList.length;
                    totalShare = totalShare.sub(1);
                    result = true;
                }
            }
        }
        return result;
    }

    function upPara(address impl, address _technologyAddr) external onlyowner validDestination(impl) validDestination(_technologyAddr) returns (bool) {
        require(implementation != impl || technologyAddr != _technologyAddr, "No change");
        implementation = impl;
        technologyAddr = _technologyAddr;
        return true;
    }
    
    function setAdMarkList(string memory _type, string memory _name) external onlyowner returns (bool) {
        if(utils.isEqual(_type, "uint") == true) {
            AdMarkUintList.push(_name);
            return true;
        } else if (utils.isEqual(_type, "string") == true) {
            AdMarkStringList.push(_name);
            return true;
        } else{
            return false;
        }
    }
    
    function getAd(bytes4 adHash) external view returns (AdData memory, uint256, uint256[] memory, string[] memory) {
        AdData memory addata = AdMap[adHash];
        uint256 bidAmount = bidderMap[adHash];
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

    function getBurnLogList(uint256 start, uint256 end) external view returns (BurnLog[] memory) {
        require(start <= end, "start <= end");
        uint256 count = end.sub(start).add(1);
        if(start >= burnLogList.length){
            count = 0;
        } else if(end >= burnLogList.length){
            end = burnLogList.length - 1;
            count = end.sub(start).add(1);
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
    
    function getKeywordsList(uint256 start, uint256 end) external view returns (string[] memory) {
        require(start <= end, "start <= end");
        uint256 count = end.sub(start).add(1);
        if(start >= keywordsSize){
            count = 0;
        } else if(end >= keywordsSize){
            end = keywordsSize - 1;
            count = end.sub(start).add(1);
        }
        string[] memory output = new string[](count);
        if(count > 0) {
            uint256 num = 0;
            string memory currentKeywords = _nextKeywords[keywordsHead];
            for (uint256 i = 0; i < keywordsSize; i++) {
                if(i >= start && i <= end) {
                    output[num] = currentKeywords;
                    num++;
                }
                if(i == end) {
                    break;
                }
                currentKeywords = _nextKeywords[currentKeywords];
            }    
        }
        return output;
    }

    function getKeywordsAdList(string memory _keywords, uint256 start, uint256 end) external view returns (bytes4[] memory) {
        require(start <= end, "start <= end");
        Keywords storage keywords = keywordsMap[_keywords];
        uint256 count = end.sub(start).add(1);
        if(start >= keywords.adList.length){
            count = 0;
        } else if(end >= keywords.adList.length){
            end = keywords.adList.length - 1;
            count = end.sub(start).add(1);
        }
        bytes4[] memory output = new bytes4[](count);
        uint256 num = 0;
        for(uint256 i = start; i < keywords.adList.length; i ++) {
            output[num] = keywords.adList[i];
            if(i == end) {
                break;
            }
            num++;
        }
        return output;
    }

    function getAdList(uint256 start, uint256 end) public view returns (bytes4[] memory) {
        require(start <= end, "start <= end");
        uint256 count = end.sub(start).add(1);
        if(start >= adHashList.length){
            count = 0;
        } else if(end >= adHashList.length){
            end = adHashList.length - 1;
            count = end.sub(start).add(1);
        }
        bytes4[] memory output = new bytes4[](count);
        uint256 num = 0;
        for(uint256 i = start; i < adHashList.length; i ++) {
            output[num] = adHashList[i];
            if(i == end) {
                break;
            }
            num++;
        }
        return output;
    }

    function getRndAdList(uint256 count) public view returns (bytes4[] memory) {
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

    function getBidderList(uint256 start, uint256 end) public view returns (bytes4[] memory) {
        require(start <= end, "start <= end");
        uint256 count = end.sub(start).add(1);
        if(start >= bidderSize){
            count = 0;
        } else if(end >= bidderSize){
            end = bidderSize - 1;
            count = end.sub(start).add(1);
        }
        bytes4[] memory output = new bytes4[](count);
        if(count > 0) {
            uint256 num = 0;
            bytes4 currentAdHash = _nextBidder[bidderHead];
            for (uint256 i = 0; i < bidderSize; i++) {
                if(i >= start && i <= end) {
                    output[num] = currentAdHash;
                    num++;
                }
                if(i == end) {
                    break;
                }
                currentAdHash = _nextBidder[currentAdHash];
            }    
        }
        return output;
    }

    function loadAd(uint256 start, uint256 end) external view returns (bytes4[] memory, bool) {
        require(start <= end, "start <= end");
        bool isBid = true;
        bytes4[] memory output = getBidderList(start, end);
        if(output.length == 0) {
            uint256 count = end.sub(start).add(1);
            output = getRndAdList(count);
            isBid = false;
        }
        return (output, isBid);
    }

    function myAdList(uint256 _type) external view returns (bytes4[] memory) {
        if(_type == 0) {
            return PlayerMap[msg.sender].adList;
        } else {
            return PlayerMap[msg.sender].adFinishList;
        }
    }

    function getPlayer() external view returns (Player memory, address[] memory, bytes4[] memory) {
        Player memory player = PlayerMap[msg.sender];
        address[] memory subordinates = player.subordinates;
        bytes4[] memory stockList = player.stockList;
        return (player, subordinates, stockList);
    }

    function Dashboard() external view returns (uint256[] memory) {
        uint256[] memory output = new uint256[](13);
        uint256 _balanceOfUSDT = balanceOfUSDT(address(this));
        Bonus memory bonus = bonusGame[bonusSession];
        Share memory share = shareGame[shareSession];
        uint256 balanceOfContract = _balances[address(this)];
        uint256 balanceOfLiquidity = totalSupply.sub(totalBurn).sub(balanceOfContract);
        output[0] = _balanceOfUSDT;
        output[1] = bonus.bonusPrizePool;
        output[2] = share.totalFunds;
        output[3] = tokenPrice;
        output[4] = totalSupply;
        output[5] = totalBurn;
        output[6] = balanceOfContract;
        output[7] = balanceOfLiquidity;
        output[8] = adHashList.length;
        output[9] = totalCompletedAd;
        output[10] = totalRevenue;
        output[11] = totalShare;
        output[12] = totalAllShareRevenue;
        return output;
    }

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