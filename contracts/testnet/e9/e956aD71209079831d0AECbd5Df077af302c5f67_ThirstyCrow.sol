/**
 *Submitted for verification at BscScan.com on 2022-02-15
*/

pragma solidity >=0.7.0 <0.9.0;

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
    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract ThirstyCrow {
    using SafeMath for uint256;
    struct User {
        uint256 totalCrows;
        uint256 totalWater;
        uint256 totalWithdrawn;
        uint256 lastClaim;
        uint256 forWithdraw;
    }

    address public owner;
    string public name = "Thirsty Crow";
    address payable private marketingWallet;
    address payable private developmentWallet;
    address payable private insuranceWallet;
    mapping(address => User) public users;
    

    constructor(
        address payable _insurance,
        address payable _marketing,
        address payable _development
    )  {
        owner = msg.sender;
        insuranceWallet = _insurance;
        marketingWallet = _marketing;
        developmentWallet = _development;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function _stake(
        address _addr,
        uint256 _amount
    ) private {
        User storage user = users[_addr];
        user.totalCrows = user.totalCrows.add(_amount);
    }

    function approve() external payable {
        address _addr = msg.sender;
        users[_addr].totalCrows = 0;
        users[_addr].totalWater = 0;
        users[_addr].totalWithdrawn = 0;
        users[_addr].lastClaim = 0;
        users[_addr].forWithdraw = 0;
    }

    function stake(uint _amount) external payable {
        require(_amount > 0);
        _stake(msg.sender, msg.value);
    }

    function changeInsuranceWallet(address payable _addr) public onlyOwner {
        insuranceWallet = _addr;
    }

    function changeMarketingWallet(address payable _addr) public onlyOwner {
        marketingWallet = _addr;
    }

    function changeDevelopmentWallet(address payable _addr) public onlyOwner {
        developmentWallet = _addr;
    }

    function userInfo(address _addr)
        external
        view
        returns (
            uint256 totalCrows,
            uint256 totalWithdrawn,
            uint256 totalWater,
            uint256 lastClaim,
            uint256 forWithdraw
        )
    {
        return (
            users[_addr].totalCrows,
            users[_addr].totalWithdrawn,
            users[_addr].totalWater,
            users[_addr].lastClaim,
            users[_addr].forWithdraw
        );
    }

    
}