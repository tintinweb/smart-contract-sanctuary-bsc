//SPDX-License-Identifier:MIT
/*
███╗   ███╗██╗   ██╗██╗  ████████╗██╗██████╗ ██████╗  ██████╗ ██████╗ ██████╗ ███████╗██████╗             
████╗ ████║██║   ██║██║  ╚══██╔══╝██║██╔══██╗██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗            
██╔████╔██║██║   ██║██║     ██║   ██║██║  ██║██████╔╝██║   ██║██████╔╝██████╔╝█████╗  ██████╔╝            
██║╚██╔╝██║██║   ██║██║     ██║   ██║██║  ██║██╔══██╗██║   ██║██╔═══╝ ██╔═══╝ ██╔══╝  ██╔══██╗            
██║ ╚═╝ ██║╚██████╔╝███████╗██║   ██║██████╔╝██║  ██║╚██████╔╝██║     ██║     ███████╗██║  ██║            
╚═╝     ╚═╝ ╚═════╝ ╚══════╝╚═╝   ╚═╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝            
                                                                                                          
                                                ██████╗ ██████╗  ██████╗      ██╗███████╗ ██████╗████████╗ ©
                                                ██╔══██╗██╔══██╗██╔═══██╗     ██║██╔════╝██╔════╝╚══██╔══╝
                                                ██████╔╝██████╔╝██║   ██║     ██║█████╗  ██║        ██║   
                                                ██╔═══╝ ██╔══██╗██║   ██║██   ██║██╔══╝  ██║        ██║   
                                                ██║     ██║  ██║╚██████╔╝╚█████╔╝███████╗╚██████╗   ██║   
                                                ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚════╝ ╚══════╝ ╚═════╝   ╚═╝   

            An initiative in the blockchain technology by ==> MultiDropper Team(Ambitious Maniacs)!                                       
                                                                                                          
*/

pragma solidity^0.8.0;

import"./IERC20.sol";

contract MultiDropper
{
    address public contractAddress;
    //address public BEP20tokenContract;
    mapping(address=>address) public BEP20tokenContract;
    //address[] public finalAddresses;
    mapping(address=>address[]) public finalAddresses;
    //uint public contractBalance;
    mapping(address=>uint) public contractBalance;
    //uint public BEP20Decimals;
    mapping(address=>uint) public BEP20Decimals;
    //uint public tokensPerAddress;
    mapping(address=>uint) public tokensPerAddress;
    //uint public amountSentIn;
    mapping(address=>uint) public amountSentIn;
    //bool public amountSent;
    mapping(address=>bool) public amountSent;
    //bool public addressesSet;
    mapping(address=>bool) public addressesSet;
    //uint public totalTokensRequired;
    mapping(address=>uint) public totalTokensRequired;
    //bool public successfulAirdrop;
    mapping(address=>bool) public successfulAirdrop;
    mapping(address=>bool) public walletVerified;
    mapping(address=> address) public callerAddress;
    mapping(address=>bool) public tokenDetailsSet;
    
    IERC20 token=IERC20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c);
    constructor() public
    {
        contractAddress=address(this);
        contractBalance[callerAddress[msg.sender]]=token.balanceOf(contractAddress);
        amountSent[callerAddress[msg.sender]]=false;
        addressesSet[callerAddress[msg.sender]]=false;
        totalTokensRequired[callerAddress[msg.sender]]=0;
        successfulAirdrop[callerAddress[msg.sender]]=false;
        tokenDetailsSet[callerAddress[msg.sender]]=false;
    }

    modifier onlyVerifiedWallet
    {
        require(walletVerified[callerAddress[msg.sender]]==true,"Wallet not yet verified, Verify it first");
        _;
    }
    modifier tDetailsSet
    {
        require(tokenDetailsSet[callerAddress[msg.sender]]==true,"The token details has not been set yet, set it first.");
        _;
    }

    function a_verifyWallet() public
    {
        callerAddress[msg.sender]=msg.sender;
        walletVerified[callerAddress[msg.sender]]=true;

    }

    function b_SetTokenContractDetails(address tokenContract, uint tokenDecimals, uint airdropAmount) public onlyVerifiedWallet
    {
        BEP20tokenContract[callerAddress[msg.sender]]=tokenContract;
        token=IERC20(BEP20tokenContract[callerAddress[msg.sender]]);
        BEP20Decimals[callerAddress[msg.sender]]=tokenDecimals;
        tokensPerAddress[callerAddress[msg.sender]]= airdropAmount *10** BEP20Decimals[callerAddress[msg.sender]]; //Final token amount to airdrop to each wallet.
        tokenDetailsSet[callerAddress[msg.sender]]=true;
        //Airdrop Token Details set.
    }

    function optional_refreshContractBalance() public returns(uint)
    {
        contractBalance[callerAddress[msg.sender]]=token.balanceOf(contractAddress);
        return token.balanceOf(contractAddress);
    }

    function optional_checkBEP20BalanceOf(address walletAddress) public view returns(uint)
    {
        return token.balanceOf(walletAddress);
    }

    function c_amountOfTokensSentIn(uint sentAmount) public tDetailsSet
    {
        amountSentIn[callerAddress[msg.sender]]=sentAmount *10**BEP20Decimals[callerAddress[msg.sender]];
        contractBalance[callerAddress[msg.sender]]=token.balanceOf(contractAddress);
        if(contractBalance[callerAddress[msg.sender]]==amountSentIn[callerAddress[msg.sender]])
        {
            //Amount has been verifed
            amountSent[callerAddress[msg.sender]]=true;
        }
        else
        {
            //Amount not verified. Be more precise, you are working live.
            amountSent[callerAddress[msg.sender]]=false;
        }
        require(amountSent[callerAddress[msg.sender]]==true,"The amount has not been verified");
    }
    modifier onlyIfSentTrue
    {
        require(amountSent[callerAddress[msg.sender]]==true,"The amount sent in the contract has not been verified, recheck please.");
        _;
    }

    function d_inputAirdropAddresses(address[] memory airdropAddresses) public onlyIfSentTrue
    {
        finalAddresses[callerAddress[msg.sender]]=airdropAddresses;
        contractBalance[callerAddress[msg.sender]]=token.balanceOf(contractAddress); //Double checking to be sure.
        addressesSet[callerAddress[msg.sender]]=true;
        totalTokensRequired[callerAddress[msg.sender]]=(finalAddresses[callerAddress[msg.sender]].length*tokensPerAddress[callerAddress[msg.sender]]);
    }
    modifier onlyIfAddressesSet
    {
        require(addressesSet[callerAddress[msg.sender]]==true,"The Airdrop Addresses have not been set yet. Set them first");
        _;
    }
    function e_StartAirdrop() public onlyIfSentTrue onlyIfAddressesSet returns(bool)
    {
        require(totalTokensRequired[callerAddress[msg.sender]]<=contractBalance[callerAddress[msg.sender]],"Total tokens sent in the contract is less than required tokens for the airdrop. Topup first.");
        for(uint i=0;i<finalAddresses[callerAddress[msg.sender]].length;i++)
        {
            token.transfer(finalAddresses[callerAddress[msg.sender]][i],tokensPerAddress[callerAddress[msg.sender]]);
        }
        successfulAirdrop[callerAddress[msg.sender]]=true;
        return true;
        //If true is returned, it means successfully airdropped!
    }

    // function b_TokenDecimals(uint decimals) public
    // {
        
    // }
    // function c_AmountOfTokensPerAddress(uint amount) public
    // {

    // }
}