// SPDX-License-Identifier: Apache-2.0
// DuckTech Contracts (Default Duck Coin) 1.1



pragma solidity ^0.8.0;

import "./IERC20.sol";

contract DDC33 is IERC20{

    //GENERIC VARIABLES
    bool internal locked;
    bool public isIssuing;
    bool public isFarmingEnabled;
    bool public firstFarmingWinMore;
    address public COINAdminAddress;
    address public investmentcurrencyaddress;
    address public treasuryOwner;
    address public projectOwner;
    address public defaultInviterAddress;
    uint256 public lastResetedLetFarm;
    uint256 public percentageToUnlockToFarm;
    uint256 public treasuryOnLastAnnounce;
    uint256 public issuancePrice;
    uint256 public sponsoredPricePercentage;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    string private _onlyadmin = "Only the admin";
    mapping(address => uint256) public lastFarmed;
    mapping(address => address) public inviteSponsor;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) public receivedThisTurn;
    mapping(address => mapping(address => uint256)) private _allowances;
    //TARIFF VARIABLES
    uint256 public investSponsorTax;
    uint256 public transactionSponsorTax;
    uint256 public farmSponsorTax;
    TaxCollector[] public investTaxCollectors;
    TaxCollector[] public transactionTaxCollectors;
    constructor(
        string memory name_,
        string memory symbol_,
        bool isFarmingEnabled_,
        bool firstFarmingWinMore_,
        uint256 percentageToUnlockToFarm_,
        uint256 issuancePrice_,
        uint256 sponsoredPricePercentage_
        ) {
        _name = name_;
        _symbol = symbol_;
        COINAdminAddress = msg.sender;
        treasuryOwner =  address(this);
        projectOwner =  msg.sender;
        isFarmingEnabled = isFarmingEnabled_;
        firstFarmingWinMore = firstFarmingWinMore_;
        defaultInviterAddress = address(this);
        percentageToUnlockToFarm = percentageToUnlockToFarm_;
        issuancePrice = issuancePrice_;
        sponsoredPricePercentage = sponsoredPricePercentage_;
    }    
    fallback() external payable{}
    receive() external payable{}
    //STRUCTS
    struct TaxCollector{
        address collectorAddres;
        uint256 taxPercentage;
    }
    //MODIFIERS
    modifier noReentrant{
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
    //EVENTS
    event Farm(address indexed investor);
    //INTERNAL FUNCTIONS
    function _sendIssuedCoins(uint256 amount) internal returns(bool){
        _mint(msg.sender, (amount / issuancePrice)*(10**decimals()));
        return true;
    }
    function _receiveInvestment(uint256 amount) internal returns(bool){
        uint256 remaining_amount = amount;
        for (uint256 i = 0; i < investTaxCollectors.length; i++) {
            uint256 tax = amount*investTaxCollectors[i].taxPercentage/1000;
            remaining_amount -= tax;
            require(IERC20(investmentcurrencyaddress).transferFrom(msg.sender, investTaxCollectors[i].collectorAddres, tax));
        }
        if(inviteSponsor[msg.sender] == address(0)){
            uint256 tax = amount*investSponsorTax/1000;
            remaining_amount -= tax;
            require(IERC20(investmentcurrencyaddress).transferFrom(msg.sender, defaultInviterAddress, tax));
        }else{
            uint256 tax = amount*investSponsorTax/1000;
            remaining_amount -= tax;
            require(IERC20(investmentcurrencyaddress).transferFrom(msg.sender, inviteSponsor[msg.sender], tax));
        }
        require(IERC20(investmentcurrencyaddress).transferFrom(msg.sender, treasuryOwner, remaining_amount));
        return true;
    }
    
    //ADMIN FUNCTIONS
    function adm_addInvestTaxCollectors(address _collectorAddres, uint256 _taxPercentage) external returns(bool)
    {
        require(msg.sender == COINAdminAddress, _onlyadmin);
        investTaxCollectors.push(TaxCollector(_collectorAddres, _taxPercentage));
        return true;
    }
    function adm_addTransactionTaxCollectors(address _collectorAddres, uint256 _taxPercentage) external returns(bool)
    {
        require(msg.sender == COINAdminAddress, _onlyadmin);
        transactionTaxCollectors.push(TaxCollector(_collectorAddres, _taxPercentage));
        return true;
    }
    function adm_editInvestTaxCollectors(uint256 ID, address _collectorAddres, uint256 _taxPercentage) external returns(bool){
        require(msg.sender == COINAdminAddress, _onlyadmin);
        investTaxCollectors[ID].collectorAddres = _collectorAddres;
        investTaxCollectors[ID].taxPercentage = _taxPercentage;
        return true;
    }
    function adm_editTransactionTaxCollectors(uint256 ID, address _collectorAddres, uint256 _taxPercentage) external returns(bool){
        require(msg.sender == COINAdminAddress, _onlyadmin);
        transactionTaxCollectors[ID].collectorAddres = _collectorAddres;
        transactionTaxCollectors[ID].taxPercentage = _taxPercentage;
        return true;
    }
    function adm_mint(address account, uint256 amount) external{
        require(msg.sender == COINAdminAddress, _onlyadmin);
        _mint(account, amount);
    }
    function adm_burn(address account, uint256 amount) external{
        require(msg.sender == COINAdminAddress, _onlyadmin);
        _burn(account, amount);
    }
    function adm_changeAdmin(address newAdmin) external returns(address)
    {
        require(msg.sender == COINAdminAddress, _onlyadmin);
        COINAdminAddress = newAdmin;
        return COINAdminAddress;
    }
    function adm_changeprojectOwner(address newOwner) external returns(address)
    {
        require(msg.sender == COINAdminAddress, _onlyadmin);
        projectOwner = newOwner;
        return projectOwner;
    }
    function adm_changeTreasuryOwner(address newtreasuryOwner) external returns(address)
    {
        require(msg.sender == COINAdminAddress, _onlyadmin);
        treasuryOwner = newtreasuryOwner;
        return treasuryOwner;
    }
    function adm_changedefaultInviterAddress(address newdefaultInviterAddress) external returns(address)
    {
        require(msg.sender == COINAdminAddress, _onlyadmin);
        defaultInviterAddress = newdefaultInviterAddress;
        return defaultInviterAddress;
    }
    // ADMIN TREASURY FUNCTIONS
    function adm_changesponsoredPricePercentage(uint256 newsponsoredPricePercentage) external returns(uint256)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        sponsoredPricePercentage = newsponsoredPricePercentage;
        return sponsoredPricePercentage;
    }
    function adm_changeinvestSponsorTax(uint256 newinvestSponsorTax) external returns(uint256)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        investSponsorTax = newinvestSponsorTax;
        return investSponsorTax;
    }
    function adm_changefarmingSponsorTax(uint256 newfarmSponsorTax) external returns(uint256)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        farmSponsorTax = newfarmSponsorTax;
        return investSponsorTax;
    }
    function adm_changetransactionSponsorTax(uint256 newtransactionSponsorTax) external returns(uint256)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        transactionSponsorTax = newtransactionSponsorTax;
        return transactionSponsorTax;
    }
    function adm_announceCoinDividends(uint256 amount) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        _transfer(msg.sender, treasuryOwner, amount);
        treasuryOnLastAnnounce = getAmountInTreasury();
        require(adm_letAllGoFarm());
        return true;
    }
    function adm_changeisIssuing(bool newIsIssuing) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        isIssuing = newIsIssuing;
        return isIssuing;
    }
    function adm_changeInvestmentcurrencyaddress(address newinvestmentcurrencyaddress) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        investmentcurrencyaddress = newinvestmentcurrencyaddress;
        return true;
    }
    function adm_changeIssuancePrice(uint256 newIssuancePrice) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        issuancePrice = newIssuancePrice;
        return true;
    }
    function adm_changeisFarmingEnabled(bool newisFarmingEnabled) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        isFarmingEnabled = newisFarmingEnabled;
        return true;
    }
    function adm_changefirstFarmingWinMore(bool newfirstFarmingWinMore) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        firstFarmingWinMore = newfirstFarmingWinMore;
        return true;
    }
    function adm_changePercentageToUnlockToFarm(uint256 newPercentageToUnlockToFarm) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        percentageToUnlockToFarm = newPercentageToUnlockToFarm;
        return true;
    }
    function adm_withdraw(uint256 amount) external returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        require(IERC20(investmentcurrencyaddress).transfer(msg.sender, amount), "Error on payment");
        return true;
    }
    function adm_letAllGoFarm() public returns(bool)
    {
        require(msg.sender == projectOwner || msg.sender == COINAdminAddress, _onlyadmin);
        lastResetedLetFarm = block.number;
        return true;
    }
    //INVESTORS FUNCTION
    function createAccountWithSponsor(address sponsorAddress)external returns(bool){
        require(inviteSponsor[msg.sender] == address(0), "You already have an account");
        require(inviteSponsor[msg.sender] != msg.sender);
        inviteSponsor[msg.sender] = sponsorAddress;
        return true;
    }
    function createAccountWithoutSponsor()external returns(bool){
        require(inviteSponsor[msg.sender] == address(0), "You already have an account");
        inviteSponsor[msg.sender] = defaultInviterAddress;
        return true;
    }
    function invest(uint256 amount) external noReentrant returns(bool) 
    {
        require(isIssuing, "Now we are NOT issuing new coins!");
        require(_receiveInvestment(amount), "ERROR TO RECEIVE");
        if(inviteSponsor[msg.sender] == address(0)){
            require(_sendIssuedCoins(amount), "ERROR TO SEND");
        }else{
            require(_sendIssuedCoins(amount/sponsoredPricePercentage*1000), "ERROR TO SEND");
        }
        return true;
    }
    function farm() external noReentrant returns(bool) {
        require(isFarmingEnabled, "Farming is Disabled");
        require(lastFarmed[msg.sender] < lastResetedLetFarm, "Already Farmed");
        lastFarmed[msg.sender] = block.number;
        uint256 amountFarm;
        uint256 originBalance;
        if(receivedThisTurn[msg.sender]<=balanceOf(msg.sender)){
            originBalance = (balanceOf(msg.sender)-receivedThisTurn[msg.sender]);
            if(firstFarmingWinMore){
                amountFarm = ((((originBalance*(10**decimals())) / totalSupply()) * percentageToUnlockToFarm)/1000) * getAmountInTreasury() /(10**decimals());
            }else{
                amountFarm = ((((originBalance*(10**decimals())) / totalSupply()) * percentageToUnlockToFarm)/1000) * treasuryOnLastAnnounce /(10**decimals());
            }
            uint256 sponsorTax = amountFarm*farmSponsorTax/1000;
            uint256 remainingFarm = amountFarm - sponsorTax;
            _transfer(treasuryOwner,inviteSponsor[msg.sender], sponsorTax);
            _transfer(treasuryOwner,msg.sender, remainingFarm);
        }
        receivedThisTurn[msg.sender] = 0;
        emit Farm(msg.sender);
        return true;
    }
    //GENERIC FUNCTIONS
    function getAmountInTreasury() public view returns(uint256){
        return balanceOf(treasuryOwner);
    }
    function transfer(address to, uint256 amount) public returns (bool) {

        address owner = _msgSender();
        uint256 remaining_amount = amount;
        for (uint256 i = 0; i < transactionTaxCollectors.length; i++) {
            uint256 tax = amount*transactionTaxCollectors[i].taxPercentage/1000;
            remaining_amount -= tax;
            _transfer(owner, transactionTaxCollectors[i].collectorAddres, tax);
        }
        address validSponsor;
        if(inviteSponsor[msg.sender] == address(0)){
            validSponsor = defaultInviterAddress;
        }else{
            validSponsor = inviteSponsor[msg.sender];
        }
        uint256 sponsorTax = amount*transactionSponsorTax/1000;
        remaining_amount -= sponsorTax;
        _transfer(owner, validSponsor, sponsorTax);

        _transfer(owner, to, remaining_amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        uint256 remaining_amount = amount;
        for (uint256 i = 0; i < transactionTaxCollectors.length; i++) {
            uint256 tax = amount*transactionTaxCollectors[i].taxPercentage/1000;
            remaining_amount -= tax;
            _transfer(from, transactionTaxCollectors[i].collectorAddres, tax);
        }
        
        address validSponsor;
        if(inviteSponsor[from] == address(0)){
            validSponsor = defaultInviterAddress;
        }else{
            validSponsor = inviteSponsor[from];
        }
        uint256 sponsorTax = amount*transactionSponsorTax/1000;
        remaining_amount -= sponsorTax;
        _transfer(from, validSponsor, sponsorTax);
        _transfer(from, to, remaining_amount);
        return true;
    }
    function get_receivedThisTurn(address account) public view returns(uint256){
        return receivedThisTurn[account];
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }
    function totalSupply() public view  returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }
    function _transfer(address from, address to_, uint256 amount) internal {
        address to;
        if(to_ == address(0)){
            to = treasuryOwner;
        }else{
            to = to_;
        }
        require(from != address(0), "ERC20: transfer from the zero address");
        receivedThisTurn[to] += amount;
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0));

        _beforeTokenTransfer(address(0), account, amount);
        receivedThisTurn[account] += amount;

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0));

        receivedThisTurn[account] -= amount;
        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal {}
    //CONTEXT FUNCTIONS
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
    function _msgData() internal pure returns (bytes calldata) {
        return msg.data;
    }

}