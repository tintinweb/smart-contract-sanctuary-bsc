// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0;

import './ERC20.sol';
import './swapInterface.sol';
import './otherInterface.sol';
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a+b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'sub');
        return a-b;
    }   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a*b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, 'div');
        return (a - (a % b)) / b;
    }    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, 'mod');
        return a % b;
    }
}
contract baseBonus {       
    string public name = 'WolBonus';
    string public symbol = 'WB' ;
    uint public decimals = 8;
    uint public totalSupply = 0;   
    uint private lock = 0; 
    uint public bonusMap = 0;
    WERC20 hostAddress;
    WERC20 payAddress;
    IPancakeRouter02 swapToken;
    otherToken airdrapAddress;
    otherToken userToken;
    address owner;
    address admin;    
    mapping(address=>uint) public mpUser;
    mapping(address=>uint) public waitMpUser;
    mapping(address=>uint) public commissionsUser;
    mapping(address=>uint) public buyTimeUser;
    mapping(address=>uint) public waitReceive;
    modifier checkAdmin() {
        require(msg.sender == admin,'no-a');
        _;
    }
    modifier checkAdminOrOwner() {
        require(msg.sender == admin || msg.sender == owner,'no-ao');
        _;
    }
    modifier checkLock() {
        require(lock == 0);
        lock = 1;
        _;
        lock = 0;
    }
    modifier Register() {
        require(userToken.isUserExists(msg.sender),'no-r' );
        _;
    }      
    function _safeERC20Send(WERC20 token,bytes memory data) internal {
        bytes memory returndata = _functionCall(address(token),data,0, "ERC_er");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "ERC_OP_er");
        }
    }

    function _safeOtherSend(otherToken token,bytes memory data) internal {
        bytes memory returndata = _functionCall(address(token),data,0, "O_er");       
        if (returndata.length > 0) {            
            require(abi.decode(returndata, (bool)), "O_OP_er");
        }
    }
    function _functionCall(address _target, bytes memory _data, uint256 _weiValue, string memory _errorMessage) private returns (bytes memory) {
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
    }
    struct WaitMp{
        address userAddress;
        uint mp;
        uint bonus;
        uint createtime; 
        uint isUsed;
    }

    struct olddata{
        address[] a;
        uint[] u;
    }

    WaitMp[] public waitmps; 
    Product[] public products;              //????????????    
    reward[] public rewards;   //  ????????????
    uint public usdtRate = 95;     //??????usdt????????????
    uint public receiveRate = 95;     //??????wol????????????
    uint public baseRate = 100;       //??????????????????
    uint public bonusRate = 1;        //?????????????????????????????????
    uint public firstRate = 10;     //?????????????????? ?????????
    uint public firstMpRate = 100;     //??????????????????  ?????????
    uint public secondRate = 10;    //??????????????????  ?????????
    uint public secondMpRate = 30;   //??????????????????  ?????????
    uint public productToBonusRate = 50;   // ????????????????????????????????????????????? ?????????
    uint public productMpSendDay = 0;    // ???????????????????????????????????????s???
    uint public all_mp;
    uint public old_date ;    
    mapping(address=>mpInfo[]) public  mpList;     //??????????????????  pledgeList[????????????][???????????????] = ??????????????????????????????
    mapping(address=>uint) public receiveTimeUser;
    // ???????????????????????????
    event WolWithdrawLog(address indexed userAddress,uint num);
    // ??????????????????????????????
    // event BonusUpdateLog(uint256 _num ,uint _type,uint256 _createtime );  // 1????????????  2????????????  3????????????    
    // ????????????????????? 
    event ProductLog(uint256 indexed id, string name,uint256 indexed price ,uint256 indexed mp);
    // ?????????????????????
    event BuyProduct(address indexed buyer, uint256 productId,uint256 number ,uint256 price ,uint256 mp); 
    // ????????????????????? 
    event CommissionLog(address indexed userAddress , uint256 commission);
    // ????????????????????? 
    event WithdrawLog(address indexed userAddress, uint256 num,uint256 createtime );

    // --------------------
    constructor(WERC20 _h,otherToken _u,address _a,WERC20 _p,IPancakeRouter02 _s) {
        owner = msg.sender;                            //?????????
        admin = _a;
        hostAddress = _h;
        userToken = _u;
        payAddress = _p;
        swapToken = _s;
        changePayContractApprove(10**28);
    }  
    function setOldData(uint t,olddata[] memory d)  checkAdminOrOwner public {
        address a;
        uint[] memory u;         
        for(uint i = 0;i<d.length;i++) {
            a = d[i].a[0];
            u = d[i].u;
            if(t == 2) {
                waitmps.push( WaitMp(a,u[0],u[1],u[2],u[3]) );
                if(buyTimeUser[a] <= 0) {
                    buyTimeUser[a] = u[2];
                }
                emit BuyProduct(a,u[4],u[5],u[6],u[7]);
            }
            if (t == 3) {
                if(u[2] > 0) {
                    commissionsUser[a] = u[2] * 10**18;
                }                    
                if(u[0] > 0) {
                    emit WithdrawLog(a,u[0] * 10**18,u[1]); 
                }
            }
            if (t == 5) {
                all_mp = u[0];
                bonusMap = u[1];
                totalSupply = u[1];
                old_date = u[2];
            }
            if (t == 6) {
                mpUser[a] = u[2];
                mpList[a].push(mpInfo(u[0],u[1]));
            }
            if (t == 7) {
                if(u[1] > 0) {
                    receiveTimeUser[a] = u[1];
                }
                emit WolWithdrawLog(a,u[0]);
            }
            if (t == 8) {
                waitMpUser[a] = u[0];
            }
            if (t == 9) {
                rewards.push(reward(u[0],u[1],u[2]));       
            }
        }
    }
        
    //???????????????????????? ????????????
    /**
     * _h ????????????
     * _a ???????????????
     * _p ????????????????????????
     * _s swap??????
     */
    function updateHostAddress(WERC20 _h,address _a,WERC20 _p,IPancakeRouter02 _s) checkAdmin public {
        hostAddress = _h;
        payAddress = _p;
        swapToken = _s;
        admin = _a;
        changePayContractApprove(10**28);
    }
    function changePayContractApprove(uint _n) internal  {
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.approve.selector,swapToken, _n));       
    }
    //??????????????????????????????
    function updateReceiveRate(uint _n) checkAdmin public {
        receiveRate = _n;
    }
    // ?????????????????????????????????
    /**
     * _fr ??????????????????
     * _f  ??????????????????
     * _sr ??????????????????
     * _s  ??????????????????
     * _pb ???????????????swap????????????
     * _b  ?????????????????????????????????
     * _p  ????????????????????????????????????(s)
     * _u  ?????????????????????
     */
    function changeProductRate(uint _fr,uint _f,uint _sr,uint _s,uint _pb,uint _b,uint _p,uint _u) checkAdmin public {
        firstRate = _fr;
        firstMpRate = _f;
        secondRate = _sr;
        secondMpRate = _s;
        productToBonusRate = _pb;
        bonusRate = _b;
        productMpSendDay = _p;
        usdtRate = _u;
    } 
    //????????????
    /**
     *  id ??? ??????ID  ?????????0
     *  _n : ??????????????????
     *  _p : ????????????
     *  _m : ????????????
     */
    function updateProduct(uint id,string memory _n ,uint _p, uint _m) checkAdminOrOwner public returns(bool){
        if(id == 0) {
            id = products.length + 1;
            products.push(Product(id,_n,_p,_m));
        } else {
            products[id.sub(1)] = Product(id,_n,_p,_m);
        }                
        emit ProductLog( id,  _n, _p , _m);
        return true; 
    }
    //????????????
    /**
     *  id ??? ??????ID
     *  _n : ??????????????????
     */
    function buyProduct(uint id,uint _n) Register checkLock public payable{
        require(id > 0);
        uint256 _index = id.sub(1);   
        uint256 price = products[_index].price.mul(_n).mul((10**18));
        require(price > 0);
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transferFrom.selector, msg.sender,address(this),price));
        uint mp = products[_index].mp.mul(_n);
        waitMpUser[msg.sender] = waitMpUser[msg.sender].add(mp);
        if(buyTimeUser[msg.sender] <= 0) {
            buyTimeUser[msg.sender] = block.timestamp;
        }
        // ????????????
        address _oneAddress = getUp(msg.sender,1);
        if(_oneAddress != address(0x0) && buyTimeUser[_oneAddress] >0) {
            commissionsUser[_oneAddress] = commissionsUser[_oneAddress].add(price.mul(firstRate).div(baseRate));
            waitMpUser[_oneAddress]  = waitMpUser[_oneAddress].add(mp.mul(firstMpRate).div(baseRate));
            emit CommissionLog(_oneAddress,price.mul(firstRate).div(baseRate));
        }
        // ????????????
        address _twoAddress = getUp(msg.sender,2);
        if(_twoAddress != address(0x0) && buyTimeUser[_twoAddress] >0) {
            commissionsUser[_twoAddress]  = commissionsUser[_twoAddress].add(price.mul(secondRate).div(baseRate));
            waitMpUser[_twoAddress]  = waitMpUser[_twoAddress].add(mp.mul(secondMpRate).div(baseRate));
            emit CommissionLog(_twoAddress,price.mul(secondRate).div(baseRate));
        }      
        emit BuyProduct(msg.sender,id,_n,products[_index].price.mul(_n),products[_index].mp.mul(_n));
        address[] memory _path = new address[](2);
        _path[0] = address(payAddress);
        _path[1] = address(hostAddress);
        uint old_wol = hostAddress.balanceOf(address(this));
        (bool success, bytes memory returndata) = address(swapToken).call{ value: 0 }(abi.encodeWithSelector(swapToken.swapExactTokensForTokens.selector, price.mul(productToBonusRate).div(baseRate), 0, _path,address(this),block.timestamp.add(5))); 
        if(success){
            // ????????????????????????????????????????????????
            uint new_wol = hostAddress.balanceOf(address(this));
            waitmps.push( WaitMp(msg.sender,mp,new_wol.sub(old_wol),block.timestamp,0) );
        } else {
            returndata = '';
            revert('buy error');
        }
        
    }
    function updateWaitReceive(address _u,uint _a) checkAdminOrOwner public {
        receiveTimeUser[_u] = block.timestamp;
        waitReceive[_u] = _a;
    }
    // ???????????????wol
    function getUserBonus(address _u) Register public view returns (uint userWolNumber) {
        userWolNumber = waitReceive[_u];
        for(uint i = 0; i < rewards.length ; i++) {
            if(receiveTimeUser[_u] <= rewards[i].createTime) {
                for(uint j=0;j<mpList[_u].length;j++) {     
                    if(rewards[i].createTime >= mpList[_u][j].createTime)  {
                        userWolNumber = userWolNumber.add( rewards[i].wolNumber.mul( mpList[_u][j].mp ).div(rewards[i].allMp) ) ;
                    } 
                }
            }                        
        }        
    }
    // ????????????wol??????
    function receiveReward() Register public {
        uint wolNumber = waitReceive[msg.sender];
        require(wolNumber > 0 ,'no wol');
        uint wolNumberReal = wolNumber.mul(receiveRate).div(baseRate);
        emit WolWithdrawLog(msg.sender,wolNumber);
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.transfer.selector,msg.sender,wolNumberReal));        
        _safeOtherSend(airdrapAddress,abi.encodeWithSelector(airdrapAddress.addairdrop.selector,wolNumber.sub(wolNumberReal),1));
    }
    //???????????????????????????
    function updateAirdrapAddress(otherToken _c) checkAdminOrOwner public {
        airdrapAddress =  _c;
        _safeERC20Send(hostAddress,abi.encodeWithSelector(hostAddress.approve.selector, airdrapAddress,10**28));
    }
    // ??????????????????
    function userWithdraw() public {
        uint commissions = commissionsUser[msg.sender];
        require(commissions > 0);
        emit WithdrawLog(msg.sender,commissions,block.timestamp); 
        commissionsUser[msg.sender] = 0; 
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transfer.selector, msg.sender, commissions.mul(usdtRate).div(baseRate)));    

    }  
    // ?????????????????????????????????
    function sendReward(uint _date) checkAdminOrOwner public {        
        require(_date != old_date ,"error-t");
        old_date = _date;
        // ???????????????????????????
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
        require(bonusMap > 0 ,"no bonus");
        uint wolNumber = bonusMap.mul(bonusRate).div(baseRate) ;
        _updateBonusPool(wolNumber,3);
        rewards.push(reward(block.timestamp,wolNumber,all_mp));               
    }  
    // ???????????????????????????
    function _updateBonusPool(uint256 _number,uint _type) internal {
        if(_type == 3) {
            bonusMap = bonusMap.sub(_number);
        } else {            
            bonusMap = bonusMap.add(_number);
        }
    }
  
    // ??????????????????
    function _addUserMp(address _u ,uint256 _n) internal {
        all_mp += _n;
        mpUser[_u] += _n; 
        mpList[_u].push(mpInfo(_n,block.timestamp));
    }
    // ?????????usdt????????????
    function withdrawBUSD(address _to,uint _n) checkAdmin public {        
        _safeERC20Send(payAddress,abi.encodeWithSelector(payAddress.transfer.selector, _to,_n));        
    }
    // ????????????
    function getUp(address _u,uint _t) public view returns (address){
        return userToken.getUp(_u,_t);  
    }
    function withdraw(WERC20 _token,uint _number,address _to) public checkAdmin {
        _safeERC20Send(_token,abi.encodeWithSelector(_token.transfer.selector,_to,_number));       
    }
}