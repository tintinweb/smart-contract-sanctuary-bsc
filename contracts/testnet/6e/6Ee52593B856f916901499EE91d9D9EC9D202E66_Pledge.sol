/**
 *Submitted for verification at BscScan.com on 2022-11-18
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.17;

/**
 * 安全数学
 */
library SafeMath {
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + (a % b));
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
}

/**
 * ERC20标准接口
 */

library TransferHelper {
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FAILED"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper: TRANSFER_FROM_FAILED"
        );
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        // 空字符串hash值
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        //内联编译（inline assembly）语言，是用一种非常底层的方式来访问EVM
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
}

contract Pledge {
    using SafeMath for uint256;

    address private owner; //管理员地址

    mapping(address => order[]) private _profitOrder; //质押列表

    mapping(address => order[]) private _financialOrder; //质押列表

    //质押时间变量
    uint256 private _profitDay = 10;
    //理财时间变量
    uint256 private _financialDay = 5;
    //质押利润率
    uint256 private _profitRate = 100;
    //理财利润率
    uint256 private _financialRate = 50;
    //质押利润衰减
    uint256 private _profitDecay = 90;
    //理财每天单数
    uint256 private _financialDayNum = 3;

    mapping(address => uint256) private _userPledgeTotal; //用户质押总表

    mapping(address => uint256) private _userFinancialTotal; //用户理财总表

    //理财订单日统计
    mapping(uint256 => uint256) private _financialDayCount; //理财订单日统计

    //定长数组10 用户利润
    uint256[10] private _userProfitRate = [10, 6, 5, 4, 3, 2, 1, 1, 1, 1];

    //二维mapping用户烧伤表
    mapping(address => mapping(address => uint256)) private _userBurn;

    mapping(address => mapping(address => uint256)) private _userBurnLast;

    //二位数组10个用户的烧伤表
    mapping(address => mapping(address => uint256[10])) private _userTeamBurn;

    mapping(address => mapping(address => uint256[10]))
        private _userTeamBurnLast;

    //用户星级
    mapping(address => uint8) private _userStar;
    //用户星级奖励
    mapping(address => uint256) private _userStarReward;
    //用户推荐奖励
    mapping(address => uint256) private _userRecommendReward;

    uint256 public _totalPledge; //总质押

    uint256 public _totalFinancial; //总理财

    uint256 private _minPledgeAmount = 10000000; //单笔最小质押额度

    uint256 private _minFinancialAmount = 10000000; //单笔最小理财额度

    uint256 private _maxFinancialAmount = 1000000000; //单笔最大理财额度

    mapping(address => address) public _parents; // 记录上级  我的地址 => 我的上级地址

    mapping(address => address[]) private _inviteRecords; //直推用户

    address private _firstAddress = 0x1aBF9A2E66906F13ff2830bc18478405abC68eE0; //创世地址

    uint256 private _totalAddress; //总地址

    address private _token = 0x5b9Ae21Ba7fe45E5440Ec9e85F92BCb47EE69E31; //TOKEN地址

    //市场地址
    address private _marketAddress = 0x29224fC97BcB2Df0ceCB56BC1E7b579708fFa3ea;
    //市场比率
    uint256 private _marketRate = 15;
    //技术地址
    address private _technologyAddress =
        0x43BCc53C9C6F034Cf6F3d3E736e0230133C626D4;
    //技术比率
    uint256 private _technologyRate = 5;

    //质押结构体
    struct order {
        uint256 index;
        uint256 num;
        uint256 lockTime;
        uint256 unLockTime;
        uint256 takeTime;
    }

    //添加锁仓到我的锁仓列表
    function lockProfit(uint256 num) public payable returns (bool) {
        require(address(msg.sender) == address(tx.origin), "no contract"); //确定是否合约

        require(num >= _minPledgeAmount, "num is too small");

        require(num % _minPledgeAmount == 0, "num is not multiple of 100");
        //转账
        TransferHelper.safeTransferFrom(
            address(_token),
            msg.sender,
            address(this),
            num
        );
        //新增持仓到订单列表
        _profitOrder[msg.sender].push(
            order({
                index: _profitOrder[msg.sender].length,
                num: num,
                lockTime: block.timestamp,
                unLockTime: block.timestamp + _profitDay * 1 minutes,
                takeTime: 0
            })
        );
        //计算奖金
        calculateBonus(num);
        //计算星级
        calculateStarBonus(num);

        //加入用户持仓统计
        _userPledgeTotal[msg.sender] = _userPledgeTotal[msg.sender].safeAdd(
            num
        );
        //全局新增
        _totalPledge = _totalPledge.safeAdd(num);

        return (true);
    }

    //添加理财到我的理财列表
    function lockFinancial(uint256 num) public payable returns (bool) {
        require(address(msg.sender) == address(tx.origin), "no contract"); //确定是否合约

        //每天15点之后才能购买
        require(
            block.timestamp >= (block.timestamp / 1 days) * 1 days + 15 hours,
            "not time"
        );

        //每天限购3单
        require(
            _financialDayCount[(block.timestamp / 1 days) * 1 days] <
                _financialDayNum,
            "not num"
        );

        require(num >= _minFinancialAmount, "num is too small");

        require(num % _minFinancialAmount == 0, "num is not multiple of 100");

        require(num <= _maxFinancialAmount, "num is too big");

        //转账
        TransferHelper.safeTransferFrom(
            address(_token),
            msg.sender,
            address(this),
            num
        );
        //新增持仓到订单列表
        _financialOrder[msg.sender].push(
            order({
                index: _financialOrder[msg.sender].length,
                num: num,
                lockTime: block.timestamp,
                unLockTime: block.timestamp + _financialDay * 1 minutes,
                takeTime: 0
            })
        );

        //加入用户持仓统计
        _userFinancialTotal[msg.sender] = _userFinancialTotal[msg.sender]
            .safeAdd(num);
        //全局新增
        _totalFinancial = _totalFinancial.safeAdd(num);

        return (true);
    }

    //发送奖金

    function send(uint256 num) private {
        //发送给持有者减去技术费和市场费
        TransferHelper.safeTransfer(
            address(_token),
            msg.sender,
            num.safeSub(num.safeMul(_technologyRate).safeDiv(100)).safeSub(
                num.safeMul(_marketRate).safeDiv(100)
            )
        );
        //发送给市场
        TransferHelper.safeTransfer(
            address(_token),
            _marketAddress,
            num.safeMul(_marketRate).safeDiv(100)
        );
        //发送给技术
        TransferHelper.safeTransfer(
            address(_token),
            _technologyAddress,
            num.safeMul(_technologyRate).safeDiv(100)
        );
    }

    //解除质押  1 质押 2 理财
    function unLock(uint256 index, uint256 types)
        public
        payable
        returns (bool)
    {
        require(address(msg.sender) == address(tx.origin), "no contract"); //确定是否合约

        if (types == 1) {
            require(
                _profitOrder[msg.sender][index].unLockTime <= block.timestamp,
                "order is not unlock"
            );
            //减少用户持仓统计
            _userPledgeTotal[msg.sender] = _userPledgeTotal[msg.sender].safeSub(
                _profitOrder[msg.sender][index].num
            );
            //全局减少
            _totalPledge = _totalPledge.safeSub(
                _profitOrder[msg.sender][index].num
            );

            //删除订单
            delete _profitOrder[msg.sender][index];

            send(_profitOrder[msg.sender][index].num);

            return (true);
        } else if (types == 2) {
            require(
                _financialOrder[msg.sender][index].unLockTime <=
                    block.timestamp,
                "order is not unlock"
            );

            //减少用户持仓统计
            _userFinancialTotal[msg.sender] = _userFinancialTotal[msg.sender]
                .safeSub(_financialOrder[msg.sender][index].num);
            //全局减少
            _totalFinancial = _totalFinancial.safeSub(
                _financialOrder[msg.sender][index].num
            );

            //删除订单
            delete _financialOrder[msg.sender][index];

            send(_financialOrder[msg.sender][index].num);

            return (true);
        }

        return (false);
    }

    //把领取的利润复投进去  //查看收益 1利息收益 2 理财收益 3 奖金收益 4 星级收益

    function reLock(uint256 types) public payable returns (bool) {
        require(address(msg.sender) == address(tx.origin), "no contract"); //确定是否合约

        uint256 profit = 0;

        if (types == 1) {
            for (uint256 i = 0; i < _profitOrder[msg.sender].length; i++) {
                uint256 time = 0;
                //查看领取时间和当前时间的差值
                if (_profitOrder[msg.sender][i].takeTime == 0) {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].lockTime;
                } else {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].takeTime;
                }
                profit +=
                    (_profitOrder[msg.sender][i].num * time) /
                    365 /
                    86400;

                _profitOrder[msg.sender][i].takeTime = block.timestamp;
                //计算收益
            }
        } else if (types == 2) {
            for (uint256 i = 0; i < _financialOrder[msg.sender].length; i++) {
                uint256 time = 0;
                //查看领取时间和当前时间的差值
                if (_financialOrder[msg.sender][i].takeTime == 0) {
                    time =
                        block.timestamp -
                        _financialOrder[msg.sender][i].lockTime;
                } else {
                    time =
                        block.timestamp -
                        _financialOrder[msg.sender][i].takeTime;
                }
                profit +=
                    (_financialOrder[msg.sender][i].num * time) /
                    365 /
                    86400;
                _financialOrder[msg.sender][i].takeTime = block.timestamp;
                //计算收益
            }
        } else if (types == 3) {
            profit = _userRecommendReward[msg.sender];
            _userRecommendReward[msg.sender] = 0;
        } else if (types == 4) {
            profit = _userStarReward[msg.sender];
            _userStarReward[msg.sender] = 0;
        }

        //必须大于0
        require(profit > 0, "profit is zero");

        _profitOrder[msg.sender].push(
            order({
                index: _profitOrder[msg.sender].length,
                num: profit,
                lockTime: block.timestamp,
                unLockTime: block.timestamp + _profitDay * 1 minutes,
                takeTime: 0
            })
        );

        //私有方法 计算烧伤
        calculateBonus(profit);
        //计算星级
        calculateStarBonus(profit);
        //加入用户持仓统计
        _userPledgeTotal[msg.sender] = _userPledgeTotal[msg.sender].safeAdd(
            profit
        );

        _totalPledge = _totalPledge.safeAdd(profit);

        return (true);
    }

    //领取收益  //查看收益 1利息收益 2 理财收益 3 奖金收益 4 星级收益
    function take(uint256 types) public payable returns (bool) {
        require(address(msg.sender) == address(tx.origin), "no contract"); //确定是否合约
        //循环更新领取时间
        uint256 profit = 0;

        if (types == 1) {
            for (uint256 i = 0; i < _profitOrder[msg.sender].length; i++) {
                uint256 time = 0;
                //查看领取时间和当前时间的差值
                if (_profitOrder[msg.sender][i].takeTime == 0) {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].lockTime;
                } else {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].takeTime;
                }

                profit +=
                    (_profitOrder[msg.sender][i].num * time) /
                    365 /
                    86400;

                _profitOrder[msg.sender][i].takeTime = block.timestamp;

                //计算收益
            }
        } else if (types == 2) {
            for (uint256 i = 0; i < _profitOrder[msg.sender].length; i++) {
                uint256 time = 0;
                //查看领取时间和当前时间的差值
                if (_profitOrder[msg.sender][i].takeTime == 0) {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].lockTime;
                } else {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].takeTime;
                }

                profit +=
                    (_profitOrder[msg.sender][i].num * time) /
                    365 /
                    86400;

                _profitOrder[msg.sender][i].takeTime = block.timestamp;
            }
        } else if (types == 3) {
            profit = _userStarReward[msg.sender];
        } else if (types == 4) {
            profit = _userStarReward[msg.sender];
        }

        //发送奖金
        send(profit);

        return true;
    }

    //查看收益 1利息收益 2 理财收益 3 奖金收益 4 星级收益
    function viewProfit(uint256 types) public view returns (uint256) {
        require(address(msg.sender) == address(tx.origin), "no contract"); //确定是否合约

        uint256 profit = 0;

        if (types == 1) {
            for (uint256 i = 0; i < _profitOrder[msg.sender].length; i++) {
                uint256 time = 0;
                //查看领取时间和当前时间的差值

                if (_profitOrder[msg.sender][i].takeTime == 0) {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].lockTime;
                } else {
                    time =
                        block.timestamp -
                        _profitOrder[msg.sender][i].takeTime;
                }

                profit +=
                    (_profitOrder[msg.sender][i].num * time) /
                    365 /
                    86400;
                //计算收益
            }
        } else if (types == 2) {
            //理财收益

            for (uint256 i = 0; i < _financialOrder[msg.sender].length; i++) {
                uint256 time = 0;
                //查看领取时间和当前时间的差值

                if (_financialOrder[msg.sender][i].takeTime == 0) {
                    time =
                        block.timestamp -
                        _financialOrder[msg.sender][i].lockTime;
                } else {
                    time =
                        block.timestamp -
                        _financialOrder[msg.sender][i].takeTime;
                }

                profit +=
                    (_financialOrder[msg.sender][i].num * time) /
                    365 /
                    86400;
                //计算收益
            }
        } else if (types == 3) {
            //奖金收益

            profit = _userStarReward[msg.sender];
        } else if (types == 4) {
            //星级收益

            profit = _userStarReward[msg.sender];
        }

        return profit;
    }

    //绑定上级
    function addRecord(address parentAddress) public payable returns (bool) {
        require(parentAddress != address(0), "Invite: 0001"); // 不允许上级地址为0地址
        address myAddress = msg.sender; // 重新赋个值，没什么实际意义，单纯为了看着舒服
        require(parentAddress != myAddress, "Invite: 0002"); // 不允许自己的上级是自己
        // 验证要绑定的上级是否有上级，只有有上级的用户，才能被绑定为上级（_firstAddress除外）。如果没有此验证，那么就可以随意拿一个地址绑定成上级了
        require(
            _parents[parentAddress] != address(0) ||
                parentAddress == _firstAddress,
            "Invite: 0003"
        );
        // 判断是否已经绑定过上级
        if (_parents[myAddress] != address(0)) {
            // 已有上级，返回一个true
            return true;
        }
        // 记录邀请关系，parentAddress邀请了myAddress，给parentAddress对应的数组增加一个记录
        _inviteRecords[parentAddress].push(myAddress);
        // 记录我的上级
        _parents[myAddress] = parentAddress;
        // 统计数量
        _totalAddress++; // 总用户数+1\

        return true;
    }

    //获取邀请人的上级10级地址数组
    function getInviteParent(address inviteAddress)
        public
        view
        returns (address[10] memory)
    {
        address[10] memory parentAddress;
        address parent = _parents[inviteAddress];
        for (uint256 i = 0; i < 10; i++) {
            if (parent != address(0)) {
                parentAddress[i] = parent;
                parent = _parents[parent];
            } else {
                break;
            }
        }
        return parentAddress;
    }

    //计算奖金并发放
    function calculateBonus(uint256 amount) private {
        //计算奖金
        uint256 last = 0;
        uint256 total = 0;
        uint256 num = 0;

        address[10] memory parentAddress = getInviteParent(msg.sender);

        for (uint256 i = 0; i < 10; i++) {
            if (parentAddress[i] != address(0)) {
                if (i == 0) {
                    //最后持有大于当前持有,用最后持有减去当前持有得到余额量
                    if (
                        _userBurn[parentAddress[i]][msg.sender] >=
                        _userPledgeTotal[parentAddress[i]]
                    ) {
                        last =
                            _userBurn[parentAddress[i]][msg.sender] -
                            _userPledgeTotal[parentAddress[i]];
                    }
                    total = _userBurnLast[parentAddress[i]][msg.sender] + last;

                    if (total < amount) {
                        num = total;
                        _userBurnLast[parentAddress[i]][msg.sender] = 0;
                    } else {
                        num = amount;
                        _userBurnLast[parentAddress[i]][msg.sender] =
                            total -
                            amount;
                    }

                    //更新
                    _userBurn[parentAddress[i]][msg.sender] = _userPledgeTotal[
                        parentAddress[i]
                    ];

                    //记录奖励
                } else {
                    address[] memory inviteUser = _inviteRecords[
                        parentAddress[i]
                    ];

                    //对邀请人的持仓量进行排序
                    for (uint256 k = 0; k < inviteUser.length - 1; k++) {
                        if (
                            _userPledgeTotal[inviteUser[k]] <
                            _userPledgeTotal[inviteUser[k + 1]]
                        ) {
                            address temp = inviteUser[k];
                            inviteUser[k] = inviteUser[k + 1];
                            inviteUser[k + 1] = temp;
                        }
                    }

                    if (
                        _userTeamBurn[parentAddress[i]][msg.sender][i] >=
                        _userPledgeTotal[parentAddress[i]]
                    ) {
                        last =
                            _userTeamBurn[parentAddress[i]][msg.sender][i] -
                            _userPledgeTotal[parentAddress[i]];
                    }
                    total = _userPledgeTotal[parentAddress[i]] + last;

                    if (total < amount) {
                        num = total;
                        _userTeamBurnLast[parentAddress[i]][msg.sender][i] = 0;
                    } else {
                        num = amount;
                        _userTeamBurnLast[parentAddress[i]][msg.sender][i] =
                            total -
                            amount;
                    }

                    _userTeamBurn[parentAddress[i]][msg.sender][
                        i
                    ] = _userPledgeTotal[parentAddress[i]];
                } //计算收益
            }

            _userRecommendReward[parentAddress[i]] += num;

            //计算星级奖励并发放
        }
    }

    function calculateStarBonus(uint256 amount) private {
        //无限循环查找上级
        address parent = _parents[msg.sender];
        uint256 level = 0;

        while (parent != address(0) && level <= 5) {
            if (_userStar[parent] > 1 && _userStar[parent] > level) {
                _userStarReward[parent] +=
                    (amount * (_userStar[parent] - level)) /
                    100;
            }
            level = _userStar[parent];
            //查找上级
            parent = _parents[parent];
        }
    }

    //分页获取我的持仓列表
    function getMyPledgeListByPage(uint256 page, uint256 size)
        public
        view
        returns (order[] memory)
    {
        uint256 start = page * size;
        uint256 end = start + size;
        if (end > _profitOrder[msg.sender].length) {
            end = _profitOrder[msg.sender].length;
        }

        order[] memory list = new order[](end - start);

        for (uint256 i = start; i < end; i++) {
            list[i - start] = _profitOrder[msg.sender][i];
        }
        return list;
    }

    //分页获取我的理财列表
    function getMyFinanceListByPage(uint256 page, uint256 size)
        public
        view
        returns (order[] memory)
    {
        uint256 start = page * size;
        uint256 end = start + size;
        if (end > _financialOrder[msg.sender].length) {
            end = _financialOrder[msg.sender].length;
        }

        order[] memory list = new order[](end - start);

        for (uint256 i = start; i < end; i++) {
            list[i - start] = _financialOrder[msg.sender][i];
        }
        return list;
    }

    //分页获取我的邀请列表(一个邀请人账户和质押额度的数组)和总人数
    function getMyInviteListByPage(uint256 page, uint256 size)
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256
        )
    {
        uint256 start = page * size;
        uint256 end = start + size;
        if (end > _inviteRecords[msg.sender].length) {
            end = _inviteRecords[msg.sender].length;
        }

        address[] memory list = new address[](end - start);
        uint256[] memory amountList = new uint256[](end - start);

        for (uint256 i = start; i < end; i++) {
            list[i - start] = _inviteRecords[msg.sender][i];
            amountList[i - start] = _userPledgeTotal[
                _inviteRecords[msg.sender][i]
            ];
        }
        return (list, amountList, _inviteRecords[msg.sender].length);
    }
}