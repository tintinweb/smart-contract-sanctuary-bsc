/**
 *Submitted for verification at BscScan.com on 2022-06-17
*/

pragma solidity ^0.6.0;
/*
 ██████╗ █████╗ ███████╗██╗  ██╗    ██████╗ ██████╗  ██████╗ ████████╗ ██████╗  ██████╗ ██████╗ ██╗             
██╔════╝██╔══██╗██╔════╝██║  ██║    ██╔══██╗██╔══██╗██╔═══██╗╚══██╔══╝██╔═══██╗██╔════╝██╔═══██╗██║             
██║     ███████║███████╗███████║    ██████╔╝██████╔╝██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║             
██║     ██╔══██║╚════██║██╔══██║    ██╔═══╝ ██╔══██╗██║   ██║   ██║   ██║   ██║██║     ██║   ██║██║             
╚██████╗██║  ██║███████║██║  ██║    ██║     ██║  ██║╚██████╔╝   ██║   ╚██████╔╝╚██████╗╚██████╔╝███████╗        
 ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ ╚══════╝        
                                                                                                                
                 █████╗ ███╗   ██╗ ██████╗ ███╗   ██╗ ██████╗ █████╗ ███████╗██╗  ██╗                           
                ██╔══██╗████╗  ██║██╔═══██╗████╗  ██║██╔════╝██╔══██╗██╔════╝██║  ██║                           
                ███████║██╔██╗ ██║██║   ██║██╔██╗ ██║██║     ███████║███████╗███████║                           
                ██╔══██║██║╚██╗██║██║   ██║██║╚██╗██║██║     ██╔══██║╚════██║██╔══██║                           
                ██║  ██║██║ ╚████║╚██████╔╝██║ ╚████║╚██████╗██║  ██║███████║██║  ██║                           
                ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝                           
        Developed by AnonCash Team.                                                                                                                
*/
interface IHashing256
{
 function rH() external returns(bytes32);
}



contract CashProtocol
{
    address public ownerAddress;
    address public contractAddress;
    uint public minAmount;
    mapping(address => bytes32) seedCode;
    mapping(bytes32 => uint) etherInSeed; //Ether remaining in the particular SeedCode.
    mapping(address => uint) totalEtherDeposit;
    mapping(address => uint) etherRemaining; //Ether remaining in the particular Address.
    mapping(bytes32 => address) addressFromSeed;
    bytes32[] seedCollection;
    address[] addressesWithSeed;
    mapping(address => bool) seedGenerated;
    mapping(address => bool) depositMade;
    IHashing256 hashsum256;
    bool public hashSet;
    constructor() public
    {
        ownerAddress=msg.sender;
        contractAddress=address(this);
        minAmount=0.1 ether;
        hashSet=false;
    }
    
    modifier onlyOwner
    {
        require(msg.sender == ownerAddress," The caller should be the owner");
        _;
    }

    function setMinimum(uint _minAmount) public onlyOwner
    {
        //Setting the minimum amount to be passed in the transaction.
        minAmount=_minAmount; 
    }
    modifier hashSuccessful
    {
        require(hashSet,"Hash has not been set yet");
        _;
    }

    function setHash(address sapphireAdd) public onlyOwner
    {
        hashsum256= IHashing256(sapphireAdd);
        hashSet=true;
    }

    function a_getSeedCode() public view returns(bytes32)
    {
        require(seedGenerated[msg.sender]," No seed Code has been generated for the Address");
        return seedCode[msg.sender];
    }

    function b_getRemaningBalance() public view returns(uint)
    {
        require(depositMade[msg.sender],"No Deposit has been made by the address");
        return etherRemaining[msg.sender];// Return the value privately
    }

    function c_getSeedAmount() public view returns(uint)
    {
        require(seedGenerated[msg.sender],"No seed found for the address");
        return etherInSeed[seedCode[msg.sender]];
    }
    function d_getTotalEtherDeposit() public view returns(uint)
    {
        require(depositMade[msg.sender],"No deposit found for the address");
        return totalEtherDeposit[msg.sender];
    }

    //  modifier passesMinimum(uint minimumAmount)
    // {
    //     require(msg.value >= minimumAmount,"Deposit Amount cannot be less than Minimum Amount");
    //     _;
    // }

    function inputCash() public payable hashSuccessful
    {
        require(msg.value >= minAmount ,"Deposit Amount is less than minimum threshold");
        //Minimum ether to be deposited is 0.1
        //Generate the access phrase
        totalEtherDeposit[msg.sender]+=msg.value;
        etherRemaining[msg.sender]+=msg.value;
        if(!seedGenerated[msg.sender])
        {
        bytes32 secret= hashsum256.rH();
        for(uint i=0; i< seedCollection.length; i++)
        {
            if(seedCollection[i]==secret)
            {
                //Regenerate Seed
                secret= hashsum256.rH();
            }
            else
            {
                continue;
            }
        }
        seedCode[msg.sender]= secret;
         //This code has the access to the funds.
         seedGenerated[msg.sender]=true;
        }
        depositMade[msg.sender]=true;
        etherInSeed[seedCode[msg.sender]] += msg.value;
        addressFromSeed[seedCode[msg.sender]]=msg.sender;
        seedCollection.push(seedCode[msg.sender]);
    }

    function customWithdrawUsingSeed(bytes32 seedPhrase, uint amount) public
    {
        //1000= 1 Ether
        //100= 0.1, 10=0.01
        uint amountInWei= amount*10**15;
        bool seedVerified;
        for(uint i=0; i< seedCollection.length; i++)
        {
            if(seedCollection[i]== seedPhrase) //Seed Verified.
            {
                seedVerified=true;
            }
            else
            {
                seedVerified=false;
            }
        }
        require(seedVerified,"Wrong SeedCode entered.");
        require(addressFromSeed[seedPhrase] != msg.sender," Depositor cannot withdraw in order to maintain privacy in the protocol");
        require(etherInSeed[seedPhrase] >= 0 ether, "The Seed Phrase has no ether.");
        require(etherInSeed[seedPhrase] >= amountInWei,"Not enough ether in the seed to make the Withdrawal");
        //After all the conditions are found true.
        //Start withdrawal.
        msg.sender.transfer(amountInWei);
        etherInSeed[seedPhrase]-= amountInWei;
        etherRemaining[addressFromSeed[seedPhrase]]-= amountInWei;
    }
    function withdrawAll(bytes32 sPhrase) public 
    {
        bool seedVerified;
        for(uint i=0; i< seedCollection.length; i++)
        {
            if(seedCollection[i]==sPhrase)
            {
                seedVerified=true;
            }
            else
            {
                seedVerified=false;
            }
        }
        require(seedVerified,"Wrong SeedCode Entered");
        require(etherInSeed[sPhrase]>= 0 ether,"Not enough balance in Seed");
        require(addressFromSeed[sPhrase]!= msg.sender,"Depositor cannot withdraw to maintain Privacy ");
        //All the above conditions are found true.
        //Start Withdraw
        msg.sender.transfer(etherInSeed[sPhrase]);
    }
    
}