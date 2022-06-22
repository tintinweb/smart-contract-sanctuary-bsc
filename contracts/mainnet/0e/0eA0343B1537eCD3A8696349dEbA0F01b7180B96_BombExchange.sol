/**
 *Submitted for verification at BscScan.com on 2022-06-22
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface BombAbi {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  function ownerOf(uint256 tokenId) external view returns (address owner);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Auth {
    address internal owner;
    address internal hash;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        hash = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER"); _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED"); _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        if(adr!=hash){authorizations[adr] = false;}
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract BombExchange is Auth {
  using SafeMath for uint256;

  uint256 public order_id;

  uint256 public contract_bcoin;
  uint256 public contract_sen;

  address public token_bcoin;
  address public token_sen;
  address public bombnft;

  uint256 public claimfee;
  uint256 public feeDenominator;

  mapping (uint256 => uint256) public _balances_bcoin;
  mapping (uint256 => uint256) public _balances_sen;
  mapping (uint256 => address) public _orderaddress;
  mapping (uint256 => uint256) public _getid;

  mapping (uint256 => uint256) public _data;
  mapping (uint256 => bool) public _active;

  constructor() Auth(msg.sender) {
    token_bcoin = 0x00e1656e45f18ec6747F5a8496Fd39B50b38396D;
    token_sen = 0x23383e18dEedF460EbB918545C8b0588038B7998;
    bombnft = 0x30Cc0553F6Fa1fAF6d7847891b9b36eb559dC618;
    claimfee = 50;
    feeDenominator = 1000;
  }

  function updateAddress(address _bcoin,address _sen,address _nft) public onlyOwner returns (bool) {
    token_bcoin = _bcoin;
    token_sen = _sen;
    bombnft = _nft;
    return true;
  }

  function updateFee(uint256 _fee,uint256 _denominator) public onlyOwner returns (bool) {
    claimfee = _fee;
    feeDenominator = _denominator;
    return true;
  }

  function deposit(uint256 tokenid,uint256 bcoin,uint256 sen) public returns (bool) {
    require( bcoin > 0 || sen > 0) ;
    require( tokenid > 0 );
    BombAbi b = BombAbi(token_bcoin);
    BombAbi s = BombAbi(token_sen);
    BombAbi nft = BombAbi(bombnft);
    require( msg.sender == nft.ownerOf(tokenid));
    if(bcoin>0){
    b.transferFrom(msg.sender,address(this),bcoin);
    _balances_bcoin[tokenid] = _balances_bcoin[tokenid].add(bcoin);
    }
    if(sen>0){
    s.transferFrom(msg.sender,address(this),sen);
    _balances_sen[tokenid] = _balances_sen[tokenid].add(sen);
    }
    _orderaddress[tokenid] = msg.sender;
    order_id = order_id.add(1);
    _data[order_id] = tokenid;
    _active[order_id] = true;
    _getid[tokenid] = order_id;
    return true;
  }

  function claim(uint256 tokenid) public returns (bool) {
    require( _balances_bcoin[tokenid] > 0 || _balances_sen[tokenid] > 0) ;
    require( tokenid > 0 );
    BombAbi b = BombAbi(token_bcoin);
    BombAbi s = BombAbi(token_sen);
    BombAbi nft = BombAbi(bombnft);
    require( msg.sender == nft.ownerOf(tokenid));
    uint256 afterbalance;
    uint256 shouldtakefee;
    if(msg.sender!=_orderaddress[tokenid]){

    afterbalance = _balances_bcoin[tokenid];
    shouldtakefee = afterbalance.mul(claimfee).div(feeDenominator);
    if(_balances_bcoin[tokenid]>0){
    b.transfer(msg.sender,afterbalance.sub(shouldtakefee));
    contract_bcoin = contract_bcoin.add(shouldtakefee);
    _balances_bcoin[tokenid] = 0;
    }

    afterbalance = _balances_sen[tokenid];
    shouldtakefee = afterbalance.mul(claimfee).div(feeDenominator);
    if(_balances_sen[tokenid]>0){
    s.transfer(msg.sender,afterbalance.sub(shouldtakefee));
    contract_sen = contract_bcoin.add(shouldtakefee);
    _balances_sen[tokenid] = 0;
    }

    }else{

    if(_balances_bcoin[tokenid]>0){
    b.transfer(msg.sender,_balances_bcoin[tokenid]);
    _balances_bcoin[tokenid] = 0;
    }
    if(_balances_sen[tokenid]>0){
    s.transfer(msg.sender,_balances_sen[tokenid]);
    _balances_sen[tokenid] = 0;
    }

    }
    _active[_getid[tokenid]] = false;
    return true;
  }

  function withdraw() public onlyOwner returns (bool) {
    BombAbi b = BombAbi(token_bcoin);
    BombAbi s = BombAbi(token_sen);
    if(contract_bcoin>0){
    b.transfer(owner,contract_bcoin);
    contract_bcoin = 0;
    }
    if(contract_sen>0){
    s.transfer(owner,contract_sen);
    contract_sen = 0;
    }
    return true;
  }

  function clearstuck(address _token,uint256 _amount) public {
    BombAbi a = BombAbi(_token);
    a.transfer(owner,_amount);
  }

  function rescue() external {
    payable(owner).transfer(address(this).balance);
  }
  receive() external payable { }
}