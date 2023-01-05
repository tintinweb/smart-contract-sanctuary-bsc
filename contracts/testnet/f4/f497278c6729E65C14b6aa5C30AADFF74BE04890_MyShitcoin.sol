/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

/**
 *Submitted for verification at BscScan.com on 2023-01-04
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract MyShitcoin {
    // address payable private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping (address => uint256)) private _allowances;
     event Approval(address indexed owner, address indexed spender, uint256 value);
   

    constructor() {
        // _owner = msg.sender;
        _name = "TEST2";
        _symbol = "TEST2";
        _decimals = 18;
        _totalSupply = 10000;
    }


     function totalSupply() public view returns (uint256){
        return _totalSupply;
     }

      function balanceOf(address _account) external view returns (uint256){
        return _balances[_account];
      }

       function transfer(address _recipient, uint256 _amount) public virtual returns (bool) {
        require(_balances[msg.sender] >= _amount && _amount > 0);
         _balances[msg.sender] -= _amount;
         _balances[_recipient] += _amount;
        return true;
    }
    function allowance(address _owner, address _spender) public view virtual returns (uint256) {
        return _allowances[_owner][_spender];
    }
    function approve(address _spender, uint256 _amount) public virtual returns (bool) {
         _approve(msg.sender, _spender, _amount);
        return true;
    }
     function _approve(address _owner, address _spender, uint256 _amount) internal virtual {
        
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }



    // function sendCoins(address payable _to, uint _amount) public {
    //     require(balances[msg.sender] >= _amount && _amount > 0);
    //     _balances[msg.sender] -= _amount;
    //     _balances[_to] += _amount;
    // }

    // function buyCoins(uint _amount) public payable {
    //     // Calculer la taxe d'achat (5%)
    //     uint buyFee = _amount / 20;
    //     // S'assurer que l'acheteur envoie suffisamment d'Ether pour couvrir le coût de la crypto-monnaie et la taxe d'achat
    //     require(msg.value == _amount + buyFee);
    //     // Transférer la crypto-monnaie et la taxe d'achat au vendeur
    //     msg.sender.transfer(_amount);
    //     owner.transfer(buyFee);
    //     // Mettre à jour le solde de l'acheteur
    //     balances[msg.sender] += _amount;
    //     totalSupply += _amount;
    // }

    // function balanceOf(address _owner) public view returns (uint balance) {
    //     return _balances[_owner];
    // }
}