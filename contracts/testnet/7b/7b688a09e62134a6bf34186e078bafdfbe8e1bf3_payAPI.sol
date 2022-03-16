/**
 *Submitted for verification at BscScan.com on 2022-03-16
*/

/**
 *Submitted for verification at BscScan.com on 2021-11-28
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract payAPI {
    mapping(string=>mapping(address=>payItem)) public payInfo ; 
    mapping(address=>bool) public VIP ; 
    address public  admin ;
    struct payItem{
        uint createTime ;
        uint value ;
    }


    function _addPayInfo(string memory payName_,address user_) external payable  returns(bool){
        payInfo[payName_][user_] = payItem(block.timestamp,msg.value);
        payable(admin).transfer(msg.value);
        return true  ;
    }

    function withdraw() public onlyAdmin{
        payable(admin).transfer(address(this).balance);
    }


    function addMember(address member_) public onlyAdmin{
        VIP[member_] = true ;
        payInfo["VIP"][member_] = payItem(block.timestamp,100 ether);
    }

    function becomeVIP(address _addr) payable external {
        payInfo["VIP"][_addr] = payItem(block.timestamp,msg.value);
        VIP[_addr] = true ;
    }

    function changeAdmin(address admin_) external onlyAdmin{
        admin = admin_ ;
    }


    function payStatus(string memory _project,address _addr) public view returns(bool _VIP,uint _createTime,uint _value) {
        _createTime = payInfo[_project][_addr].createTime;
        _value = payInfo[_project][_addr].value;
        return (VIP[_addr],_createTime,_value);
    }

    modifier onlyAdmin{
        require(msg.sender == admin ,"You are not admin");
        _;
    }


    receive() external payable {
        payable(admin).transfer(address(this).balance);
    }

    constructor(){
        admin = msg.sender ;
        payInfo["VIP"][admin] = payItem(block.timestamp,100 ether);
        VIP[admin] = true ;
    }
}