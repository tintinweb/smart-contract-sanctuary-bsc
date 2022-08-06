// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

import "./IBEP20.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./IPancakePair.sol";

contract VRMCToken is Ownable, IBEP20 {
    using Address for address;

    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    mapping(address => bool) _whitelist;

    string _name = "VRMetaCenter";
    string _symbol = "VRMC";
    uint8 _decimals = 18;
    uint256 _totalSupply = 1000000000000 * (10 ** _decimals);

    address constant BURN = 0xB7a1D12F469D273Cd19343C43BAEEA2BbDA18ce9;
    address public marketingFeeReceiver;
    address public VrmcFeeReceiver;
    uint256 totalFee = 10;
    uint256 marketingFee = 6;
    uint256 burnFee = 2;
    uint256 buyVrmcFee = 2;
    uint256 sellVrmcFee = 2;
    uint256 feeDenominator = 100;

    constructor(address marketingFeeAddress, address VrmcFeeAddress) {
        marketingFeeReceiver = marketingFeeAddress;
        VrmcFeeReceiver = VrmcFeeAddress;
        _whitelist[_msgSender()] = true;
        _balances[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    /**
     * @dev Returns the bep20 token owner.
     */
    function getOwner() external view override returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
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
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
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
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][recipient] - amount);
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
    function increaseAllowance(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + amount);
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
    function decreaseAllowance(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] - amount);
        return true;
    }

    /**
     * @dev Burns `amount` tokens and assigns them to `msg.sender`, decreasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function burn(uint256 amount) external onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }

    /**
     * @dev Burns `amount` tokens and assigns them to `from`, decreasing
     * the total supply.
     *
     * Requirements
     *
     * - `from` cannot be the zero address.
     */
    function burnFrom(address from, uint256 amount) external onlyOwner returns (bool) {
        _burnFrom(from, amount);
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
        require(sender != address(0), "BEP20: transfer from the zero address");
        require(recipient != address(0), "BEP20: transfer to the zero address");

        _balances[sender] -= amount;
        uint256 amountReceived = _takeFee(sender, recipient, amount);
        _balances[recipient] += amountReceived;
        emit Transfer(sender, recipient, amountReceived);
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

        _totalSupply += amount;
        _balances[account] += amount;
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

        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _approve(account, _msgSender(), _allowances[account][_msgSender()] - amount);
        _burn(account, amount);
    }

    /**
     * @dev Takes fee out from transfer `amount`.
     */
    function _takeFee(address sender, address receiver, uint256 amount) internal returns (uint256) {
        if(_whitelist[sender])
            return amount;

        // distribute fee when to buy token in PancakeSwap
        if(sender.isContract() && keccak256(bytes(IPancakePair(sender).symbol())) == keccak256(bytes("Cake-LP"))) {
            if(IPancakePair(sender).token0() == address(this) || IPancakePair(sender).token1() == address(this)) {
                uint256 marketingFeeAmount = amount * marketingFee / feeDenominator;
                _balances[marketingFeeReceiver] += marketingFeeAmount;
                emit Transfer(sender, marketingFeeReceiver, marketingFeeAmount);

                uint256 VrmcFeeAmount = amount * buyVrmcFee / feeDenominator;
                _balances[VrmcFeeReceiver] += VrmcFeeAmount;
                emit Transfer(sender, VrmcFeeReceiver, VrmcFeeAmount);

                return amount * (feeDenominator - totalFee) / feeDenominator;
            }
        }

        // distribute fee when to sell token in PancakeSwap
        if(receiver.isContract() && keccak256(bytes(IPancakePair(receiver).symbol())) == keccak256(bytes("Cake-LP"))) {
            if(IPancakePair(receiver).token0() == address(this) || IPancakePair(receiver).token1() == address(this)) {
                uint256 marketingFeeAmount = amount * marketingFee / feeDenominator;
                _balances[marketingFeeReceiver] += marketingFeeAmount;
                emit Transfer(sender, marketingFeeReceiver, marketingFeeAmount);

                uint256 burnFeeAmount = amount * burnFee / feeDenominator;
                _balances[BURN] += burnFeeAmount;
                emit Transfer(sender, BURN, burnFeeAmount);

                uint256 VrmcFeeAmount = amount * sellVrmcFee / feeDenominator;
                _balances[VrmcFeeReceiver] += VrmcFeeAmount;
                emit Transfer(sender, VrmcFeeReceiver, VrmcFeeAmount);

                return amount * (feeDenominator - totalFee) / feeDenominator;
            }
        }

        return amount;
    }

    /**
     * @dev Sets marketing fee receiver.
     */
    function setMarketingFeeReceiver(address account) external onlyOwner {
        marketingFeeReceiver = account;
    }

    /**
     * @dev Sets smart fee receiver.
     */
    function setVrmcFeeReceiver(address account) external onlyOwner {
        VrmcFeeReceiver = account;
    }

    /**
     * @dev Excludes account from fee.
     */
    function excludeFromFee(address account) external onlyOwner {
        _whitelist[account] = true;
    }
}