// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
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

contract STIERTEST is Ownable {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    uint256 decimalfactor;
    uint256 public Max_Token;
    uint256 public Token_Sold;
    uint256 public MaxFee;
    uint256 public ICO_Token;
    uint256 public PublicSale_Token;
    uint256 public Gaming_Token;
    uint256 public E_Commerce_Token;
    uint256 public NFT_Token;
    uint256 public TradeBot_Token;

    bool icoStarted = true;
    bool mintAllowed = true;
    mapping(address => bool) public blackListMap;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => assets) public userAssets;
    mapping(address => uint256) public distributionIncome; //Get income received from distribution;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);
    event Withdrawn(address indexed from, uint256 value, uint256 date);
    event Distribution(
        address indexed receiver,
        address fromUser,
        uint256 levelIncome,
        uint256 incomeReceived
    );
    event BuyToken(
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
        uint256 referCount100;
        bool activeAllLevel;
        bool isExist;
    }
    struct assets {
        address userAddress;
        // uint256 withdrawableAsset;
        uint256 totalAsset;
    }
    uint256 priceIndex = 0;
    uint256 public _currentId = 1;
    mapping(address => userData) public users;
    address firstId;
    address founderWallet1 = 0xaA89b450b023763f5B30a4326681Da0D13930e2d;
    address founderWallet2 = 0x02f704262F63f9C624AF0E1Dd25e790Be8Ed23ac;
    address marketFounder = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address ICO_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address PublicSale_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address Founders_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address Gaming_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address TradeBot_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address Nft_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    address E_Commerce_Address = 0x7968a967902a5Bb354926e490164601cD545A9f2;
    uint256 _minInvestment = 100 ether;
    uint256 price = 0.8 ether;
    uint256 _amountForAccessAllLevel = 100 ether;
    uint256[] levelDistribution = [5, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1];

    constructor(
        string memory SYMBOL,
        string memory NAME,
        uint8 DECIMALS
    ) {
        symbol = SYMBOL;
        name = NAME;
        decimals = DECIMALS;
        decimalfactor = 10**uint256(decimals);
        Max_Token = 2500000 * decimalfactor;
        ICO_Token = 1000000 * decimalfactor;
        PublicSale_Token = 500000 * decimalfactor;
        Gaming_Token = 250000 * decimalfactor;
        E_Commerce_Token = 125000 * decimalfactor;
        NFT_Token = 125000 * decimalfactor;
        TradeBot_Token = 125000 * decimalfactor;
        users[founderWallet1] = userData(
            _currentId,
            founderWallet1,
            address(0),
            100,
            block.timestamp,
            2,
            true,
            true
        );
        firstId = founderWallet1;
        _currentId++;
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
            emit Transfer(_from, owner, adminCommission);
        }

        emit Transfer(_from, _to, amountSend);
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

        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }

        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function _mint(address _to, uint256 _value)
        internal
        returns (bool success)
    {
        require(Max_Token >= (totalSupply + _value));
        require(mintAllowed, "Max supply reached");

        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }

        balanceOf[_to] += _value;
        totalSupply += _value;
        require(balanceOf[_to] >= _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function _tokenomicMint(uint256 _value) internal returns (bool success) {
        require(Max_Token >= (totalSupply + _value), "Max Supply reached");

        require(mintAllowed, "Max supply reached");
        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }

        balanceOf[PublicSale_Address] += (_value * 20) / 100;
        emit Transfer(address(0), PublicSale_Address, (_value * 20) / 100);

        balanceOf[founderWallet1] += (_value * 9) / 100;
        emit Transfer(address(0), founderWallet1, (_value * 9) / 100);
        balanceOf[founderWallet2] += (_value * 6) / 100;
        emit Transfer(address(0), founderWallet2, (_value * 6) / 100);

        balanceOf[Gaming_Address] += (_value * 10) / 100;
        emit Transfer(address(0), Gaming_Address, (_value * 10) / 100);

        balanceOf[TradeBot_Address] += (_value * 5) / 100;
        emit Transfer(address(0), TradeBot_Address, (_value * 5) / 100);

        balanceOf[Nft_Address] += (_value * 5) / 100;
        emit Transfer(address(0), Nft_Address, (_value * 5) / 100);

        balanceOf[E_Commerce_Address] += (_value * 5) / 100;
        emit Transfer(address(0), E_Commerce_Address, (_value * 5) / 100);

        totalSupply += (_value * 60) / 100;

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

    function buyToken(
        address referredBy,
        uint256 _amount,
        uint256 mode
    ) external {
        require(checkUserExists(referredBy) == true, "Invalid refer address");
        require(msg.sender != address(0), "Can't be zero address");
        require(icoStarted == true, "ICO ended");

        require(
            Token_Sold + ((_amount * decimalfactor) / price) <= ICO_Token,
            "Max ICO Limit Reached!"
        );
        require(mode <= 1, "Invalid mode of payment");
        uint256 _decimalfactor = 10**18;
        uint256 amount = _amount * _decimalfactor;

        bool _activeAllLevel = false;
        IERC20 token;

        if (amount >= _amountForAccessAllLevel) {
            _activeAllLevel = true;
            users[referredBy].referCount100 += 1;
        }
        Token_Sold += ((amount * decimalfactor) / price);
        //Now we will distribute income

        if (mode == 0) {
            token = IERC20(address(0x19212012e74fb5f2FF055d43929138eA1B36f92e));
        }
        if (mode == 1) {
            token = IERC20(address(0x19212012e74fb5f2FF055d43929138eA1B36f92e));
        }

        require(amount >= _minInvestment, "Can't be less than Min Amount");
        uint256 _tokenTransfered = (amount * 10) / 100;
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "Token allowance too low"
        );
        _tokenomicMint(
            ((_amount * decimalfactor) / (price / 10000000000)) * decimalfactor
        );
        _mint(
            msg.sender,
            ((_amount * decimalfactor) / (price / 10000000000)) * decimalfactor
        );
        if (referredBy == founderWallet1) {
            token.transferFrom(
                msg.sender,
                founderWallet1,
                (_tokenTransfered * 55) / 100
            );
            token.transferFrom(
                msg.sender,
                founderWallet2,
                (_tokenTransfered * 45) / 100
            );
        } else if (referredBy != founderWallet1) {
            token.transferFrom(msg.sender, referredBy, _tokenTransfered);
            emit Distribution(referredBy, msg.sender, 5, _tokenTransfered);
        }
        distributionIncome[referredBy] += _tokenTransfered;
        address uplineUserAddress = getUplineAddress(referredBy);
        uint256 currentLevelDistribute = 0;

        for (uint256 i = 0; i <= _currentId; i++) {
            if (uplineUserAddress == firstId) {
                break;
            } else {
                if (currentLevelDistribute < 11) {
                    if (
                        users[uplineUserAddress].activeAllLevel == true &&
                        users[uplineUserAddress].referCount100 >= 2
                    ) {
                        token.transferFrom(
                            msg.sender,
                            uplineUserAddress,
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
        uint256 remainingBalance = amount - _tokenTransfered;

        token.transferFrom(
            msg.sender,
            marketFounder,
            (remainingBalance * 10) / 100
        );
        token.transferFrom(
            msg.sender,
            founderWallet1,
            (remainingBalance * 50) / 100
        );

        token.transferFrom(
            msg.sender,
            founderWallet2,
            (remainingBalance * 40) / 100
        );

        if (users[msg.sender].userAddress == address(0)) {
            users[msg.sender] = userData(
                _currentId,
                msg.sender,
                referredBy,
                amount,
                block.timestamp,
                0,
                _activeAllLevel,
                true
            );

            _currentId++;
        } else if (users[msg.sender].userAddress == msg.sender) {
            users[msg.sender].amountPaid += amount;
            users[msg.sender].activeAllLevel = _activeAllLevel;
        }
        // userAssets[msg.sender].withdrawableAsset +=
        //     (amount * decimalfactor) /
        //     price;
        userAssets[msg.sender].totalAsset += (amount * decimalfactor) / price;
        // if (Token_Sold >= priceLevel[priceIndex]) {
        //     priceIndex++;
        // }

        emit BuyToken(
            msg.sender,
            referredBy,
            _amount * _decimalfactor,
            block.timestamp
        );
    }

    function checkAllowance(uint256 Coin) public view returns (uint256) {
        IERC20 token;
        if (Coin == 0) {
            token = IERC20(address(0x19212012e74fb5f2FF055d43929138eA1B36f92e));
        }
        if (Coin == 1) {
            token = IERC20(address(0x19212012e74fb5f2FF055d43929138eA1B36f92e));
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

    // function withdrawStaking() public returns (bool) {
    //     require(icoStarted == false, "ICO is running");
    //     require(
    //         ((users[msg.sender].joingDate - block.timestamp) / 60 / 60 / 24) %
    //             30 ==
    //             0,
    //         "Incorrect withdrawal date"
    //     );
    //     require(
    //         userAssets[msg.sender].withdrawableAsset > 0,
    //         "Maximum amount withdrawn."
    //     );

    //     uint256 WM = (userAssets[msg.sender].withdrawableAsset * 10) / 100;
    //     _mint(msg.sender, WM);
    //     userAssets[msg.sender].withdrawableAsset - WM;
    //     emit Withdrawn(msg.sender, WM, block.timestamp);
    //     return true;
    // }

    // function getWithdrawableBalance(address _userAddress)
    //     public
    //     view
    //     returns (uint256)
    // {
    //     uint256 balance = userAssets[_userAddress].withdrawableAsset;
    //     return balance;
    // }

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
        return price;
    }

    function getCurrentPrice(uint256 _price) public returns (uint256) {
        price = _price;
        return price;
    }

    function setIcoSaleStatus(uint256 _status) public {
        require(msg.sender == owner, "Only Owner can change Status");
        if (_status == 0) {
            icoStarted = false;
        } else {
            icoStarted = true;
        }
    }

    function setMinAmount(uint256 amount) public onlyOwner {
        _minInvestment = amount;
    }
}