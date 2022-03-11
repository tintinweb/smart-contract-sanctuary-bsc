/**
 *Submitted for verification at BscScan.com on 2022-03-11
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface xxxxxxx {
    
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    
    constructor()  {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor()  {
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

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract xxxxxxxx is Ownable{
    using SafeMath for uint256;

    xxxxxxx public waynewallet;

    uint256 public xxxxx = 10;
    uint256 public xxxxxx = 990;
    address public xxxxxxxxx =   0x5500Bb8b6d866A629d08D1b8AFb39f262e55281d;
    address public xxxxxxxxxx =  0x66dcb8AF26fC524d3A11324177a12BD06ce2309c;

    event waynewalletxxxxxxxxxxxxx(address indexed user, uint256 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    event xxxxxxxxxxx(address indexed owner, uint256 xxxxx, uint256 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx);
    event FailSafe(address indexed token, address to, uint256 amount);
    event Setxxxxxxxxx(address indexed owner, address xxxxxxxxx);
    event Setxxxxxxxxxx(address indexed owner, address xxxxxxxxxx);
    
    constructor(xxxxxxx _waynewallet){
        waynewallet = _waynewallet;
    }
    
    function setxxxxxxxxx(address _xxxxxxxxx)external onlyOwner {
        require(_xxxxxxxxx!= address(0x0),"Recharge :: zero address dected");
        xxxxxxxxx = _xxxxxxxxx;
        emit Setxxxxxxxxx(msg.sender, _xxxxxxxxx);
    }
    
    function setxxxxxxxxxx(address _xxxxxxxxxx)external onlyOwner {
        require(_xxxxxxxxxx!= address(0x0),"Recharge :: zero address dected");
        xxxxxxxxxx = _xxxxxxxxxx;
        emit Setxxxxxxxxxx(msg.sender, _xxxxxxxxxx);
    }
    
    function exchange(uint256 _amount)external {
        require(_amount > 0,"Recharge :: Deposit number of tokens");
        uint256 tokens = _amount.mul(xxxxxx).div(1e3);
        waynewallet.transferFrom(msg.sender, xxxxxxxxx, _amount.sub(tokens));
        waynewallet.transferFrom(msg.sender, xxxxxxxxxx, tokens);
        emit waynewalletxxxxxxxxxxxxx(msg.sender, _amount);
    }
    
    function xxxxxxxxxxxx(uint256 _xxxxx, uint256 _xxxxxx)external onlyOwner {
        require(_xxxxx.add(_xxxxxx) == 1000,"Invalid ");
        xxxxx = _xxxxx;
        xxxxxx = _xxxxxx;
        emit xxxxxxxxxxx(msg.sender, _xxxxx, _xxxxxx);
    }
    
    function failSafe(address _token,address _to, uint256 _amount)external onlyOwner {
        
        if(_token == address(0x0)){
            payable(msg.sender).transfer(address(this).balance);
            emit FailSafe(address(this), _to, address(this).balance);
        }
        else {
            xxxxxxx(_token).transfer(_to, _amount);
            emit FailSafe(_token, _to, _amount);
        }
    }
}