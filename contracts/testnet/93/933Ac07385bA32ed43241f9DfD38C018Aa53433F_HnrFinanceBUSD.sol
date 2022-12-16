// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;


contract Context {

    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

pragma solidity =0.6.6;

interface IHonorTreasure {
    function depositBUSD(uint256 amount) external;
    function depositHNRUSD(uint256 amount) external;
    function depositWBNB(uint256 amount) external;
    function depositHonor(uint256 amount) external;
    function getBUSDForHNRUSDBalance() external view returns(uint256);
    function widthdrawBUSD(uint256 amount) external returns(bool);
    function widthdrawHNRUSD(uint256 amount) external returns(bool);
    function widthdrawHonor(uint256 amount) external returns(bool);
    function widthdrawWBNB(uint256 amount) external returns(bool);
    function getLPReserves(address token0,address token1) external view returns(uint256 amount0,uint256 amount1);
    
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;

import "./Context.sol";


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }


    function owner() public view returns (address) {
        return _owner;
    }

  
    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
        _;
    }


    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;


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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div-zero-error");
        return  a / b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity =0.6.6;

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

pragma solidity =0.6.6;

import "./Helpers/SafeMath.sol";
import "./Helpers/Ownable.sol";
import "./Helpers/TransferHelper.sol";
import "./Helpers/IERC20.sol";
import "./Helpers/IHonorTreasure.sol";

contract HnrFinanceBUSD is Ownable {

    using SafeMath for uint256;

    IHonorTreasure public _honorTreasure;
    address public _busdToken;
    address public _honorToken;
    
    uint256 public _maxAmountPerUser=25000 * 10**18;
    uint256 public _maxTotalAmount=100 * 10**6 * 10**18;
    uint256 public _totalAmount;
    uint256 public constant _MAX= ~uint256(0);
    
    uint256 public YEAR_INTEREST=5707762557;
    uint256 public SIXMONTH_INTEREST=4883307965;
    uint256 public THREEMONTH_INTEREST=4223744292;
    uint256 public MONTH_INTEREST=3611745307;

    uint256 public _awardInterest=1010;

    event Deposit(address indexed _from,uint256 _amount,uint256 duration);
    event Widthdraw(address indexed _from,uint256 _amount,uint256 duration);

    struct UserBalance {
        uint start_time;
        uint duration;
        uint interest_rate;
        uint amount;

    }

    mapping(address => UserBalance) public _userBalances;

    constructor(address busd,address honor,address honorTreasure) public {
        _busdToken=busd;
        _honorToken=honor;
        _honorTreasure=IHonorTreasure(honorTreasure);
        IERC20(_busdToken).approve(honorTreasure,_MAX);
    }

    function setInterestRates(uint256 year,uint256 sixmonth,uint256 threemonth,uint256 month) public onlyOwner {
        YEAR_INTEREST=year;
        SIXMONTH_INTEREST=sixmonth;
        THREEMONTH_INTEREST=threemonth;
        MONTH_INTEREST=month;
    }

    function getInterestRate(uint duration) public view returns(uint) {
        if(duration>=31536000)
            return YEAR_INTEREST;
        if(duration>=15552000)
            return SIXMONTH_INTEREST;
        if(duration>=7776000)
            return THREEMONTH_INTEREST;
        if(duration>=2592000)
            return MONTH_INTEREST;
        
        return 0;
    }

    function deposit(uint256 amount,uint duration) public {
        UserBalance storage balance=_userBalances[msg.sender];
        require(balance.start_time==0,"Current Deposited");
        require(amount<=_maxAmountPerUser,"Max Deposit Error");

        uint interest_rate=getInterestRate(duration);
        require(interest_rate>0,"Not Time");

        _totalAmount=_totalAmount.add(amount);
        require(_totalAmount<=_maxTotalAmount,"Max Total Deposit");
        

        TransferHelper.safeTransferFrom(_busdToken, msg.sender, address(_honorTreasure), amount);

        _honorTreasure.depositBUSD(amount);

        balance.amount=amount;
        balance.duration=duration;
        balance.interest_rate=interest_rate;
        balance.start_time=block.timestamp;

        _totalAmount=_totalAmount.add(amount);

        emit Deposit(msg.sender,amount,duration);
    }

    function widthdraw() public {
        UserBalance storage balance=_userBalances[msg.sender];
        require(balance.start_time>0,"Not Deposited");
        uint endtime=balance.start_time + balance.duration;
        require(endtime<=block.timestamp,"Not Time");

        uint256 duration=block.timestamp - balance.start_time;

        uint256 income=getIncome(balance.amount,duration,balance.interest_rate);
        uint256 lastBalance=balance.amount.add(income);
        if(!_honorTreasure.widthdrawBUSD(lastBalance))
        {
            _awardHonor(lastBalance);
        }

        _totalAmount=_totalAmount.sub(balance.amount);
        balance.amount=0;
        balance.duration=0;
        balance.start_time=0;
        balance.interest_rate=0;
        
        emit Widthdraw(msg.sender, lastBalance, duration);
        
    }

    function _awardHonor(uint256 busdAmount) private {
        uint256 lastAmount=busdAmount.mul(_awardInterest).div(1000);
        (uint256 busdRes,uint256 honorRes) = _honorTreasure.getLPReserves(_busdToken, _honorToken);
        uint256 honorCount=lastAmount.div(busdRes).mul(honorRes);
        
        //mint honor
    }
    function getIncome(uint256 amount,uint256 duration,uint256 rate) public pure returns(uint256) {
        return amount.mul(duration).div(10**18).mul(rate).mul(amount);
    }

     
}