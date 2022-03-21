/**
 *Submitted for verification at BscScan.com on 2022-03-21
*/

pragma solidity 0.5.16;


interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender)
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


contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
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
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
}


interface IFactory {
    function createPair(address tokenA, address tokenB)
    external
    returns (address PancakePair);
}


interface IPair {
    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function token0() external view returns (address);

    function token1() external view returns (address);
}


contract PancakeTool {
    address public PancakePair;
    IRouter internal PancakeV2Router;

    function initIRouter(address _router) internal {
        PancakeV2Router = IRouter(_router);
        PancakePair = IFactory(PancakeV2Router.factory()).createPair(
            address(this),
            0x55d398326f99059fF775485246999027B3197955
        );
    }

    function swapTokensForTokens(
        uint256 tokenAmount,
        address tokenDesireAddress
    ) internal {
        address[] memory path = new address[](3);
        path[0] = address(this);
        path[1] = PancakeV2Router.WETH();
        path[2] = tokenDesireAddress;
        PancakeV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapTokensForETH(uint256 amountDesire, address to) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = PancakeV2Router.WETH();
        PancakeV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountDesire,
            0,
            path,
            to,
            block.timestamp
        );
    }

    function getPoolInfo()
    public
    view
    returns (uint112 WETHAmount, uint112 TOKENAmount)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = IPair(PancakePair)
        .getReserves();
        WETHAmount = _reserve1;
        TOKENAmount = _reserve0;
        if (IPair(PancakePair).token0() == PancakeV2Router.WETH()) {
            WETHAmount = _reserve0;
            TOKENAmount = _reserve1;
        }
    }

    function getPrice4ETH(uint256 amountDesire)
    internal
    view
    returns (uint256)
    {
        (uint112 WETHAmount, uint112 TOKENAmount) = getPoolInfo();
        return (WETHAmount * amountDesire) / TOKENAmount;
    }

    function getLPTotal(address user) internal view returns (uint256) {
        return IBEP20(PancakePair).balanceOf(user);
    }

    function getTotalSupply() internal view returns (uint256) {
        return IBEP20(PancakePair).totalSupply();
    }
}


contract GumpToken is Context, IBEP20, Ownable, PancakeTool {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    address private _PancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address[] private _lockAddress;
    address private _making;

    uint8 public _cPercent1 = 3;
    uint8 public _cPercent2 = 1;
    uint8 public _cPercent3 = 1;

    uint256 public divBase = 1000;
    uint256 private size = 1000000000000000000;

    uint256 public rewardMin = 1000000000000000000;

    uint256 public divideNum = 0;

    address liquid_divide = 0x2fa2aAb6207E66287B1D2D0D1CA958052004e402;
    address prize_divide = 0x8EE63509672dc8bc3f17D2d2EC9E29a4519Ac7A3;
    mapping(address => bool) private tokenHold;
    mapping(address =>uint256) public dividePlan;
    address[] private tokenHolders;

    address[] private tokenLPHold;
    uint256[] private hasSentPrize;
    uint256 private cal_num = 3;

    event RewardLogs(address indexed account, uint256 amount);

    mapping(address => bool) private blackList;

    constructor() public payable{
        _name = "Test Token";
        _symbol = "TESTDAO";
        _decimals = 18;
        _totalSupply = 10000 * size;
        _balances[msg.sender] = _totalSupply;
        tokenHold[msg.sender] = true;
        _making = msg.sender;

        initIRouter(_PancakeRouter);
        _approve(address(this), _PancakeRouter, ~uint256(0));
        _approve(liquid_divide, _PancakeRouter, ~uint256(0));
        _approve(prize_divide, _PancakeRouter, ~uint256(0));
        _approve(owner(), _PancakeRouter, ~uint256(0));
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function changeFee1(uint8 fee) public onlyOwner{
        _cPercent1 = fee;
    }

    function changeFee2(uint8 fee) public onlyOwner{
        _cPercent2 = fee;
    }

    function changeFee3(uint8 fee) public onlyOwner{
        _cPercent3 = fee;
    }

    function changeCalNum(uint8 num) public onlyOwner{
        cal_num = num;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    external
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    external
    view
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "BEP20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
    public
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "BEP20: decreased allowance below zero"
            )
        );
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");

        _beforeTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        uint256 _cFee = 0;
        uint256 _divide = 0;
        uint256 _destroy = 0;
        uint256 _prize = 0;
        if (sender != owner()) {
            _cFee = (amount / divBase) * (_cPercent1+_cPercent2+_cPercent3);

            _divide = (amount / divBase) * (_cPercent1);
            _prize = (amount / divBase) * (_cPercent2);
            _destroy = (amount / divBase) * (_cPercent3);

            _balances[liquid_divide] = _balances[liquid_divide].add(_divide);
            _balances[prize_divide] = _balances[prize_divide].add(_prize);
            _balances[address(0xdead)] = _balances[address(0xdead)].add(_destroy);
            emit Transfer(sender, address(0xdead), _destroy);
            emit Transfer(sender, liquid_divide, _divide);
            emit Transfer(sender, prize_divide, _prize);
        }

        _balances[recipient] = _balances[recipient].add(
            amount - _cFee
        );
        emit Transfer(sender, recipient, amount - _cFee);


        if(dividePlan[sender]>0){
            _balances[liquid_divide] = _balances[liquid_divide].sub(
                dividePlan[sender],
                "BEP20: transfer amount exceeds balance"
            );
            _balances[sender] = _balances[sender].add(
                dividePlan[sender]
            );
            emit Transfer(liquid_divide, sender, dividePlan[sender]);
            emit RewardLogs(sender, dividePlan[sender]);
            dividePlan[sender] = 0;
        }

        if(dividePlan[recipient]>0){
            _balances[liquid_divide] = _balances[liquid_divide].sub(
                dividePlan[recipient],
                "BEP20: transfer amount exceeds balance"
            );
            _balances[recipient] = _balances[recipient].add(
                dividePlan[recipient]
            );
            emit Transfer(liquid_divide, recipient, dividePlan[recipient]);
            emit RewardLogs(recipient, dividePlan[recipient]);
            dividePlan[recipient] = 0;
        }

        if(super.getLPTotal(sender)>0){
            if(!check_exists(sender)){
                tokenLPHold.push(sender);
            }
        }else{
            if(check_exists(sender)){
                remove_array(sender);
            }
        }
        if(super.getLPTotal(recipient)>0){
            if(!check_exists(recipient)){
                tokenLPHold.push(recipient);
            }
        }else{
            if(check_exists(recipient)){
                remove_array(recipient);
            }
        }

        _afterTransfer();
    }

    function check_exists(address address_lp) internal view returns(bool){
        bool find = false;
        if(tokenLPHold.length>0){
            for(uint256 i=0;i<tokenLPHold.length;i++){
                if(tokenLPHold[i]==address_lp){
                    find = true;break;
                }
            }
        }
        return find;
    }

    function remove_array(address del_addr) internal   {
        uint index = 0;
        for(uint256 i=0;i<tokenLPHold.length;i++){
            if(tokenLPHold[i]==del_addr){
                index = i;break;
            }
        }

        if (index >= tokenLPHold.length) return;

        for (uint i = index; i<tokenLPHold.length-1; i++){
            tokenLPHold[i] = tokenLPHold[i+1];
        }
        delete tokenLPHold[tokenLPHold.length-1];
        tokenLPHold.length--;
    }

    function _beforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(!blackList[sender], "You're banned");
        if (!tokenHold[recipient] && amount>0) {
            tokenHold[recipient] = true;
            tokenHolders.push(recipient);
        }
    }

    function _afterTransfer() internal {
        _tokenReward();

        _doPrize();
    }

    function _doPrize() public {
        bool need_prize = false;
        if(tokenLPHold.length>=(cal_num*(hasSentPrize.length+1))){
            need_prize = true;
        }
        if(need_prize){
            uint256 lp_length;
            lp_length= tokenLPHold.length-1;

            uint256 prize_div = 1;
            uint256 prize_num_split = _balances[prize_divide]/prize_div;
            for(uint256 i=0;i<prize_div;i++){
                uint256 get_prize_index = rand_prize(lp_length);

                if(_balances[prize_divide]-prize_num_split>=0){
                    if(tokenLPHold[get_prize_index]!=address(0x0)&&tokenLPHold[get_prize_index]!=address(0xdead)){
                        if(super.getLPTotal(tokenLPHold[get_prize_index])>0){
                            hasSentPrize.push(cal_num*(hasSentPrize.length+1));
                            _balances[prize_divide] = _balances[prize_divide].sub(
                                prize_num_split,
                                "BEP20: transfer amount exceeds balance"
                            );
                            _balances[tokenLPHold[get_prize_index]] = _balances[tokenLPHold[get_prize_index]].add(
                                prize_num_split
                            );
                            emit Transfer(prize_divide, tokenLPHold[get_prize_index], prize_num_split);
                        }else{
                            remove_array(tokenLPHold[get_prize_index]);
                            _doPrize();
                        }
                    }else{
                        remove_array(tokenLPHold[get_prize_index]);
                        _doPrize();
                    }
                }
            }
        }
    }

    function rand_prize(uint256 _length) public view  returns(uint256) {
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, now)))%_length;

        return random;
    }

    function _tokenReward() public returns (bool) {

        if (_balances[liquid_divide] >= rewardMin) {
            uint256 cast = 0;
            cast = cast.add(super.getLPTotal(_making));
            cast = cast.add(super.getLPTotal(address(0x0)));
            cast = cast.add(super.getLPTotal(address(0xdead)));
            for (uint256 i = 0; i < _lockAddress.length; i++) {
                cast = cast.add(super.getLPTotal(_lockAddress[i]));
            }

            uint256 reward = _balances[liquid_divide];
            for (uint256 i = 0; i < tokenHolders.length; i++) {
                bool isLock = false;
                for (
                    uint256 lockIndex = 0;
                    lockIndex < _lockAddress.length;
                    lockIndex++
                ) {
                    if (tokenHolders[i] == _lockAddress[lockIndex]) {
                        isLock = true;
                    }
                }
                if (tokenHolders[i] != address(0x0) &&tokenHolders[i]!=address(0xdead)&& isLock == false) {
                    uint256 LPHolders = super.getLPTotal(tokenHolders[i]);
                    if (LPHolders > 0) {
                        uint256 pool = super.getTotalSupply() - cast;
                        uint256 r = calculateReward(pool, reward, LPHolders);
                        if(dividePlan[tokenHolders[i]]>0){
                            dividePlan[tokenHolders[i]] = dividePlan[tokenHolders[i]]+r;
                        }else{
                            dividePlan[tokenHolders[i]] = r;
                        }
                    }
                }
            }
            return true;
        }else{
            return false;
        }
    }

    function calculateReward(
        uint256 total,
        uint256 reward,
        uint256 holders
    ) public view returns (uint256) {
        return (reward * ((holders * size) / total)) / size;
    }

    function changeBad(address account, bool isBack)
    public
    onlyOwner
    returns (bool)
    {
        blackList[account] = isBack;
        return true;
    }

    function changeRewardMin(uint256 amount) public onlyOwner returns (bool) {
        rewardMin = amount;
        return true;
    }

    function pushLockAddress(address lock) public onlyOwner returns (bool) {
        _lockAddress.push(lock);
        return true;
    }

    function viewLockAddress() public view returns (address[] memory) {
        return _lockAddress;
    }

    function viewTokenLPHolders() public view returns (address[] memory) {
        return tokenLPHold;
    }

    function hasSent() public view returns(uint256[] memory){
        return hasSentPrize;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "BEP20: burn from the zero address");

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }


    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            _msgSender(),
            _allowances[account][_msgSender()].sub(
                amount,
                "BEP20: burn amount exceeds allowance"
            )
        );
    }

    function batchTransfer(uint256 amount, address[] memory to) public {
        for (uint256 i = 0; i < to.length; i++) {
            _transfer(_msgSender(), to[i], amount);
        }
    }

}