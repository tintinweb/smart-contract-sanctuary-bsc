/**
 *Submitted for verification at BscScan.com on 2022-06-23
*/

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


/////   _____ _____   ____ _____ _       _____       ____  ______     __          __     _____  
/////   / ____|  __ \ / __ |_   _| |     / ____|     / __ \|  ____|    \ \        / /\   |  __ \ 
/////  | (___ | |__) | |  | || | | |    | (___      | |  | | |__        \ \  /\  / /  \  | |__) |
/////   \___ \|  ___/| |  | || | | |     \___ \     | |  | |  __|        \ \/  \/ / /\ \ |  _  / 
/////   ____) | |    | |__| _| |_| |____ ____) |    | |__| | |            \  /\  / ____ \| | \ \ 
/////  |_____/|_|     \____|_____|______|_____/      \____/|_|             \/  \/_/    \_|_|  \_\
/////                                                                                     
                                                                                                                  
                                                                                                                 

library SafeMathInt {

    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != -1 || a != MIN_INT256);

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
        require(b != 0);
        return a % b;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipRenounced(address indexed previousOwner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Not owner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(_owner);
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Zero Address Validation");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// Spoils Of War : All the Profits from Arsenal NFT Community will be sit here and airdropped every 30 Days

contract SpoilsOfWar is Ownable {


    using SafeMath for uint256;
    
    uint256 public totalRewardsToDate;             // total rewards airdropped to date
    mapping(uint256 => uint256) rewardsPerEra;  // store rewards in each era

    uint256 public lastAirdropTime;            

    uint256 public warCycle;    

    mapping(address => uint256) rewardsPerUser;  // how much rewards each user received from spoils of war

    address public rewardTokenAddress;

    constructor(address _tokenAddress)  {
        warCycle = 1;
        rewardTokenAddress = _tokenAddress;
    }

    function distributeRewards(address[] memory _recipients, uint256[] memory _amount) external onlyOwner returns (bool) {
       
        uint256 totalRewards = 0;
        for (uint i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "Invalid Address");
            require(IERC20(rewardTokenAddress).transfer(_recipients[i], _amount[i]));

            rewardsPerUser[_recipients[i]] = rewardsPerUser[_recipients[i]].add(_amount[i]); 
            totalRewards = totalRewards.add(_amount[i]);            
        }

        rewardsPerEra[warCycle] = totalRewards;
        warCycle++ ;        
        totalRewardsToDate = totalRewardsToDate.add(totalRewards);  

        lastAirdropTime = block.timestamp;     
        
        return true;
    }

    function setRewardTokenAddress (address _tokenAddress) external onlyOwner {
        require(_tokenAddress != address(0),"Invalid Address");
        rewardTokenAddress = _tokenAddress;
    }

    function withdrawETH (address _to) external onlyOwner {
        require( _to != address(0),"Invalid Address");
        payable(_to).transfer(address(this).balance);

    }

    function withdrawErc20 (address _tokenAddress, address _to, uint256 _amount) external onlyOwner {
        require( _to != address(0), "Invalid Address");
        require( _tokenAddress != address(0), "Invalid Address");
        require( IERC20(_tokenAddress).balanceOf(address(this)) >= _amount, "Insufficient Balance");
        IERC20(_tokenAddress).transfer(_to, _amount);
    }
    
}