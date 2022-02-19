// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import './ERC20.sol';
import './wolMath.sol';
import './swapInterface.sol';
import './otherInterface.sol';

contract baseBonus {      
    using SafeMath for uint;      
    string public name = 'WolBonus';
    string public symbol = 'WB' ;
    uint8 public decimals = 8;
    uint  public totalSupply = 0;    
    WERC20 hostAddress;
    WERC20 payAddress;
    IPancakeRouter02 swapToken;
    otherToken airdrapAddress;
    otherToken userToken;
    address owner;
    address admin;
    uint private lock = 0;
    uint public sendRewardTime = 0;
    mapping(address => uint) public balanceOf;
   
    mapping(address=>uint) public mpUser;
    mapping(address=>uint) public receiveTimeUser;
    mapping(address=>uint) public waitMpUser;
    mapping(address=>uint) public commissionsUser;
    mapping(address=>uint) public buyTimeUser;
   
    modifier checkAdmin() {
        require(msg.sender == admin,'invalid operation');
        _;
    }
    modifier checkAdminOrOwner() {
        require(msg.sender == admin || msg.sender == owner,'invalid operation');
        _;
    }
    modifier checkLock() {
        require(lock == 0);
        lock = 1;
        _;
        lock = 0;
    }
    modifier checkRegister() {
        bool isRegister = userToken.isUserExists(msg.sender);
        require(isRegister,'invalid operation' );
        _;
    }      
    function _safeERC20Send(WERC20 token,bytes memory data) internal {
        bytes memory returndata = _functionCall(address(token),data,0, "SafeERC20: low-level call failed");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }

    function _safeOtherSend(otherToken token,bytes memory data) internal {
        bytes memory returndata = _functionCall(address(token),data,0, "SafeERC20: low-level call failed");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
    function _functionCall(address _target, bytes memory _data, uint256 _weiValue, string memory _errorMessage) private returns (bytes memory) {
        // require(isContract(_target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = _target.call{ value: _weiValue }(_data);
        if (success) {
            return returndata;
        } else {
           
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(_errorMessage);
            }
        }
    }
}
contract wolBonus is baseBonus{    
    using SafeMath for uint;    
    struct reward {
        uint createTime;
        uint wolNumber;
        uint allMp;
    }
    struct mpInfo{
        uint mp;
        uint createTime;
    }
    struct Product {
        uint id ;
        string name;
        uint price;
        uint mp;
        uint8 status;
    }
    struct WaitMp{
        address userAddress;
        uint mp;
        uint bonus;
        uint createtime; 
        uint isUsed;
    }

    WaitMp[] public waitmps; 
    Product[] public products;              //产品数据    
    uint receiveRate = 95;     //提现wol到账比例
    uint baseRate = 100;       //提现基础比例
    uint bonusRate = 1;        //加权分红池每日发放比例
    uint firstRate = 10;     //一级奖励佣金 百分比
    uint firstMpRate = 100;     //一级奖励算力  百分比
    uint secondRate = 10;    //二级奖励佣金  百分比
    uint secondMpRate = 30;   //二级奖励算力  百分比
    uint productToBonusRate = 80;   // 购买产品的价格一定比例到分红池 百分比
    uint productMpSendDay = 0;    // 购买产品算力释放所需时间（s）
    uint public nosuccess ;
    uint public all_mp;
    uint old_date ;
    reward[] public rewards;   //  奖励列表
    mapping(address=>mpInfo[]) public  mpList;     //用户对应算力  pledgeList[用户地址][发放时间戳] = 用户发放时间质押数量
    // 事件，主币提现日志
    event WolWithdrawLog(address indexed userAddress,uint num);
    // 事件，加权分红池更新
    event BonusUpdateLog(uint256 _num ,uint _type,uint256 _createtime );  // 1产品产生  2提现产生  3发放减少    
    // 事件，产品更新 
    event ProductLog(uint256 indexed id, string name,uint256 indexed price ,uint256 indexed mp);
    // 事件，购买产品
    event BuyProduct(address indexed buyer, uint256 productId,uint256 number ,uint256 price ,uint256 mp); 
    // 事件，佣金发放 
    event CommissionLog(address indexed userAddress , uint256 commission);
    // 事件，佣金提现 
    event WithdrawLog(address indexed userAddress, uint256 num,uint256 createtime );

    // --------------------
    constructor(WERC20 _hostAddress,otherToken _userToken,address _admin,WERC20 _payAddress,IPancakeRouter02 _swapToken) {
        owner = msg.sender;                            //发币者
        admin = _admin;
        hostAddress = _hostAddress;
        userToken = _userToken;
        payAddress = _payAddress;
        swapToken = _swapToken;
        changePayContractApprove(10**28);
    }  
        
    //修改主币合约地址 和管理员
    function updateHostAddress(WERC20 _hostAddress,address _admin,WERC20 _payAddress,IPancakeRouter02 _swapToken) checkAdmin public {
        hostAddress = _hostAddress;
        payAddress = _payAddress;
        swapToken = _swapToken;
        admin = _admin;
        changePayContractApprove(10**28);
    }
    function changePayContractApprove(uint _number) checkAdmin public {
        (bool success, bytes memory returndata) = address(payAddress).call{ value: 0 }(abi.encodeWithSelector(payAddress.approve.selector,swapToken, _number)); 
        if (!success) {           
            if (returndata.length > 0) {               
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert('fail-r');
            }
        }
    }
    //修改收益提现到账比例
    function updateReceiveRate(uint _number) checkAdmin public {
        receiveRate = _number;
    }
    // 更改加权分红池分销比例
    function changeProductRate(uint256 _firstRate,uint256 _firstMpRate,uint256 _secondRate,uint256 _secondMpRate) checkAdmin public {
        firstRate = _firstRate;
        firstMpRate = _firstMpRate;
        secondRate = _secondRate;
        secondMpRate = _secondMpRate;
        productToBonusRate = baseRate.sub(_firstRate).sub(_secondRate);
    } 
    //添加产品
    function addProduct(string memory _name,uint256 _price, uint256 _mp,uint8 _status) checkAdminOrOwner public  returns(uint)  {
        uint256 id =  products.length + 1;        
        require(_price > 0); 
        products.push(Product(id,_name,_price,_mp,_status));
        require(id == products.length);
        emit ProductLog( id,  _name, _price , _mp);
        return id;
    }
    //更改产品
    function updateProduct(uint id,string memory _name ,uint256 _price, uint256 _mp,uint8 _status) checkAdminOrOwner public returns(bool){
        require(id > 0);   
        require(_price > 0);  
        uint256 _index = id.sub(1);  
        require(products[_index].id > 0 );   
        products[_index] = Product(id,_name,_price,_mp,_status);
        emit ProductLog( id,  _name, _price , _mp);
        return true; 
    }
    //购买产品
    function buyProduct(uint productId,uint number) checkRegister checkLock public payable{
        require(productId > 0);
        uint256 _index = productId.sub(1);   
        uint256 price = products[_index].price.mul(number).mul((10**18));
        require(price > 0);
        // _safeTransfer(payAddress,msg.sender,address(this),price);   
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this),price));
        uint mp = products[_index].mp.mul(number);
        waitMpUser[msg.sender] = waitMpUser[msg.sender].add(mp);
        if(buyTimeUser[msg.sender] <= 0) {
            buyTimeUser[msg.sender] = block.timestamp;
        }
        
        // 一级分佣
        address _oneAddress = getUp(msg.sender,1);
        if(_oneAddress != address(0x0) && buyTimeUser[_oneAddress] >0) {
            commissionsUser[_oneAddress] = commissionsUser[_oneAddress].add(price.mul(firstRate).div(baseRate));
            waitMpUser[_oneAddress]  = waitMpUser[_oneAddress].add(mp.mul(firstMpRate).div(baseRate));
            emit CommissionLog(_oneAddress,price.mul(firstRate).div(baseRate));
        }
        // 二级分佣
        address _twoAddress = getUp(msg.sender,2);
        if(_twoAddress != address(0x0) && buyTimeUser[_twoAddress] >0) {
            commissionsUser[_twoAddress]  = commissionsUser[_twoAddress].add(price.mul(secondRate).div(baseRate));
            waitMpUser[_twoAddress]  = waitMpUser[_twoAddress].add(mp.mul(secondMpRate).div(baseRate));
            emit CommissionLog(_twoAddress,price.mul(secondRate).div(baseRate));
        }      
        address[] memory _path = new address[](2);
        _path[0] = address(payAddress);
        _path[1] = address(hostAddress);
        _swapBUSDForHostToken(price.mul(productToBonusRate).div(baseRate),0,_path,address(this),mp);
        emit BuyProduct(msg.sender,productId,number,products[_index].price.mul(number),products[_index].mp.mul(number));
    }
    function _swapBUSDForHostToken(uint _amountIn,uint _amountOutMin,address[] memory _path,address _to,uint _mp ) private {    
        uint old_wol = hostAddress.balanceOf(address(this));
        (bool success, bytes memory returndata) = address(swapToken).call{ value: 0 }(abi.encodeWithSelector(swapToken.swapExactTokensForTokens.selector, _amountIn, _amountOutMin, _path,_to,block.timestamp.add(5))); 
        if(success){
            // 添加一定比例的价格到等待分红池中
            uint new_wol = hostAddress.balanceOf(address(this));
            waitmps.push( WaitMp(msg.sender,_mp,new_wol.sub(old_wol),block.timestamp,0) );
        } else {
            returndata = '';
            revert('buy error');
        }
    }
    
    // 用户待领取wol
    function getUserBonus() checkRegister public view returns (uint userWolNumber) {
        userWolNumber = 0;
        for(uint i = 0; i < rewards.length ; i++) {
            if(receiveTimeUser[msg.sender] > rewards[i].createTime) {
                continue;
            }
            for(uint j=0;j<mpList[msg.sender].length;j++) {     
                if(rewards[i].createTime < mpList[msg.sender][j].createTime)  {
                    continue;
                }        
                userWolNumber = userWolNumber.add( rewards[i].wolNumber.mul( mpList[msg.sender][j].mp ).div(rewards[i].allMp) ) ;
            }            
        }        
    }
    // 用户领取wol奖励
    function receiveReward() checkRegister public {
        uint wolNumber = getUserBonus();
        require(wolNumber > 0 ,'no wol');
        uint wolNumberReal = wolNumber.mul(receiveRate).div(baseRate);
        receiveTimeUser[msg.sender] = block.timestamp;
        emit WolWithdrawLog(msg.sender,wolNumber);
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.transfer.selector,msg.sender,wolNumberReal));        
        _safeOtherSend(airdrapAddress,abi.encodeWithSelector(airdrapAddress.addairdrop.selector,wolNumber.sub(wolNumberReal),1));
    }
    //修改空投池合约地址
    function updateAirdrapAddress(otherToken _contractAddress) checkAdminOrOwner public {
        airdrapAddress =  _contractAddress;
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.approve.selector, airdrapAddress,10**28));
    }
    // 用户提现佣金
    function userWithdraw() public {
        uint commissions = commissionsUser[msg.sender];
        require(commissions > 0);
        emit WithdrawLog(msg.sender,commissions,block.timestamp); 
        commissionsUser[msg.sender] = 0; 
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transfer.selector, msg.sender, commissions));    
        // _safeTransfer(payAddress,address(this),msg.sender,commissions);
    }  
    // 每日奖励发放记录到池子
    function sendReward(uint _date) checkAdminOrOwner public {        
        require(_date != old_date ,"error-t");
        old_date = _date;
        // if(sendRewardTime == 0) {
        //     sendRewardTime = block.timestamp;
        // } else {
        //     require(sendRewardTime + 86400 > block.timestamp,'time error') ;
        //     sendRewardTime = sendRewardTime.add(86400);
        // }
        // 产品七天后算力释放
        for(uint i = 0; i<waitmps.length;i++) {
            if(waitmps[i].isUsed != 1) {
                if (waitmps[i].createtime.add(productMpSendDay) < block.timestamp) {
                    waitmps[i].isUsed = 1;
                    _addUserMp(waitmps[i].userAddress,waitmps[i].mp);
                    waitMpUser[waitmps[i].userAddress] -=waitmps[i].mp;
                    _updateBonusPool(waitmps[i].bonus,1);
                    address _oneAddress = getUp(waitmps[i].userAddress,1);
                    uint ct = waitmps[i].createtime;
                    uint ot = buyTimeUser[_oneAddress];
                    if( _oneAddress != address(0x0) && ot < ct && ot >0) {
                        waitMpUser[_oneAddress] = waitMpUser[_oneAddress].sub(waitmps[i].mp.mul(firstMpRate).div(baseRate));
                        _addUserMp(_oneAddress,waitmps[i].mp.mul(firstMpRate).div(baseRate));
                    }
                    address _twoAddress =  getUp(waitmps[i].userAddress,2);
                    uint tt = buyTimeUser[_twoAddress] ;
                    if(_twoAddress != address(0x0) && tt < ct && tt >0) {
                        waitMpUser[_twoAddress] = waitMpUser[_twoAddress].sub(waitmps[i].mp.mul(secondMpRate).div(baseRate));
                        _addUserMp(_twoAddress,waitmps[i].mp.mul(secondMpRate).div(baseRate));               
                    }   
                }
            }             
        }
        require(balanceOf[owner] > 0 ,"no bonus");
        uint wolNumber = balanceOf[owner].mul(bonusRate).div(baseRate) ;
        _burn(owner,wolNumber);
        rewards.push(reward(block.timestamp,wolNumber,all_mp));               
    }
    // // 添加金额到加权分红池里
    function addBonus( uint256 _value, uint _type) checkAdmin public {  
        _updateBonusPool(_value,_type);
    }
    // 更新加权分红池币量
    function _updateBonusPool(uint256 _number,uint _type) internal {
        if(_type == 3) {
            balanceOf[owner] = balanceOf[owner].sub(_number);
            totalSupply = totalSupply.sub(_number);
        } else {            
            balanceOf[owner] = balanceOf[owner].add(_number);
            totalSupply = totalSupply.add(_number);
        }        
        emit BonusUpdateLog(_number,_type,block.timestamp);
    }
    function _burn(address from,uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
    }
    // 用户添加算力
    function _addUserMp(address userAddress ,uint256 _number) internal {
        all_mp += _number;
        mpUser[userAddress] += _number; 
        mpList[userAddress].push(mpInfo(_number,block.timestamp));
    }
    // 多余的usdt提取出来
    function withdrawBUSD(address _to,uint _number) checkAdmin public {
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transfer.selector, _to,_number));        
    }
    // 获取上级
    function getUp(address _address,uint _type) public view returns (address){
        address upAddress = userToken.getUp(_address,_type);  
        return upAddress;       
    }
}