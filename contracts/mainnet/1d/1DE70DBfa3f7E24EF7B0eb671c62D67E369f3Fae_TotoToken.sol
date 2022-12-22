/**
 *Submitted for verification at BscScan.com on 2022-12-22
*/

// SPDX-License-Identifier: auTech;
pragma solidity ^0.8.7;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function power(uint256 a,uint p) internal pure returns (uint256) {
        uint res = 1;
        while(p != 0) {
            if(p & 1 == 1) {
                res = res * a;
            }
            p >>= 1;
            a = a * a;
        }
    return res;
}

}


interface IBEP20 {

    function decimals() external view returns (uint8);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

struct Permit {
    address owner;
    address spender;
    uint256 value;
    uint256 nonce;
    uint256 deadline;
}



interface IOZCoin is IBEP20 {

    function permitApprove(Permit memory permit, uint8 v, bytes32 r, bytes32 s) external;
}

interface IToto is IBEP20 {

    function dayProduction4Stake(uint dayNum) external returns (uint);

    function transferStakePool(address spender,uint amount) external;

}

contract OZCoinStake {
        
    using SafeMath for uint;

    struct Account {
        address accountAddress;
        uint256 accountSerialNumber;
        uint256 stakeAmount;
        uint256 beginStakeTimestamp;
        uint256 stakeExpirationTimestamp;
        uint256 stakeExpirationSettleCount;
        uint256 totoAmount;
    }


    uint public totalStake;

    address private contractOwner;

    uint lastSettleTime;

    uint initialTime;

    uint settleCycle = 3;

    //结算次数 
    uint public settleCount;

    //地址-序列号加入时结算次数
    mapping(address => mapping(uint => uint)) public  openAccountCount;

    //根据加入时次数分组
    mapping(uint => Account[]) public countAccounts;

    //地址下面账户序列号
    mapping(address => uint[]) public accountAddressSerialNumber;

    //每次结算时总质押数量
    mapping(uint => uint) public countTotalStakeAmount;

    //每次的质押量
    mapping(uint => uint) public countStakeAmount;

    //结算次数-ozcoin对toto收益比例
    mapping(uint => uint) public countYield;

    //对应次数-地址-序列号-地址下标
    mapping(uint => mapping(address => mapping(uint => uint))) addressIds;

    //地址-序列号-地址序列号数组下标
    mapping(address => mapping(uint => uint)) serialNumberIndex;

    //地址-质押序列号 递增
    mapping (address => uint) public accountSerialNumber;

    //天数-是否结算
    mapping (uint => bool) public ifDaySettle;

    address OZCAddress;

    address multiSignWallet;

    event AccountStakeExpirationTimestampChange(address accountAddress, uint serialNumber, uint beforeValue, uint afterValue);

    modifier onlyMultiSign() {
        require(msg.sender == multiSignWallet,"Forbidden");
        _;
    }

    function withdrawToken(address contractAddress,address targetAddress,uint amount) onlyMultiSign external {
        IBEP20(contractAddress).transfer(targetAddress,amount);
    }

    function getAllAccountByAddress(address accountAddress) public view returns (uint,uint) {
        uint accountNum = 0;
        uint totalStakeAmount = 0;
        for (uint i = 0 ; i < accountAddressSerialNumber[accountAddress].length ; i++) {
            uint serialNumber = accountAddressSerialNumber[accountAddress][i];
            uint openSettleCount = openAccountCount[accountAddress][serialNumber];
            uint index = addressIds[openSettleCount][accountAddress][serialNumber];
            totalStakeAmount = totalStakeAmount.add(countAccounts[openSettleCount][index].stakeAmount);
            accountNum = accountNum.add(1);
        }
        return (accountNum,totalStakeAmount);
    }

    function getAccountByAddress(address accountAddress,uint serialNumber) public view returns (Account memory) {
        uint openSettleCount = openAccountCount[accountAddress][serialNumber];
        uint index = addressIds[openSettleCount][accountAddress][serialNumber];
        require(index > 0,"Nonexistent");
        return countAccounts[openSettleCount][index];
    }

    function openAccount(address accountAddress,uint stakeAmount) private returns (bool) {
        uint serialNumber = accountSerialNumber[accountAddress].add(1);
        accountSerialNumber[accountAddress] = serialNumber;
        uint nowTimestamp = block.timestamp;
        uint firstSettleTimestamp = nowTimestamp + (1 days - (nowTimestamp % 1 days)) + 2 hours;
        uint expirationTimestamp = firstSettleTimestamp + ((settleCycle-1) * 1 days);
        if (!ifDaySettle[nowTimestamp/1 days]) { //如果今天尚未结算 参与今日结算 过期时间-1天
            expirationTimestamp = expirationTimestamp - 1 days;
        }
        Account memory newAccount = Account(accountAddress,serialNumber,stakeAmount,nowTimestamp,expirationTimestamp,settleCount+settleCycle,0);
        if (countAccounts[settleCount].length==0) {
            countAccounts[settleCount].push();//0被占位
        }
        countAccounts[settleCount].push(newAccount);
        accountAddressSerialNumber[accountAddress].push(serialNumber);
        serialNumberIndex[accountAddress][serialNumber] = accountAddressSerialNumber[accountAddress].length - 1;
        addressIds[settleCount][accountAddress][serialNumber] = countAccounts[settleCount].length - 1;
        openAccountCount[accountAddress][serialNumber] = settleCount;
        totalStake = totalStake.add(stakeAmount);
        countStakeAmount[settleCount] = countStakeAmount[settleCount].add(stakeAmount);
        return true;
    }

    function removeStakeAccount(uint count,uint index) private {
        countAccounts[count][index] = countAccounts[count][countAccounts[count].length - 1];
        countAccounts[count].pop();
        if (countAccounts[count].length==1) {
            delete countAccounts[count];
        }
    }

    function removeStakeAccountSerialNumber(address accountAddress,uint serialNumber) private {
        uint index = serialNumberIndex[accountAddress][serialNumber];
        accountAddressSerialNumber[accountAddress][index] = accountAddressSerialNumber[accountAddress][accountAddressSerialNumber[accountAddress].length - 1];
        accountAddressSerialNumber[accountAddress].pop();
    }

    function removeStakeAccountByAddress(address accountAddress,uint serialNumber) private {
        uint openSettleCount = openAccountCount[accountAddress][serialNumber];
        uint index = addressIds[openSettleCount][accountAddress][serialNumber];
        delete countAccounts[openSettleCount][index]; //删除账户
        delete openAccountCount[accountAddress][serialNumber]; //删除账户对应的次数
        delete addressIds[openSettleCount][accountAddress][serialNumber]; //删除账户对应下标
        removeStakeAccountSerialNumber(accountAddress,serialNumber);//删除账户对应序列号
        removeStakeAccount(openSettleCount,index);
    }

    function updateStakeAccountByAddress(Account memory updateAccount) private {
        uint openSettleCount = openAccountCount[updateAccount.accountAddress][updateAccount.accountSerialNumber];
        uint index = addressIds[openSettleCount][updateAccount.accountAddress][updateAccount.accountSerialNumber];
        delete countAccounts[openSettleCount][index]; //删除账户
        countAccounts[openSettleCount][index] = updateAccount;
    }

    function simulationRedemption() external  view returns (uint,uint) {
        address accountAddress = msg.sender;
        uint accountNum = 0;
        uint sumToto = 0;
        for (uint i = 0 ; i < accountAddressSerialNumber[accountAddress].length ; i++) {
            accountNum = accountNum.add(1);
            uint serialNumber = accountAddressSerialNumber[accountAddress][i];
            uint openSettleCount = openAccountCount[accountAddress][serialNumber];
            Account memory account = getAccountByAddress(accountAddress,serialNumber);
            if(account.stakeExpirationSettleCount > settleCount) {
                continue;
            }
            //周期为开户后30次  ex:0次进入 结算1-30 ; 31次进入 结算32-61次
            uint addCount = 0;
            for (uint si = openSettleCount + 1 ; si <= account.stakeExpirationSettleCount ; si++) {
                uint yield = countYield[si];
                account.totoAmount = account.totoAmount.add(yield.mul(account.stakeAmount));//质押数量计算每次收益
                addCount = addCount.add(1);
            }
            sumToto = sumToto.add(account.totoAmount);
        }

        return (accountNum,sumToto);
    }

    function redemption() external returns (bool) {
        address accountAddress = msg.sender;
        for (uint i = 0 ; i < accountAddressSerialNumber[accountAddress].length ; i++) {
            uint serialNumber = accountAddressSerialNumber[accountAddress][i];
            uint openSettleCount = openAccountCount[accountAddress][serialNumber];
            Account memory account = getAccountByAddress(accountAddress,serialNumber);
            if(account.stakeExpirationSettleCount > settleCount) {
                continue;
            }
            for (uint si = openSettleCount + 1 ; si <= account.stakeExpirationSettleCount ; si++) {
                uint yield = countYield[si];
                account.totoAmount = account.totoAmount.add(yield.mul(account.stakeAmount));//质押数量计算每次收益
            }
            //返还ozcoin  派发toto
            IOZCoin(OZCAddress).transfer(accountAddress,account.stakeAmount);
            IToto(contractOwner).transferStakePool(accountAddress,account.totoAmount);
            removeStakeAccountByAddress(accountAddress,serialNumber);
        }
        return true;
    }


    function changeAccountStakeExpirationTimestamp(address accountAddress) onlyMultiSign external returns (bool) {
        for (uint i = 0 ; i < accountAddressSerialNumber[accountAddress].length ; i++) {
            uint serialNumber = accountAddressSerialNumber[accountAddress][i];
            Account memory account = getAccountByAddress(accountAddress,serialNumber);
            if(account.stakeExpirationSettleCount <= settleCount) {
                continue;
            }
            uint openSettleCount = openAccountCount[accountAddress][serialNumber];
            uint before = account.stakeExpirationTimestamp;
            uint timestamp = block.timestamp;
            account.stakeExpirationTimestamp = timestamp;
            account.stakeExpirationSettleCount = settleCount;
            updateStakeAccountByAddress(account);
            countStakeAmount[openSettleCount] = countStakeAmount[openSettleCount].sub(account.stakeAmount);
            totalStake = totalStake.sub(account.stakeAmount);
            emit AccountStakeExpirationTimestampChange(accountAddress, serialNumber, before, timestamp);

        }
        return true;
    }

    function stake(uint amount,uint nonce,uint deadline,uint8 v, bytes32 r, bytes32 s) external returns (bool success) {
        address from = msg.sender;
        address to = address(this);
        Permit memory permit = Permit(from,to,amount,nonce,deadline);
        IOZCoin(OZCAddress).permitApprove(permit,v,r,s);
        IOZCoin(OZCAddress).transferFrom(from,to,amount);
        openAccount(from,amount);
        return true;
    }

    function settle(uint timestamp) external {
        address _sender = msg.sender;
        require(_sender == contractOwner,"Not my owner");
        require( timestamp < block.timestamp,'exception call');
        require( timestamp > initialTime,'exception call');
        require( timestamp - lastSettleTime >= 1 days,'In the cooling');
        require(!ifDaySettle[timestamp/1 days],'Repeat settle');
        uint totoProduction = IToto(_sender).dayProduction4Stake(timestamp/1 days);
        settleCount = settleCount.add(1);
        if (settleCount>settleCycle) {//剔除掉周期之外保存的总量
            uint expirtionCount = settleCount - settleCycle - 1; //例如:第四次结算 总量为1 2 3质押量 去除0次
            totalStake =  totalStake.sub(countStakeAmount[expirtionCount]);
        }
        ifDaySettle[timestamp/1 days] = true;
        uint ozcoinYield = 0;
        countTotalStakeAmount[settleCount] = totalStake;
        if (totalStake>0) {
            ozcoinYield = totoProduction.div(totalStake);
        }
        countYield[settleCount] = ozcoinYield;
        lastSettleTime = timestamp;
    }


    constructor (address ozcContractAddress,address multiSignWalletAddress,uint initialTimeStamp) {
        contractOwner = msg.sender;
        initialTime = initialTimeStamp;
        OZCAddress = ozcContractAddress;
        multiSignWallet = multiSignWalletAddress;
    }
    
}


struct TransferInfo {
    address spender;
    uint256 amount;
}

contract Pool {

    uint public poolId;

    address private contractOwner;

    constructor (uint id) {
        contractOwner = msg.sender;
        poolId = id;
    }

    function withdraw(address contractAddress,address spender,uint amount) external {
        address _sender = msg.sender;
        require(_sender == contractOwner,"Not my owner");
        IBEP20(contractAddress).transfer(spender,amount);
    }

}

contract TotoToken {

    OZCoinStake public ozcoinStake;

    address private contractOwner;

    using SafeMath for uint;

    uint public initialTime;

    uint public lastProduceTime;

    uint public lastSettleTime;

    uint256 private _totalSupply;

    string public constant name = "TOTO";

    string public constant symbol = "TOTO";

    uint8 public constant decimals = 18;

    uint public lastProduction;

    mapping(uint => uint) public dayProduction4Stake;

    uint public nextProduction;

    uint public productionLimit;

    bool public allowExchange = true;

    address private multiSignWallet;

    mapping(uint => Pool) public pools;

    mapping(uint => address) public poolAutoAddress;

    mapping(address => uint) private supportedContractAddress;

    mapping(address => uint) private balances;

    mapping(uint => uint) public daySold;

    mapping(uint => uint) private poolDistributeProportion;

    mapping (address => mapping (address => uint)) public _allowance;

    event ContractOwnerChange(address beforeAddress, address afterAddress);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

    event DecreaseApprove(address indexed _owner, address indexed _spender, uint _value);

    event NextProductionChange(uint beforeValue, uint afterValue);

    event PoolAutoAddressChange(address beforeValue, address afterValue);

    event ProductionLimitChange(uint beforeValue, uint afterValue);

    event PoolDistributeProportionChange(uint poolId, uint proportion);

    enum PoolId {
        Pass,
        OzGroupPool,
        OzSupporterPool,
        OzFoundationPool,
        StakePool,
        OzbetPool,
        OzbetVipPool
    }

    modifier onlyMultiSign() {
        require(msg.sender == multiSignWallet,"Forbidden");
        _;
    }

    function balanceOf(address _owner) external view returns (uint balance) {
        return balances[_owner];
    }

    function doTransfer(address _from, address _to, uint _value) private {
        uint fromBalance = balances[_from];
        require(fromBalance >= _value, "Insufficient funds");
        balances[_from] = fromBalance.sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function doApprove(address owner,address _spender,uint _value) private {
        _allowance[owner][_spender] = _value;
        emit Approval(owner,_spender,_value);
    }

    function transfer(address _to, uint _value) external returns (bool success) {
        address _owner = msg.sender;
        doTransfer(_owner,_to,_value);
        return true;
    }

    function approve(address _spender, uint _value) external returns (bool success){
        address _sender = msg.sender;
        doApprove(_sender,_spender,_value);
        return true;
    }

    function decreaseApprove(address _spender, uint _value) external returns (bool success){
        address _sender = msg.sender;
        uint remaining = _allowance[_sender][_spender];
        remaining = remaining.sub(_value);
        _allowance[_sender][_spender] = remaining;
        emit DecreaseApprove(_sender,_spender,_value);
        return true;
    }

    function allowance(address _owner, address _spender) external view returns (uint remaining){
        return _allowance[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool success){
        address _sender = msg.sender;
        uint remaining = _allowance[_from][_sender];
        require(_value <= remaining,"Insufficient remaining allowance");
        remaining = remaining.sub(_value);
        _allowance[_from][_sender] = remaining;
        doTransfer(_from, _to, _value);
        return true;
    }

    function withdrawToken(address contractAddress,address targetAddress,uint amount) onlyMultiSign external returns(bool) {
        IBEP20(contractAddress).transfer(targetAddress,amount);
        return true;
    }

    function totalSupply() external view returns (uint){
        return _totalSupply;
    }

    function mint(address spender,uint _value) onlyMultiSign external returns (bool success) {
        return _mint(_value,spender);
    }

    function _mint(uint _value,address spender) private returns (bool success) {
        address _from = 0x0000000000000000000000000000000000000000;
        balances[spender] = balances[spender].add(_value);
        _totalSupply = _totalSupply.add(_value);
        emit Transfer(_from, spender, _value);
        return true;
    }

    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    function setProductionLimit(uint productionLimitV) onlyMultiSign public returns(bool) {
        uint before = productionLimit;
        productionLimit = productionLimitV;
        emit ProductionLimitChange(before,productionLimitV);
        return true;
    }

    function setPoolDistributeProportion(uint ozGroupProportion, uint ozSupportProportion, uint ozFundProportion, uint stakeProportion, uint ozbetProportion, uint ozbetVipProportion) onlyMultiSign public returns(bool) {
        require(ozGroupProportion + ozSupportProportion + ozFundProportion + stakeProportion + ozbetProportion + ozbetVipProportion == 100,"Sum must to be 100");
        poolDistributeProportion[1] = ozGroupProportion;
        emit PoolDistributeProportionChange(1,ozGroupProportion);
        poolDistributeProportion[2] = ozSupportProportion;
        emit PoolDistributeProportionChange(2,ozSupportProportion);
        poolDistributeProportion[3] = ozFundProportion;
        emit PoolDistributeProportionChange(3,ozFundProportion);
        poolDistributeProportion[4] = stakeProportion;
        emit PoolDistributeProportionChange(4,stakeProportion);
        poolDistributeProportion[5] = ozbetProportion;
        emit PoolDistributeProportionChange(5,ozbetProportion);
        poolDistributeProportion[6] = ozbetVipProportion;
        emit PoolDistributeProportionChange(6,ozbetVipProportion);
        return true;
    }

    function setPoolDistributeProportionPrivate(uint ozGroupProportion, uint ozSupportProportion, uint ozFundProportion, uint stakeProportion, uint ozbetProportion, uint ozbetVipProportion) private {
        require(ozGroupProportion + ozSupportProportion + ozFundProportion + stakeProportion + ozbetProportion + ozbetVipProportion == 100,"Sum must to be 100");
        poolDistributeProportion[1] = ozGroupProportion;
        poolDistributeProportion[2] = ozSupportProportion;
        poolDistributeProportion[3] = ozFundProportion;
        poolDistributeProportion[4] = stakeProportion;
        poolDistributeProportion[5] = ozbetProportion;
        poolDistributeProportion[6] = ozbetVipProportion;
    }

    function setContractOwner(address newOwner) onlyMultiSign external returns (bool) {
        address beforeAddress = contractOwner;
        contractOwner = newOwner;
        emit ContractOwnerChange(beforeAddress,newOwner);
        return true;
    }

    function produce(uint timestamp) external returns (bool) {
        require( msg.sender == contractOwner,"Not my owner");
        require( timestamp < block.timestamp,"Exception call : can not  after the block");
        require( timestamp > initialTime,"Exception call : can not be before the initial");
        require( timestamp - lastProduceTime >= 1 days,"In the cooling");
        require(( _totalSupply + nextProduction <= productionLimit) || productionLimit == 0 ,"Production Limit");
        uint onePercent = nextProduction.div(100);
        _mint(nextProduction,address(this));
        lastProduction = nextProduction;
        address ozGroupPoolAddress = address(pools[uint(PoolId.OzGroupPool)]);
        uint ozGroupPoolAmount = onePercent.mul(poolDistributeProportion[uint(PoolId.OzGroupPool)]);
        doTransfer(address(this),ozGroupPoolAddress,ozGroupPoolAmount);

        address ozSupporterPoolAddress = address(pools[uint(PoolId.OzSupporterPool)]);
        uint ozSupporterPoolAmount = onePercent.mul(poolDistributeProportion[uint(PoolId.OzSupporterPool)]);
        doTransfer(address(this),ozSupporterPoolAddress,ozSupporterPoolAmount);

        address ozFoundationPoolAddress = address(pools[uint(PoolId.OzFoundationPool)]);
        uint ozFoundationPoolAmount = onePercent.mul(poolDistributeProportion[uint(PoolId.OzFoundationPool)]);
        doTransfer(address(this),ozFoundationPoolAddress,ozFoundationPoolAmount);

        address stakePoolAddress = address(pools[uint(PoolId.StakePool)]);
        uint stakePoolAmount = onePercent.mul(poolDistributeProportion[uint(PoolId.StakePool)]);
        dayProduction4Stake[timestamp/1 days] = stakePoolAmount;
        doTransfer(address(this),stakePoolAddress,stakePoolAmount);

        address ozbetPoolAddress = address(pools[uint(PoolId.OzbetPool)]);
        uint ozbetPoolAmount = onePercent.mul(poolDistributeProportion[uint(PoolId.OzbetPool)]);
        doTransfer(address(this),ozbetPoolAddress,ozbetPoolAmount);

        address ozbetVipPoolAddress = address(pools[uint(PoolId.OzbetVipPool)]);
        uint ozbetVipPoolAmont = onePercent.mul(poolDistributeProportion[uint(PoolId.OzbetVipPool)]);
        doTransfer(address(this),ozbetVipPoolAddress,ozbetVipPoolAmont);
        uint minProduction = 1000000;
        if(nextProduction>minProduction.mul(decimals)) {
            nextProduction = onePercent.mul(99);
            emit NextProductionChange(lastProduction,nextProduction);
        }
        lastProduceTime = timestamp;
        return true;
    }

    function getDays() public view returns (uint) {
        uint currentTime = block.timestamp;
        uint difference = currentTime.sub(initialTime);
        uint dayNum = difference/1 days;
        if (difference % 1 days > 0) {
            dayNum += 1;
        }
        return dayNum;
    }

    function switchExchange() external onlyMultiSign returns(bool)  {
        if (allowExchange) {
            allowExchange = false;
        } else {
            allowExchange = true;
        }
        return true;
    }

    //使用稳定币兑换TOTO
    function exchange(address spender,address contractAddress,uint amount) external {
        require(supportedContractAddress[contractAddress] == 1,"Don't support");
        require(allowExchange,"Not allow");
        uint dayNum = getDays();
        uint todaySold = daySold[dayNum];
        address owner = msg.sender;
        uint allowanceValue = IBEP20(contractAddress).allowance(owner,address(this));
        require(allowanceValue >= amount,"Insufficient allowance");
        bool res = IBEP20(contractAddress).transferFrom(owner,address(this),amount);
        require(res,"Transfer failed");
        uint8 erc20decimals = IBEP20(contractAddress).decimals();
        //proportion toto对应erc20比例
        //根据精度差距计算兑换数量
        uint totoAmount = amount;
        uint ten = 10;
        if (erc20decimals<decimals) {
            uint8 decimalsDifference = decimals - erc20decimals;
            uint proportion = ten.power(decimalsDifference);
            totoAmount = amount.mul(proportion);
        }
        if (erc20decimals>decimals) {
            uint8 decimalsDifference = erc20decimals - decimals;
            uint proportion = ten.power(decimalsDifference);
            totoAmount = amount.div(proportion);
        }
        totoAmount = totoAmount.mul(10);
        uint sellLimit = 10000;
        require( todaySold + totoAmount <= sellLimit.mul(ten.power(decimals)),"Inadequate");
        _mint(totoAmount,spender);
        daySold[dayNum] = todaySold + totoAmount;
    }


    function distribute(uint poolId,TransferInfo[] memory transferInfos) onlyMultiSign external returns(bool) {
        Pool pool = pools[poolId];
        for(uint i=0;i<transferInfos.length;i++) {
            pool.withdraw(address(this),transferInfos[i].spender,transferInfos[i].amount);
        }
        return true;
    }

    function setNextProduction(uint productionAmount) external onlyMultiSign returns(bool) {
        uint before = nextProduction;
        nextProduction = productionAmount;
        emit NextProductionChange(before,nextProduction);
        return true;
    }

    function configurePoolAutoAddress(uint poolId,address autoAirDropAddress) onlyMultiSign external returns(bool) {
        address before = poolAutoAddress[poolId];
        poolAutoAddress[poolId] = autoAirDropAddress;
        emit PoolAutoAddressChange(before,autoAirDropAddress);
        return true;
    }

    function autoAirDrop(uint poolId,TransferInfo[] memory transferInfos) external {
        require(msg.sender == poolAutoAddress[poolId],"Forbidden");
        Pool pool = pools[poolId];
        for(uint i=0;i<transferInfos.length;i++) {
            pool.withdraw(address(this),transferInfos[i].spender,transferInfos[i].amount);
        }
    }


    //划转质押toto矿池
    function transferStakePool(address spender,uint amount) external {
        require(msg.sender==address(ozcoinStake),"Forbidden");
        pools[uint(PoolId.StakePool)].withdraw(address(this),spender,amount);
    }

    function settleStake(uint timestamp) external {
        address _sender = msg.sender;
        require(_sender == contractOwner,"Not my owner");
        ozcoinStake.settle(timestamp);
    }

    function initPool(uint poolId) private {
        Pool newPool = new Pool(poolId);
        pools[poolId] = newPool;
    }

    constructor (uint initialTimestamp,address multiSignWalletAddress,address OZCoinAddress) {
        contractOwner = msg.sender;
        initPool(uint(PoolId.OzGroupPool));
        initPool(uint(PoolId.OzSupporterPool));
        initPool(uint(PoolId.OzFoundationPool));
        initPool(uint(PoolId.StakePool));
        initPool(uint(PoolId.OzbetPool));
        initPool(uint(PoolId.OzbetVipPool));
        setPoolDistributeProportionPrivate(20,15,30,5,20,10);
        multiSignWallet = multiSignWalletAddress;
        address OZCAddress = OZCoinAddress;//address(0xb6571e3DcBf05b34d8718D9be8b57CbF700C15A0);
        address BUSDAddress = address(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
        ozcoinStake = new OZCoinStake(OZCAddress,multiSignWalletAddress,initialTimestamp);
        supportedContractAddress[OZCAddress] = 1;
        supportedContractAddress[BUSDAddress] = 1;
        uint ten = 10;
        uint baseProduction = 10000000;
        nextProduction = baseProduction.mul(ten.power(decimals));
        initialTime = initialTimestamp;
    }

}