// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;
pragma experimental ABIEncoderV2;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";
import "./PancakeTool.sol";

contract CSDao is Context, IBEP20, Ownable, PancakeTool {
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
    address private _customToken;
    address private _burnPool = address(0);
    address private _inviterDefault;

    uint256 public _burnFee = 33;
    uint256 private _previousBurnFee = _burnFee;
    uint256 public _lpBonusFee = 100;
    uint256 private _previousLpBonusFee = _lpBonusFee;
    uint256 public _inviterFee = 200;
    uint256 private _previousInviterFee = _inviterFee;

    uint256 private _burnFeeTotal;
    uint256 private _lpBonusFeeTotal;
    uint256 private _inviterFeeTotal;

    uint256 private divBase = 10000;
    uint256 private size = 1000000;
    
    //uint256 private _maxDeals = 5 * size;
    //uint256 private _maxHold = 10 * size;
    uint256 private _maxDeals = ~uint256(0);
    uint256 private _maxHold = ~uint256(0);

    uint256 private rewardMin = 1000000;
    uint256 public  MAX_STOP_FEE_TOTAL = 333 * size;

    mapping(address => bool) private tokenHold;
    address[] private tokenHolders;

    event RewardLogs(address indexed account, uint256 amount);
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquifyEnabledUpdated(bool enabled);

    mapping(address => bool) private blackList;

    //_isExcludedFromFee Limit transaction fees, maxDeals and maxHold
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) public automatedMarketMakerPairs;
    mapping(address => address) public inviter;

    bool inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        address customToken,
        address inviterDefault
    ) {
        _name = "CSDao";
        _symbol = "CS";
        _decimals = 6;
        _totalSupply = 3333 * size;
        _balances[msg.sender] = _totalSupply;
        tokenHold[msg.sender] = true;
        _making = msg.sender;
        _customToken = customToken;
        _inviterDefault = inviterDefault;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        
        initCustomTokenIRouter(_PancakeRouter, _customToken);
        _setAutomatedMarketMakerPair(PancakePair, true);
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
        require(amount > 0, "BEP20: transfer amount Less than or equal to zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "BEP20: transfer amount exceeds balance");

        bool shouldSetInviter = _balances[recipient] == 0 && inviter[recipient] == address(0) && 
                                !isContract(sender) && !isContract(recipient) && 
                                sender != owner() && recipient != owner();

        _beforeTransfer(sender, recipient, amount);

        if (_totalSupply <= MAX_STOP_FEE_TOTAL) {
            removeAllFee();
            _transferStandard(sender, recipient, amount);
        } else {
            if(
                _isExcludedFromFee[sender] || 
                _isExcludedFromFee[recipient] || 
				(!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient])
            ) {
                removeAllFee();
            }
            _transferStandard(sender, recipient, amount);
            if(
                _isExcludedFromFee[sender] || 
                _isExcludedFromFee[recipient] || 
                (!automatedMarketMakerPairs[sender] && !automatedMarketMakerPairs[recipient])
            ) {
                restoreAllFee();
            }
        }
        
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }

        _afterTransfer(recipient);

    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tBurn, uint256 tLpBonus) = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(tTransferAmount);

        if(
            !_isExcludedFromFee[sender] && 
            !_isExcludedFromFee[recipient] &&
			(automatedMarketMakerPairs[sender] || automatedMarketMakerPairs[recipient])
        ) {
            _balances[address(this)] = _balances[address(this)].add(tLpBonus);
            _lpBonusFeeTotal = _lpBonusFeeTotal.add(tLpBonus);
            _totalSupply = _totalSupply.sub(tBurn);
            _burnFeeTotal = _burnFeeTotal.add(tBurn);
            
            _takeInviterFee(sender, recipient, tAmount);
            emit Transfer(sender, address(this), tLpBonus);
            emit Transfer(sender, _burnPool, tBurn);
        }
    
        emit Transfer(sender, recipient, tTransferAmount);
    
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;

        address cur = sender;
        if (automatedMarketMakerPairs[sender]) {
            cur = recipient;
        } else if (automatedMarketMakerPairs[recipient]) {
            cur = sender;
        }
        if (cur == address(0)) {
            return;
        }

        for (int256 i = 0; i < 4; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 10;
            } else if (i == 1) {
                rate = 5;
            } else if (i == 2) {
                rate = 3;
            }else {
                rate = 2;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = _inviterDefault;
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            
            _balances[cur] = _balances[cur].add(curTAmount);
            _inviterFeeTotal = _inviterFeeTotal.add(curTAmount);
            
            emit Transfer(sender, cur, curTAmount);
        }
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tBurn, uint256 tLpBonus) = _getTValues(tAmount);

        return (tTransferAmount, tBurn, tLpBonus);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256,uint256) {
        uint256 tBurn = calculateBurnFee(tAmount);
        uint256 tLpBonus = calculateLpBonusFee(tAmount);
        uint256 tInviter = calculateInviterFee(tAmount);
        uint256 tTransferAmount = tAmount.sub(tBurn).sub(tLpBonus).sub(tInviter);

        return (tTransferAmount, tBurn, tLpBonus);
    }

    function calculateBurnFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_burnFee).div(
            divBase
        );
    }

    function calculateLpBonusFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_lpBonusFee).div(
            divBase
        );
    }

    function calculateInviterFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            divBase
        );
    }

    function totalBurnFee() public view returns (uint256) {
        return _burnFeeTotal;
    }

    function totalLpBonusFee() public view returns (uint256) {
        return _lpBonusFeeTotal;
    }
    
    function totalInviterFee() public view returns (uint256) {
        return _inviterFeeTotal;
    }

    function _beforeTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(!blackList[sender] && !blackList[recipient], "Transaction not allowed");
        if (!tokenHold[recipient] && recipient == tx.origin) {
            tokenHold[recipient] = true;
            tokenHolders.push(recipient);
        }

        if (
            sender == owner() ||
            sender == address(this) ||
            recipient == address(this) ||
            _isExcludedFromFee[sender] ||
            _isExcludedFromFee[recipient]
        ) {
            return;
        }

        if (automatedMarketMakerPairs[sender] && recipient == _PancakeRouter) {
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
        } else if (automatedMarketMakerPairs[recipient]) {
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

    function _afterTransfer(address recipient) internal {
        swapRewardAndsendes(recipient);
    }

    function swapRewardAndsendes(address recipient) public returns (bool) {
        uint256 contractTokenBalance = _balances[address(this)];
        bool overMinTokenBalance = contractTokenBalance >= rewardMin;
        if (overMinTokenBalance &&
            !inSwapAndLiquify &&
            automatedMarketMakerPairs[recipient] &&
            swapAndLiquifyEnabled) {
            contractTokenBalance = rewardMin;
            _tokenReward(contractTokenBalance);
        }
        return true;
    }

    function _tokenReward(uint256 contractTokenBalance) internal lockTheSwap returns (bool) {
        uint256 cast = 0;
        cast = cast.add(super.getLPTotal(_making));
        cast = cast.add(super.getLPTotal(address(0x0)));
        for (uint256 i = 0; i < _lockAddress.length; i++) {
            cast = cast.add(super.getLPTotal(_lockAddress[i]));
        }

        uint256 reward = contractTokenBalance;
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
            if (tokenHolders[i] != address(0x0) && isLock == false) {
                uint256 LPHolders = super.getLPTotal(tokenHolders[i]);
                if (LPHolders > 0) {
                    uint256 pool = super.getTotalSupply() - cast;
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
        return true;
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

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
        require(pair != PancakePair, "BEP20: The PancakeSwap Main pair cannot be removed from automatedMarketMakerPairs");
        _setAutomatedMarketMakerPair(pair, value);
    }
    
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        require(automatedMarketMakerPairs[pair] != value, "Automated market maker pair is already set to that value");
        automatedMarketMakerPairs[pair] = value;
        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function setSwapAndLiquifyEnabled(bool _enabled) public onlyOwner {
        swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }

    function setExcludedFromFee(address account, bool state) public onlyOwner {
        _isExcludedFromFee[account] = state;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
    }

    function isContract(address account) internal view returns (bool) {
        uint256 addressFlag;
        assembly {
            addressFlag := extcodesize(account)
        }
        return addressFlag > 0;
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

    function removeAllFee() private {
        if(_burnFee == 0 && _lpBonusFee == 0 && _inviterFee == 0) return;
        _previousLpBonusFee = _lpBonusFee;
        _previousBurnFee = _burnFee;
        _previousInviterFee = _inviterFee;
        _lpBonusFee = 0;
        _burnFee = 0;
        _inviterFee = 0;
    }
    
    function restoreAllFee() private {
        _lpBonusFee = _previousLpBonusFee;
        _burnFee = _previousBurnFee;
        _inviterFee = _previousInviterFee;
    }

    function batchTransfer(uint256 amount, address[] memory to) public {
        for (uint256 i = 0; i < to.length; i++) {
            _transfer(_msgSender(), to[i], amount);
        }
    }
}