/**
 *Submitted for verification at BscScan.com on 2022-08-29
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.5.10;

interface externalcall {
    function hokcointrigger(address account,uint256 amountETH) external returns (bool);
}

contract Ownable {
    address internal owner;
    constructor(address _owner) public { owner = _owner; }
    modifier onlyOwner() { require(isOwner(msg.sender), "!OWNER"); _; }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
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

contract HoksageMatrix is Ownable {
  using SafeMath for uint256;

  event NewRegister(address indexed account,address invitor);
  event BuyNewSlot(address indexed account,address placeslot,uint256 level);
  event NewCycle(address indexed account,uint256 reinvestcount,uint256 level);

  struct User {
    bool registered;
    address invitor;
    uint256 partnercount;
    mapping(uint256 => bool) activelevel;
    mapping(uint256 => Matrix) matrix;
  }

  struct Matrix {
    address upline;
    address[] referee;
    uint256 reinvestcount;
    mapping(uint256 => Cycle) cycle;
  }

  struct Cycle {
    address[] child;
  }

  address public HOKCOIN;
  address public treasury;
  uint256 public lastid;
  uint256 public contract_invest;

  mapping(address => User) public users;
  mapping(address => uint256) public total_invest;
  mapping(address => uint256) public total_earn_partner;
  mapping(address => uint256) public total_earn_matrix;
  mapping(uint256 => uint256) public cost;

  mapping(address => uint256) public address2id;
  mapping(uint256 => address) public id2address;

  bool reentrantcy;
  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor() public Ownable(msg.sender) {
    cost[1] = 200;
    cost[2] = 400;
    cost[3] = 800;
    cost[4] = 1600;
    cost[5] = 3200;
    cost[6] = 6400;
    cost[7] = 12800;
    cost[8] = 25000;
    cost[9] = 50000;
    cost[10] = 100000;
    cost[11] = 200000;
    cost[12] = 400000;
    cost[13] = 800000;
    cost[14] = 1500000;
    cost[15] = 3000000;
  }

  function finalize(address firstaccount) public onlyOwner() returns (bool) {
    require(!users[firstaccount].registered,"already finalize");

    lastid = lastid.add(1);
    address2id[firstaccount] = lastid;
    id2address[lastid] = firstaccount;

    users[firstaccount].registered = true;
    users[firstaccount].invitor = address(0);
    uint256 i = 1;

    do{
    users[firstaccount].activelevel[i] = true;
    i++;
    }while(i<=15);

    total_invest[firstaccount] = cost[1];

    return true;
  }

  function setTokenAddress(address tokenAddress,address treasuryAddress) public onlyOwner returns (bool) {
    HOKCOIN = tokenAddress;
    treasury = treasuryAddress;
    return true;
  }

  function revokeTokenAddress() public onlyOwner returns (bool) {
    HOKCOIN = address(0);
    treasury = address(0);
    return true;
  }

  function registerExt(address register,address invitor) public payable noReentrant returns (bool) {
    require(!users[register].registered,"this address already registered");
    require(users[invitor].registered,"not found invitor in matrix");
    require(msg.value>=cost[1],"not enought fund");

    lastid = lastid.add(1);
    address2id[register] = lastid;
    id2address[lastid] = register;

    users[register].registered = true;
    users[register].invitor = invitor;
    users[register].activelevel[1] = true;

    users[invitor].partnercount++;

    process(register,invitor,1);

    payment(register,invitor,1);

    emit NewRegister(register,invitor);

    return true;
  }

  function buynewslotExt(address account,uint256 level) external payable noReentrant returns (bool) {
    require(users[account].activelevel[level.sub(1)],"buy previous level first");
    require(!users[account].activelevel[level],"already bought level");
    require(msg.value>=cost[level],"not enought fund");
    require(level>1 && level<=15,"buy level is out of range");
    
    users[account].activelevel[level] = true;

    address place = findReferral(account,level);
    process(account,place,level);

    payment(account,users[account].invitor,level);

    emit BuyNewSlot(account,place,level);

    return true;
  }

  function payment(address account,address invitor,uint256 level) internal returns (bool) {

    uint256 amount = cost[level];
    contract_invest = contract_invest.add(amount);
    total_invest[account] = total_invest[account].add(amount);

    if(HOKCOIN != address(0)){
      safeTransferETH(treasury,per(amount,5));
      externalcall a = externalcall(HOKCOIN);
      a.hokcointrigger(account,amount);
    }else{
      safeTransferETH(owner,per(amount,5));
    }

    safeTransferETH(invitor,per(amount,40));
    total_earn_partner[invitor] = total_earn_partner[invitor].add(per(amount,40));

    address tempaccount;

    tempaccount = getUpline(account,level,0);
    safeTransferETH(tempaccount,per(amount,10));
    total_earn_matrix[tempaccount] = total_earn_matrix[tempaccount].add(per(amount,10));

    tempaccount = getUpline(account,level,1);
    safeTransferETH(tempaccount,per(amount,10));
    total_earn_matrix[tempaccount] = total_earn_matrix[tempaccount].add(per(amount,10));

    tempaccount = getUpline(account,level,2);
    safeTransferETH(tempaccount,per(amount,10));
    total_earn_matrix[tempaccount] = total_earn_matrix[tempaccount].add(per(amount,10));

    address closepart = findClosePart(getUpline(account,level,3),level);
    address checker = getUpline(account,level,1);
    if(checker!=closepart || getUpline(account,level,3)==address(0)){
      tempaccount = getUpline(account,level,3);
      safeTransferETH(tempaccount,per(amount,25));
      total_earn_matrix[tempaccount] = total_earn_matrix[tempaccount].add(per(amount,25));
    }

    return true;
  }

  function isActiveLevels(address account,uint256 level) public view returns (bool) {
    return users[account].activelevel[level];
  }

  function isAccountLevel(address account) public view returns (uint256) {
    uint256 checker;
    uint256 result;
    do{
      checker++;
      if(users[account].activelevel[checker]){
        result = checker;
      }else{
        return result;
      }
    }while(true);
  }

  function getMatrix(address account,uint256 level) public view returns (address,address[] memory,uint256) {
    return
    (
        users[account].matrix[level].upline,
        users[account].matrix[level].referee,
        users[account].matrix[level].reinvestcount
    );
  }

  function getCycle(address account,uint256 level,uint256 cyclecount) public view returns (address[] memory) {
    return users[account].matrix[level].cycle[cyclecount].child;
  }

  function getMatrixMember(address viewer,uint256 level,uint256 viewcycle) public view returns (uint256) {
    address[] memory path = getMatrix32(viewer,level,viewcycle);
    uint256 i;
    uint256 result;
    do{
      result = result.add(users[path[i]].partnercount);
      i++;
    }while(i<path.length);
    return result;
  }

  function getMatrix32(address viewer,uint256 level,uint256 viewcycle) public view returns (address[] memory){
    address[] memory path = new address[](32);
    path[0] = address(0);
    path[1] = viewer;
    if(users[viewer].matrix[level].cycle[viewcycle].child.length==2){
      path[2] = users[viewer].matrix[level].cycle[viewcycle].child[0];
      path[3] = users[viewer].matrix[level].cycle[viewcycle].child[1];
    }else{
      path[2] = getMatrixTree(viewer,level,0,false);
      path[3] = getMatrixTree(viewer,level,1,false);
    }
    path[4] = getMatrixTree(path[2],level,0,true);
    path[5] = getMatrixTree(path[2],level,1,true);
    path[6] = getMatrixTree(path[3],level,0,true);
    path[7] = getMatrixTree(path[3],level,1,true);
    path[8] = getMatrixTree(path[4],level,0,true);
    path[9] = getMatrixTree(path[4],level,1,true);
    path[10] = getMatrixTree(path[5],level,0,true);
    path[11] = getMatrixTree(path[5],level,1,true);
    path[12] = getMatrixTree(path[6],level,0,true);
    path[13] = getMatrixTree(path[6],level,1,true);
    path[14] = getMatrixTree(path[7],level,0,true);
    path[15] = getMatrixTree(path[7],level,1,true);
    path[16] = getMatrixTree(path[8],level,0,true);
    path[17] = getMatrixTree(path[8],level,1,true);
    path[18] = getMatrixTree(path[9],level,0,true);
    path[19] = getMatrixTree(path[9],level,1,true);
    path[20] = getMatrixTree(path[10],level,0,true);
    path[21] = getMatrixTree(path[10],level,1,true);
    path[22] = getMatrixTree(path[11],level,0,true);
    path[23] = getMatrixTree(path[11],level,1,true);
    path[24] = getMatrixTree(path[12],level,0,true);
    path[25] = getMatrixTree(path[12],level,1,true);
    path[26] = getMatrixTree(path[13],level,0,true);
    path[27] = getMatrixTree(path[13],level,1,true);
    path[28] = getMatrixTree(path[14],level,0,true);
    path[29] = getMatrixTree(path[14],level,1,true);
    path[30] = getMatrixTree(path[15],level,0,true);
    path[31] = getMatrixTree(path[15],level,1,true);
    return path;
  }

  function getMatrixTree(address account,uint256 level,uint256 branch,bool viewasroot) internal view returns (address) {
    if(account == address(0)){ return address(0); }
    if(users[account].matrix[level].reinvestcount>0 && viewasroot){
      return users[account].matrix[level].cycle[0].child[branch];
    }else{
      if(branch==0 && users[account].matrix[level].referee.length>0){
        return users[account].matrix[level].referee[branch];
      }else
      if(branch==1 && users[account].matrix[level].referee.length==2){
        return users[account].matrix[level].referee[branch];
      }else{
        return address(0);
      }
    }
  }

  function isColor(address account,address viewer,uint256 level) external view returns (uint256) {
    if(users[account].invitor == address(0) ){
      return 1;
    }else if(users[account].invitor == viewer){
      return 2;
    }else if(
      users[account].invitor == getUpline(viewer,level,0)
      || users[account].invitor == getUpline(viewer,level,1)
      || users[account].invitor == getUpline(viewer,level,2)
      || users[account].invitor == getUpline(viewer,level,3)
    ){
      return 3;
    }else{
      return 4;
    }
  }

  function process(address register,address invitor,uint256 level) internal {
    signMatrix(register,invitor,level);
    if(shouldReinvest(register,level)){
        address reinvestaccount = getUpline(register,level,3);
        uint256 currentcycle = users[reinvestaccount].matrix[level].reinvestcount;
        users[reinvestaccount].matrix[level].cycle[currentcycle].child = users[reinvestaccount].matrix[level].referee;
        users[reinvestaccount].matrix[level].referee = new address[](0);
        users[reinvestaccount].matrix[level].reinvestcount = currentcycle.add(1);
        emit NewCycle(reinvestaccount,currentcycle.add(1),level);
        payment(reinvestaccount,users[reinvestaccount].invitor,level);
    }
  }

  function signMatrix(address register,address invitor,uint256 level) internal {
    if(users[invitor].matrix[level].referee.length<2){

        users[invitor].matrix[level].referee.push(register);
        users[register].matrix[level].upline = invitor;

    }else{

        address[] memory root = new address[](2);
        root[0] = users[invitor].matrix[level].referee[0];
        root[1] = users[invitor].matrix[level].referee[1];

        if(users[root[0]].matrix[level].referee.length<2){

            users[root[0]].matrix[level].referee.push(register);
            users[register].matrix[level].upline = root[0];

        }else
        if(users[root[1]].matrix[level].referee.length<2){

            users[root[1]].matrix[level].referee.push(register);
            users[register].matrix[level].upline = root[1];

        }else{

            address[] memory branch = new address[](4);
            branch[0] = users[root[0]].matrix[level].referee[0];
            branch[1] = users[root[0]].matrix[level].referee[1];
            branch[2] = users[root[1]].matrix[level].referee[0];
            branch[3] = users[root[1]].matrix[level].referee[1];

            if(users[branch[0]].matrix[level].referee.length<2){

                users[branch[0]].matrix[level].referee.push(register);
                users[register].matrix[level].upline = branch[0];

            }else
            if(users[branch[1]].matrix[level].referee.length<2){

                users[branch[1]].matrix[level].referee.push(register);
                users[register].matrix[level].upline = branch[1];

            }else
            if(users[branch[2]].matrix[level].referee.length<2){

                users[branch[2]].matrix[level].referee.push(register);
                users[register].matrix[level].upline = branch[2];
                
            }else
            if(users[branch[3]].matrix[level].referee.length<2){

                users[branch[3]].matrix[level].referee.push(register);
                users[register].matrix[level].upline = branch[3];
                
            }else{

                address[] memory rootlet = new address[](8);
                rootlet[0] = users[branch[0]].matrix[level].referee[0];
                rootlet[1] = users[branch[0]].matrix[level].referee[1];
                rootlet[2] = users[branch[1]].matrix[level].referee[0];
                rootlet[3] = users[branch[1]].matrix[level].referee[1];
                rootlet[4] = users[branch[2]].matrix[level].referee[0];
                rootlet[5] = users[branch[2]].matrix[level].referee[1];
                rootlet[6] = users[branch[3]].matrix[level].referee[0];
                rootlet[7] = users[branch[3]].matrix[level].referee[1];

                if(users[rootlet[0]].matrix[level].referee.length<2){

                    users[rootlet[0]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[0];

                }else
                if(users[rootlet[1]].matrix[level].referee.length<2){

                    users[rootlet[1]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[1];

                }else
                if(users[rootlet[2]].matrix[level].referee.length<2){

                    users[rootlet[2]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[2];

                }else
                if(users[rootlet[3]].matrix[level].referee.length<2){

                    users[rootlet[3]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[3];

                }else
                if(users[rootlet[4]].matrix[level].referee.length<2){

                    users[rootlet[4]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[4];

                }else
                if(users[rootlet[5]].matrix[level].referee.length<2){

                    users[rootlet[5]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[5];

                }else
                if(users[rootlet[6]].matrix[level].referee.length<2){

                    users[rootlet[6]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[6];

                }else
                if(users[rootlet[7]].matrix[level].referee.length<2){

                    users[rootlet[7]].matrix[level].referee.push(register);
                    users[register].matrix[level].upline = rootlet[7];

                }else{
                    
                    revert("revert by matrix sign");

                }

            }

        }

    }
  }

  function getUpline(address account,uint256 level,uint256 layer) internal view returns (address) {
    address[] memory upline = new address[](4);
    upline[0] = users[account].matrix[level].upline;
    upline[1] = users[upline[0]].matrix[level].upline;
    upline[2] = users[upline[1]].matrix[level].upline;
    upline[3] = users[upline[2]].matrix[level].upline;
    return upline[layer];
  }

  function shouldReinvest(address account,uint256 level) internal view returns (bool) {
    if(account==address(0)){ return false; }
    address host = getUpline(account,level,3);
    uint256 currentcycle = users[host].matrix[level].reinvestcount;
    address[] memory checkerMatrix = getMatrix32(host,level,currentcycle);
    if(
      checkerMatrix[16] != address(0) &&
      checkerMatrix[17] != address(0) &&
      checkerMatrix[18] != address(0) &&
      checkerMatrix[19] != address(0) &&
      checkerMatrix[20] != address(0) &&
      checkerMatrix[21] != address(0) &&
      checkerMatrix[22] != address(0) &&
      checkerMatrix[23] != address(0) &&
      checkerMatrix[24] != address(0) &&
      checkerMatrix[25] != address(0) &&
      checkerMatrix[26] != address(0) &&
      checkerMatrix[27] != address(0) &&
      checkerMatrix[28] != address(0) &&
      checkerMatrix[29] != address(0) &&
      checkerMatrix[30] != address(0) &&
      checkerMatrix[31] != address(0)
    ){
      return true;
    }else{
      return false;
    }
  }

  function findClosePart(address account,uint256 level) internal view returns (address) {
    if(account==address(0)){ return address(0); }
    address host = getUpline(account,level,3);
    uint256 currentcycle = users[host].matrix[level].reinvestcount;
    address[] memory closepart = getMatrix32(account,level,currentcycle);
    return closepart[7];
  }

  function findReferral(address account,uint256 level) internal view returns (address) {
    do{
      if(users[users[account].invitor].activelevel[level]){
        return users[account].invitor;
      }else if(account!=address(0)){
        account = users[account].invitor;
      }else{
        return address(0);
      }
    }while(true);
  }

  function rate(uint256 amount,uint256 percentage,uint256 denominator) internal pure returns (uint256) {
    return amount.mul(percentage).div(denominator);
  }

  function transferETH(address recipient,uint256 amount) internal returns (bool) {
    if(recipient==address(0)){ recipient=owner; }
    if(amount>0){ address(uint160(recipient)).transfer(amount); }
    return true;
  }

  function batchregister(address[] calldata accounts,address invitor) external returns (bool) {
    require(users[invitor].registered,"ref address does not exit");

    uint256 i = 0;
    do{

        address register = accounts[i];
        require(!users[register].registered,"account(s) registered error");

        lastid = lastid.add(1);
        address2id[register] = lastid;
        id2address[lastid] = register;

        users[register].registered = true;
        users[register].invitor = invitor;
        users[register].activelevel[1] = true;

        users[invitor].partnercount++;

        process(register,invitor,1);

        emit NewRegister(register,invitor);
        i++;
      
    }while(i<accounts.length);

    return true;
  }

  function per(uint256 amount,uint256 percentage) internal pure returns (uint256) {
    return amount.mul(percentage).div(100);
  }
  
  function safeTransferETH(address recipient,uint256 amount) internal returns (bool) {
    if(recipient==address(0)){ recipient = owner; }
    address(uint160(recipient)).transfer(amount);
    return true;
  }

  function purge() external onlyOwner returns (bool) {
    address(uint160(msg.sender)).transfer(address(this).balance);
    return true;
  }
}