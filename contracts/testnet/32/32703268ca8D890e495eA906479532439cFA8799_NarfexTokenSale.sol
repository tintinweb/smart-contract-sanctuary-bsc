// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

// using PancakeFactory to get price of Narfex in BUSD
interface PancakeFactory {
    function getPair(address _token0, address _token1) external view returns (address pairAddress);
}

interface PancakePair {
    function getReserves() external view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
    function token0() external view returns (address);
}

interface IBEP20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/// @title Private sale contract for Narfex token in BUSD price
/// @author Viktor Potemkin
/// @notice After 60 days from the date of purchase, users can unlock tokens for the amount equivalent to the deposit in BUSD
/// @notice every 120 days after unlocking from the previous item, users receive 10 percent of the remaining locked amount of Narfex 

contract NarfexTokenSale {

    // user participating in the Narfex private sale
    struct Buyer{
        uint256 narfexAmount; // Current narfex amount left
        uint256 tenPercents; // Narfex amount left after the first unlock
        uint256 busdDeposit; // deposit for buy tokens in private sale
        uint256 unlockTime; // time point when user unlock tokens
        uint256 availableBalance; // token balance to withdraw
        bool isNarfexPayed; // payed narfexAmount = busdDeposit.mul(priceNarfex) after 60 days
        bool isWhitelisted; // added to whitelist
    }

    mapping (address => Buyer) public buyers; 

    IBEP20 public narfexContract;  // the token being sold
    IBEP20 public busdAddress; // payment token address
    address public owner; // deployer of contract 
    uint256 public saleStartTime; // starting sale point
    uint256 public toEndSecondsAmount; // Ending of private sale for whitelist in seconds
    uint256 public minAmountForUser; // minimum amount of deposit to buy in busd for each user
    uint256 public maxAmountForUser; // maximum amount of deposit for sale in busd for each user
    bool public isSaleStarted; // from this point sale is started
    uint256 public firstUnlockSeconds;// period of time for unlock 100% BUSD price
    uint256 public percentageUnlockSeconds;// period of time to unlock 10% of locked Narfex
    uint256 public firstNarfexPrice;// price of Narfex to buy locked tokens

    address public pairAddress; // pair Narfex -> BUSD in PancakeSwap
    uint constant WAD = 10 ** 18; // Decimal number with 18 digits of precision

    event Sold(address buyer, uint256 amount);
    event FirstUnlock(address buyer, uint256 lockedAmount, uint256 narfexPrice, uint256 unlockedAmount);
    event UnlockTokensToBuyers(address buyer, uint256 amount); //after 60 days
    event AddedToWhitelist(address buyer);
    event Withdraw(address buyer, uint256 amount);

    constructor (
        IBEP20  _narfexContract, 
        IBEP20 _busdAddress,
        address _pairAddress,
        uint256 _minAmountForUser,
        uint256 _maxAmountForUser,
        uint256 _firstNarfexPrice,
        uint256 _firstUnlockSeconds,
        uint256 _percentageUnlockSeconds
        ) {
        
        owner = msg.sender;
        buyers[owner].isWhitelisted = true;
        narfexContract = _narfexContract;
        busdAddress = _busdAddress;
        pairAddress = _pairAddress;
        minAmountForUser = _minAmountForUser;
        maxAmountForUser = _maxAmountForUser;
        firstNarfexPrice = _firstNarfexPrice > 0
            ? _firstNarfexPrice
            : 4 * WAD / 10 ;
        firstUnlockSeconds = _firstUnlockSeconds;
        percentageUnlockSeconds = _percentageUnlockSeconds;
    }

    /// @notice verification of private purchase authorization
    modifier onlyisWhitelisted() {
        require(isWhitelisted(msg.sender), "You are not in whitelist");
        _;
    }

    /// @notice verification of owner
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    /// @notice starting sale with pairAddress of Narfex-BUSD in PancakeSwap
    function startSale(uint256 _toEndSecondsAmount) public onlyOwner {
        saleStartTime = block.timestamp;
        isSaleStarted = true;
        toEndSecondsAmount = _toEndSecondsAmount;
    }

    /// @notice users buy locked tokens by transferring BUSD to this contract 
    /// @param amount Amount of BUSD tokens to deposit in wei (10**18)
    function buyTokens(uint256 amount) public onlyisWhitelisted {
        address _msgSender = msg.sender; 

        require(isSaleStarted, "Sorry, sale not started");
        require(block.timestamp - saleStartTime < toEndSecondsAmount, "Sorry, sale already end");
        require(amount >= minAmountForUser, "Too big deposit");
        require(amount <= maxAmountForUser - buyers[_msgSender].busdDeposit, "Too small deposit");
        uint256 scaledAmount = amount * WAD / firstNarfexPrice;
        require(scaledAmount <= getBalanceNarfex(), "You can not buy more than maximum supply");
        buyers[_msgSender].busdDeposit += amount;
        buyers[_msgSender].narfexAmount += scaledAmount;
        
        busdAddress.transferFrom(_msgSender, address(this), amount);
        emit Sold(_msgSender, scaledAmount);
    }

    /// @notice allows users to withdraw unlocked tokens
    /// @param _amount amount of Narfex tokens to withdraw
    function withdraw(uint256 _amount) public onlyisWhitelisted {
        address _msgSender = msg.sender; // lower gas

        if (_amount == 0 || _amount > buyers[_msgSender].availableBalance) {
            _amount = buyers[_msgSender].availableBalance;
        } 
        
        require(narfexContract.balanceOf(address(this)) >= _amount, "Not enough tokens in contract");
        buyers[_msgSender].availableBalance -= _amount;
        narfexContract.transfer(_msgSender, _amount);
        emit Withdraw (_msgSender, _amount);
    }

    /// @notice allows users to unlock tokens after a certain period of time
    function unlock() public onlyisWhitelisted {
        address _msgSender = msg.sender;
        Buyer storage buyer = buyers[_msgSender];
        require(block.timestamp - saleStartTime > toEndSecondsAmount);

        if (!buyer.isNarfexPayed) {
            // Unlock tokens after 60 days for buyers 
            require (block.timestamp - saleStartTime >= toEndSecondsAmount + firstUnlockSeconds); 
            buyer.isNarfexPayed = true;
            // Apply a new unlock time
            buyer.unlockTime = saleStartTime + toEndSecondsAmount + firstUnlockSeconds;
            // Calculate amount
            uint price = getNarfexBUSDPrice();
            uint unlockAmount = buyer.busdDeposit * WAD / price;
            if (buyer.narfexAmount < unlockAmount) {
                unlockAmount = buyer.narfexAmount;
            }
            emit FirstUnlock(_msgSender, buyer.narfexAmount, price, unlockAmount);
            // Apply a new amount
            buyer.busdDeposit = 0;
            buyer.narfexAmount -= unlockAmount;
            buyer.availableBalance = unlockAmount;
            // Calculate 10% for next withdrawals
            buyer.tenPercents = buyer.narfexAmount / 10;
            emit UnlockTokensToBuyers(_msgSender, unlockAmount);
        } else {
            // Unlock 10% tokens after 120 days for buyers
            require (block.timestamp - buyer.unlockTime >= percentageUnlockSeconds);
            // Apply a new unlock time
            buyer.unlockTime += percentageUnlockSeconds;

            if (buyer.narfexAmount >= buyer.tenPercents) {
                // Apply a new amount
                buyer.narfexAmount -= buyer.tenPercents;
                buyer.availableBalance += buyer.tenPercents;
                emit UnlockTokensToBuyers(_msgSender, buyer.tenPercents);
            }
        }
    }

    /// @notice send from this contract unsold tokens and deposited BUSD tokens to the owner
    function saleEnded() public onlyOwner{
        require(block.timestamp - saleStartTime >= toEndSecondsAmount, "Sorry, sale has not ended yet");
        // Send unsold tokens to the owner
        narfexContract.transfer(owner, getBalanceNarfex());
        // Send BUSD tokens to the owner
        busdAddress.transfer(owner, getBalanceBUSD());
    }

    /// @notice add to whitelist user
    /// @param _address address of user for add to whitelist
    function addWhitelist(address _address) public onlyOwner{
        buyers[_address].isWhitelisted = true;
        emit AddedToWhitelist(_address);
    }

    /// @notice get ratio for pair from Pancake
    /// @return returns ratio
    function getNarfexBUSDPrice() public view returns (uint) {
        PancakePair pair = PancakePair(pairAddress);
        (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast) = pair.getReserves();
        if (address(narfexContract) == pair.token0()) {
            return reserve1 * WAD / reserve0;
        } else {
            return reserve0 * WAD / reserve1;
        }
    }

    /// @notice get amount of BUSD in this contract
    /// @return returns amount of BUSD in this contract
    function getBalanceBUSD() public view returns(uint256){
        return busdAddress.balanceOf(address(this));
    }

    /// @notice get amount of Narfex in this contract
    /// @return returns amount of Narfex in this contract
    function getBalanceNarfex() public view returns(uint256){
        return narfexContract.balanceOf(address(this));
    }

    /// @notice check allowance for user to buy in private sale
    /// @param _address address of user for check allowance
    function isWhitelisted(address _address) public view returns(bool) {
        return buyers[_address].isWhitelisted;
    }

    /// @notice changes owner address for adding in whitelist users
    /// @param _address the address of new owner
    /// @return returns address of new owner
    function changeOwner(address _address) public onlyOwner returns(address){
        owner = _address;
        return owner;
    }

    /// @notice changes unlock period
    /// @param _firstUnlockSeconds unlock period for 100% deposit busd
    /// @param _percentageUnlockSeconds unlock period for 10% of locked balance
    function setUnlockPeriod(uint256 _firstUnlockSeconds, uint256 _percentageUnlockSeconds) public onlyOwner{
        firstUnlockSeconds = _firstUnlockSeconds;
        percentageUnlockSeconds = _percentageUnlockSeconds;
    }

    /// @notice Set the first unlock date
    /// @param _timestamp UNIX timestamp in seconds
    function setFirstUnlockTime(uint256 _timestamp) public onlyOwner {
        firstUnlockSeconds = _timestamp - saleStartTime;
    }

    /// @notice changes price of Narfex in buyTokens function
    /// @param _firstNarfexPrice price of Narfex in buyTokens function
    function setFirstNarfexPrice(uint256 _firstNarfexPrice) public onlyOwner{
        firstNarfexPrice = _firstNarfexPrice;
    }

    /// @notice changes amount of minimum deposit BUSD in buyTokens function
    /// @param _minAmountForUser minimum deposit BUSD in buyTokens function
    function setMinAmountForUser (uint256 _minAmountForUser) public onlyOwner{
        minAmountForUser = _minAmountForUser;
    }

    /// @notice changes amount of maximum deposit BUSD in buyTokens function
    /// @param _maxAmountForUser maximum deposit BUSD in buyTokens function
    function setMaxAmountForUser (uint256 _maxAmountForUser) public onlyOwner{
        maxAmountForUser = _maxAmountForUser;
    }

    /// @notice Returns the timestamp of the next unlock
    /// @param _buyer User address
    /// @return Timestamp in seconds. Will return 0 if there is no locked Narfex amount
    function getNextUnlockTime(address _buyer) public view returns(uint256) {
        Buyer storage buyer = buyers[_buyer];
        if (buyer.isNarfexPayed) {
            // Return time of next percentage unlock
            return buyer.narfexAmount > 0
                ? buyer.unlockTime + percentageUnlockSeconds
                : 0;
        } else {
            // Return time of the first unlock
            return saleStartTime + toEndSecondsAmount + firstUnlockSeconds;
        }
    }

    /// @notice Returns the current available NRFX balance to withdraw
    /// @param _buyer User address
    /// @return NRFX amount
    function getAvailableBalance(address _buyer) public view returns(uint256) {
        return buyers[_buyer].availableBalance;
    }

}