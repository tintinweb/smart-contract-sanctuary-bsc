//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;


interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface INarfexTokenSale {
    function buyTokens(uint256 amount) external;
    function unlock() external;
    function withdraw(uint256 _numberOfTokens) external;
    function isWhitelisted(address _address) external view returns(bool);
    function getAvailableBalance(address _address) external view returns(uint256);
}

contract Pool {
    
    struct Crowdfunder{
        uint256 busdDeposit; // user's deposit in BUSD
        uint256 availableBalance; // balance of NRFX to withdraw
        bool deposited; // user is Crowdfunder 
    }

    mapping(address => Crowdfunder) public crowd; // array address to struct
    
    address[] users; // array of users addresses

    IBEP20 public busdAddress; // BUSD address
    IBEP20 public nrfxAddress; // address of Narfex
    address public _owner; //owner of this pool
    address public factoryOwner; // owner of factory contract
    INarfexTokenSale public tokenSaleAddress; // address of token-sale contract
    bool public isNarfexLocked; // from this point users can not deposit busd to this pool
    uint256 public maxPoolAmount; // maximum of crowdfunding amount
    uint256 public minUserDeposit; // minimum deposit for user
    uint256 public maxUserDeposit; // maximum deposit for user
    uint256 public busdAmount; // all BUSD in contract before participate in token-sale
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision
    uint constant NARFEX_COMMISSION = 2 * WAD / 100; // Narfex token commission in wei

    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);
    event Unlock(uint256 income);
    event EmergencyWithdraw();

    constructor(
        IBEP20 _busdAddress,
        IBEP20 _nrfxAddress,
        INarfexTokenSale _tokenSaleAddress,
        address _factoryOwner,
        uint256 _maxPoolAmount,
        uint256 _minUserDeposit,
        uint256 _maxUserDeposit
        ) {
        busdAddress = _busdAddress;
        nrfxAddress = _nrfxAddress;
        tokenSaleAddress = _tokenSaleAddress;
        factoryOwner = _factoryOwner;
        maxPoolAmount = _maxPoolAmount;
        maxUserDeposit = _maxUserDeposit;
        minUserDeposit = _minUserDeposit;
        _owner = msg.sender;
    }

    /// @notice deposit BUSD tokens from Crowdfunders for this pool
    /// @param amount of deposit in this pool in BUSD 
    function depositBUSD(uint256 amount) external {
        address _msgSender = msg.sender;

        require(maxPoolAmount - busdAmount - amount >= 0, "You can not deposit this amount");
        require(!isPoolCollected(), "Crowdfunding in this pool is over");
        require(amount >= minUserDeposit, "Deposit should be more than minUserDeposit");
        require(amount + crowd[_msgSender].busdDeposit <= maxUserDeposit, "Deposit should be less than maxUserDeposit");

        // Create a new Crowdfunder
        if (!crowd[_msgSender].deposited) {
            crowd[_msgSender].deposited = true;
            users.push(_msgSender);
        } 

        // Apply amount to the pool
        crowd[_msgSender].busdDeposit += amount;
        busdAmount += amount;
        
        busdAddress.transferFrom(_msgSender, address(this), amount);
        emit Deposit(_msgSender, amount);
    }

    /// @notice Withdraw NRFX for Crowdfunder
    /// @param _amount Amount NRFX to withdraw
    function withdrawNRFX(uint256 _amount) external {
        address _msgSender = msg.sender;

        // Amount must be equal or less than crowdfunder balance
        uint amount = _amount > crowd[_msgSender].availableBalance
            ? crowd[_msgSender].availableBalance
            : _amount;
        crowd[_msgSender].availableBalance -= amount;
        nrfxAddress.transfer(_msgSender, amount);
        emit Withdraw(_msgSender, amount);
    }

    /// @notice Transfer BUSD to token-sale contract for participate in token-sale
    function buyNRFX() external {
        require(isPoolCollected(), "Crowdfunding in this pool is over");
        uint busdBalance = getBusdBalance();
        require(busdBalance == busdAmount, "The pool balance is empty");
        isNarfexLocked = true;
        busdAddress.approve(address(tokenSaleAddress), busdBalance);
        tokenSaleAddress.buyTokens(busdBalance);
    }

    /// @notice unlocking NRFX in INTokenSale contract
    function unlockNRFX() external {
        require(isNarfexLocked, "Crowdfunding in this pool is over");
        tokenSaleAddress.unlock();
        // Get the incoming balance before withdraw to divide it before it adds up to the pool balance
        uint income = tokenSaleAddress.getAvailableBalance(address(this));
        // Subtract Narfex transfer commission
        income -= income * NARFEX_COMMISSION / WAD;
        // Send NRFX to the Pool
        tokenSaleAddress.withdraw(0);
        emit Unlock(income);
        for(uint256 i = 0; i < users.length; i++){
            uint256 share = getUserIncomeShare(income, users[i]);
            crowd[users[i]].availableBalance += share;
            crowd[users[i]].deposited = false;
        }
    }

    /// @notice Withdraw BUSD deposits for all users (for some issues)
    function emergencyWithdrawBUSD() public {
        require(
            msg.sender == _owner || msg.sender == factoryOwner,
            "Only owner of the pool or the factory owner can use this function");
        require(!isNarfexLocked, "Crowdfunding in this pool is over");

        for(uint256 i = 0; i < users.length; i++) {
            busdAddress.transfer(users[i], crowd[users[i]].busdDeposit);
            crowd[users[i]].busdDeposit = 0;
            crowd[users[i]].deposited = false;
        }
        busdAmount = 0;
        emit EmergencyWithdraw();
    }

    /// @notice get balance of BUSD tokens in this pool
    function getBusdBalance() public view returns (uint256) {
        return busdAddress.balanceOf(address(this));
    }

    /// @notice get balance of NRFX tokens in this pool
    function getNrfxBalance() public view returns (uint256) {
        return nrfxAddress.balanceOf(address(this));
    }    

    /// @notice Returns percentage of BUSD in this pool for each user
    /// @param _user Address of Crowdfunder
    /// @return User share
    function getUserShare(address _user) public view returns(uint256){
        return busdAmount > 0
            ? crowd[_user].busdDeposit * WAD / busdAmount
            : 0;
    }

    /// @notice Returns amount of user available balace in the income
    /// @param _income Amount of tokens
    /// @param _user Address of Crowdfunder
    /// @return NRFX amount
    function getUserIncomeShare(uint _income, address _user) public view returns(uint256) {
        uint share = getUserShare(_user);
        return share > 0
            ? _income * share / WAD
            : 0;
    }

    /// @notice Returns amount of NRFX available in the Pool
    /// @param _user Crowdfunder address
    /// @return NRFX amount
    function getUserAvailableNRFX(address _user) public view returns(uint256) {
        return crowd[_user].availableBalance;
    }

    /// @notice Returns amount of NRFX available in the Pool and NarfexTokenSale both
    /// @param _user Crowdfunder address
    /// @return NRFX amount
    function getUserNRFXBalance(address _user) public view returns(uint) {
        uint income = tokenSaleAddress.getAvailableBalance(address(this));
        return crowd[_user].availableBalance + getUserIncomeShare(income, _user);
    }

    /// @notice Returns true if the pool is full
    /// @return Pool is fully collected
    function isPoolCollected() public view returns(bool) {
        return busdAmount == maxPoolAmount;
    }

    /// @notice Returns true if the pool is whitelisted in TokenSale contract
    /// @return Pool is whitelisted 
    function isWhitelisted() public view returns(bool) {
        return tokenSaleAddress.isWhitelisted(address(this));
    }

    /// @notice Ends pool collection prematurely. Available only for owner and factory owner
    function forceCompleteThePool() public {
        require(
            msg.sender == _owner || msg.sender == factoryOwner,
            "Only owner of the pool or the factory owner can use this function");
        maxPoolAmount = busdAmount;
    }

    /// @notice changes amount of minimum deposit BUSD in depositBUSD function
    /// @param _minUserDeposit minimum deposit BUSD in depositBUSD function
    function setMinUserDeposit (uint256 _minUserDeposit) public {
        require(msg.sender == factoryOwner);
        minUserDeposit = _minUserDeposit;
    }

    /// @notice changes amount of maximum deposit BUSD in depositBUSD function
    /// @param _maxUserDeposit maximum deposit BUSD in depositBUSD function
    function setMaxUserDeposit (uint256 _maxUserDeposit) public {
        require(msg.sender == factoryOwner);
        maxUserDeposit = _maxUserDeposit;
    } 

    /// @notice Returns users.length
    /// @return Users count
    function getUsersCount() public view returns(uint) {
        return users.length;
    }

    /// @notice Returns the pool data in one request
    function getPoolData() public view returns(
        uint _maxPoolAmount,
        uint _minUserDeposit,
        uint _maxUserDeposit,
        bool _isNarfexLocked,
        bool _isPoolCollected,
        bool _isWhitelisted,
        uint _busdAmount,
        uint _busdBalance,
        uint _nrfxBalance
    ) {
        return (
            maxPoolAmount,
            minUserDeposit,
            maxUserDeposit,
            isNarfexLocked,
            isPoolCollected(),
            isWhitelisted(),
            busdAmount,
            getBusdBalance(),
            getNrfxBalance()
        );
    }

    /// @notice Returns Crowdfunder data in one request
    function getUserData(address _address) public view returns(
        uint _busdDeposit,
        uint _availableBalance,
        uint _share,
        bool _isOwner,
        bool _isFactoryOwner
    ) {
        Crowdfunder storage user = crowd[_address];
        return (
            user.busdDeposit,
            user.availableBalance,
            getUserShare(_address),
            _address == _owner,
            _address == factoryOwner
        );
    }

}