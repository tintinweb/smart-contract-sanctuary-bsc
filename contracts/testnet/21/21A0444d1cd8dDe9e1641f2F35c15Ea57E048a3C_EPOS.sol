pragma solidity ^0.8.5;

// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Ownable {
    address public owner;
    // AggregatorV3Interface internal priceFeed;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        // priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );

        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
}

contract EPOS is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Token;
    uint256 public Token_Sold;
    uint256 public MaxFee; // in 10**8
    bool mintAllowed = true;
    mapping(address => bool) public blackListMap;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => assets) public userAssets;
    mapping(address => uint256) public distributionIncome; //Get income received from distribution;
    event TransferAsset(
        address indexed from,
        address indexed to,
        uint256 value
    );
    event Burn(address indexed from, uint256 value);
    event Withdrawn(address indexed from, uint256 value, uint256 date);
    event Distribution(
        address indexed receiver,
        address fromUser,
        uint256 levelIncome,
        uint256 incomeReceived
    );
    event Registeration(
        address userAddress,
        address referredBy,
        uint256 amountPaid,
        uint256 joingDate
    );
    struct userData {
        uint256 id;
        address userAddress;
        address referredBy;
        uint256 amountPaid;
        uint256 joingDate;
        bool activeAllLevel;
        bool isExist;
    }
    struct assets {
        address userAddress;
        uint256 withdrawableAsset;
        uint256 totalAsset;
    }
    uint256 priceIndex = 0;
    uint256 public _currentId = 1;
    mapping(address => userData) public users;
    address firstId;
    uint256 _minInvestment = 10;

    uint256 _amountForAccessAllLevel = 10000000000;
    uint256[] levelDistribution = [3, 2, 1, 1];

    uint256[] price = [1000000000, 1875000000, 3125000000, 5000000000];
    uint256[] priceLevel = [
        2000000000000,
        4000000000000,
        6000000000000,
        8000000000000
    ];

    constructor(
        string memory SYMBOL,
        string memory NAME,
        uint8 DECIMALS
    ) {
        symbol = SYMBOL;
        name = NAME;
        decimals = DECIMALS;
        decimalfactor = 10**uint256(decimals);
        Max_Token = 200000 * decimalfactor;

        users[msg.sender] = userData(
            _currentId,
            msg.sender,
            address(0),
            100,
            block.timestamp,
            true,
            true
        );
        firstId = msg.sender;
        _currentId++;

        // mint(MINT_ADDRESS, 1000000 * decimalfactor);
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(
            !blackListMap[_from],
            "Your address is blocked from transferring tokens."
        );
        require(
            !blackListMap[_to],
            "Your address is blocked from transferring tokens."
        );
        require(_to != address(0));
        uint256 adminCommission = (MaxFee * _value) / 10**10;
        uint256 amountSend = _value - adminCommission;
        balanceOf[_from] -= _value;
        balanceOf[_to] += amountSend;
        if (adminCommission > 0) {
            balanceOf[owner] += (adminCommission);
            emit TransferAsset(_from, owner, adminCommission);
        }

        emit TransferAsset(_from, _to, amountSend);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function burn(uint256 _value) public returns (bool success) {
        require(msg.sender == owner, "Only Owner Can Burn");
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        Max_Token -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public returns (bool success) {
        require(Max_Token >= (totalSupply + _value));
        require(mintAllowed, "Max supply reached");
        require(msg.sender == owner, "Only Owner Can Mint");
        // require(BNB * value == msg.value);
        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }

        // require(msg.sender == owner, "Only Owner Can Mint");
        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit TransferAsset(address(0), _to, _value);
        return true;
    }

    function _mint(address _to, uint256 _value)
        internal
        returns (bool success)
    {
        require(Max_Token >= (totalSupply + _value), "Max Supply reached");
        require(mintAllowed, "Max supply reached");
        // uint256 reBnb = getBNB(_value);
        // require(reBnb >= msg.value, "Invalid Amount sent");

        // require(BNB * value == msg.value);
        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }

        balanceOf[_to] += _value; // minting 15% extra to the owner
        totalSupply += _value;

        require(balanceOf[_to] >= _value);
        emit TransferAsset(address(0), _to, _value);
        return true;
    }

    function addBlacklist(address _blackListAddress) external onlyOwner {
        blackListMap[_blackListAddress] = true;
    }

    function removeBlacklist(address _blackListAddress) external onlyOwner {
        blackListMap[_blackListAddress] = false;
    }

    function updateMaxFee(uint256 _MaxFee) external onlyOwner {
        MaxFee = _MaxFee;
    }

    function destroyBlackFunds(address _blackListAddress) public onlyOwner {
        require(blackListMap[_blackListAddress]);
        Max_Token -= balanceOf[_blackListAddress];
        totalSupply -= balanceOf[_blackListAddress];
        balanceOf[_blackListAddress] = 0;
        emit Burn(_blackListAddress, balanceOf[_blackListAddress]);
    }

    function register(
        address referredBy,
        uint256 _amount,
        uint256 mode
    ) external {
        require(checkUserExists(referredBy) == true, "Invalid refer address");
        require(msg.sender != address(0), "Can't be zero address");

        require(
            Token_Sold + ((_amount * decimalfactor) / price[priceIndex]) <=
                priceLevel[priceIndex],
            "Current buy limit is limited"
        );
        require(mode <= 1, "Invalid mode of payment");
        bool _activeAllLevel = false;
        IERC20 token;
        uint256 priceDecimal = 1;
        if (_amount * decimalfactor >= _amountForAccessAllLevel) {
            _activeAllLevel = true;
        }
        Token_Sold += (_amount * decimalfactor) / price[priceIndex];
        //Now we will distribute income
        uint256 _decimalfactor = 10**14;
        priceDecimal = 10**10;

        if (mode == 0) {
            token = IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));
        }
        if (mode == 1) {
            token = IERC20(address(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee));
            // _decimalfactor = 10**18;
        }

        uint256 amount = _amount * decimalfactor;
        require(
            amount >= _minInvestment * _decimalfactor,
            "Can't be less than Min Amount"
        );
        uint256 _tokenTransfered = (amount * 5) / 100;
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "Token 1 allowance too low"
        );
        token.transferFrom(msg.sender, referredBy, _tokenTransfered);

        distributionIncome[referredBy] += (amount * decimalfactor * 5) / 100;
        address uplineUserAddress = getUplineAddress(referredBy);
        uint256 currentLevelDistribute = 0;

        for (uint256 i = 0; i <= _currentId; i++) {
            if (uplineUserAddress == firstId) {
                break;
            } else {
                if (currentLevelDistribute < 4) {
                    if (users[uplineUserAddress].activeAllLevel == true) {
                        token.transferFrom(
                            msg.sender,
                            referredBy,
                            (amount *
                                levelDistribution[currentLevelDistribute]) / 100
                        );
                        _tokenTransfered +=
                            (amount *
                                levelDistribution[currentLevelDistribute]) /
                            100;
                        distributionIncome[uplineUserAddress] +=
                            (amount *
                                levelDistribution[currentLevelDistribute]) /
                            100;
                        emit Distribution(
                            uplineUserAddress,
                            msg.sender,
                            currentLevelDistribute,
                            (amount *
                                levelDistribution[currentLevelDistribute]) / 100
                        );
                        uplineUserAddress = getUplineAddress(uplineUserAddress);
                        currentLevelDistribute++;
                    } else {
                        uplineUserAddress = getUplineAddress(uplineUserAddress);
                    }
                } else {
                    break;
                }
            }
        }
        token.transferFrom(msg.sender, owner, amount - _tokenTransfered);
        //15% minted and send to founder wallets
        _mint(owner, (((_amount * 100000000) / price[priceIndex]) * 15) / 100);

        users[msg.sender] = userData(
            _currentId,
            msg.sender,
            referredBy,
            amount,
            block.timestamp,
            _activeAllLevel,
            true
        );
        userAssets[msg.sender].withdrawableAsset +=
            (_amount * decimalfactor) /
            price[priceIndex];
        userAssets[msg.sender].totalAsset +=
            (_amount * decimalfactor) /
            price[priceIndex];
        _currentId++;

        if (Token_Sold >= priceLevel[priceIndex]) {
            priceIndex++;
        }

        emit Registeration(
            msg.sender,
            referredBy,
            _amount * decimalfactor,
            block.timestamp
        );
    }

    function checkAllowance(uint256 Coin) public view returns (uint256) {
        IERC20 token;
        if (Coin == 0) {
            token = IERC20(address(0xf64959391e3f92037F87Bf0B75AD85228c9C2a55));
        }
        if (Coin == 1) {
            token = IERC20(address(0x411F8A0D947B2fF3834fD614070A895c734645c2));
        }
        uint256 allow = token.allowance(msg.sender, address(this));
        return allow;
    }

    function getUplineAddress(address _userAddress)
        internal
        view
        returns (address)
    {
        return users[_userAddress].referredBy;
    }

    function checkUserExists(address _userAddress)
        internal
        view
        returns (bool)
    {
        return users[_userAddress].isExist;
    }

    function withdrawStaking() public returns (bool) {
        require(
            ((users[msg.sender].joingDate - block.timestamp) / 60 / 60 / 24) %
                30 ==
                0,
            "Incorrect withdrawal date"
        );
        require(
            userAssets[msg.sender].withdrawableAsset > 0,
            "Maximum amount withdrawn."
        );

        uint256 WM = (userAssets[msg.sender].withdrawableAsset * 10) / 100;
        _mint(msg.sender, WM);
        userAssets[msg.sender].withdrawableAsset - WM;
        emit Withdrawn(msg.sender, WM, block.timestamp);
        return true;
    }

    function getWithdrawableBalance(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 balance = userAssets[_userAddress].withdrawableAsset;
        return balance;
    }

    function getTotalBalance(address _userAddress)
        public
        view
        returns (uint256)
    {
        uint256 balance = userAssets[_userAddress].totalAsset;
        return balance;
    }

    function getBV(address _userAddress) public view returns (uint256) {
        uint256 bv = distributionIncome[_userAddress];
        return bv;
    }

    function getCurrentPrice() public view returns (uint256) {
        return price[priceIndex];
    }
}