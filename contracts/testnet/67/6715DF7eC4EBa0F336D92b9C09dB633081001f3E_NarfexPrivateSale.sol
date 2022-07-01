// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

interface PancakePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1);
    function token0() external view returns (address);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/// @title Narfex Private Sale contract with vesting
/// @author Danil Sakhinov
/// @notice Users must be whitelisted in order to participate in the sale.
/// @notice During the sale, the user can buy Narfex at a fixed price.
/// @notice Purchased Narfex will be locked for 60 days from the end of the sale.
/// @notice After 60 days, the user will be able to withdraw Narfex in an amount equivalent to his BUSD deposit at the price at the time of unlock.
/// @notice The remaining Narfex user will be able to withdraw 10% every 120 days.
contract NarfexPrivateSale {

    struct User {
        bool isWhitelisted; // Is the user added to the whitelist
        uint deposit; // Purchase amount in BUSD
        uint narfexLocked; // Nafex blocked at the time of purchase
        uint withdrawn; // Amount of Narfex withdrawn
    }
    mapping (address => User) public users;
    address[] usersList;

    address public owner;

    // Contracts
    IBEP20 public NRFX;
    IBEP20 public BUSD;
    PancakePair public pair;

    uint constant WAD = 10 ** 18;
    uint constant DAY = 60 * 60 * 24;
    uint public profitFractination = 10 * WAD / 100; // The percentage into which the remaining profit is broken down
    uint public minUserAmount = 30000 * WAD; // The minimum amount for which a user can make a purchase
    uint public maxUserAmount = 100000 * WAD; // The maximum amount for which a user can make a purchase

    uint public saleStartTime; // Sale start timestamp in seconds
    uint public saleEndTime; // Sale end timestamp in seconds
    // The number of seconds between the end of the sale and Narfex unlocking equivalent to a deposit
    uint public depositLockupPeriod = 60 * DAY;
    // Number of seconds between percentage splits of profit
    uint public profitLockupPeriod = 120 * DAY;

    // Funds reserved for users that cannot be withdrawn by the owner
    uint public narfexReserved;
    // Offer price. Default: 0.4 BUSD
    uint public narfexStartPrice = 4 * WAD / 10;
    // The final price from which the profit margin will be calculated. Fixed at the time of the first unlock
    uint public narfexEndPrice;

    constructor (
        IBEP20 _nrfxAddress, // Narfex token address
        IBEP20 _busdAddress, // BUSD token address
        PancakePair _pair, // NRFX-BUSD Pancake Pair address
        uint _minUserAmount, // Minumum user deposit. Default is 30k WAD
        uint _maxUserAmount, // Maximum user deposit. Default is 100k WAD
        uint _depositLockupPeriod, // First lockup size in seconds. Default is 60 days
        uint _profitLockupPeriod, // Next lockups sizes in seconds. Default is 120 days
        uint _narfexStartPrice // NRFX price. Default is 0.4 WAD
    ) {
        owner = msg.sender;
        NRFX = IBEP20(_nrfxAddress);
        BUSD = IBEP20(_busdAddress);
        pair = PancakePair(_pair);
        minUserAmount = _minUserAmount > 0 ? _minUserAmount : minUserAmount;
        maxUserAmount = _maxUserAmount > 0 ? _maxUserAmount : maxUserAmount;
        depositLockupPeriod = _depositLockupPeriod > 0 ? _depositLockupPeriod : depositLockupPeriod;
        profitLockupPeriod = _profitLockupPeriod > 0 ? _profitLockupPeriod : profitLockupPeriod;
        narfexStartPrice = _narfexStartPrice > 0 ? _narfexStartPrice : narfexStartPrice;
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender), "You are not in whitelist");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    event Whitelisted(address _address);
    event SaleStarted(uint _startTime, uint _endTime);
    event PriceLock(uint _price);
    event Buy(address _user, uint _busdAmount, uint _narfexAmount);
    event Withdraw(address _user, uint _amount);
    event CollectBUSD(address _user, uint _amount);
    event CollectSurplus(address _user, uint _amount);

    /// @notice Mark another address as the contract owner
    /// @param _address New owner address
    function transferOwnership(address _address) public onlyOwner {
        owner = _address;
    }

    /// @notice Check if user is whitelisted
    /// @param _address User address
    /// @return bool
    function isWhitelisted(address _address) public view returns(bool) {
        return users[_address].isWhitelisted;
    }

    /// @notice Add user to the whitelist
    /// @param _address User address
    function addToWhitelist(address _address) public onlyOwner {
        users[_address].isWhitelisted = true;
        usersList.push(_address);
        emit Whitelisted(_address);
    }

    /// @notice Returns current Narfex price in BUSD
    /// @return Price
    function getNarfexPrice() public view returns (uint) {
        (uint112 reserve0, uint112 reserve1) = pair.getReserves();
        if (address(NRFX) == pair.token0()) {
            return reserve1 * WAD / reserve0;
        } else {
            return reserve0 * WAD / reserve1;
        }
    }

    /// @notice Returns the contract BUSD balance
    /// @return balance
    function getBusdBalance() public view returns(uint) {
        return BUSD.balanceOf(address(this));
    }

    /// @notice Returns the contract NRFX balance
    /// @return balance
    function getNarfexBalance() public view returns(uint) {
        return NRFX.balanceOf(address(this));
    }

    /// @notice Returns available NRFX to withdraw by the Owner
    /// @return amount
    function getNarfexAvailable() public view returns(uint) {
        return getNarfexBalance() - narfexReserved;
    }

    /// @notice Check if the sale is started
    /// @return bool
    function isSaleStarted() public view returns(bool) {
        return saleStartTime > 0;
    }

    /// @notice Check if the sale is ended
    /// @return bool
    function isSaleEnded() public view returns(bool) { 
        return 0 < saleEndTime && saleEndTime <= block.timestamp;
    }

    /// @notice Check if the sale is active
    /// @return bool
    function isSaleActive() public view returns(bool) {
        return isSaleStarted() && !isSaleEnded();
    }

    /// @notice Check if the first unlock is ready
    /// @return bool
    function isDepositUnlocked() public view returns(bool) {
        return isSaleEnded() && saleEndTime + depositLockupPeriod <= block.timestamp;
    }

    /// @notice Returns last unlock index. Useful for calculating the amount of Narfex available
    /// @return bool
    function getUnlockIndex() public view returns(uint) {
        return isDepositUnlocked()
            ? (block.timestamp - (saleEndTime + depositLockupPeriod)) / profitLockupPeriod
            : 0;
    }

    /// @notice Starts a sale for the specified duration. Available only for contract Owner
    /// @param _salePeriod Amount of seconds to sale end
    function startSale(uint _salePeriod) public onlyOwner {
        require(!isSaleStarted(), "Sale already started");
        saleStartTime = block.timestamp;
        saleEndTime = block.timestamp + _salePeriod;
        emit SaleStarted(saleStartTime, saleEndTime);
    }

    /// @notice Calculates amount of Narfex for BUSD deposit with specified price
    /// @param _deposit BUSD amount
    /// @param _price Narfex price in BUSD
    /// @return Narfex amount
    function getNarfexAmount(uint _deposit, uint _price) public view returns(uint) {
        return _deposit * WAD / (_price > 0 ? _price : getNarfexPrice());
    }

    /// @notice Buys NRFX for the specified amount of BUSD at the declared price and locks them in the contract.
    /// @param _amount BUSD amount
    function buy(uint _amount) public onlyWhitelisted {
        require(isSaleStarted(), "Sorry, the sale has not started yet");
        require(!isSaleEnded(), "Sorry, the sale has already ended");
        require(_amount >= minUserAmount, "Too small deposit");
        require(_amount <= maxUserAmount, "Too big deposit");

        // Calculate guaranteed number of tokens
        uint narfexAmount = getNarfexAmount(_amount, narfexStartPrice);
        require(narfexAmount <= getNarfexAvailable(), "Sorry, there is not enough sale supply");

        address sender = msg.sender;
        users[sender].deposit = _amount;
        users[sender].narfexLocked = narfexAmount;
        // Reserve this Narfex amount on the contract
        narfexReserved += narfexAmount;
        BUSD.transferFrom(sender, address(this), _amount);
        emit Buy(sender, _amount, narfexAmount);
    }

    /// @notice Locks the Narfex price
    /// @param _price New price in BUSD. Default: Current Narfex price
    function lockNarfexPrice(uint _price) internal {
        if (narfexEndPrice > 0) return; // End price already locked
        narfexEndPrice = _price > 0 ? _price : getNarfexPrice();
        // Narfex end price can't be lower than start price
        if (narfexEndPrice < narfexStartPrice) narfexEndPrice = narfexStartPrice;
        emit PriceLock(narfexEndPrice);
    }

    /// @notice Transfers amount of Narfex to a user
    /// @param _address User address
    /// @param _amount Narfex amount
    function payToUser(address _address, uint _amount) internal {
        require(getNarfexBalance() >= _amount, "Sorry, there is not enough sale supply");
        users[_address].withdrawn += _amount;
        // Decrease common reserve
        narfexReserved -= _amount;
        NRFX.transfer(_address, _amount);
    }

    /// @notice Returns current available amount of Narfex to withdraw
    /// @param _address User address
    /// @return Amount of Narfex
    function getAvailableToWithdraw(address _address) public view returns(uint) {
        if (!isDepositUnlocked()) return 0;
        User storage user = users[_address];
        if (!user.isWhitelisted) return 0;

        // Index of unlock period
        uint index = getUnlockIndex();
        // The number of Narfex equivalent to deposited BUSD amount
        uint depositEquivalent = getNarfexAmount(user.deposit, narfexEndPrice);
        // The profit total size
        uint profit = user.narfexLocked - depositEquivalent;
        // Narfex amount for each period
        uint profitFraction = profit * profitFractination / WAD;
        // How much should have been paid by now
        uint availableNow = index == 0
            ? depositEquivalent
            : depositEquivalent + profitFraction * index;
        // Subtract what has already been paid
        return availableNow - user.withdrawn;
    }

    /// @notice Withdraws all currently available User's Narfex
    /// @notice Fixes the price if it has not already been done by other users
    function withdraw() public onlyWhitelisted {
        require(isDepositUnlocked(), "Lockup period is not over yet");

        if (narfexEndPrice == 0) {
            // The user is the first to withdraw tokens. Fix the price first
            lockNarfexPrice(0);
        }

        address sender = msg.sender;
        uint amount = getAvailableToWithdraw(sender);
        require(amount > 0, "You do not have funds to withdraw");
        payToUser(sender, amount);
        emit Withdraw(sender, amount);
    }

    /// @notice Sends all available BUSD to the contract owner. Available only for contract Owner
    /// @notice Can be called at any time, because receiving Narfex is already guaranteed to users
    function sendBusdToOwner() public onlyOwner {
        uint balance = getBusdBalance();
        BUSD.transfer(owner, balance);
        emit CollectBUSD(owner, balance);
    }

    /// @notice Sends all unused Narfex to the contract owner. Available only for contract Owner
    /// @notice Can only be called when the sale is over
    function sendNarfexToOwner() public onlyOwner {
        require(isSaleEnded(), "The sale is not ended - reserves not yet determined");
        uint available = getNarfexBalance() - narfexReserved;
        require(available > 0, "No Narfex available to collect");
        NRFX.transfer(owner, available);
        emit CollectSurplus(owner, available);
    }

    /// @notice Ends sale early. Available only for contract Owner
    function forceSaleEnd() public onlyOwner {
        require(isSaleActive(), "Sale is not active");
        saleEndTime = block.timestamp;
    }

    /// @notice Changes the end time of an active sale. Available only for contract Owner
    function changeSaleEnd(uint _timestamp) public onlyOwner {
        require(isSaleActive(), "You can extend only active sale");
        saleEndTime = _timestamp;
    }

    /// @notice Accelerates the time of the first unlock. Available only for contract Owner
    /// @notice Can only be called after the end of the sale.
    /// @notice Fixes the final price of Narfex.
    function forceUnlockDeposit() public onlyOwner {
        require(isSaleEnded(), "Sale still not ended");
        require(narfexEndPrice == 0, "Deposit already unlocked");
        // Make first lockup period shorter
        depositLockupPeriod = block.timestamp - saleEndTime;
        // Lock current Narfex price
        lockNarfexPrice(0);
    }

    /// @notice Sets the minimum of user deposit. Available only for contract Owner
    /// @param _amount BUSD amount
    function setMinUserAmount(uint _amount) public onlyOwner {
        minUserAmount = _amount;
    }

    /// @notice Sets the maximum of user deposit. Available only for contract Owner
    /// @param _amount BUSD amount
    function setMaxUserAmount(uint _amount) public onlyOwner {
        maxUserAmount = _amount;
    }

    /// @notice Sets the percentage by which the profit is split. Available only for contract Owner
    /// @notice Cannot be called when a sale has already started
    /// @param _percents Amount of percents.
    function setProfitFractination(uint _percents) public onlyOwner {
        require(!isSaleStarted(), "You can't change the rules after the sale start");
        require(_percents <= WAD, "The fraction can't be higher than 100%");
        require(_percents > WAD / 100 * 5, "Too small fraction. Minimum is 5%");
        profitFractination = _percents;
    }

    /// @notice Sets the period of time from the end of the sale when the first unlock occurs.
    /// @notice Available only for contract Owner
    /// @notice If the sale has already started, the unlock period can only be shortened.
    /// @param _seconds Period in seconds
    function setDepositLockupPeriod(uint _seconds) public onlyOwner {
        require(!isDepositUnlocked(), "Deposits is already unlocked");
        if (isSaleStarted()) {
            require(_seconds < depositLockupPeriod, "After the start of sales, you can only shorten the period");    
        }
        depositLockupPeriod = _seconds;
    }

    /// @notice Sets the period of time after which you can collect a percentage of the profit
    /// @notice Available only for contract Owner
    /// @notice If the sale has already started, the unlock period can only be shortened.
    /// @param _seconds Period in seconds
    function setProfitLockupPeriod(uint _seconds) public onlyOwner {
        if (isSaleStarted()) {
            require(_seconds < profitLockupPeriod, "After the start of sales, you can only shorten the period");    
        }
        profitLockupPeriod = _seconds;
    }

    /// @notice Sets the initial sentence. Available only for contract Owner
    /// @notice The offer cannot be changed after the start of sales
    /// @param _price Amount of BUSD for one Narfex
    function setStartNarfexPrice(uint _price) public onlyOwner {
        require(!isSaleStarted(), "You can't change the demand after the sale start");
        require(_price > 0, "The price can't be equal zero");
        narfexStartPrice = _price;
    }

    /// @notice Returns the time of the next unlock if the sale has started. Otherwise 0
    /// @return Timestamp in seconds
    function getNextUnlockTime() public view returns(uint) {
        if (!isSaleStarted()) return 0;
        if (!isSaleEnded()) return saleEndTime;
        if (!isDepositUnlocked()) return saleEndTime + depositLockupPeriod;
        return saleEndTime + depositLockupPeriod + (getUnlockIndex() + 1) * profitLockupPeriod;
    }

}