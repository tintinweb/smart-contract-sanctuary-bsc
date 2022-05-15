/**
 *Submitted for verification at BscScan.com on 2022-05-15
*/

// File: YiBoxToken/Context.sol
pragma solidity ^0.6.6;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.6.6;

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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.6.6;

library SafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint32 c = a - b;

        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint32 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.6.6;

library SafeMathExt {
    function add128(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        require(c >= a, "uint128: addition overflow");

        return c;
    }

    function sub128(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b <= a, "uint128: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function add64(uint64 a, uint64 b) internal pure returns (uint64) {
        uint64 c = a + b;
        require(c >= a, "uint64: addition overflow");

        return c;
    }

    function sub64(uint64 a, uint64 b) internal pure returns (uint64) {
        require(b <= a, "uint64: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function safe128(uint256 a) internal pure returns(uint128) {
        require(a < 0x0100000000000000000000000000000000, "uint128: number overflow");
        return uint128(a);
    }

    function safe64(uint256 a) internal pure returns(uint64) {
        require(a < 0x010000000000000000, "uint64: number overflow");
        return uint64(a);
    }

    function safe32(uint256 a) internal pure returns(uint32) {
        require(a < 0x0100000000, "uint32: number overflow");
        return uint32(a);
    }

    function safe16(uint256 a) internal pure returns(uint16) {
        require(a < 0x010000, "uint32: number overflow");
        return uint16(a);
    }
}

pragma solidity ^0.6.6;

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

pragma solidity ^0.6.6;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    function transferOwnership(address newOwner) public {
        require(newOwner != address(0), "newOwner invalid");
        if (_owner != address(0)) {
            require(_msgSender() == _owner, "not owner");
        }
        
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface YiToken {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _amount) external returns (bool);
    function setMainPool(address pool_) external;
    function mint(address dest_) external;
}

contract MainPool is Ownable {
    using SafeMath for uint256;
    using SafeMath32 for uint32;

    uint256 decimal = 10 ** 18;
    address mainToken;

    address public StakePool;
    address public KeyPool;
    address public HashratePool;

    address mainPool;

    function setTokenMain(address _addr) public {
        require(_addr != address(0), "token is invali");
        mainToken = _addr;
        // YiToken(_addr).setMainPool(address(this));
    }

    function allocation () public {
        require(mainToken != address(0), "token is invali");
        YiToken(mainToken).mint(address(this));
    }


    function setMainPool(address _main) external onlyOwner{
        require(_main != address(0));
        mainPool = _main;
    }

    function setStakePool(address _stake) external onlyOwner {
        require(_stake != address(0));
        StakePool = _stake;
    }

    function setKeyPool(address _key) external onlyOwner {
        require(_key != address(0));
        KeyPool = _key;
    }

    function setHashratePool(address _hashrate) external onlyOwner {
        require(_hashrate != address(0));
        HashratePool = _hashrate;
    }

    function tranMainPool(address _new) external {
        require(_new != address(0));
        require(msg.sender == mainPool);
        mainPool = _new;
    }

    function tranStakePool(address _new) external {
        require(_new != address(0));
        require(msg.sender == StakePool);
        StakePool = _new;
    }

    function tranKeyPool(address _new) external {
        require(_new != address(0));
        require(msg.sender == KeyPool);
        KeyPool = _new;
    }

    function tranHashratePool(address _new) external {
        require(_new != address(0));
        require(msg.sender == HashratePool);
        HashratePool = _new;
    }

    //给指定账号分配指定数量的币
    function allocTo(address _to, uint32 _amount) external onlyOwner {
        require(_to != address(0), " target address is null ... ");
        require(_amount > 0, " wrong amount ... ");

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _amount, " Insufficient balance ... ");
        bool res = YiToken(mainToken).transfer(_to,_amount);
        require(res);
    }

    function allocStake(uint32 _stake) external {
        require(msg.sender == StakePool);
        uint256 _need = 0;
        if (_stake <= 50000000) {
            _need = 50000 * decimal;
        } else if (_stake <= 100000000) {
            _need = 75000 * decimal;
        } else if (_stake <= 200000000) {
            _need = 100000 * decimal;
        } else {
            _need = 125000 * decimal;
        }

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _need);
        bool res = YiToken(mainToken).transfer(StakePool,_need);
        require(res);
    }
}