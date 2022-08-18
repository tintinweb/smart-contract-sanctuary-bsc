/**
 *Submitted for verification at BscScan.com on 2022-08-18
*/

// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.0;

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
pragma solidity 0.7.0;


library LibERC20 {

   function approveQuery(address _token,address _spender) internal view returns(uint256 _amount){
       _amount=IERC20(_token).allowance(msg.sender,_spender);
   }

   function queryDecimals(address _token) internal view returns(uint256 decimals){
       decimals=IERC20(_token).decimals();
   }

    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    ) internal {
        uint256 size;
        assembly {
            size := extcodesize(_token)
        }
        require(size > 0, "LibERC20: Address has no code");
        (bool success, bytes memory result) = _token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, _from, _to, _value));
        handleReturn(success, result);
    }

    function transfer(
        address _token,
        address _to,
        uint256 _value
    ) internal {
        uint256 size;
        assembly {
            size := extcodesize(_token)
        }
        require(size > 0, "LibERC20: Address has no code");
        (bool success, bytes memory result) = _token.call(abi.encodeWithSelector(IERC20.transfer.selector, _to, _value));
        handleReturn(success, result);
    }

    function handleReturn(bool _success, bytes memory _result) internal pure {
        if (_success) {
            if (_result.length > 0) {
                require(abi.decode(_result, (bool)), "LibERC20: contract call returned false");
            }
        } else {
            if (_result.length > 0) {
                // bubble up any reason for revert
                revert(string(_result));
            } else {
                revert("LibERC20: contract call reverted");
            }
        }
    }
}
pragma solidity =0.7.0;

interface IBiswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function swapFee() external view returns (uint32);
    function devFee() external view returns (uint32);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
    function setSwapFee(uint32) external;
    function setDevFee(uint32) external;
}
pragma solidity 0.7.0;

library LibBiswapPair {

   function approveQuery(address _token,address _spender) internal view returns(uint256 _amount){
       _amount=IBiswapPair(_token).allowance(msg.sender,_spender);
   }

   function queryDecimals(address _token) internal pure returns(uint256 decimals){
       decimals=IBiswapPair(_token).decimals();
   }

    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint256 _value
    ) internal {
        uint256 size;
        assembly {
            size := extcodesize(_token)
        }
        require(size > 0, "LibERC20: Address has no code");
        (bool success, bytes memory result) = _token.call(abi.encodeWithSelector(IBiswapPair.transferFrom.selector, _from, _to, _value));
        handleReturn(success, result);
    }

    function transfer(
        address _token,
        address _to,
        uint256 _value
    ) internal {
        uint256 size;
        assembly {
            size := extcodesize(_token)
        }
        require(size > 0, "LibERC20: Address has no code");
        (bool success, bytes memory result) = _token.call(abi.encodeWithSelector(IBiswapPair.transfer.selector, _to, _value));
        handleReturn(success, result);
    }

    function handleReturn(bool _success, bytes memory _result) internal pure {
        if (_success) {
            if (_result.length > 0) {
                require(abi.decode(_result, (bool)), "LibERC20: contract call returned false");
            }
        } else {
            if (_result.length > 0) {
                // bubble up any reason for revert
                revert(string(_result));
            } else {
                revert("LibERC20: contract call reverted");
            }
        }
    }
    //返回池子币数量
    function getReserves(address _token) internal view returns(uint112 reserve0, uint112 reserve1){
        (reserve0, reserve1,) = IBiswapPair(_token).getReserves();
    }
    //总流通量
     function getTotalSupply(address _token) internal view returns(uint balance){
       balance = IBiswapPair(_token).totalSupply();
    }
}
pragma solidity >=0.7.0;
pragma experimental ABIEncoderV2;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }

    function div(uint x, uint y) internal pure returns (uint z) {
        require(y>0,'ds-math-div-overflow');
        z = x / y;
        //require((z = x / y) * y == x, 'ds-math-div-overflow');
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

pragma solidity 0.7.0;

struct BalanceMap{
    mapping(address => mapping(address => BalanceInfo)) userBalanceMap;
}
struct BalanceInfo{
    uint balance;
}
struct Transferin{
    uint amount; //余额
    uint timein; //转入时间
}

struct TransferOut{
    uint amount; //余额
    uint timeout; //转出时间
}
struct IncomeInfo{
    uint amount; //收益
    uint timecome; //分配时间
}
struct IncomeAllInfo{
    address addr;
    uint amount; //收益
    uint timecome; //分配时间
}
contract kugoushibbdefi{
    using SafeMath for uint; 
    address owner;
    uint addressNum = 0;//地址计数器（只记录质押类型地址）
    mapping(uint => address) addressMap;//地址计数器（只记录质押类型地址）
    mapping(address => uint) addressNumMap;//转币次数
    mapping(address=>mapping(address=>BalanceInfo)) userBalanceMap;
    event _transferIn(address userAddr,address token,uint amount); 
    event _transferOut(address userAddr,address token,uint amount);
    event _transferInkgt(address userAddr,uint amount);
    event _transferOutkgt(address userAddr,uint amount);
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    //kgt合约地址
    address kgttokenaddress = 0xB858EC225986122eBd1AC6a1A3b9C27008f42801;
    //shibb合约地址
    address shibbtokenaddress = 0x0E0d97DdD63eb75fBACE026B8A3E56cBE225c298;
    //lp-shibb-kgt合约地址
    address shibbKgtAddress = 0x762F95280a168fcdcCefEb9E0B837158C41A4AE0;
    //设置总池子
    uint allKgtBalance = 0;
    //已分红总数量
    uint aleryKgtBalance = 0;
    //总转入lp数量
    uint allShibbLpNum = 0;
    constructor(address tokenOwnerAddress){
      owner = tokenOwnerAddress;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0),"newOwner is null.");
        owner = newOwner;
        emit OwnerSet(owner, newOwner);
    }
    function getOwner() external view returns (address) {
        return owner;
    }
    //是否是合约地址
     function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    function transferInkgt(uint _amount) external payable onlyOwner returns(bool){
        address _token = kgttokenaddress;
        require(isContract(msg.sender) == false,'address cannot be the contract address');
        require(_token!=address(0),'token invalid');
        require(_amount>0,'amount must be greater than 0');
        require(LibERC20.approveQuery(_token,address(this)) >= _amount, "Insufficient authorization limit remaining");
        //开始转账
        LibERC20.transferFrom(_token, msg.sender, address(this), _amount);
        allKgtBalance = allKgtBalance.add(_amount);
        emit _transferInkgt(msg.sender,_amount);
        return true;
    }
    function transferOutkgt(uint _amount) external payable onlyOwner returns(bool){
        address _token = kgttokenaddress;
        require(isContract(msg.sender) == false,'address cannot be the contract address');
        require(_token!=address(0),'token invalid');
        require(_amount>0,'amount must be greater than 0');
        require(allKgtBalance>=_amount,'The total pool balance of kgt is insufficient');
        //开始转账
        LibERC20.transfer(_token, msg.sender, _amount);
        allKgtBalance = allKgtBalance.sub(_amount);
        emit _transferOutkgt(msg.sender,_amount);
        return true;
    }
    function transferIn(address _token,uint _amount) external payable returns(bool){
        require(isContract(msg.sender) == false,'address cannot be the contract address');
        require(_token!=address(0),'token invalid');
        require(_amount>0,'amount must be greater than 0');
        require(LibERC20.approveQuery(_token,address(this)) >= _amount, "Insufficient authorization limit remaining");
        //开始转账
        LibERC20.transferFrom(_token, msg.sender, address(this), _amount);
        BalanceInfo storage _balanceInfo = userBalanceMap[msg.sender][_token];
        _balanceInfo.balance = _balanceInfo.balance.add(_amount);
        if(_token == shibbKgtAddress){
            allShibbLpNum = allShibbLpNum.add(_amount);
            if(addressNumMap[msg.sender] <= 0){
                addressMap[addressNum] = msg.sender;
                addressNum = addressNum.add(1);
            } 
           addressNumMap[msg.sender] = addressNumMap[msg.sender]+1;
        }
        emit _transferIn (msg.sender,_token,_amount);
        return true;
    }
    function transferOut(address _token,uint _amount) external payable returns(bool){
        require(isContract(msg.sender) == false,'address cannot be the contract address');
        require(_token!=address(0),'token invalid');
        require(_amount>0,'amount must be greater than 0');
        BalanceInfo storage _balanceInfo = userBalanceMap[msg.sender][_token];
        require(_balanceInfo.balance >=_amount,'Insufficient recoverable assets');
        //开始转账
       LibERC20.transfer(_token, msg.sender, _amount);
        _balanceInfo.balance = _balanceInfo.balance.sub(_amount);
        if(_token == shibbKgtAddress){
            allShibbLpNum = allShibbLpNum.sub(_amount);
        }
        emit _transferOut(msg.sender,_token,_amount);
        return true;
    }
    function queryBalance(address _token) public view returns(uint){
        BalanceInfo storage _balanceInfo = userBalanceMap[msg.sender][_token];
        return (_balanceInfo.balance);
    }
    function approveQuery(address _token,address _sender) public view returns(uint256 balance){
        balance = LibERC20.approveQuery(_token,_sender);
    }
    function queryDecimals(address _token) internal view returns(uint256 decimals){
       decimals=LibERC20.queryDecimals(_token);
   }
   function querykgtBalance() public view returns(uint balance){
      return allKgtBalance;
   }
   function queryallLpNum() public view returns(uint balance){
      return allShibbLpNum;
   }
   function distributionIncome() public onlyOwner returns(bool){
       require(addressNum>0,'The number of addresses must be greater than 0');
       require(allKgtBalance>0,'The balance of the kgt income pool is insufficient!');
        uint alllpBalance = LibBiswapPair.getTotalSupply(shibbKgtAddress);
         (,uint reserve1) = LibBiswapPair.getReserves(shibbKgtAddress);
       for(uint i=0;i<addressNum;i++){
            uint lpbalance  = userBalanceMap[addressMap[i]][shibbKgtAddress].balance;
            if(lpbalance > 0){
                uint kgtBalance =   lpbalance.mul(reserve1).mul(2).div(alllpBalance);
                kgtBalance = kgtBalance.div(5).div(365);
                if(kgtBalance >0 && allKgtBalance>=kgtBalance){
                     BalanceInfo storage _balanceInfo = userBalanceMap[addressMap[i]][kgttokenaddress];
                     _balanceInfo.balance = _balanceInfo.balance.add(kgtBalance);
                     allKgtBalance = allKgtBalance.sub(kgtBalance);
                     aleryKgtBalance = aleryKgtBalance.add(kgtBalance);
                }
            }
       }
       return true;
   }

}