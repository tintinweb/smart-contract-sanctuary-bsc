/*
    Copyright 2020 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    SPDX-License-Identifier: Apache License, Version 2.0
*/

pragma solidity 0.6.10;

import { poor } from "./pool.sol";

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function burn(address account, uint256 amount) external;
        
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IBEP20 {
  /**
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external view returns (uint8);

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external view returns (string memory);

  /**
  * @dev Returns the token name.
  */
  function name() external view returns (string memory);

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view returns (address);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `recipient`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address _owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * IMPORTANT: Beware that changing an allowance with this method brings the risk
   * that someone may use both the old and the new allowance by unfortunate
   * transaction ordering. One possible solution to mitigate this race
   * condition is to first reduce the spender's allowance to 0 and set the
   * desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * Emits an {Approval} event.
   */
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `sender` to `recipient` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  /**
   * @dev Emitted when `value` tokens are moved from one account (`from`) to
   * another (`to`).
   *
   * Note that `value` may be zero.
   */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /**
   * @dev Emitted when the allowance of a `spender` for an `owner` is set by
   * a call to {approve}. `value` is the new allowance.
   */
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Defi is poor{
    
    /*----------------参数-------------------*/

    //每日奖励的数量
    uint256 public dayRewardAmount = 2660;

    address BDD = 0xeb8e1A39FC308da4D50D4bf5633Ec42B7e1dD41d;
    address DAC = 0x696Db825D84656F07FC33be21eE5a586b3b286cA;
    address NBB = 0x5300A338D637376806d1d5C1dEf07614FCfC1645;

    IERC20 BDDInterface = IERC20(BDD);
    IERC20 DACInterface = IERC20(DAC);
    IERC20 NBBInterface = IERC20(NBB);

    //币安主链的usdt合约地址
    //address usdt = 0x55d398326f99059fF775485246999027B3197955;

    //自己在测网部署的
    address usdt = 0x1Caf155270E80aEF65665Ff2aF7b4e884597e38b;
    //USDT稳定币合约导入
    IBEP20 usdtInterface = IBEP20(usdt);
    
    /*--------------------事件--------------------*/

    //买入后触发
    event Purchase(address indexed _buyer, uint256 indexed amount);
    
    //提现后触发
    event WithDraw(address indexed _withDrawer, uint256 indexed amount);
    
   
    

    //每日分红一次
    function Reward() public onlyOwner returns(bool){
        
        //设置一个冷却时间   ----------------< 待完成

        //pool记录奖励总量 执行奖励函数则会奖励一次
        totalRewards = totalRewards + dayRewardAmount;
        
        //获取总用户数量
        uint256 UserNumber = getUserNumber();

        for(uint256 i =0 ;i < UserNumber ; i++ ){

            //确定每个地址的每日的分红量  DAC个人产币数据 =（个人债券持有张数\全网总债券张数）•每日DAC产出量----------<等待改动  小数会出问题
            uint256 dayEveryUserReward = (((userBDDAMount[vips[i]]*100000000) / allUserBDDAmount) * dayRewardAmount)/100000000;

            //DAC每日分红的时候不需要转给他们,等他们提现的时候转给他们
            userRewards[vips[i]] = userRewards[vips[i]] + dayEveryUserReward;

        }
    }


    //买入方法    转入usdt 和 社区代币  --将usdt进行转账 --社区代币销毁
    function purchase(address _buyer,uint256 _usdtamount,uint256 _NBBamount) public {
        
        //之前已经买过的话那已经有了数据 直接修改对的拥有量
        uint256 amount = _usdtamount + _NBBamount ;
        
        //记录全网所有用户拥有的债券数量
        allUserBDDAmount = allUserBDDAmount + amount;

        if(isVip[_buyer] == true){
            
            //修改用户对应的债券数量
            userBDDAMount[_buyer] + amount;

            //将对应债券数量从合约转给用户 在债券合约部署以后需要将代币的权益授权给合约
            BDDInterface.transferFrom(address(this),_buyer,amount);
           
            //按比例把usdt分别转账给三个金库地址和流动池----等待完成，如何使用小数-----<<<<<<等待搞定
            //97%三个地址分443   3%进入流动性矿池
            //usdtInterface.transferFrom(msg.sender,treasuryList[0],(_usdtamount*97)/100);
            //usdtInterface.transferFrom(msg.sender,treasuryList[1],(_usdtamount*3)/100);
            
            //记录USDT销毁总量
            destroiedUSDT = destroiedUSDT + _usdtamount;

            //社区代币直接销毁
            //NBBInterface.burn(_buyer,_NBBamount);

            //记录销毁总量
            destroiedNBB = destroiedNBB +_NBBamount;
            
        }else{

            //加入VIP
            vips.push(_buyer);
            
            //是否为VIP-->true
            isVip[_buyer] = true;

            //修改用户对应的债券数量
            userBDDAMount[_buyer] = userBDDAMount[_buyer] + amount;

            //将对应债券数量从合约转给用户 在债券合约部署以后需要将代币的权益授权给合约
            BDDInterface.transferFrom(address(this),_buyer,amount);
           
            
            //usdtInterface.transferFrom(msg.sender,treasuryList[0],(_usdtamount*97)/100);
            //usdtInterface.transferFrom(msg.sender,treasuryList[1],(_usdtamount*3)/100);

            //记录USDT销毁总量
            destroiedUSDT = destroiedUSDT + _usdtamount;
            
            //社区代币直接销毁
            //NBBInterface.burn(_buyer,_NBBamount);

            //记录销毁总量
            destroiedNBB = destroiedNBB +_NBBamount;
        }
        emit Purchase(_buyer,amount);
        
    }
  
    function withDraw(address withDrawer,uint256 _amount) public{
        require(msg.sender == withDrawer);
        require(isVip[withDrawer] == true);
        require(userRewards[withDrawer] >= _amount);
    
        //减去用户的分红记录
        userRewards[withDrawer] = userRewards[withDrawer] - _amount;
        
        uint256 defla = (_amount*2)/100;
        //扣除通缩-------<<<小数还没实现
        if(needDeflation()==true){
            defla = (_amount*2)/100;
            DACInterface.burn(address(this),defla);
        }

        uint256 Fee = (_amount*10)/100;
        uint amount = _amount - defla - Fee;
        //将DAC从合约转给用户  在奖励代币合约部署以后需要将代币的权益授权给合约
        DACInterface.transferFrom(address(this),withDrawer,amount);

        //触发事件
        emit WithDraw(withDrawer,_amount);

    }

    //判断是否还要通缩
    function needDeflation() public view returns(bool){
        if(DACInterface.totalSupply()<=598000){
            return false;
        }
        return true;
    }
 

    
}