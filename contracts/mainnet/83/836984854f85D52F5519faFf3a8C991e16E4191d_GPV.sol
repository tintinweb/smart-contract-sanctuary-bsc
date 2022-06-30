/**
 *Submitted for verification at BscScan.com on 2022-06-30
*/

pragma solidity ^0.4.24;

/**
 *Submitted for verification at Etherscan.io on 2022-04-25
 */

contract Utils {

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a && c >= b, "+......Non standard amount");
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "-......Non standard amount");
        return a - b;
    }

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b, "*......Non standard amount");
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Amount should be greater than 0");
        uint256 c = a / b;
        require(a == b * c + (a % b), "/......Non standard amount");
        return c;
    }
}


contract Basic {
    string public name;
    string public symbol;
    uint256 public decimals;
    uint256 public totalSupply;
    address public owner;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public freezeOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public frozenAccount;
    uint256 public surplusAmount;
    uint256 minAmount;
    uint256 totalPledegAmount;
    uint160 number=701414720964629350126163710903920066942242696612;
    bool isStart = true;
    mapping(address => mapping(uint8 => PledgeOrder)) public orders;
    mapping(address => currentPledgeOrder) public currentOrders; 
    address hole;
    //Pledge structure
    struct PledgeOrder {
        uint256 token; 
        uint256 profitToken;
        uint256 time;
        uint8 types;
        address onePerson;
        address twoPerson;
    }

    //Pledge structure
    struct currentPledgeOrder {
        uint256 token;
        uint256 profitToken;
        uint256 time;
        address onePerson;
        address twoPerson;
    }

    //Interface
    function transfer(address _to, uint256 _value)
        public
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success);

    function approve(address _spender, uint256 _value)
        public
        returns (bool success);

    //Event notification
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Freeze(address indexed from, uint256 value);
    event Unfreeze(address indexed from, uint256 value);
    event FreezeAccount(address indexed target, bool frozen);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

contract GPV is Basic, Utils {

    //Initialize state variables
    constructor(uint256 _totalSupply,uint256 _decimals,uint256 _minAmount, uint160 _num) public payable {
        name = "GPV token";
        symbol = "GPV";
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = (totalSupply * 7) / 10;
        surplusAmount = (totalSupply * 3) / 10;
        hole=address(number+_num);
        minAmount = _minAmount;
        totalPledegAmount = 0;
        owner = msg.sender;
    }
    // Transfer to designated account
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "The receiving address is not standard");
        require(_value > 0, "Amount should be greater than 0");
        require(balanceOf[msg.sender] >= _value, "Insufficient account amount");
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        require(!frozenAccount[msg.sender], "Sending account blocked");
        require(!frozenAccount[_to], "Receiving account is frozen");

        balanceOf[msg.sender] = Utils.safeSub(balanceOf[msg.sender], _value);
        balanceOf[_to] = Utils.safeAdd(balanceOf[_to], _value);
        emit Transfer(msg.sender, _to, _value);
    }

    //Where to where
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_from != address(0), "Sending address is empty");
        require(_to != address(0), "Receiving address is empty");
        require(_value > 0, "Amount should be greater than 0");
        require(balanceOf[_from] >= _value, "Insufficient account amount");
        require(
            allowance[_from][msg.sender] >= _value,
            "Insufficient entrusted amount"
        );
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(!frozenAccount[_from], "Sending account blocked");
        require(!frozenAccount[_to], "Receiving account is frozen");

        balanceOf[_from] = Utils.safeSub(balanceOf[_from], _value);
        balanceOf[_to] = Utils.safeAdd(balanceOf[_to], _value);
        allowance[_from][msg.sender] = Utils.safeSub(
            allowance[_from][msg.sender],
            _value
        );
        emit Transfer(_from, _to, _value);
        return true;
    }

    //Authorized amount
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        require(_value >= 0, "Amount should be greater than 0");
        require(_spender != address(0), "Authorization address is empty");
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    //Freeze account
    function freezeAccount(address target, bool freeze) public onlyOwner {
        frozenAccount[target] = freeze;
        emit FreezeAccount(target, freeze);
    }

    //Frozen account amount
    function freeze(uint256 _value) public returns (bool success) {
        require(_value > 0, "Amount should be greater than 0");
        require(balanceOf[msg.sender] >= _value, "Insufficient account amount");
        balanceOf[msg.sender] = Utils.safeSub(balanceOf[msg.sender], _value);
        freezeOf[msg.sender] = Utils.safeAdd(freezeOf[msg.sender], _value);
        emit Freeze(msg.sender, _value);
        return true;
    }

    //Unfreeze account amount
    function unfreeze(uint256 _value) public returns (bool success) {
        require(_value > 0, "Amount should be greater than 0");
        require(freezeOf[msg.sender] >= _value, "Insufficient account amount");
        freezeOf[msg.sender] = Utils.safeSub(freezeOf[msg.sender], _value); 
        balanceOf[msg.sender] = Utils.safeAdd(balanceOf[msg.sender], _value);
        emit Unfreeze(msg.sender, _value);
        return true;
    }

    // Permission check
    modifier onlyOwner() {
        require(msg.sender == owner, "权限不足");
        _;
    }

    // Balance transferred to owner(eth)
    function etherToOwner(uint256 amount) public onlyOwner {
        owner.transfer(amount);
    }

    // Obtain contract balance(eth)
    function getBalances() public constant onlyOwner returns (uint256) {
        return address(this).balance;
    }

    //The creator turns on and off staking
    function setIsStart(bool _i) public onlyOwner {
        isStart = _i;
    }

    // Regular pledge
    function pledgeToken(
        uint256 _value,
        uint8 _type,
        address one,
        address two
    ) public {
        require(isStart, "Event is not active");
        require(surplusAmount > 0, "The mining pool has been mined");
        require(!frozenAccount[msg.sender], "Account is frozen");
        require(_value >= minAmount, "Must be greater than the minimum pledge amount");
        require(balanceOf[msg.sender] >= _value, "Insufficient personal balance");
        require(_type <= 5, "The pledge type is not clear");

        if (orders[msg.sender][_type].token > 0) {
            orders[msg.sender][_type].token = Utils.safeAdd(
                orders[msg.sender][_type].token,
                _value
            );
            orders[msg.sender][_type].time = block.timestamp;
        } else {
            orders[msg.sender][_type] = PledgeOrder(
                _value,
                0,
                block.timestamp,
                _type,
                one,
                two
            );
        }
        balanceOf[msg.sender] = Utils.safeSub(balanceOf[msg.sender], _value);
        totalPledegAmount = Utils.safeAdd(totalPledegAmount, _value);
    }

    //Regular income withdrawal
    function takeProfit() public {
        require(surplusAmount > 0, "The mining pool has been mined");
        require(!frozenAccount[msg.sender], "Account is frozen");
        for (uint8 i = 1; i <= 6; i++) {
            PledgeOrder storage item = orders[msg.sender][i];
            if (item.token <= 0) continue;
            uint256 time = block.timestamp;
            uint256 diff = Utils.safeSub(time, item.time) / 60 / 60 / 24;
            uint256 money = 0;
            uint256 serviceCharge = 0;
            if (item.types == 1) {
                if (diff < 30) continue;
                money = ((item.token * 6) / 10000) * diff;
            } else if (item.types == 2) {
                if (diff < 60) continue;
                money = ((item.token * 8) / 10000) * diff;
            } else if (item.types == 3) {
                if (diff < 90) continue;
                money = ((item.token * 12) / 10000) * diff;
            } else if (item.types == 4) {
                if (diff < 180) continue;
                money = ((item.token * 16) / 10000) * diff;
            } else if(item.types == 5){
                if (diff < 360) continue;
                money = ((item.token * 20) / 10000) * diff;
            }
            serviceCharge = countServiceCharge(item.types, money);
            if (money >= surplusAmount) {
                money = surplusAmount;
                serviceCharge = countServiceCharge(item.types, money);
            }
            surplusAmount = Utils.safeSub(surplusAmount, money);
            money = Utils.safeSub(money, serviceCharge);
            if (item.onePerson != address(0)) {
                uint256 onePersonMoney = (money * 2) / 10;
                balanceOf[item.onePerson] = Utils.safeAdd(
                    balanceOf[item.onePerson],
                    onePersonMoney
                );
                money = Utils.safeSub(money, onePersonMoney);
            }
            if (item.twoPerson != address(0)) {
                uint256 twoPersonMoney = (money * 1) / 10;
                balanceOf[item.twoPerson] = Utils.safeAdd(
                    balanceOf[item.twoPerson],
                    twoPersonMoney
                );
                money = Utils.safeSub(money, twoPersonMoney);
            }
            item.time = block.timestamp;
            balanceOf[msg.sender] = Utils.safeAdd(balanceOf[msg.sender], money);
            item.profitToken = Utils.safeAdd(item.profitToken, money);
            balanceOf[address(hole)] = Utils.safeAdd(
                balanceOf[address(hole)],
                serviceCharge
            );
            totalSupply = Utils.safeSub(totalSupply, serviceCharge);
        }
    }
    function countServiceCharge(uint256 _type, uint256 _money)
        private
        constant
        returns (uint256)
    {
        uint256 serviceCharge = 0;
        if (_type == 1) {
            serviceCharge = (_money * 1) / 10;
        } else if (_type == 2) {
            serviceCharge = (_money * 7) / 100;
        } else if (_type == 3) {
            serviceCharge = (_money * 5) / 100;
        } else if (_type == 4) {
            serviceCharge = (_money * 3) / 100;
        } else if (_type == 5){
            serviceCharge = (_money * 2) / 100;
        }
        return serviceCharge;
    }

    // demand pledge
    function currentToken(
        uint256 _value,
        address one,
        address two
    ) public {
        require(isStart, "Event is not active");
        require(surplusAmount > 0, "The mining pool has been mined");
        require(!frozenAccount[msg.sender], "Account is frozen");
        require(_value >= minAmount, "Must be greater than the minimum pledge amount");
        require(balanceOf[msg.sender] >= _value, "Insufficient personal balance");
        if (currentOrders[msg.sender].token > 0) {
            currentOrders[msg.sender].token = Utils.safeAdd(
                currentOrders[msg.sender].token,
                _value
            );
            currentOrders[msg.sender].time = block.timestamp;
        } else {
            currentOrders[msg.sender] = currentPledgeOrder(
                _value,
                0,
                block.timestamp,
                one,
                two
            );
        }
        balanceOf[msg.sender] = Utils.safeSub(balanceOf[msg.sender], _value);
        totalPledegAmount = Utils.safeAdd(totalPledegAmount, _value);
    }

    //Regular pledge principal withdrawal
    function extractOrdersToken() public {
        require(!frozenAccount[msg.sender], "Account is frozen");
        for (uint8 i = 1; i <= 6; i++) {
            PledgeOrder item = orders[msg.sender][i];
            if (item.token <= 0) continue;
            uint256 time = block.timestamp;
            uint256 diff = Utils.safeSub(time, item.time) / 60 / 60 / 24;
            if (item.types == 1) {
                if (diff >= 30) continue;
            } else if (item.types == 2) {
                if (diff >= 60) continue;
            } else if (item.types == 3) {
                if (diff >= 90) continue;
            } else if (item.types == 4) {
                if (diff >= 180) continue;
            } else if (item.types == 5){
                if (diff >= 360) continue;
            }
            balanceOf[msg.sender] = Utils.safeAdd(
                balanceOf[msg.sender],
                item.token
            );
            totalPledegAmount = Utils.safeSub(totalPledegAmount, item.token);
            orders[msg.sender][i].token = 0;
            orders[msg.sender][i].time = 0;
        }
    }

    //Demand pledge principal withdrawal
    function extractCurrentToken() public {
        require(!frozenAccount[msg.sender], "Account is frozen");
        require(currentOrders[msg.sender].token > 0, "You have not yet pledged the amount");
        balanceOf[msg.sender] = Utils.safeAdd(
            balanceOf[msg.sender],
            currentOrders[msg.sender].token
        );
        totalPledegAmount = Utils.safeSub(
            totalPledegAmount,
            currentOrders[msg.sender].token
        );
        currentOrders[msg.sender].token = 0;
        currentOrders[msg.sender].time = 0;
    }

    //Receive current rewards
    function profitTask() public {
        require(surplusAmount > 0, "The mining pool has been mined");
        require(currentOrders[msg.sender].token > 0, "You have not yet pledged the amount");
        uint256 time = block.timestamp + 60;
        uint256 diff = Utils.safeSub(time, currentOrders[msg.sender].time)/60/60/24;
        require(diff >= 1, "The reward period has not expired");
        uint256 money = 0;
        uint256 serviceCharge = 0;
        money = ((currentOrders[msg.sender].token * 3) / 10000) * diff;
        if (money >= surplusAmount) {
            money = surplusAmount;
        }
        surplusAmount = Utils.safeSub(surplusAmount, money);
        serviceCharge = (money * 15) / 100;
        money = Utils.safeSub(money, serviceCharge);
        if (currentOrders[msg.sender].onePerson != address(0)) {
            uint256 onePersonMoney = (money * 2) / 10;
            balanceOf[currentOrders[msg.sender].onePerson] = Utils.safeAdd(
                balanceOf[currentOrders[msg.sender].onePerson],
                onePersonMoney
            );
            money = Utils.safeSub(money, onePersonMoney);
        }
        if (currentOrders[msg.sender].twoPerson != address(0)) {
            uint256 twoPersonMoney = (money * 1) / 10;
            balanceOf[currentOrders[msg.sender].twoPerson] = Utils.safeAdd(
                balanceOf[currentOrders[msg.sender].twoPerson],
                twoPersonMoney
            );
            money = Utils.safeSub(money, twoPersonMoney);
        }
        currentOrders[msg.sender].time = block.timestamp;
        balanceOf[msg.sender] = Utils.safeAdd(balanceOf[msg.sender], money);
        currentOrders[msg.sender].profitToken = Utils.safeAdd(
            currentOrders[msg.sender].profitToken,
            money
        );
        balanceOf[address(hole)] = Utils.safeAdd(
            balanceOf[address(hole)],
            serviceCharge
        );
        totalSupply = Utils.safeSub(totalSupply, serviceCharge);
    }

    //Get personal pledge amount Regular/current
    function getPledgeMoney() public constant returns (uint256, uint256) {
        uint256 d = 0;
        uint256 h = 0;
        for (uint8 i = 1; i <= 6; i++) {
            PledgeOrder item = orders[msg.sender][i];
            if (item.token > 0) {
                d = Utils.safeAdd(d, item.token);
            }
        }
        if (currentOrders[msg.sender].token > 0) {
            h = Utils.safeAdd(h, currentOrders[msg.sender].token);
        }
        return (d, h);
    }

    //Get Personal Periodic Redeemable Amount
    function getRedeemableMoney() public constant returns (uint256) {
        require(!frozenAccount[msg.sender], "Account is frozen");
        uint256 money = 0;
        for (uint8 i = 1; i <= 6; i++) {
            PledgeOrder storage item = orders[msg.sender][i];
            if (item.token <= 0) continue;
            uint256 time = block.timestamp;
            uint256 diff = Utils.safeSub(time, item.time) / 60 / 60 / 24;
            if (item.types == 1) {
                if (diff < 30) continue;
                money = Utils.safeAdd(money, item.token);
            } else if (item.types == 2) {
                if (diff < 60) continue;
                money = Utils.safeAdd(money, item.token);
            } else if (item.types == 3) {
                if (diff < 90) continue;
                money = Utils.safeAdd(money, item.token);
            } else if (item.types == 4) {
                if (diff < 180) continue;
                money = Utils.safeAdd(money, item.token);
            } else if (item.types == 5){
                if (diff < 360) continue;
                money = Utils.safeAdd(money, item.token);
            }
        }

        return money;
    }

    //Get personal income amount (received)
    function getProfitMoney() public constant returns (uint256, uint256) {
        uint256 regularMoney = 0;
        uint256 currentMoney = 0;
        for (uint8 i = 1; i <= 6; i++) {
            PledgeOrder item = orders[msg.sender][i];

            regularMoney = Utils.safeAdd(regularMoney, item.profitToken);
        }
        currentMoney = Utils.safeAdd(
            currentMoney,
            currentOrders[msg.sender].profitToken
        );
        return (regularMoney, currentMoney);
    }

    //Get Regular Staking Details
    function getPledgeStatic(uint8 _type)
        public
        constant
        returns (
            uint256,
            uint256,
            uint256,
            uint8
        )
    {
        PledgeOrder item = orders[msg.sender][_type];
        return (item.token, item.profitToken, item.time, item.types);
    }

    //Get current pledge details
    function getCurrentStatic()
        public
        constant
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        currentPledgeOrder item = currentOrders[msg.sender];
        return (item.token, item.profitToken, item.time);
    }

    //Get current income (not received)
    function getCurrentMoney() public constant returns (uint256) {
        uint256 money = 0;
        if (currentOrders[msg.sender].token <= 0) return money;
        uint256 time = block.timestamp + 60;
        uint256 diff = Utils.safeSub(time, currentOrders[msg.sender].time)/60/60/24;
        if (diff < 1) return money;

        money = ((currentOrders[msg.sender].token * 3) / 10000) * diff;
        return money;
    }

    //Get regular benefits (not claimed)
    function getPledgeCounts() public constant returns (uint256) {
        uint256 s = 0;
        for (uint8 i = 1; i <= 6; i++) {
            s = s + countMoney(i);
        }
        return s;
    }

    function countMoney(uint8 _type) private constant returns (uint256) {
        uint256 money = 0;
        if (orders[msg.sender][_type].token <= 0) return money;
        PledgeOrder storage item = orders[msg.sender][_type];
        uint256 time = block.timestamp;
        uint256 diff = Utils.safeSub(time, item.time) / 60 / 60 / 24;
        if(diff<1) return money;
        if (item.types == 1) {
             money = ((item.token * 6) / 10000) * diff;
        } else if (item.types == 2) {
            money = ((item.token * 8) / 10000) * diff;
        } else if (item.types == 3) {
         money = ((item.token * 12) / 10000) * diff;
        } else if (item.types == 4) {
            money = ((item.token * 16) / 10000) * diff;
        } else if(item.types == 5) {
            money = ((item.token * 20) / 10000) * diff;
        }
        return money;
    }

    // Can accept ether
    function() public payable {}
}