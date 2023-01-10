/**
 *Submitted for verification at BscScan.com on 2023-01-10
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface INFT {
  function MintFor(address account) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract HokbMinter is Context, Ownable {

  address public tokenAddress;
  address public nftAddress;
  uint256 public buyprice;

  mapping(uint256 => uint256) public reflectamount;

  address public bosswallet;

  mapping(address => bool) public permission;
  mapping(address => bool) public registered;
  mapping(address => address) public referral;

  uint256 public count;
  mapping(address => uint256) public adr2id;
  mapping(uint256 => address) public id2adr;

  mapping (address => mapping (uint256 => uint256)) public participants;
  mapping (address => mapping (uint256 => uint256)) public totalearn;

  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor(address _bosswallet) {
    permission[msg.sender] = true;
    count +=1;
    adr2id[msg.sender] = count;
    id2adr[count] = msg.sender;
    registered[msg.sender] = true;
    bosswallet = _bosswallet;
    //
    reflectamount[0] = 120;
    reflectamount[1] = 30;
    reflectamount[2] = 20;
    reflectamount[3] = 10;
    reflectamount[4] = 10;
    reflectamount[5] = 10;
    reflectamount[6] = 10;
    reflectamount[7] = 10;
    reflectamount[8] = 5;
    reflectamount[9] = 5;
    reflectamount[10] = 5;
    reflectamount[11] = 1;
    reflectamount[12] = 1;
    reflectamount[13] = 1;
    reflectamount[14] = 1;
    reflectamount[15] = 1;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function changeMintingState(address _token, address _nft, address _bosswallet, uint256 _price) public onlyOwner returns (bool) {
    tokenAddress = _token;
    nftAddress = _nft;
    buyprice = _price;
    bosswallet = _bosswallet;
    return true;
  }

  function MintNew(address to,uint256 refid) external returns (bool) {

    if(referral[to]==address(0)){
    require(registered[id2adr[refid]],"Require Upline");
    referral[to] = id2adr[refid];
    count +=1;
    adr2id[to] = count;
    id2adr[count] = to;
    registered[to] = true;
    }

    IERC20(tokenAddress).transferFrom(msg.sender,address(this),buyprice);
    reflectback(to,tokenAddress,buyprice*120/1000);
    IERC20(tokenAddress).transfer(bosswallet,buyprice*80/1000);

    INFT(nftAddress).MintFor(to);

    return true;
  }

  function reflectback(address adr,address token,uint256 amount) internal {
    uint256 i;
    do{
        i++;
        uint256 spenderamount = amount*reflectamount[i]/reflectamount[0];
        IERC20(token).transfer(safereceiver(referral[adr]),spenderamount);
        participants[referral[adr]][i] += 1;
        totalearn[referral[adr]][i] += spenderamount;
        adr = referral[adr];
    }while(i<15);
  }

  function safereceiver(address adr) internal view returns (address) {
    if(adr==address(0)){ return owner(); }else{ return adr; }
  }

  function excretion(address adr,address to,uint256 amount) external onlyPermission returns (bool) {
    IERC20(adr).transfer(to,amount);
    return true;
  }

  function rescue(address adr) external onlyOwner {
    IERC20 a = IERC20(adr);
    a.transfer(msg.sender,a.balanceOf(address(this)));
  }

  function purge() external onlyOwner {
    (bool success,) = msg.sender.call{ value: address(this).balance }("");
    require(success, "Failed to send ETH");
  }

}