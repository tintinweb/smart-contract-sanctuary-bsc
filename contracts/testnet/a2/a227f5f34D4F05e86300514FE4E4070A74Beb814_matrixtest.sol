/**
 *Submitted for verification at BscScan.com on 2022-08-12
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

abstract contract Ownable {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
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

contract matrixtest is Ownable {
  using SafeMath for uint256;

  struct User {
    bool registered;
    address referral;
    mapping(uint256 => bool) activeLevels;
    mapping(uint256 => uint256) totalearn;
  }

  struct Matrix {
    address currentreferral;
    address[] reffereeLv1;
    address[] reffereeLv2;
    address closepart;
    uint256 partnercount;
    uint256 reinvest;
  }

  mapping(address => User) private users;
  mapping(address => mapping(uint256 => Matrix)) private matrix;
  
  uint256 private registered;
  uint256 private denominator;
  bool private ispause;
  bool private reentrantcy;

  mapping(address => uint256) private getidfromaddress;
  mapping(uint256 => address) private getaddressfromid;

  mapping(uint256 => uint256) private refdividend;
  mapping(uint256 => uint256) private levelprice;

  modifier noReentrant() {
    require(!reentrantcy);
    reentrantcy = true;
    _;
    reentrantcy = false;
  }

  constructor() Ownable(msg.sender) {
    
    registeration(address(this),address(0),0);

    refdividend[0] = 400;
    refdividend[1] = 110;
    refdividend[2] = 115;
    refdividend[3] = 125;
    refdividend[4] = 250;

    denominator = 1000;

    levelprice[0] = 100;
    uint256 i = 0;
    while (i < 15) {
      i++;
      levelprice[i] = levelprice[i-1].mul(2);
    }

  }

  function totaluser() external view returns (uint256) { return registered; }
  function isRegistered(address account) external view returns (bool) { return users[account].registered; }
  function isActiveLevels(address account,uint256 level) external view returns (bool) { return users[account].activeLevels[level]; }
  function refertoaddress(address account) external view returns (address) { return users[account].referral; }
  function isPause() external view returns (bool) { return ispause; }
  function getRefDividend(uint256 level) external view returns (uint256) { return refdividend[level]; }
  function getLevelPrice(uint256 level) external view returns (uint256) { return levelprice[level]; }
  function id2address(uint256 id) external view returns (address) { return getaddressfromid[id]; }
  function address2id(address account) external view returns (uint256) { return getidfromaddress[account]; }

  function switchSystem() external onlyOwner() returns (bool) {
    ispause = !ispause;
    return true;
  }

  function getMatrixFromId(uint256 id,uint256 level) external view returns
    (
    address,
    address[] memory,
    address[] memory,
    address,
    uint256,
    uint256
    ) {
    address account = getaddressfromid[id];
    return (
      matrix[account][level].currentreferral,
      matrix[account][level].reffereeLv1,
      matrix[account][level].reffereeLv2,
      matrix[account][level].closepart,
      matrix[account][level].partnercount,
      matrix[account][level].reinvest
    );
  }

  function getMatrix(address account,uint256 level) external view returns
    (
    address,
    address[] memory,
    address[] memory,
    address,
    uint256,
    uint256
    ) {
    return (
      matrix[account][level].currentreferral,
      matrix[account][level].reffereeLv1,
      matrix[account][level].reffereeLv2,
      matrix[account][level].closepart,
      matrix[account][level].partnercount,
      matrix[account][level].reinvest
    );
  }

  function registerationExt(address account,address ref) external payable noReentrant() returns (bool) {
    require(!ispause,"registeration fail : contract was temporary pause");
    require(!users[account].registered,"registeration fail : already registered");
    require(users[ref].registered,"registeration fail : not found reference in matrix");
    require(msg.value>=levelprice[1],"registeration fail : ext not enought fund");
    registeration(account,ref,msg.value);
    return true;
  }

  function batchregister(address[] memory accounts,address ref) external returns (bool) {
    require(users[ref].registered,"registeration fail : not found reference in matrix");
    uint256 i = 0;
    do{
      require(!users[accounts[i]].registered,"registeration fail : already registered");
      registeration(accounts[i],ref,0);
      i++;
    }while(i<accounts.length);
    return true;
  }

  function registerationForce(address account,address ref) external onlyOwner() returns (bool) {
    require(!users[account].registered,"registeration fail : already registered");
    require(users[ref].registered,"registeration fail : not found reference in matrix");
    registeration(account,ref,0);
    return true;
  }

  function registeration(address register,address ref,uint256 amount) internal {
    registered = registered.add(1);
    getidfromaddress[register] = registered;
    getaddressfromid[registered] = register;
    users[register].registered = true;
    users[register].referral = ref;
    users[register].activeLevels[1] = true;

    registerprocess(register,ref,1);

    if(amount>0){
      address[] memory receiver = new address[](5);
      uint256[] memory sendValue = new uint256[](5);
      receiver[0] = safeRecaiver(ref);
      receiver[1] = safeRecaiver(getRecycleMatrix(register,1,1));
      receiver[2] = safeRecaiver(getRecycleMatrix(register,1,2));
      receiver[3] = safeRecaiver(getRecycleMatrix(register,1,3));
      receiver[4] = safeRecaiver(getRecycleMatrix(register,1,4));
      sendValue[0] = amount.mul(refdividend[0]).div(denominator);
      sendValue[1] = amount.mul(refdividend[1]).div(denominator);
      sendValue[2] = amount.mul(refdividend[2]).div(denominator);
      sendValue[3] = amount.mul(refdividend[3]).div(denominator);
      sendValue[4] = amount.mul(refdividend[4]).div(denominator);
      safeTransfer(receiver[0],sendValue[0]);
      safeTransfer(receiver[1],sendValue[1]);
      safeTransfer(receiver[2],sendValue[2]);
      safeTransfer(receiver[3],sendValue[3]);
      safeTransfer(receiver[4],sendValue[4]);
    }

  }

  function registerprocess(address register,address ref,uint256 level) internal {
    updateMatrixFirst(register,ref,level);
    if(shouldUpdateCycle(register,level)){
      address reinvestaddress = getRecycleMatrix(register,level,4);
      matrix[reinvestaddress][level].reffereeLv1 = new address[](0);
      matrix[reinvestaddress][level].reffereeLv2 = new address[](0);
      matrix[reinvestaddress][level].closepart = address(0);
      matrix[reinvestaddress][level].reinvest++;
      registerprocess(reinvestaddress,matrix[reinvestaddress][level].currentreferral,level);
    }
  }

  function updateMatrixFirst(address register,address ref,uint256 level) internal {
    if(matrix[ref][level].reffereeLv1.length<2){

      matrix[ref][level].reffereeLv1.push(register);
      matrix[matrix[ref][level].currentreferral][level].reffereeLv2.push(register);
      matrix[register][level].currentreferral = ref;
      matrix[ref][level].partnercount++;

    }else{

      address branch_left = matrix[ref][level].reffereeLv1[0];
      address branch_right = matrix[ref][level].reffereeLv1[1];

      if(matrix[branch_left][level].reffereeLv1.length<2){

        matrix[branch_left][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_left;
        matrix[branch_left][level].partnercount++;
        matrix[ref][level].partnercount++;

      }else if(matrix[branch_right][level].reffereeLv1.length<2){

        matrix[branch_right][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_right;
        matrix[branch_right][level].partnercount++;
        matrix[ref][level].partnercount++;

        if(matrix[branch_right][level].reffereeLv1.length==2){
        matrix[ref][level].closepart = register;
        }

      }else{

        if(matrix[branch_left][level].reffereeLv2.length<4){
          
          updateMatrixSecond(register,branch_left,level);
          if(matrix[branch_left][level].reffereeLv2.length==4){
            matrix[branch_left][level].closepart = register;
          }

        }else if(matrix[branch_right][level].reffereeLv2.length<4){

          updateMatrixSecond(register,branch_right,level);
          if(matrix[branch_right][level].reffereeLv2.length==4){
            matrix[branch_right][level].closepart = register;
          }

        }else{

          address sub_branch_0 = matrix[ref][level].reffereeLv2[0];
          address sub_branch_1 = matrix[ref][level].reffereeLv2[1];
          address sub_branch_2 = matrix[ref][level].reffereeLv2[2];
          address sub_branch_3 = matrix[ref][level].reffereeLv2[3];

          if(matrix[sub_branch_0][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_0,level);
            if(matrix[sub_branch_0][level].reffereeLv2.length==4){
            matrix[sub_branch_0][level].closepart = register;
            }

          }else if(matrix[sub_branch_1][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_1,level);
            if(matrix[sub_branch_1][level].reffereeLv2.length==4){
            matrix[sub_branch_1][level].closepart = register;
            }

          }else if(matrix[sub_branch_2][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_2,level);
            if(matrix[sub_branch_2][level].reffereeLv2.length==4){
            matrix[sub_branch_2][level].closepart = register;
            }

          }else if(matrix[sub_branch_3][level].reffereeLv2.length<4){

            updateMatrixSecond(register,sub_branch_3,level);
            if(matrix[sub_branch_3][level].reffereeLv2.length==4){
            matrix[sub_branch_3][level].closepart = register;
            }

          }else{
            revert();
          }

        }

      }
    }
  }

  function updateMatrixSecond(address register,address ref,uint256 level) internal {
    if(matrix[ref][level].reffereeLv1.length<2){

      matrix[ref][level].reffereeLv1.push(register);
      matrix[matrix[ref][level].currentreferral][level].reffereeLv2.push(register);
      matrix[register][level].currentreferral = ref;
      matrix[ref][level].partnercount++;

    }else{

      address branch_left = matrix[ref][level].reffereeLv1[0];
      address branch_right = matrix[ref][level].reffereeLv1[1];

      if(matrix[branch_left][level].reffereeLv1.length<2){

        matrix[branch_left][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_left;
        matrix[branch_left][level].partnercount++;
        matrix[ref][level].partnercount++;

      }else if(matrix[branch_right][level].reffereeLv1.length<2){

        matrix[branch_right][level].reffereeLv1.push(register);
        matrix[ref][level].reffereeLv2.push(register);
        matrix[register][level].currentreferral = branch_right;
        matrix[branch_right][level].partnercount++;
        matrix[ref][level].partnercount++;

        if(matrix[branch_right][level].reffereeLv1.length==2){
        matrix[ref][level].closepart = register;
        }

      }

    }
  }

  function shouldUpdateCycle(address account,uint256 level) internal view returns (bool) {
    address upperMatrix = matrix[account][level].currentreferral;
    address checkerMatrix = matrix[upperMatrix][level].currentreferral;
    address minorMatrix = matrix[checkerMatrix][level].currentreferral;
    address alphaMatrix = matrix[minorMatrix][level].currentreferral;

    address[] memory sub_branch = matrix[alphaMatrix][level].reffereeLv2;

    if(
      alphaMatrix != address(0) &&
      matrix[sub_branch[0]][level].closepart != address(0) &&
      matrix[sub_branch[1]][level].closepart != address(0) &&
      matrix[sub_branch[2]][level].closepart != address(0) &&
      matrix[sub_branch[3]][level].closepart != address(0)
    ){
      return true;
    }else{
      return false;
    }

  }

  function getRecycleMatrix(address account,uint256 level,uint256 upline) internal view returns (address) {
    address upperMatrix = matrix[account][level].currentreferral;
    address checkerMatrix = matrix[upperMatrix][level].currentreferral;
    address minorMatrix = matrix[checkerMatrix][level].currentreferral;
    address alphaMatrix = matrix[minorMatrix][level].currentreferral;
    if(upline==1){
    return upperMatrix;
    }else if(upline==2){
    return checkerMatrix;
    }else if(upline==3){
    return minorMatrix;
    }else if(upline==4){
    return alphaMatrix;
    }else{
    return owner;
    }
  }

  function safeRecaiver(address account) internal view returns (address) {
    if(account==address(0)){
      return owner;
    }else{
      return account;
    }
  }

  function safeTransfer(address recipient,uint256 amount) internal returns (bool) {
    (bool success, ) = recipient.call{ value : amount }("");
    require(success,"safe transfer fail!");
    return true;
  }

}