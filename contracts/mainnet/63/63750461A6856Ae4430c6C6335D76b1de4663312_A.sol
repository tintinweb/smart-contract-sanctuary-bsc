/**
 *Submitted for verification at BscScan.com on 2022-09-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-07-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract A {
    //0xFd76C87B72A74455409EDe7255085afc96a1a23a 0x1c7E83f8C581a967940DBfa7984744646AE46b29
    IERC20 ftts = IERC20(0x669765d450e92d79fEBbB966a1eAD054cb62F33b);
    // address owner = 0x097287349aCa67cfF56a458DcF11BbaE54565540;
    // address father;
    // constructor() public  {
       
    // }
    address admin = msg.sender;
    struct CHAIN{
        address addr;
        uint amount;
    }
    event  CROSS(
        uint indexed  sum,
        address addr,
        uint amount
    );
    uint public  sum_all =1 ;
    mapping(uint =>CHAIN) public  money;
    function isApprove(address addr) external view  returns(uint){
       return  ftts.allowance(addr, address(this)); 
    }
    function setAdmin(address addr)external {
        require(msg.sender ==admin,"no admin");
        admin = addr;
    }
    function cross(uint amount)external {
        require(amount>0,"<0");
        require(ftts.allowance(msg.sender, address(this))>=amount,"allow<amount"); 
        ftts.transferFrom(msg.sender, address(0x252d1Afd05c384157522AA10fa93C969953dec66), amount);
        CHAIN memory aa = CHAIN(msg.sender,amount);
        money[sum_all] = aa;
        emit CROSS(sum_all,
                   msg.sender,
                   amount
                    );
        sum_all+=1;
    }
    // CHAIN bb =CHAIN(msg.sender,123);
    function getC(uint num)external view  returns(address, uint){
        CHAIN memory bb = money[num]; 
        return (bb.addr,bb.amount);
    }
}