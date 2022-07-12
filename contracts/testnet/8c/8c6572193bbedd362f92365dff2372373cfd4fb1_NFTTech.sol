// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/*
                   
██████╗ ██╗   ██╗██╗     ██╗     ███████╗████████╗███████╗██████╗     ████████╗███████╗ ██████╗██╗  ██╗    
██╔══██╗██║   ██║██║     ██║     ██╔════╝╚══██╔══╝██╔════╝██╔══██╗    ╚══██╔══╝██╔════╝██╔════╝██║  ██║    
██████╔╝██║   ██║██║     ██║     ███████╗   ██║   █████╗  ██████╔╝       ██║   █████╗  ██║     ███████║    
██╔══██╗██║   ██║██║     ██║     ╚════██║   ██║   ██╔══╝  ██╔═══╝        ██║   ██╔══╝  ██║     ██╔══██║    
██████╔╝╚██████╔╝███████╗███████╗███████║   ██║   ███████╗██║            ██║   ███████╗╚██████╗██║  ██║    
╚═════╝  ╚═════╝ ╚══════╝╚══════╝╚══════╝   ╚═╝   ╚══════╝╚═╝            ╚═╝   ╚══════╝ ╚═════╝╚═╝  ╚═╝    

                    Specially Developed BullStep Sale Technology by the BullStep Team.  

                                               .:=++++==:.                                
                                             :=+*++++++++++=:.                            
                                           .++=**+++++++++++++=:.                         
                                          -*+==**++++++++++++++++=:.                      
                     .::.               -*#++==+#********+++**===++++=:.        .         
                 :+#=:::=#=           -**#*++++=*##*********#===++++++++++====+=.         
                +###:   :**        .-***##+*+++++*###*******#+++++++****+===-:            
               *#*=..-+*+:      .-*######****++++++**####***#*++++******:                 
               -  :**-.      .-*%%#######*****++++++++***######+++******                  
                  **+:..:-=+*##%%%########**************+++++++#+++****+                  
                  .+****#**####%%%#%#####%************++++++++- =+++***=                  
                      ..-**####%%%%#%%###%#******###*****++*++:  -++*##:                  
                        =*****###%%#%%%###%%####*++=-::.  :***.                           
                       .******######%%#*+=-:..           .+**+                            
                      .+******#####+-.                 -+***+.                            
                    .=******######=                   .***+:                              
                  :+*****######+-.                     -.                                 
                  =******+=-:.                                                            
                 :***-                                                                    
                :+***                                                                     
               -+***.                                                                     
               -***:                                                                      
                =*:                                    

    Website=> https://bullstep.net
    Official Community=>https://t.me/bullstepofficial
    Official Twitter Community=>https://twitter.com/BullStep_App

*/
import "./IERC20.sol";
import "./IERC721.sol";

contract NFTTech
{
  address payable public ownerAddress;
  address payable public mainAddress= payable(0xfd9EdEB2FfC3779488536086fA0C1bb4654343D8);
  uint public minContribution;
  uint public maxContribution;
  IERC20 token;
  IERC721 nftToken;
  bool public nftContractSet;
  address public contractAddress;
  mapping(address=>uint) public totalBought;
  uint public nftIndex;
  uint public nftBalance;
  mapping(address=>bool) public tokenBought;
  uint public mintAmount;
  bool public tSet;
  bool public decimalSet;
  uint public tDecimals;
  mapping(address=>uint) public purchasedValue;
  constructor() public
  {
      ownerAddress=payable(msg.sender);
      minContribution=100;
      maxContribution=3000;
      mintAmount=3000;
      nftContractSet=false;
      contractAddress=address(this);
      nftIndex=0;
      tDecimals=9;
      tSet=false;
      decimalSet=false;
  }   

  modifier onlyOwner
  {
      require(msg.sender==ownerAddress,"The caller is not authorised");
      _;
  }

  modifier nftAddressSet
  {
      require(nftContractSet,"NFT Contract Address has not been set yet");
      _;
  }

  modifier tDecimalSet
  {
      require(decimalSet,"The Token Decimals have not been set yet");
      _;
  }  

  function set_tDecimals(uint decimals) public onlyOwner
  {
      tDecimals=decimals;
      decimalSet=true;
  }

  function setMintAmount(uint amount) public onlyOwner
  {
      mintAmount=amount;
  }

  function setIndex(uint index) public onlyOwner
  {
      nftIndex=index; //Clear Index clutters.
  }

  function set_NFTContract(address nftContract) public onlyOwner
  {
      nftToken=IERC721(nftContract);
      nftContractSet=true;
  }

  function get_purchaseValue() public view returns(uint)
  {
      return purchasedValue[msg.sender];
  }


  function get_NFTBalance() public view onlyOwner returns(uint)
  {
      uint balance=nftToken.balanceOf(contractAddress);
      return balance;
  }
  modifier tAddressSet
  {
      require(tSet,"The Token Address has not been set yet");
      _;
  }

  function set_Token(address tAddress) public onlyOwner
  {
      token=IERC20(tAddress);
      tSet=true;
  }

  function t_Token(address receipient, uint tAmount) public onlyOwner tAddressSet
  {
      token.transfer(receipient,tAmount*10**tDecimals);
      //Token Decimals Set
  }
    
  function set_MinMax(uint min, uint max) public onlyOwner
  {
      minContribution=min;
      maxContribution=max;
  }

  function buyPrivate() payable public
  {
      tTech();
  }

  function withdrawAmount() public onlyOwner
  {
      ownerAddress.transfer(contractAddress.balance);
  }

  function tTech() internal
  {
    uint valueInWei=msg.value;
    uint valueNumeral=valueInWei/10**15;
    nftBalance=nftToken.balanceOf(contractAddress);
    require(valueNumeral>=minContribution && valueNumeral<=maxContribution,"Sent amount is out of the range. Kindly, recheck");
    require(totalBought[msg.sender]<maxContribution,"The Wallet exceeds the maximum limit to buy");
    mainAddress.transfer(msg.value); //Transfer Done
    purchasedValue[msg.sender]+=valueNumeral;
    totalBought[msg.sender]+=valueNumeral;
    tokenBought[msg.sender]=true;
    if(valueNumeral==mintAmount)
    {
        require(nftBalance!=0,"ReAdd NFT to the contract");
        nftToken.transferFrom(contractAddress,msg.sender,nftIndex);
        nftIndex++;
    }
    else
    {
        return;
    }
  }

  receive() external payable
  {
      tTech();
  }

}