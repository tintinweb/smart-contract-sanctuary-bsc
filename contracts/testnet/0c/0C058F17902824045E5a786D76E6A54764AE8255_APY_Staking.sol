/**
 *Submitted for verification at BscScan.com on 2022-03-18
*/

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


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


pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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



pragma solidity ^0.8.0;


interface IERC20 {
 
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
 
    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

   
    event Transfer(address indexed from, address indexed to, uint256 value);

  
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.8.0;


contract APY_Staking is Ownable {

    using SafeMath for uint256;

    IERC20 public S_Token;
    IERC20 public R_Token;

    uint256 public _decimal = 10e18;

    uint256 public APY = 35;
    uint256 public series = 31536000;

    struct Data {
        address _user;
        uint256 _stakedAmount;
        uint256 _time;
        uint256 _APYs;  
    }

    mapping (address => Data) public stakers;
    mapping (address => bool) public Invested;

    constructor(address _StakeToken, address _RewardToken){
        S_Token = IERC20(_StakeToken);
        R_Token = IERC20(_RewardToken);
    }


    function stake(uint256 _amount) public {

        require(!Invested[msg.sender],"Already Invested!!!");

        address _person = msg.sender;
        uint256 _subtotal = _amount.mul(_decimal);

        require(S_Token.allowance(msg.sender,address(this)) >= _subtotal, "Allowance for Such Amount Not Approved Yet!!");
        S_Token.transferFrom(_person,address(this),_subtotal);

        Data storage newupdate = stakers[msg.sender];
        newupdate._user = _person;
        newupdate._stakedAmount = _subtotal;
        newupdate._time = block.timestamp;
        newupdate._APYs = calapy(_subtotal);

        Invested[_person] = true;

    }

    function unstake() public {
        require(Invested[msg.sender],"Record Not Found!!!");

        Data storage rec = stakers[msg.sender];
        uint apy_s = rec._APYs;
        uint ml = calreward(rec._time);
        uint final_reward = ml.mul(apy_s);

        S_Token.transfer(msg.sender,rec._stakedAmount);
        R_Token.transfer(msg.sender,final_reward);

        clear(msg.sender);
    }


    function checkAllowance() public view returns (uint) {
        return S_Token.allowance(msg.sender,address(this));
    }

    function Cont_balance(uint _pid) public view returns (uint _bal)  {
        if(_pid == 1){
            return S_Token.balanceOf(address(this));
        }
        if(_pid == 2){
            R_Token.balanceOf(address(this));
        }
        else{
            require(false,"Invalid Selection!!");
        }
    }

    function calreward(uint _time) internal view returns (uint) {
        uint sec = block.timestamp.sub(_time);
        return sec;
    }

    function calapy(uint _amount) internal view returns (uint){
        uint num = _amount.mul(APY).div(10e2);
        return num.div(series);
    }

    function clear(address _person) internal {
        Data storage newupdate = stakers[_person];
        newupdate._stakedAmount = 0;
        newupdate._time = 0;
        newupdate._APYs = 0;
        Invested[_person] = false;
    }

    function Emg_withdraw() public onlyOwner {
        S_Token.transfer(msg.sender,S_Token.balanceOf(address(this)));
        R_Token.transfer(msg.sender,R_Token.balanceOf(address(this)));
    }   


}