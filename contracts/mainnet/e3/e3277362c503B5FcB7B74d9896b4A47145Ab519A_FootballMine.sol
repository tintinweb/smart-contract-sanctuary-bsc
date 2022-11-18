/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

//SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

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

interface IRouter {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract ReentrancyGuard {
    // https://solidity.readthedocs.io/en/latest/control-structures.html?highlight=zero-state#scoping-and-declarations
    // zero-state of _ENTERED_ is false
    bool private _ENTERED_;

    modifier preventReentrant() {
        require(!_ENTERED_, "REENTRANT");
        _ENTERED_ = true;
        _;
        _ENTERED_ = false;
    }
}

contract FootballMine is ReentrancyGuard {
    struct UserInfo {
        uint balanceOf;
        uint startStakedTime;
        uint lastClaimedTime;
        uint claimedCount;
        uint claimedAmount;
        uint subordinatesL1;
        uint subordinatesL2;
        uint subordinatesL3;
        address inviter;
        mapping(address => bool) isSubordinateExist;
    }

    uint public totalSupply = 4500000*(1e18);
    uint public charge = 10 * (1e18); //10 usdt
    uint public baseAmount = 1000 * (1e18);
    address public owner;
    address public token;
    address public firstAddress = 0xe83F2B2851783C5FDF098Bd14A7D447f30a4129a;
    address public usdt = 0x55d398326f99059fF775485246999027B3197955;
    address public router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint public count; //总参与人数
    uint public startTime; //第一个开始挖矿时间
    uint public totalStakedUsdt;

    mapping(address => UserInfo) public userInfo;
    mapping(address => bool) public isExist;

    constructor(address _token) {
        owner = msg.sender;
        token = _token;
        IBEP20(usdt).approve(router, ~uint256(0));
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function setOwner(address newOwenr) external onlyOwner {
        owner = newOwenr;
    }

    function setFirstAddress(address _firstAddress) external onlyOwner {
        firstAddress = _firstAddress;
    }

    function buy(address inviter) external {
        require(inviter != msg.sender, "inviter can not be self");
        require(inviter == firstAddress || userInfo[inviter].startStakedTime > 0, 'invalid inviter');
        require(userInfo[msg.sender].startStakedTime == 0 
            || (userInfo[msg.sender].startStakedTime != 0 && userInfo[msg.sender].claimedCount%10 == 0), 'already staked');
		require(IBEP20(usdt).allowance(msg.sender, address(this)) >= charge, 'allowance not enough');
		require(IBEP20(usdt).balanceOf(msg.sender) >= charge, 'balance not enough');
        
        if (count == 0) {
            startTime = block.timestamp;
        }


        IBEP20(usdt).transferFrom(msg.sender, address(this), charge);
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = token;
        IRouter(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(
            charge, 
            0, 
            path, 
            address(this), 
            block.timestamp
        );

        totalStakedUsdt += charge;
        if (!isExist[msg.sender]) {
            isExist[msg.sender] = true;
            count++;
        }
        //更新个人数据
        if (userInfo[msg.sender].inviter == address(0)) {
            userInfo[msg.sender].inviter = inviter;
        }
        userInfo[msg.sender].startStakedTime = block.timestamp;
        userInfo[msg.sender].balanceOf = 10*(1e18);
        //更新上级
        address inviterL1 = userInfo[msg.sender].inviter;
        UserInfo storage uiOfL1 = userInfo[inviterL1];
        if (!uiOfL1.isSubordinateExist[msg.sender]) {
            uiOfL1.isSubordinateExist[msg.sender] = true;
            uiOfL1.subordinatesL1++;
        }
        address inviterL2 = userInfo[inviterL1].inviter;
        if (inviterL2 != address(0)) {
            UserInfo storage uiOfL2 = userInfo[inviterL2];
            if (!uiOfL2.isSubordinateExist[msg.sender]) {
                uiOfL2.isSubordinateExist[msg.sender] = true;
                uiOfL2.subordinatesL2++;
            }
            address inviterL3 = userInfo[inviterL2].inviter;
            if (inviterL3 != address(0)) {
                UserInfo storage uiOfL3 = userInfo[inviterL3];
                if (!uiOfL3.isSubordinateExist[msg.sender]) {
                    uiOfL3.isSubordinateExist[msg.sender] = true;
                    uiOfL3.subordinatesL3++;
                }
            }
        }
        
    }

    function getPendingRewards(address account) public view returns (uint) {
        UserInfo storage ui = userInfo[account];
        if (ui.startStakedTime == 0
            || block.timestamp - ui.startStakedTime < 1 days
            || block.timestamp - ui.lastClaimedTime < 1 days
            || ui.balanceOf == 0
        ) {
            return 0;
        }

        uint _baseAmount = getBaseAmount();
        uint gain;

        uint subordinatesL1 = ui.subordinatesL1;
        uint subordinatesL2 = ui.subordinatesL2;
        uint subordinatesL3 = ui.subordinatesL3;
        if (subordinatesL1 >= 2) {  // 5 3 1
            gain = subordinatesL1 * _baseAmount / 20 
                + subordinatesL2 * _baseAmount *3 / 100
                + subordinatesL3 * _baseAmount / 100;
        }
        return _baseAmount + gain;
    }

    function estimateRewards(address account) public view returns (uint) {
        UserInfo storage ui = userInfo[account];

        uint _baseAmount = getBaseAmount();
        uint gain;

        uint subordinatesL1 = ui.subordinatesL1;
        uint subordinatesL2 = ui.subordinatesL2;
        uint subordinatesL3 = ui.subordinatesL3;
        if (subordinatesL1 >= 2) {  // 5 3 1
            gain = subordinatesL1 * _baseAmount / 20 
                + subordinatesL2 * _baseAmount *3 / 100
                + subordinatesL3 * _baseAmount / 100;
        }
        return _baseAmount + gain;
    }

    function getBaseAmount() public view returns (uint) {
        if (startTime == 0) {
            return baseAmount;
        }
        uint _baseAmount = baseAmount;
        uint elapsedTime = block.timestamp - startTime;
        uint i = elapsedTime / 10 days;
        if (i >= 1) {
            for (; i > 0; i--) {
                _baseAmount = _baseAmount/2;
            }
        }
        return _baseAmount;
    }

    function claim() external {
        uint rewards = getPendingRewards(msg.sender);
        require(rewards > 0, "can not claim");
        require(IBEP20(token).balanceOf(address(this)) >= rewards, "unsufficient balances");
        IBEP20(token).transfer(msg.sender, rewards);

        UserInfo storage ui = userInfo[msg.sender];
        ui.claimedAmount += rewards;
        ui.claimedCount++;
        ui.balanceOf -= 1*(1e18);
        ui.lastClaimedTime = block.timestamp;
    }

    function getcirculatingSupply() external view returns (uint) {
        address dead = 0x000000000000000000000000000000000000dEaD;
        uint amountOfDead = IBEP20(token).balanceOf(dead);
        uint amountOfZero = IBEP20(token).balanceOf(address(0));
        uint amountOfThis = IBEP20(token).balanceOf(address(this));
        return 10000000*(1e18) - amountOfDead - amountOfZero - amountOfThis;
    }

    function exactTokensOfThis(uint amount) external onlyOwner {
        require(IBEP20(token).balanceOf(address(this)) >= amount, "unsufficient tokens");
        IBEP20(token).transfer(msg.sender, amount);
    }

    function viewAountOfThis() external view returns (uint) {
        return IBEP20(token).balanceOf(address(this));
    }
}