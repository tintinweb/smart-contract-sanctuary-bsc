/**
 *Submitted for verification at BscScan.com on 2022-08-26
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

/// @title Bitscrow Token
/// @author Bitscrow Team

contract BitscrowToken{
    mapping(address => uint256) private _balances; 
    mapping(address => mapping(address => uint256)) private _allowances;
    uint private _totalSupply = 250000000 * 10 ** 18; 
    string private _name = " Bitscrow";
    string private _symbol = "BTSCRW";
    uint private _decimals = 18;
    uint8 private _MAXTXFEE = 5; 
    uint private maxownablepercentage = 2 ;
    uint private maxownableamount;
    uint8 private txFee = 0;
    address private noTaxWallet;
    address private owner;
    address private marketingWallet = 0x023B8F9ee90080d018246E6b885A31d2c8212360; 
    address private TimelockedDevswallett = 0xA873c1970961F627D79A4220Ea7206EdA67ae92F;
    address private timelockedTokensWallet = 0x46F899792C165825E37C511f45C697B024423033; 
    address private stakingWallet = 0x270cAe2462bCbC373c76CFf3C8f49996f14B6AB5; 
    address private dev1 = 0x5f7A951f4eAf51be91b030EF762D84266e992DdA;
    address private dev2 = 0xac0FB773Cea3812961135C2116D59DFd46618698;
    address private dev3 = 0xcf5e78cd852EFb32F96F0aD88Ac5c4d4c51D609B;
    address private dev4 = 0xbF13dD197c2E025262a15268f29163990be40112;
    address private dev5 = 0xE5fe1c3C182Eb80Deab69872582665C628270b52;
    uint private _dateofdeployment;
    uint private lastWithdraw;
    bool private antiwhalenabled;
    bool private buttonEnabled = true;
    uint private declarationEnablingDate;
    uint private lockedFunds;
    uint private unlockedFunds;
    uint private sparedays;
    uint private truevalue;
    uint private truetxfeeT;
    uint private LOCKEDFUNDSDEVS;
    uint private _declartionChangeOwnerDate ;
    address private _declaredAddress;
    uint private RequiredeDaysBeforeChange = 15 days;
    uint private _declartionChangeTaxDate ;
    uint8 private _declaredFee;
    uint private _declartionChangeWarningTimeDate;
    uint private _declartionChangeMaxOwnDate;
    uint private _declaredMaxOwn;
    uint private _declartionChangeMaxTxDate;
    uint private _declaredWarningTime;

    // events
    
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint value);
    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint value);
    /**
     * @dev Emitted when 'value' of tokens ar moved from an account ('burner') to
     * the 0 address
     */
    event Burn(address indexed burner, uint256 value);

    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    //modifiers
    
    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
   
    /* if the antiwhale is enabled ensures 
    that the amount owned by the reciever of the transfer after the transaction
    will not be higher than the maxownablepercentage and that the amount sent 
    is not higher than the maxtxpercentage*/ 
    function antiwhalecheck(address to, uint amount)
    private returns(bool success)
    {
        
        if(antiwhalenabled) {
            maxownableamount = _totalSupply  * maxownablepercentage / 100;
            require(balanceOf(to) + amount <= maxownableamount, "you already own too many token");
        }
        return true;
        
    }

    //ensures that the sender of the transaction isn't the timelockedTokensWallet or the TimelockedDevswallett
    modifier isntlocked{
        require(msg.sender != timelockedTokensWallet);
        require(msg.sender != TimelockedDevswallett);
        _;
    }

    // ensures that the sender of the transaction is the TimelockedTokenswallett
    modifier onlytimelockedwallet{
        require(msg.sender == timelockedTokensWallet);
        _;
    }

    //constructor
    /// @dev split the supply among different wallets, set the _dateofdeployment, the last withdraw and the owner
    constructor() {
        owner = msg.sender;
        _dateofdeployment = block.timestamp;
        // the owner is set to the creator of the contract
        emit OwnerSet(address(0), owner);
        /* 18.4 % of the supply will be sent to the owner, 
        this funds will be entirely used for the presale on pinkswap,
        and for the initial liquidity pool on pancakeswap */
        uint initialownerbalance = 46000000 * 10 **18;
        _balances[owner] = initialownerbalance; 
        emit Transfer(address(0), owner, initialownerbalance );
        /* 5 % of the total supply will be sent to the marketing wallet,
        this funds will be used to pay for the marketing campaings of the token */
        uint initialMarketingWalletBalance = 12500000 * 10 ** 18;
        _balances[marketingWallet] = initialMarketingWalletBalance ; 
        emit Transfer(address(0), marketingWallet, initialMarketingWalletBalance);
        /* 5 % of the total supply will be sent to the staking wallet,
        this funds will be used to pay for the rewards of the staking program, and they will be
        immediatly locked in the staking smart contract */
        uint initialStakingWalletBalance = 12500000 * 10 ** 18;
        _balances[stakingWallet] = initialStakingWalletBalance; 
        emit Transfer(address(0), stakingWallet, initialStakingWalletBalance);
        /* 61.6 % of the total supply will be sent to the timelockedTokensWallet,
        this funds will be released from this wallet at a maximum rate of 1% of 
        the initial timelockedTokensWallet balance */
        lockedFunds = 154000000 * 10 ** 18 ; 
        _balances[timelockedTokensWallet] = lockedFunds;
        emit Transfer(address(0), timelockedTokensWallet, lockedFunds);
        /* 10 % of the total supply will be sent to the  TimelockedDevswallet,
        this funds will be unlocked after one year since the date of deployment and 
        they will be used to pay the five initial developers of the bitscrow ecosystem  */
        LOCKEDFUNDSDEVS = 25000000 * 10 ** 18;
        _balances[TimelockedDevswallett] = LOCKEDFUNDSDEVS;
        emit Transfer(address(0), TimelockedDevswallett, LOCKEDFUNDSDEVS);
        lastWithdraw = _dateofdeployment;
    }
    
        /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     * Emits an {Approval} event.
     */
    function approve(address spender, uint value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }
    

    /** @notice this function has the isntlocked modifiers since the timelockedTokensWallet 
     *and the TimelockedDevswallett are not allowed to use this function 
     */
    function transfer(address to, uint256 amount) public isntlocked returns (bool) {
        
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    /** @notice the timelockedTokensWallet and the TimelockedDevswallett are 
     * not allowed to use this function 
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  returns (bool) {
        require(from != timelockedTokensWallet);
        require(from != TimelockedDevswallett);
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    /** @dev sends 2% of the supply to each developer, this function can only beused one time 
     * and only one year after the deployment
     */
    function UnlockDevsFunds()public isOwner returns(bool success){
        require(msg.sender == TimelockedDevswallett);
        require(block.timestamp - _dateofdeployment >= 365 days );
        uint singleDevAmount = LOCKEDFUNDSDEVS * 2 / 100;
        transferNoTax(msg.sender, dev1, singleDevAmount);
        transferNoTax(msg.sender, dev2, singleDevAmount);
        transferNoTax(msg.sender, dev3, singleDevAmount);
        transferNoTax(msg.sender, dev4, singleDevAmount);
        transferNoTax(msg.sender, dev5, singleDevAmount);
        LOCKEDFUNDSDEVS = 0;
        return true;

        
    }
    
    /** @dev allows the timelockedwallet to send a max of 0,616 of the total supply 
     *to an address each month, until the lockedfunds are finished
    */
    function withdrawlockedfunds(uint amount, address reciever) public onlytimelockedwallet returns(bool success){
        if(block.timestamp - lastWithdraw + sparedays >= 30 days ) {
            sparedays = block.timestamp - lastWithdraw + sparedays - (30 days) ;
            if(lockedFunds >= 1540000 * 10 **18){
                lockedFunds -= 1540000 * 10 **18;
                unlockedFunds += 1540000 * 10 **18;
            }else{
                unlockedFunds += lockedFunds;
                lockedFunds = 0;
            }
            
            lastWithdraw = block.timestamp;
            
        }
        require(amount <= unlockedFunds, "you haven't unlocked this many funds yet");
        require(reciever != address(0));
        unlockedFunds -= amount;
        _balances[msg.sender] -= amount;
        _balances[reciever] += amount;
        emit Transfer(msg.sender, reciever, amount);

        return true;


    }



    //change variables

    function declareEnableAntiwhaleButton() public isOwner returns(bool success) {
        declarationEnablingDate = block.timestamp;
        return true;
    }
    
    /** @dev  allows the owner to enable the antiwhale button so, to enable it the owner has to 
     * first declare it and then wait until the ('RequiredeDaysBeforeChange') have passed to actually
     * enable it, when the buttonEnabled is true the owner can turn on and off the antiwhale
    */
    function enableAntiwhaleButton(bool enable) public isOwner returns(bool success) {
        if(enable == true) {
            require(declarationEnablingDate != 0);
            require(block.timestamp - declarationEnablingDate > RequiredeDaysBeforeChange);
            buttonEnabled = enable;
            declarationEnablingDate = 0;

        }else {
            buttonEnabled = enable;
        }
        return true;
    }

    function enableantiwhale(bool enable) public isOwner returns(bool success){
        require(buttonEnabled == true);
        antiwhalenabled = enable;
        return true;
    }

    
    
    /** @dev this function is used to  warn the users that the owner of the contract is going to change, and give
     *them time (RequiredeDaysBeforeChange) to decide what to do.
     *to change owner the current owner has to declare the new owner and then wait until 
     *the RequiredeDaysBeforeChange have passed to change owner.  
     */
    /// @param newOwner The address of the new owner
    function declareOwnerChange(address newOwner)public isOwner returns(bool success){
        require(newOwner != address(0));
        _declartionChangeOwnerDate = block.timestamp;
        _declaredAddress = newOwner;
        return true;
    }

    /// @notice allows the current owner to tranfer ownership
    /// @dev available ony if RequiredeDaysBeforeChange have passed
    function changeOwner() public isOwner returns(bool success) {
        require(_declartionChangeOwnerDate != 0);
        require(block.timestamp - _declartionChangeOwnerDate > RequiredeDaysBeforeChange);
        emit OwnerSet(owner, _declaredAddress);
        owner = _declaredAddress;
        return true;
    }

    /// @dev set txfee to 0%
    function excludeTransfeFee() public isOwner returns(bool success) {
        txFee = 0;
        return true;
    } 
    
    /** @dev this function is used to  warn the users that the maximum ownable percentage ('mmaxownablepercentage')
     * of the contract is going to change, and give
     *them time ('RequiredeDaysBeforeChange') to decide what to do.
     *to change the maximum ownable percentage the current owner has to declare the new percentage and then wait until 
     *the ('RequiredeDaysBeforeChange') have passed to actually change it.  
     */
    /// @param newMaxOwn The new percentge
    function declareMaxOwnChange(uint newMaxOwn)public isOwner returns(bool success){
        
        _declartionChangeMaxOwnDate = block.timestamp;
        _declaredMaxOwn = newMaxOwn;
        
        return true;
    }
    /// @notice allows the current owner to change the maximum ownable percentage 
    /// @dev available ony if RequiredeDaysBeforeChange have passed since the date of declaration
    function setMaxOwnablePerentage() isOwner public returns(bool) {
        require(_declartionChangeMaxOwnDate != 0);
        require(block.timestamp - _declartionChangeMaxOwnDate > RequiredeDaysBeforeChange);
        maxownablepercentage = _declaredMaxOwn;

        return true;
    }

    function ChangeNoTaxAddress(address newWallet) public isOwner returns(bool) {
        require(msg.sender == owner, "you have to be the owner to change the no tax address");
        noTaxWallet = newWallet;

        return true;
    }



    /** @dev  this function is used to warn the users that the TxFees of the token are going to change, and give
     * them time (RequiredeDaysBeforeChange) to decide what to do.
     * to change txFees the current owner has to declare the new txFees and then wait until 
     * the RequiredeDaysBeforeChange have passed to actually change them.  
    */
    /// @param newTxFee new transaction fee, must be lower than _MAXTXFEE
    function declareTaxChange(uint8 newTxFee)public isOwner returns(bool success){
        require(newTxFee <= _MAXTXFEE);
        _declartionChangeTaxDate = block.timestamp;
        _declaredFee = newTxFee;
        
        return true;
    }

    function ChangeTxFees()public isOwner returns(bool) {
        require(_declartionChangeTaxDate != 0);
        require(block.timestamp - _declartionChangeTaxDate > RequiredeDaysBeforeChange);
        txFee = _declaredFee;
        return true;
    }
    
    /** @dev  this function is used to warn the users that the warnig time is going to change, and give
     * them time (RequiredeDaysBeforeChange * 2) to decide what to do.
     * to change the warning time the current owner has to declare the new txFees and then wait until 
     * the RequiredeDaysBeforeChange have passed to actually change it.  
    */
    /// @param newWarningTime the new warning time
    function declareNewWarningTime(uint newWarningTime)public isOwner returns(bool success){
        _declartionChangeWarningTimeDate = block.timestamp;
        _declaredWarningTime = newWarningTime;
        return true;
    }
    
    /// @dev ensures that double the time of ('RequiredeDaysBeforeChange') has passed since the declaration
    function changeWarningTime()public isOwner returns(bool success) {
        require(_declartionChangeWarningTimeDate != 0);
        require(block.timestamp - _declartionChangeWarningTimeDate > (RequiredeDaysBeforeChange * 2));
        RequiredeDaysBeforeChange = _declaredWarningTime;
        return true;
    }
    
    
    /// @dev Returns the name of the token 
    function name() public view returns (string memory) {
        return _name;
    }

    /// @dev Returns the Symbol of the token
    function symbol() public view   returns (string memory) {
        return _symbol;
    }

    /// @dev Returns the decimals of the token
    function decimals() public pure  returns (uint8) {
        return 18;
    }
    
    /// @dev Returns the Total Supply of the token
    function totalSupply() public view   returns (uint256) {
        return _totalSupply;
    }
    
    /// @dev Returns the date of deployment
    function dateofdeployment() public view   returns (uint256) {
        return _dateofdeployment;
    }

    /// @dev Returns the declared warning time 
    function declaredWarningTime() public view returns(uint256){
        return _declaredWarningTime;
    }

    /// @dev Returns the current warning time 
    function WarningTime() public view   returns (uint256) {
        return RequiredeDaysBeforeChange;
    }

    /// @dev Returns the current locked amount 
    function SeeLockedFunds() public view returns(uint256){
        return lockedFunds;
    }
    
    /// @dev Returns the amount that is currently available to withdraw from {withdrawlockedfunds}
    function SeeUnLockedFunds() public view returns(uint256){
        return unlockedFunds;
    }
    
    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address ownr, address spender) public view  returns (uint256) {
        return _allowances[ownr][spender];
    }

    /// @dev Returns the current owner of the contract
    function getOwner() public view returns (address) {
        return owner;
    }

    /// @dev Returns the amount of tokens owned by `account`.
    function balanceOf(address Address) public view returns(uint) {
        return _balances[Address];
    }
    
    /// @dev Returns the timestamp of the declaration of the owner transfer 
    function declartionChangeOwnerDate() public view returns(uint256){
        return _declartionChangeOwnerDate;
    }

    function declaredAddress() public view returns(address){
        return _declaredAddress;
    }

    function declartionChangeTaxDate() public view returns(uint){
        return _declartionChangeTaxDate;
    }

    function declaredFee() public view returns(uint8){
        return _declaredFee;
    }

    function currentTxFee() public view returns(uint8){
        return txFee;
    }

    function seeLastWithdraw() public view returns(uint){
        return lastWithdraw;
    }

    function isAntiwhaleEnabled() public view returns(bool){
        return antiwhalenabled;
    }

    function isButtonEnabled() public view returns(bool){
        return buttonEnabled;
    }

    function declartionChangeMaxOwnDate() public view returns(uint){
        return _declartionChangeMaxOwnDate;
    }

    function declaredMaxOwn() public view returns(uint){
        return _declaredMaxOwn;
    }

    function seemaxownablepercentage() public view returns(uint){
        return maxownablepercentage;
    }

    function seeSparedays() public view returns(uint){
        return sparedays;
    }


    //transfers

    function transferNoTax(address from, address to, uint value) private returns(bool){
        _balances[to] += value;
        _balances[from] -= value;
        emit Transfer(msg.sender, to, value);
        return true;   
    }

    function transferPaid(address to, uint value) private{
        _balances[to] += value;
       
        
        emit Transfer(msg.sender, to, value);
       

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private  {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if(txFee > 0){
            require(amount >= 100);
        }
        
        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        antiwhalecheck(to, amount);
        if (from == noTaxWallet || from == owner) {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }else {
            truetxfeeT = 0;
            if(txFee > 0){
                truetxfeeT  = amount * txFee  / 100;
                transferPaid(marketingWallet, truetxfeeT);
            }
            
            truevalue = (amount - truetxfeeT);
            _balances[to] += truevalue;
            _balances[from] -= amount;
            
            emit Transfer(from, to, truevalue);

        }    
    }
    

    function _spendAllowance(
        address ownr,
        address spender,
        uint256 amount
    ) private {
        uint256 currentAllowance = allowance(ownr, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(ownr, spender, currentAllowance - amount);
            }
        }
    }

    function _approve(
        address ownr,
        address spender,
        uint256 amount
    ) private {
        require(ownr != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownr][spender] = amount;
        emit Approval(ownr, spender, amount);
    }

    function transferToHolder(address to, uint value) private {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        _balances[to] += value;
        _balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }

    //burn

    function burn (uint256 _value) public  isntlocked returns(bool success) {
        require(msg.sender == owner, "you have to be the owner to burn");
        
        require(balanceOf(msg.sender) >= _value);
        _balances[msg.sender] -= _value;
        _totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns(bool success) {
        require(msg.sender == owner, "you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= _allowances[_from][msg.sender]);
        
        _balances[_from] -= _value;
        _totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }  
}