/**
 *Submitted for verification at BscScan.com on 2022-09-11
*/

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: contracts/WFSInvite.sol


pragma solidity 0.8.15;




/**   
*   @dev 邀约投资业务：require 2292
*          发布、投资、发布取回、投资取回，
*          发布订单查询、累计投资金额查询
*          发布事件、投资事件、发布取回事件、投资取回事件
*          发布手续费、投资手续费设置
*          WFC币合约地址设置、USDT合约地址设置
*/

contract WFSInvite is Context, Ownable {
    // 订单编号
    uint256 private _orderId = 0;
    // 发布募集的押金比例，4位精度
    uint256 public cashPledge = 10000;
    // @TODO 上线时需要核定真实的违约时间，120秒是测试使用
    // 违约时间
    // uint256 public delay = 3 days;    
    uint256 public delay = 120 seconds;
    // 本币 WFC
    address public tokenA;
    // 兑换币 USDT
    address public tokenB;
    // 订单发布手续费比例，4位精度
    uint256 public inviteFee;
    // 提现手续费比例，4位精度
    uint256 public withDrawFee;
    // 累计收取的手续费
    uint256 private _totalFee;

    // 发布人取回募集，订单单价高于市场价N% 精度为4位 默认0.1%
    uint256 public retrievedOverPriceRide = 1000;
    // 发布人取回募集，当前市场拥有过最高价 USDT 18位 默认当前最高价0USDT
    uint256 public orderMaxPrice = 0;

    // 订单ID对应的发布用户
    mapping(uint256 => address) private _initiator;
    // 订单ID对应的募集总额
    mapping(uint256 => uint256) private _tAmt;
    // 订单ID对应的已募集金额
    mapping(uint256 => uint256) private _eAmt;
    // 订单ID对应的募集单价
    mapping(uint256 => uint256) private _initPrice;
    // 订单ID对应的募集截止日期
    mapping(uint256 => uint256) private _deadline;
    // 订单是否结束, true 已结束， false 未结束
    mapping(uint256 => bool) private _ended;
    // 订单ID对应的预付金额(USDT)
    mapping(uint256 => uint256) private _prepaid;
    // 用户投资某个订单ID的累计投资总量
    mapping(address => mapping(uint256 => uint256)) private _cAmt;
    // 用户是否投资
    mapping(address => bool) private _isInvestment;
    
    // 某发布者用户，手动终止(取回)私募剩余金额（USDT）
    mapping(address => uint256) private _surplusSumPirce;

    // 发布订单事件
    event Invited(uint256 indexed id, address indexed initiator, uint256 amount, uint256 price);
    // 投资事件
    event Investment(uint256 indexed id, address indexed investors, uint256 amount);
    // 订单取回事件
    event Retrieved(address indexed account, uint256 id);
    // 投资领取事件
    event Withdraw(address indexed account, uint256 id);

    constructor(address _tokenA, address _tokenB) {
        // @TODO 上线时需要填写WFC 和 USDT的合约地址
        // WFC币种的合约地址 
        tokenA = _tokenA;
        // BSC链上的USDT合约地址
        tokenB = _tokenB;

        // 邀约发布手续费 0.5%
        inviteFee = 50;
        // 用户取回手续费 1%
        withDrawFee = 100;
    }
    
    // @dev 手续费设置，发布手续费和提现手续费
    function setFee(uint256 _inviteFee, uint256 _withDrawFee) external onlyOwner {
        inviteFee = _inviteFee;
        withDrawFee = _withDrawFee;
    }

    // @dev 设置 发布人取回募集，订单单价高于市场价N% 精度为4位 默认0.1%
    function setOverPriceRide(uint256 _retrievedOverPriceRide) external onlyOwner {
        retrievedOverPriceRide = _retrievedOverPriceRide;
    }

    // @dev 通过发布订单的ID查询订单详情
    // @param: _id 订单ID
    // @return: _initiator[_id] 发布用户
    // @return: _tAmt[_id]      募集总量
    // @return: _eAmt[_id]      已募集量
    // @return: _initPrice[_id] 单价
    // @return: _prepaid[_id]   预付押金
    // @return: _deadline[_id]  投资截止时间
    // @return: _ended[_id]     结束状态
    function getInviteOrder(uint256 _id) public view returns(address, uint256, uint256, uint256, uint256, uint256, bool) {
        return (_initiator[_id], _tAmt[_id], _eAmt[_id], _initPrice[_id], _prepaid[_id], _deadline[_id], _ended[_id]);
    }

    // @dev 通过用户和订单号，查询投资总额
    // @param _account: 用户地址
    // @param _id: 订单ID
    // @return 某个用户某笔订单的累计投资金额
    function getInjection(address _account, uint256 _id) public view returns(uint256) {
        return _cAmt[_account][_id];
    }

    // @dev 平台查看合约收到的手续费
    function getFee() external view onlyOwner returns(uint256) {
        return _totalFee;
    }

    // @dev 平台提取合约收到的手续费
    function reFee() external onlyOwner returns(bool) {
        uint256 _amount = _totalFee;
        _totalFee = 0;
        IERC20(tokenB).transfer(_msgSender(), _amount);        
        return true;
    }

    // @dev 通过用户，查询用户取回私募后剩余押金金额 USDT
    // @param _account: 用户地址
    function getSurplusSumPirce(address _account) public view returns(uint256){
        return _surplusSumPirce[_account];
    }  
        
    // @dev 发布投资
    // @param: _amount 募集的WFC的总数量，需要注意精度 = 10 ** 8
    // @param: _price 募集单价，需要注意精度 = 10 ** 18
    // @param: _date 募集截止时间
    function invited(address _inviter, uint256 _amount, uint256 _price, uint256 _date) public returns(bool) {        

        // 应该支付的USDT = 募集总量 * 单价 * 押金（WFC的精度8 ， 押金比例百分比精度4： 8 + 4 = 12） 
        uint256 _deposit = (_amount * _price * cashPledge)  / 10 ** 12; 
        // 最小押金应不低于1 USDT
        require(_deposit >= 1000000000000000000, "INV1");
        // 手续费 = 押金 * 手续费比例 ， 比例精度4：
        uint256 _fee = _deposit * inviteFee / 10000;
        // 总计应付金额 = 应该支付的USDT + 手续费USDT 
        uint256 _sum = _deposit + _fee;
        
        // 上次发布者取回募集剩余押金 USDT 20220905新增
        uint256 _surplusSumPirceEnd = _surplusSumPirce[_inviter];
        //实际总计应付金额USDT = 总计应付金额 - 上次发布者取回募集剩余押金 20220905新增
        if(_sum <= _surplusSumPirceEnd) {
            _surplusSumPirce[_inviter] = _surplusSumPirceEnd - _sum;
            _sum = 0;    
        }
        if(_sum > _surplusSumPirceEnd){
            _surplusSumPirce[_inviter] = 0;
            _sum = _sum - _surplusSumPirceEnd;
        }
  
        // 订单ID
        _orderId++;
        // 采用局部变量，防止重入
        uint256 _id = _orderId;

        // 把USDT转到合约上
        IERC20(tokenB).transferFrom(_inviter, address(this), _sum);
        
        // 记录订单信息
        // 已付押金（函数内部变量，单独处理）
        _prepaid[_id] = _deposit;
        // _initiator[_id] 发布用户
        // _tAmt[_id]      募集总量
        // _initPrice[_id] 单价
        // _deadline[_id]  投资截止时间
        // _ended[_id]     结束状态
        (_initiator[_id], _tAmt[_id], _initPrice[_id], _deadline[_id],  _ended[_id]) = (_inviter, _amount, _price, _date, false);

        // 总手续费增加
        _totalFee += _fee;

        //设置市场订单最高价
        if(orderMaxPrice < _price){
            orderMaxPrice = _price;
        }
        
        emit Invited(_id, _inviter, _amount, _price);

        return true;
    }

    // @dev 用户投资
    // @param: _id     订单编号
    // @param: _amount 投资数量 WFC 需要注意精度 = 10 ** 8
    function investment(uint256 _id, uint256 _amount) public returns(bool) {
   
        require(_amount > 0 , "INJ1");
        // 募集还没有关闭
        require(!(_ended[_id]), "INJ2");
        // 在投资截止时间前才能投资
        require(block.timestamp < _deadline[_id], "INJ3");
        // 订单剩余的投资额度大于等于投资金额
        require(_tAmt[_id] - _eAmt[_id] >= _amount, "INJ4" );

        address _account = _msgSender();

        // 用户只能同时投资一笔
        require(!(_isInvestment[_account]), "INJ5");     

        // 投资的钱放到合约
        IERC20(tokenA).transferFrom(_account, address(this), _amount);
        // 更新订单已募集到的金额
        _eAmt[_id] += _amount;
        // 增加用户的投资金额
        _cAmt[_account][_id] += _amount;

        // 用户已投资
        _isInvestment[_account] = true;

        emit Investment(_id, _account, _amount);
        
        return true;
    }
    
    // @dev 发布人取回募集，随时可以取回（取回了，订单就提前结束）
    // @param: _id 订单编号
    function retrieved(uint256 _id) public returns(bool) {
        address _retriever = _msgSender();
        // 取回者和发布者是同一个人（只能取回自己的）
        require(_retriever == _initiator[_id], "RET1");
        // 此前订单没有因“取回”或“违约”而关闭
        require(!(_ended[_id]), "RET2");

        // a.条件：邀约订单未到期、发布数量也未达到
        if(block.timestamp < _deadline[_id] && _eAmt[_id] < _tAmt[_id]){
            //b.条件：市场上有高于该发布方邀约订单的单价（平台设置高出单价的比例参数）
            uint256 _initPriceRideVal = _initPrice[_id] * retrievedOverPriceRide / 10000;
            uint256 _initPriceEnd = _initPrice[_id] + _initPriceRideVal;
            //当前市场最高价没有比此前订单单价高
            require(_initPriceEnd <= orderMaxPrice, "RET3");
        }

        // 已付款项
        uint256 _hPay = _prepaid[_id];
        // 应付的USDT数量 = 已募集到的WFC数量 * USDT单价 / WFC精度 
        uint256 _sPay = (_eAmt[_id] * _initPrice[_id]) / 10 ** 8;

        // 先处理本合约的内部数据，再发起外部业务
        // 关闭募集
        _ended[_id] = true;
        // 更新已付金额为应付金额
        _prepaid[_id] = _sPay;

        // 如果已付的钱不够（应付款 > 已付款），需要补钱
        if(_sPay > _hPay) {
            uint _amount = _sPay - _hPay;
            IERC20(tokenB).transferFrom(_retriever, address(this), _amount);       
        }
        
        if(block.timestamp >= _deadline[_id] || _eAmt[_id] >= _tAmt[_id]){
            // 如果已付的钱多了(已付款 > 应付款)，需要退钱 时间到期或数量达到目标，取回，则需要退换剩余保证金
            if(_hPay > _sPay) {
                uint256 _amount = _hPay - _sPay;
                IERC20(tokenB).transfer(_retriever, _amount);
            }
        }else{
            //如果已付的钱多了(已付款 > 应付款)，改为不退款，剩余保证金将自动放在该发布方下一个邀约订单中（保证金不能被发布方取回） 中途取回 不退还保证金
            if(_hPay > _sPay) {
                uint256 _amount = _hPay - _sPay;
                uint256 _oldSurplusSumPirce = _surplusSumPirce[_retriever];
                _surplusSumPirce[_retriever] =  _oldSurplusSumPirce + _amount;
            }
        }        
    
        // 把募集到的WFC转给募集方
        IERC20(tokenA).transfer(_retriever, _eAmt[_id]);

        // 将投资结束时间改为当前 20220905新增
        _deadline[_id] = block.timestamp;

        emit Retrieved(_retriever, _id);
        
        return true;
    }

    // @dev 用户取回投资，如果订单是正常状态，用户获得USDT；如果订单超过了违约时间，用户获得USDT，并退回自己投资的所有WFC
    // @param: _id 订单编号
    function withdraw(uint256 _id) public returns(bool) {
        address _account = _msgSender();
        // 这是一个有效的投资人
        require(_isInvestment[_account], "WD0");     
        // 在投资关闭 + N天延长期后可以取回
        require(block.timestamp >= (_deadline[_id] + delay), "WD1");
        
        // 用户投资的WFC
        uint256 _amount = _cAmt[_account][_id];
        // 用户应该分得的USDT = 发布方的预付的押金 * 个人的投资总量 / 订单收到的投资量
        uint256 _bouns = _prepaid[_id] * _amount / _eAmt[_id];
        // 手续费
        uint256 _fee = _bouns * withDrawFee / 10000;

        // 用户投资的WFC归0
        _cAmt[_account][_id] = 0;
        // 转USDT给投资人
        IERC20(tokenB).transfer(_account, (_bouns - _fee));
        // 平台手续费增加
        _totalFee += _fee;
        
        // 如果到期后，发布方没有正常关闭，则发布方被视为违约，需要退还用户投资的WFC
        if(!(_ended[_id])) {
            _ended[_id] = true;
            // 退还用户WFC
            IERC20(tokenA).transfer(_account, _amount);
        }
        
        // 投资取回后将投资人标记为不是投资人
        _isInvestment[_account] = false;

        emit Withdraw(_account, _id);

        return true;
    }

}