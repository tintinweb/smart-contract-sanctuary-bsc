/**
 *Submitted for verification at BscScan.com on 2022-09-11
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
    uint8 private _decimals = 18;
    uint8 private _MAXTXFEE = 5; 
    uint8 private txFee;
    address private noTaxWallet;
    address private owner;
    address private marketingWallet = 0x60d015cE6Ff68cD961925EdC5C8DAF43ecE14eff; 
    address private TimelockedDevswallett = 0x77C9678d07B6c36D0451d62048a59eEb7aF32243;
    address private timelockedTokensWallet = 0xE21370a228F5Fb4EE952874b0401bbeD11E63283; 
    address private stakingWallet = 0x7D17620E05c09A037CE724d884B152a7C8128aE6; 
    address private dev1 = 0x5f7A951f4eAf51be91b030EF762D84266e992DdA;
    address private dev2 = 0xac0FB773Cea3812961135C2116D59DFd46618698;
    address private dev3 = 0xcf5e78cd852EFb32F96F0aD88Ac5c4d4c51D609B;
    uint private lockedFunds;
    uint private truevalue;
    uint private truetxfeeT;
    uint private LOCKEDFUNDSDEVS;
    uint private _declartionChangeOwnerDate ;
    address private _declaredAddress;
    uint private RequiredeDaysBeforeChange = 15 days;
    uint private _declartionChangeTaxDate ;
    uint8 private _declaredFee;
    uint private _declartionChangeWarningTimeDate;
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
    
    // modifier to check if caller is owner
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    //constructor
    /// @dev split the supply among different wallets, set the _dateofdeployment, the last withdraw and the owner
    constructor() {
        owner = msg.sender;
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
    
    

    function transfer(address to, uint256 amount) public  returns (bool) {
        
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function burn (uint256 _value) public  returns(bool success) {
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

    /** @dev sends 1/3 of the LOCKEDFUNDSDEVS to each developer, this function can only be used 
     *  only one year after the deployment, (this funds are locked for one year using pinklock)
     */
    function DistributeDevsFunds()public  returns(bool success){
        require(msg.sender == TimelockedDevswallett);
        require(balanceOf(TimelockedDevswallett) == LOCKEDFUNDSDEVS);
        uint singleDevAmount = LOCKEDFUNDSDEVS  / 3 ;
        transferNoTax(msg.sender, dev1, singleDevAmount);
        transferNoTax(msg.sender, dev2, singleDevAmount);
        transferNoTax(msg.sender, dev3, singleDevAmount);

        LOCKEDFUNDSDEVS = 0;
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
  
    /// @dev Returns the declared warning time 
    function declaredWarningTime() public view returns(uint256){
        return _declaredWarningTime;
    }

    /// @dev Returns the current warning time 
    function WarningTime() public view   returns (uint256) {
        return RequiredeDaysBeforeChange;
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


    //transfers

    function transferNoTax(address from, address to, uint value) private returns(bool){
        require(balanceOf(from) >= value);
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
        
        if (from == noTaxWallet || from == owner) {
            transferNoTax(from, to, amount);
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


}