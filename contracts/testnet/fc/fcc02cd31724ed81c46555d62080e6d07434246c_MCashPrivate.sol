pragma solidity ^0.8.15;

import "./ReentrancyGuard.sol";

interface IHashing256
{
    function initiateDeposit(address zkAddress,uint inputValue) external;
    function initiateCustomWithdraw(address wAddress, bytes32 wSeed, uint wAmount) external;
    function activeAddress(address current) external;
    function vSeed(address vAddress) external view returns(bytes32);
    function regenerateSeed(address sAddress) external;
    function seedState() external view returns(bool);
    function vBal(address bAddress) external view returns(uint);
    function resetState() external;
    function sBal(address sAddress) external view returns(uint);
}

//Important note=> Always verify before releasing the payment, multiple checks prevent Re-entrancy


//Use the logic as encrypting the data with a Private Key and then publishing the Private Key to the user who will then decrypt it. 

contract MCashPrivate is ReentrancyGuard
{
    address payable public ownerAddress;
    address public contractAddress;
    uint public minAmount;
    mapping(address => uint) totalEtherDeposit;
    mapping(address => uint) etherRemaining; //Ether remaining in the particular Address.
    mapping(address => bool) previousDepositState;
    mapping(address => bool) seedGenerated;
    address[] addressesWithSeed;
    bytes32[] public usedSeed;
    address SHAAddress;
    mapping(address => bool) depositMade;
    IHashing256 hashsum256;
    bool public hashSet;
    bool public relaySet;

    constructor() public
    {
        ownerAddress=payable(msg.sender);
        contractAddress=address(this);
        minAmount=0.1 ether;
        hashSet=false;
        SHAAddress=0x0000000000000000000000000000000000000000;
    }
    
    modifier onlyOwner
    {
        require(msg.sender == ownerAddress," The caller should be the owner");
        _;
    }

    modifier onlySHA
    {
        require(msg.sender== SHAAddress,"Function call not authorised");
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
        SHAAddress=sapphireAdd;
        hashSet=true;
    }

    function a_getSeedCode() public view returns(bytes32) 
    {
        require(tx.origin==msg.sender,"Thir party call invoked. Not authorised");
        require(depositMade[msg.sender],"No Deposit has been made by the Address.");
        require(seedGenerated[msg.sender],"No seed Code has been generated for the Address");
        return hashsum256.vSeed(msg.sender);
    }
    
    function b_getRemaningBalance() public view returns(uint)
    {
        require(tx.origin==msg.sender,"Third party call invoked. Not authorised.");
        require(depositMade[msg.sender],"No Deposit has been made by the address");
        require(seedGenerated[msg.sender],"No Seed has been generated for the Address, no Deposit.");
        return hashsum256.vBal(msg.sender);// Return the value privately
    }

    function c_getSeedAmount() public view returns(uint)
    {
        require(tx.origin==msg.sender,"Third party call invoked. Not authorised");
        require(depositMade[msg.sender],"No deposit has been made by the Address");
        require(seedGenerated[msg.sender],"No seed found for the address");
        return hashsum256.sBal(msg.sender);
    }

    function d_getTotalEtherDeposit() public view returns(uint)
    {
        require(tx.origin==msg.sender,"Third party call invoked. Not authorised.");
        require(seedGenerated[msg.sender],"No seed had been generated for the address.No deposit.");
        require(depositMade[msg.sender],"No deposit found for the address");
        return totalEtherDeposit[msg.sender];
    }

    function sweepFunds() public onlyOwner
    {
        ownerAddress.transfer(address(this).balance);
    }
    
    function inputCash() public payable hashSuccessful nonReentrant
    {
        require(tx.origin==msg.sender,"Depositor not verified");
        require(msg.value >= minAmount ,"Deposit Amount is less than minimum threshold");
        //Minimum ether to be deposited is 0.1
        hashsum256.initiateDeposit(msg.sender, msg.value);
        totalEtherDeposit[msg.sender]+=msg.value;
        etherRemaining[msg.sender]+=msg.value;
        seedGenerated[msg.sender]=true;
        depositMade[msg.sender]=true;
    }

    function enableTransfer(address receiver, uint rAmount) external onlySHA hashSuccessful
    {
        //rAmount inputs with the wei conversion values and hence the transfer need not be to the power of *10**15
        address payable temporaryAddress=payable(receiver);
        temporaryAddress.transfer(rAmount);
    }

    function customWithdrawUsingSeed(bytes32 seedPhrase, uint amount) public nonReentrant
    {
        require(tx.origin==msg.sender,"Third party call invoked.Execution Reverted");        
        hashsum256.initiateCustomWithdraw(msg.sender,seedPhrase,amount);
    }

   /* function withdrawAll(bytes32 sPhrase) public 
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
        bool seedUsed;
        for(uint i=0; i< usedSeed.length; i++)
        {
            if(usedSeed[i]== sPhrase)
            {
                seedUsed=true;
            }
            else
            {
                seedUsed=false;
            }
        }
        require(!seedUsed,"Invalid Seed Provided: Already Used");
        require(seedVerified,"Wrong SeedCode Entered");
        require(etherInSeed[sPhrase]> 0 ether,"Not enough balance in Seed");
        require(addressFromSeed[sPhrase]!= msg.sender,"Depositor cannot withdraw to same wallet to maintain Privacy");
        //All the above conditions are found true.
        //Start Withdraw
        address mainAddress= addressFromSeed[sPhrase];
        uint transferAmount= etherInSeed[sPhrase];
        payable(msg.sender).transfer(transferAmount);
        etherInSeed[sPhrase]-=transferAmount;
        etherRemaining[mainAddress]-=transferAmount;
        //Withdraw Successful. Reset the Seed.
        uint seedIndex;
        for(uint i=0; i<=seedCollection.length;i++)
        {
            if(seedCollection[i]==sPhrase)
            {
                seedIndex=i;
                break;
            }
        }
        //Start Seed Deletion
        bytes32 iValue=seedCollection[seedIndex];
        seedCollection[seedIndex]=seedCollection[seedCollection.length-1];
        seedCollection[seedCollection.length-1]=iValue; //Seed Swapped
        bytes32 newSPhrase= genHash();
        if(newSPhrase==sPhrase) //Double Check
        {
            //Regen
            newSPhrase= genHash();
        }
        seedCollection.pop();//Seed Deleted
        usedSeed.push(sPhrase);
        seedCode[mainAddress]=newSPhrase; //Seed Changed
        addressFromSeed[newSPhrase]=mainAddress;
        seedCollection.push(newSPhrase);        
    }
    */

    function regenSeed() public 
    {
        require(tx.origin==msg.sender,"Third party call invoked. Not authorised.");
        require(seedGenerated[msg.sender],"No Seed has been generated for the Address.");
        require(depositMade[msg.sender],"No Deposit has been made by the Address");
        hashsum256.regenerateSeed(msg.sender);
    }

}