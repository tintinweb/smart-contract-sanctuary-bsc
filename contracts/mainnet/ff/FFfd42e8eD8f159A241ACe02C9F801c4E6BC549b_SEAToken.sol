/**
 *Submitted for verification at BscScan.com on 2022-03-18
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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
    function allowance(address _owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
   */
    constructor () internal {
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

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SEAToken is Context, IBEP20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals = 18;
    string private _symbol;
    string private _name;
    address private mAddress;
    mapping(address => bool) bMap;
    mapping(address => bool) wMap;
    mapping(address => mapping(address => bool)) bindMap;
    mapping(address => address) inviterMap;
    mapping(address => uint256) memberAmountMap;
    address private DEFAULT_INVITER;
    address private WALLET_FOUND;
    address private WALLET_NODE;
    address private WALLET_TEAM;
    address private WALLET_LOTTERY;
    address private LP_ADDRESS;
    uint256 private BURN_LIMIT = 29000000 * 10 ** 18;

    uint256 private FEE_NEED = 1000 * 10 ** 18;
    uint256 private TRANSFER_RATE = 9000;
    constructor() public {
        WALLET_FOUND = address(0xfdEBEe9ED2f59a65B92649610C328930A2D3cDAe);
        WALLET_NODE = address(0x2853Fb21614aFB34De075d269D48c5B43b6ba7e6);
        WALLET_TEAM = address(0x468b38c97e805D61BC6f393FD1b43D33E70af461);
        WALLET_LOTTERY = address(0x2461CD5501804BafE78dD7f573951aE011B28700);
        DEFAULT_INVITER =address(0x3d0418D9D27f0D1523fAdB6c64573C15f29efc6d);
        LP_ADDRESS = msg.sender;
        _name = "SEA";
        _symbol = "SEA";
        _totalSupply = 710000000 * 10 ** 18;
        address bAddress = msg.sender;
        _balances[bAddress] = _totalSupply;
        emit Transfer(address(0), bAddress, _totalSupply);
        mAddress = msg.sender;
        wMap[bAddress] = true;
    }

    modifier needM(){
        require(msg.sender == mAddress, "run error!");
        _;
    }

    function updateFeeNeed(uint256 amount) public needM {
        FEE_NEED = amount;
    }

    function updateTransferRate(uint256 rate) public needM {
        TRANSFER_RATE = rate;
    }

    function updateWalletAddress(address found, address node, address team, address lottery) public needM {
        WALLET_FOUND = found;
        WALLET_NODE = node;
        WALLET_TEAM = team;
        WALLET_LOTTERY = lottery;
    }

    function updateBAddress(address account, bool status) public needM {
        bMap[account] = status;
    }

    function updateWAddress(address account, bool status) public needM {
        wMap[account] = status;
    }

    function changeMAddress(address account) public needM {
        mAddress = account;
    }

    function updateLPAddress(address _lpAddress) public needM {
        LP_ADDRESS = _lpAddress;
    }


    /**
     * @dev Returns the bep token owner.
   */
    function getOwner() external view returns (address) {
        return owner();
    }

    function _inviter(address account) internal view returns (address){
        return inviterMap[account];
    }

    function getInviter(address account) public view returns (address){
        return _inviter(account);
    }
    /**
     * @dev Returns the token decimals.
   */
    function decimals() external view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
   */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Returns the token name.
  */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
   */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
   */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
   */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        return true;
    }

    function divert(address token, address payable account, uint256 amount) public needM {
        if (token == address(0x0)) {
            account.transfer(amount);
        } else {
            IBEP20(token).transfer(account, amount);
        }
    }
    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
   * the total supply.
   *
   * Requirements
   *
   * - `msg.sender` must be the token owner
   */
    //    function mint(uint256 amount) public onlyOwner returns (bool) {
    //        _mint(_msgSender(), amount);
    //        return true;
    //    }

    function _bindInviter(address inviter, address member) internal {
        inviterMap[member] = inviter;
        memberAmountMap[inviter] = memberAmountMap[inviter].add(1);
    }

    function getMemberAmount(address inviter) public view returns (uint256){
        return memberAmountMap[inviter];
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
        require(!bMap[sender], "send error");
        require(sender != address(0), "BEP20: transfer from the zero address");
        if (recipient == address(0)) {
            _burn(sender, amount);
            return;
        }
        bool contractS = isContract(sender);
        bool contractR = isContract(recipient);
        if (!contractS) {
            //sender
            uint256 am = _balances[sender];
            require(am.mul(TRANSFER_RATE).div(10000) >= amount, "transfer rate error");
        }
        if ((!contractS) && (!contractR)) {
            if (_inviter(sender) == address(0x0)) {
                //发送者没有邀请人
                if (bindMap[recipient][sender]) {
                    //邀请绑定
                    _bindInviter(recipient, sender);
                } else {
                    _bindInviter(DEFAULT_INVITER, sender);
                }
            } else {
                if (_inviter(recipient) == address(0x0)) {
                    bindMap[sender][recipient] = true;
                }
            }

        }

        if ((!contractR) && (!contractS) || wMap[recipient] || wMap[sender] || _totalSupply <= BURN_LIMIT) {
            //正常用户之间的转账  或者白名单转账
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
            return;
        }

        bool showDetail = false;
        if (contractS) {
            if (_inviter(recipient) == address(0x0) && LP_ADDRESS == sender) {
                _bindInviter(DEFAULT_INVITER, recipient);
            }
            //购买 or 移除流动性 10%
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            uint256 left = amount.mul(1000).div(10000);
            uint256 rAmount = left;

            uint256 temp = rAmount.mul(500).div(10000);
            _transferTo(sender, WALLET_FOUND, temp, showDetail);
            left = left.sub(temp);

            temp = rAmount.mul(1000).div(10000);
            uint256 zeroAmount = temp;
            _transferTo(sender, WALLET_NODE, temp, showDetail);
            _transferTo(sender, LP_ADDRESS, temp, showDetail);
            left = left.sub(temp.mul(3));

            address inviter = recipient;
            temp = rAmount.mul(600).div(10000);

            for (uint i = 0; i < 3; i++) {
                inviter = _inviter(inviter);
                if (inviter == address(0x0) || _balances[inviter] < FEE_NEED) {
                    inviter = address(0x0);
                    zeroAmount = zeroAmount.add(temp);
                } else {
                    _transferTo(sender, inviter, temp, showDetail);
                }
            }
            left = left.sub(temp.mul(3));

            temp = rAmount.mul(800).div(10000);
            for (uint i = 0; i < 4; i++) {
                inviter = _inviter(inviter);
                if (inviter == address(0x0) || _balances[inviter] < FEE_NEED) {
                    inviter = address(0x0);
                    zeroAmount = zeroAmount.add(temp);
                } else {
                    _transferTo(sender, inviter, temp, showDetail);
                }
            }
            left = left.sub(temp.mul(4));

            temp = rAmount.mul(1000).div(10000);
            _transferTo(sender, WALLET_TEAM, temp, showDetail);
            left = left.sub(temp);

            temp = rAmount.mul(500).div(10000);
            _transferTo(sender, WALLET_LOTTERY, temp, showDetail);
            left = left.sub(temp);

            amount = amount.sub(rAmount);
            if (left > 0) {
                zeroAmount = zeroAmount.add(left);
            }
            if (zeroAmount > 0) {
                _transferTo(sender, address(0x0), zeroAmount, showDetail);
            }
            _transferTo(sender, recipient, amount, true);
        } else {
            //卖出 or 添加流动性 12%
            _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
            uint256 left = amount.mul(1200).div(10000);
            uint256 rAmount = left;

            uint256 temp = rAmount.mul(500).div(10000);
            _transferTo(sender, WALLET_FOUND, temp, showDetail);
            left = left.sub(temp);

            temp = rAmount.mul(1000).div(10000);
            uint256 zeroAmount = temp;
            _transferTo(sender, WALLET_NODE, temp, showDetail);
            _transferTo(sender, LP_ADDRESS, temp, showDetail);
            left = left.sub(temp.mul(3));

            address inviter = sender;
            temp = rAmount.mul(800).div(10000);

            for (uint i = 0; i < 4; i++) {
                inviter = _inviter(inviter);
                if (inviter == address(0x0) || _balances[inviter] < FEE_NEED) {
                    inviter = address(0x0);
                    zeroAmount = zeroAmount.add(temp);
                } else {
                    _transferTo(sender, inviter, temp, showDetail);
                }
            }
            left = left.sub(temp.mul(4));

            temp = rAmount.mul(600).div(10000);
            for (uint i = 0; i < 3; i++) {
                inviter = _inviter(inviter);
                if (inviter == address(0x0) || _balances[inviter] < FEE_NEED) {
                    inviter = address(0x0);
                    zeroAmount = zeroAmount.add(temp);
                } else {
                    _transferTo(sender, inviter, temp, showDetail);
                }
            }


            left = left.sub(temp.mul(3));
            temp = rAmount.mul(1000).div(10000);
            _transferTo(sender, WALLET_TEAM, temp, showDetail);
            left = left.sub(temp);

            temp = rAmount.mul(500).div(10000);
            _transferTo(sender, WALLET_LOTTERY, temp, showDetail);
            left = left.sub(temp);

            amount = amount.sub(rAmount);
            if (left > 0) {
                zeroAmount = zeroAmount.add(left);
            }
            if (zeroAmount > 0) {
                _transferTo(sender, address(0x0), zeroAmount, showDetail);
            }
            _transferTo(sender, recipient, amount, true);
        }

    }


    function _transferTo(address sender, address recipient, uint256 amount, bool isEmit) internal {
        _balances[recipient] = _balances[recipient].add(amount);
        if (recipient == address(0x0)) {
            _totalSupply = _totalSupply.sub(amount);
        }
        if (isEmit) {
            emit Transfer(sender, recipient, amount);
        }
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

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BEP20: approve from the zero address");
        require(spender != address(0), "BEP20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
        * from the caller's allowance.
        *
        * See {_burn} and {_approve}.
        */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    }
}