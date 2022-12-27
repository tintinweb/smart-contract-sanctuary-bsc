pragma solidity ^0.8.17;

//SPDX-License-Identifier: MIT Licensed

interface IToken {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function balanceOf(address Admin) external view returns (uint256);

    function mint(address to, uint256 amount) external returns (bool);

    function allowance(address Admin, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;

    event Approval(
        address indexed Admin,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract POOL {
    IToken public CREST; // CREST
    IToken public BUSD = IToken(0xf5265b3DAbD3Ca2619B9002a9929CD1c606CEa00); // BUSD
    address BNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; //for BNB
    AggregatorV3Interface public priceFeedbnb;

    address payable public Admin;

    address[] public multiSigAdmins;

    uint256 public tokenPerUsdBuy = 10;
    uint256 public tokenPerUsdSell = 10;

    uint256 public transactionCount = 0;

    uint256 public soldToken;
    uint256 public amountRaisedBNB;
    uint256 public amountRaisedBUSD;

    bool public CanMint;
    bool public CanBuy;
    bool public CanSell;

    struct user {
        uint256 bnb_balance;
        uint256 busd_balance;
        uint256 token_balance;
        uint256 bnb_balance_sell;
        uint256 busd_balance_sell;
        uint256 token_balance_sell;
    }

    struct Transaction {
        address Token;
        address payable to;
        uint256 amount;
        uint256 time;
        bool isExecuted;
        bool isApproved;
        bool isRejected;
        uint256 approveCount;
        uint256 rejectCount;
        mapping(address => bool) isApprovedBy;
        mapping(address => bool) isRejectedBy;
    }

    mapping(address => user) public users;
    mapping(address => bool) public multisigAdmin;
    mapping(uint256 => Transaction) public transactions;
    mapping(address => bool) public isBlocked;

    modifier onlyAdmin() {
        require(msg.sender == Admin, "POOL: Not an Admin");
        _;
    }

    modifier onlyMultiSigAdmin() {
        require(multisigAdmin[msg.sender] == true, "POOL: Not an Admin");
        _;
    }

    modifier isNOTBot() {
        require(isBlocked[msg.sender] == false, "POOL: You are blocked");
        _;
    }

    modifier isNotContract() {
        require(msg.sender == tx.origin, "POOL: You are blocked");
        require(!(msg.sender.code.length > 0), "POOL: You are blocked");
        _;
    }

    event TOKEN_BOUGHT(address _user, uint256 _amount, address Token);
    event TOKEN_SOLD(address _user, uint256 _amount, address Token);
    event TRANASACTON_REQUESTED(
        address _user,
        address _to,
        uint256 _amount,
        address Token,
        uint256 _time,
        uint256 _transactionId
    );
    event TRANSACTION_APPROVED(
        address _user,
        address _to,
        uint256 _amount,
        address Token,
        uint256 _time,
        uint256 _transactionId
    );
    event TRANSACTION_REJECTED(
        address _user,
        address _to,
        uint256 _amount,
        address Token,
        uint256 _time,
        uint256 _transactionId
    );
    event TRANASACTON_EXECUTED(
        address _user,
        address _to,
        uint256 _amount,
        address Token,
        uint256 _time,
        uint256 _transactionId
    );

    constructor(IToken _CREST) {
        Admin = payable(msg.sender);
        multisigAdmin[msg.sender] = true;
        multiSigAdmins.push(Admin);

        // BSC
        priceFeedbnb = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526 //testnet
            //     0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE //mainnet
        );
        CREST = _CREST;
        CanBuy = true;
        CanSell = true;
        CanMint = false;
    }

    receive() external payable {}

    // to get real time price of bnb
    function getLatestPricebnb() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedbnb.latestRoundData();
        return uint256(price);
    }

    // to buy token during POOL time with BNB => for web3 use

    function buyTokenbnb() public payable isNotContract isNOTBot {
        require(CanBuy == true, "POOL: Can't buy token");

        uint256 numberOfTokens;
        numberOfTokens = bnbToToken(msg.value);

        soldToken = soldToken + (numberOfTokens);
        amountRaisedBNB = amountRaisedBNB + (msg.value);
        users[msg.sender].bnb_balance =
            users[msg.sender].bnb_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        if (CanMint) {
            CREST.mint(msg.sender, numberOfTokens);
        } else {
            CREST.transfer(msg.sender, numberOfTokens);
        }

        emit TOKEN_BOUGHT(msg.sender, numberOfTokens, BNB);
    }

    //to sell token during POOL time with BNB => for web3 use
    function sellTokenbnb(uint256 _amount) public isNotContract isNOTBot {
        require(CanSell == true, "POOL: Can't sell token");

        CREST.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = tokenToBnb(_amount);
        require(amount <= address(this).balance, "POOL: Not enough BNB");
        users[msg.sender].bnb_balance_sell =
            users[msg.sender].bnb_balance_sell +
            (amount);
        users[msg.sender].token_balance_sell =
            users[msg.sender].token_balance_sell +
            (_amount);
        payable(msg.sender).transfer(amount);

        emit TOKEN_SOLD(msg.sender, _amount, BNB);
    }

    // to buy token during POOL time with BUSD => for web3 use
    function buyTokenbusd(uint256 _amount) public isNotContract isNOTBot {
        require(CanBuy == true, "POOL: Can't buy token");

        uint256 numberOfTokens;
        numberOfTokens = busdToToken(_amount);
        BUSD.transferFrom(msg.sender, address(this), _amount);
        soldToken = soldToken + (numberOfTokens);
        amountRaisedBUSD = amountRaisedBUSD + (_amount);
        users[msg.sender].busd_balance =
            users[msg.sender].busd_balance +
            (_amount);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        if (CanMint) {
            CREST.mint(msg.sender, numberOfTokens);
        } else {
            CREST.transfer(msg.sender, numberOfTokens);
        }

        emit TOKEN_BOUGHT(msg.sender, numberOfTokens, address(BUSD));
    }

    // to sell token during POOL time with BUSD => for web3 use
    function sellTokenbusd(uint256 _amount) public isNotContract isNOTBot {
        require(CanSell == true, "POOL: Can't sell token");

        CREST.transferFrom(msg.sender, address(this), _amount);
        uint256 amount = tokenToBusd(_amount);
        require(
            amount <= BUSD.balanceOf(address(this)),
            "POOL: Not enough BUSD"
        );
        BUSD.transfer(msg.sender, amount);
        users[msg.sender].busd_balance_sell =
            users[msg.sender].busd_balance_sell +
            (amount);
        users[msg.sender].token_balance_sell =
            users[msg.sender].token_balance_sell +
            (_amount);

        emit TOKEN_SOLD(msg.sender, _amount, address(BUSD));
    }

    // to check number of token for given bnb
    function bnbToToken(uint256 _amount) public view returns (uint256) {
        uint256 bnbToUsd = (_amount * (getLatestPricebnb())) / (1 ether);
        uint256 numberOfTokens = bnbToUsd * (tokenPerUsdBuy);
        return (numberOfTokens * (10**(CREST.decimals()))) / (1e8);
    }

    // to check number of token for given TOKEN
    function tokenToBnb(uint256 _amount) public view returns (uint256) {
        uint256 usdToBnb = (_amount * (1 ether)) /
            (getLatestPricebnb()) /
            (tokenPerUsdSell) /
            (10**(CREST.decimals())) /
            (1e8);
        return usdToBnb;
    }

    // to check number of token for given BUSD
    function busdToToken(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount *
            (tokenPerUsdBuy) *
            (10**(CREST.decimals()))) / (10**(BUSD.decimals()));
        return numberOfTokens;
    }

    // to check number of token for given TOKEN
    function tokenToBusd(uint256 _amount) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * (10**(BUSD.decimals()))) /
            (tokenPerUsdSell) /
            (10**(CREST.decimals()));
        return numberOfTokens;
    }

    // to change Price of the token
    function changePrice(uint256 _priceBuy, uint256 _priceSell)
        external
        onlyAdmin
    {
        tokenPerUsdBuy = _priceBuy;
        tokenPerUsdSell = _priceSell;
    }

    // transfer Adminship
    function changeAdmin(address payable _newAdmin)
        external
        onlyAdmin
        isNotContract
        isNOTBot
    {
        Admin = _newAdmin;
    }

    // change tokens
    function changeToken(address _token)
        external
        onlyAdmin
        isNotContract
        isNOTBot
    {
        CREST = IToken(_token);
    }

    // to get current UTC time
    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    // to get contract bnb balance
    function contractBalancebnb() external view returns (uint256) {
        return address(this).balance;
    }

    // to get contract busd balance
    function contractBalancebusd() external view returns (uint256) {
        return BUSD.balanceOf(address(this));
    }

    // Set Miniting
    function SetMinting(bool enable) external onlyAdmin isNotContract isNOTBot {
        require(enable != CanMint, "POOL: Already in that state");
        CanMint = enable;
    }

    // Set Buying
    function SetBuying(bool enable) external onlyAdmin isNotContract isNOTBot {
        require(enable != CanBuy, "POOL: Already in that state");
        CanBuy = enable;
    }

    // Set Selling
    function SetSelling(bool enable) external onlyAdmin isNotContract isNOTBot {
        require(enable != CanSell, "POOL: Already in that state");
        CanSell = enable;
    }

    // to add new multisigAdmin
    function addAdmin(address _newAdmin)
        external
        onlyAdmin
        isNotContract
        isNOTBot
    {
        require(!multisigAdmin[_newAdmin], "POOL: Already an admin");
        multisigAdmin[_newAdmin] = true;
        multiSigAdmins.push(_newAdmin);
    }

    // to remove multisigAdmin
    function removeAdmin(address _admin)
        external
        onlyAdmin
        isNotContract
        isNOTBot
    {
        require(multisigAdmin[_admin], "POOL: Not an admin");
        multisigAdmin[_admin] = false;
        for (uint256 i = 0; i < multiSigAdmins.length; i++) {
            if (multiSigAdmins[i] == _admin) {
                multiSigAdmins[i] = multiSigAdmins[multiSigAdmins.length - 1];
                multiSigAdmins.pop();
                break;
            }
        }
    }

    // to get number of multisigAdmins
    function getAdminCount() external view returns (uint256) {
        return multiSigAdmins.length;
    }

    // to get all multisigAdmins
    function getAdmins() external view returns (address[] memory) {
        return multiSigAdmins;
    }

    // initiate transaction for multisig
    function initiateTransaction(
        address payable _to,
        uint256 _value,
        address token
    ) external onlyMultiSigAdmin isNotContract isNOTBot {
        require(multisigAdmin[_to], "POOL: Not an admin");
        require(_value > 0, "POOL: Value must be greater than 0");
        require(token != address(0), "POOL: Invalid token address");

        uint256 transactionId = transactionCount;
        Transaction storage transaction = transactions[transactionId];
        transaction.to = _to;
        transaction.amount = _value;
        transaction.Token = token;
        transaction.time = block.timestamp + 1 days;
        transaction.isExecuted = false;
        transaction.isApproved = false;
        transaction.isRejected = false;
        transaction.approveCount = 0;
        transaction.rejectCount = 0;

        transactionCount = transactionCount + 1;

        emit TRANASACTON_REQUESTED(
            msg.sender,
            _to,
            _value,
            token,
            block.timestamp + 1 days,
            transactionId
        );
    }

    // approve transaction for multisig
    function approveOrRejectTransaction(uint256 id, bool Choice)
        external
        onlyMultiSigAdmin
        isNotContract
        isNOTBot
    {
        Transaction storage transaction = transactions[id];

        require(
            transaction.isExecuted == false,
            "POOL: Transaction already executed"
        );
        require(
            transaction.isApproved == false,
            "POOL: Transaction already approved"
        );
        require(
            transaction.isRejected == false,
            "POOL: Transaction already rejected"
        );
        require(
            transaction.time > block.timestamp,
            "POOL: Transaction time expired"
        );
        require(
            transaction.to != msg.sender,
            "POOL: Can not Approve to yourSelf"
        );

        require(
            transaction.isApprovedBy[msg.sender] ==
                transaction.isRejectedBy[msg.sender],
            "already Approved or Rejected"
        );

        if (Choice) {
            transaction.isApprovedBy[msg.sender] = true;
            transaction.isRejectedBy[msg.sender] = false;
            transaction.approveCount++;
        } else {
            transaction.isApprovedBy[msg.sender] = false;
            transaction.isRejectedBy[msg.sender] = true;
            transaction.rejectCount++;
        }
    }

    function executeTransaction(uint256 id)
        external
        onlyMultiSigAdmin
        isNotContract
        isNOTBot
    {
        Transaction storage transaction = transactions[id];

        require(
            block.timestamp > transaction.time,
            "COFFEE PROJECT: Time NOT Passed YET"
        );
        require(
            !transaction.isRejected,
            "COFFEE PROJECT: Trasnaction REJECTED"
        );
        require(
            !transaction.isExecuted,
            "COFFEE PROJECT: Trasnaction Already Executed"
        );
        if ( transaction.approveCount < ((multiSigAdmins.length)/2)) {
            transaction.isRejected = true;
            transaction.isApproved = false;
            emit TRANSACTION_APPROVED(
                msg.sender,
                transaction.to,
                transaction.amount,
                transaction.Token,
                block.timestamp + 1 days,
                id
            );
        } else {
            transaction.isRejected = false;
            transaction.isApproved = true;
            emit TRANSACTION_REJECTED(
                msg.sender,
                transaction.to,
                transaction.amount,
                transaction.Token,
                block.timestamp + 1 days,
                id
            );
        }
        if (transaction.Token == BNB) {
            if (address(this).balance >= transaction.amount) {
                transaction.to.transfer(transaction.amount);
                transaction.isExecuted = true;
                emit TRANASACTON_EXECUTED(
                    msg.sender,
                    transaction.to,
                    transaction.amount,
                    transaction.Token,
                    block.timestamp + 1 days,
                    id
                );
            }
        } else {
            if (
                IToken(transaction.Token).balanceOf(address(this)) >=
                transaction.amount
            ) {
                IToken(transaction.Token).transfer(
                    transaction.to,
                    transaction.amount
                );
                transaction.isExecuted = true;
                emit TRANASACTON_EXECUTED(
                    msg.sender,
                    transaction.to,
                    transaction.amount,
                    transaction.Token,
                    block.timestamp + 1 days,
                    id
                );
            }
        }
    }
}