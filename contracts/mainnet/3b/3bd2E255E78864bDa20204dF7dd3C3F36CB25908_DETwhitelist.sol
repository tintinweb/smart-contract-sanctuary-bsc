/**
 *Submitted for verification at BscScan.com on 2022-08-19
*/

pragma solidity ^0.8.0;

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

    function getTime() public view returns (uint256) {
        return block.timestamp;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

contract DETwhitelist is Ownable{
    using SafeMath for uint256;

    address[27] public _whiteRewardKeys=[
        0x47cc268aC28C16792f04eC6efc7d52278228f224,
        0x0c08bD73cB6a831DC6f2aD83C2827C63F2394677,
        0xABF3C9C73d08e19232353be1a8320A08f1da3f40,
        0x5c20f355aEa3F0d79A7d8517eF067370d5F57ebb,
        0xfC3d79da6E6512dCA80E2b0B113654DEbd6b81cD,
        0xdE66189dE61Bd08D5AFC1061F9c1EDc086EDF650,
        0xF8904391f3DF81888a9b8F2c32DD1D52a45F98AE,
        0xd398ae6BA0C14a4F9bF969F12ce3DEd30f605Fe0,
        0xb9E62EDDB57B2cEfb2C3CC8F9FA10CF08847bF36,
        0x7252449FC6Ff35cB5820D024D349DF48686a4467,
        0x028E1054DcC091Da99b826D28055a423DCbCe03e,
        0xFaABEf8e138da96f0F84c1eB24cA0c936CE7b1c9,
        0xfe7896FA898C062860d2b1Fe356Ad2B0F1f41727,
        0xf7f92D0C643EE0105E99d605aDA357E88Fe53F87,
        0x142eDA21c291c467066e0b94B85B3D5beC7E3429,
        0x4cA8d2B532d11Db9D2B82131C0e1F288e5e5139c,
        0x8EcEd98bF0Ca1d0a524FBBec2B804C46b5f9EA05,
        0xf845b113ba3cBCf5e4c8A616d79E04648277d60A,
        0x437723E22AfEfFD296AF834F7F503C684Af21B21,
        0xb691F128E43003A25bB5c8304649636677c60E2c,
        0xe7A5c5C83BB02Ac06aE5448F7A22C99EE57081d5,
        0xA09302c2Fbb418061Fcc1fA1f8C92c9986360012,
        0x2b8c56d17b8e18b86b95Ed78A7b96922cf336571,
        0x941F920B26b6a1809389f29d816402CE116DdcEa,
        0x91B878F93f58E6fe767114b3d34B064AE8C279Bf,
        0x709F518313EBa1F247e4951db0F0ad3bEA688bAE,
        0x88392E3Cae316410f444b07966d0c100d9980088

     ];
 
    event reward_event(address to,uint256 amount);
    function div_reward(IERC20 _token) public onlyOwner
    {
         
        uint256 amount=_token.balanceOf(address(this)).div(_whiteRewardKeys.length);
        for(uint i=0;i<_whiteRewardKeys.length;i++)
        {
            address to=_whiteRewardKeys[i];
            
            _token.transfer(to,amount);   
           emit reward_event(to,amount);
        }
        
    }
}