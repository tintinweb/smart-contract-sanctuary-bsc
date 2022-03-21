/**
 *Submitted for verification at BscScan.com on 2022-03-21
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

contract Miner is Ownable {
    mapping(address => bool) internal miner;

    constructor() {
        miner[msg.sender] = true;
    }

    modifier onlyMiner {
        require(miner[msg.sender] == true || msg.sender == _owner);
        _;
    }

    function setMiner(address _address, bool flag) public onlyOwner {
        miner[_address] = flag;
    }

    function getMiner(address _address) public view returns (bool) {
        return miner[_address];
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

abstract contract AntKingSlippage {
    function slippage(uint256 amountToWei, address [] calldata superiors) external virtual returns (address [] memory slippageAddress, uint256 [] memory slippageAmount);
}

contract AntKingToken is IERC20, Miner {

    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 private _totalCount;
    uint256 private _totalSupply;
    uint private _waitMining;

    mapping(address => uint256) private _balances;
    mapping(address => uint256) private buyAmount;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;

    mapping(address => address) private inviter;
    address public swapRouter;
    address private slippageAddress;
    uint private slippageRatio;
    
    constructor() {

        _name = "TestAntKing";
        _symbol = "TAK";
        _decimals = 18;

        _totalSupply = 3888 * 10 ** uint(_decimals);
        _waitMining = 2100 * 10 ** uint(_decimals);
		
        _balances[msg.sender] = _totalSupply - _waitMining;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);
        
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        miner[msg.sender] = true;
        _owner = msg.sender;

        slippageRatio = 13;

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

    function waitMining() public view returns (uint) {
        return _waitMining;
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
        }

        if(sender == swapRouter && !_isExcludedFromFee[recipient]) {
            
            uint256 slidingPoint = amount.mul(slippageRatio).div(100);
            uint256 surplus = amount.sub(slidingPoint);
        
		    _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(surplus);

            address [] memory superiors = new address[](6);
            if(inviter[recipient] != address(0)) {
                superiors[0] = inviter[recipient];

                for(uint8 i=0; i<superiors.length - 1; i++) {
                    if(inviter[superiors[i]] != address(0)) {
                        superiors[i+1] = inviter[superiors[i]];
                    }
                }

            }
            
            (address [] memory slippageAddresses, uint256 [] memory slippageAmounts) = AntKingSlippage(slippageAddress).slippage(amount, superiors);
            for(uint8 i=0; i<slippageAddresses.length; i++) {
                if(slippageAddresses[i] != address(0)) {
                    _balances[slippageAddresses[i]] = _balances[slippageAddresses[i]].add(slippageAmounts[i]);
                    emit Transfer(sender, slippageAddresses[i], slippageAmounts[i]);
                }
            }
            
            emit Transfer(sender, recipient, surplus);

        } else {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        
    }

    /*
     * @dev Set up | Creator call | Set the AntKing slippage contract address
     * @param contractAddress  Configure the AntKing slippage contract address
     */
    function setAntKingSlippageContract(address contractAddress) public onlyOwner {
        slippageAddress = contractAddress;
    }

    function changeRouter(address router) public onlyOwner {
        swapRouter = router;
    }

    function setSlippageRatio(uint ratio) public onlyOwner {
        slippageRatio = ratio;
    }

    /*
    function mining(address _address, uint tokens) public onlyMiner returns (bool success) {
        if(tokens <= _waitMining){
            _balances[_address] = _balances[_address].add(tokens);
            _waitMining = _waitMining.sub(tokens);
        }
        emit Transfer(address(0), _address, tokens);
        return true;
    }
    */

    function getInviter(address _address) public view returns (address) {
        return inviter[_address];
    }

}