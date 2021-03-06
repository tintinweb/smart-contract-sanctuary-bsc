/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^ 0.8.3;

abstract contract ERC20{
    function balanceOf(address tokenOwner) external virtual view returns (uint balance);
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function mining(address _address,uint tokens) external virtual returns (bool success);
    function querySeedToUsdtPrice() external view virtual returns (uint256);//1 token = ? U
    function stake(address account,uint256 amountToWei,uint columnType,uint columnId,uint coinAmount,uint tokenAmount) external virtual;
}

library Counters {
    struct Counter {uint256 _value;}

    function current(Counter storage counter) internal view returns (uint256) {return counter._value;}

    function increment(Counter storage counter) internal {unchecked {counter._value += 1;}}

    function decrement(Counter storage counter) internal {uint256 value = counter._value; require(value > 0, "Counter: decrement overflow"); unchecked {counter._value = value - 1;}}

    function reset(Counter storage counter) internal {counter._value = 0;}
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
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
}

contract Comn {
    address internal owner;
    uint256 internal constant _NOT_ENTERED = 1;
    uint256 internal constant _ENTERED = 2;
    uint256 internal _status = 1;
    mapping(address => bool) private approveMapping; //????????????mapping
    modifier onlyOwner(){
        require(msg.sender == owner,"Modifier: The caller is not the creator");
        _;
    }
    modifier onlyApprove(){
        require(approveMapping[msg.sender] || msg.sender == owner,"Modifier : The caller is not the approve");
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
    function setApproveAddress(address _address,bool _bool) public onlyOwner(){
        approveMapping[_address] = _bool;
    }
    function backWei(uint256 a, uint decimals) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 amount = a / (10 ** uint256(decimals));
        return amount;
    }
    fallback () payable external {}
    receive () payable external {}
}

contract BottomLP is Comn{
    using SafeMath for uint;
    address burnAddress = address(0x000000000000000000000000000000000000dEaD);/* ???????????? */

    //??????
    function stake(uint sid,uint coinAmountToWei) public {
        require(coinAmountToWei > 0, 'BottomLP : Cannot stake 0');
        require(lpMapping[sid].isOpen , 'BottomLP : Closed');
        require(lpMapping[sid].createTime != 0 , 'BottomLP : non-existent');
        uint coin2UsdtPrice = ERC20(coinContract).querySeedToUsdtPrice(); //??????coin???????????????USDT
        uint coinEqualUsdt = coinAmountToWei.mul(coin2UsdtPrice).backWei(18); //coinAmountToWei ????????????USDT

        uint tokenAmountToWei = 0; //?????????token??????
        if(lpMapping[sid].tokenPriceToCoin != 0){//?????????????????????
            tokenAmountToWei = lpMapping[sid].tokenPriceToCoin.mul(coinAmountToWei).backWei(18);
        } else {//????????????????????????
            uint usdtBalance = ERC20(usdtContract).balanceOf(lpMapping[sid].token2UsdtPancakePair);//??????USDT??????
            uint tokenBalance = ERC20(lpMapping[sid].tokenContract).balanceOf(lpMapping[sid].token2UsdtPancakePair);//??????token??????
            require(usdtBalance.mul(2) >= lpMapping[sid].tokenBottomPoolUsdt , 'BottomLP : The bottom pool is not up to standard');//????????????????????????
            uint usdt2TokenPrice = tokenBalance.divFloat(usdtBalance,18); //??????USDT????????????token
            tokenAmountToWei = usdt2TokenPrice.mul(coinEqualUsdt).backWei(18);
        }
        ERC20(coinContract).transferFrom(msg.sender,burnAddress,coinAmountToWei);//??????Coin
        ERC20(lpMapping[sid].tokenContract).transferFrom(msg.sender,burnAddress,tokenAmountToWei);//??????token
        
        lpMapping[sid].coinAmount += coinAmountToWei;
        lpMapping[sid].tokenAmount += tokenAmountToWei;

        ERC20(miningContract).stake(msg.sender,coinEqualUsdt.mul(2),2,lpMapping[sid].sId,coinAmountToWei,tokenAmountToWei);
    }


    /*
     * @dev ?????? | ??????????????? | ??????????????????
     * @param rankingArray ????????????
     */
    function queryLP() public view returns (LP[] memory queryArray){
        uint idLength = _sId.current();
        uint selectLength = 0;
        for(uint i=1; i <= idLength; i++){
            if(lpMapping[i].isOpen && lpMapping[i].createTime != 0){
                selectLength++;
            }
        }
        queryArray = new LP[](selectLength);
        uint index = 0;
        for(uint i=1; i <= idLength; i++){
            if(lpMapping[i].isOpen && lpMapping[i].createTime != 0){
                queryArray[index] = lpMapping[i];
                index++;
            }
        }
    }
    

    /*---------------------------------------------------????????????-----------------------------------------------------------*/
    using Counters for Counters.Counter;
    Counters.Counter _sId;
    mapping(uint => LP) public lpMapping;                  //<???????????????,???????????????>
    address coinContract;
    address usdtContract;
    address miningContract;
    
    struct LP {
        uint sId;                       //?????????ID
        bool isOpen;                    //??????
        uint coinAmount;                //coin?????????
        uint tokenAmount;               //token?????????
        address tokenContract;          //token????????????
        string tokenName;               //token??????
        address token2UsdtPancakePair;  //token - usdt ?????????lp??????
        uint tokenPriceToCoin;          //token??????(????????????)
        uint tokenBottomPoolUsdt;       //token??????USDT??????????????????
        uint createTime;                //????????????
    }

    function setConfig(address _coinContract,address _usdtContract,address _miningContract) public onlyOwner {
        coinContract = _coinContract;
        usdtContract = _usdtContract;
        miningContract = _miningContract;
    }

    function createLP(address _tokenContract,string memory _tokenName,uint _tokenPriceToCoin,address _token2UsdtPancakePair,uint _tokenBottomPoolUsdt) external onlyOwner returns (uint sId){
        _sId.increment();
        sId = _sId.current();
        lpMapping[sId] = LP(sId,true,0,0,_tokenContract,_tokenName,_token2UsdtPancakePair,_tokenPriceToCoin,_tokenBottomPoolUsdt,block.timestamp);
    }

    function updateLP(uint sid,address tokenContract,string memory tokenName,uint tokenPriceToCoin,address token2UsdtPancakePair,uint tokenBottomPoolUsdt) external onlyOwner returns (uint sId){
        require(lpMapping[sid].createTime != 0 , 'BottomLP : non-existent');
        lpMapping[sId].tokenContract = tokenContract;
        lpMapping[sId].tokenName = tokenName;
        lpMapping[sId].tokenPriceToCoin = tokenPriceToCoin;
        lpMapping[sId].token2UsdtPancakePair = token2UsdtPancakePair;
        lpMapping[sId].tokenBottomPoolUsdt = tokenBottomPoolUsdt;
    }

    function setLpOpen(uint sId,bool flag) external onlyOwner{
        lpMapping[sId].isOpen = flag;
    }
}