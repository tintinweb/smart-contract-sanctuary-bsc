//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./IERC20.sol";
import "./Ownable.sol";

    struct CommissionRecord {
        uint totalCommission;
        uint totalInvitees;
    }

    error ZeroBalance();
    error InvalidPercent();

contract IDOPlatform is Ownable {

    IERC20 constant USDT = IERC20(0x4Db8F7C0821D8e747099df8e58D13B70BfcF221d);
    address constant defaultCommisonAddress = 0xEE0f26Aaabf15aFc10DF94EDA481C8C3CA1ccaD8;
    uint constant commisonBase = 100;

    //邀請%數
    uint public commisonPercent = 20;
    //所有購買人地址
    address[] public depositAddresses;
    //邀請人獲利
    mapping(address => CommissionRecord) public commissionRecord;
    //購買人數量
    mapping(address => uint) public depositRecord;

    event Deposit(address indexed caller, address indexed referral, uint indexed amount);
    event CommisonSend(address indexed referral, uint indexed amount);

    function deposit(address referral, uint amount) external {
        //邀請人沒填或邀請人沒有買過或邀請人是自己 就會把邀請地址給預設
        if(referral == address(0) || depositRecord[referral] == 0 || msg.sender == referral) {
            referral = defaultCommisonAddress;
        }

        //前端需要讓用戶Approve給合約 合約調用用戶的錢轉到合約中
        USDT.transferFrom(msg.sender, address(this), amount);

        //紀錄購買人地址 後續購買不再添加 避免重複
        if(depositRecord[msg.sender] == 0) {
            depositAddresses.push(msg.sender);
        }

        //紀錄購買人數量
        depositRecord[msg.sender] += amount;

        //紀錄邀請人資訊
        commisonSend(referral, amount);

        emit Deposit(msg.sender, referral, amount);
    }

    function commisonSend(address commisonAddress, uint depositAmount) internal {
        //邀請人數+1 
        commissionRecord[commisonAddress].totalInvitees++;
        //反佣 = 數量 * 20 / 100 佣金總量
        uint commision = depositAmount * commisonPercent / commisonBase;
        commissionRecord[commisonAddress].totalCommission += commision;
        //合約把錢轉給邀請人
        USDT.transfer(commisonAddress, commision);

        emit CommisonSend(commisonAddress, commision);
    }

    //修改佣金%數(預設20)
    function fixCommisonPercent(uint _commisonPercent) external onlyOwner {
        if(_commisonPercent >= 100)
            revert InvalidPercent();

        commisonPercent = _commisonPercent;
    }

    //項目方取所有的錢
    function withdrawFunds() external onlyOwner {
        uint balance = USDT.balanceOf(address(this));
        if(balance == 0)
            revert ZeroBalance();

        USDT.transfer(owner, balance);
    }

}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);

    // ======================================================
    //                        OPTIONAL                       
    // ======================================================
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "invalid address");
        require(_newOwner != owner, "same address");
        owner = _newOwner;
    }
}