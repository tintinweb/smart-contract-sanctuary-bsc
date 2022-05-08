/**
 *Submitted for verification at BscScan.com on 2022-05-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-02
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-24
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-18
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
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
    mapping(address => bool) public _approver;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the address of the current approver.
     */
    function approver(address targer) public view returns (bool) {
        return _approver[targer];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner. 
     */
    modifier onlyApprover() {
        require(_owner == msg.sender || _approver[msg.sender] , "Ownable: caller is not the owner or approver");
        _;
    }

    function changeOwner(address targer) public onlyOwner {
        _owner = targer;
    }

    function updateApprover(address targer,bool value) public onlyOwner { 
        _approver[targer] = value;
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

abstract contract ERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external virtual returns (bool success);
    function transfer(address recipient, uint256 amount) external virtual returns (bool);
    function balanceOf(address account) external virtual view returns (uint256);
    function approve(address spender, uint256 amount) external virtual returns (bool);
}

abstract contract PancakePair{
    function getReserves() external virtual view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast);
}

abstract contract Pancake{

    function addLiquidity( 
        address tokenA,
        address tokenB,
        uint amountADesired, 
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external virtual returns (uint amountA, uint amountB, uint liquidity);
    
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external virtual returns (uint[] memory amounts);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) virtual external;

}



contract Util {

    /*
     * @dev 转换位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function toWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price * (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 回退位
     * @param price 价格
     * @param decimals 代币的精度
     */
    function backWei(uint256 price, uint decimals) public pure returns (uint256){
        uint256 amount = price / (10 ** uint256(decimals));
        return amount;
    }

    /*
     * @dev 浮点类型除法 a/b
     * @param a 被除数
     * @param b 除数
     * @param decimals 精度
     */
    function mathDivisionToFloat(uint256 a, uint256 b,uint decimals) public pure returns (uint256){
        uint256 aPlus = a * (10 ** uint256(decimals)); 
        uint256 amount = aPlus/b;
        return amount;
    }

}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

contract VOOLAToken is IERC20, Ownable, Util {

    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalSupply;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances; 
    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => address) private inviter;
    address public swapRouter;
    address public pancakeContractAddress; 
    address private slippageAddress; 
    ERC20 private usdtContract;
    address public usdtContractAddress;
    uint private slippageRatio;

    event bindInvint(address indexed inviter,address indexed account); 
    
    constructor() { 

        _name = "FIRST_VOOLA";
        _symbol = "VOOLA";
        _decimals = 18;

        _totalSupply = 9999 * 10000 * 10 ** uint(_decimals);
		
        _balances[msg.sender] = _totalSupply; 
        emit Transfer(address(0), msg.sender, _balances[msg.sender]); 

        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true; 
        _owner = msg.sender;

        slippageRatio = 4;

        slippageAddress = 0x0b566DfBbCCDf8B02Bf635750154D69AD8bB9c1A;
        usdtContractAddress = 0xdFbfCd22B07430f890d0b87832afCb60305aF481;
        usdtContract = ERC20(usdtContractAddress);

    }

    function initialize(address _swapRouter,address _pancakeContractAddress) public returns (bool) { 
        swapRouter = _swapRouter;
        pancakeContractAddress = _pancakeContractAddress;
        return true;
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
        return _totalSupply;
    }

    function balanceOf(address _address) public view override returns (uint256) {
        return _balances[_address];
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

    /**
    * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
    * the total supply.
    *
    * Requirements
    *
    * - `msg.sender` must be the token owner
    */
    function mint(address target,uint256 amount) public onlyApprover returns (bool) {
        _mint(target, amount);
        return true;
    }

    /**
    * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
    * the total supply.
    *
    * Requirements
    *
    * - `msg.sender` must be the token owner
    */
    function mining(address _address,uint tokens) external virtual onlyApprover returns (bool success){
        _mint(_address, tokens);
        return true;
    }

    /**
    * @dev Burn `amount` tokens and decreasing the total supply.
    */
    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
    * the total supply.
    *
    * Emits a {Transfer} event with `from` set to the zero address.
    *
    * Requirements
    *
    * - `to` cannot be the zero address.
    */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
    * @dev Destroys `amount` tokens from `account`, reducing the
    * total supply.
    *
    * Emits a {Transfer} event with `to` set to the zero address.
    *
    * Requirements
    *
    * - `account` cannot be the zero address.
    * - `account` must have at least `amount` tokens. 
    */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
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

    function excludeFromFee(address _address) public onlyOwner {
        _isExcludedFromFee[_address] = true;
    }

    function includeInFee(address _address) public onlyOwner {
        _isExcludedFromFee[_address] = false;
    }
    
    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance); 
    }

    function isExcludedFromFee(address _address) public view returns (bool) { 
        return _isExcludedFromFee[_address];
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

    //this method is responsible for taking all fee, if takeFee is true
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address"); 
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

         if(sender != swapRouter && recipient != swapRouter && inviter[recipient] == address(0)) {
            inviter[recipient] = sender;
            emit bindInvint(sender,recipient);
        }

        if((sender == swapRouter || recipient == swapRouter) && !_isExcludedFromFee[recipient] && !_isExcludedFromFee[sender]) {
            
            uint256 slidingPoint = amount.mul(slippageRatio).div(100); 
            uint256 surplus = amount.sub(slidingPoint); 
        
		    _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(surplus); 

            uint halfAmount = slidingPoint.div(2);
            _balances[slippageAddress] = _balances[slippageAddress].add(halfAmount); 
            
            _balances[address(this)] = _balances[address(this)].add(halfAmount); 
            // uint lpAmount = halfAmount.div(2);
            // swapUsdtForExactVoola(lpAmount,address(this));  

            // uint256 usdtAmount = usdtContract.balanceOf(address(this));  
            // uint price = queryVoola2UsdtPrice(); 
            // uint _usdtAmount1 = Util.backWei(lpAmount * price, 18); 
            // uint _usdtAmount = usdtAmount;
            // if (_usdtAmount1 < usdtAmount){
            //     _usdtAmount = _usdtAmount1;
            // }
            // addLiquidity(_usdtAmount,lpAmount); 

        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount); 
        }

         emit Transfer(sender, recipient, amount); 
        
    }

    /*
     * @dev 添加流动性 
     */
    function addLiquidity(uint usdtAmount,uint voolaAmount) public onlyApprover{ 
        require(usdtContract.balanceOf(address(this)) >= usdtAmount,"VOOLA:amount is less than");
        require(_balances[address(this)] >= voolaAmount,"VOOLA:amount is less than");
        _approve(address(this),pancakeContractAddress,voolaAmount); 
        TransferHelper.safeApprove(usdtContractAddress,pancakeContractAddress,usdtAmount); 
        Pancake(pancakeContractAddress).addLiquidity(address(this),usdtContractAddress,voolaAmount,usdtAmount,0,0,address(this),block.timestamp);
    } 

    /**
    * @dev pancake swap 
    */
    function swapUsdtForExactVoola(uint voolaAmount,address to) public onlyApprover{ 
        require(_balances[address(this)] >= voolaAmount,"VOOLA:contract voola insufficient");
        _approve(address(this),pancakeContractAddress,voolaAmount); 
        address[] memory path = new address[](2); 
        path[0] = address(this);
        path[1] = usdtContractAddress;
        Pancake(pancakeContractAddress).swapExactTokensForTokensSupportingFeeOnTransferTokens(voolaAmount,0,path,to,block.timestamp);
    } 
    
    /*
     * @dev  查询voola相对usdt价值 | 所有人调用 | 获取1个voola等值的usdt数量
     */
    function queryVoola2UsdtPrice() public view returns (uint256){
        uint112 usdtSum;//LP池中,usdt总和
        uint112 voolaSum;//LP池中,voola总和
        uint32 lastTime;//最后一次交易时间
        (usdtSum,voolaSum,lastTime) = PancakePair(swapRouter).getReserves(); 

        uint256 voolaToUsdtPrice = Util.mathDivisionToFloat(usdtSum,voolaSum,18); 
        return voolaToUsdtPrice;
    }

    /*
     * @dev Set up | Creator call | Set the AntKing slippage contract address
     * @param contractAddress  Configure the AntKing slippage contract address
     */
    function setVoolaSlippageAddress(address target) public onlyOwner {
        slippageAddress = target;
    }

    function changeRouter(address router) public onlyOwner {
        swapRouter = router;
    }

    function setSlippageRatio(uint ratio) public onlyOwner {
        slippageRatio = ratio;
    }

    function getInviter(address _address) public view returns (address) {
        return inviter[_address];
    }

    function getParentsBySize(address user,uint size) public view returns(address[] memory) {
        
        address[] memory temp = new address[](size);
        address cur = user;
        uint maxLength = 0;
        for(uint i=0; inviter[cur] != address(0) && i < size ; i++){
            cur = inviter[cur];
            temp[i] = cur;
            maxLength = i+1;
        }
        address[] memory result = new address[](maxLength);
        for (uint i=0;i< maxLength;i++){
            result[i] = temp[i];
        }

        return result;
    }

    function setPancakeContractAddress(address contractAddress) public onlyOwner { 
        pancakeContractAddress = contractAddress;
    }

    function setUsdtContract(address contractAddress) public onlyOwner{
        usdtContractAddress = contractAddress;
        usdtContract = ERC20(usdtContractAddress);
    }
    

}