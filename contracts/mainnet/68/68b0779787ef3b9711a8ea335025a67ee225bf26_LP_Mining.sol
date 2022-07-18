// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

interface router {
    function getAmounsOut(uint256 amount_, address[] memory path) external view returns (uint256[]memory);
}

contract LP_Mining is Ownable {
    uint public pairAmount;
    uint private constant acc = 1e10;
    address public DBG;
    uint public totalPrice;
    uint public totalClaimPrice;
    uint public totalTVL;
    uint public totalClaimDBG;

    event Stake(address indexed sender_, uint indexed poolID_, uint indexed cycle_, uint amount_);
    event Claim(address indexed sender_, uint indexed poolID_, uint indexed amount_);
    event UnStake(address indexed sender_, uint indexed poolID_, uint indexed cycle_);

    struct PoolInfo {
        string name;
        address LP;
        bool status;
        uint totalPower;
        uint rate;
        uint daliyOut;
        uint debt;
        uint lastTime;
        uint[] coe;
        uint[] cycle;
        string logo;
        address outToken;
        uint totalClimed;
        address mainToken;
    }

    mapping(uint => PoolInfo)public poolInfo;


    function setDBG(address addr_) public onlyOwner {
        DBG = addr_;
    }

    struct UserPool {
        uint stakeAmount;
        uint power;
        uint cycle;
        uint stakeTime;
        uint endTime;
        uint debt;
    }

    struct UserInfo {
        uint totalPower;
        uint claimed;
        uint toClaim;
        mapping(uint => UserPool) userPool;
    }

    mapping(address => mapping(uint => UserInfo))public userInfo;

    function newPool(string memory name_,
        address Token_,
        bool status,
        uint daliyOut_,
        uint[] calldata coe_,
        uint[] calldata cycle_,
        string memory logo_,
        address out_,
        address mainToken_) public onlyOwner {
        poolInfo[pairAmount].LP = Token_;
        poolInfo[pairAmount].name = name_;
        poolInfo[pairAmount].daliyOut = daliyOut_;
        poolInfo[pairAmount].rate = daliyOut_ / 1 days;
        poolInfo[pairAmount].status = status;
        poolInfo[pairAmount].coe = coe_;
        poolInfo[pairAmount].cycle = cycle_;
        poolInfo[pairAmount].logo = logo_;
        poolInfo[pairAmount].outToken = out_;
        poolInfo[pairAmount].mainToken = mainToken_;
        pairAmount ++;
    }


    function editPool(uint ID,
        string memory name_,
        address Token_,
        bool status,
        uint daliyOut_,
        uint[] calldata coe_,
        uint[] calldata cycle_,
        address out_,
        address mainToken_) public onlyOwner {
        poolInfo[ID].LP = Token_;
        poolInfo[ID].name = name_;
        poolInfo[ID].daliyOut = daliyOut_;
        poolInfo[ID].rate = daliyOut_ / 1 days;
        poolInfo[ID].status = status;
        poolInfo[ID].coe = coe_;
        poolInfo[ID].cycle = cycle_;
        poolInfo[ID].outToken = out_;
        poolInfo[ID].mainToken = mainToken_;
    }

    function changeLogo(uint ID_, string memory logo_) public onlyOwner {
        require(poolInfo[ID_].LP != address(0), 'wrong ID');
        poolInfo[ID_].logo = logo_;
    }

    function checkEndTime(address addr_, uint ID_, uint cycle_) external view returns (uint){
        return userInfo[addr_][ID_].userPool[cycle_].endTime;
    }

    function checkAllLP() public view returns (string[] memory){
        string[] memory a = new string[](pairAmount);
        for (uint i = 0; i < pairAmount; i ++) {
            a[i] = poolInfo[i].name;
        }
        return a;
    }

    // function getPrice(address addr_)public view returns(uint){
    //     uint deci = IERC20(addr_).decimals();
    //     address[] memory path = new address[](2);
    //     path[0] = addr_;
    //     path[1] = U;
    //     uint[] memory p = R.getAmounsOut(10**deci,path);
    //     return p[1];
    // }

    function setPoolStatus(uint ID_, bool status_) external onlyOwner {
        require(poolInfo[ID_].LP != address(0), 'wrong ID');
        poolInfo[ID_].status = status_;
    }

    function checkCycle(uint ID_) public view returns (uint[] memory, uint[] memory){
        return (poolInfo[ID_].cycle, poolInfo[ID_].coe);
    }

    function coutingPower(uint ID_, uint cycle_, uint amount_) public view returns (uint){
        return poolInfo[ID_].coe[cycle_] * amount_ / 10;
    }

    function coutingDebt(uint ID_) internal view returns (uint){
        PoolInfo storage aa = poolInfo[ID_];
        return aa.totalPower > 0 ? aa.rate * (block.timestamp - aa.lastTime) * acc / aa.totalPower + aa.debt : 0 + aa.debt;
    }

    function coutingeClaim(address addr_, uint ID_, uint cycle_) public view returns (uint){
        UserPool storage aa = userInfo[addr_][ID_].userPool[cycle_];
        uint rew;
        if (aa.stakeAmount == 0) {
            return 0;
        }

        uint tempDebt = coutingDebt(ID_);
        rew = (tempDebt - aa.debt) * aa.stakeAmount / acc;
        return rew;

    }

    function coutingAll(address addr_, uint ID_) public view returns (uint){
        uint rew;
        for (uint i = 0; i < poolInfo[ID_].cycle.length; i++) {
            if (userInfo[addr_][ID_].userPool[i].stakeAmount > 0) {
                rew += coutingeClaim(addr_, ID_, i);
            }
        }
        return rew;
    }

    function claimAll(uint ID_) external {
        uint rew;
        uint tempDebt = coutingDebt(ID_);

        for (uint i = 0; i < poolInfo[ID_].cycle.length; i++) {
            if (userInfo[msg.sender][ID_].userPool[i].stakeAmount > 0) {
                rew += coutingeClaim(msg.sender, ID_, i);
                userInfo[msg.sender][ID_].userPool[i].debt = tempDebt;
            }
        }
        require(rew > 0, 'no rewared');
        IERC20(poolInfo[ID_].outToken).transfer(msg.sender, rew);
        if (poolInfo[ID_].outToken == DBG) {
            totalClaimDBG += rew;
        }
        userInfo[msg.sender][ID_].claimed += rew;
        // uint deci = IERC20(poolInfo[ID_].mainToken).decimals();
        //        uint p = getPrice(poolInfo[ID_].mainToken);
        //        uint value = p * rew / 10**deci;
        //        totalClaimPrice += value;
        poolInfo[ID_].totalClimed += rew;
        emit Claim(msg.sender, ID_, rew);
    }


    function stake(uint ID_, uint cycle_, uint amount_) external {
        require(poolInfo[ID_].status, 'not open');
        require(poolInfo[ID_].LP != address(0), 'wrong ID');
        require(cycle_ < poolInfo[ID_].cycle.length, 'wrong cycle');
        PoolInfo storage cc = poolInfo[ID_];
        IERC20(cc.LP).transferFrom(msg.sender, address(this), amount_);
        uint tempPow = coutingPower(ID_, cycle_, amount_);
        userInfo[msg.sender][ID_].userPool[cycle_].stakeAmount += amount_;
        userInfo[msg.sender][ID_].userPool[cycle_].power += tempPow;
        userInfo[msg.sender][ID_].userPool[cycle_].stakeTime = block.timestamp;
        userInfo[msg.sender][ID_].userPool[cycle_].cycle = cc.cycle[cycle_];
        userInfo[msg.sender][ID_].userPool[cycle_].endTime = block.timestamp + cc.cycle[cycle_];
        // uint deci = IERC20(cc.mainToken).decimals();
        // uint p = getPrice(cc.mainToken);
        // uint value = p * amount_ / 10**deci;
        uint tempDebt = coutingDebt(ID_);
        poolInfo[ID_].debt = tempDebt;
        // totalPrice += value;
        poolInfo[ID_].totalPower += tempPow;
        poolInfo[ID_].lastTime = block.timestamp;
        userInfo[msg.sender][ID_].totalPower += tempPow;
        userInfo[msg.sender][ID_].userPool[cycle_].debt = tempDebt;
        totalTVL += amount_;
        emit Stake(msg.sender, ID_, cc.cycle[cycle_], amount_);

    }

    function unStake(uint ID_, uint cycle_) external {
        require(poolInfo[ID_].status, 'not open');
        require(poolInfo[ID_].LP != address(0), 'wrong ID');
        require(cycle_ < poolInfo[ID_].cycle.length, 'wrong cycle');
        require(userInfo[msg.sender][ID_].userPool[cycle_].stakeAmount > 0, 'no amount');
        require(block.timestamp > userInfo[msg.sender][ID_].userPool[cycle_].endTime, 'too early');
        PoolInfo storage cc = poolInfo[ID_];
        UserPool storage aa = userInfo[msg.sender][ID_].userPool[cycle_];
        // uint deci = IERC20(cc.mainToken).decimals();
        // uint p = getPrice(cc.mainToken);
        uint rew = coutingeClaim(msg.sender, ID_, cycle_);
        IERC20(cc.outToken).transfer(msg.sender, rew);
        userInfo[msg.sender][ID_].claimed += rew;
        poolInfo[ID_].totalClimed += rew;
        IERC20(cc.LP).transfer(msg.sender, aa.stakeAmount);
        uint tempDebt = coutingDebt(ID_);
        totalTVL -= aa.stakeAmount;
        // uint value = p * aa.stakeAmount / 10**deci;
        // totalPrice -= value;
        // value = p * rew / 10**deci;
        // totalClaimPrice += value;
        poolInfo[ID_].totalPower -= aa.power;
        poolInfo[ID_].debt = tempDebt;
        poolInfo[ID_].lastTime = block.timestamp;
        userInfo[msg.sender][ID_].totalPower -= aa.power;
        userInfo[msg.sender][ID_].userPool[cycle_] = UserPool({
        stakeAmount : 0,
        power : 0,
        stakeTime : 0,
        cycle : 0,
        endTime : 0,
        debt : 0
        });
        emit UnStake(msg.sender, ID_, cycle_);
    }

    function safePull(address token_, address wallet, uint amount_) public onlyOwner {
        IERC20(token_).transfer(wallet, amount_);
    }


}