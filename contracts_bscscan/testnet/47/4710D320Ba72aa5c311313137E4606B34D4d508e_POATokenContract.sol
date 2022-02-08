// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import "./2_Owner.sol";

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract POATokenContract is Owner {
    using SafeMath for uint256;
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    mapping(address => Unlock[]) public frozenAddress;
    mapping(address => uint256) public unlock_amount_transfered;
    struct Unlock {
        uint256 unlock_time;
        uint256 amount;
    }

    mapping (address => bool) private _isExcludedFromFee;
    uint public totalSupply = 9000000 * 10**9;
    string public constant name = "KALINDO";
    string public constant symbol = "KAL";
    uint public constant decimals = 9;
    //LIQUIDITY
    //ECONOMY wallet = TEAM wallet
    uint256 public liquidityFeePercentage = 200; // 200 = 2%
    uint256 public economyFeePercentage = 100; // 100 = 1%
    uint256 public burnFeePercentage = 10; // 10 = 0.1%
    uint256 public stakeFeePercentage = 100; // 100 = 1%
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
    event SetBurnFee(uint256 oldValue, uint256 newValue);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    
    constructor() {
        // set tokenomics balances
        balances[liquidity_wallet] = liquidity_supply;
        emit Transfer(address(0), liquidity_wallet, liquidity_supply);
        balances[rewards_wallet] = rewards_supply;
        emit Transfer(address(0), rewards_wallet, rewards_supply);
        balances[privateSale_wallet] = privateSale_supply;
        emit Transfer(address(0), privateSale_wallet, privateSale_supply);
        balances[publicSale_wallet] = publicSale_supply;
        emit Transfer(address(0), publicSale_wallet, publicSale_supply);
        balances[airdrop_wallet] = airdrop_supply;
        emit Transfer(address(0), airdrop_wallet, airdrop_supply);
        balances[marketing_wallet] = marketing_supply;
        emit Transfer(address(0), marketing_wallet, marketing_supply);
        balances[devTeam_wallet] = devTeam_supply;
        emit Transfer(address(0), devTeam_wallet, devTeam_supply);

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

    function checkFrozenAddress(address _account, uint256 _amount) private returns(bool){
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

            if(last_unlock_completed == false){
                if(amount_unlocked.sub(unlock_amount_transfered[_account]) >= _amount){
                    allowed_operation = true;
                }else{
                    allowed_operation = false;
                }
            }else{
                allowed_operation = true;
            }

            if(allowed_operation == true){
                unlock_amount_transfered[_account] = unlock_amount_transfered[_account].add(_amount);
            }
        }else{
            allowed_operation = true;
        }

        return allowed_operation;
    }

    function excludeFromFee(address account) public isOwner {
        _isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public isOwner {
        _isExcludedFromFee[account] = false;
    }
    function isExcludedFromFee(address account) public view returns(bool) {
        return _isExcludedFromFee[account];
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

    function modifyBurnFeePercentage(uint256 _newVal) external isOwner {
        require(_newVal <= 1000, "the new value should range from 0 to 1000");
        emit SetBurnFee(burnFeePercentage, _newVal);
        burnFeePercentage = _newVal;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function getLiquidityFee(uint256 _value) public view returns(uint256){
        return _value.mul(liquidityFeePercentage).div(10**4);
    }
    function getEconomyFee(uint256 _value) public view returns(uint256){
        return _value.mul(economyFeePercentage).div(10**4);
    }
    function getStakeFee(uint256 _value) public view returns(uint256){
        return _value.mul(stakeFeePercentage).div(10**4);
    }
    function getBurnFee(uint256 _value) public view returns(uint256){
        return _value.mul(burnFeePercentage).div(10**4);
    }
    
    function getAdditionalFee(uint256 _value) private pure returns(uint256){
        uint256 aditionalFee = 0;
        if(_value >= 8100 * 10**9){
            aditionalFee = _value.mul(300).div(10**4); // 300 = 3%
        }
        if(_value >= 16200 * 10**9){
            aditionalFee = _value.mul(600).div(10**4); // 600 = 6%
        }
        if(_value >= 24300 * 10**9){
            aditionalFee = _value.mul(900).div(10**4); // 900 = 9%
        }
        if(_value >= 40500 * 10**9){
            aditionalFee = _value.mul(1800).div(10**4); // 1800 = 18%
        }
        if(_value >= 64800 * 10**9){
            aditionalFee = _value.mul(2700).div(10**4); // 2700 = 27%
        }
        return aditionalFee;
    }
    
    function transfer(address to, uint value) external returns(bool) {
        require(checkFrozenAddress(msg.sender, value) == true, "the amount is greater than the amount available unlocked");
        require(balanceOf(msg.sender) >= value, 'balance too low');

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[msg.sender] || _isExcludedFromFee[to]){
            balances[to] += value;
            emit Transfer(msg.sender, to, value);
        }else{
            balances[liquidityWallet] += getLiquidityFee(value);
            balances[economyWallet] += getEconomyFee(value);
            balances[stakeFeeWallet] += getStakeFee(value);
            balances[aditionalFeeWallet] += getAdditionalFee(value);
            burnFee(msg.sender, getBurnFee(value));
            balances[to] += value.sub(getLiquidityFee(value).add(getEconomyFee(value)).add(getBurnFee(value)).add(getAdditionalFee(value)).add(getStakeFee(value)));
            emit Transfer(msg.sender, liquidityWallet, getLiquidityFee(value));
            emit Transfer(msg.sender, economyWallet, getEconomyFee(value));
            emit Transfer(msg.sender, stakeFeeWallet, getStakeFee(value));
            emit Transfer(msg.sender, aditionalFeeWallet, getAdditionalFee(value));
            emit Transfer(msg.sender, to, value.sub(getLiquidityFee(value).add(getEconomyFee(value)).add(getBurnFee(value)).add(getAdditionalFee(value)).add(getStakeFee(value))));
        }

        balances[msg.sender] -= value;
        return true;
    }

    function transferFrom(address from, address to, uint value) external returns(bool) {
        require(checkFrozenAddress(from, value) == true, "the amount is greater than the amount available unlocked");
        require(balanceOf(from) >= value, 'balance too low');
        require(allowance[from][msg.sender] >= value, 'allowance too low');

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            balances[to] += value;
            emit Transfer(from, to, value);
        }else{
            balances[liquidityWallet] += getLiquidityFee(value);
            balances[economyWallet] += getEconomyFee(value);
            balances[stakeFeeWallet] += getStakeFee(value);
            balances[aditionalFeeWallet] += getAdditionalFee(value);
            burnFee(from, getBurnFee(value));
            balances[to] += value.sub(getLiquidityFee(value).add(getEconomyFee(value)).add(getBurnFee(value)).add(getAdditionalFee(value)).add(getStakeFee(value)));
            emit Transfer(from, liquidityWallet, getLiquidityFee(value));
            emit Transfer(from, economyWallet, getEconomyFee(value));
            emit Transfer(from, stakeFeeWallet, getStakeFee(value));
            emit Transfer(from, aditionalFeeWallet, getAdditionalFee(value));
            emit Transfer(from, to, value.sub(getLiquidityFee(value).add(getEconomyFee(value)).add(getBurnFee(value)).add(getAdditionalFee(value)).add(getStakeFee(value))));
        }

        balances[from] -= value;
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);
        return true;   
    }
    
    function approve(address spender, uint value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;   
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
    function _burn(address account, uint256 amount, bool update_balance) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        if(update_balance == true){
            balances[account] = accountBalance.sub(amount);
        }
        totalSupply = totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burnFee(address account, uint256 amount) private {
        _burn(account, amount, false);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount, true);
    }

    function burnFrom(address account, uint256 amount) public {
        require(allowance[account][msg.sender] >= amount, "ERC20: burn amount exceeds allowance");
        allowance[account][msg.sender] = allowance[account][msg.sender].sub(amount);
        _burn(account, amount, true);
    }
}