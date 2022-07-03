/**
 *Submitted for verification at BscScan.com on 2022-07-02
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

contract Token{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint private _totalSupply = 250000000 * 10 ** 18;
    string private _name = " Btscrow";
    string private _symbol = "BTCSCRW";
    uint private _decimals = 18;
    uint private MAXTXFEE = 10;
    uint private maxownablepercentage = 10 ;
    uint private maxownableamount;
    uint private maxtxpercentage = 3;
    uint private maxtxamount;
    uint private txfeeToHolders = 0;
    uint private txfeeToTeam = 0;
    address private noTaxWallet;
    address private owner;
    address private marketingWallet = 0x023B8F9ee90080d018246E6b885A31d2c8212360;
    address private teamWallet = 0xA873c1970961F627D79A4220Ea7206EdA67ae92F;
    address private timelockedTokensWallet = 0x46F899792C165825E37C511f45C697B024423033;
    bool private existbool = false;
    uint private dateofdeployment;
    uint private lastWithdraw;
    address [] holders;
    uint private truetxfeeH;
    bool public antiwhalenabled = false;
    uint private lockedFunds;
    uint private unlockedFunds;
    uint private sparedays = 0;
    uint private truevalue;

    // events

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    //struct
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view   returns (string memory) {
        return _symbol;
    }

    function decimals() public pure  returns (uint8) {
        return 18;
    }

    function totalSupply() public view   returns (uint256) {
        return _totalSupply;
    }

    //modifiers

    modifier isOwner() {
        
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    function antiwhalecheck(address to, uint amount)
    private returns(bool success)
    {
        
        if(antiwhalenabled) {
            maxownableamount = _totalSupply  * maxownablepercentage / 100;
            maxtxamount = _totalSupply  * maxtxpercentage / 100;
            require(balanceOf(to) + amount <= maxownableamount, "you already own too many token");
            require(amount <= maxtxamount, "you cannot make transactions this high");
        }
        return true;
        
    }


    modifier isntlocked{
        require(msg.sender != timelockedTokensWallet);
        require(msg.sender != teamWallet);
        _;
    }

    modifier onlytimelockedwallet{
        require(msg.sender == timelockedTokensWallet);
        _;
    }


    //change variables
    
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function setMaxOwnablePerentage(uint newPercentage) isOwner public returns(bool){
        maxownablepercentage = newPercentage;

        return true;
    }

    function ChangeNoTaxAddress(address newWallet) public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        noTaxWallet = newWallet;

        return true;
    }
    
    function setMaxTxPerentage(uint _newPercentage) isOwner public returns(bool){
        maxtxpercentage = _newPercentage;

        return true;
    }

    function ChangeTxFees( uint newTxFeeToHolders, uint , uint newTxFeeToTeam)
    public returns(bool) {
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to change the transaction fee");
        require(newTxFeeToHolders + newTxFeeToTeam <= MAXTXFEE);
        txfeeToTeam = newTxFeeToTeam;
        txfeeToHolders = newTxFeeToHolders;
        
        

        return true;
    }

    //constructor

    constructor() {
        owner = msg.sender;
        dateofdeployment = block.timestamp;
        emit OwnerSet(address(0), owner);
        _balances[owner] = _totalSupply / 100 * 35;
        _balances[marketingWallet] = _totalSupply / 100 * 5;
        lockedFunds = _totalSupply / 100 * 50;
        _balances[teamWallet] = _totalSupply / 100 * 10;
        _balances[timelockedTokensWallet] = lockedFunds;
        lastWithdraw = dateofdeployment;
    }

    //transfers

    function transferNoTax(address from, address to, uint value) private returns(bool){
        _balances[to] += value;
        _balances[from] -= value;
        exist(to);
        if(existbool  == false && to != owner){
            
            holders.push(to);
            }
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
    ) internal  {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        antiwhalecheck(to, amount);
        if (from == noTaxWallet || from == owner) {
 

            unchecked {
            _balances[from] = fromBalance - amount;
        }
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }else {
            truetxfeeH  = amount / 100 * txfeeToTeam;
            truevalue = (amount - truetxfeeH );
            _balances[to] += truevalue;
            _balances[from] -= amount;
            transferPaid(owner, truetxfeeH);
            emit Transfer(from, to, truevalue);

        }
        exist(to);
        if(existbool  == false && to != owner){
            
            holders.push(to);
        }
        

        

        
    }

    function transfer(address to, uint256 amount) public isntlocked returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public  returns (bool) {
        require(from != timelockedTokensWallet);
        require(from != teamWallet);
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function transferFromTeamWallett(address to,uint amount)public returns(bool success){
        require(msg.sender == teamWallet);
        require(block.timestamp - dateofdeployment >= 365 days);

        transferNoTax(msg.sender, to, amount);
        
        return true;

        
    }

    function _spendAllowance(
        address ownr,
        address spender,
        uint256 amount
    ) internal  {
        uint256 currentAllowance = allowance(ownr, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(ownr, spender, currentAllowance - amount);
            }
        }
    }

    function allowance(address ownr, address spender) public view  returns (uint256) {
        return _allowances[ownr][spender];
    }

    function _approve(
        address ownr,
        address spender,
        uint256 amount
    ) internal  {
        require(ownr != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[ownr][spender] = amount;
        emit Approval(ownr, spender, amount);
    }


    function withdrawlockedfunds(uint amount, address reciever) public onlytimelockedwallet returns(bool success){
        if(block.timestamp - lastWithdraw + sparedays >= 30 days){
            sparedays = block.timestamp - lastWithdraw + sparedays - 30 days;
            if(lockedFunds >= 6250000 * 10 *18){
                lockedFunds -= 6250000 * 10 *18;
                unlockedFunds += 6250000 * 10 *18;
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
    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        _balances[to] += value;
        _balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }

    //burn

    function burn (uint256 _value) public  isntlocked returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        
        require(balanceOf(msg.sender) >= _value);
        _balances[msg.sender] -= _value;
        _totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    
 
    function burnFrom(address _from, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= _allowances[_from][msg.sender]);
        
        _balances[_from] -= _value;
        _totalSupply -= _value;
        emit Transfer (_from, address(0), _value);
        return true;
    }
    
    //rewards distribution

    function exist(address holder) private {
        existbool = false;
        for (uint256 i = 0; i < holders.length; i++) {
            if (holders[i] == holder) {
                existbool = true;}
        }    
    }


    function distributeRewards(uint256 _value) public returns(bool success){
        _value = _value * 10 **18;
        uint  availableSupplyH = 0;
        for(uint i = 0; i < holders.length; i++) {
            availableSupplyH = availableSupplyH + balanceOf(holders[i]);
        }
        uint valueH = _value;
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i]) *valueH / availableSupplyH);
            transferToHolder(holders[i], percentageToHolder);
        }
        
        return true;
    }

    function distributeRewardsint(uint256 _value) private returns(bool success){
        
        uint  availableSupplyH = 0;
        for(uint i = 0; i < holders.length; i++) {
            availableSupplyH = availableSupplyH + balanceOf(holders[i]);
        }
        
        uint  percentageToHolder;
        for(uint i = 0; i < holders.length; i++) {
            percentageToHolder = (balanceOf(holders[i]) * _value / availableSupplyH);
            transferPaid(holders[i], percentageToHolder);
        }
        
        return true;
    }

   //other
    

    

    function getOwner() external view returns (address) {
        return owner;
    }

    function balanceOf(address Address) public view returns(uint) {
        return _balances[Address];
    }

    function approve(address spender, uint value) public returns (bool) {
        _allowances[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
    }

    //DAO

    struct Voter {
        uint weight; 
        bool voted;  
        address delegate; 
        uint vote;   
        
    }

    struct Proposal {
        string _name; 
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    

    Proposal[] public proposals;


    function createProposals(string[] memory proposalNames) public {
        chairperson = msg.sender;


        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                _name: proposalNames[i],
                voteCount: 0
            }));
        }
        
    }

    function giverighttovote() public isOwner{
        for (uint i = 0; i < holders.length; i++){
            voters[holders[i]].weight = balanceOf(holders[i]) * 100 **18 / _totalSupply;
             
        }
    }

    function getweight() public view  returns(uint weight){
        return voters[msg.sender].weight;
    }
    

    function delegate(address to) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "You already voted.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            
            require(to != msg.sender, "Found loop in delegation.");
        }
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {

            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            delegate_.weight += sender.weight;
        }
    }

 
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(sender.weight != 0, "Has no right to vote");
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;

        proposals[proposal].voteCount += sender.weight;
    }


    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    function winnerName() public view
            returns (string memory winnerName_)
    {
        winnerName_ = proposals[winningProposal()]._name;
    }

   

    
}