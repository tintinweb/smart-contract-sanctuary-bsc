/**
 *Submitted for verification at BscScan.com on 2022-08-24
*/

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
}

contract ClaimPool {
    using SafeMath for uint256;
    struct UserInfo {
        uint256 originalAmounts; //原币数量
        uint256 beginTime; //开始时间
        uint256 claimedAmount; //已提取的数量    
    }
    address public owner;
    address public tokenAddress = 0x1736d893526201D832CF594B52335Da367150fb1;
    address public recipientWallet = 0xeFa629f26E320a1888285d87F32428B1B5043249; //收Fee钱包
    address[] public holders;
    uint256 public fee;
    uint256 public totalClaimedAmount;
    bool public claimEnable;  //提币开关
    mapping(address => UserInfo) public userInfo;
    mapping (address => bool) public isHolderExist;
    constructor() {
        owner = recipientWallet;
        claimEnable = true;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setTokenAddress(address value) public onlyOwner {
        tokenAddress = value;
    }

    function setClaimEnable(bool _claimEnable) public onlyOwner {
        claimEnable = _claimEnable;
    }

    function setClaimFee(uint256 _fee) public onlyOwner {
        fee = _fee;
    }

    function reflect(address[] memory accounts, uint256[] memory amounts) public onlyOwner {
        uint256 length = accounts.length;
        require(length > 0, "no account");
        require(amounts.length == length, 'invalid amounts');
        UserInfo storage data;
        for(uint8 i = 0; i < length; i++) {
            address cur = accounts[i];
            data = userInfo[cur];
            data.originalAmounts = amounts[i].mul(1e18);
            data.beginTime = block.timestamp;
            if(!isHolderExist[cur]) {
               holders.push(cur); 
               isHolderExist[cur] = true;
            }       
        }

    }

    function availableRewards(address account) external view returns(uint){
        UserInfo storage data = userInfo[account];
        if(data.originalAmounts == 0) return 0;
        uint256 gain;
        uint256 beginTime = data.beginTime;
        uint256 originalAmount = data.originalAmounts;
        if(block.timestamp - beginTime >= 199 days) {
            gain = data.originalAmounts;
        } else {
            uint256 lapsedDays = (block.timestamp - beginTime).div(1 days);
            gain = originalAmount.mul(lapsedDays.add(1)).div(200);
        }

        return gain.sub(data.claimedAmount);
    }

    function claimRewards(uint amount) external {
        require(claimEnable, "pls wait");
        require(amount > 0, 'invalid amount');
        require(IBEP20(tokenAddress).balanceOf(address(this)) >= amount, 'contract balance not enough');
        require(this.availableRewards(msg.sender) >= amount, "unsufficient balance");
        if(fee >0) {
            require(IBEP20(tokenAddress).allowance(msg.sender, address(this)) >= fee, 'allowance not enough');
		    require(IBEP20(tokenAddress).balanceOf(msg.sender) >= fee, 'balance not enough');
            TransferHelper.safeTransferFrom(tokenAddress, msg.sender, recipientWallet, fee);
        }
        UserInfo storage data = userInfo[msg.sender];
        data.claimedAmount = data.claimedAmount.add(amount);
        IBEP20(tokenAddress).transfer(msg.sender, amount);
        totalClaimedAmount = totalClaimedAmount.add(amount);
    }

    function viewAmountOfThis() public view returns(uint) {
        uint amount = IBEP20(tokenAddress).balanceOf(address(this));
        return amount.div(1e18);
    }

    function exactLeftTokens() external onlyOwner {
        uint balanceOfThis = IBEP20(tokenAddress).balanceOf(address(this));
        require( balanceOfThis > 0, 'no balance');
        IBEP20(tokenAddress).transfer(msg.sender, balanceOfThis);
    }
}