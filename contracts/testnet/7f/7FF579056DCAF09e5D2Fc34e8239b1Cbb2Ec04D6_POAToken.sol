// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC20/ERC20.sol";
import "./utils/Owner.sol";
import "./utils/SafeMath.sol";

contract POAToken is ERC20, Owner {
    using SafeMath for uint256;

    mapping(address => Unlock[]) public frozenAddress;
    mapping(address => uint256) public unlock_amount_transfered;
    struct Unlock {
        uint256 unlock_time;
        uint256 amount;
    }

    mapping (address => bool) private privateSaleList;
    mapping (address => bool) private _isExcludedFromFee;
    uint8 private constant _decimals = 9;

    // properties used to get fee
    uint256 private constant amountDivToGetFee = 10**4;

    uint256 private constant minAditionalFee_1 = 8100 * 10**9;
    uint256 private constant minAditionalFee_2 = 16200 * 10**9;
    uint256 private constant minAditionalFee_3 = 24300 * 10**9;
    uint256 private constant minAditionalFee_4 = 40500 * 10**9;
    uint256 private constant minAditionalFee_5 = 64800 * 10**9;

    uint256 private constant amountMulToGetAditionalFee_1 = 300;
    uint256 private constant amountMulToGetAditionalFee_2 = 600;
    uint256 private constant amountMulToGetAditionalFee_3 = 900;
    uint256 private constant amountMulToGetAditionalFee_4 = 1800;
    uint256 private constant amountMulToGetAditionalFee_5 = 2700;

    //ECONOMY wallet = TEAM wallet
    uint256 public liquidityFeePercentage = 200; // 200 = 2%
    uint256 public economyFeePercentage = 100; // 100 = 1%
    uint256 public burnFeePercentage = 10; // 10 = 0.1%
    uint256 public stakeFeePercentage = 100; // 100 = 1%
    uint256 public privateSaleFeePercentage = 5000; // 5000 = 50%
    // fees wallets
    address public constant liquidityWallet = 0x9Ea860895F9d4A17cF585CC67B1b91D5525610cd;
    address public constant economyWallet = 0x421440AC44F90B453315De846eDd973Bc9F90c41;
    address public constant aditionalFeeWallet = 0x41f68b95F69a714Cd73598FefbDA4b451FD854c1;
    address public constant stakeFeeWallet = 0x6894Ff91256D6d2F6629c6C50D2B9b2F97D43fd3;

    // tokenomics wallets
    address public constant liquidity_wallet = 0x12B0b891786006cE8e4029D6A09De53C175cf8b6;
    address public constant rewards_wallet = 0x21921f4295A1a5bafE65ee74a5b4dC4400075cD9;
    address public constant privateSale_wallet = 0x4026E5b1D16629DCE70fedbD6347921EFfcBeBFE;
    address public constant publicSale_wallet = 0x94689E32EcbE5bE78cE67a70Aa9EA91Be2A3bB25;
    address public constant airdrop_wallet = 0x0bd27D24a4e577378f9dc5252c1CA68805324B20;
    address public constant marketing_wallet = 0x202eE6bC3e581772AF4bcecb4C282552177E3B41;
    address public constant devTeam_wallet = 0x39DAbe92281Cd5E8e5684B388dac244710c7C601;

    // tokenomics supply
    uint public constant liquidity_supply = 1620000 * 10**9;
    uint public constant rewards_supply = 4050000 * 10**9;
    uint public constant privateSale_supply = 450000 * 10**9;
    uint public constant publicSale_supply = 1350000 * 10**9;
    uint public constant airdrop_supply = 90000 * 10**9;
    uint public constant marketing_supply = 180000 * 10**9;
    uint public constant devTeam_supply = 1260000 * 10**9;
    
    event SetLiquidityFee(uint256 oldValue, uint256 newValue);
    event SetEconomyFee(uint256 oldValue, uint256 newValue);
    event SetStakeFee(uint256 oldValue, uint256 newValue);
    event SetPrivateSaleFee(uint256 oldValue, uint256 newValue);
    event SetBurnFee(uint256 oldValue, uint256 newValue);

    constructor() ERC20("BAHAMAS", "BAH") {
        // set tokenomics balances
        _mint(liquidity_wallet, liquidity_supply);
        _mint(rewards_wallet, rewards_supply);
        _mint(privateSale_wallet, privateSale_supply);
        _mint(publicSale_wallet, publicSale_supply);
        _mint(airdrop_wallet, airdrop_supply);
        _mint(marketing_wallet, marketing_supply);
        _mint(devTeam_wallet, devTeam_supply);

        // lock tokenomics balances
        // 2592000 = 30 days
        uint256 month_time = 2592000;

        // devTeam
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + 1, 63000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time), 189000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time * 2), 189000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time * 3), 189000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time * 4), 189000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time * 5), 189000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time * 6), 189000 * 10**9));
        frozenAddress[devTeam_wallet].push(Unlock(block.timestamp + (month_time * 7), 63000 * 10**9));
    }

    function decimals() public pure override returns (uint8) {
        return _decimals;
    }

    function isSenderBlockedForTransfer(address _account, uint256 _amount) private returns(bool){ // ===
        require(_account != address(0), "ERC20: isSenderBlockedForTransfer account the zero address"); // ===
        bool allowed_operation = false;
        uint256 amount_unlocked = 0;
        bool last_unlock_completed = false;
        if(frozenAddress[_account].length > 0){

            for(uint256 i=0; i<frozenAddress[_account].length; i++){
                if(block.timestamp >= frozenAddress[_account][i].unlock_time){
                    amount_unlocked = amount_unlocked.add(frozenAddress[_account][i].amount);
                }
                if(i == (frozenAddress[_account].length-1) && block.timestamp >= frozenAddress[_account][i].unlock_time){
                    last_unlock_completed = true;
                }
            }

            if(!last_unlock_completed){ // ===
                if(amount_unlocked.sub(unlock_amount_transfered[_account]) >= _amount){
                    allowed_operation = true;
                }else{
                    allowed_operation = false;
                }
            }else{
                allowed_operation = true;
            }

            if(allowed_operation){ // ===
                unlock_amount_transfered[_account] = unlock_amount_transfered[_account].add(_amount);
            }
        }else{
            allowed_operation = true;
        }

        return allowed_operation;
    }

    function excludeFromFee(address[] memory accounts) external isOwner { // ===
        for (uint256 i=0; i<accounts.length; i++) {
            if(_isExcludedFromFee[accounts[i]] == false){ // ===
                _isExcludedFromFee[accounts[i]] = true;
            }
        }
    }
    function includeInFee(address[] memory accounts) external isOwner { // ===
        for (uint256 i=0; i<accounts.length; i++) {
            _isExcludedFromFee[accounts[i]] = false;
        }
    }
    function isExcludedFromFee(address account) external view returns(bool) { // ===
        return _isExcludedFromFee[account];
    }

    function addToPrivateSaleList(address[] memory accounts) external isOwner { // ===
        for (uint256 i=0; i<accounts.length; i++) {
            privateSaleList[accounts[i]] = true;
        }
    }
    function removeToPrivateSaleList(address[] memory accounts) external isOwner { // ===
        for (uint256 i=0; i<accounts.length; i++) {
            if(privateSaleList[accounts[i]] == true){ // ===
                privateSaleList[accounts[i]] = false;
            }
        }
    }

    function modifyLiquidityFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 1000, "the new value should range from 0 to 1000");
        emit SetLiquidityFee(liquidityFeePercentage, _newVal);
        liquidityFeePercentage = _newVal;
    }

    function modifyEconomyFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 1000, "the new value should range from 0 to 1000");
        emit SetEconomyFee(economyFeePercentage, _newVal);
        economyFeePercentage = _newVal;
    }

    function modifyStakeFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 1000, "the new value should range from 0 to 1000");
        emit SetStakeFee(stakeFeePercentage, _newVal);
        stakeFeePercentage = _newVal;
    }

    function modifyPrivateSaleFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 5000, "the new value should range from 0 to 5000");
        emit SetPrivateSaleFee(privateSaleFeePercentage, _newVal);
        privateSaleFeePercentage = _newVal;
    }

    function modifyBurnFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 1000, "the new value should range from 0 to 1000");
        emit SetBurnFee(burnFeePercentage, _newVal);
        burnFeePercentage = _newVal;
    }

    function getLiquidityFee(uint256 _value) public view returns(uint256){
        return _value.mul(liquidityFeePercentage).div(amountDivToGetFee);
    }
    function getEconomyFee(uint256 _value) public view returns(uint256){
        return _value.mul(economyFeePercentage).div(amountDivToGetFee);
    }
    function getStakeFee(uint256 _value) public view returns(uint256){
        return _value.mul(stakeFeePercentage).div(amountDivToGetFee);
    }
    function getPrivateSaleFee(uint256 _value) public view returns(uint256){
        return _value.mul(privateSaleFeePercentage).div(amountDivToGetFee);
    }
    function getBurnFee(uint256 _value) public view returns(uint256){
        return _value.mul(burnFeePercentage).div(amountDivToGetFee);
    }
    
    function getAdditionalFee(uint256 _value) private pure returns(uint256){
        uint256 aditionalFee = 0;
        if(_value >= minAditionalFee_1){
            aditionalFee = _value.mul(amountMulToGetAditionalFee_1).div(amountDivToGetFee); // 300 = 3%
        }
        if(_value >= minAditionalFee_2){
            aditionalFee = _value.mul(amountMulToGetAditionalFee_2).div(amountDivToGetFee); // 600 = 6%
        }
        if(_value >= minAditionalFee_3){
            aditionalFee = _value.mul(amountMulToGetAditionalFee_3).div(amountDivToGetFee); // 900 = 9%
        }
        if(_value >= minAditionalFee_4){
            aditionalFee = _value.mul(amountMulToGetAditionalFee_4).div(amountDivToGetFee); // 1800 = 18%
        }
        if(_value >= minAditionalFee_5){
            aditionalFee = _value.mul(amountMulToGetAditionalFee_5).div(amountDivToGetFee); // 2700 = 27%
        }
        return aditionalFee;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(amount > 0, "ERC20: transfer amount must be greater than 0"); // ===
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        require(isSenderBlockedForTransfer(from, amount), "ERC20: the amount is greater than the amount available unlocked"); // ===
        
        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }else{
            _balances[liquidityWallet] += getLiquidityFee(amount);
            _balances[economyWallet] += getEconomyFee(amount);
            _balances[stakeFeeWallet] += getStakeFee(amount);

            if(privateSaleList[from]){
                _balances[aditionalFeeWallet] += getAdditionalFee(amount).add(getPrivateSaleFee(amount));
                uint256 valueToSend = amount.sub(getLiquidityFee(amount).add(getEconomyFee(amount)).add(getBurnFee(amount)).add(getAdditionalFee(amount)).add(getStakeFee(amount)).add(getPrivateSaleFee(amount)));
                _balances[to] += valueToSend;
                emit Transfer(from, to, valueToSend);
                emit Transfer(from, aditionalFeeWallet, getAdditionalFee(amount).add(getPrivateSaleFee(amount)));
            }else{
                _balances[aditionalFeeWallet] += getAdditionalFee(amount);
                _balances[to] += amount.sub(getLiquidityFee(amount).add(getEconomyFee(amount)).add(getBurnFee(amount)).add(getAdditionalFee(amount)).add(getStakeFee(amount)));
                emit Transfer(from, to, amount.sub(getLiquidityFee(amount).add(getEconomyFee(amount)).add(getBurnFee(amount)).add(getAdditionalFee(amount)).add(getStakeFee(amount))));
                emit Transfer(from, aditionalFeeWallet, getAdditionalFee(amount));
            }

            burnFee(from, getBurnFee(amount));
            emit Transfer(from, liquidityWallet, getLiquidityFee(amount));
            emit Transfer(from, economyWallet, getEconomyFee(amount));
            emit Transfer(from, stakeFeeWallet, getStakeFee(amount));
        }

        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _afterTokenTransfer(from, to, amount);
    }

    function _burn(address account, uint256 amount, bool update_balance) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        if(update_balance){ // ===
            _balances[account] = accountBalance.sub(amount);
        }
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burnFee(address account, uint256 amount) private {
        _burn(account, amount, false);
    }

    function burn(uint256 amount) external { // ===
        _burn(msg.sender, amount, true);
    }

    function burnFrom(address account, uint256 amount) external { // ===
        require(account != address(0), "ERC20: burn from the zero address"); // ===
        require(_allowances[account][msg.sender] >= amount, "ERC20: burn amount exceeds allowance");
        _allowances[account][msg.sender] = _allowances[account][msg.sender].sub(amount);
        _burn(account, amount, true);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

/**
 * @title Owner
 * @dev Set & change owner
 */
contract Owner {

    address private owner;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    // modifier to check if caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to Ether balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    /**
     * @dev Set contract deployer as owner
     */
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Change owner
     * @param newOwner address of new owner
     */
    function changeOwner(address newOwner) external isOwner { // ===
        require(newOwner != address(0), "ERC20: changeOwner newOwner the zero address"); // ===
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "./../utils/Context.sol";

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
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
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
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances; // === change from private to internal

    mapping(address => mapping(address => uint256)) internal _allowances; // === change from private to internal

    uint256 internal _totalSupply; // === change from private to internal

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}