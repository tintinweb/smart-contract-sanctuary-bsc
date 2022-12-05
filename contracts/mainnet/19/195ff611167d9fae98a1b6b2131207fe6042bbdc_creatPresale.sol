/**
 *Submitted for verification at BscScan.com on 2022-12-05
*/

/**
 *Submitted for verification at BscScan.com on 2022-09-04
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
    //预售合约
    contract creatPresale{
    //认购的usdtToken转到哪个地址
    address public owner;
    //认购的金额
    uint public money;
    //认购的数量
    uint public mount;
    //以什么币为认购token
    address public usdtToken;
    //用户认购什么token
    address public presaleToken;
    //每个人只能认购一次，认购后为bool为false,认购代币直接转到认购人的账户无需自己领取
    mapping(address=>bool) public judgeSale;
     //认购开始时间
    uint public startTime;
    //认购结束时间
    uint public endTime;
    //合约中token余额
    uint public tokenBalance;
    
    //构造函数设置权限人
    constructor() payable{
        owner =msg.sender;
    }
    //函数修改器
      modifier onlyOwner(){
          require(msg.sender==owner,'isnot owner');
          _;
      }
    //设置认购的参数
    function setPresaleData(uint _mount,uint _money,address _usdtToken,address _presaleToken,uint _startTime,uint _endTime) external onlyOwner{
         mount= _mount*10**18;
        money=_money*10**18;
        usdtToken=_usdtToken;
        presaleToken=_presaleToken;
        startTime=_startTime;
        endTime=_endTime;
    }
    //查询合约中要发的币的余额
    function setSendToken() external{
         IERC20 presaleTokenUser= IERC20(presaleToken);
        //合约中需要发放的token
        tokenBalance = presaleTokenUser.balanceOf(address(this));
    }
       function getSendToken() view external returns(uint){
         IERC20 presaleTokenUser= IERC20(presaleToken);
        //合约中需要发放的token
        return presaleTokenUser.balanceOf(address(this));
    }
    //认购时候将代币转到项目方的钱包，并且把token转到用户的钱包
    function userClaim(address _invitor) external{
        //认购需要转的token和项目方发放的token
       IERC20 usdtTokenUser= IERC20(usdtToken);
       IERC20 presaleTokenUser= IERC20(presaleToken);
        //必须是预售已经开始但是还未结束并且账户内的token足够并且每个人只能认购一次
       require(block.timestamp>=startTime,'Pre sale has not started yet');
       require(block.timestamp<=endTime,'The pre-sale has ended');
      require(tokenBalance>mount,'Insufficient token, please contact the administrator');
       require(judgeSale[msg.sender]!=true,'You have participated in the subscription');
        //向项目方转币
        usdtTokenUser.transferFrom(msg.sender, owner, money/10*8);
        //向推荐人转币
        usdtTokenUser.transferFrom(msg.sender, _invitor, money/10*2);
       //合约向用户转币
       presaleTokenUser.transfer(msg.sender, mount);
       //成功后将用户打入黑名单不可在认购
       judgeSale[msg.sender]=true;
    }
    //权限拥有者可以将众筹合约中的代币全部取出来
       function claimBalance() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount, address to) external onlyOwner {
        IERC20(token).transfer(to, amount);
    }
     receive() external payable {}
}