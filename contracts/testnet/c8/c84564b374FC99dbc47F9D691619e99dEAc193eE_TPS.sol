// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./IUniswapV2Router.sol";

/**
 * @title TPS代币模块
 * @dev 这是TPS的标准接口
 */
contract TPS is Ownable {
    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    string name_ = "TPS";
    string symbol_ = "TPS";
    uint32 decimals_ = 18;
    uint256 totalSupply_ = 21000000 * (10 ** decimals_);
    uint256 initialSupply_ = 21000000 * (10 ** decimals_);

    // 费率比例 1:10000 (固定)
    uint32 ratio_ = 10000;
    // 手续费率 3表示万分之三
    uint32 rate_ = 300;
    // 最大手续费
    uint256 feeMax_ = 10000000 * 10 ** decimals_;

    // address => uint256
    mapping(address => uint256) balances;
    // _owner => _operator => uint256
    mapping(address => mapping(address => uint256)) allowed;
    // _owner => _amount
    mapping(address => uint256) frozenAccount;
	// 用户的上级 address => address
	mapping(address => address) public inviteFather;
    // 默认上级地址
    address public addr_default = 0xd397A6E818972Ac83CEb4c1cC59DC4fFa36d6BFa;
	// 用户直属下级列表 address => address[]
	mapping(address => address[]) public inviteSon;
	// 邀请奖励比例
	uint256[] public rewardArr = [200, 100];
    // 当给别人转账金额为11TPS时，建立邀请关系
    uint256 public inviteNum = 11 * 10 ** decimals_;

    // 流动性池合约
    IUniswapV2Router public uniswapTPS;
    address public uniswapCapitalPool = 0xF9504c76a84f4b1d443590EDA70d20b2fDd934E9;
    // LP质押池地址
    address public addr_lpPool = 0xd397A6E818972Ac83CEb4c1cC59DC4fFa36d6BFa;

    /*
     * @dev 构造函数，发行TPS代币
     */
    constructor() {
        // 将资产转到发起账户
        balances[msg.sender] = initialSupply_;
        emit Transfer(address(0), msg.sender, initialSupply_);
    }

    /*
     * @dev 事件通知 —— 冻结资产
     * @param {String} _address 目标地址
     * @param {Number} _amount 冻结额度
     */
    event Frozen(address indexed _address, uint256 _amount);

    /*
     * @dev 事件通知 —— 发生交易
     * @param {String} _from
     * @param {String} _to
     * @param {Number} _amount
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _amount);

    /*
     * @dev 事件通知 —— 授权变更
     * @param {String} _owner
     * @param {String} _operator
     * @param {Number} _amount
     */
    event Approval(address indexed _owner, address indexed _operator, uint256 _amount);

    /*
     * @dev 事件通知 —— 增发代币
     * @param {String} _address 增发币接收地址
     * @param {String} _amount 增发数量
     */
    event Mint(address indexed _address, uint256 _amount);

    /*
     * @dev 事件通知 —— 销毁代币
     * @param {String} _address 目标地址
     * @param {Number} _amount 销毁的数量
     */
    event Burn(address indexed _address, uint256 _amount);

    /**
     * @dev 查询代币名称
     */
    function name() public view returns (string memory) {
        return name_;
    }

    /**
     * @dev 查询代币符号
     */
    function symbol() public view returns (string memory) {
        return symbol_;
    }

    /**
     * @dev 查询代币精度
     */
    function decimals() public view returns (uint32) {
        return decimals_;
    }

    /**
     * @dev 查询代币总发行量
     * @return {Number} 返回发行量
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev 最大手续费
     * @return {Number} 返回手续费
     */
    function feeMax() public view returns (uint256) {
        return feeMax_;
    }

    /*
     * @dev 设置最大手续费
     * @param {Number} feeMax 最大手续费
     */
    function setFeeMax(uint256 _feeMax) public onlyOwner {
        // 最大手续费
        feeMax_ = _feeMax;
    }

    /**
     * @dev 手续费率
     * @return {Number} 返回手续费率
     */
    function rate() public view returns (uint32) {
        return rate_;
    }

    /*
     * @dev 设置转账手续费
     * @param {Number} _rate
     */
    function setRate(uint32 _rate) public onlyOwner {
        // 转账手续费
        rate_ = _rate;
    }

    /**
     * @dev 查询手续费
     * @param {Number} _amount 额度
     * @return {Number} 返回手续费
     */
    function getFee(uint256 _amount) public view returns (uint256) {
        if (rate_ == 0) {
            return 0;
        }
        uint256 fee = (_amount * rate_).div(ratio_);
        if (fee > feeMax_) {
            fee = feeMax_;
        }
        return fee;
    }

    /**
     * @dev 查询账户被冻结资产额度
     * @param {String} _address 查询的地址
     */
    function frozenOf(address _address) public view returns (uint256) {
        return frozenAccount[_address];
    }

    /**
     * @dev 查询地址余额
     * @param {String} _address
     * @return {Number} 返回余额
     */
    function balanceOf(address _address) public view returns (uint256) {
        return balances[_address];
    }

    /**
     * @dev 查询地址可用余额
     * @param {String} _address
     * @return {Number} 返回余额
     */
    function balanceUseOf(address _address) public view returns (uint256) {
        uint256 balance = balanceOf(_address);
        uint256 frozen = frozenOf(_address);
        return balance.sub(frozen);
    }
    
	/*
	 * 建立邀请关系
	 * @param {String} father 上级
	 * @param {String} son 下级
	 */
	function _invite(address _father, address _son) internal {
		if(inviteFather[_son] == address(0) && _son != _father){
			inviteFather[_son] = _father;
			inviteSon[_father].push(_son);
		}
	}

	/*
	 * 建立邀请关系
	 * @param {String} son 下级
	 * @param {Number} _amount 下级
	 */
    modifier invite(address _son, uint256 _amount) {
        _;
        // 如果给别人转账11枚，则和对方建立邀请关系
        if(_amount == inviteNum){
            _invite(msg.sender, _son);
        }
    }

    /*
     * @dev 从Uni转出
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function _transferUniOut(address _to, uint256 _amount) private {
        address _from = uniswapCapitalPool;
        uint256 balance = balanceOf(_from);
        uint256 frozen = frozenOf(_from);
        uint256 _balance = balance.sub(_amount);
        require(
            balance > frozen && _balance >= frozen,
            "TPS: Insufficient available balance"
        );
        balances[_from] = _balance;

        // 扣除3%给LP质押池
        uint256 fee = getFee(_amount);
        uint256 total = _amount - fee;
        balances[_to] = balances[_to].add(total);
        balances[addr_lpPool] = balances[addr_lpPool].add(fee);
        emit Transfer(_from, _to, _amount);
        emit Transfer(_to, addr_lpPool, fee);
    }

    /*
     * @dev 转入到Uni
     * @param {String} _from 转出人
     * @param {Number} _amount 转账金额
     */
    function _transferUniIn(address _from, uint256 _amount) private {
        address _to = uniswapCapitalPool;
        uint256 fee = getFee(_amount);
        uint256 total = _amount + fee;
        uint256 balance = balanceOf(_from);
        require(balance >= total, "TPS: insufficient account balance");
        uint256 _balance = balance.sub(total);
        uint256 frozen = frozenOf(_from);
        require(
            balance > frozen && _balance >= frozen,
            "TPS: Insufficient available balance"
        );
        balances[_to] = balances[_to].add(_amount);

        // 计算手续费
        uint256 fee2 = (_amount * rewardArr[0]).div(ratio_);
        uint256 fee1 = fee - fee2;

        address f2 = inviteFather[_from];
        if(f2 == address(0)) {
            // 如果转账人没有上级，则默认地址获得所有TPS手续费
            balances[addr_default] = balances[addr_default].add(fee);
            emit Transfer(_from, _to, _amount);
            emit Transfer(_from, addr_default, fee);
        }
        else {
            address f1 = inviteFather[f2];
             if(f1 == address(0)) {
                // 如果没有上上级，则默认地址获得上上级的手续费
                balances[f2] = balances[f2].add(fee2);
                balances[addr_default] = balances[addr_default].add(fee1);
                emit Transfer(_from, _to, _amount);
                emit Transfer(_from, f2, fee2);
                emit Transfer(_from, addr_default, fee1);
            }
            else {
                balances[f2] = balances[f2].add(fee2);
                balances[f1] = balances[f1].add(fee1);
                emit Transfer(_from, _to, _amount);
                emit Transfer(_from, f2, fee2);
                emit Transfer(_from, f1, fee1);
            }
        }
    }

    /*
     * @dev 转账
     * @param {String} _from 转出人
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function _transfer(
        address _from,
        address _to,    
        uint256 _amount
    ) private {
        if(_to == uniswapCapitalPool){
            // 用户添加LP，转入到Uniswap
            _transferUniIn(_from, _amount);
        }
        else if(_from == uniswapCapitalPool){
            // 用户移除LP，从Uniswap转出
            _transferUniOut(_to, _amount);
        }
        else {
            uint256 balance = balanceOf(_from);
            require(balance >= _amount, "TPS: insufficient account balance");
            uint256 frozen = frozenOf(_from);
            uint256 _balance = balance.sub(_amount);
            require(
                balance > frozen && _balance >= frozen,
                "TPS: Insufficient available balance"
            );
            balances[_from] = _balance;
            balances[_to] = balances[_to].add(_amount);
            emit Transfer(_from, _to, _amount);
        }
    }

    /*
     * @dev 发起人转账
     * @param {String} _to 收款用户
     * @param {Number} _amount 金额
     */
    function transfer(address _to, uint256 _amount) invite(_to, _amount) public {
        require(
            _to != address(0),
            "TPS: cannot transfer to black hole address"
        );
        require(_to != msg.sender, "TPS: cannot transfer to self");
        require(_amount > 0, "TPS: transfer _amount must be greater than 0");
        _transfer(msg.sender, _to, _amount);
    }

    /*
     * @dev 发起人转账
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function safeTransfer(
        address _to,
        uint256 _amount
    ) public returns(bool){
        transfer(_to,_amount);
        return true;
    }

    /*
     * @dev 从某账户转账给某人（公开）
     * @param {String} _from 转出人
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public {
        require(_amount > 0, "TPS: transfer _amount must be greater than 0");
        require(
            allowed[_from][msg.sender] >= _amount,
            "TPS: Exceed the authorized limit"
        );
        _transfer(_from, _to, _amount);
    }

      /*
     * @dev 从某账户转账给某人（公开）
     * @param {String} _from 转出人
     * @param {String} _to 收款人
     * @param {Number} _amount 转账金额
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns(bool){
        transferFrom(_from,_to,_amount);
        return true;
    }


    /*
     * 授权
     * @param {String} _operator 授权可操作人
     * @param {Number} _amount 授权单笔可操作额度
     */
    function approve(address _operator, uint256 _amount) public {
        address owner = msg.sender;
        allowed[owner][_operator] = _amount;
        emit Approval(owner, _operator, _amount);
    }

    /**
     * @dev 查询授权额度
     * @param {String} _owner 持有人地址
     * @param {String} _operator 授权人地址
     * @return {Number} 返回授权额度
     */
    function allowance(address _owner, address _operator)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_operator];
    }

    /*
     * @dev 批量转账
     * @param {String} _from 转自某人
     * @param {String} _toArr 转给某人
     * @param {Number} _amount 转账额度
     */
    function _transferBath(
        address _from,
        address[] memory _toArr,
        uint256 _amount
    ) private {
        uint256 balance = balanceOf(_from);
        uint256 count = _toArr.length.mul(_amount);
        uint256 fee = getFee(count);
        uint256 total = count + fee;
        require(balance >= total, "TPS: insufficient account balance");
        uint256 frozen = frozenOf(_from);
        require(
            balance > frozen && balance.sub(frozen) >= total,
            "TPS: insufficient available balance"
        );
        for (uint256 i = 0; i < _toArr.length; i++) {
            address _to = _toArr[i];
            _transfer(_from, _to, _amount);
        }
    }

    /*
     * @dev (授权人)批量转账
     * @param {String} _from 转出地址
     * @param {String} _toArr 收币地址集合
     * @param {Number} _amount 每个地址所获额度
     */
    function transferFromBath(
        address _from,
        address[] memory _toArr,
        uint256 _amount
    ) public {
        uint256 n = allowance(_from, msg.sender);
        require(n > 0, "TPS: No operation permission");
        require(n >= _amount, "TPS: Exceeds the single actionable _amount");
        _transferBath(_from, _toArr, _amount);
    }

    /*
     * @dev 批量转账
     * @param {String} _toArr 收币地址集合
     * @param {Number} _amount 每个地址所获额度
     */
    function transferBath(address[] memory _toArr, uint256 _amount) public {
        _transferBath(msg.sender, _toArr, _amount);
    }

    /*
     * @dev 增发代表
     * @param {String} _address 增发给某人
     * @param {Number} _amount 增发的数量
     */
    function mint(address _address, uint256 _amount) public onlyAdmin {
        balances[_address] = balances[_address].add(_amount);
        totalSupply_ = totalSupply_.add(_amount);
        emit Mint(_address, _amount);
        emit Transfer(zeroAddress, owner, _amount);
        emit Transfer(owner, _address, _amount);
    }

    /*
     * @dev 冻结资产
     * @param {String} _address 目标地址
     * @param {Number} _amount 冻结额度
     */
    function freeze(address _address, uint256 _amount) public onlyAdmin {
        uint256 balance = balanceOf(_address);
        if (_amount > balance) {
            _amount = balance;
        }
        frozenAccount[_address] = _amount;
        emit Frozen(_address, _amount);
    }

    /*
     * @dev 销毁
     * @param {String} _address 账户地址
     * @param {Number} _amount 销毁数量
     */
    function _burn(address _address, uint256 _amount) private {
        require(
            _address != address(0),
            "TPS: cannot destroy from zero address"
        );
        balances[_address] = balances[_address].sub(_amount);
        totalSupply_ = totalSupply_.sub(_amount);
        emit Transfer(_address, address(0), _amount);
    }

    /*
     * @dev 销毁某人的代币
     * @param {String} _address 账户地址
     * @param {Number} _amount 销毁数量
     */
    function burnFrom(address _address, uint256 _amount) public onlyAdmin {
        _burn(_address, _amount);
    }

    
    /*
     * 设置默认地址
     * @param {String} _address 地址
     */
    function setDefault(address _address) public onlyAdmin {
        addr_default = _address;
    }
    
    /*
     * 设置Uniswap地址
     * @param {String} _address 地址
     */
    function setUniswapTPS(address _address) public onlyAdmin {
        uniswapTPS = IUniswapV2Router(_address);
    }
    
    /*
     * 设置Uniswap资金池地址
     * @param {String} _address 地址
     */
    function setUniswapCapitalPool(address _address) public onlyAdmin {
        uniswapCapitalPool = _address;
    }
    
    /*
     * 设置lp质押挖矿地址
     * @param {String} _address 地址
     */
    function setlpPool(address _address) public onlyAdmin {
        addr_lpPool = _address;
    }
}