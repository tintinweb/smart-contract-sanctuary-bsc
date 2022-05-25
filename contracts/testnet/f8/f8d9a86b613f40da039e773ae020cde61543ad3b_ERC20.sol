/**
 *Submitted for verification at BscScan.com on 2022-05-25
*/

// SPDX-License-Identifier: SimPL-2.0
pragma solidity ^0.8.0;

interface Token {
    // 添加流动池
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    // 代币兑换
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    // 代币授权
    function approve(address spender, uint256 amount) external returns (bool);

    // 交易
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    // 余额
    function balanceOf(address account) external view returns (uint256);

    // 获取币价
    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

contract ERC20 {
    // 合约拥有者
    address public founder = address(0);
    // 资产
    mapping(address => uint256) private _balances;
    // 委托交易数量
    mapping(address => mapping(address => uint256)) public _allowances;
    // 对应地址上级
    mapping(address => address) private leader;
    // 对应地址直推数量
    mapping(address => uint256) private subordinate;
    // 资产总数
    uint256 public totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 买地址
    mapping(address => bool) public buyAddress;
    // 卖地址
    mapping(address => bool) public sellAddress;
    // 买滑点
    uint8 public buySlipPoint = 10;
    // 卖滑点
    uint8 public sellSlipPoint = 10;
    // 交易对地址
    address public pairAddress;
    // USDT信息
    address private usdtAddress = 0x55d398326f99059fF775485246999027B3197955;
    uint8 private usdtDecimals = 6;
    // 官方代币信息
    address public pancakeAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // ptec代币信息
    address public ptecAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // 已销毁数量
    uint256 public destroyNum;
    // PTE价格
    uint256 public pteUsdt;
    // 基金会地址
    address public foundationAddress;
    // 今日分红数量
    uint256 public todayBonusNum;
    // 白名单
    mapping(address => bool) public whiteList;
    // 总销毁数量
    uint256 public totalDestruction = 10500 * 10**decimals;
    // 截止销毁数量
    uint256 public endDestruction = 2100 * 10**decimals;
    // 流动性挖矿地址
    mapping(address => bool) private mobilityMappingAddress;
    address[] private mobilityArrayAddress;
    // 普通转账手续费
    uint8 public serviceCharge = 2;
    // PTE最小数量
    uint8 public pteMax = 20;
    // 交易最大比例
    uint8 public transferMaxRatio = 90;
    // 地址分红数
    mapping(address => uint256) airdropQuantity;

    // 交易事件
    event Transfer(address indexed from, address indexed to, uint256 value);
    // 委托交易事件
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // 初始化
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_
    ) {
        founder = msg.sender;
        name = name_;
        symbol = symbol_;
        _mint(address(this), totalSupply_ * 10**decimals);
    }

    // 调其他合约的方法
    function approveContract(
        address _address,
        address spender,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == founder);
        Token token = Token(_address);
        token.approve(spender, amount);
        return true;
    }

    function transferContract(
        address _address,
        address spender,
        uint256 amount
    ) external returns (bool) {
        require(msg.sender == founder);
        Token token = Token(_address);
        token.transfer(spender, amount);
        return true;
    }

    // 设置合约拥有者
    function setFounder(address _address) public returns (bool) {
        require(msg.sender == founder);
        founder = _address;
        return true;
    }

    // 设置买地址
    function setBuyAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        buyAddress[_address] = true;
        return true;
    }

    // 设置卖地址
    function setSellAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        sellAddress[_address] = true;
        return true;
    }

    // 设置买滑点
    function setBuySlipPoint(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        buySlipPoint = _number;
        return true;
    }

    // 设置卖滑点
    function setSellSlipPoint(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        sellSlipPoint = _number;
        return true;
    }

    // 设置地址对
    function setPairAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        pairAddress = _address;
        return true;
    }

    // 设置今日分红数量
    function setTodayBonusNum(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        todayBonusNum = _number;
        return true;
    }

    // 设置PTE价格
    function setPteUsdt(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        pteUsdt = _number;
        return true;
    }

    // 设置基金会地址
    function setFoundationAddress(address _address) public returns (bool) {
        require(msg.sender == founder);
        foundationAddress = _address;
        return true;
    }

    // 设置白名单地址
    function setWhiteList(address _address) public returns (bool) {
        require(msg.sender == founder);
        whiteList[_address] = true;
        return true;
    }

    // 设置总销毁数量
    function setTotalDestruction(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        totalDestruction = _number * decimals;
        return true;
    }

    // 设置截止销毁数量
    function setEndDestruction(uint256 _number) public returns (bool) {
        require(msg.sender == founder);
        endDestruction = _number * decimals;
        return true;
    }

    // 获取流动性挖矿地址数量
    function getMobilityArrayAddressLength() public view returns (uint256) {
        return mobilityArrayAddress.length;
    }

    // 获取流动性挖矿地址
    function getMobilityArrayAddress(uint256 i) public view returns (address) {
        return mobilityArrayAddress[i];
    }

    // 设置普通转账手续费
    function setServiceCharge(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        serviceCharge = _number;
        return true;
    }

    // 设置PTE最小数量
    function setPteMax(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        pteMax = _number;
        return true;
    }

    // 设置PTE转账最大比例
    function setTransferMaxRatio(uint8 _number) public returns (bool) {
        require(msg.sender == founder);
        transferMaxRatio = _number;
        return true;
    }

    // 获取地址余额
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 转账
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    // 合约空投
    function contractAirdrop(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == founder);
        whiteList[recipient] = true;
        uint256 senderBalance = _balances[address(this)];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[address(this)] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(address(this), recipient, amount);
        return true;
    }

    // 合约转账
    function contractTransfer(address recipient, uint256 amount)
        public
        returns (bool)
    {
        require(msg.sender == founder);
        uint256 senderBalance = _balances[address(this)];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[address(this)] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(address(this), recipient, amount);
        return true;
    }

    // 获取指定地址的委托交易剩余数量
    function allowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    // 设置委托交易数量
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    // 委托交易
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, msg.sender, currentAllowance - amount);
        }

        return true;
    }

    // 增加委托交易剩余数量
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + addedValue
        );
        return true;
    }

    // 减少委托交易剩余数量
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(msg.sender, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    // 获取上级地址
    function get_leader(address account) public view returns (address) {
        return _leader(account);
    }

    // 获取直推数量
    function get_subordinate(address account) public view returns (uint256) {
        return _subordinate(account);
    }

    // 交易方法
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        if (!whiteList[sender]) {
            uint256 now_balance = _balances[sender];
            if (amount > (now_balance * transferMaxRatio) / 100) {
                require(false, "ERC20: too many transactions");
            }
        }

        if (totalDestruction - endDestruction > destroyNum) {
            uint256 profit_amount = 0;
            address push_address;
            if (buyAddress[sender]) {
                // 判断为用户购买
                if (!whiteList[recipient]) {
                    // 获取USDT流动池数量
                    uint256 usdtMobilityNum = Token(usdtAddress).balanceOf(
                        pairAddress
                    );
                    // 计算滑点数量
                    uint8 slip_point = buySlipPoint;
                    if (usdtMobilityNum >= 500 * 10**(4 + 6)) {
                        slip_point = 5;
                    } else if (usdtMobilityNum >= 200 * 10**(4 + 6)) {
                        slip_point = 7;
                    } else if (usdtMobilityNum >= 100 * 10**(4 + 6)) {
                        slip_point = 8;
                    } else if (usdtMobilityNum >= 50 * 10**(4 + 6)) {
                        slip_point = 9;
                    }
                    // 计算用户应得数量
                    amount = (amount * (100 - slip_point)) / 100;
                    // 销毁数量
                    profit_amount = (amount * slip_point) / 100;
                    push_address = recipient;
                }
            } else if (sellAddress[recipient]) {
                // 判断为用户卖出
                if (!whiteList[sender]) {
                    if (!mobilityMappingAddress[sender]) {
                        mobilityArrayAddress.push(sender);
                        mobilityMappingAddress[sender] = true;
                    }
                    // 获取PTE价格
                    address[] memory path = new address[](2);
                    path[0] = address(this);
                    path[1] = usdtAddress;
                    uint256[] memory getAmountsOut = Token(pancakeAddress)
                        .getAmountsOut(10**decimals, path);

                    uint256 pteNowUsdt = getAmountsOut[1];
                    uint8 slip_point = sellSlipPoint;
                    if (pteNowUsdt < pteUsdt) {
                        uint256 difference = pteUsdt - pteNowUsdt;
                        uint256 ratio = (difference / pteUsdt) * 100;
                        if (ratio > 15) {
                            slip_point = 30;
                        } else if (ratio > 10) {
                            slip_point = 25;
                        } else if (ratio > 5) {
                            slip_point = 20;
                        } else if (ratio > 0) {
                            slip_point = 15;
                        }
                    }
                    // 计算用户应得数量
                    amount = (amount * (100 - slip_point)) / 100;
                    // 销毁数量
                    profit_amount = (amount * slip_point) / 100;
                    push_address = sender;
                }
            } else {
                // 计算用户应得数量
                amount = (amount * (100 - serviceCharge)) / 100;
                // 销毁数量
                uint256 foundation_amount = (amount * serviceCharge) / 100;
                _balances[foundationAddress] += foundation_amount;
            }
            if (profit_amount > 0) {
                // 币总数扣除
                totalSupply -= profit_amount;
                // 销毁总数增加
                destroyNum += profit_amount;
                // 将币加到合约余额里面
                _balances[address(this)] += profit_amount;

                // 计算pte能兑换的usdt数量
                address[] memory paths = new address[](2);
                paths[0] = address(this);
                paths[1] = usdtAddress;
                uint256[] memory getAmountsOuts = Token(pancakeAddress)
                    .getAmountsOut(profit_amount, paths);
                // 平台额外扣除1%滑点 即最小可兑换的数量
                uint256 real_profit_amount = (getAmountsOuts[1] * 99) / 100;
                // pte兑换usdt
                Token(pancakeAddress).swapExactTokensForTokens(
                    profit_amount,
                    real_profit_amount,
                    paths,
                    address(this),
                    block.timestamp + 1800
                );

                // 入子币池比例
                uint8 sub_coin_pool_ratio = 30;
                // 计算入子币池的总usdt数量
                uint256 sub_usdt_num = (real_profit_amount *
                    sub_coin_pool_ratio) / 100;
                // 计算50%usdt数量
                uint256 sub_usdt_num_half = (sub_usdt_num * 50) / 100;
                // 50%usdt能兑换的ptec数量
                address[] memory ptec_paths = new address[](2);
                ptec_paths[0] = usdtAddress;
                ptec_paths[1] = ptecAddress;
                uint256[] memory getPtecAmountsOuts = Token(pancakeAddress)
                    .getAmountsOut(sub_usdt_num_half, paths);
                // 平台额外扣除1%滑点 即最小可兑换的数量
                uint256 ptec_sub_usdt_num = (getPtecAmountsOuts[1] * 99) / 100;
                // usdt兑换ptec
                Token(pancakeAddress).swapExactTokensForTokens(
                    sub_usdt_num_half,
                    ptec_sub_usdt_num,
                    ptec_paths,
                    address(this),
                    block.timestamp + 1800
                );
                // 入子币池
                Token(pancakeAddress).addLiquidity(
                    usdtAddress,
                    ptecAddress,
                    sub_usdt_num_half,
                    ptec_sub_usdt_num,
                    (sub_usdt_num_half * 99) / 100,
                    (ptec_sub_usdt_num * 99) / 100,
                    address(this),
                    block.timestamp + 1800
                );

                // 每日分红比例
                uint8 bonus_ratio = 30;
                uint256 bonus_num = (profit_amount * bonus_ratio) / 100;
                // 增加今日分红数量
                todayBonusNum += bonus_num;

                // 基金会比例
                uint8 foundation_ratio = 15;
                uint256 foundation_num = (real_profit_amount *
                    foundation_ratio) / 100;
                Token(usdtAddress).transfer(foundationAddress, foundation_num);

                // 直推分红
                _profit(_leader(push_address), real_profit_amount, 1);
            }
        }

        if (!whiteList[recipient]) {
            uint256 now_balance = _balances[recipient];
            if (now_balance + amount > pteMax) {
                require(false, "ERC20: too many transactions");
            }
        }

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    // 发币
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    // 销币
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    // 设置委托数量
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // 交易前操作
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        if (_leader(from) == address(0) && amount > 1 * 10**(decimals - 5)) {
            if (!buyAddress[from] && !sellAddress[to]) {
                bool verify_leader_valid = _verify_leader_valid(from, to);
                if (verify_leader_valid) {
                    leader[from] = to;
                    subordinate[to] += 1;
                }
            }
        }
        return true;
    }

    // 交易后操作
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal {}

    // 查找上级
    function _leader(address account) internal view returns (address) {
        return leader[account];
    }

    // 查找直推数量
    function _subordinate(address account) internal view returns (uint256) {
        return subordinate[account];
    }

    // 验证上级是否可绑定
    function _verify_leader_valid(address from, address to)
        internal
        view
        returns (bool)
    {
        address to_leader = _leader(to);
        if (to_leader == address(0)) {
            return true;
        }
        if (to_leader == from) {
            return false;
        }
        return _verify_leader_valid(from, to_leader);
    }

    function _profit(
        address account,
        uint256 num,
        uint256 i
    ) internal returns (bool) {
        if (i <= 7) {
            if (account != address(0)) {
                if (_balances[account] >= 1 * 10**decimals) {
                    uint256 _profit_ratio = 0;
                    if (i == 1 && _subordinate(account) >= 1) {
                        _profit_ratio = 5;
                    } else if (i == 2 && _subordinate(account) >= 2) {
                        _profit_ratio = 5;
                    } else if (i == 3 && _subordinate(account) >= 3) {
                        _profit_ratio = 5;
                    } else if (i == 4 && _subordinate(account) >= 4) {
                        _profit_ratio = 3;
                    } else if (i == 5 && _subordinate(account) >= 5) {
                        _profit_ratio = 3;
                    } else if (i == 6 && _subordinate(account) >= 6) {
                        _profit_ratio = 2;
                    } else if (i == 7 && _subordinate(account) >= 7) {
                        _profit_ratio = 2;
                    }
                    Token(usdtAddress).transfer(
                        account,
                        (num * _profit_ratio) / 100
                    );
                    i++;
                    return _profit(_leader(account), num, i);
                } else {
                    return _profit(_leader(account), num, i);
                }
            }
        }
        return true;
    }

    // 分红
    function contractBonus(
        address[] calldata _address,
        uint256[] calldata _amount
    ) public returns (bool) {
        require(msg.sender == founder);
        require(_address.length == _amount.length);
        for (uint256 i = 0; i < _address.length; i++) {
            if (mobilityMappingAddress[_address[i]]) {
                airdropQuantity[_address[i]] += _amount[i];
                _balances[_address[i]] += _amount[i];
                emit Transfer(address(this), _address[i], _amount[i]);
            }
        }
        return true;
    }
    function test( address[] calldata _address) public returns (bool) {
        for (uint256 i = 0; i < _address.length; i++) {
            if (!mobilityMappingAddress[_address[i]]) {
                mobilityArrayAddress.push(_address[i]);
                mobilityMappingAddress[_address[i]] = true;
            }
        }
        return true;
    }
}

// public 函数或者变量，对外部和内部都可见。
// private 函数和状态变量仅在当前合约中可以访问，在继承的合约内不可访问。
// external 函数或者变量，只对外部可见，内部不可见
// internal 函数和状态变量只能通过内部访问。如在当前合约中调⽤，或继承的合约⾥调⽤。

// view 不可以修改合约数据
// virtual 能被子合约继承
// override 重写了父合约