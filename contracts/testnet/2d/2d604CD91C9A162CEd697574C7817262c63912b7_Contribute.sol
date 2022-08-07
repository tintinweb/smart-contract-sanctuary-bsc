/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface IERC20 {
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
  function faucet(address account,uint256 amount,uint256 price) external;
  function burnt(address account,uint256 amount,uint256 price) external;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
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
        authorizations[adr] = false;
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

contract Contribute is Context,Auth{
  using SafeMath for uint256;

  event UpdatedPackage(address indexed admin, uint256 key,uint256 packagelevel,uint256 amount);
  event TxCreated();

  mapping (uint256 => mapping (uint256 => uint256)) private hash_packdata;
  mapping (address => mapping (uint256 => uint256)) private hash_earned;
  mapping (uint256 => mapping (address => address)) private hash_downline;
  mapping (address => mapping (uint256 => uint256)) private hash_sharedscore;

  uint256 private fee_dividend;
  uint256 private fee_withdraw;
  mapping (address => bool) public isAdmin;
  mapping (uint256 => uint256) private fee_refreward;
  mapping (uint256 => address) public externaladdress;

  uint256 public txorder;
  mapping (uint256 => uint256) public txamountin;
  mapping (uint256 => uint256) public txamountout;
  mapping (uint256 => uint256) public txprice;
  mapping (uint256 => address) public txowner;
  mapping (uint256 => uint256) public txwhen;
  mapping (uint256 => string) public txdata;

  uint256 private fee_contribute;

  uint256 public monthy_start;
  uint256 public monthy_split;

  address public token;
  address public USDT;
  uint256 public baseprice;
  uint256 public growratio;
  uint256 public riseprice;
  bool public publicbuy;
  bool public adminbuy;
  bool public safemath;

  uint256 public contribution_id;
  mapping (uint256 => address) public contribution_idowner;
  mapping (uint256 => uint256) public contribution_undividend;
  mapping (uint256 => uint256) public contribution_max;
  mapping (uint256 => uint256) public contribution_name;
  mapping (uint256 => address) public topshared_address;
  mapping (uint256 => address) public secshared_address_1;
  mapping (uint256 => address) public secshared_address_2;
  mapping (uint256 => address) public secshared_address_3;
  mapping (uint256 => address) public secshared_address_4;

  mapping (uint256 => uint256) public wallet_topshared;
  mapping (address => uint256) public invitecount;
  mapping (address => mapping (uint256 => bool)) public topshared_exit;

  bool internal locked;
  bool internal claiming;

  modifier noReentrant() {
  require(!locked, "No re-entrancy");
  locked = true;
  _;
  locked = false;
  }

  constructor(address _token,address _usdt) Auth(msg.sender) {
  
  //token state
  token = _token;
  USDT = _usdt; //usde
  baseprice = 1 * (10**13); //0.00001 $ per token
  growratio = 5 * (10**18);
  riseprice = 1; //0.01%
  //monthy_split = 2592000; // a month
  monthy_split = 60*60*2; // a hour

  publicbuy = true;
  adminbuy = true;
  safemath = true;

  //contribute state
  externaladdress[1] = 0x08103592888d231A09D3C243676A01884040979F; //dev fee
  externaladdress[2] = 0x0582A030EdDF674E8ef643F4cd1a9dB7CE572aDB; //marketing
  externaladdress[3] = 0xA7B95056B1447D8B97eF938f469c4aBE3adE78a2; //caller
  externaladdress[4] = 0x355fC7ccA06FE5F0aF07E0Bef3d8d912dA6B742f; //staking
  externaladdress[5] = 0x3a9d29016EbD56f6945796CB47CB7896bf3a9a34; //top shared
  externaladdress[6] = 0x527F30e97DBe30b6CE524527F0413F722501e91d; //dividend

  fee_dividend = 150; //15% dividen
  fee_withdraw = 50; //5% to owner
  fee_refreward[1] = 50; //5% to ref level 1
  fee_refreward[2] = 30; //3% to ref level 2
  fee_refreward[3] = 10; //1% to ref level 3
  fee_refreward[4] = 5; //0.5% to ref level 4
  fee_refreward[5] = 5; //0.5% to ref level 5
  fee_contribute = 10; //total 50 or 5% fee (5 address)
  //1% dev fee //1% marketing //1% caller //1% top ref //1% staking

  hash_packdata[0][1] = 50;
  hash_packdata[0][2] = 500;
  hash_packdata[0][3] = 1000;
  hash_packdata[0][4] = 5000;
  hash_packdata[0][5] = 10000;
  hash_packdata[0][6] = 30000;

  hash_packdata[1][1] = 40; //150%
  hash_packdata[1][2] = 450; //160%
  hash_packdata[1][3] = 1000; //170%
  hash_packdata[1][4] = 5500; //180%
  hash_packdata[1][5] = 12000; //190%
  hash_packdata[1][6] = 39000; //200%

  }

  function getPackData(uint256 key,uint256 package) external view returns (uint256) {
    //key 0 = price matic cost in usdt
    //key 1 = maximumed earned dividend in usdt
    //pagekage = package level
    return hash_packdata[key][package];
  }

  function updatePackData(uint256 key,uint256 package,uint256 amount) external authorized returns (bool) {
    hash_packdata[key][package] = amount;
    emit UpdatedPackage(msg.sender,key,package,amount);
    return true;
  }

  function updateAdminAddress(address[] memory account) external authorized returns (bool) {
    uint i = 0;
    while (i < account.length ) {
      i++;
      externaladdress[i] = account[i];
    }
    return true;
  }

  function getAccountEarned(address account,uint256 key) external view returns (uint256) {
    //key 0 = dividend earned
    //key 1 = ref 5% earned
    //key 2 = ref 3% earned
    //key 3 = ref 1% earned
    //key 4 = ref 0.5% earned
    //key 5 = ref 0.5% earned
    //key 6 = top shared earned
    return hash_earned[account][key];
  }

  function getAccountScore(address account,uint256 key) external view returns (uint256) {
    return hash_sharedscore[account][key];
  }

  function setForceBuy(bool publicbuyflag,bool adminbuyflag) external authorized returns (bool) {
    publicbuy = publicbuyflag;
    adminbuy = adminbuyflag;
    return true;
  }

  function grantAdminRole(address account,bool flag) external authorized returns (bool) {
    isAdmin[account] = flag;
    return true;
  }

  function getMonth() external view returns (uint256) {
    return thismounth();
  }

  function getfeeRefReward(uint256 reflevel) external view returns (uint256) {
    return fee_refreward[reflevel];
  }

  function getfeeContribute() external view returns (uint256) {
    return fee_contribute;
  }

  function getDownline(uint256 reflevel,address who) external view returns (address) {
    return hash_downline[reflevel][who];
  }

  function getAccountDownline(address account) external view returns (address[5] memory) {
    return [
    hash_downline[1][account],
    hash_downline[2][account],
    hash_downline[3][account],
    hash_downline[4][account],
    hash_downline[5][account]
    ];
  }

  function getAmountTokenOut(uint256 _usdin) external view returns (uint256) {
    IERC20 a = IERC20(USDT);
    uint256 calculateusd = a.balanceOf(address(this)).add(_usdin);
    uint256 calculateprice = getprice(calculateusd.mul(70).div(100));
    return _usdin.div(calculateprice);
  }

  function getAmountUSDTOut(uint256 _tokenin) external view returns (uint256) {
    uint256 calculateprice = getcurrentprice().mul(70).div(100);
    return _tokenin.mul(calculateprice).div(10**18);
  }  

  function getPriceAtUsd(uint256 _usd) external view returns (uint256) {
    return getprice(_usd.mul(10**18));
  }

  function getBuyPrice() external view returns (uint256) {
    return getcurrentprice();
  }

  function getSoldPrice() external view returns (uint256) {
    return getcurrentprice().mul(70).div(100);
  }

  function getReferLink(address account) external view returns (uint256) {
    uint256 i = 0;
    while (i <= contribution_id) {
      if(contribution_idowner[i]==account){
        return i;
      }
      i++;
    }
    return 0;
  }

  function getContributeFilter(uint256 filteramount) external view returns (uint256) {
    uint256 i = 0;
    uint256 result = 0;
    while (i <= txorder) {
      if(keccak256(abi.encodePacked((txdata[i]))) == keccak256(abi.encodePacked(("contribute")))){
        if(txamountin[i]==filteramount){ result = result.add(1); } 
      }
      i++;
    }
    return result;
  }

  function directBuy(uint256 amountusd) external noReentrant() returns (bool) {
    if(isAdmin[msg.sender] && !adminbuy){ revert("admin direct buy not allow!"); }
    if(!isAdmin[msg.sender] && !publicbuy){ revert("public direct buy not allow!"); }
    IERC20 a = IERC20(USDT);
    IERC20 b = IERC20(token);
    uint256 beforeusd = a.balanceOf(address(this));
    uint256 afterusd = beforeusd.add(amountusd);
    uint256 boughtoutprice = getprice(afterusd);
    if(isAdmin[msg.sender]){
      boughtoutprice = boughtoutprice.mul(70).div(100);
    }
    uint256 receiveamount = amountusd.div(boughtoutprice);
    uint256 decimals = b.decimals();
    receiveamount = receiveamount.mul(10**decimals);
    a.transferFrom(msg.sender,address(this),amountusd);
    b.faucet(msg.sender,receiveamount,boughtoutprice);
    //create tx
    txorder = txorder.add(1);
    txamountin[txorder] = amountusd;
    txamountout[txorder] = receiveamount;
    txprice[txorder] = boughtoutprice;
    txowner[txorder] = msg.sender;
    txwhen[txorder] = block.timestamp;
    txdata[txorder] = "Buy";
    emit TxCreated();
    return true;
  }

  function directSell(uint256 amounttoken) external noReentrant() returns (bool) {
    if(isAdmin[msg.sender] && !adminbuy){ revert("admin direct buy not allow!"); }
    if(!isAdmin[msg.sender] && !publicbuy){ revert("public direct buy not allow!"); }
    IERC20 a = IERC20(USDT);
    IERC20 b = IERC20(token);
    uint256 decimals = b.decimals();
    uint256 freezeprice = getcurrentprice().mul(70).div(100);
    uint256 usdtamount = amounttoken.div(10**decimals).mul(freezeprice);
    if(!isAdmin[msg.sender]){
        uint256 withdrawfee = usdtamount.mul(fee_withdraw).div(1000);
        a.transfer(owner,withdrawfee);
        usdtamount = usdtamount.sub(withdrawfee);
    }
    b.burnt(msg.sender,amounttoken,freezeprice);
    a.transfer(msg.sender,usdtamount);
    //create tx
    txorder = txorder.add(1);
    txamountin[txorder] = amounttoken;
    txamountout[txorder] = usdtamount;
    txprice[txorder] = getcurrentprice();
    txowner[txorder] = msg.sender;
    txwhen[txorder] = block.timestamp;
    txdata[txorder] = "Sell";
    emit TxCreated();
    return true;
  }

  function contribution(uint256 packageid,address referto) external noReentrant() returns (bool) {
    require(msg.sender!=referto);
    uint256 investamount = hash_packdata[0][packageid];
    investamount = investamount * (10**18);
    if(monthy_start==0){ monthy_start = block.timestamp; }
    uint256 time = block.timestamp.sub(monthy_start);
    uint256 index = time.div(monthy_split);
    hash_sharedscore[referto][index] = hash_sharedscore[referto][index].add(investamount);
    invitecount[referto] = invitecount[referto].add(1);
    sortsharedscore(referto);
    IERC20 a = IERC20(USDT);
    IERC20 b = IERC20(token);
    require(a.balanceOf(msg.sender)>=investamount && investamount>0);
    a.transferFrom(msg.sender,address(this),investamount);
    uint256 contractusd = a.balanceOf(address(this)).mul(70).div(100);
    uint256 boughtoutprice = getprice(contractusd);
    uint256 receiveamount = investamount.div(boughtoutprice);
    receiveamount = receiveamount.mul(10**18);
    b.faucet(msg.sender,receiveamount,boughtoutprice);
    refMapping(msg.sender,referto);
    uint i = 0;
    address refaccount;
    uint256 refreward;
    while (i < 5) {
      i++;
      refaccount = hash_downline[i][msg.sender];
      refreward = investamount.mul(fee_refreward[i]).div(1000);
      if(refaccount!=address(0)){
        a.transfer(refaccount,refreward);
        hash_earned[refaccount][i] = hash_earned[refaccount][i].add(refreward);
      }else{
        a.transfer(owner,refreward);
      }
    }
    i = 0;
    while (i < 5) {
        i++;
        a.transfer(externaladdress[i],getadmintax(investamount));
    }
    wallet_topshared[thismounth()] = wallet_topshared[thismounth()].add(getadmintax(investamount));
    a.transfer(externaladdress[6],getdividendtax(investamount));
    contribution_id = contribution_id.add(1);
    contribution_idowner[contribution_id] = msg.sender;
    contribution_undividend[contribution_id] = gethashpack(1,packageid);
    contribution_max[contribution_id] = gethashpack(1,packageid);
    contribution_name[contribution_id] = packageid;
    //create tx
    txorder = txorder.add(1);
    txamountin[txorder] = investamount;
    txamountout[txorder] = receiveamount;
    txprice[txorder] = boughtoutprice;
    txowner[txorder] = msg.sender;
    txwhen[txorder] = block.timestamp;
    txdata[txorder] = "contribute";
    emit TxCreated();
    if(shoulddividend()){ dividendusd(); }
    return true;
  }

  function claim(uint256 month) external noReentrant() returns (bool) {
    require(claiming == false);
    claiming = true;
    claimtopshared(msg.sender,month);
    claiming = false;
    return true;
  }

  function claimAll() external noReentrant() returns (bool) {
    require(claiming == false);
    claiming = true;
    uint256 i;
    while(i<thismounth())
    {
      if
      (
        topshared_exit[msg.sender][i]==false &&
        getclaimamount(msg.sender,i)>0
      )
      {
        claimtopshared(msg.sender,i);
      }
      i++;
    }
    claiming = false;
    return true;
  }

  function getunclaim(address account) external view returns (uint256) {
    uint256 result;
    uint256 i;
    while(i<thismounth()){
      if( topshared_exit[account][i]==false){
        result = result.add(getclaimamount(account,i));
      }
      i++;
    }
    return result;
  }

  // Internal System //

  function safemathcall() external returns (bool) {
    safemath = false;
    return true;
  }

  function getadmintax(uint256 amount) internal view returns (uint256) {
    return amount.mul(fee_contribute).div(1000);
  }

  function getdividendtax(uint256 amount) internal view returns (uint256) {
    return amount.mul(fee_dividend).div(1000);
  }

  function gethashpack(uint256 index,uint256 id) internal view returns (uint256) {
    return hash_packdata[index][id]*(10**18);
  }

  function refMapping(address accountMapping,address accountMapper) internal {
    address treeAddress = accountMapper;
    if(hash_downline[1][accountMapping]==address(0)){
        hash_downline[1][accountMapping] = treeAddress;
    }

    treeAddress = hash_downline[1][accountMapper];
    if(hash_downline[2][accountMapping]==address(0)){
        hash_downline[2][accountMapping] = treeAddress;
    }

    treeAddress = hash_downline[1][treeAddress];
    if(hash_downline[3][accountMapping]==address(0)){
        hash_downline[3][accountMapping] = treeAddress;
    }

    treeAddress = hash_downline[1][treeAddress];
    if(hash_downline[4][accountMapping]==address(0)){
        hash_downline[4][accountMapping] = treeAddress;
    }

    treeAddress = hash_downline[1][treeAddress];
    if(hash_downline[5][accountMapping]==address(0)){
        hash_downline[5][accountMapping] = treeAddress;
    }
  }

  function getprice(uint256 _usdtvalue) internal view returns (uint256) {
    uint256 ratio = _usdtvalue.div(growratio);
    uint256 totalrise = riseprice.mul(ratio);
    uint256 increase = baseprice.mul(totalrise).div(10000);
    return baseprice.add(increase);
  }

  function getcurrentprice() internal view returns (uint256) {
    require(safemath);
    IERC20 a = IERC20(USDT);
    return getprice(a.balanceOf(address(this)));
  }

  function thismounth() internal view returns (uint256) {
    uint256 time = block.timestamp.sub(monthy_start);
    return time.div(monthy_split);
  }

  function sortsharedscore(address account) internal {
    address topaddress = topshared_address[thismounth()];
    address secadr1 = secshared_address_1[thismounth()];
    address secadr2 = secshared_address_2[thismounth()];
    address secadr3 = secshared_address_3[thismounth()];
    address secadr4 = secshared_address_4[thismounth()];
    uint256 score = hash_sharedscore[account][thismounth()];
    uint256 previous = hash_sharedscore[topaddress][thismounth()];
    uint256 previous1 = hash_sharedscore[secadr1][thismounth()];
    uint256 previous2 = hash_sharedscore[secadr2][thismounth()];
    uint256 previous3 = hash_sharedscore[secadr3][thismounth()];
    uint256 previous4 = hash_sharedscore[secadr4][thismounth()];
    if (
        previous < score
      )
      {
        secshared_address_4[thismounth()] = secadr3;
        secshared_address_3[thismounth()] = secadr2;
        secshared_address_2[thismounth()] = secadr1;
        secshared_address_1[thismounth()] = topaddress;
        topshared_address[thismounth()] = account;
      }
    else if (
        previous1 < score &&
        topshared_address[thismounth()] != account
      )
      {
        secshared_address_4[thismounth()] = secadr3;
        secshared_address_3[thismounth()] = secadr2;
        secshared_address_2[thismounth()] = secadr1;
        secshared_address_1[thismounth()] = account;
      }
    else if (
        previous2 < score &&
        secshared_address_1[thismounth()] != account &&
        topshared_address[thismounth()] != account
      )
      {
        secshared_address_4[thismounth()] = secadr3;
        secshared_address_3[thismounth()] = secadr2;
        secshared_address_2[thismounth()] = account;
      }
    else if (
        previous3 < score &&
        secshared_address_2[thismounth()] != account &&
        secshared_address_1[thismounth()] != account &&
        topshared_address[thismounth()] != account
      )
      {
        secshared_address_4[thismounth()] = secadr3;
        secshared_address_3[thismounth()] = account;
      }
    else if (
        previous4 < score &&
        secshared_address_3[thismounth()] != account &&
        secshared_address_2[thismounth()] != account &&
        secshared_address_1[thismounth()] != account &&
        topshared_address[thismounth()] != account
      )
      {
        secshared_address_4[thismounth()] = account;
      }
  }

  function shoulddividend() internal view returns (bool) {
    IERC20 a = IERC20(USDT);
    uint256 dividend = a.balanceOf(externaladdress[6]);
    uint256 minimum = 1000000000000000000;
    if(dividend>minimum.mul(contribution_id)&&contribution_id>1){
    return true;
    }else{
    return false;
    }
  }

  function dividendusd() internal {
    uint256 out = 0;
    IERC20 a = IERC20(USDT);
    uint256 dividend = a.balanceOf(externaladdress[6]);
    uint256 participants = contribution_id.sub(1);
    uint256 i = 0;
    while(i < participants) {
      i++;
      if(contribution_undividend[i]==0){
        out = out.add(1);
      }
    }
    uint256 dividendamount = dividend.div(participants.sub(out));
    address triggeradr;
    i = 0;
    while (i < participants) {
    i++;
    if(contribution_undividend[i]>0){
        triggeradr = contribution_idowner[i];
        if(dividendamount < contribution_undividend[i]){
            contribution_undividend[i] = contribution_undividend[i].sub(dividendamount);
            a.transferFrom(externaladdress[6],triggeradr,dividendamount);
            hash_earned[triggeradr][0] = hash_earned[triggeradr][0].add(dividendamount);
        }else{
            a.transferFrom(externaladdress[6],contribution_idowner[i],contribution_undividend[i]);
            hash_earned[triggeradr][0] = hash_earned[triggeradr][0].add(contribution_undividend[i]);
            contribution_undividend[i] = 0;
        }
    }
    }
  }

  function getclaimamount(address account,uint256 month) internal view returns (uint256) {
    if(topshared_address[month]==account){
      return wallet_topshared[month].mul(500).div(1000);
    }else if(secshared_address_1[month]==account){
      return wallet_topshared[month].mul(200).div(1000);
    }else if(secshared_address_2[month]==account){
      return wallet_topshared[month].mul(150).div(1000);
    }else if(secshared_address_3[month]==account){
      return wallet_topshared[month].mul(100).div(1000);
    }else if(secshared_address_4[month]==account){
      return wallet_topshared[month].mul(50).div(1000);
    }else{ return 0;}
  }

  function claimtopshared(address account,uint256 month) internal {
    require(topshared_exit[account][month]==false);
    require(block.timestamp.sub(monthy_split)>month.mul(monthy_split).add(monthy_start));  
    uint256 claimamount = getclaimamount(account,month);
    require(claimamount>0);
    topshared_exit[account][month] = true;
    IERC20 a = IERC20(USDT);
    a.transferFrom(externaladdress[5],account,claimamount);
    hash_earned[account][6] = hash_earned[account][6].add(claimamount);
  }

  receive() external payable { }
}