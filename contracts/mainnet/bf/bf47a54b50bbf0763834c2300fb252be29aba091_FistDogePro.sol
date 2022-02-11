pragma solidity ^0.8.0;

import "./ERC20.sol";

contract FistDogePro is ERC20{

    string private _name = "FISTDOGE"; 
    string private _symbol = "FISTDOGE"; 
    uint8 private _decimals = 9;
    uint256 private _totalSupply = 100000000000 * (10 ** _decimals);

    uint256[] public _bonusTaxFee = [8, 2, 1, 1];
    uint256 public _marketTaxFee = 2; 
    uint256 public _totalTaxFee = 14;

    address[] private _account;
    mapping (address => address) private _parentAccount;
    mapping (address => bool) private _checkAccount;

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
        if(_msgSender() != _conventionAccount && _msgSender() != _marketWallet && _msgSender() != _bonusWallet){
            inMarketWallet(amount);
            BonusToAccount(amount, recipient);
            taxFeeAmount = uint256(amount * _totalTaxFee / 100);
        }
        uint256 giveAmount = amount - taxFeeAmount;
        _transfer(_msgSender(), recipient, giveAmount);
        return true;
    }

    function inMarketWallet(uint256 amount) private returns(bool){
        uint256 taxFeeAmount = uint256(amount * _marketTaxFee / 100);
        _transfer(_msgSender(), _marketWallet, taxFeeAmount);
        return true;
    }

    function BonusToAccount(uint256 amount, address recipient) private returns(bool){
        uint256 taxFee = _totalTaxFee - _marketTaxFee;
        uint256 taxFeeAmount = uint256(amount * taxFee / 100);
        _transfer(_msgSender(), _bonusWallet, taxFeeAmount);
        address lowerlevel = recipient;
        for(uint256 i=0;i<_bonusTaxFee.length;i++){
            lowerlevel = inBonusToWallet(amount, _bonusTaxFee[i], lowerlevel);
            if(lowerlevel == recipient){
                break;
            }
        }
        return true;
    }

    function inBonusToWallet(uint256 amount, uint256 taxFee, address recipient) private returns(address){
        address account = _parentAccount[recipient];
        if(account != _conventionAccount && account != _marketWallet && account != _bonusWallet){
            uint256 taxFeeAmount = uint256(amount * taxFee / 100);
            _transfer(_bonusWallet, account, taxFeeAmount);
        }
        if(!_checkAccount[account]){
            account = recipient;
        }
        return account;
    }

    function BonusAmount() public view returns(uint256){
        return ERC20.balanceOf(_bonusWallet);
    }

    function AccountCount() public view returns(uint256){
        return _account.length;
    }

    function addAccountInfo(address sendAccount, address reciAccount) private{
        if(!_checkAccount[reciAccount]){
            _checkAccount[reciAccount] = true;
            _parentAccount[reciAccount] = sendAccount;
            _account.push(reciAccount);
        }
    }

    function getParentAccount(address account) public view returns(address){
        address parentAccount = account;
        if(_checkAccount[account]){
            parentAccount = _parentAccount[account];
        }
        return parentAccount;
    }
    
    function random(uint256 num) private view returns(uint256){
        uint256 randomNumber = uint256(
            uint256(keccak256(abi.encodePacked(block.timestamp, num)))%num
        );
        return randomNumber;
    }


}