/**
 *Submitted for verification at BscScan.com on 2023-02-09
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
  function decimals() external pure returns (uint8);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface INFT {
  function MintFor(address account) external returns (bool);
}

interface IREFWALL {
  function newReward(uint256 amount,address[] memory participants) external returns (bool);
}

interface IMIGRATE {
  function count() external view returns (uint256);
  function adr2id(address adr) external view returns (uint256);
  function id2adr(uint256 id) external view returns (address);
  function referral(address adr) external view returns (address);
  function registered(address adr) external view returns (bool);
}

interface IDEXRouter {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
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

contract HokbMinterV3 is Context, Ownable {

  IDEXRouter public router;
  address pcv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  uint256 public mirateid = 1;

  address public tokenAddress = 0x3d02B82ACBC64dAD2c4d82768dfA42B12E26a74a;
  address public refwallet = 0xc0CcdD7a2BceE184238EAd300a574391d6b3B737;
  address public bosswallet = 0x7495785c9b5eC54cb8242b951526749b16fA7a52;
  address public nftAddress = 0xf64387d50c23adC07dc435aF33b51aba0B4f6e02;
  uint256 public buyprice = 55000000000000000000000;

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

  constructor() {
    router = IDEXRouter(pcv2);
    permission[address(this)] = true;
    permission[msg.sender] = true;
    referral[msg.sender] = msg.sender;
    count +=1;
    adr2id[msg.sender] = count;
    id2adr[count] = msg.sender;
    registered[msg.sender] = true;
  }

  function migrate(address _contract) public onlyOwner returns (bool) {
    uint256 i = mirateid;
    uint256 max = IMIGRATE(_contract).count();
    do{
        i++;
        address adr = IMIGRATE(_contract).id2adr(i);
        id2adr[i] = adr;
        adr2id[adr] = i;
        referral[adr] = IMIGRATE(_contract).referral(adr);
        registered[adr] = true;
    }while(i<max);
    mirateid = max;
    count = max;
    return true;
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function changeMintingState(address _token, address _nft, address _refwallet, address _bosswallet, uint256 _price) public onlyOwner returns (bool) {
    tokenAddress = _token;
    nftAddress = _nft;
    refwallet = _refwallet;
    bosswallet = _bosswallet;
    buyprice = _price;
    return true;
  }

  function MintNew(address to,uint256 refid) external returns (bool) {
    
    _registerFor(to,refid);

    IERC20(tokenAddress).transferFrom(msg.sender,address(this),buyprice);
    
    _updateRefReward(to,buyprice*120/1000,true);

    IERC20(tokenAddress).approve(pcv2,buyprice*80/1000);
    swap2ETH(buyprice*80/1000,tokenAddress);

    INFT(nftAddress).MintFor(to);

    return true;
  }

  function registerFor(address to,uint256 refid) external onlyPermission returns (bool) {
    _registerFor(to,refid);
    return true;
  }

  function _registerFor(address to,uint256 refid) internal {
    if(referral[to]==address(0)){
    require(registered[id2adr[refid]],"Require Upline");
    referral[to] = id2adr[refid];
    count +=1;
    adr2id[to] = count;
    id2adr[count] = to;
    registered[to] = true;
    }
  }

  function updateRefReward(address adr,uint256 amount,bool iscount) public onlyPermission returns (bool) {
    _updateRefReward(adr,amount,iscount);
    return true;
  }

  function _updateRefReward(address adr,uint256 amount,bool iscount) internal {

    IERC20(tokenAddress).transfer(refwallet,amount);

    address triggeradr;
    uint256 earned;

    address[] memory st = new address[](1);
    earned = amount*30/120;

    triggeradr = safereferral(adr);
    st[0] = triggeradr;
    if(iscount){ participants[triggeradr][1] += 1; }
    totalearn[triggeradr][1] += earned;

    IREFWALL(refwallet).newReward(earned,st);

    address[] memory nd = new address[](1);
    earned = amount*20/120;

    triggeradr = safereferral(st[0]);
    nd[0] = triggeradr;
    if(iscount){ participants[triggeradr][2] += 1; }
    totalearn[triggeradr][2] += earned;

    IREFWALL(refwallet).newReward(earned,nd);

    address[] memory ten = new address[](5);
    earned = amount*10/120;

    triggeradr = safereferral(nd[0]);
    ten[0] = triggeradr;
    if(iscount){ participants[triggeradr][3] += 1; }
    totalearn[triggeradr][3] += earned;

    triggeradr = safereferral(ten[0]);
    ten[1] = triggeradr;
    if(iscount){ participants[triggeradr][4] += 1; }
    totalearn[triggeradr][4] += earned;

    triggeradr = safereferral(ten[1]);
    ten[2] = triggeradr;
    if(iscount){ participants[triggeradr][5] += 1; }
    totalearn[triggeradr][5] += earned;

    triggeradr = safereferral(ten[2]);
    ten[3] = triggeradr;
    if(iscount){ participants[triggeradr][6] += 1; }
    totalearn[triggeradr][6] += earned;

    triggeradr = safereferral(ten[3]);
    ten[4] = triggeradr;
    if(iscount){ participants[triggeradr][7] += 1; }
    totalearn[triggeradr][7] += earned;

    IREFWALL(refwallet).newReward(earned,ten);

    address[] memory five = new address[](3);
    earned = amount*5/120;

    triggeradr = safereferral(ten[4]);
    five[0] = triggeradr;
    if(iscount){ participants[triggeradr][8] += 1; }
    totalearn[triggeradr][8] += earned;

    triggeradr = safereferral(five[0]);
    five[1] = triggeradr;
    if(iscount){ participants[triggeradr][9] += 1; }
    totalearn[triggeradr][9] += earned;

    triggeradr = safereferral(five[1]);
    five[2] = triggeradr;
    if(iscount){ participants[triggeradr][10] += 1; }
    totalearn[triggeradr][10] += earned;

    IREFWALL(refwallet).newReward(earned,five);

    address[] memory one = new address[](5);
    earned = amount*1/120;

    triggeradr = safereferral(five[2]);
    one[0] = triggeradr;
    if(iscount){ participants[triggeradr][11] += 1; }
    totalearn[triggeradr][11] += earned;

    triggeradr = safereferral(one[0]);
    one[1] = triggeradr;
    if(iscount){ participants[triggeradr][12] += 1; }
    totalearn[triggeradr][12] += earned;

    triggeradr = safereferral(one[1]);
    one[2] = triggeradr;
    if(iscount){ participants[triggeradr][13] += 1; }
    totalearn[triggeradr][13] += earned;

    triggeradr = safereferral(one[2]);
    one[3] = triggeradr;
    if(iscount){ participants[triggeradr][14] += 1; }
    totalearn[triggeradr][14] += earned;

    triggeradr = safereferral(one[3]);
    one[4] = triggeradr;
    if(iscount){ participants[triggeradr][15] += 1; }
    totalearn[triggeradr][15] += earned;

    IREFWALL(refwallet).newReward(earned,one);
  }


  function swap2ETH(uint256 amount,address tokenin) internal {
    address[] memory path = new address[](2);
    path[0] = tokenin;
    path[1] = router.WETH();
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    amount,
    0,
    path,
    bosswallet,
    block.timestamp
    );
  }

  function safereferral(address adr) internal view returns (address) {
    if(referral[adr]==address(0)){
        return owner();
    }else{ return referral[adr]; }
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
  
  receive() external payable { }
}