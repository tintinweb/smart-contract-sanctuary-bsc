/**
 *Submitted for verification at BscScan.com on 2022-05-12
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function balanceOf(address tokenOwner) external virtual view returns (uint balance);
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function getInviter(address _address) external view virtual returns (address);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        if (b == a) {
            return 0;
        }
        require(b < a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a / b;
        return c;
    }
    function divFloat(uint256 a, uint256 b,uint decimals) internal pure returns (uint256){
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 aPlus = a * (10 ** uint256(decimals));
        uint256 c = aPlus/b;
        return c;
    }
}

contract Comn {
    address internal owner;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor() {
        owner = msg.sender;
        _status = _NOT_ENTERED;
    }
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
    function outToken(address contractAddress,address targetAddress,uint amountToWei) public onlyOwner{
        ERC20(contractAddress).transfer(targetAddress,amountToWei);
    }
    fallback () payable external {}
    receive () payable external {}
}

contract PublicExchange is Comn{
    using SafeMath for uint256;
    address private burnAddress = address(0x000000000000000000000000000000000000dEaD);/* ???????????? */
    mapping(address => uint) public updateTimeMap;      //????????????
    mapping(address => uint) public exchangeMap;        //????????????
    mapping(address => uint) public outPutTotalMap;     //???????????????
    mapping(address => uint) public outPutCollectMap;   //???????????????

    //??????
    function exchange(uint amountToWei) public {
        require(amountToWei > 10 ** 4, "PublicExchange : Unsupported contract");
        if(updateTimeMap[msg.sender] == 0){
            updateTimeMap[msg.sender] = block.timestamp;
        }
        exchangeMap[msg.sender] += amountToWei;
        outPutTotalMap[msg.sender] += amountToWei.mul(exchangeScale).div(10000);
        ERC20(inAddress).transferFrom(msg.sender,burnAddress,amountToWei);
    }
    
    //????????????
    function getProfit() public view returns (uint amountToWei){
        uint balanceProfit = outPutTotalMap[msg.sender] - outPutCollectMap[msg.sender];//????????????
        if(balanceProfit > 0){
            uint secondOutPut = outPutTotalMap[msg.sender].mul(releaseScale).div(10000).div(86400);//??????????????????
            uint waitReceiveTime = block.timestamp - updateTimeMap[msg.sender];//?????????????????????
            uint waitProfit = waitReceiveTime.mul(secondOutPut);//?????????????????????
            if(waitProfit > balanceProfit){
                 amountToWei = balanceProfit;
            } else {
                 amountToWei = waitProfit;
            }
        } else {
            amountToWei = 0;
        }
    }

    //??????
    function collect() public {
        uint waitProfit = getProfit();//???????????????
        if (waitProfit > 0) {
            updateTimeMap[msg.sender] = block.timestamp;
            outPutCollectMap[msg.sender] += waitProfit;
            ERC20(outAddress).transfer(msg.sender,waitProfit);
        }
    }


    /*---------------------------------------------------????????????-----------------------------------------------------------*/
    address public inAddress;                                   //[??????]  ??????????????????
    address public outAddress;                                  //[??????]  ??????????????????
    uint public exchangeScale = 1000;                           //[??????]  ???????????? (???:1000 ???: 1000/10000 (10%))
    uint public releaseScale = 100;                             //[??????]  ???????????? (???:1000 ???: 100/10000/??? (1%/???))
    
    function setContract(address _inAddress,address _outAddress) public onlyOwner {
        inAddress = _inAddress;
        outAddress = _outAddress;
    }

    function setExchangeScale(uint _scale) public onlyOwner {
        exchangeScale = _scale;
    }

    function setReleaseScale(uint _scale) public onlyOwner {
        releaseScale = _scale;
    }
}