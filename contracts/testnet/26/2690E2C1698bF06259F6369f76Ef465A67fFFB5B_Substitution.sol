/**
 *Submitted for verification at BscScan.com on 2022-07-29
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.0;

interface GlodContract{
    function decimals() external view returns (uint8);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
}

contract Substitution{

    //置换对
    mapping(uint256=>path) public SubstitutionPath;
    struct path{
        address  frompath_;//来源代币地址
        address  topath_;//目标代币地址
        address  collect_;//收取来源代币地址
        uint256  proportion_;//置换百分比
    }
    address public _owner;//管理员
    modifier Owner {
        require(_owner == msg.sender);
        _;
    }
    constructor(){
        _owner = msg.sender;
    }
    
    //设置置换对
    function setSubstitutionPath(uint256 Path_,address frompath_,address topath_,address collect_,uint256 proportion_) 
        public 
        Owner 
        returns (bool){
            SubstitutionPath[Path_] = path(frompath_,topath_,collect_,proportion_);
            return true;
        }
    //置换
    function toSubstitution(uint256 Path_,uint256 amount_)
        public
        returns (bool){
            require(SubstitutionPath[Path_].frompath_ != address(0),"Displacement pair from does not exist");
            require(SubstitutionPath[Path_].topath_ != address(0),"Displacement pair to does not exist");
            require(SubstitutionPath[Path_].collect_ != address(0),"Displacement pair collect does not exist");
            require(SubstitutionPath[Path_].proportion_ != 0,"Displacement pair proportion is 0");
            GlodContract fromglod = GlodContract(SubstitutionPath[Path_].frompath_);
            GlodContract toglod = GlodContract(SubstitutionPath[Path_].topath_);
            fromglod.transferFrom(msg.sender,SubstitutionPath[Path_].collect_,amount_);
            toglod.transfer(msg.sender,amount_*SubstitutionPath[Path_].proportion_/100);
            return true;
        }
    //赎回from币
    function redeem(address glod_,address to_,uint256 amount_) 
        public 
        Owner 
        returns (bool){
            GlodContract glod = GlodContract(glod_);
            glod.transfer(to_,amount_);
            return true;
        }

}