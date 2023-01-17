/**
 *Submitted for verification at BscScan.com on 2023-01-17
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

interface IMINTER {
    function bosswallet() external view returns (address);
    function buyprice() external view returns (uint256);
    function reflectamount(uint256 level) external view returns (uint256);
    function referral(address adr) external view returns (address);
    function excretion(address adr,address to,uint256 amount) external;
    function updateRefReward(address adr,uint256 amount,bool iscount) external returns (bool);
}

interface IENERGY {
    function lastclaim(uint256 tokenid) external view returns (uint256);
    function lastrefill(uint256 tokenid) external view returns (uint256);
    function lastattack(uint256 tokenid) external view returns (uint256);
    function lastwithdraw(uint256 tokenid) external view returns (uint256);
    function mod_lastclaim(uint256 tokenid,uint256 stamp) external;
    function mod_lastrefill(uint256 tokenid,uint256 stamp) external;
    function mod_lastattack(uint256 tokenid,uint256 stamp) external;
    function mod_lastwithdraw(uint256 tokenid,uint256 stamp) external;
}

interface IAUTOSWAP {
  function autoswap() external returns (bool);
}

interface INFT {
  function Nfts(uint256 tokenid) external returns (uint256,uint256,uint256);
  function ownerOf(uint256 tokenid) external view returns (address);
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

contract HokbRewardRouterV2 is Context, Ownable {

  IDEXRouter public router;
  address pcv2 = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

  IMINTER public minter;
  address public minterAddress = 0x72B35077a013eCeE3EC96297D9fC168Ee6bFbb4D;

  IENERGY public energy;
  address public energyAddress = 0x68a53e8BAb5b8A4aF83CDfD9d7448A06938d759A;

  INFT public nft;
  address public nftAddress = 0xf64387d50c23adC07dc435aF33b51aba0B4f6e02;

  address public tokenAddress = 0x3d02B82ACBC64dAD2c4d82768dfA42B12E26a74a;
  
  mapping(address => bool) public permission;
  mapping(uint256 => uint256) public refillcost;

  bool autoswap_busd = false;

  mapping (address => mapping (uint256 => uint256)) public totalearn;

  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor() {
    router = IDEXRouter(pcv2);
    minter = IMINTER(minterAddress);
    energy = IENERGY(energyAddress);
    nft = INFT(nftAddress);
    permission[msg.sender] = true;
    refillcost[3] = 3750*(10**18);
    refillcost[7] = 7500*(10**18);
    refillcost[15] = 15000*(10**18);
    refillcost[31] = 28000*(10**18);
  }

  function flagePermission(address _account,bool _flag) public onlyOwner returns (bool) {
    permission[_account] = _flag;
    return true;
  }

  function flageAutoSwap(bool _flag) public onlyOwner returns (bool) {
    autoswap_busd = _flag;
    return true;
  }

  function changeMintingState(address _token, address _nft, address _minter, address _energy) public onlyOwner returns (bool) {
    tokenAddress = _token;
    nftAddress = _nft;
    minterAddress = _minter;
    energyAddress = _energy;
    minter = IMINTER(minterAddress);
    energy = IENERGY(energyAddress);
    nft = INFT(nftAddress);
    return true;
  }

  function setrefill(uint256 _days, uint256 _amount) public onlyPermission returns (bool) {
    refillcost[_days] = _amount;
    return true;
  }

  function claim(uint256 tokenid) public returns (bool) {
    address ownerNFT = nft.ownerOf(tokenid);
    uint256 mintingprice = minter.buyprice();
    uint256 lastclaim = energy.lastclaim(tokenid);
    uint256 lastrefill = energy.lastrefill(tokenid);
    (,uint256 date,uint256 ra) = nft.Nfts(tokenid);

    uint256 percent = (((1400 * ra)/10000) + 6800) / 100; //68  82
    uint256 secreward = mintingprice * percent / 100 / 2592000;

    if(lastclaim==0){ lastclaim = date; }
    if(lastrefill==0){ lastrefill = date + 2592000; }

    uint256 miningtime;
    if(block.timestamp>lastrefill){
      miningtime = lastrefill - lastclaim;
    }else{
      miningtime = block.timestamp - lastclaim;
    }

    uint256 reward = miningtime * secreward;
    minter.excretion(tokenAddress,ownerNFT,reward);

    energy.mod_lastclaim(tokenid,block.timestamp);

    return true;
  }

  function refill(uint256 tokenid,uint256 _days) public returns (bool) {
    require(refillcost[_days]>0,"!ERROR : OUT OF PACKAGE");

    uint256 amount = refillcost[_days];

    IERC20(tokenAddress).transferFrom(msg.sender,minterAddress,amount*800/1000);

    minter.updateRefReward(msg.sender,amount*120/1000,false);

    IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount*80/1000);
    IERC20(tokenAddress).approve(pcv2,amount*80/1000);
    swap2ETH(amount*80/1000,tokenAddress);

    if(autoswap_busd){ IAUTOSWAP(minter.bosswallet()).autoswap(); }

    uint256 lastrefill = energy.lastrefill(tokenid);
    (,uint256 date,) = nft.Nfts(tokenid);

    if(lastrefill==0){ lastrefill = date + 2592000; }

    if(lastrefill<block.timestamp){
      energy.mod_lastrefill(tokenid,block.timestamp+(86400*_days));
    }else{
      energy.mod_lastrefill(tokenid,lastrefill+(86400*_days));
    }

    return true;
  }

  function swap2ETH(uint256 amount,address tokenin) internal {
    address[] memory path = new address[](2);
    path[0] = tokenin;
    path[1] = router.WETH();
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    amount,
    0,
    path,
    minter.bosswallet(),
    block.timestamp
    );
  }

  function safereceiver(address adr) internal view returns (address) {
    if(adr==address(0)){ return minterAddress; }else{ return adr; }
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