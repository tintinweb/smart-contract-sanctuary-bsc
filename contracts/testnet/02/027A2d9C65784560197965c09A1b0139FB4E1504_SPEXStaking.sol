/**
 *Submitted for verification at BscScan.com on 2023-03-06
*/

pragma solidity 0.8.10;

// SPDX-License-Identifier: UNLICENSED
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

contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {   
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function ownable(address _newowner) internal {
        _transferOwnership(_newowner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SPEXStaking is Initializable , Ownable {

    struct Pool {
        address token0;
        address token1;
        uint ttlToken0Invested;
        uint ttlToken1Invested;
        uint share;
    }

    struct InvestPool {
       mapping(address=>Deposit[]) deposits;
       mapping(address=>uint) totalDeposits;
       mapping(address=>uint) totalWithdrawal;
       mapping(address=>uint) checkpoint; 
       uint total;
    }

    struct Deposit {
        address token;
        uint amount;
        uint start;
        uint share;
    }

    uint public lastPoolId;
    mapping(uint => Pool) public pools;
    mapping(address => mapping(uint=>InvestPool)) public userInvestment;
    mapping(address =>mapping(address =>bool)) public isPoolExist;

    event PoolCreated(address token0 , address token1 ,uint share);
    event Invest(uint poolId , address token, uint amount);
    event Claim(address user, uint poolId, address token, uint amount);

    function initialize(address _owner) external  initializer {
        ownable(_owner);
        lastPoolId=1;
    }

    function createPool (address _token0, address _token1, uint _share) external  onlyOwner {
        require(!isPoolExist[_token0][_token1],"Pool already exist!");
        pools[lastPoolId].token0 =_token0;
        pools[lastPoolId].token1 =_token1;
        pools[lastPoolId].share =_share;
        isPoolExist[_token0][_token1]= true;
        isPoolExist[_token1][_token0]= true;
        emit PoolCreated(_token0 , _token1 ,  _share);
    }

    function deposit(uint _poolId, address _token, uint _amount ) external {
        require(pools[_poolId].token0 ==_token || pools[_poolId].token1 ==_token ,"Invalid token");
        require(IERC20(_token).allowance(msg.sender,address(this))>=_amount,"ERC20: allownace exceed!");
        IERC20(_token).transferFrom(msg.sender,address(this),_amount);
        if(pools[_poolId].token0 ==_token ){
            pools[_poolId].ttlToken0Invested += _amount;
        } else {
            pools[_poolId].ttlToken1Invested += _amount;
        }
        // users[msg.sender].deposits.push(Deposit(_token,_amount,block.timestamp,pools[_poolId].share));
        userInvestment[msg.sender][_poolId].deposits[_token].push(Deposit(_token,_amount,block.timestamp,pools[_poolId].share));
        userInvestment[msg.sender][_poolId].totalDeposits[_token]= _amount;
        emit Invest(_poolId , _token, _amount);
    }

    function getUserDividents(address _user, uint _poolId,  address _token) public view returns(uint){
        Deposit[] memory deposits = userInvestment[_user][_poolId].deposits[_token];
        uint totalAmount;
        for(uint i=0; i<deposits.length; i++) {
                Deposit memory _deposit = userInvestment[_user][_poolId].deposits[_token][i];
                uint256 finish = _deposit.start+300; // 365 days
                if (userInvestment[_user][_poolId].checkpoint[_token] < finish) {
                    uint256 share = (_deposit.amount*_deposit.share)/100;
                    uint256 from = _deposit.start > userInvestment[_user][_poolId].checkpoint[_token] ? _deposit.start : userInvestment[_user][_poolId].checkpoint[_token];
                    uint256 to = finish < block.timestamp ? finish : block.timestamp;
                    if (from < to) {
                        totalAmount = totalAmount+(share*(to-from))/(300); //365 days
                    }
                }
           
        }
         return (totalAmount);
    }

    function claimReward(address _user, uint _poolId, address _token) public {
        require(pools[_poolId].token0 ==_token || pools[_poolId].token1 ==_token ,"Invalid token");
        uint amount = getUserDividents(_user,_poolId,_token);
        IERC20(_token).transfer(_user,amount);
        userInvestment[_user][_poolId].checkpoint[_token] =block.timestamp;
        emit Claim(_user,  _poolId,  _token,  amount);
    }

    function withdrawToken(address _user, uint _poolId, address _token, uint _amount) external {
        claimReward( _user,  _poolId, _token);
        Deposit[] memory deposits = userInvestment[_user][_poolId].deposits[_token];
        uint withdwAmt;
        for(uint i=0; i<deposits.length; i++) {
            if(deposits[i].amount>=_amount) {
                userInvestment[_user][_poolId].deposits[_token][i].amount -= _amount;
                withdwAmt =_amount;
                break;
            } else {
               _amount = _amount-deposits[i].amount;
                withdwAmt +=deposits[i].amount;
                userInvestment[_user][_poolId].deposits[_token][i].amount=0;
            }
        }
        IERC20(_token).transfer(_user,withdwAmt);
    }

    function changeRewardShareInPool(uint _poolId, uint _newShare) external  onlyOwner {
        pools[_poolId].share = _newShare;
    }

    function getDepositsByUser(address _user, uint _poolId, address _token) external  view returns(Deposit[] memory) {
        return userInvestment[_user][_poolId].deposits[_token];
    }
}