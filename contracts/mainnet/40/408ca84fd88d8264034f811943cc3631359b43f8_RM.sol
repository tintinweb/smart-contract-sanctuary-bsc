// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./PancakeTool.sol";

contract RM is Context, IBEP20, Ownable, PancakeTool {
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

    uint8 private _cPercent = 5;

    uint256 private divBase = 100;
    uint256 private size = 1000000000000000000;

    uint256 private _maxDeals = 5 * size;
    uint256 private _maxHold = 10 * size;

    uint256 private rewardMin = 10000000000000000000;

    mapping(address => bool) private tokenHold;
    address[] private tokenHolders;

    event RewardLogs(address indexed account, uint256 amount);

    mapping(address => bool) private blackList;

    constructor() public {
        _name = "RM Token";
        _symbol = "RM";
        _decimals =18;
        _totalSupply = 1314 * size;
        _balances[msg.sender] = _totalSupply;
        tokenHold[msg.sender] = true;
        _making = msg.sender;

        initIRouter(_PancakeRouter);
        _approve(address(this), _PancakeRouter, ~uint256(0));
        _approve(owner(), _PancakeRouter, ~uint256(0));
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override  returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) external view override returns (uint256) {
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

    //The token pancake  5%
    //Increased liquidity and transaction number is 5
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
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

    /**
     * @dev Burn `amount` tokens and decreasing the total supply.
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
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
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _beforeTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "BEP20: transfer amount exceeds balance"
        );

        uint256 _cFee = 0;
        if (sender != owner()) {
            _cFee = (amount / divBase) * _cPercent;
            _balances[address(this)] = _balances[address(this)].add(_cFee);
            emit Transfer(sender, address(this), _cFee);
        }

        _balances[recipient] = _balances[recipient].add(
            amount - _cFee
        );
        emit Transfer(sender, recipient, amount - _cFee);

        _afterTransfer();
    }

    function _beforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(!blackList[sender], "You're banned");
        if (!tokenHold[recipient] && recipient == tx.origin) {
            tokenHold[recipient] = true;
            tokenHolders.push(recipient);
        }

        if (
            sender == owner() ||
            sender == address(this) ||
            recipient == address(this)
        ) {
            return;
        }

        if (sender == PancakePair && recipient == _PancakeRouter) {
            uint256 aBalance = _balances[recipient] + amount;
            require(
                aBalance <= _maxHold,
                "The maximum number of holdings is 10"
            );
        } else if (sender == _PancakeRouter) {
            uint256 aBalance = _balances[recipient] + amount;
            require(
                aBalance <= _maxHold,
                "The maximum number of holdings is 10"
            );
        } else if (recipient == PancakePair) {
            require(amount <= _maxDeals, "The maximum number of deals is 5");
        } else {
            require(amount <= _maxDeals, "The maximum number of deals is 5");
            uint256 aBalance = _balances[recipient] + amount;
            require(
                aBalance <= _maxHold,
                "The maximum number of holdings is 10"
            );
        }

    }

    function _afterTransfer() internal {
        swapRewardAndsendes();
    }

    function swapRewardAndsendes() public returns (bool) {
        if (_balances[address(this)] >= rewardMin) {
            _tokenReward();
        }
        return true;
    }

    //以下计算公式中抛去了营销地址和合约地址,这意味着所有的分红代币将全部公平公正的分配到每一个普通用户手上
    function _tokenReward() internal returns (bool) {
        //需要抛出的Pool数量
        uint256 cast = 0;
        cast = cast.add(super.getLPTotal(_making));
        cast = cast.add(super.getLPTotal(address(0x0)));
        for (uint256 i = 0; i < _lockAddress.length; i++) {
            cast = cast.add(super.getLPTotal(_lockAddress[i]));
        }
        //获取当前合约可以进行分红的代币数量
        uint256 reward = _balances[address(this)];
        //进行循环过滤不符合条件的地址
        for (uint256 i = 0; i < tokenHolders.length; i++) {
            //如果为普通地址
            bool isLock = false;
            //如果等于锁池子的地址
            for (
                uint256 lockIndex = 0;
                lockIndex < _lockAddress.length;
                lockIndex++
            ) {
                if (tokenHolders[i] == _lockAddress[lockIndex]) {
                    isLock = true;
                }
            }
            //如果不是0地址并且也不是锁定池子地址 则可以分红
            if (tokenHolders[i] != address(0x0) && isLock == false) {
                //获取当前地址的LP数量
                uint256 LPHolders = super.getLPTotal(tokenHolders[i]);
                //如果LP持有数量大于0
                if (LPHolders > 0) {
                    //计算当前池子中不包括营销地址、LP锁定地址的LP数量总和
                    uint256 pool = super.getTotalSupply() - cast;
                    //按照当前地址在池子中所占百分比进行分配分红代币
                    uint256 r = calculateReward(pool, reward, LPHolders);
                    _balances[address(this)] = _balances[address(this)].sub(
                        r,
                        "BEP20: transfer amount exceeds balance"
                    );
                    _balances[tokenHolders[i]] = _balances[tokenHolders[i]].add(
                        r
                    );
                    emit Transfer(address(this), tokenHolders[i], r);
                    emit RewardLogs(tokenHolders[i], r);
                }
            }
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

    function viewTokenHolders() public view returns (address[] memory) {
        return tokenHolders;
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

        _balances[account] = _balances[account].sub(
            amount,
            "BEP20: burn amount exceeds balance"
        );
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

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
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