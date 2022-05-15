/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

pragma solidity ^0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

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

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IPancakePair {
    function balanceOf(address owner) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract ARTTOOL {
    event ActiveAccount(address indexed account,address indexed refer);
    event UpdateActive(address indexed account,address indexed refer);
    event Make(address indexed account,uint8 id,uint256 usdAmount,uint256 bKAmount,uint256 bAAmount);
    event Pledge(address indexed account,uint256 amount);
    event Release(address indexed account,uint256 amount);
    event MultiTransfer(uint256 total, address tokenAddress);
    mapping (address => address) private _refers;
    address[] private _actives;
    address private _master;
    using SafeMath  for uint;

   
    address private KNT = 0xA4a7ABE3bFEf949E7a76ee48c0780666453040f1;
    address private ART = 0xAC3dF984D3C70db98BcC25CE352CBA12D0713cB1;
    address private DDA = 0x5888CeB36582deEB3f318b1DbE2CD353fF37d00c;
    address private USDT = 0x07FF944b000390Ce4bfEd9adfa1EdBDE62902857;

    address private PAIR_KNT_USDT = 0x6083adDeF83C6E88f69036fE26819fD6ea8D605b;
    address private PAIR_ART_USDT = 0xF85492838fB8a62188ECAc330b966844D4Ba52f9;
    address private PAIR_DDA_USDT = 0xe2e042D1955093B642D245E68B1ede14Ffc9Dc10;

    mapping (address => uint256) private _balances;
    uint256 private _totalSupply;

    constructor () public{
        _master = msg.sender;
        _refers[msg.sender]=msg.sender;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function pledge(uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");
        require(IPancakePair(PAIR_ART_USDT).transferFrom(msg.sender,_master,amount),"transfer error");
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        emit Pledge(msg.sender,amount);
        return true;
    }

    function release(uint256 amount) public returns(bool status){
        require(amount > 0 ,"error");
        require(IPancakePair(PAIR_ART_USDT).transferFrom(_master,msg.sender,amount),"transfer error");
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        emit Release(msg.sender,amount);
        return true;
    }

    

    function make(uint8 id,uint8 t,uint256 usdAmount) public returns(bool status){
        require(usdAmount > 0 ,"error");

        //ART/USDT
        uint256 bART = IPancakePair(ART).balanceOf(PAIR_ART_USDT);
        uint256 bAUSDT = IPancakePair(USDT).balanceOf(PAIR_ART_USDT);
        // uint256 bART = 10**18;
        // uint256 bAUSDT = 17 * 10**18;
        // uint256 bA = bAUSDT.div(bART);
        

        if(t == 1){//KNT/ART
            //KNT/USDT
            uint256 bKNT = IPancakePair(KNT).balanceOf(PAIR_KNT_USDT);
            uint256 bKUSDT = IPancakePair(USDT).balanceOf(PAIR_KNT_USDT);
            // uint256 bKNT = 10**18;
            // uint256 bKUSDT = 1497 * 10**18;
            // uint256 pK = bKUSDT.div(bKNT);
      
            uint256 bKAmount = usdAmount.mul(bKNT).div(bKUSDT);
            uint256 bAAmount = usdAmount.mul(bART).div(bAUSDT);
            require(IERC20(KNT).transferFrom(msg.sender,_master,bKAmount),"KNT transfer error");
            require(IERC20(ART).transferFrom(msg.sender,_master,bAAmount),"ART transfer error");
            emit Make(msg.sender,id,usdAmount,bKAmount,bAAmount);
        } else {//DDA/ART
            //DDA/USDT
            uint256 bDDA = IPancakePair(DDA).balanceOf(PAIR_DDA_USDT);
            uint256 bDUSDT = IPancakePair(USDT).balanceOf(PAIR_DDA_USDT);
            // uint256 bDDA = 10**18;
            // uint256 bDUSDT = 10**17;
            // uint256 pD = bKUSDT.div(bDDA);

            uint256 bDAmount = usdAmount.mul(bDDA).mul(1e6).div(bDUSDT.mul(1e18));
            uint256 bAAmount = usdAmount.mul(bART).div(bAUSDT);
            require(IERC20(KNT).transferFrom(msg.sender,_master,bDAmount),"DDA transfer error");
            require(IERC20(ART).transferFrom(msg.sender,_master,bAAmount),"ART transfer error");
            emit Make(msg.sender,id,usdAmount,bDAmount,bAAmount);
        }
      
        return true;
    }

    function setToken(uint8 id,address addr) public{
        require(msg.sender == _master);
        if(id == 1){
            KNT = addr;
        }else if(id == 2){
            ART = addr;
        }else if(id == 3){
            DDA = addr;
        }else{
            USDT = addr;
        }
    }

    function getToken(uint8 id) public view returns(address token){
        if(id == 1){
            return KNT;
        }else if(id == 2){
            return ART;
        }else if(id == 3){
            return DDA;
        }else{
            return USDT;
        }
    }

    function setPair(uint8 id,address addr) public{
        require(msg.sender == _master);
        if(id == 1){
            PAIR_KNT_USDT = addr;
        } else if(id == 2){
            PAIR_ART_USDT = addr;
        } else {
            PAIR_DDA_USDT = addr;
        }
    }

    function getPair(uint8 id) public view returns(address token){
        if(id == 1){
            return PAIR_KNT_USDT;
        } else if(id == 2){
            return PAIR_ART_USDT;
        } else {
            return PAIR_DDA_USDT;
        }
    }

    function active(address refer) public returns(uint code){
        if(_refers[refer] == address(0)){
            return 1;
        }
        if(msg.sender == refer){
            return 2;
        }
        if(_refers[msg.sender]!=address(0)){
            return 3;
        }
        _refers[msg.sender] = refer;
        _actives.push(msg.sender);
        emit ActiveAccount(msg.sender,refer);
        return 0;
    }

    function isActive() view public returns(bool status){
        return _refers[msg.sender] != address(0);
    }

    function getActive(address addr) view public returns(bool status){
        return _refers[addr] != address(0);
    }

    function activeRefer(address addr) public view returns(address refer){
        return _refers[addr];
    }

    function updateActive(address addr,address refer) public{
        require(msg.sender == _master);
        _refers[addr] = refer;
        emit UpdateActive(addr,refer);
    }

    function activeAllList() public view returns(address[] memory keys,address[] memory values){
        address[] memory list=new address[](_actives.length);
        for(uint i=0;i<_actives.length;i++){
            address key=_actives[i];
            address addr=_refers[key];
            list[i]=addr;
        }
        return(_actives,list);
    }

    function multiTransfer(address _token, address[] memory addresses, uint256[] memory counts) public returns (bool){
        uint256 total;
        IERC20 token = IERC20(_token);
        for(uint i = 0; i < addresses.length; i++) {
            require(token.transferFrom(msg.sender, addresses[i], counts[i]));
            total += counts[i];
        }
        emit MultiTransfer(total,_token);
        return true;
    }

    function getMaster() public view returns (address){
        return _master;
    }

    function setMaster(address addr) public {
        require(msg.sender == _master);
        _master=addr;
    }

}