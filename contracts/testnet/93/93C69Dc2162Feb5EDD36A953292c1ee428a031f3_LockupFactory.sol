/**
 *Submitted for verification at BscScan.com on 2023-02-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom
	(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Lockup {
    //mu token
    IERC20 public  muToken; 
    address public factory;
    //time 
    uint256[] public  times;
    //Number of rewards
    uint256[]  public nums;
    //Users who can withdraw cash
    mapping(address => bool) public whiteList;

    constructor() 
	{
        factory = msg.sender;
    }
    function setInt(address _token,uint256[] memory _times,uint256[] memory _nums,address[] memory _white) external
	{
        require(msg.sender == factory,"must factory");
        require(_times.length == _nums.length,"length error");
		require(_white.length == 2,"_white length error");
		muToken = IERC20(_token);
		times = _times;
		nums = _nums;
		whiteList[_white[0]] = true;
		whiteList[_white[1]] = true;
    }
    function  getReward() external 
    {
        require(whiteList[msg.sender],"You don't have permission");
        uint num = 0;
        for(uint256 i=0;i<times.length;i++){
           if(block.timestamp > times[i]){
                if( nums[i] > 0){
                    num += nums[i];
                    nums[i] = 0;      
                }              
            }else{
                break;
            }
        }
        
        require(num > 0, "There is no reward to claim");
        muToken.transfer(msg.sender, num);
        
    }

   

}


contract LockupFactory {
 
    Lockup lockup;
    address public owner;
    uint256 public key;
    mapping(uint256 => Lockup) public lockup_list;
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    constructor() {
        owner = msg.sender;
    }
    function createLockup(address _token,uint256[] memory _times,uint256[] memory _nums,address[] memory _white,uint256 _key) external onlyOwner
	{
        require(key == _key,"_key error");
        uint256 num = 0;
        for(uint i=0;i<_nums.length;i++){
            num += _nums[i];
        }
        require(num > 0,"_nums error");

        key = key + 1;
        lockup = new Lockup();
        lockup.setInt(_token,_times,_nums,_white);
        lockup_list[_key] = lockup;
        

        IERC20 muToken = IERC20(_token);
        muToken.transferFrom(msg.sender,address(lockup), num);

    }

    function transferOwnership(address newOwner) public  onlyOwner {
        owner = newOwner;
    }
}