/**
 *Submitted for verification at BscScan.com on 2022-04-07
*/

pragma solidity ^0.4.26;
pragma experimental ABIEncoderV2;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DepositToken is Ownable {
    event SetPackage(uint256 id, address token, uint256 amount);
    event Deposit(address user, uint256 packageId);
    event Withdraw(address token, uint256 amount);

    struct Package {
      uint256 id;
      IERC20 token;
      uint256 amount;
    }

    mapping(uint256 => Package) public packages;
    address public ceoAddress = address(0x64470E5F5DD38e497194BbcAF8Daa7CA578926F6);

    constructor() public {}

    modifier onlyManager() {
        require(msg.sender == owner || msg.sender == ceoAddress);
        _;
    }

    modifier onlyCeoAddress() {
        require(msg.sender == ceoAddress);
        _;
    }

    function setPackage(uint256 _id, address _token, uint256 _amount) public onlyCeoAddress {
      require(_token != address(0), "Invalid address!");
      //require(_amount > 0, "Amount must be >0!");

      IERC20 erc20 = IERC20(_token);
      packages[_id] = Package({id: _id, token: erc20, amount: _amount});
      emit SetPackage(_id, _token, _amount);
    }

    function deposit(uint _id) public {
        require(packages[_id].token != address(0), "Invalid token!");
        IERC20(packages[_id].token).transferFrom(msg.sender, address(this), packages[_id].amount);
        emit Deposit(msg.sender, _id);
    }
    
    function withdraw(address _token, uint256 _amount) public onlyManager {
        IERC20 erc20 = IERC20(_token);
        require(erc20.balanceOf(address(this)) > 0, "Cannot withdraw 0!");
        erc20.transfer(msg.sender, _amount);
        emit Withdraw(_token, _amount);
    }

    function changeCeo(address _address) public onlyCeoAddress {
        require(_address != address(0));
        ceoAddress = _address;
    }
}