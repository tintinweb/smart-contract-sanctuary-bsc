/**
 *Submitted for verification at BscScan.com on 2022-06-21
*/

//SPDX-License-Identifier: MIT


pragma solidity 0.8.2;

contract Token{
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint public totalSupply = 250000000 * 10 ** 18;
    string public name = " Btscrow";
    string public symbol = "BTCSCRW";
    uint public decimals = 18;
    uint public MAXTXFEE = 10;
    uint public maxownablepercentage = 10 ;
    uint private maxownableamount;
    uint public maxtxpercentage = 3;
    uint private maxtxamount;
    uint txfeeToHolders = 0;
    uint txfeeToTeam = 0;
    address noTaxWallet;
    address  owner;
    address marketingWallet = 0x023B8F9ee90080d018246E6b885A31d2c8212360;
    address teamWallet = 0xA873c1970961F627D79A4220Ea7206EdA67ae92F;
    address timelockedTokensWallet = 0x46F899792C165825E37C511f45C697B024423033;
    bool private existbool = false;
    uint dateofdeployment;
    uint lastWithdraw;
    address[] holders;

    // events

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    event Burn(address indexed burner, uint256 value);
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    //struct


    //modifiers

    modifier isOwner() {
        
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    modifier antiwhalecheck(address from ,address to, uint value){
        maxownableamount = totalSupply / 100 * maxownablepercentage;
        maxtxamount = totalSupply / 100 * maxtxpercentage;
        if(from == owner || to == owner || from == teamWallet) {  
            _;
        }else {
            require(balanceOf(to) + value <= maxownableamount, "you already own too many token");
            require(value <= maxtxamount, "you cannot make transactions this high");
        }
        _;
    }

    modifier checkifoneyearpassed(address from){
        if(from == teamWallet){
            require(block.timestamp - dateofdeployment >= 365 days);
        }
        _;
    }

    modifier isntlocked(address from){
        require(from != timelockedTokensWallet);
        _;
    }

    modifier onlytimelockedwallet(){
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
        _balances[owner] = totalSupply / 100 * 35;
        _balances[marketingWallet] = totalSupply / 100 * 5;
        _balances[teamWallet] = totalSupply / 100 * 10;
        lastWithdraw = dateofdeployment;
    }

    //transfers

    function transferNoTax(address to, uint value) private returns(bool){
        _balances[to] += value;
        _balances[msg.sender] -= value;
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

    
    function transfer(address to, uint value) public antiwhalecheck(msg.sender, to, value) checkifoneyearpassed(msg.sender) 
    isntlocked(msg.sender) returns(bool) {
        require(balanceOf(msg.sender) >= value, 'balance too low');
        
        if (msg.sender == noTaxWallet || msg.sender == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeH = value / 100 * txfeeToHolders;
            
        
            uint truetxfeeT = value / 100 * txfeeToTeam;
            uint truevalue = (value - truetxfeeH  -  truetxfeeT);
            _balances[to] += truevalue;
            _balances[msg.sender] -= value;
            transferPaid(owner, truetxfeeT);
            distributeRewardsint(truetxfeeH);
            exist(to);
            if(existbool  == false && to != owner){
                
                holders.push(to);
            }
            
            emit Transfer(msg.sender, to, truevalue);
        }

        return true;

    }

  
    


    
    
    function transferFrom(address from, address to, uint value) antiwhalecheck(from, to, value) 
    isntlocked(from) checkifoneyearpassed(from) public returns(bool) {
        require(balanceOf(from) >= value, 'balance too low');
        require(_allowances[from][msg.sender] >= value, '_allowances too low');
        maxownableamount = totalSupply / 100 * maxownablepercentage;
        maxtxamount = totalSupply / 100 * maxtxpercentage;
    
        if (from == noTaxWallet || from == owner) {


            transferNoTax(to, value);
         } else {
            uint truetxfeeH = value / 100 * txfeeToHolders;
            
            
            uint truetxfeeT = value / 100 * txfeeToTeam;
            uint truevalue = (value - truetxfeeH   - truetxfeeT);
            _balances[to] += truevalue;
            _balances[from] -= value;
            transferPaid(owner, truetxfeeT);
            distributeRewardsint(truetxfeeH);
            exist(to);
            if(existbool  == false && to != owner){
                
                holders.push(to);
            } 
            
            emit Transfer(from, to, truevalue);
        }

        return true;
    }

    function withdrawlockedfunds(address reciever) public onlytimelockedwallet returns(bool success){
        if(block.timestamp - lastWithdraw >= 30 days){
            _balances[timelockedTokensWallet] -= 6250000 * 10 *18;
            _balances[reciever] += 6250000 * 10 *18;
            lastWithdraw = block.timestamp;
            return true;
        }else{
            revert("a month did not pass yet");
        }
    }

    function transferToHolder(address to, uint value) private{
        require(balanceOf(msg.sender) >= value, 'balance too low');
        _balances[to] += value;
        _balances[msg.sender] -= value;
        
        emit Transfer(msg.sender, to, value);
       

    }

    //burn

    function burn (uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        
        require(balanceOf(msg.sender) >= _value);
        _balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer (msg.sender, address(0), _value);
        return true;
    }

    
 
    function burnFrom(address _from, uint256 _value) public returns(bool success){
        require(msg.sender == owner, "you are not the owner of the contract, you have to be the owner to burn");
        require(balanceOf(_from) >= _value);
        require(_value <= _allowances[_from][msg.sender]);
        
        _balances[_from] -= _value;
        totalSupply -= _value;
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
        string name; 
        uint voteCount;
    }

    address public chairperson;

    mapping(address => Voter) public voters;

    

    Proposal[] public proposals;


    function createProposals(string[] memory proposalNames) public {
        chairperson = msg.sender;


        for (uint i = 0; i < proposalNames.length; i++) {

            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
        
    }

    function giverighttovote() public isOwner{
        for (uint i = 0; i < holders.length; i++){
            voters[holders[i]].weight = balanceOf(holders[i]) * 100 **18 / totalSupply;
             
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
        winnerName_ = proposals[winningProposal()].name;
    }

   

    
}