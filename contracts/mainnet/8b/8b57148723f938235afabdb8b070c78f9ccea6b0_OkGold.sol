/**
 *Submitted for verification at BscScan.com on 2023-02-14
*/

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

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
    ) external returns (bool);
}

// File: contracts/OkGold.sol


/* // Creator: Organik Labs 2022 Organik, Inc.
 ██████  ██████   ██████   █████  ███    ██ ██ ██   ██ 
██    ██ ██   ██ ██       ██   ██ ████   ██ ██ ██  ██  
██    ██ ██████  ██   ███ ███████ ██ ██  ██ ██ █████   
██    ██ ██   ██ ██    ██ ██   ██ ██  ██ ██ ██ ██  ██  
 ██████  ██   ██  ██████  ██   ██ ██   ████ ██ ██   ██ 
// Public Vault (Manage different types of Vaults to send or receive money).
// a. Everyone should have a personal Vault (No ID, Not transferable).
// b. Private Vaults can be built (with ID) these vaults are transferable.
// c. Group Vaults can be managed by multiple owners.
// d. Switch for AutoPayment. (Vaults mirror the payment in real time).
// Future: ERC-20 Tokens should be compatible with Vaults. At least allow them to be withdrawn by OWNER.
// LEDGER TYPES.
// 0 -> Genesis, deposit on vault creation. (Deposit)
// 1 -> Deposit from owner * (Deposit)
// 2 -> Deposit from member * (Deposit)
// 3 -> Deposit from External * (Payment)
// 4 -> Deposit from Vault * (Transfer)
// 5 -> Deposit from Personal Account * (Transfer)
// 6 -> Payout to Owner (Withdraw)
// 7 -> Payout to Member (Withdraw)
// 8 -> Payout to External (Broadcast)
// 9 -> Payout to Vault (Transfer)
// 10 -> Payout to Personal Account **** (Check if this is needed or how would it work) (Transfer) *****
// 11 -> A Full Withdrawal and Vault Closure. (Withdraw)
*/ // OKGold v1 (November 2022)
pragma solidity ^0.8.17;


contract OkGold {
    
    uint32 private version = 1000000001; // Version 1.0.0.1
    address private contractOwner;
        
    uint256 private contractBalance;
    uint256 private stackedBalance;
    uint256 private membersBalance;
    uint256 private totalVaultCount;
    uint256 private totalLedgerCount;
    
    string private name = "OK.GOLD v1.0.0.1";

    mapping (address => uint256) private balanceOf;
    mapping (address => uint256) private balanceOfMember;
    mapping (uint256 => bool)    private vaultLock;
    mapping (uint256 => bool)    private closedVault;

    mapping (address => mapping(uint256 => uint256)) private myVaultsMap;
    mapping (uint256 => mapping(address => bool)) private membersByVault;
    mapping (address => mapping(uint256 => uint256)) private memberIndexByVault;

    mapping (uint256 => Vault)   private vaults;
    mapping (address => uint256) private myVaultsCount;
    mapping (address => mapping(uint256 => PrivVault)) private privVaultMap;
    mapping (address => uint256) private myPVCount;

    struct PrivVault {
        uint256 amount;
        bool withdraw;
    }

    struct VaultWrapper {
        VaultDetails vault;
        bool closed;
        uint256 native;
        uint256 priv;
        uint256 v;
    }

    struct Settings {
        string name;
        bool isContractOwner;
        ProofOfFunds proof;
        uint256 nativeBalance;
        uint256 privateBalance;
        Vault[] myVaults;
        PrivVault[] records;
        uint256 version;
    }

    struct ProofOfFunds {
        uint256 balance;
        uint256 vaults;
        uint256 members;
    }

    struct VaultDetails {
        Vault   vault;
        bool owner;
        bool member;
    }

    // Vault to keep all of our money.
    struct Vault {
        uint256 id;
        string name;
        string title;
        uint256 created;
        uint256 balance;
        Ledger[] records;
        uint256 recordsCount;
        Member[] members;
        uint256 membersCount;
        address payable creator;
        address payable owner;
        bool verified;
    }
    // Store all records of transactions between Vaults or Members
    struct Ledger {
        uint256 id;
        string ref;
        uint256 amount;
        uint256 stamp;
        uint8 typeOf;
        address payable creator;
        address payable receiver;
        uint256 vaultTo;
        uint256 vaultFrom;
        bool positive;
    }
    // Store all Members of Vaults, including the Vault ID for each Member.
    struct Member {
        uint256 vault;
        uint256 stamp;
        address payable handler;
        address payable addedBy;
        bool active;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }
    
    modifier isVaultOpen(uint256 _vault){
        require(closedVault[_vault] == false, "X0");
        _;
    }

    modifier fundsSent(uint256 _vault){
        require(_vault <= totalVaultCount && !closedVault[_vault] && msg.value >= 1, "X1" );
        _;
    }

    /// @notice The requested withdrawal amount must be available in the contract balance
    modifier withMinBalance(uint256 amount) {
        require(address(this).balance >= amount);
        _;
    }

    modifier zeroBalance(){
        require(address(this).balance >= 0, "ZERO-BALANCE");
        _;
    }

    modifier transferCheck(address _to)
    {
        require( _to != contractOwner && _to != address(0), "X9" );
        _;
    }

    modifier safeDelegate(uint256 _vault, address _owner){
        require(address(_owner) != address(vaults[_vault].owner) && address(_owner) != address(0), "SAFE-DEL");
        _;
    }

    modifier vaultOwner(uint256 _vault){
        require( address(msg.sender) == address(vaults[_vault].owner), "NO-ACCESS");
        _;
    }

    modifier isMember(uint256 _vault){
        require( membersByVault[_vault][msg.sender] == true, "MEMBERS-ONLY");
        _;
    }

    event NewVault(address indexed from, uint256 id);
    event  Deposit(address indexed from, uint256 indexed vault, uint256 id);
    event Transfer(address indexed from, uint256 id);

    constructor (){
        contractOwner = msg.sender;
    }

    /// @notice Allow deposits from anyone
    fallback() external payable {}

    receive() external payable {}
    
    function getPVLedger()
    private view
    returns (PrivVault[] memory)
    {
        PrivVault[] memory records = new PrivVault[](myPVCount[msg.sender]);
        for (uint256 index = 0; index < myPVCount[msg.sender]; index++) {
            records[index] = privVaultMap[msg.sender][index];
        }
        return records;
    }

    function verify(uint256 _vault, bool _bool, string memory _title, string memory _name)
    external payable
    onlyOwner()
    {
        if(vaults[_vault].id == _vault){
            Vault storage vault = vaults[_vault];
            vault.verified = bool(_bool);
            vault.title = _title;
            vault.name = _name;
        }
        // vault.name = _name;
    }
    
    function readContractSettings()
    external view
    returns(Settings memory)
    {
        return (Settings(
            name,
            // contractOwner,
            bool(contractOwner == msg.sender),
            ProofOfFunds(getBalance(), stackedBalance, membersBalance),
            // getBalance(),
            // stackedBalance,
            // membersBalance,
            address(msg.sender).balance,
            balanceOfMember[msg.sender],
            // myTxsCount[msg.sender],
            // myVaultsCount[msg.sender],
            listVaults(),
            getPVLedger(),
            version
            ));
    }

    function ledger(uint256 _vault, uint256 _total, Ledger[] memory _ledger)
    external payable
    isMember(_vault)
    {
        vaultLockUnlock(_vault, true);
        // Make a payment and get it on the ledger.
        // This should NOT be similar to a DEPOSIT.
        // Only for Payments. (Money moves from the Vault into an External Vault/Member/Wallet)
        // Check if msg.sender is Owner or Member (Done by Modifier)
        bool txReceipt;
        // FROM: (Owner or Members)
        // TO:
        // Owner (Full/Partial Withdraw)
        // Member (Transfer to Member Wallet)
        // External (Transfer to Other Vaults/Wallets)

        Vault storage vault = vaults[_vault];
        Ledger[] memory ledgers = new Ledger[](_total);

        for (uint256 index = 0; index < _total; index++) {
            txReceipt = false;
            ledgers[index]    = _ledger[index];
            ledgers[index].positive = false;
            ledgers[index].id = totalLedgerCount;
            ledgers[index].stamp = block.timestamp;
            ledgers[index].creator = payable(msg.sender);
            // Perform LEDGER action.
            if(ledgers[index].typeOf == 6){
                // Transfer to Owner.
                txReceipt = safeTransferTx(vault.balance, ledgers[index].amount, vault.owner);
            }
            else if(ledgers[index].typeOf == 7){
                // Transfer to Member.
                if(membersByVault[_vault][ledgers[index].receiver]){
                    txReceipt = safeTransferTx(vault.balance, ledgers[index].amount, ledgers[index].receiver);
                }
            }
            else if(ledgers[index].typeOf == 8){
                // Transfer to External.
                // Check for Stacked Balance (From Vault to Wallet)
                txReceipt = safeTransferTx(vault.balance, ledgers[index].amount, ledgers[index].receiver);
            }
            else if(ledgers[index].typeOf == 9){
                // Transfer to another Vault.
                txReceipt = safeTransferVaultTx(vault.balance, ledgers[index].amount, _vault, ledgers[index].vaultTo);
            }
            else if(ledgers[index].typeOf == 10){
                // Transfer to Personal Account.
                txReceipt = safeTransferPersonalTx(vault.balance, ledgers[index].amount, _vault, ledgers[index].receiver);
            }
            else if(ledgers[index].typeOf == 11){
                // Vault OMEGA. Closure and Full Withdrawal.
                // Do not perform further actions if this is found.
                txReceipt = safeTransferTx(vault.balance, vault.balance, msg.sender);
                if(txReceipt){
                    index = _total; // This should break the FOR loop.
                    closedVault[_vault] = true;
                }
            }
            if(txReceipt){
                // Update Balance (V2V Tx : type 9 && type 10 : balance already updated). 
                if(ledgers[index].typeOf < 9){
                    vault.balance  -= ledgers[index].amount;
                    stackBalance(ledgers[index].amount, false);
                }
                vault.records.push(ledgers[index]);
                vault.recordsCount += 1;
                // emit Transfer(msg.sender, totalLedgerCount);
                totalLedgerCount++;
            }
        }
        updateContractBalance();
        vaultLockUnlock(_vault, false);
    }

    function deposit(bool _self, uint256 _vault, Ledger memory _ledger)
    external payable
    fundsSent(_vault)
    {
        // Deposit in SELF or Vault.
        bool txReceipt;
        if(_self){
            // Deposit on PV 
            balanceOfMember[msg.sender] += msg.value;
            membersBalance += msg.value;
            privLedger(msg.value, false);
        }else{
            // require(_ledger.typeOf >= 1 && _ledger.typeOf <= 5, "WRONG-TYPE");
            vaultLockUnlock(_vault, true);

            Vault storage vault = vaults[_vault];

            if( ( _ledger.typeOf == 1 && address(vault.owner) == address(msg.sender) ) || (_ledger.typeOf == 2 && membersByVault[_vault][msg.sender]) || (_ledger.typeOf >= 3 && _ledger.typeOf <= 5) ){
                // 1 -> Deposit from owner
                // 2 -> Deposit from member * (Deposit)
                // 3 -> Deposit from External * (Payment)
                // 4 -> Deposit from Vault * (Transfer)
                // 5 -> Deposit from Personal Account * (Transfer)
                _ledger.positive = true;
                _ledger.id = totalLedgerCount;
                _ledger.creator  = payable(msg.sender);
                _ledger.receiver = payable(0);
                _ledger.vaultTo = _vault;
                _ledger.stamp = block.timestamp;
                _ledger.amount = msg.value;
                // Move Funds.
                if(_ledger.typeOf ==  5){  // if(_ledger.typeOf < 4 && _ledger.typeOf != 5){ // Updated (Nov 16th)
                    txReceipt = safeDepositPersonalTx(balanceOfMember[msg.sender], _ledger.amount, _vault);
                    // From Vault to Personal
                }else if(_ledger.typeOf == 4){
                    // This is wrong, balance should be from external Vault (From). Nov 16th.
                    // txReceipt = safeTransferVaultTx(vault.balance, _ledger.amount, _ledger.vaultFrom, _vault);
                    txReceipt = safeTransferVaultTx(vaults[_ledger.vaultFrom].balance, _ledger.amount, _ledger.vaultFrom, _vault);
                }else{
                    _ledger.vaultFrom = 0;
                    stackBalance(_ledger.amount, true);
                    vault.balance += _ledger.amount;
                }
                vault.records.push(_ledger);
                vault.recordsCount += 1; // Added Nov 16th.
                // emit Deposit(msg.sender, _vault, totalLedgerCount);
                totalLedgerCount++;
            }
            vaultLockUnlock(_vault, false);
        }
        updateContractBalance();
    }

    function createVault(string memory _name)
    external payable
    {
        // Create a new Vault
        uint256 nextVaultId = totalVaultCount;

        Vault storage vault = vaults[totalVaultCount];
        vault.id   = nextVaultId;
        vault.name = _name;
        vault.created = block.timestamp;

        membersByVault[nextVaultId][msg.sender] = true;
        memberIndexByVault[msg.sender][nextVaultId] = 0;

        vault.members.push(Member(nextVaultId, block.timestamp, payable(msg.sender), payable(0), true));

        if(msg.value >= 1){
            vault.records.push(Ledger(
                totalLedgerCount,
                "", 
                msg.value, 
                block.timestamp, 
                uint8(0), 
                payable(msg.sender),
                payable(0),
                nextVaultId, 
                uint256(0), 
                true
                ));

            totalLedgerCount++;
            vault.recordsCount = 1;
            vault.balance = msg.value;
            stackBalance(msg.value, true);
        }

        vault.membersCount = 1;

        vault.creator = payable(msg.sender);
        vault.owner   = payable(msg.sender);

        myVaultsMap[msg.sender][myVaultsCount[msg.sender]] = nextVaultId;
        myVaultsCount[msg.sender]++;
        totalVaultCount++;
        // emit NewVault(msg.sender, nextVaultId);
        updateContractBalance();
    }

    function readVault(uint256 _vault) 
    public view
    // isVaultOpen(_vault)
    // returns(VaultWrapper memory)
    returns(VaultDetails memory, bool, uint256, uint256, uint256)
    {
        // Do not allow access to Vault if it doesn't exist
        // require( _vault == vaults[_vault].id, "E-4" ); // Added Nov 16th.
        // if(closedVault[_vault] == false){
        bool isVaultOwner = bool(msg.sender == vaults[_vault].owner);
        bool isVaultMember = bool(membersByVault[_vault][msg.sender]);
        
        Vault memory vault = vaults[_vault];
        
        if(!isVaultMember){
            vault.balance = 0;
            vault.records = new Ledger[](1);
            vault.recordsCount = 0; // Added Nov 16th
        }
        return (
            VaultDetails(vault, isVaultOwner, isVaultMember),
            closedVault[_vault],
            address(msg.sender).balance,
            balanceOfMember[msg.sender],
            version);
        /**!/
        return VaultWrapper(
            VaultDetails(vault, isVaultOwner, isVaultMember),
            closedVault[_vault],
            address(msg.sender).balance,
            balanceOfMember[msg.sender],
            version);
        /**/
    }

    function privLedger(uint256 _amount, bool _withdraw)
    private
    {
        privVaultMap[msg.sender][myPVCount[msg.sender]] = PrivVault(_amount, _withdraw);
        myPVCount[msg.sender] += 1;
    }

    function openVault(uint256 _amount, address _to)
    public
    {
        // Withdraw from a SelfVault (Personal Account)
        require(balanceOfMember[msg.sender] >= _amount, "E-5");
        uint amount;
        address to;
        if( address(_to) == address(0) ){
            to = msg.sender;
        }else{
            to = _to;
        }
        if(_amount >= 1){
            amount = _amount;
            balanceOfMember[msg.sender] -= _amount;
        }else{
            amount = balanceOfMember[msg.sender];
            balanceOfMember[msg.sender] = 0;
        }
        membersBalance -= amount;
        updateContractBalance();
        payable(to).transfer(amount);
        privLedger(amount, true);
        // Should we LOCK Personal Accounts too?
    }
    
    /**!/
    function destroyVault() public {
        // Withdraw ALL from a Vault
        // PENDING ** ???
    }
    /**/

    function delegateVault(uint256 _vault, address _owner)
    public
    vaultOwner(_vault)
    safeDelegate(_vault, _owner)
    {
        // Transfer ownership of this Vault to another account (From Vault owner to a Member)
        Vault storage vault = vaults[_vault];
        vault.owner = payable(_owner);
        membersByVault[_vault][_owner] = true;
        // We need to add this Vault into the list of "MyVaults" to display them on Home.
        // myVaultsMap[msg.sender][myVaultsCount[msg.sender]] = _vault;
        // myVaultsCount[msg.sender]++;
    }

    function updateVaultMembers(uint256 _vault, uint256 _total, Member[] memory _members, bool[] memory _add)
    public
    vaultOwner(_vault)
    {
        // Add or Remove Vault Members. // Only the Vault owner can do this.
        vaultLockUnlock(_vault, true);
        if(membersByVault[_vault][msg.sender]){ // This IF might not be necessary.
            for (uint256 index = 0; index < _total; index++) {
                if(_add[index]){
                    // Add into Members list
                    if(membersByVault[_vault][_members[index].handler] == false){
                        membersByVault[_vault][_members[index].handler] = true;
                        Vault storage vault = vaults[_vault];
                        if(_members[index].handler == vault.members[memberIndexByVault[_members[index].handler][_vault]].handler){
                            vault.members[memberIndexByVault[_members[index].handler][_vault]].active = true;
                        }else{
                            vault.members.push(Member(_vault, block.timestamp, payable(_members[index].handler), payable(msg.sender), true));
                            memberIndexByVault[_members[index].handler][_vault] = vault.membersCount;
                        }
                        vault.membersCount += 1;
                    }
                }else{
                    // Remove from Members list
                    if(membersByVault[_vault][_members[index].handler] == true){
                        membersByVault[_vault][_members[index].handler] = false;
                        Vault storage vault = vaults[_vault];
                        vault.members[memberIndexByVault[_members[index].handler][_vault]].active = false;
                        vault.membersCount -= 1;
                    }
                }
            }
        }
        vaultLockUnlock(_vault, false);
    }

    /// @notice Full Contract withdrawal
    function withdraw()
    external
    onlyOwner
    {
        // contractBalance = Balance which is not part of any of the Vaults.
        // payable(msg.sender).transfer(address(this).balance); // This is WRONG.
        payable(msg.sender).transfer(contractBalance);
        contractBalance = 0;
    }
    
    /// @notice Partial Contract withdrawal
    /// @param _amount Amount requested for withdrawal
    function withdraw(uint256 _amount, address _to)
    external
    onlyOwner
    withMinBalance(_amount)
    {
        require(_amount <= contractBalance, "E-6");
        address payable to     = payable(msg.sender);
        if( _to != address(0) ){
            to = payable(_to);
        }
        to.transfer(_amount);
        contractBalance -= _amount;
    }

    function withdrawERC20(address _tokenContract, uint256 _amount, address _to)
    external
    zeroBalance
    onlyOwner
    {
        require( address(this) != _tokenContract, "E-7" );
        address payable to     = payable(msg.sender);
        // Withdraw any other Tokens that might have been sent to ie: ETH* APE, LPT, MATIC.
        uint256 balance = IERC20(_tokenContract).balanceOf(address(this));
        if(balance > 0 && _amount <= balance){
            if( address(_to) != address(0) ){
                to = payable(_to);
            }
            if(_amount >= 1){
                IERC20(_tokenContract).transfer(to, _amount);
            }else{
                IERC20(_tokenContract).transfer(to, balance);
            }
        }
    }

    function transferContract(address _newOwner)
    external
    onlyOwner
    transferCheck(_newOwner)
    {
        contractOwner = _newOwner;
    }

    function getBalance()
    public view
    returns(uint) {
        return address(this).balance;
    }

    function updateContractBalance()
    private
    {
        contractBalance = getBalance() - stackedBalance - membersBalance;
    }


    function safeTransferTx(uint256 _balance, uint256 _amount, address _to)
    private
    returns(bool){
        if(_balance >= _amount && stackedBalance >= _amount){
        // Check if StackedBalance has enough. // Updated Nov 16th.
        // if(_balance >= _amount){
            payable(_to).transfer(_amount);
            return true;
        }
        return false;
    }
    
    function safeTransferPersonalTx(uint256 _balance, uint256 _amount, uint256 _vault, address _to)
    private
    returns(bool){
        if(_balance >= _amount){
            Vault storage vaultFrom = vaults[_vault];
            balanceOfMember[_to] += _amount;
            membersBalance += _amount;
            vaultFrom.balance -= _amount;
            stackBalance(_amount, false);
            return true;
        }
        return false;
    }

    function safeDepositPersonalTx(uint256 _balance, uint256 _amount, uint256 _vault)
    private
    returns(bool){
        if(_balance >= _amount){
            Vault storage vaultTo = vaults[_vault];
            balanceOfMember[msg.sender] -= _amount;
            membersBalance -= _amount;
            vaultTo.balance += _amount;
            stackBalance(_amount, true);
            return true;
        }
        return false;
    }

    function safeTransferVaultTx(uint256 _balance, uint256 _amount, uint256 _from, uint256 _to)
    private
    returns(bool){
        if(_balance >= _amount && _from != _to){
            Vault storage vaultTo   = vaults[_to];
            vaultTo.records.push(Ledger(
                totalLedgerCount,
                "", // No Ref on Cross-Ledger
                _amount,
                block.timestamp, 
                uint8(0), 
                payable(msg.sender),
                payable(0),
                _from,
                _to,
                true
            ));
            vaultTo.recordsCount += 1;
            Vault storage vaultFrom = vaults[_from];
            vaultFrom.balance -= _amount;
            vaultTo.balance += _amount;
            return true;
        }
        return false;
    }

    function stackBalance(uint256 _stack, bool _positive)
    private
    returns(uint256) {
        // Deposit in SELF or Vault.
        if(_stack >= 1){
            if(_positive){
                stackedBalance += _stack;
            }else if(stackedBalance >= _stack){
                stackedBalance -= _stack;
            }else{
                return 0; // We need to check if vault.balance == zero too, to understand if this failed.
            }
        }
        return stackedBalance;
    }

    function vaultLockUnlock(uint256 _vault, bool _lock)
    private
    {
        vaultLock[_vault] = _lock;
    }

    function listVaults()
    private view
    returns(Vault[] memory)
    {
        Vault[] memory vaultArray = new Vault[](myVaultsCount[msg.sender]);
        for (uint256 index = 0; index < myVaultsCount[msg.sender]; index++) {
            vaultArray[index] = vaults[myVaultsMap[msg.sender][index]];
        }
        return vaultArray;
    }

}