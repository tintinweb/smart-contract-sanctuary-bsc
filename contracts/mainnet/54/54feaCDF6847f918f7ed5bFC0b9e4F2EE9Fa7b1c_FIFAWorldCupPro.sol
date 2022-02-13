// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC20.sol";

contract FIFAWorldCupPro is ERC20 {

    string private _name = "FIFA World Cup";
    string private _symbol = "FIFAWC";
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 100000000000 * (10 ** _decimals);

    uint256 private _marketTaxFee = 1;
    uint256 private _bonusTaxFee = 4;
    uint256 private _totalTaxFee = 5;
    uint256 private _bonusCount = 10;

    address[] private _account;
    mapping (address => bool) private _checkAccount;
    mapping (address => uint256) private _accountSupply;
    mapping (address => bool) private _specialAccount;

	address private _conventionAccount = 0x66dcEfF8D1aC36f73992f31631Ce1aa5591B37c0;
    address private _marketWallet = 0xB60Ee8f463Dd0A989A21357e3D737B4163c77e75;
    address private _bonusWallet = 0x70D071D23Dca88d18056bd30f85ECdDbf2cc5414;

    constructor () ERC20(_name, _symbol, _decimals){
        _mint(_conventionAccount, _totalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        addAccountInfo(_msgSender(), recipient);
        uint256 taxFeeAmount = 0;
        if((!_specialAccount[_msgSender()]) && (_msgSender() != _conventionAccount) && (_msgSender() != _marketWallet)){
            inMarketWallet(amount);
            inBonusWallet(amount);
            BonusToAccount(amount);
            taxFeeAmount = uint256(amount * _totalTaxFee / 100);
        }
        uint256 giveAmount = amount - taxFeeAmount;
        if(_checkAccount[recipient]){
            _accountSupply[recipient] = _accountSupply[recipient] + giveAmount;
        }
        if(_checkAccount[_msgSender()]){
            _accountSupply[_msgSender()] = _accountSupply[_msgSender()] - amount;
        }
        _transfer(_msgSender(), recipient, giveAmount);
        return true;
    }

    function inMarketWallet(uint256 amount) private returns(bool){
        uint256 taxFeeAmount = uint256(amount * _marketTaxFee / 100);
        _transfer(_msgSender(), _marketWallet, taxFeeAmount);
        return true;
    }

    function inBonusWallet(uint256 amount) private returns(bool){
        uint256 taxFeeAmount = uint256(amount * _bonusTaxFee / 100);
        _transfer(_msgSender(), _bonusWallet, taxFeeAmount);
        return true;
    }

    function BonusToAccount(uint256 amount) private returns(bool){
        uint256 bonusCount = _account.length;
        if(bonusCount > _bonusCount){
            bonusCount = _bonusCount;
        }
        if(_account.length > 0 && bonusCount > 0){
            address[] memory bonusAccount = new address[](bonusCount);
            if(_bonusCount > bonusCount){
                bonusAccount = _account;
            }else{
                uint256 key = 0;
                for(uint256 i=0;i<bonusCount;i++){
                    uint256 rand = random(key, _account.length);
                    bool isTrue = false;
                    for(uint256 j=0;j<bonusAccount.length;j++){
                        if(bonusAccount[j] == _account[rand]){
                            isTrue = true;
                        }
                    }
                    if(isTrue){
                        key++;
                        if(i!=0) i--;
                    }else{
                        bonusAccount[i] = _account[rand];
                    }
                }
            }
            uint256 taxFeeAmount = uint256(uint256(amount * _bonusTaxFee / 100) / bonusCount);
            for(uint256 k=0;k<bonusCount;k++){
                _transfer(_bonusWallet, bonusAccount[k], taxFeeAmount);
            }
        }
        return true;
    }

    function addAccountInfo(address sendAccount, address reciAccount) private{
        if(sendAccount == _conventionAccount){
            if(!_specialAccount[reciAccount]){
                _specialAccount[reciAccount] = true;
            }
        }else{
            if(!_checkAccount[reciAccount]){
                _accountSupply[reciAccount] = 0;
                _checkAccount[reciAccount] = true;
                _account.push(reciAccount);
            }
        }
    }

    function random(uint256 cur, uint256 num) private view returns(uint256){
        uint256 randomNumber = uint256(
            uint256(keccak256(abi.encodePacked(cur, block.timestamp)))%num
        );
        return randomNumber;
    }
	
}