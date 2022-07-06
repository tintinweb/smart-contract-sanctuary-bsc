pragma solidity ^0.8.0;

//import "./IERC20.sol";
import "./IERC721.sol";

contract NFTTech
{
  address public ownerAddress;
  address payable public mainAddress= payable(0xfd9EdEB2FfC3779488536086fA0C1bb4654343D8);
  uint public minContribution;
  uint public maxContribution;
  //IERC20 token;
  IERC721 nftToken;
  bool public nftContractSet;
  address public contractAddress;
  mapping(address=>uint) public totalBought;
  uint public nftIndex;
  uint public nftBalance;
  mapping(address=>bool) public tokenBought;
  constructor() public
  {
      ownerAddress=msg.sender;
      minContribution=100;
      maxContribution=3000;
      nftContractSet=false;
      contractAddress=address(this);
      nftIndex=0;
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

  function setIndex(uint index) public onlyOwner
  {
      nftIndex=index; //Clear Index clutters.
  }

  function set_NFTContract(address nftContract) public onlyOwner
  {
      nftToken=IERC721(nftContract);
      nftContractSet=true;
  }
  function get_NFTBalance() public view onlyOwner returns(uint)
  {
      uint balance=nftToken.balanceOf(contractAddress);
      return balance;
  }

    
  function set_MinMax(uint min, uint max) public onlyOwner
  {
      minContribution=min;
      maxContribution=max;
  }

  function buyPrivate() payable public
  {

  }

  receive() external payable
  {
    uint valueInWei=msg.value;
    uint valueNumeral=valueInWei/10**15;
    nftBalance=nftToken.balanceOf(contractAddress);
    require(valueNumeral>=minContribution && valueNumeral<=maxContribution,"Sent amount is out of the range. Kindly, recheck");
    require(totalBought[msg.sender]<maxContribution,"The Wallet exceeds the maximum limit to buy");
    mainAddress.transfer(msg.value); //Transfer Done
    totalBought[msg.sender]+=valueNumeral;
    tokenBought[msg.sender]=true;
    if(valueNumeral==1000)
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

}