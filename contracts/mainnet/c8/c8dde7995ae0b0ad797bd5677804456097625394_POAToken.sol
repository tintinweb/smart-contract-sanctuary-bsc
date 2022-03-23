// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./ERC20.sol";
import "./Owner.sol";
import "./SafeMath.sol";

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
    uint256 public liquidityFeePercentage = 0; // 200 = 2%
    uint256 public economyFeePercentage = 0; // 100 = 1%
    uint256 public burnFeePercentage = 0; // 10 = 0.1%
    uint256 public stakeFeePercentage = 0; // 100 = 1%
    uint256 public privateSaleFeePercentage = 0; // 5000 = 50%
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

    constructor() ERC20("Path of Alchemist Token", "POA") {
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